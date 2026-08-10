import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show AppBackground;
import '../models/moment.dart';
import '../services/share_service.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/season_share_card.dart';

/// Presents the monthly card the way the weekly reveal presents its card:
/// floating over the dimmed app landscape, X to leave, a quiet Share beneath.
/// The first version put the card on a bare gradient page with a full-width
/// button — a different app's furniture (design review, SS1).
class SeasonShareScreen extends StatefulWidget {
  const SeasonShareScreen({
    super.key,
    required this.seasonWord,
    required this.moments,
    required this.returnCount,
    required this.gapsShortening,
  });

  final String seasonWord;
  final List<Moment> moments;
  final int returnCount;
  final bool gapsShortening;

  @override
  State<SeasonShareScreen> createState() => _SeasonShareScreenState();
}

class _SeasonShareScreenState extends State<SeasonShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final size = MediaQuery.of(context).size;
    try {
      await WidgetsBinding.instance.endOfFrame;
      await ShareService.shareCard(
        _cardKey,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(DateTime.now());

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.18),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 22,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      // Rounded for the preview only — the clip sits outside
                      // the RepaintBoundary, so the exported story stays a
                      // clean 9:16 rectangle. Scales down on short screens;
                      // the capture reads layout size, so the export is
                      // identical either way.
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RepaintBoundary(
                          key: _cardKey,
                          child: SeasonShareCard(
                            monthLabel: monthLabel,
                            seasonWord: widget.seasonWord,
                            moments: widget.moments,
                            returnCount: widget.returnCount,
                            gapsShortening: widget.gapsShortening,
                            theme: themeProvider.theme,
                            l10n: l10n,
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                ),
                // A quiet pill, not a full-width slab — the card is the
                // subject of this screen and the button is just its exit.
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: CupertinoButton(
                    onPressed: _sharing ? null : _share,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.share,
                          size: 20,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.shareButton,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
