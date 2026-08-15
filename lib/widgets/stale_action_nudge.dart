import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/profile/change_path_screen.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show styledPrimaryButton;
import '../models/moment.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// When an action has gone quiet, and which quiet action gets to say so.
///
/// Pure and static on purpose: the selection used to sit inside a State method
/// that needed a BuildContext, which is the shape this project has already
/// been bitten by — the widget catch-up's whole policy lived in a method
/// requiring a Navigator and had zero coverage.
class StaleAction {
  StaleAction._();

  /// Ten days without a single completion.
  ///
  /// Not a week: with four to six actions, one of them going seven days
  /// untouched is ordinary even for someone using the app well, so a weekly
  /// threshold turns this card into furniture. Not a fortnight either — that
  /// was long enough that a dead action sat on the home screen for half a
  /// month. Ten clears [Rescue.minQuietDays] (5) with room, so the gentle
  /// reduced screen and this card never argue with each other over the same
  /// silence.
  static const int afterDays = 10;

  /// True when [habit] has had no moment inside the window, and the user has
  /// enough history for that to mean anything. Silent while the whole history
  /// is younger than the window: an action two days old has not failed to
  /// land, it has not been tried.
  static bool isStale({
    required String habit,
    required List<Moment> moments,
    required DateTime now,
  }) {
    if (moments.isEmpty) return false;
    final cutoff = now.toUtc().subtract(const Duration(days: afterDays));
    final oldest = moments
        .map((m) => m.completedAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    if (!oldest.isBefore(cutoff)) return false;
    return !moments.any(
      (m) => m.habitName == habit && m.completedAt.isAfter(cutoff),
    );
  }

  /// The one quiet action allowed to ask the whole question, or null.
  ///
  /// [visible] must be in render order (pinned first) — the first stale action
  /// in it wins. An explicit, stable tiebreak, not a ranking: two actions
  /// equally quiet must not swap places between visits.
  ///
  /// Every other stale action keeps the one-line hint. Four "your intention
  /// may not fit" cards on one screen is a dashboard demanding optimisation,
  /// which is the pressure this app exists to remove.
  static String? primary({
    required List<String> visible,
    required List<Moment> moments,
    required DateTime now,
  }) {
    if (moments.isEmpty) return null;
    final cutoff = now.toUtc().subtract(const Duration(days: afterDays));
    final oldest = moments
        .map((m) => m.completedAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    if (!oldest.isBefore(cutoff)) return null;
    final reachedForRecently = moments
        .where((m) => m.completedAt.isAfter(cutoff))
        .map((m) => m.habitName)
        .toSet();
    for (final habit in visible) {
      if (!reachedForRecently.contains(habit)) return habit;
    }
    return null;
  }
}

/// Which actions the user has already answered "leave it as is" for.
///
/// Kept per habit, and cleared the moment that habit stops being stale, so a
/// dismissal covers *this* quiet stretch and not the action forever: someone
/// who returns to it and drifts again months later gets asked again.
class StaleNudgeDismissals {
  static const _key = 'stale_nudge_dismissed';

  static Future<Set<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  static Future<void> add(String habit) async {
    final prefs = await SharedPreferences.getInstance();
    final all = (prefs.getStringList(_key) ?? const <String>[]).toSet()
      ..add(habit);
    await prefs.setStringList(_key, all.toList());
  }

  static Future<void> clear(String habit) async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getStringList(_key);
    if (all == null || !all.contains(habit)) return;
    await prefs.setStringList(_key, all.where((h) => h != habit).toList());
  }
}

/// Frames one action card that has gone ten days without a moment, and offers
/// the one door that is actually worth opening at that point: a different
/// intention.
///
/// It shows on the *first* quiet action only, and it replaced the bare "Not
/// landing? Hold to swap it." line outright — a full card on every quiet
/// action would be four decisions on one screen, and a quieter fallback line
/// under the rest was a second voice saying the same thing worse.
///
/// Everything it says is computed: the body claims nothing about the action's
/// lifetime (which is not recorded), only about the window that was checked —
/// no moments in the last ten days, which is exactly the trigger.
class StaleActionNudge extends StatelessWidget {
  const StaleActionNudge({
    super.key,
    required this.card,
    required this.onKeep,
  });

