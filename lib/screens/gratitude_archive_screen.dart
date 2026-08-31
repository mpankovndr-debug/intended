import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show AppBackground, pagePad;
import '../models/gratitude_entry.dart';
import '../models/gratitude_month.dart';
import '../services/gratitude_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// Past pages, a month at a time, oldest first — the same reading order the
/// moment grid and [PauseMonth] use, so the first thing you scroll to is the
/// month's first page.
///
/// The chevrons walk between months that actually hold pages, not between
/// calendar months. A month you wrote nothing in is not a stop on the walk:
/// an empty month view is "look how much you haven't done", which is the one
/// thing this app never renders.
class GratitudeArchiveScreen extends StatefulWidget {
  const GratitudeArchiveScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const GratitudeArchiveScreen(),
      );

  @override
  State<GratitudeArchiveScreen> createState() => _GratitudeArchiveScreenState();
}

class _GratitudeArchiveScreenState extends State<GratitudeArchiveScreen> {
  List<GratitudeEntry> _all = const [];
  List<DateTime> _months = const [];
  int _index = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await GratitudeService.getAll();
    if (!mounted) return;
    setState(() {
      _all = all;
      _months = GratitudeMonth.monthsWithPages(all);
      _index = 0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    if (_loading || _months.isEmpty) {
      return Scaffold(
          backgroundColor: colors.onboardingBg1, body: const SizedBox());
    }

    final anchor = _months[_index];
    final pages = GratitudeMonth.forMonth(_all, anchor);
    // Newest month sits at index 0, so "older" walks the list forwards.
    final canGoOlder = _index < _months.length - 1;
    final canGoNewer = _index > 0;

    return Scaffold(
      backgroundColor: colors.onboardingBg1,
      // The same landscape the home screen sits on: past pages are a place in
      // the app, not a sheet over it.
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // The way out. The month row's own left chevron sits where a
              // back control normally would, so without this the only exit
              // was the system swipe — and nothing on screen said so.
              Padding(
                padding: EdgeInsets.fromLTRB(pagePad(context), 8, pagePad(context), 0),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 24, color: colors.checkmarkFill),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(pagePad(context), 12, pagePad(context), 0),
                child: Row(
                  children: [
                    _chevron(colors, Icons.chevron_left_rounded, canGoOlder,
                        () => setState(() => _index++)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            DateFormat('MMMM', locale).format(anchor),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: colors.textPrimary,
                              fontFamily: AppTextStyles.displayFontFor(
                                  Localizations.localeOf(context).languageCode),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.gratitudePagesCount(pages.length),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                              fontFamily: AppTextStyles.bodyFont(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _chevron(colors, Icons.chevron_right_rounded, canGoNewer,
                        () => setState(() => _index--)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(pagePad(context), 26, pagePad(context), 40),
                  itemCount: pages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _pageCard(
                      colors, l10n, pages[i], locale, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chevron(
          dynamic colors, IconData icon, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon,
              size: 26,
              color: enabled ? colors.textLabel : colors.textDisabled),
        ),
      );

  Widget _pageCard(dynamic colors, AppLocalizations l10n, GratitudeEntry e,
      String locale, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
            : const Color(0xFFFFFFFF).withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
              : colors.buttonDark.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM', locale)
                .format(e.localWallClock)
                .toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colors.checkmarkFill,
              fontFamily: AppTextStyles.bodyFont(context),
            ),
          ),
          if (e.forSelf.isNotEmpty) ...[
            const SizedBox(height: 14),
            _group(colors, l10n.gratitudeToYourself, e.forSelf),
          ],
          if (e.forSelf.isNotEmpty && e.forOthers.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: colors.divider.withOpacity(0.13)),
          ],
          if (e.forOthers.isNotEmpty) ...[
            const SizedBox(height: 14),
            _group(colors, l10n.gratitudeToOthers, e.forOthers),
          ],
        ],
      ),
    );
  }

  /// Dots, not numbers. Numbering prints 1-2-3 beside a night that got to two,
  /// which is a count you can come up short against; a dot is structure with
  /// nothing to score.
  Widget _group(dynamic colors, String label, List<String> lines) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: colors.accentMuted,
                fontFamily: AppTextStyles.bodyFont(context),
              )),
          const SizedBox(height: 9),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.accentRegular,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(line,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: colors.textPrimary,
                          fontFamily: AppTextStyles.bodyFont(context),
                        )),
                  ),
                ],
              ),
            ),
        ],
      );
}
