import WidgetKit
import SwiftUI

// MARK: - Basic Widget (Free) — Small & Medium sizes

struct BasicProvider: TimelineProvider {
    func placeholder(in context: Context) -> BasicEntry {
        BasicEntry(date: Date(), content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (BasicEntry) -> Void) {
        completion(BasicEntry(date: Date(), content: loadWidgetContent()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BasicEntry>) -> Void) {
        let content = loadWidgetContent()
        let entry = BasicEntry(date: Date(), content: content)
        // Refresh at midnight for new day
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

struct BasicEntry: TimelineEntry {
    let date: Date
    let content: WidgetContent
}

// MARK: - Views
//
// The layouts live in IntendedWidgetViews.swift and are shared with the
// premium widget's medium size: the free tier is the intention, today's
// actions with tap-to-record, and the month so far.

struct BasicSmallView: View {
    let entry: BasicEntry
    var body: some View { IntendedSmallView(content: entry.content) }
}

struct BasicMediumView: View {
    let entry: BasicEntry
    var body: some View { IntendedMediumView(content: entry.content) }
}

// MARK: - Widget configuration

struct IntendedBasicWidget: Widget {
    let kind: String = "IntendedBasicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BasicProvider()) { entry in
            if #available(iOS 17.0, *) {
                BasicWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetArtForFamily(content: entry.content)
                    }
            } else {
                BasicWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Intended")
        .description("Track your daily habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BasicWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: BasicEntry

    var body: some View {
        switch family {
        case .systemSmall:
            BasicSmallView(entry: entry)
        case .systemMedium:
            BasicMediumView(entry: entry)
        default:
            BasicSmallView(entry: entry)
        }
    }
}
