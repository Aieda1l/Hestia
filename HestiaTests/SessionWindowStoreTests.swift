import Foundation
import XCTest
@testable import Hestia

final class SessionWindowStoreTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func withIsolatedDefaults(_ assertions: (UserDefaults) throws -> Void) throws {
        let suite = "HestiaWindowTests." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try assertions(defaults)
    }

    private func window() throws -> CompanionWindow {
        try SessionWindowEngine().begin(
            task: .studying, duration: 21_600, at: now,
            id: UUID(), posterKey: "frozen-session-poster"
        )
    }

    func testNoStoredWindowIsNilRatherThanAPlaceholderSession() throws {
        try withIsolatedDefaults { defaults in
            XCTAssertNil(try SessionWindowStore(defaults: defaults).load())
            XCTAssertNil(defaults.object(forKey: SessionWindowStore.storageKey))
        }
    }

    func testCrashAfterRequestBeforeSavingActivityIDRecoversUUID() throws {
        try withIsolatedDefaults { defaults in
            let startingWindow = try window()
            XCTAssertNil(startingWindow.activityID)
            try SessionWindowStore(defaults: defaults).save(startingWindow)

            // Simulate a new app process/store instance before Activity.request
            // returned its ID. Task 4 will use the static UUID for a system
            // lookup; this test makes no ActivityKit existence claim.
            let reopened = SessionWindowStore(defaults: defaults)
            var recovered = try XCTUnwrap(reopened.load())
            XCTAssertEqual(recovered.id, startingWindow.id)
            XCTAssertEqual(recovered.deadline, startingWindow.deadline)
            XCTAssertEqual(recovered.posterKey, startingWindow.posterKey)
            XCTAssertEqual(recovered.phase, .starting)
            XCTAssertNil(recovered.activityID)

            recovered.activityID = "observed-on-relaunch"
            recovered.phase = .running
            try reopened.save(recovered)
            XCTAssertEqual(try SessionWindowStore(defaults: defaults).load(), recovered)
        }
    }

    func testEndPendingSurvivesFreshStoreWithoutClaimingSystemEnded() throws {
        try withIsolatedDefaults { defaults in
            var pending = try window()
            pending.activityID = "known-activity"
            pending.phase = .endPending
            try SessionWindowStore(defaults: defaults).save(pending)

            let reopened = try XCTUnwrap(SessionWindowStore(defaults: defaults).load())
            XCTAssertEqual(reopened.id, pending.id)
            XCTAssertEqual(reopened.phase, .endPending)
            XCTAssertEqual(
                SessionWindowEngine().reconcile(
                    reopened,
                    at: reopened.deadline.addingTimeInterval(1),
                    activity: .stale
                ),
                .endPending
            )
        }
    }

    func testExpiringClearingWindowDoesNotTurnCompanionModeOff() throws {
        try withIsolatedDefaults { defaults in
            let preferences = CompanionPreferencesStore(defaults: defaults)
            try preferences.setModeEnabled(true)
            let store = SessionWindowStore(defaults: defaults)
            let current = try window()
            try store.save(current)
            let engine = SessionWindowEngine()
            XCTAssertEqual(
                engine.reconcile(
                    current, at: current.deadline.addingTimeInterval(1), activity: .active
                ),
                .elapsed
            )
            // Task 4 must resolve the old system activity BEFORE calling the
            // primitive clear operation or starting a replacement session.
            XCTAssertFalse(engine.canStartNewWindow(
                after: current,
                at: current.deadline.addingTimeInterval(1),
                observedActivity: .active
            ))
            XCTAssertTrue(engine.canStartNewWindow(
                after: current,
                at: current.deadline.addingTimeInterval(1),
                observedActivity: .ended
            ))
            XCTAssertThrowsError(try store.clear()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .unresolvedWindow)
            }
            XCTAssertEqual(try store.load(), current)
            // After Task 4 CONFIRMS a terminal activity, it may mark this
            // persisted logical window finished and then clear it safely.
            var finished = current
            finished.phase = .finished
            try store.save(finished)
            try store.clear()
            XCTAssertNil(try SessionWindowStore(defaults: defaults).load())
            let reopenedPreferences = try CompanionPreferencesStore(defaults: defaults).load()
            XCTAssertTrue(reopenedPreferences.modeEnabled)
            XCTAssertEqual(reopenedPreferences.lastDuration, 21_600)
            XCTAssertEqual(reopenedPreferences.lastTask, .creating)
        }
    }

    func testGroupProviderNilFailsExplicitly() {
        XCTAssertThrowsError(try SessionWindowStore.appGroup(defaults: nil)) {
            XCTAssertEqual($0 as? SessionWindowStoreError, .appGroupUnavailable)
        }
    }

    func testWrongStoredTypeThrowsWithoutRemovingData() throws {
        try withIsolatedDefaults { defaults in
            defaults.set("wrong type", forKey: SessionWindowStore.storageKey)
            let store = SessionWindowStore(defaults: defaults)
            XCTAssertThrowsError(try store.load()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
            XCTAssertThrowsError(try store.save(try window())) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
            XCTAssertThrowsError(try store.clear()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
            XCTAssertEqual(defaults.string(forKey: SessionWindowStore.storageKey), "wrong type")
        }
    }

    func testInvalidJSONBytesSurviveFailedOperations() throws {
        try withIsolatedDefaults { defaults in
            let original = Data("malformed session record".utf8)
            defaults.set(original, forKey: SessionWindowStore.storageKey)
            let store = SessionWindowStore(defaults: defaults)
            XCTAssertThrowsError(try store.load()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
            XCTAssertThrowsError(try store.save(try window())) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
            XCTAssertEqual(defaults.data(forKey: SessionWindowStore.storageKey), original)
        }
    }

    func testSemanticallyInvalidStoredWindowIsCorrupt() throws {
        try withIsolatedDefaults { defaults in
            var invalid = try window()
            invalid.activityID = ""
            let raw = try JSONEncoder().encode(invalid)
            defaults.set(raw, forKey: SessionWindowStore.storageKey)
            XCTAssertThrowsError(try SessionWindowStore(defaults: defaults).load()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
            XCTAssertEqual(defaults.data(forKey: SessionWindowStore.storageKey), raw)
        }
    }

    func testUnsafeRelativePosterKeyIsRejectedOnSaveAndLoad() throws {
        try withIsolatedDefaults { defaults in
            let invalid = CompanionWindow(
                id: UUID(), task: .reading, start: now,
                deadline: now.addingTimeInterval(3_600),
                activityID: nil, posterKey: "sessions/../../outside.png", phase: .starting
            )
            let store = SessionWindowStore(defaults: defaults)
            XCTAssertThrowsError(try store.save(invalid)) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .invalidWindow)
            }
            defaults.set(try JSONEncoder().encode(invalid), forKey: SessionWindowStore.storageKey)
            XCTAssertThrowsError(try store.load()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .corruptData)
            }
        }
    }

    func testInvalidWindowRejectedBeforeOverwritingExistingRecord() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            let valid = try window()
            try store.save(valid)
            let before = try XCTUnwrap(defaults.data(forKey: SessionWindowStore.storageKey))

            let invalid = CompanionWindow(
                id: UUID(), task: .reading, start: now,
                deadline: now.addingTimeInterval(28_801),
                activityID: nil, posterKey: "poster", phase: .starting
            )
            XCTAssertThrowsError(try store.save(invalid)) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .invalidWindow)
            }
            XCTAssertEqual(defaults.data(forKey: SessionWindowStore.storageKey), before)
            XCTAssertEqual(try store.load(), valid)
        }
    }

    func testClearWithoutExistingWindowIsIdempotent() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            try store.clear()
            try store.clear()
            XCTAssertNil(try store.load())
        }
    }

    func testDifferentUUIDCannotOverwriteUnresolvedWindow() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            var original = try window()
            let replacement = try SessionWindowEngine().begin(
                task: .reading, duration: 600, at: now.addingTimeInterval(60)
            )
            XCTAssertNotEqual(original.id, replacement.id)
            for phase in [WindowPhase.starting, .running, .elapsed, .endPending] {
                original.phase = phase
                try store.save(original)
                let before = try XCTUnwrap(defaults.data(forKey: SessionWindowStore.storageKey))
                XCTAssertThrowsError(try store.save(replacement)) {
                    XCTAssertEqual($0 as? SessionWindowStoreError, .unresolvedWindow)
                }
                XCTAssertEqual(defaults.data(forKey: SessionWindowStore.storageKey), before)
                XCTAssertEqual(try store.load(), original)
            }
        }
    }

    func testCannotClearActiveElapsedOrEndPendingWindow() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            var current = try window()
            for phase in [WindowPhase.starting, .running, .elapsed, .endPending] {
                current.phase = phase
                try store.save(current)
                let before = try XCTUnwrap(defaults.data(forKey: SessionWindowStore.storageKey))
                XCTAssertThrowsError(try store.clear()) {
                    XCTAssertEqual($0 as? SessionWindowStoreError, .unresolvedWindow)
                }
                XCTAssertEqual(defaults.data(forKey: SessionWindowStore.storageKey), before)
            }
        }
    }

    func testFinishedWindowCanBeClearedOrReplacedWithNewUUID() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            var old = try window()
            old.phase = .finished  // Only after the future coordinator verifies terminal state.
            try store.save(old)

            let replacement = try SessionWindowEngine().begin(
                task: .reading, duration: 3_600, at: old.deadline.addingTimeInterval(60)
            )
            try store.save(replacement)
            XCTAssertEqual(try store.load(), replacement)
            XCTAssertThrowsError(try store.clear()) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .unresolvedWindow)
            }

            var finishedReplacement = replacement
            finishedReplacement.phase = .finished
            try store.save(finishedReplacement)
            try store.clear()
            XCTAssertNil(try store.load())
        }
    }

    func testSameUUIDCannotRewriteImmutablePosterOrDeadline() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            let first = try window()
            try store.save(first)
            let tampered = CompanionWindow(
                id: first.id, task: first.task, start: first.start,
                deadline: first.deadline, activityID: "observed-activity",
                posterKey: "other-poster.png", phase: .running
            )
            XCTAssertThrowsError(try store.save(tampered)) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .invalidWindow)
            }
            XCTAssertEqual(try store.load(), first)
        }
    }

    func testKnownActivityIDCannotBeLostOnLaterWrite() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            var current = try window()
            current.activityID = "actual-id"
            current.phase = .running
            try store.save(current)

            var missingID = current
            missingID.activityID = nil
            XCTAssertThrowsError(try store.save(missingID)) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .invalidWindow)
            }
            XCTAssertEqual(try store.load(), current)
        }
    }

    func testEndPendingCannotRegressToRunning() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            var current = try window()
            current.activityID = "observed-id"
            current.phase = .endPending
            try store.save(current)
            for earlier in [WindowPhase.starting, .running, .elapsed] {
                var staleWrite = current
                staleWrite.phase = earlier
                XCTAssertThrowsError(try store.save(staleWrite)) {
                    XCTAssertEqual($0 as? SessionWindowStoreError, .invalidWindow)
                }
                XCTAssertEqual(try store.load(), current)
            }
            var finished = current
            finished.phase = .finished
            try store.save(finished)
            XCTAssertEqual(try store.load(), finished)
        }
    }

    func testElapsedSessionCannotRegressToRunning() throws {
        try withIsolatedDefaults { defaults in
            let store = SessionWindowStore(defaults: defaults)
            var elapsed = try window()
            elapsed.phase = .elapsed
            try store.save(elapsed)
            var stale = elapsed
            stale.phase = .running
            XCTAssertThrowsError(try store.save(stale)) {
                XCTAssertEqual($0 as? SessionWindowStoreError, .invalidWindow)
            }
            XCTAssertEqual(try store.load(), elapsed)
        }
    }
}
