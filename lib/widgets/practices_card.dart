import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../screens/gratitude_cadence_screen.dart';
import '../screens/gratitude_page_screen.dart';
import '../main.dart' show doorColor, pagePad;
import '../screens/pause_screen.dart';
import '../services/gratitude_preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// The two practices, in one container: a minute of breath, and a page of
/// thanks.
///
/// One card rather than two floating lines. Everything else on this screen is
/// a rounded container, and the doors were the only exception — with one door
/// that exception reads as *special*, and with two it reads as an oversight.
/// Grouping them also says the true thing about them: these are practices,
/// siblings to each other, and not siblings of the actions in the list below
/// (which carry a checkmark and become moments) or of the quiet doors under it
/// (which are settings you touch once a month).
///
/// Both rows are drawn here rather than reusing the old standalone pause door,
/// which painted a band of warm light behind its text. Alone on the landscape
/// that glow was the point; inside a card, beside a plain sibling, it made the
/// two rows look like different kinds of thing — so the card sets one ink, one
/// height, one weight, and neither row is dressed differently from the other.
class PracticesCard extends StatelessWidget {
  const PracticesCard({super.key});

  /// First open goes to setup; every open after goes straight to the page.
  static Future<void> openGratitude(BuildContext context) async {
    final chosen = await GratitudePreferencesService.hasChosenCadence();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      chosen ? GratitudePageScreen.route() : GratitudeCadenceScreen.route(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    // The list's own gutter rule, not a copied constant. A hardcoded 24
    // matched _pagePad exactly on phones — which is why every phone check
    // passed — and overshot the 680pt content cap by 92pt on an iPad, where
    // this card ran wider than every intention card below it.
    final pad = pagePad(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, 0),
      child: Container(
        decoration: BoxDecoration(
          // The Profile page's card surface, not the habit card's. At
          // `cardBackground` (0.28) this washed into the landscape and the two
          // doors read as floating text again — which is the exact thing
          // putting them in a container was meant to fix.
          color: colors.profileCard.withOpacity(colors.profileCardOpacity),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                : const Color(0xFFFFFFFF).withOpacity(0.6),
            width: 1,
          ),
          // The intention cards' exact edge, both layers of it: the outer
          // shadow for depth and the top-edge bevel that gives the glass its
          // lit rim. Without the bevel this card sat flatter than the cards
          // under it and read as a different material.
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: const Color(0xFFFFFFFF).withOpacity(isDark ? 0.18 : 0.25),
              blurRadius: isDark ? 0.5 : 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DoorRow(
              label: l10n.pauseEntryTitle,
              onTap: () => Navigator.of(context)
                  .push(PauseScreen.route(entry: 'home')),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 22),
              color: colors.divider.withOpacity(colors.dividerOpacity),
            ),
            _DoorRow(
              label: l10n.gratitudeDoor,
              onTap: () => openGratitude(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// One practice, as a line of letterspaced type. Both rows use this, so a
/// change to weight, ink or height can only ever land on both.
class _DoorRow extends StatelessWidget {
  const _DoorRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            // The same type as "add something of your own" at the foot of the
            // list — these are all invitations to open something, and they
            // were reading as three different kinds of control.
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: doorColor(colors),
              fontFamily: AppTextStyles.bodyFont(context),
            ),
          ),
        ),
      ),
    );
  }
}
