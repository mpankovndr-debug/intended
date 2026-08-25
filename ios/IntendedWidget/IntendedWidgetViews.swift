import AppIntents
import SwiftUI
import WidgetKit

// MARK: - The home-screen widgets' shared views
//
// The intention as the title, the month as colours, today's actions as tap
// targets — on the theme's painting. No ring, no denominator, no wordmark
// (CLAUDE.md: no scores; HIG: people seldom need your logo). Everything
// worded arrives pre-localised from the app; this file only lays it out.

// MARK: Type scale (points). Russian runs longer, so its display sizes step down.

struct WidgetType {
    let isRu: Bool
    init(locale: String) { isRu = locale == "ru" }

    var intentSmall: CGFloat { isRu ? 14 : 15 }
    var intentMedium: CGFloat { isRu ? 16 : 18 }
    var intentLarge: CGFloat { isRu ? 19 : 22 }
    var eyebrowSmall: CGFloat { 11.5 }
    var eyebrowMedium: CGFloat { 12 }
    var eyebrowLarge: CGFloat { 12.5 }
    var legend: CGFloat { 12.5 }
    var actionSmall: CGFloat { isRu ? 12.5 : 13 }
    var actionMedium: CGFloat { isRu ? 13 : 14 }
    var actionLarge: CGFloat { isRu ? 14.5 : 15.5 }
    var time: CGFloat { 12 }
}

// MARK: Background — theme gradient, the theme's painting, the share card's wash

struct WidgetArtBackground: View {
    let content: WidgetContent
    let wide: Bool

