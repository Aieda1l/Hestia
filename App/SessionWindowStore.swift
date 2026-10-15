import Foundation

enum SessionWindowStoreError: Error, Equatable {
    case appGroupUnavailable
    case corruptData
    case invalidWindow
    case unresolvedWindow
}

// Exactly one current-window record. Persist this BEFORE requesting
// ActivityKit; after request, update the same UUID with its returned ID.
final class SessionWindowStore {
    static let storageKey = "hestia.session.window.v1"

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    static func appGroup() throws -> SessionWindowStore {
        try appGroup(defaults: UserDefaults(suiteName: CompanionPreferencesStore.appGroupIdentifier))
    }

    static func appGroup(defaults: UserDefaults?) throws -> SessionWindowStore {
        guard let defaults else {
            throw SessionWindowStoreError.appGroupUnavailable
        }
        return SessionWindowStore(defaults: defaults)
    }

    func load() throws -> CompanionWindow? {
        guard let raw = defaults.object(forKey: Self.storageKey) else {
            return nil
        }
        guard let data = raw as? Data,
              let window = try? JSONDecoder().decode(CompanionWindow.self, from: data),
              Self.isValid(window) else {
            throw SessionWindowStoreError.corruptData
        }
        return window
    }

    func save(_ window: CompanionWindow) throws {
        guard Self.isValid(window) else {
            throw SessionWindowStoreError.invalidWindow
        }
        // Do not silently replace unreadable data; the caller must recover it
        // explicitly rather than destroy a saved session UUID.
        if let previous = try load() {
            if previous.id != window.id {
                // A deadline being elapsed is NOT evidence that its previous
                // ActivityKit instance has terminated. The coordinator must
                // first confirm terminal state and persist .finished.
                guard previous.phase == .finished else {
                    throw SessionWindowStoreError.unresolvedWindow
                }
            } else {
                // The UUID and immutable artwork/task/time identity must
                // survive ActivityKit ID and phase updates across relaunches.
                guard previous.task == window.task,
                      previous.start == window.start,
                      previous.deadline == window.deadline,
                      previous.posterKey == window.posterKey else {
                    throw SessionWindowStoreError.invalidWindow
                }
                // Once a system ID is known, subsequent local saves cannot
                // quietly forget or switch that ActivityKit association.
                if let knownID = previous.activityID, window.activityID != knownID {
                    throw SessionWindowStoreError.invalidWindow
                }
                if previous.phase == .finished && window.phase != .finished {
                    throw SessionWindowStoreError.invalidWindow
                }
                // Writes from a delayed caller may not roll a session back
                // from ending/elapsed to running. The Task 4 coordinator is
                // the only owner allowed to confirm transition to finished.
                guard Self.isForwardPhaseTransition(from: previous.phase, to: window.phase) else {
                    throw SessionWindowStoreError.invalidWindow
                }
            }
        }
        let data = try JSONEncoder().encode(window)
        defaults.set(data, forKey: Self.storageKey)
    }

    func clear() throws {
        // A corrupt record should remain available for explicit recovery,
        // not be erased silently by a routine session transition.
        if let previous = try load(), previous.phase != .finished {
            throw SessionWindowStoreError.unresolvedWindow
        }
        defaults.removeObject(forKey: Self.storageKey)
    }

    private static func isValid(_ window: CompanionWindow) -> Bool {
        let duration = window.deadline.timeIntervalSince(window.start)
        if let activityID = window.activityID, activityID.isEmpty {
            return false
        }
        return duration.isFinite &&
            duration > 0 &&
            duration <= SessionWindowEngine.maximumDuration &&
            CompanionWindow.isSafePosterKey(window.posterKey)
    }

    private static func isForwardPhaseTransition(
        from previous: WindowPhase, to next: WindowPhase
    ) -> Bool {
        switch previous {
        case .starting:
            return true
        case .running:
            return next != .starting
        case .elapsed:
            return next == .elapsed || next == .endPending || next == .finished
        case .endPending:
            return next == .endPending || next == .finished
        case .finished:
            return next == .finished
        }
    }
}
