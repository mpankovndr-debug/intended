import WidgetKit
import SwiftUI

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

// MARK: - Habit row

struct HabitRow: View {
    let habit: HabitEntry
    let theme: ThemeData

    var body: some View {
        let textPrimary = Color(argbHex: theme.textPrimary)
        let textSecondary = Color(argbHex: theme.textSecondary)
        let checkmark = Color(argbHex: theme.checkmark)

        HStack(spacing: 10) {
            // Focus area color dot
            if let hex = habit.colorHex {
                Circle()
                    .fill(Color(argbHex: hex))
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(textSecondary.opacity(0.4))
                    .frame(width: 8, height: 8)
            }

            // Habit name
            Text(habit.name)
                .font(.system(size: 14, weight: habit.done ? .medium : .regular))
                .foregroundColor(habit.done ? textSecondary : textPrimary)
                .strikethrough(habit.done, color: textSecondary.opacity(0.5))
                .lineLimit(1)

            Spacer()

            // Checkmark
            if habit.done {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(checkmark)
            } else {
                Circle()
                    .stroke(textSecondary.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 16, height: 16)
            }
        }
    }
}

// MARK: - Progress arc

struct ProgressArc: View {
    let completed: Int
    let total: Int
    let accent: Color
    let textPrimary: Color
    let textSecondary: Color
    var size: CGFloat = 52

    private var fraction: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(completed) / CGFloat(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(accent.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(completed)")
                    .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                    .foregroundColor(accent)
                Text("/\(total)")
                    .font(.system(size: size * 0.21, weight: .medium, design: .rounded))
                    .foregroundColor(textSecondary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Premium medium view

struct PremiumMediumView: View {
    let entry: PremiumEntry

    private var content: WidgetContent { entry.content }
    private var theme: ThemeData { content.theme }
    private var strings: WidgetStrings { WidgetStrings(locale: content.locale) }
    private var showUpgrade: Bool { !content.isPremium }

    private let maxHabits = 3

    var body: some View {
        let textPrimary = Color(argbHex: theme.textPrimary)
        let textSecondary = Color(argbHex: theme.textSecondary)
        let accent = Color(argbHex: theme.accent)

        Group {
            if showUpgrade {
                degradedView(textPrimary: textPrimary, textSecondary: textSecondary, accent: accent)
            } else {
                premiumMediumContent(textPrimary: textPrimary, textSecondary: textSecondary, accent: accent)
            }
        }
        .widgetBackground(theme: theme)
    }

    private var isEmpty: Bool { content.totalCount == 0 }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }

    @ViewBuilder
    private func premiumMediumContent(textPrimary: Color, textSecondary: Color, accent: Color) -> some View {
        if isEmpty {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(content.greeting)
                        .font(.system(size: 14, weight: .medium))
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
            }
        } else if allDone {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(content.greeting)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)
                    Spacer(minLength: 6)
                    Text(strings.allDone)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                ZStack {
                    Circle()
                        .stroke(accent, lineWidth: 4)
                        .frame(width: 56, height: 56)
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(accent)
                }
            }
        } else {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(content.greeting)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)

                    Spacer(minLength: 6)

                    let visibleHabits = Array(content.habits.prefix(maxHabits))
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(visibleHabits.enumerated()), id: \.offset) { _, habit in
                            HabitRow(habit: habit, theme: theme)
                        }
                    }

                    if content.habits.count > maxHabits {
                        Text(strings.more(content.habits.count - maxHabits))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textSecondary)
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ProgressArc(
                    completed: content.completedCount,
                    total: content.totalCount,
                    accent: accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    size: 56
                )
            }
        }
    }

    @ViewBuilder
    private func degradedView(textPrimary: Color, textSecondary: Color, accent: Color) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Intended")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textSecondary)

                Spacer(minLength: 8)

                Text("\(content.completedCount)/\(content.totalCount) \(strings.today)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(textPrimary)

                Spacer(minLength: 4)

                Text(strings.upgrade(habitCount: content.totalCount))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ProgressArc(
                completed: content.completedCount,
                total: content.totalCount,
                accent: accent,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                size: 56
            )
        }
    }
}

