import Foundation

enum SessionWindowError: Error, Equatable {
    case invalidDuration
    case invalidPosterKey
    case previousWindowUnresolved
}

// Pure date-based rules. Neither observing a deadline nor reconciling the
// state performs ActivityKit calls, schedules a timer or executes in background.
struct SessionWindowEngine {
    static let maximumDuration: TimeInterval = 28_800

    func begin(
        task: CompanionTask,
        duration: TimeInterval,
        at date: Date,
        id: UUID = UUID(),
        posterKey: String = StarterCompanion.id
    ) throws -> CompanionWindow {
        guard duration.isFinite, duration > 0, duration <= Self.maximumDuration else {
            throw SessionWindowError.invalidDuration
        }
        guard CompanionWindow.isSafePosterKey(posterKey) else {
            throw SessionWindowError.invalidPosterKey
        }
        let deadline = date.addingTimeInterval(duration)
        guard deadline > date, deadline.timeIntervalSince(date).isFinite else {
            throw SessionWindowError.invalidDuration
        }
        return CompanionWindow(
            id: id,
            task: task,
            start: date,
            deadline: deadline,
            activityID: nil,
            posterKey: posterKey,
            phase: .starting
        )
    }

    func reconcile(
        _ window: CompanionWindow,
        at date: Date,
        activity: ActivitySurfaceState
    ) -> WindowPhase {
        // Apple's dismissed state is terminal for the SYSTEM activity. It
        // must not be confused with ending the user's underlying local task.
        if window.phase == .endPending {
            return (activity == .ended || activity == .dismissed) ? .finished : .endPending
        }
        if window.phase == .finished {
            return .finished
        }
        // Never reactivate an elapsed task if the system clock is adjusted
        // backward; once the task finished locally, its phase is monotonic.
        if window.phase == .elapsed {
            return .elapsed
        }
        // The task deadline is authoritative for local elapsed status, even
        // while ActivityKit remains active or only reports stale/dismissed.
        if date >= window.deadline {
            return .elapsed
        }
        if window.phase == .starting && activity == .missing {
            // A crash between request and persisted Activity ID is unresolved.
            return .starting
        }
        // An ActivityKit dismissal/end is not an instruction to stop the
        // genuine local task before its deadline.
        return .running
    }

    // Logical eligibility only; NOT proof that ActivityKit removed the old
    // activity. Use canStartNewWindow after reconciling system presentations.
    func canRestart(after window: CompanionWindow, at date: Date) -> Bool {
        window.phase != .endPending &&
            (window.phase == .finished || window.phase == .elapsed || date >= window.deadline)
    }

    // The required guard for an owner/coordinator before any NEW ActivityKit
    // request. It must supply the latest matched system state; treating an
    // unqueried state as "missing" would be unsafe.
    func canStartNewWindow(
        after current: CompanionWindow?,
        at date: Date,
        observedActivity: ActivitySurfaceState
    ) -> Bool {
        guard let current else {
            return observedActivity == .missing
        }
        guard canRestart(after: current, at: date) else {
            return false
        }
        switch observedActivity {
        case .ended, .dismissed, .missing:
            return true
        case .pending, .active, .stale:
            return false
        }
    }

    // Preferred pure start entry for Task 4: protects against a second
    // logical window while the previous task/system presentation is unresolved.
    func beginIfAllowed(
        after current: CompanionWindow?,
        observedActivity: ActivitySurfaceState,
        task: CompanionTask,
        duration: TimeInterval,
        at date: Date,
        id: UUID = UUID(),
        posterKey: String = StarterCompanion.id
    ) throws -> CompanionWindow {
        guard canStartNewWindow(after: current, at: date, observedActivity: observedActivity) else {
            throw SessionWindowError.previousWindowUnresolved
        }
        return try begin(task: task, duration: duration, at: date, id: id, posterKey: posterKey)
    }
}
