import SwiftUI
import WidgetKit

// Temporary, static bootstrap widget. ActivityConfiguration is a later task.
private struct BootstrapEntry: TimelineEntry {
    let date: Date
}

private struct BootstrapProvider: TimelineProvider {
    func placeholder(in context: Context) -> BootstrapEntry {
        BootstrapEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (BootstrapEntry) -> Void) {
        completion(BootstrapEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BootstrapEntry>) -> Void) {
        completion(Timeline(entries: [BootstrapEntry(date: Date())], policy: .never))
    }
}

private struct BootstrapWidget: Widget {
    private let kind = "HestiaBootstrap"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BootstrapProvider()) { _ in
            VStack(spacing: 8) {
                StarterMascotView()
                Text(StarterCompanion.defaultName)
                    .font(.caption)
            }
            .containerBackground(for: .widget) {
                Color.purple.opacity(0.08)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Mochi, Hestia starter companion widget")
        }
        .configurationDisplayName("Hestia Bootstrap")
        .description("Temporary widget for verifying the Hestia extension.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct HestiaWidgets: WidgetBundle {
    var body: some Widget {
        BootstrapWidget()
    }
}
