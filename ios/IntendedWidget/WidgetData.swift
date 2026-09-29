import Foundation
import SwiftUI

// MARK: - Shared data model for widget rendering

struct HabitEntry: Codable {
    let name: String
    /// English habit title used for HabitTracker ID resolution on the Flutter side.
    /// Falls back to `name` when absent (pre-update data).
    let rawName: String?
    let done: Bool
    let colorHex: String?
    /// Wall-clock time of today's moment ("07:40"), already formatted for the
    /// user's locale from the moment's own offset. Nil until done.
    let doneAt: String?

    /// The key to use when recording completions — always the raw English name.
    var trackingName: String { rawName ?? name }

    /// Convenience init that defaults rawName to nil (for placeholders / backwards compat).
    init(name: String, rawName: String? = nil, done: Bool, colorHex: String?, doneAt: String? = nil) {
        self.name = name
        self.rawName = rawName
        self.done = done
        self.colorHex = colorHex
        self.doneAt = doneAt
    }
}

struct ThemeData: Codable {
    let id: String
    let isDark: Bool
    let bgTop: String
    let bgBottom: String
    let bg1: String?
    let bg2: String?
    let bg3: String?
    let textPrimary: String
    let textSecondary: String
    let textTertiary: String
    let accent: String
    let cardBg: String
    let cardBgOpacity: Double
    let checkmark: String

    /// 3-color gradient matching share cards, falls back to bgTop/bgBottom.
    var backgroundColors: [Color] {
        if let b1 = bg1, let b2 = bg2, let b3 = bg3 {
            return [Color(argbHex: b1), Color(argbHex: b2), Color(argbHex: b3)]
        }
        return [Color(argbHex: bgTop), Color(argbHex: bgBottom)]
    }
}

struct LegendEntry: Codable {
    let label: String
    let hex: String
}

struct WidgetContent {
    let habits: [HabitEntry]
    let completedCount: Int
    let totalCount: Int
    let greeting: String
    let isPremium: Bool
    /// This month's moments as ARGB hex colours, oldest first — the mosaic
    /// the premium widget grows in its spare space.
    let monthTiles: [String]
    /// "August · 23 moments" — composed and localised by the app.
    let eyebrowSmall: String
    /// "August 23 · 37 moments · back 2 times".
    let eyebrowLarge: String
    /// Focus areas with counts, most first, at most five.
    let legend: [LegendEntry]
    /// Caption under the faded month for non-subscribers (fade, never padlock).
    let monthUnlock: String
    /// Painted backgrounds rendered by the app into the app group, or nil.
    let artSquarePath: String?
    let artWidePath: String?
    let theme: ThemeData
    let locale: String

    static let placeholder = WidgetContent(
        habits: [
            HabitEntry(name: "Drink water", done: true, colorHex: "FF6B9BD2"),
            HabitEntry(name: "Read 10 pages", done: false, colorHex: "FF8B9A6B"),
            HabitEntry(name: "Take a walk", done: true, colorHex: "FFD96766"),
        ],
        completedCount: 2,
        totalCount: 4,
        greeting: "Do what feels right today",
        isPremium: false,
        monthTiles: [],
        eyebrowSmall: "August · 23 moments",
        eyebrowLarge: "August 23 · 37 moments · back 2 times",
        legend: [
            LegendEntry(label: "Health 14", hex: "FFD96766"),
            LegendEntry(label: "Self-care 11", hex: "FFB8A089"),
            LegendEntry(label: "Mood 5", hex: "FF9B8299"),
        ],
        monthUnlock: "Intended+ — the whole month in colour",
        artSquarePath: nil,
        artWidePath: nil,
        theme: ThemeData(
            id: "warmClay",
            isDark: false,
            bgTop: "FFF2D4B0",
            bgBottom: "FFD49A70",
            bg1: "FFF5EDE0",
            bg2: "FFE8DCC8",
            bg3: "FFDDD1C0",
            textPrimary: "FF3C342A",
            textSecondary: "FF9A8A78",
            textTertiary: "FF9B8A7A",
            accent: "FF7A6A58",
            cardBg: "FFF9EBE0",
            cardBgOpacity: 0.28,
            checkmark: "FF7A6A58"
        ),
        locale: "en"
    )
}

// MARK: - UserDefaults loading

let appGroupId = "group.com.intendedapp.ios"

