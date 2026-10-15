import SwiftUI

private struct CompanionPreferencesStoreKey: EnvironmentKey {
    static let defaultValue: CompanionPreferencesStore? = nil
}

extension EnvironmentValues {
    var companionPreferencesStore: CompanionPreferencesStore? {
        get { self[CompanionPreferencesStoreKey.self] }
        set { self[CompanionPreferencesStoreKey.self] = newValue }
    }
}

@main
struct HestiaApp: App {
    @State private var preferencesSetup: Result<CompanionPreferencesStore, Error>

    init() {
        _preferencesSetup = State(initialValue: Self.openCompanionStore())
    }

    private static func openCompanionStore() -> Result<CompanionPreferencesStore, Error> {
        Result {
            let store = try CompanionPreferencesStore.appGroup()
            // Surface corrupt existing data instead of silently resetting it.
            _ = try store.load()
            return store
        }
    }

    var body: some Scene {
        WindowGroup {
            switch preferencesSetup {
            case .success(let store):
                // Task 5 can read this store from the environment.
                StarterMascotView()
                    .environment(\.companionPreferencesStore, store)
            case .failure(let error):
                VStack(spacing: 12) {
                    Image(systemName: "externaldrive.badge.exclamationmark")
                        .font(.largeTitle)
                        .accessibilityHidden(true)
                    Text("Companion storage unavailable")
                        .font(.headline)
                    Text((error as? CompanionPreferencesStoreError) == .corruptData
                         ? "Saved companion settings could not be read. Nothing was reset. Your data is preserved."
                         : "Shared companion storage could not be opened. Nothing was reset. You can retry.")
                        .multilineTextAlignment(.center)
                    Button("Retry opening companion") {
                        preferencesSetup = Self.openCompanionStore()
                    }
                }
                .padding()
            }
        }
    }
}
