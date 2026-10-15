import Foundation
import XCTest
@testable import Hestia

final class CompanionPreferencesTests: XCTestCase {
    private func withIsolatedDefaults(_ assertions: (UserDefaults) throws -> Void) throws {
        let suiteName = "HestiaTests." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try assertions(defaults)
    }

    func testMissingPreferencesUseDocumentedDefaults() throws {
        try withIsolatedDefaults { defaults in
            let preferences = try CompanionPreferencesStore(defaults: defaults).load()
            XCTAssertEqual(preferences.selectedID, "starter-orb")
            XCTAssertEqual(preferences.name, "Mochi")
            XCTAssertFalse(preferences.modeEnabled)
            XCTAssertFalse(preferences.reducedMotion)
            XCTAssertEqual(preferences.lastTask, .creating)
            XCTAssertEqual(preferences.lastDuration, 21_600)
            XCTAssertNil(defaults.object(forKey: CompanionPreferencesStore.storageKey))
        }
    }

    func testCompanionModePersistsAcrossFreshInstancesUntilStopped() throws {
        try withIsolatedDefaults { defaults in
            let first = CompanionPreferencesStore(defaults: defaults)
            XCTAssertFalse(try first.load().modeEnabled)

            try first.setModeEnabled(true)
            XCTAssertTrue(try CompanionPreferencesStore(defaults: defaults).load().modeEnabled)

            try CompanionPreferencesStore(defaults: defaults).setModeEnabled(false)
            XCTAssertFalse(try CompanionPreferencesStore(defaults: defaults).load().modeEnabled)
        }
    }

    func testLastTaskDurationAndCompanionIdentitySurviveReopening() throws {
        try withIsolatedDefaults { defaults in
            let first = CompanionPreferencesStore(defaults: defaults)
            var preferences = try first.load()
            preferences.selectedID = "original-sprite"
            preferences.name = "Pip"
            preferences.lastTask = .reading
            preferences.lastDuration = 3_600
            preferences.reducedMotion = true
            preferences.modeEnabled = true
            try first.save(preferences)

            let reopened = try CompanionPreferencesStore(defaults: defaults).load()
            XCTAssertEqual(reopened, preferences)
        }
    }

    func testEditingLastTaskDoesNotSilentlyResetEnabledMode() throws {
        try withIsolatedDefaults { defaults in
            let first = CompanionPreferencesStore(defaults: defaults)
            try first.setModeEnabled(true)

            let reopened = CompanionPreferencesStore(defaults: defaults)
            var updated = try reopened.load()
            updated.lastTask = .studying
            updated.lastDuration = 7_200
            try reopened.save(updated)

            let afterReopen = try CompanionPreferencesStore(defaults: defaults).load()
            XCTAssertTrue(afterReopen.modeEnabled)
            XCTAssertEqual(afterReopen.lastTask, .studying)
            XCTAssertEqual(afterReopen.lastDuration, 7_200)
        }
    }

    func testCorruptDataThrowsWithoutDiscardingTheSavedBytes() throws {
        try withIsolatedDefaults { defaults in
            let corruptData = Data("not a JSON preferences object".utf8)
            defaults.set(corruptData, forKey: CompanionPreferencesStore.storageKey)
            let store = CompanionPreferencesStore(defaults: defaults)

            XCTAssertThrowsError(try store.load()) { error in
                XCTAssertEqual(error as? CompanionPreferencesStoreError, .corruptData)
            }
            XCTAssertThrowsError(try store.setModeEnabled(false)) { error in
                XCTAssertEqual(error as? CompanionPreferencesStoreError, .corruptData)
            }
            XCTAssertEqual(defaults.data(forKey: CompanionPreferencesStore.storageKey), corruptData)
        }
    }

    func testUnexpectedStoredTypeIsNotMistakenForFirstLaunch() throws {
        try withIsolatedDefaults { defaults in
            defaults.set("unexpected string", forKey: CompanionPreferencesStore.storageKey)

            XCTAssertThrowsError(try CompanionPreferencesStore(defaults: defaults).load()) { error in
                XCTAssertEqual(error as? CompanionPreferencesStoreError, .corruptData)
            }
            XCTAssertEqual(defaults.string(forKey: CompanionPreferencesStore.storageKey),
                           "unexpected string")
        }
    }

    func testNilAppGroupDefaultsIsExplicitlyUnavailable() {
        XCTAssertThrowsError(try CompanionPreferencesStore.appGroup(defaults: nil)) { error in
            XCTAssertEqual(error as? CompanionPreferencesStoreError, .appGroupUnavailable)
        }
    }

    func testFailedEncodingDoesNotOverwriteSavedMode() throws {
        try withIsolatedDefaults { defaults in
            let store = CompanionPreferencesStore(defaults: defaults)
            try store.setModeEnabled(true)
            let bytesBefore = try XCTUnwrap(defaults.data(forKey: CompanionPreferencesStore.storageKey))

            var invalid = try store.load()
            invalid.lastDuration = .nan
            XCTAssertThrowsError(try store.save(invalid))

            XCTAssertEqual(defaults.data(forKey: CompanionPreferencesStore.storageKey), bytesBefore)
            XCTAssertTrue(try CompanionPreferencesStore(defaults: defaults).load().modeEnabled)
        }
    }
}