// MARK: - Premium large view

struct PremiumLargeView: View {
    let entry: PremiumEntry

    private var content: WidgetContent { entry.content }
    private var theme: ThemeData { content.theme }
    private var strings: WidgetStrings { WidgetStrings(locale: content.locale) }
    private var showUpgrade: Bool { !content.isPremium }

    private let maxHabits = 5

    var body: some View {
        let textPrimary = Color(argbHex: theme.textPrimary)
        let textSecondary = Color(argbHex: theme.textSecondary)
        let accent = Color(argbHex: theme.accent)

        Group {
            if showUpgrade {
                degradedLargeView(textPrimary: textPrimary, textSecondary: textSecondary, accent: accent)
            } else {
                premiumLargeContent(textPrimary: textPrimary, textSecondary: textSecondary, accent: accent)
            }
        }
        .widgetBackground(theme: theme)
    }

    private var isEmpty: Bool { content.totalCount == 0 }
    private var allDone: Bool { content.totalCount > 0 && content.completedCount == content.totalCount }

    @ViewBuilder
    private func premiumLargeContent(textPrimary: Color, textSecondary: Color, accent: Color) -> some View {
        if isEmpty {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Intended")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(textSecondary)
                        Text(content.greeting)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Spacer()
                Image(systemName: "leaf")
                    .font(.system(size: 36))
                    .foregroundColor(accent.opacity(0.5))
                Text(strings.noHabits)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textSecondary)
                    .padding(.top, 8)
                Spacer()
            }
        } else if allDone {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Intended")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(textSecondary)
                        Text(content.greeting)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(accent, lineWidth: 5)
                        .frame(width: 72, height: 72)
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(accent)
                }
                Text(strings.allDone)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(textPrimary)
                    .padding(.top, 10)
                Spacer()
                Text(formattedDate())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textSecondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Intended")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(textSecondary)
                        Text(content.greeting)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textPrimary)
                            .lineLimit(2)
                    }
                    Spacer()
                    ProgressArc(
                        completed: content.completedCount,
                        total: content.totalCount,
                        accent: accent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        size: 56
                    )
                }

                Spacer(minLength: 8)

                Rectangle()
                    .fill(textSecondary.opacity(0.15))
                    .frame(height: 1)

                Spacer(minLength: 8)

                let visibleHabits = Array(content.habits.prefix(maxHabits))
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(visibleHabits.enumerated()), id: \.offset) { index, habit in
                        HabitRow(habit: habit, theme: theme)
                        if index < visibleHabits.count - 1 {
                            Spacer(minLength: 4)
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                if content.habits.count > maxHabits {
                    Text(strings.more(content.habits.count - maxHabits))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textSecondary)
                        .padding(.top, 4)
                }

                Spacer(minLength: 10)

                Text(formattedDate())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textSecondary)
            }
        }
    }

    @ViewBuilder
    private func degradedLargeView(textPrimary: Color, textSecondary: Color, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Intended")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(textSecondary)
                    Text(content.greeting)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)
                }
                Spacer()
            }

            Spacer()

            // Large centered progress
            HStack {
                Spacer()
                ProgressArc(
                    completed: content.completedCount,
                    total: content.totalCount,
                    accent: accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    size: 80
                )
                Spacer()
            }

            Spacer()

            // Upgrade CTA at bottom
            Text(strings.upgrade(habitCount: content.totalCount))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(accent)
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        formatter.locale = Locale(identifier: content.locale)
        return formatter.string(from: Date())
    }
}

// MARK: - Widget configuration

struct IntendedPremiumWidget: Widget {
    let kind: String = "IntendedPremiumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PremiumProvider()) { entry in
            if #available(iOS 17.0, *) {
                PremiumWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        LinearGradient(
                            colors: entry.content.theme.backgroundColors,
                            startPoint: UnitPoint(x: 0.3, y: 0),
                            endPoint: UnitPoint(x: 0.7, y: 1)
                        )
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
