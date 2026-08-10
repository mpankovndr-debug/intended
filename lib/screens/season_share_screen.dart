import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../services/share_service.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/season_share_card.dart';

/// Shows the monthly card at readable size, then hands it to the share sheet.
///
/// The card renders at a fixed 1080×1350 so the exported image is identical on
/// every device; here it is scaled down to fit the screen. The capture reads
/// the real render tree, so what is scaled on screen is captured at full size
/// — which is why the card is transformed rather than laid out responsively.
class SeasonShareScreen extends StatefulWidget {
  const SeasonShareScreen({
    super.key,
    required this.seasonWord,
    required this.moments,
    required this.returnCount,
  });

  final String seasonWord;
  final List<Moment> moments;
  final int returnCount;

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
    final screen = MediaQuery.of(context).size;

    // Leave room for the button and the safe areas; the card keeps its ratio.
    final scale = ((screen.width - 48) / SeasonShareCard.width)
        .clamp(0.0, (screen.height * 0.62) / SeasonShareCard.height);

    return CupertinoPageScaffold(
      backgroundColor: colors.bgGradientTop,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: colors.bgGradientTop,
        border: null,
        middle: Text(
          l10n.shareButton,
          style: AppTextStyles.body(context)
              .copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              width: SeasonShareCard.width * scale,
              height: SeasonShareCard.height * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: SeasonShareCard(
                    seasonWord: widget.seasonWord,
                    moments: widget.moments,
                    returnCount: widget.returnCount,
                    theme: themeProvider.theme,
                    l10n: l10n,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(28),
                  color: colors.ctaPrimary,
                  onPressed: _sharing ? null : _share,
                  child: Text(
                    l10n.shareButton,
                    style: AppTextStyles.body(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
