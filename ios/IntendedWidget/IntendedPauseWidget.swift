import WidgetKit
import SwiftUI

// MARK: - Pause launcher widget
//
// A door, not a dashboard: every family is a single tap-through into the
// Pause screen via the homeWidget://pause deep link — the Flutter side pins
// this URI contract in PauseLauncher.handleWidgetUri, and the two must move
// together. Deliberately no counts and no progress: a widget that displayed
// "pauses taken" would turn a rescue into a score.
//
// The bare `homeWidget` query key is not decoration: the home_widget plugin
// (SwiftHomeWidgetPlugin.isWidgetUrl) only forwards a launch URL to Dart
// when the query contains an item named `homeWidget` — the scheme alone is
// ignored. Without it the tap still opened the app and landed on Home.
// test/pause_test.dart reads this file and pins the key on every URL.

enum PauseWidgetLink {
    static let home = URL(string: "homeWidget://pause?src=widget&homeWidget")!
    static let lockScreen = URL(string: "homeWidget://pause?src=lockscreen&homeWidget")!
}

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

// MARK: - The lit pebble

/// The Pause screen's pebble silhouette: a circle deformed by two slow sine
/// lobes. Mirrors `_SunPebblePainter._pebble` in pause_screen.dart with the
/// morph clock pinned at zero — the pose the app itself holds under Reduce
/// Motion. The path fills the rect's inscribed circle; callers size the
/// frame to 2r.
struct PebbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var path = Path()
        let steps = 72
        for i in 0...steps {
            let theta = 2 * Double.pi * Double(i) / Double(steps)
            let wobble = 1 + 0.05 * sin(2 * theta) + 0.04 * sin(3 * theta + 1.7)
            let p = CGPoint(
                x: c.x + r * wobble * cos(theta),
                y: c.y + r * wobble * sin(theta)
            )
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        return path
    }
}

/// The app's breath glow, still. The layers are the painter's
/// (`_SunPebblePainter.paint` and `_breathGlow._halo`) at the Reduce Motion
/// pose: scale 0.8, brightness lift 0.5, clock 0. Sun by day, moon on dark
/// themes — the same two palettes as PauseScreen.
///
/// The alphas are denser than the app's. There the pebble is a third of the
/// screen over pale sky art; here it is 70pt on the theme's own gradient,
/// and at that size the app's translucent rim melted into a mint
/// background (founder review, 2026-09-05). So the deeper-rose shade that
/// the app reserves for bright warm skies draws the silhouette on every
/// light theme, the body runs near-opaque, and its rim leans toward the
/// shade instead of toward the core.
struct PausePebbleView: View {
    let theme: ThemeData
    /// The square the pebble is laid out in (the painter's `box`).
    let box: CGFloat

    // PauseScreen.sunCore / sunBody / sunShade / moonCore / moonBody.
    private static let sunCore = Color(argbHex: "FFFFF8F6")
    private static let sunBody = Color(argbHex: "FFFBDFDB")
    private static let sunShade = Color(argbHex: "FFEFC0B4")
    private static let moonCore = Color(argbHex: "FFF2F0FF")
    private static let moonBody = Color(argbHex: "FFD6D3F0")

    private let n: Double = 0.5
    private let scale: Double = 0.8

