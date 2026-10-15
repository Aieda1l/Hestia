import Foundation
import XCTest
@testable import Hestia

final class SessionWindowEngineTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let engine = SessionWindowEngine()

    func testSixHourWindowStartsWithDurableIdentityAndImmutablePoster() throws {
        let id = UUID()
        let window = try engine.begin(
            task: .reading,
            duration: 21_600,
            at: now,
            id: id,
            posterKey: "poster-for-session"
        )
        XCTAssertEqual(window.id, id)
        XCTAssertEqual(window.task, .reading)
        XCTAssertEqual(window.start, now)
        XCTAssertEqual(window.deadline, now.addingTimeInterval(21_600))
        XCTAssertEqual(window.posterKey, "poster-for-session")
        XCTAssertNil(window.activityID)
        XCTAssertEqual(window.phase, .starting)
    }

    func testDefaultPosterUsesOriginalCompanion() throws {
        let window = try engine.begin(task: .creating, duration: 600, at: now)
        XCTAssertEqual(window.posterKey, StarterCompanion.id)
    }

    func testRejectsZeroNegativeNaNInfinityAndOverEightHours() {
        for invalid in [0.0, -1, -.infinity, .infinity, .nan, 28_801] {
            XCTAssertThrowsError(try engine.begin(task: .studying, duration: invalid, at: now)) {
                XCTAssertEqual($0 as? SessionWindowError, .invalidDuration)
            }
        }
    }

    func testMaximumEightHoursIsAccepted() throws {
        let window = try engine.begin(task: .reading, duration: 28_800, at: now)
        XCTAssertEqual(window.deadline, now.addingTimeInterval(28_800))
    }

    func testBlankPosterIsRejected() {
        XCTAssertThrowsError(
            try engine.begin(task: .creating, duration: 300, at: now, posterKey: "  \n")
        ) {
            XCTAssertEqual($0 as? SessionWindowError, .invalidPosterKey)
        }
    }

    func testUnsafePosterPathsAreRejectedButRelativePosterFileIsAllowed() throws {
        for path in ["/absolute.png", "../private.png", "sessions/../private.png",
                     "sessions//poster.png", "C:\\private.png", "sessions\\poster.png",
                     "sessions/./poster.png", "poster name.png"] {
            XCTAssertThrowsError(
                try engine.begin(task: .creating, duration: 300, at: now, posterKey: path)
            ) {
                XCTAssertEqual($0 as? SessionWindowError, .invalidPosterKey)
            }
        }
        XCTAssertEqual(
            try engine.begin(
                task: .creating, duration: 300, at: now, posterKey: "sessions/123/poster.png"
            ).posterKey,
            "sessions/123/poster.png"
        )
    }

    func testDeadlineIsElapsedEvenIfSystemStillActive() throws {
        let window = try engine.begin(task: .reading, duration: 21_600, at: now)
        XCTAssertEqual(engine.reconcile(window, at: window.deadline, activity: .active), .elapsed)
        XCTAssertEqual(
            engine.reconcile(window, at: window.deadline.addingTimeInterval(1), activity: .stale),
            .elapsed
        )
        XCTAssertTrue(engine.canRestart(after: window, at: window.deadline))
        // Logical eligibility never means the old ActivityKit presentation has ended.
        XCTAssertFalse(engine.canStartNewWindow(
            after: window,
            at: window.deadline,
            observedActivity: .active
        ))
    }

    func testStaleDismissedAndPendingAreNotLogicalCompletion() throws {
        var window = try engine.begin(task: .creating, duration: 3_600, at: now)
        window.phase = .running
        for observed in [ActivitySurfaceState.stale, .dismissed, .pending, .ended] {
            XCTAssertEqual(
                engine.reconcile(window, at: now.addingTimeInterval(10), activity: observed),
                .running
            )
        }
        XCTAssertFalse(engine.canRestart(after: window, at: now.addingTimeInterval(10)))
    }

    func testStartingWithMissingActivityRemainsUnresolved() throws {
        let window = try engine.begin(task: .reading, duration: 600, at: now)
        XCTAssertEqual(engine.reconcile(window, at: now, activity: .missing), .starting)
        XCTAssertEqual(engine.reconcile(window, at: now, activity: .active), .running)
        XCTAssertEqual(engine.reconcile(window, at: now, activity: .pending), .running)
    }

    func testEndPendingRequiresConfirmedEndAndFinishedRemainsFinished() throws {
        var window = try engine.begin(task: .studying, duration: 600, at: now)
        window.phase = .endPending
        for observed in [ActivitySurfaceState.active, .stale, .missing, .pending] {
            XCTAssertEqual(
                engine.reconcile(window, at: window.deadline.addingTimeInterval(10), activity: observed),
                .endPending
            )
        }
        XCTAssertFalse(engine.canRestart(after: window, at: window.deadline.addingTimeInterval(10)))
        XCTAssertEqual(engine.reconcile(window, at: now, activity: .ended), .finished)
        XCTAssertEqual(engine.reconcile(window, at: now, activity: .dismissed), .finished)
        window.phase = .finished
        XCTAssertEqual(engine.reconcile(window, at: now, activity: .active), .finished)
    }

    func testGuardRejectsDuplicateStartAndUnresolvedOldActivity() throws {
        let window = try engine.begin(task: .reading, duration: 3_600, at: now)
        XCTAssertThrowsError(
            try engine.beginIfAllowed(
                after: window,
                observedActivity: .missing,
                task: .studying,
                duration: 600,
                at: now.addingTimeInterval(1)
            )
        ) { XCTAssertEqual($0 as? SessionWindowError, .previousWindowUnresolved) }

        for observed in [ActivitySurfaceState.active, .stale, .pending] {
            XCTAssertFalse(engine.canStartNewWindow(
                after: window,
                at: window.deadline.addingTimeInterval(1),
                observedActivity: observed
            ))
        }
        XCTAssertFalse(engine.canStartNewWindow(
            after: nil,
            at: now,
            observedActivity: .active
        ))
        XCTAssertTrue(engine.canStartNewWindow(
            after: window,
            at: window.deadline,
            observedActivity: .dismissed
        ))
    }

    func testExplicitRestartAfterResolvedExpiryUsesNewUUID() throws {
        let first = try engine.begin(task: .reading, duration: 21_600, at: now)
        XCTAssertFalse(engine.canStartNewWindow(
            after: first,
            at: now.addingTimeInterval(20),
            observedActivity: .ended
        ))
        let second = try engine.beginIfAllowed(
            after: first,
            observedActivity: .ended,
            task: first.task,
            duration: first.deadline.timeIntervalSince(first.start),
            at: first.deadline.addingTimeInterval(1)
        )
        XCTAssertNotEqual(first.id, second.id)
        XCTAssertEqual(second.task, .reading)
        XCTAssertEqual(second.deadline.timeIntervalSince(second.start), 21_600)
        XCTAssertTrue(engine.canStartNewWindow(
            after: first,
            at: first.deadline,
            observedActivity: .missing
        ))
        XCTAssertEqual(second.phase, .starting)
    }

    func testFreshWindowOnlyWhenNoPreviouslyVisibleActivity() throws {
        XCTAssertFalse(engine.canStartNewWindow(after: nil, at: now, observedActivity: .pending))
        let first = try engine.beginIfAllowed(
            after: nil, observedActivity: .missing,
            task: .creating, duration: 600, at: now
        )
        XCTAssertEqual(first.phase, .starting)
    }
}
