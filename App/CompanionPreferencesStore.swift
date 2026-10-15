import Foundation

enum CompanionPreferencesStoreError: Error, Equatable {
    case appGroupUnavailable
    case corruptData
}

final class CompanionPreferencesStore {
    static let appGroupIdentifier = "group.com.example.Hestia"
    static let storageKey = "hestia.companion.preferences.v1"

    private let defaults: UserDefaults

    // Inject a test suite to keep unit tests isolated from real companion data.
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    // Do not fall back to UserDefaults.standard if the entitled group is missing.
    static func appGroup() throws -> CompanionPreferencesStore {
        try appGroup(defaults: UserDefaults(suiteName: appGroupIdentifier))
    }

    static func appGroup(defaults: UserDefaults?) throws -> CompanionPreferencesStore {
        guard let defaults else {
            throw CompanionPreferencesStoreError.appGroupUnavailable
        }
        return CompanionPreferencesStore(defaults: defaults)
    }

    func load() throws -> CompanionPreferences {
        guard let storedValue = defaults.object(forKey: Self.storageKey) else {
            return .initial
        }

        // Existing but wrong-typed data is corrupt, not an empty first launch.
        guard let data = storedValue as? Data else {
            throw CompanionPreferencesStoreError.corruptData
        }

        do {
            return try JSONDecoder().decode(CompanionPreferences.self, from: data)
        } catch {
            throw CompanionPreferencesStoreError.corruptData
        }
    }

    func save(_ preferences: CompanionPreferences) throws {
        // Encode first; if this fails, never overwrite previously saved values.
        let data = try JSONEncoder().encode(preferences)
        defaults.set(data, forKey: Self.storageKey)
    }

    func setModeEnabled(_ enabled: Bool) throws {
        var preferences = try load()
        preferences.modeEnabled = enabled
        try save(preferences)
    }
}
