import AppIntents
import WidgetKit
import Foundation

/// App Intent for completing a habit directly from the widget.
/// Writes the completion to shared UserDefaults so Flutter can sync on next launch.
@available(iOS 17.0, *)
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Mark a habit as completed from the widget")

    @Parameter(title: "Habit Name")
    var habitName: String

    init() {}

    init(habitName: String) {
        self.habitName = habitName
    }

    func perform() async throws -> some IntentResult {
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return .result()
        }

        // Read current pending completions
        var pending = loadPendingCompletions(defaults: defaults)

        // Create a completion entry with today's date
        let today = dateKey(for: Date())
        let entry = WidgetCompletion(habitName: habitName, dateKey: today)

        // Avoid duplicates
        if !pending.contains(where: { $0.habitName == entry.habitName && $0.dateKey == entry.dateKey }) {
            pending.append(entry)
        }

        // Save back
        savePendingCompletions(pending, defaults: defaults)

        // Also update the widget_habits data to show immediate visual feedback
        updateHabitDoneStatus(habitName: habitName, defaults: defaults)

        // Reload all widget timelines for immediate visual update
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }

    // MARK: - Helpers

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func loadPendingCompletions(defaults: UserDefaults) -> [WidgetCompletion] {
        guard let json = defaults.string(forKey: "widget_pending_completions"),
              let data = json.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([WidgetCompletion].self, from: data)) ?? []
    }

    private func savePendingCompletions(_ completions: [WidgetCompletion], defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(completions),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        defaults.set(json, forKey: "widget_pending_completions")
    }

    /// Updates the widget_habits JSON to mark this habit as done immediately,
    /// so the widget shows the checkmark without waiting for Flutter.
    private func updateHabitDoneStatus(habitName: String, defaults: UserDefaults) {
        guard let habitsJson = defaults.string(forKey: "widget_habits"),
              let habitsData = habitsJson.data(using: .utf8),
              var habits = try? JSONDecoder().decode([MutableHabitEntry].self, from: habitsData) else {
            return
        }

        // Mark matching habit as done
        for i in habits.indices {
            if habits[i].name == habitName {
                habits[i].done = true
                break
            }
        }

        // Update completed count
        let completedCount = habits.filter { $0.done }.count
        defaults.set(completedCount, forKey: "widget_completed_count")

        // Save updated habits
        if let data = try? JSONEncoder().encode(habits),
           let json = String(data: data, encoding: .utf8) {
            defaults.set(json, forKey: "widget_habits")
        }
    }
}

/// A habit completion entry stored in shared UserDefaults for Flutter to sync.
struct WidgetCompletion: Codable, Equatable {
    let habitName: String
    let dateKey: String
}

/// Mutable version of HabitEntry for in-place updates.
private struct MutableHabitEntry: Codable {
    let name: String
    var done: Bool
    let colorHex: String?
}
