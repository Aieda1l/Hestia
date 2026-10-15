import SwiftUI

enum StarterCompanion {
    static let id = "starter-orb"
    static let defaultName = "Mochi"
}

struct StarterMascotView: View {
    var body: some View {
        ZStack {
            Circle().fill(.purple.opacity(0.3))
            HStack(spacing: 12) {
                Circle().fill(.primary).frame(width: 8, height: 8)
                Circle().fill(.primary).frame(width: 8, height: 8)
            }
        }
        .frame(width: 64, height: 64)
        .accessibilityLabel("Mochi, Hestia starter companion")
    }
}
