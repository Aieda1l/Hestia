import Foundation

enum CompanionTask: String, Codable, CaseIterable {
    case reading
    case studying
    case creating
}

struct CompanionPreferences: Codable, Equatable {
    var selectedID: String
    var name: String
    var modeEnabled: Bool
    var reducedMotion: Bool
    var lastTask: CompanionTask
    var lastDuration: TimeInterval

    static let initial = CompanionPreferences(
        selectedID: StarterCompanion.id,
        name: StarterCompanion.defaultName,
        modeEnabled: false,
        reducedMotion: false,
        lastTask: .creating,
        lastDuration: 21_600
    )
}

// A task window is a finite logical session, independent from whether iOS
// displays its Live Activity. The poster identity cannot change mid-session.
enum WindowPhase: String, Codable, Equatable {
    case starting
    case running
    case elapsed
    case endPending
    case finished
}

// Observed system presentation, not a second logical session state.
// Stale is nonterminal; dismissed and ended are terminal system states,
// but neither state by itself stops the user's separate logical task early.
enum ActivitySurfaceState: Equatable {
    case pending
    case active
    case stale
    case ended
    case dismissed
    case missing
}

struct CompanionWindow: Codable, Equatable, Identifiable {
    let id: UUID
    let task: CompanionTask
    let start: Date
    let deadline: Date
    var activityID: String?
    let posterKey: String
    var phase: WindowPhase

    // Internal relative asset key (e.g. "poster-123.png" or
    // "sessions/123/poster.png"), never a user-supplied filesystem path.
    // Keeping this validation beside the model prevents decoded records from
    // bypassing the same constraint enforced when creating a new window.
    static func isSafePosterKey(_ key: String) -> Bool {
        guard !key.isEmpty, !key.hasPrefix("/") else {
            return false
        }
        let allowed = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/"
        )
        guard key.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return false
        }
        return key.split(separator: "/", omittingEmptySubsequences: false).allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }
}
