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
