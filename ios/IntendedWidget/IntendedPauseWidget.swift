import WidgetKit
import SwiftUI

// MARK: - Pause launcher widget
//
// A door, not a dashboard: every family is a single tap-through into the
// Pause screen via the homeWidget://pause deep link — the Flutter side pins
// this URI contract in PauseLauncher.handleWidgetUri, and the two must move
// together. Deliberately no counts and no progress: a widget that displayed
// "pauses taken" would turn a rescue into a score.

struct PauseProvider: TimelineProvider {
    func placeholder(in context: Context) -> PauseEntry {
        PauseEntry(date: Date(), theme: WidgetContent.placeholder.theme, locale: "en")
    }

    func getSnapshot(in context: Context, completion: @escaping (PauseEntry) -> Void) {
        let content = loadWidgetContent()
        completion(PauseEntry(date: Date(), theme: content.theme, locale: content.locale))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PauseEntry>) -> Void) {
        let content = loadWidgetContent()
        let entry = PauseEntry(date: Date(), theme: content.theme, locale: content.locale)
        // Static content — the app reloads this timeline by name whenever
        // theme or locale change (WidgetService.updateWidget).
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct PauseEntry: TimelineEntry {
    let date: Date
    let theme: ThemeData
    let locale: String
}

// MARK: - Home screen (systemSmall)

struct PauseSmallView: View {
    let entry: PauseEntry
    private var strings: WidgetStrings { WidgetStrings(locale: entry.locale) }

    var body: some View {
        VStack(spacing: 10) {
            // The app's breath glow in miniature: the theme accent as a soft
            // radial bloom with a white core — light, not an object.
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(argbHex: entry.theme.accent).opacity(0.55),
                                Color(argbHex: entry.theme.accent).opacity(0.0),
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 34
                        )
                    )
                    .frame(width: 68, height: 68)
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 26, height: 26)
                    .blur(radius: 8)
            }
            Text(strings.pauseTitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(argbHex: entry.theme.textPrimary).opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(theme: entry.theme)
    }
}

// MARK: - Lock screen accessories

struct PauseAccessoryCircularView: View {
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            // Sun through mist — the app's weather.
            Image(systemName: "sun.haze")
                .font(.system(size: 18))
        }
    }
}

struct PauseAccessoryInlineView: View {
    let entry: PauseEntry
    private var strings: WidgetStrings { WidgetStrings(locale: entry.locale) }

    var body: some View {
        Text("\(Image(systemName: "sun.haze")) \(strings.pauseTitle)")
    }
}

// MARK: - Configuration

struct PauseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PauseEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            PauseAccessoryCircularView()
                .widgetURL(URL(string: "homeWidget://pause?src=lockscreen"))
        case .accessoryInline:
            PauseAccessoryInlineView(entry: entry)
                .widgetURL(URL(string: "homeWidget://pause?src=lockscreen"))
        default:
            PauseSmallView(entry: entry)
                .widgetURL(URL(string: "homeWidget://pause?src=widget"))
        }
    }
}

struct IntendedPauseWidget: Widget {
    let kind: String = "IntendedPauseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PauseProvider()) { entry in
            if #available(iOS 17.0, *) {
                PauseWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        LinearGradient(
                            colors: entry.theme.backgroundColors,
                            startPoint: UnitPoint(x: 0.3, y: 0),
                            endPoint: UnitPoint(x: 0.7, y: 1)
                        )
                    }
            } else {
                PauseWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Pause")
        .description("A minute of breath, one tap away.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}