  /// The action card itself, unchanged. The nudge frames it rather than
  /// replacing it, so the card keeps its own tap target and the buttons below
  /// keep theirs — nothing here can be hit by aiming at "complete".
  final Widget card;

  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final bodyFont = AppTextStyles.bodyFont(context);

    // ctaPrimary, not accentRegular: the accents are solved as *marks* and go
    // muddy on the dark themes (deepFocus's accentRegular is 0xFF6E6458),
    // while ctaPrimary is solved for foreground use in all ten.
    final accent = colors.ctaPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        // Both surfaces are built on the theme's own card colour rather than
        // floated as washes over the landscape — the frame a light tint, the
        // panel inside a deeper one, so they separate by weight instead of by
        // transparency. Stacked washes went muddy on every light theme, and a
        // hairline alone left the frame reading as nothing at all.
        //
        // Not a BackdropFilter: this project already tried blur behind a
        // translucent fill on the action cards and removed it, because the
        // landscape came through and every card read grey (design review, SS6).
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            accent.withOpacity(isDark ? 0.12 : 0.09),
            colors.profileCard,
          ).withOpacity(isDark ? 0.90 : 0.86),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withOpacity(isDark ? 0.26 : 0.20),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card,
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              // A surface, not a wash. At a low alpha over the landscape the
              // treeline read straight through the copy — the panel has to be
              // something the text sits *on*. Built on the card surface every
              // theme already solves (white on the light themes, their own
              // dark grey on deepFocus and nightBloom), tinted toward the
              // accent, and left a hair short of opaque so it still reads as
              // glass rather than a pasted rectangle.
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accent.withOpacity(isDark ? 0.20 : 0.15),
                  colors.profileCard,
                ).withOpacity(isDark ? 0.95 : 0.92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.staleNudgeTitle,
                          style: TextStyle(
                            fontSize: 16.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            // Not 'Sora': the display face has no Cyrillic,
                            // and this string is shown in both languages.
                            fontFamily: bodyFont,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.staleNudgeBody,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: colors.textSecondary,
                            fontFamily: bodyFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ExcludeSemantics(
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: CustomPaint(painter: _SproutPainter(accent)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            styledPrimaryButton(
              label: l10n.staleNudgeChange,
              onPressed: () {
                HapticFeedback.mediumImpact();
                // The same door the Today screen already opens, opened the
                // same way. Changing an intention is not a habit swap and
                // never touches the two free swaps a month — swapHabit() is
                // the only thing that spends those, and nothing on this path
                // calls it.
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => const ChangePathScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: onKeep,
              child: Text(
                l10n.staleNudgeKeep,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  fontFamily: bodyFont,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A seedling, drawn rather than shipped as an asset: one path set that takes
/// its colour from the theme, instead of ten PNGs that would each have to be
/// re-cut when a palette moves.
class _SproutPainter extends CustomPainter {
  const _SproutPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The stem stops where the leaves start. Run it past them and the whole
    // thing reads as a signpost, which is what the first pass drew.
    final stem = Path()
      ..moveTo(w * 0.50, h * 0.86)
      ..cubicTo(w * 0.50, h * 0.70, w * 0.47, h * 0.55, w * 0.48, h * 0.40);
    canvas.drawPath(
      stem,
      Paint()
        ..color = color.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round,
    );

    final leftLeaf = Path()
      ..moveTo(w * 0.48, h * 0.46)
      ..cubicTo(w * 0.34, h * 0.34, w * 0.16, h * 0.31, w * 0.12, h * 0.42)
      ..cubicTo(w * 0.16, h * 0.55, w * 0.36, h * 0.57, w * 0.48, h * 0.46)
      ..close();
    canvas.drawPath(leftLeaf, Paint()..color = color.withOpacity(0.32));

    final rightLeaf = Path()
      ..moveTo(w * 0.48, h * 0.41)
      ..cubicTo(w * 0.60, h * 0.24, w * 0.80, h * 0.19, w * 0.87, h * 0.28)
      ..cubicTo(w * 0.85, h * 0.43, w * 0.62, h * 0.50, w * 0.48, h * 0.41)
      ..close();
    canvas.drawPath(rightLeaf, Paint()..color = color.withOpacity(0.46));

    canvas.drawLine(
      Offset(w * 0.24, h * 0.90),
      Offset(w * 0.76, h * 0.90),
      Paint()
        ..color = color.withOpacity(0.22)
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SproutPainter oldDelegate) => oldDelegate.color != color;
}
