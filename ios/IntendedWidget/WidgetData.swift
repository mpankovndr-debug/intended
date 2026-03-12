import Foundation
import SwiftUI

// MARK: - Shared data model for widget rendering

struct HabitEntry: Codable {
    let name: String
    let done: Bool
    let colorHex: String?
}

struct ThemeData: Codable {
    let id: String
    let isDark: Bool
    let bgTop: String
    let bgBottom: String
    let textPrimary: String
    let textSecondary: String
    let textTertiary: String
    let accent: String
    let cardBg: String
    let cardBgOpacity: Double
    let checkmark: String
}

struct WidgetContent {
    let habits: [HabitEntry]
    let completedCount: Int
    let totalCount: Int
    let greeting: String
    let isPremium: Bool
    let theme: ThemeData
    let locale: String

    static let placeholder = WidgetContent(
        habits: [
            HabitEntry(name: "Take 3 slow breaths", done: true, colorHex: "FFD96766"),
            HabitEntry(name: "Set one priority", done: false, colorHex: "FF8B9A6B"),
            HabitEntry(name: "Drink a glass of water", done: true, colorHex: "FFD96766"),
        ],
        completedCount: 2,
        totalCount: 4,
        greeting: "Do what feels right today",
        isPremium: false,
        theme: ThemeData(
            id: "warmClay",
            isDark: false,
            bgTop: "FFF2D4B0",
            bgBottom: "FFD49A70",
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
    let locale = defaults.string(forKey: "widget_locale") ?? "en"

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
        theme: theme,
        locale: locale
    )
}

// MARK: - Color helpers

extension Color {
    /// Parse "AARRGGBB" hex string to SwiftUI Color.
    init(argbHex: String) {
        let hex = argbHex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

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

    var upgrade: String {
        locale == "ru" ? "Обновите для подробностей" : "Upgrade to see more"
    }

    var noHabits: String {
        locale == "ru" ? "Пока нет привычек" : "No habits yet"
    }

    var allDone: String {
        locale == "ru" ? "Всё сделано!" : "All done for today!"
    }
}