    var body: some View {
        let isDark = theme.isDark
        let dim = isDark ? 0.62 : 1.0
        let bodyDim = isDark ? 0.58 : 1.0
        let core = isDark ? Self.moonCore : Self.sunCore
        let pebbleBody = isDark ? Self.moonBody : Self.sunBody
        let fog = mix(pebbleBody, core, 0.5)
        let edgeLight = mix(core, .white, 0.6)
        // What the body's rim leans toward: the rose shade by day, so the
        // edge is a touch deeper than the middle; the moon body at night.
        let rim = isDark ? pebbleBody : Self.sunShade
        let r = box * 0.44 * scale
        // Rises a little with the breath, as a chest does.
        let lift = -box * 0.02 * n

        ZStack {
            // Halo: the light soaking outward into the fog, behind the body.
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: fog.opacity((0.60 + 0.10 * n) * dim), location: 0.0),
                            .init(color: fog.opacity(0.45 * dim), location: 0.55),
                            .init(color: fog.opacity(0.20 * dim), location: 0.78),
                            .init(color: fog.opacity(0.0), location: 1.0),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: box * 0.7
                    )
                )
                .frame(width: box * 1.4, height: box * 1.4)

            // Outer glow: a wide, heavily blurred skirt around the silhouette.
            // Rose-shaded rather than body-coloured, so it reads as a glow
            // against the gradient and not as more of it.
            PebbleShape()
                .fill((isDark ? pebbleBody : Self.sunShade).opacity(0.55 * dim))
                .frame(width: 2 * r * 1.18, height: 2 * r * 1.18)
                .blur(radius: r * 0.28)
                .offset(y: lift)

            // The deeper-rose shade just outside the edge: the silhouette.
            // Heavier still on a bright warm sky, where light alone has
            // nothing to be brighter than.
            if !isDark {
                PebbleShape()
                    .fill(Self.sunShade.opacity((theme.isBrightWarmSky ? 0.75 : 0.60) * dim))
                    .frame(width: 2 * r * 1.07, height: 2 * r * 1.07)
                    .blur(radius: r * 0.10)
                    .offset(y: lift)
            }

            // Light spilling outward from the edge, both sides of the boundary.
            PebbleShape()
                .stroke(edgeLight.opacity(0.35 * dim), lineWidth: r * 0.14)
                .frame(width: 2 * r, height: 2 * r)
                .blur(radius: r * 0.08)
                .offset(y: lift)

            // Body: luminous, lit from above its centre.
            PebbleShape()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: core.opacity(0.98 * bodyDim), location: 0.0),
                            .init(color: pebbleBody.opacity(0.96 * bodyDim), location: 0.50),
                            .init(color: pebbleBody.opacity(0.95 * bodyDim), location: 0.80),
                            .init(color: mix(pebbleBody, rim, 0.45).opacity(0.94 * bodyDim), location: 1.0),
                        ],
                        center: UnitPoint(x: 0.5, y: 0.45),
                        startRadius: 0,
                        endRadius: r * 1.10
                    )
                )
                .frame(width: 2 * r, height: 2 * r)
                .offset(y: lift)

            // A soft highlight sits high.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.55 * dim), Color.white.opacity(0.0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: r * 0.55
                    )
                )
                .frame(width: r * 1.10, height: r * 1.10)
                .offset(y: lift - r * 0.22)

            // Inner glow: light gathering at the rim, clipped to the body.
            PebbleShape()
                .stroke(edgeLight.opacity((0.38 + 0.10 * n) * dim), lineWidth: r * 0.20)
                .frame(width: 2 * r, height: 2 * r)
                .blur(radius: r * 0.09)
                .clipShape(PebbleShape())
                .offset(y: lift)

            // The boundary itself: a whisper of a line.
            PebbleShape()
                .stroke(Color.white.opacity(0.18 * dim), lineWidth: r * 0.02)
                .frame(width: 2 * r, height: 2 * r)
                .blur(radius: r * 0.02)
                .offset(y: lift)
        }
        .frame(width: box, height: box)
    }

    private func mix(_ a: Color, _ b: Color, _ t: Double) -> Color {
        var (ar, ag, ab, aa): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (br, bg, bb, ba): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        UIColor(a).getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        UIColor(b).getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let k = CGFloat(t)
        return Color(
            .sRGB,
            red: Double(ar + (br - ar) * k),
            green: Double(ag + (bg - ag) * k),
            blue: Double(ab + (bb - ab) * k),
            opacity: Double(aa + (ba - aa) * k)
        )
    }
}

private extension ThemeData {
    /// PauseScreen.brightWarmSky: the onboarding sky (bg2) is warm and pale
    /// enough that light alone can't draw the pebble's edge.
    var isBrightWarmSky: Bool {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        UIColor(Color(argbHex: bg2 ?? bgBottom)).getRed(&r, green: &g, blue: &b, alpha: &a)
        let hi = max(r, g, b), lo = min(r, g, b)
        let lightness = (hi + lo) / 2
        guard hi > lo else { return lightness > 0.80 }
        let d = hi - lo
        var hue: CGFloat
        if hi == r {
            hue = ((g - b) / d).truncatingRemainder(dividingBy: 6)
        } else if hi == g {
            hue = (b - r) / d + 2
        } else {
            hue = (r - g) / d + 4
        }
        hue *= 60
        if hue < 0 { hue += 360 }
        let warm = hue < 75 || hue > 330
        return warm && lightness > 0.80
    }
}

// MARK: - Home screen (systemSmall)

struct PauseSmallView: View {
    let entry: PauseEntry
    private var strings: WidgetStrings { WidgetStrings(locale: entry.locale) }

    var body: some View {
        let content = VStack(spacing: 4) {
            PausePebbleView(theme: entry.theme, box: 100)
            Text(strings.pauseTitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(argbHex: entry.theme.textPrimary).opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // iOS 17 already insets widget content by its own margins; stacking
        // the shared helper's 16pt on top left the title ~90pt of width on a
        // 6.3" phone and it truncated to "a minute of bre…". Below 17 the
        // helper's padding is the only inset, so keep it there.
        if #available(iOS 17.0, *) {
            content
        } else {
            content.widgetBackground(theme: entry.theme)
        }
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
                .widgetURL(PauseWidgetLink.lockScreen)
        case .accessoryInline:
            PauseAccessoryInlineView(entry: entry)
                .widgetURL(PauseWidgetLink.lockScreen)
        default:
            PauseSmallView(entry: entry)
                .widgetURL(PauseWidgetLink.home)
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
