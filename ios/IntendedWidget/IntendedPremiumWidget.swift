import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Premium Widget (Intended+ only) — Medium & Large sizes

struct PremiumProvider: TimelineProvider {
    func placeholder(in context: Context) -> PremiumEntry {
        PremiumEntry(date: Date(), content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PremiumEntry) -> Void) {
        completion(PremiumEntry(date: Date(), content: loadWidgetContent()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PremiumEntry>) -> Void) {
        let content = loadWidgetContent()
        let entry = PremiumEntry(date: Date(), content: content)
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

struct PremiumEntry: TimelineEntry {
    let date: Date
    let content: WidgetContent
}

// MARK: - Views
//
// Medium is the same view the free widget shows — recording is free. Large
// is the month with its legend and all of today; without a subscription the
// month renders faded, never padlocked (IntendedWidgetViews.swift).

struct PremiumMediumView: View {
    let entry: PremiumEntry
    var body: some View { IntendedMediumView(content: entry.content) }
}

struct PremiumLargeView: View {
    let entry: PremiumEntry
    var body: some View { IntendedLargeView(content: entry.content) }
}

// MARK: - Widget configuration

struct IntendedPremiumWidget: Widget {
    let kind: String = "IntendedPremiumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PremiumProvider()) { entry in
            if #available(iOS 17.0, *) {
                PremiumWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetArtForFamily(content: entry.content)
                    }
            } else {
                PremiumWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Intended — Detailed")
        .description("See your habits, progress, and daily message.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct PremiumWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PremiumEntry

    var body: some View {
        switch family {
        case .systemMedium:
            PremiumMediumView(entry: entry)
        case .systemLarge:
            PremiumLargeView(entry: entry)
        default:
            PremiumMediumView(entry: entry)
        }
    }
}
