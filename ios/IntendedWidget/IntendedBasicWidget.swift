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

// MARK: - Small widget view

struct BasicSmallView: View {
    let entry: BasicEntry

    private var content: WidgetContent { entry.content }
    private var theme: ThemeData { content.theme }
    private var strings: WidgetStrings { WidgetStrings(locale: content.locale) }
    private var isEmpty: Bool { content.totalCount == 0 }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }

    var body: some View {
        let textPrimary = Color(argbHex: theme.textPrimary)
        let textSecondary = Color(argbHex: theme.textSecondary)
        let accent = Color(argbHex: theme.accent)

        Group {
            if isEmpty {
                // Empty state
                VStack(spacing: 6) {
                    Image(systemName: "leaf")
                        .font(.system(size: 24))
                        .foregroundColor(accent.opacity(0.6))
                    Text(strings.noHabits)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(textSecondary)
                        .multilineTextAlignment(.center)
                }
            } else if allDone {
                // All done celebration
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .stroke(accent, lineWidth: 4)
                            .frame(width: 48, height: 48)
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(accent)
                    }
                    Text(strings.allDone)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            } else {
                // Normal state: centered progress arc
                VStack(spacing: 6) {
                    ProgressArc(
                        completed: content.completedCount,
                        total: content.totalCount,
                        accent: accent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        size: 48
                    )
                    Text(strings.today)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textSecondary)
                }
            }
        }
        .widgetBackground(theme: theme)
    }
}

// MARK: - Medium widget view

struct BasicMediumView: View {
    let entry: BasicEntry

    private var content: WidgetContent { entry.content }
    private var theme: ThemeData { content.theme }
    private var strings: WidgetStrings { WidgetStrings(locale: content.locale) }
    private var isEmpty: Bool { content.totalCount == 0 }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }

    var body: some View {
        let textPrimary = Color(argbHex: theme.textPrimary)
        let textSecondary = Color(argbHex: theme.textSecondary)
        let accent = Color(argbHex: theme.accent)

        Group {
            if isEmpty {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(content.greeting)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)
                        Spacer(minLength: 4)
                        Text(strings.noHabits)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "leaf")
                        .font(.system(size: 28))
                        .foregroundColor(accent.opacity(0.5))
                        .padding(.leading, 12)
                }
            } else if allDone {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(content.greeting)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)
                        Spacer(minLength: 4)
                        Text(strings.allDone)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(accent, lineWidth: 5)
                                .frame(width: 72, height: 72)
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(accent)
                        }
                        Text(strings.today)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(textSecondary)
                    }
                    .padding(.leading, 12)
                }
            } else {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(content.greeting)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)

                        Spacer(minLength: 4)

                        Text(formattedDate())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 4) {
                        ProgressArc(
                            completed: content.completedCount,
                            total: content.totalCount,
                            accent: accent,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            size: 72
                        )
                        Text(strings.today)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(textSecondary)
                    }
                    .padding(.leading, 12)
                }
            }
        }
        .widgetBackground(theme: theme)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        formatter.locale = Locale(identifier: content.locale)
        return formatter.string(from: Date())
    }
}

// MARK: - Widget configuration

struct IntendedBasicWidget: Widget {
    let kind: String = "IntendedBasicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BasicProvider()) { entry in
            if #available(iOS 17.0, *) {
                BasicWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        LinearGradient(
                            colors: entry.content.theme.backgroundColors,
                            startPoint: UnitPoint(x: 0.3, y: 0),
                            endPoint: UnitPoint(x: 0.7, y: 1)
                        )
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