func loadWidgetContent() -> WidgetContent {
    guard let defaults = UserDefaults(suiteName: appGroupId) else {
        return .placeholder
    }

    // Parse habits
    var habits: [HabitEntry] = []
    if let json = defaults.string(forKey: "widget_habits"),
       let data = json.data(using: .utf8) {
        habits = (try? JSONDecoder().decode([HabitEntry].self, from: data)) ?? []
    }

    let completedCount = defaults.integer(forKey: "widget_completed_count")
    let totalCount = defaults.integer(forKey: "widget_total_count")
    let greeting = defaults.string(forKey: "widget_greeting") ?? "Do what feels right today"
    let isPremium = defaults.bool(forKey: "widget_is_premium")
    var monthTiles: [String] = []
    if let tilesJson = defaults.string(forKey: "widget_month_tiles"),
       let tilesData = tilesJson.data(using: .utf8) {
        monthTiles = (try? JSONDecoder().decode([String].self, from: tilesData)) ?? []
    }
    let locale = defaults.string(forKey: "widget_locale") ?? "en"
    let eyebrowSmall = defaults.string(forKey: "widget_eyebrow_small") ?? ""
    let eyebrowLarge = defaults.string(forKey: "widget_eyebrow_large") ?? ""
    var legend: [LegendEntry] = []
    if let legendJson = defaults.string(forKey: "widget_legend"),
       let legendData = legendJson.data(using: .utf8) {
        legend = (try? JSONDecoder().decode([LegendEntry].self, from: legendData)) ?? []
    }
    let monthUnlock = defaults.string(forKey: "widget_month_unlock") ?? ""
    // Art paths are written by the app; an empty string means "this theme has none".
    func artPath(_ key: String) -> String? {
        guard let path = defaults.string(forKey: key), !path.isEmpty,
              FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }

    // Parse theme
    var theme = WidgetContent.placeholder.theme
    if let themeJson = defaults.string(forKey: "widget_theme"),
       let themeData = themeJson.data(using: .utf8) {
        theme = (try? JSONDecoder().decode(ThemeData.self, from: themeData)) ?? theme
    }

    return WidgetContent(
        habits: habits,
        completedCount: completedCount,
        totalCount: totalCount,
        greeting: greeting,
        isPremium: isPremium,
        monthTiles: monthTiles,
        eyebrowSmall: eyebrowSmall,
        eyebrowLarge: eyebrowLarge,
        legend: legend,
        monthUnlock: monthUnlock,
        artSquarePath: artPath("widget_art_square"),
        artWidePath: artPath("widget_art_wide"),
        theme: theme,
        locale: locale
    )
}

// MARK: - Color helpers

extension Color {
    /// Parse "AARRGGBB" hex string to SwiftUI Color.
    /// Falls back to a neutral gray if the string is malformed.
    init(argbHex: String) {
        let hex = argbHex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        let scanned = Scanner(string: hex).scanHexInt64(&int)

        guard scanned, hex.count >= 6 else {
            self.init(.sRGB, red: 0.5, green: 0.5, blue: 0.5, opacity: 1)
            return
        }

        let a, r, g, b: UInt64
        if hex.count == 8 {
            a = (int >> 24) & 0xFF
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else {
            a = 255
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Localized widget strings

struct WidgetStrings {
    let locale: String

    var today: String {
        locale == "ru" ? "сегодня" : "today"
    }

    func more(_ n: Int) -> String {
        locale == "ru" ? "ещё \(n)" : "+\(n) more"
    }

    func upgrade(habitCount: Int) -> String {
        if habitCount > 0 {
            if locale == "ru" {
                return "Intended+ — покажет \(habitCount) \(ruHabitForm(habitCount))"
            }
            return "Intended+ — see your \(habitCount) habits"
        }
        return locale == "ru" ? "Intended+ — покажет привычки" : "Intended+ — see your habits"
    }

    private func ruHabitForm(_ n: Int) -> String {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 && mod100 != 11 { return "привычку" }
        if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14) { return "привычки" }
        return "привычек"
    }

    var noHabits: String {
        locale == "ru" ? "Пока нет привычек" : "No habits yet"
    }

    var pauseTitle: String {
        locale == "ru" ? "минута дыхания" : "a minute of breath"
    }

    var allDone: String {
        locale == "ru" ? "Всё сделано!" : "All done for today!"
    }
}

// MARK: - Widget background helper

/// On iOS 17+ the gradient is provided by `.containerBackground(for: .widget)` in
/// the widget configuration, so views only need padding. On older iOS, views render
/// their own full-bleed gradient via ZStack.
extension View {
    @ViewBuilder
    func widgetBackground(theme: ThemeData) -> some View {
        if #available(iOS 17.0, *) {
            self.padding(16)
        } else {
            ZStack {
                LinearGradient(
                    colors: theme.backgroundColors,
                    startPoint: UnitPoint(x: 0.3, y: 0),
                    endPoint: UnitPoint(x: 0.7, y: 1)
                )
                self.padding(16)
            }
        }
    }
}