    var body: some View {
        let theme = content.theme
        ZStack {
            LinearGradient(
                colors: theme.backgroundColors,
                startPoint: UnitPoint(x: 0.3, y: 0),
                endPoint: UnitPoint(x: 0.7, y: 1)
            )
            if let path = wide ? content.artWidePath : content.artSquarePath,
               let image = UIImage(contentsOfFile: path) {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                // The wash between the painting and the type, lifted from
                // season_share_card.dart: light themes breathe white, dark
                // ones deepen their own ground instead of greying it.
                let wash = theme.isDark ? Color(argbHex: theme.bgTop) : Color.white
                LinearGradient(
                    stops: [
                        .init(color: wash.opacity(0.55), location: 0),
                        .init(color: wash.opacity(0.14), location: 0.42),
                        .init(color: wash.opacity(0.42), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

/// Picks the crop by family from inside `containerBackground`, where the
/// widget family environment is still available.
struct WidgetArtForFamily: View {
    @Environment(\.widgetFamily) private var family
    let content: WidgetContent

    var body: some View {
        WidgetArtBackground(content: content, wide: family == .systemMedium)
    }
}

extension View {
    /// iOS 17 paints the art through `containerBackground` and applies the
    /// system content margins itself; iOS 16 gets both here.
    @ViewBuilder
    func widgetArt(content: WidgetContent, wide: Bool) -> some View {
        if #available(iOS 17.0, *) {
            self
        } else {
            ZStack {
                WidgetArtBackground(content: content, wide: wide)
                self.padding(16)
            }
        }
    }
}

// MARK: Tiles — one rounded square per moment, with the grid's own gradient

/// `moment_grid.dart`: a lift of +0.07 lightness toward the top-left, the base
/// at 55%, a −0.05 shade at the bottom-right, corner radius 0.28 × size.
struct MomentTile: View {
    let hex: String

    var body: some View {
        GeometryReader { geo in
            let (h, s, l) = hsl(ofArgbHex: hex)
            RoundedRectangle(cornerRadius: geo.size.width * 0.28, style: .continuous)
                .fill(LinearGradient(
                    stops: [
                        .init(color: color(h: h, s: s, l: min(1, l + 0.07)), location: 0),
                        .init(color: color(h: h, s: s, l: l), location: 0.55),
                        .init(color: color(h: h, s: s, l: max(0, l - 0.05)), location: 1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
    }
}

/// Fixed-size tiles flowing left to right, newest last. When the month has
/// more moments than fit in `maxRows`, the *oldest* are hidden — the widget
/// shows the latest stretch and the eyebrow says how many there are in all.
/// There is never an empty cell: the last row simply ends.
struct MosaicFlow: Layout {
    let tile: CGFloat
    let spacing: CGFloat
    let maxRows: Int

    private func perRow(for width: CGFloat) -> Int {
        guard width.isFinite, width > 0 else { return 1 }
        return max(1, Int(((width + spacing) / (tile + spacing)).rounded(.down)))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let natural = CGFloat(max(1, subviews.count)) * (tile + spacing) - spacing
        let width = (proposal.width?.isFinite ?? false) ? proposal.width! : natural
        let per = perRow(for: width)
        let shown = min(subviews.count, per * maxRows)
        let rows = shown == 0 ? 0 : Int((Double(shown) / Double(per)).rounded(.up))
        let height = rows == 0 ? 0 : CGFloat(rows) * (tile + spacing) - spacing
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let per = perRow(for: bounds.width)
        let skip = max(0, subviews.count - per * maxRows)
        for (i, sub) in subviews.enumerated() {
            if i < skip {
                sub.place(at: bounds.origin, proposal: ProposedViewSize(width: 0, height: 0))
                continue
            }
            let j = i - skip
            let x = bounds.minX + CGFloat(j % per) * (tile + spacing)
            let y = bounds.minY + CGFloat(j / per) * (tile + spacing)
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: tile, height: tile))
        }
    }
}

/// Variable-width chips wrapping onto new lines (the legend).
struct WrapFlow: Layout {
    var spacing: CGFloat = 14
    var lineSpacing: CGFloat = 4

    private func rows(for width: CGFloat, subviews: Subviews) -> [[(Int, CGSize)]] {
        var result: [[(Int, CGSize)]] = [[]]
        var x: CGFloat = 0
        for (i, sub) in subviews.enumerated() {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                result.append([])
                x = 0
            }
            result[result.count - 1].append((i, size))
            x += size.width + spacing
        }
        return result
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = (proposal.width?.isFinite ?? false) ? proposal.width! : .greatestFiniteMagnitude
        let rows = rows(for: width, subviews: subviews)
        var height: CGFloat = 0
        var used: CGFloat = 0
        for row in rows {
            var rowHeight: CGFloat = 0
            var rowWidth: CGFloat = 0
            for (_, size) in row {
                rowHeight = max(rowHeight, size.height)
                rowWidth += size.width
            }
            rowWidth += CGFloat(max(0, row.count - 1)) * spacing
            height += rowHeight
            used = max(used, rowWidth)
        }
        height += CGFloat(max(0, rows.count - 1)) * lineSpacing
        return CGSize(width: width.isFinite ? width : used, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(for: bounds.width, subviews: subviews) {
            var x = bounds.minX
            let rowHeight = row.map { $0.1.height }.max() ?? 0
            for (i, size) in row {
                subviews[i].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + lineSpacing
        }
    }
}

// MARK: Pieces

struct IntentionText: View {
    let text: String
    let size: CGFloat
    let theme: ThemeData

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .semibold))
            .foregroundColor(Color(argbHex: theme.textPrimary))
            .lineLimit(2)
            .minimumScaleFactor(0.9)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct EyebrowText: View {
    let text: String
    let size: CGFloat
    let theme: ThemeData

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .medium))
            .foregroundColor(Color(argbHex: theme.textSecondary))
            .lineLimit(1)
    }
}

struct Mosaic: View {
    let hexes: [String]
    let tile: CGFloat
    let spacing: CGFloat
    let maxRows: Int

    var body: some View {
        MosaicFlow(tile: tile, spacing: spacing, maxRows: maxRows) {
            ForEach(Array(hexes.enumerated()), id: \.offset) { _, hex in
                MomentTile(hex: hex)
            }
        }
    }
}

struct LegendRow: View {
    let entries: [LegendEntry]
    let size: CGFloat
    let theme: ThemeData

    var body: some View {
        WrapFlow(spacing: 14, lineSpacing: 4) {
            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                HStack(spacing: 5) {
                    Circle().fill(Color(argbHex: entry.hex)).frame(width: 7, height: 7)
                    Text(entry.label)
                        .font(.system(size: size, weight: .medium))
                        .foregroundColor(Color(argbHex: theme.textSecondary))
                        .lineLimit(1)
                }
            }
        }
    }
}

/// One action: a tap target that records the moment (iOS 17), the name, and —
/// once done — the wall-clock time it was recorded.
struct ActionRow: View {
    let habit: HabitEntry
    let theme: ThemeData
    let size: CGFloat
    let target: CGFloat
    var timeSize: CGFloat = 12
    var showTime: Bool = false

    var body: some View {
        let primary = Color(argbHex: theme.textPrimary)
        let secondary = Color(argbHex: theme.textSecondary)
        let tertiary = Color(argbHex: theme.textTertiary)
        // The check is drawn in the ground colour so it reads on dark themes too.
        let checkInk = theme.isDark ? Color(argbHex: theme.bgTop) : Color.white

        HStack(spacing: 10) {
            if habit.done {
                ZStack {
                    Circle().fill(primary)
                    Image(systemName: "checkmark")
                        .font(.system(size: target * 0.46, weight: .bold))
                        .foregroundColor(checkInk)
                }
                .frame(width: target, height: target)
            } else if #available(iOS 17.0, *) {
                Button(intent: CompleteHabitIntent(habitName: habit.trackingName)) {
                    Circle()
                        .strokeBorder(primary.opacity(0.55), lineWidth: 1.75)
                        .frame(width: target, height: target)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                Circle()
                    .strokeBorder(primary.opacity(0.55), lineWidth: 1.75)
                    .frame(width: target, height: target)
            }

            Text(habit.name)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(habit.done ? secondary : primary)
                .lineLimit(1)

            if showTime, habit.done, let at = habit.doneAt {
                Spacer(minLength: 6)
                Text(at)
                    .font(.system(size: timeSize, weight: .medium))
                    .foregroundColor(tertiary)
            } else {
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: Small — the intention, then the month so far

struct IntendedSmallView: View {
    let content: WidgetContent

    var body: some View {
        let type = WidgetType(locale: content.locale)
        let strings = WidgetStrings(locale: content.locale)
        let theme = content.theme

        VStack(alignment: .leading, spacing: 0) {
            IntentionText(text: content.greeting, size: type.intentSmall, theme: theme)
            Spacer(minLength: 6)
            if !content.monthTiles.isEmpty {
                Mosaic(hexes: content.monthTiles, tile: 12.5, spacing: 3, maxRows: 3)
                EyebrowText(text: content.eyebrowSmall, size: type.eyebrowSmall, theme: theme)
                    .padding(.top, 5)
            } else if content.habits.isEmpty {
                EyebrowText(text: strings.noHabits, size: type.eyebrowSmall, theme: theme)
            } else {
                // A month with no moments yet: today's actions, so the first
                // tap has somewhere to land.
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(content.habits.prefix(3).enumerated()), id: \.offset) { _, habit in
                        ActionRow(habit: habit, theme: theme, size: type.actionSmall, target: 18)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetArt(content: content, wide: false)
    }
}

// MARK: Medium — the intention across the top; actions and the month beneath

struct IntendedMediumView: View {
    let content: WidgetContent

    var body: some View {
        let type = WidgetType(locale: content.locale)
        let strings = WidgetStrings(locale: content.locale)
        let theme = content.theme
        let shown = Array(content.habits.prefix(3))
        let rest = content.habits.count - shown.count

        VStack(alignment: .leading, spacing: 0) {
            IntentionText(text: content.greeting, size: type.intentMedium, theme: theme)
            Spacer(minLength: 8)
            HStack(alignment: .bottom, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    if shown.isEmpty {
                        EyebrowText(text: strings.noHabits, size: type.eyebrowMedium, theme: theme)
                    }
                    ForEach(Array(shown.enumerated()), id: \.offset) { _, habit in
                        ActionRow(habit: habit, theme: theme, size: type.actionMedium, target: 22)
                    }
                    if rest > 0 {
                        EyebrowText(text: strings.more(rest), size: type.eyebrowMedium, theme: theme)
                            .padding(.leading, 32)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if !content.monthTiles.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Mosaic(hexes: content.monthTiles, tile: 14, spacing: 4, maxRows: 3)
                        EyebrowText(text: content.eyebrowSmall, size: type.eyebrowMedium, theme: theme)
                    }
                    .frame(width: 140)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetArt(content: content, wide: true)
    }
}

// MARK: Large — the month, its legend, and all of today (Intended+)

struct IntendedLargeView: View {
    let content: WidgetContent

    var body: some View {
        let type = WidgetType(locale: content.locale)
        let strings = WidgetStrings(locale: content.locale)
        let theme = content.theme
        let locked = !content.isPremium
        let shown = Array(content.habits.prefix(4))

        VStack(alignment: .leading, spacing: 0) {
            // Block 1 — the intention and the month in words.
            IntentionText(text: content.greeting, size: type.intentLarge, theme: theme)
            EyebrowText(
                text: locked ? content.monthUnlock : content.eyebrowLarge,
                size: type.eyebrowLarge,
                theme: theme
            )
            .padding(.top, 4)

            // Block 2 — the month in colour. Not subscribed: the real thing,
            // faded to the grid's own dim (fade, never padlock).
            if !content.monthTiles.isEmpty {
                Spacer(minLength: 12)
                VStack(alignment: .leading, spacing: 12) {
                    Mosaic(hexes: content.monthTiles, tile: 16, spacing: 4, maxRows: 4)
                    if !content.legend.isEmpty {
                        LegendRow(entries: content.legend, size: type.legend, theme: theme)
                    }
                }
                .opacity(locked ? 0.38 : 1)
            }

            // Block 3 — today, with the time each moment was recorded.
            Spacer(minLength: 12)
            VStack(alignment: .leading, spacing: 12) {
                if shown.isEmpty {
                    EyebrowText(text: strings.noHabits, size: type.eyebrowLarge, theme: theme)
                }
                ForEach(Array(shown.enumerated()), id: \.offset) { _, habit in
                    ActionRow(
                        habit: habit, theme: theme,
                        size: type.actionLarge, target: 24,
                        timeSize: type.time, showTime: true
                    )
                }
            }
        }
        .padding(.top, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetArt(content: content, wide: false)
    }
}

// MARK: Colour helpers

private func hsl(ofArgbHex hex: String) -> (Double, Double, Double) {
    var value: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&value)
    let hasAlpha = hex.count == 8
    let r = Double((value >> 16) & 0xFF) / 255
    let g = Double((value >> 8) & 0xFF) / 255
    let b = Double(value & 0xFF) / 255
    _ = hasAlpha
    let maxC = max(r, g, b), minC = min(r, g, b)
    let l = (maxC + minC) / 2
    guard maxC != minC else { return (0, 0, l) }
    let d = maxC - minC
    let s = l > 0.5 ? d / (2 - maxC - minC) : d / (maxC + minC)
    var h: Double
    if maxC == r { h = (g - b) / d + (g < b ? 6 : 0) }
    else if maxC == g { h = (b - r) / d + 2 }
    else { h = (r - g) / d + 4 }
    h /= 6
    return (h, s, l)
}

private func color(h: Double, s: Double, l: Double) -> Color {
    func hue2rgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
        var t = t
        if t < 0 { t += 1 }
        if t > 1 { t -= 1 }
        if t < 1 / 6 { return p + (q - p) * 6 * t }
        if t < 1 / 2 { return q }
        if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
        return p
    }
    if s == 0 { return Color(.sRGB, red: l, green: l, blue: l, opacity: 1) }
    let q = l < 0.5 ? l * (1 + s) : l + s - l * s
    let p = 2 * l - q
    return Color(
        .sRGB,
        red: hue2rgb(p, q, h + 1 / 3),
        green: hue2rgb(p, q, h),
        blue: hue2rgb(p, q, h - 1 / 3),
        opacity: 1
    )
}
