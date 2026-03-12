import WidgetKit
import SwiftUI

// MARK: - Lock Screen Widgets (Free for all users) — iOS 16+

@available(iOS 16.0, *)
struct LockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenEntry {
        LockScreenEntry(date: Date(), content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LockScreenEntry) -> Void) {
        completion(LockScreenEntry(date: Date(), content: loadWidgetContent()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenEntry>) -> Void) {
        let content = loadWidgetContent()
        let entry = LockScreenEntry(date: Date(), content: content)
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

@available(iOS 16.0, *)
struct LockScreenEntry: TimelineEntry {
    let date: Date
    let content: WidgetContent
}

// MARK: - Accessory Circular

@available(iOS 16.0, *)
struct AccessoryCircularView: View {
    let entry: LockScreenEntry

    private var content: WidgetContent { entry.content }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }
    private var fraction: Double {
        guard content.totalCount > 0 else { return 0 }
        return Double(content.completedCount) / Double(content.totalCount)
    }

    var body: some View {
        if content.totalCount == 0 {
            // Empty state
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "leaf")
                    .font(.system(size: 16))
            }
        } else if allDone {
            // All done
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
            }
        } else {
            // Progress gauge
            Gauge(value: fraction) {
                Text("")
            } currentValueLabel: {
                VStack(spacing: -2) {
                    Text("\(content.completedCount)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("/\(content.totalCount)")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                }
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}

// MARK: - Accessory Inline

@available(iOS 16.0, *)
struct AccessoryInlineView: View {
    let entry: LockScreenEntry

    private var content: WidgetContent { entry.content }
    private var strings: WidgetStrings { WidgetStrings(locale: content.locale) }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }

    var body: some View {
        if content.totalCount == 0 {
            Text(strings.noHabits)
        } else if allDone {
            Text("\(Image(systemName: "checkmark.circle.fill")) \(strings.allDone)")
        } else {
            Text("\(content.completedCount)/\(content.totalCount) \(strings.today)")
        }
    }
}

// MARK: - Accessory Rectangular

@available(iOS 16.0, *)
struct AccessoryRectangularView: View {
    let entry: LockScreenEntry

    private var content: WidgetContent { entry.content }
    private var strings: WidgetStrings { WidgetStrings(locale: content.locale) }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }

    var body: some View {
        if content.totalCount == 0 {
            VStack(alignment: .leading, spacing: 2) {
                Text("Intended")
                    .font(.headline)
                    .widgetAccentable()
                Text(strings.noHabits)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if allDone {
            VStack(alignment: .leading, spacing: 2) {
                Text("Intended")
                    .font(.headline)
                    .widgetAccentable()
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text(strings.allDone)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(content.completedCount)/\(content.totalCount)")
                        .font(.headline)
                        .widgetAccentable()
                    Text(strings.today)
                        .font(.headline)
                }
                // Show top 2 habits
                let visible = Array(content.habits.prefix(2))
                ForEach(Array(visible.enumerated()), id: \.offset) { _, habit in
                    HStack(spacing: 4) {
                        Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 9))
                        Text(habit.name)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Widget configuration

@available(iOS 16.0, *)
struct IntendedLockScreenWidget: Widget {
    let kind: String = "IntendedLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenProvider()) { entry in
            LockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("Intended")
        .description("Quick glance at your daily progress.")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

@available(iOS 16.0, *)
struct LockScreenEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: LockScreenEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            AccessoryCircularView(entry: entry)
        }
    }
}
