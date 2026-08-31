import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/gratitude_entry.dart';
import '../services/gratitude_service.dart';
import '../services/notification_scheduler.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import 'gratitude_archive_screen.dart';

/// Tonight's page: what you were thankful for, toward yourself and toward
/// other people.
///
/// The one rule the layout exists to keep: **no empty slots**. Ten numbered
/// boxes would say "3 of 10" without printing the number, which is a
/// denominator wearing a form's clothes and the exact pressure this app
/// removes. So the page is *lines*, added one at a time — an underline is
/// something to write on, a box is something you left empty. On a hard night
/// three lines is the whole page, and nothing on screen can say otherwise.
///
/// Closing saves whatever exists. Unlike a pause, a part-written page is not
/// an abandoned attempt — four lines are four lines.
class GratitudePageScreen extends StatefulWidget {
  const GratitudePageScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const GratitudePageScreen(),
      );

  @override
  State<GratitudePageScreen> createState() => _GratitudePageScreenState();
}

class _GratitudePageScreenState extends State<GratitudePageScreen> {
  final List<TextEditingController> _self = [];
  final List<TextEditingController> _others = [];
  // One node per line, so a line added by "add another" can take the caret.
  // Without this the new line is an unlabelled blank with no cursor in it —
  // an invisible target the writer has to go hunting for.
  final Map<TextEditingController, FocusNode> _focus = {};
  GratitudeEntry? _existing;
  bool _loading = true;
  bool _hasPastPages = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await GratitudeService.getAll();
    final today = await GratitudeService.forDay();
    if (!mounted) return;
    setState(() {
      _existing = today;
      _hasPastPages = all.any((e) => e.localDay != today?.localDay);
      _fill(_self, today?.forSelf ?? const []);
      _fill(_others, today?.forOthers ?? const []);
      _loading = false;
    });
  }

  void _fill(List<TextEditingController> into, List<String> lines) {
    for (final line in lines) {
      into.add(_track(TextEditingController(text: line)));
    }
    // Always one open line to write on, never an empty one below a written
    // one — the "add another" affordance is what grows the list.
    if (into.isEmpty) into.add(_track(TextEditingController()));
  }

  TextEditingController _track(TextEditingController c) {
    _focus[c] = FocusNode();
    return c;
  }

  @override
  void dispose() {
    // A page typed and then dismissed by the system back gesture must not
    // vanish: the same failure the completion modal fixed for notes.
    if (!_saved) _persist();
    for (final c in [..._self, ..._others]) {
      _focus.remove(c)?.dispose();
      c.dispose();
    }
    super.dispose();
  }

  List<String> _linesOf(List<TextEditingController> cs) =>
      [for (final c in cs) c.text];

  /// Writes the page and rebuilds the notification queue, which is what drops
  /// tonight's reminder once there is something on the page.
  Future<void> _persist() {
    final self = _linesOf(_self);
    final others = _linesOf(_others);
    final existing = _existing;
    final entry = existing == null
        ? GratitudeEntry.create(forSelf: self, forOthers: others)
        : existing.copyWith(forSelf: self, forOthers: others);
    // Returns the future rather than swallowing it. `dispose` cannot await
    // and drops it on purpose — a lost page is worse than a late queue
    // rebuild — but `_done` must, because the very next thing it does reads
    // this write back.
    return GratitudeService.save(entry);
  }

  Future<void> _done() async {
    // Awaited, not fired: `scheduleGratitude` asks `writtenToday()` whether
    // to drop tonight's slot, and reads this very write to answer. Racing it
    // nudges someone to write the page they just finished.
    await _persist();
    _saved = true;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await NotificationScheduler.scheduleGratitude(l10n);
    if (!mounted) return;
    // A State stays mounted for the whole exit transition, so a late pop
    // would land on the route below (§11).
    if (ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pop();
  }

  void _addLine(List<TextEditingController> into) {
    if (into.length >= GratitudeEntry.maxLinesPerSide) return;
    final added = _track(TextEditingController());
    setState(() => into.add(added));
    // After the frame that builds it, or the node has nothing to attach to.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus[added]?.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateStr =
        DateFormat('EEEE, d MMMM', locale).format(DateTime.now()).toUpperCase();

    return Scaffold(
      backgroundColor: colors.modalBg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.modalBg1, colors.modalBg2, colors.modalBg3],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    _header(colors, dateStr, l10n),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.gratitudeTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  height: 1.25,
                                  color: colors.textPrimary,
                                  fontFamily: AppTextStyles.displayFontFor(
                                      Localizations.localeOf(context)
                                          .languageCode),
                                )),
                            const SizedBox(height: 10),
                            Text(l10n.gratitudeHint,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSubtitle,
                                  fontFamily: AppTextStyles.bodyFont(context),
                                )),
                            const SizedBox(height: 34),
                            _side(colors, l10n, l10n.gratitudeToYourself,
                                l10n.gratitudeSelfPlaceholder, _self),
                            const SizedBox(height: 34),
                            _side(colors, l10n, l10n.gratitudeToOthers,
                                l10n.gratitudeOthersPlaceholder, _others),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: GestureDetector(
                        onTap: _done,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: colors.buttonDark,
                            borderRadius: BorderRadius.circular(27),
                          ),
                          alignment: Alignment.center,
                          child: Text(l10n.gratitudeDone,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.buttonText,
                                fontFamily: AppTextStyles.bodyFont(context),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _header(dynamic colors, String dateStr, AppLocalizations l10n) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.close_rounded,
                  size: 24, color: colors.checkmarkFill),
            ),
            Expanded(
              child: Text(dateStr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                    fontFamily: AppTextStyles.bodyFont(context),
                  )),
            ),
            // Only once there is something behind you. An archive door that
            // opens on nothing is a promise of content, which is the failure
            // "silence beats filler" replaced.
            _hasPastPages
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context)
                        .push(GratitudeArchiveScreen.route()),
                    child: Icon(Icons.menu_book_outlined,
                        size: 22, color: colors.checkmarkFill),
                  )
                : const SizedBox(width: 24),
          ],
        ),
      );

  Widget _side(
    dynamic colors,
    AppLocalizations l10n,
    String label,
    String placeholder,
    List<TextEditingController> controllers,
  ) {
    final full = controllers.length >= GratitudeEntry.maxLinesPerSide;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colors.textLabel,
              fontFamily: AppTextStyles.bodyFont(context),
            )),
        const SizedBox(height: 16),
        for (int i = 0; i < controllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: TextField(
              controller: controllers[i],
              focusNode: _focus[controllers[i]],
              maxLength: GratitudeEntry.maxLineLength,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: colors.textPrimary,
                fontFamily: AppTextStyles.bodyFont(context),
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                hintText: i == 0 ? placeholder : null,
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: colors.accentMuted,
                  fontFamily: AppTextStyles.bodyFont(context),
                ),
                contentPadding: const EdgeInsets.only(bottom: 10),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: colors.divider.withOpacity(0.20), width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: colors.divider.withOpacity(0.42), width: 1),
                ),
              ),
            ),
          ),
        // The cap is said out loud at the *add* path, never enforced by
        // silently dropping a line at render (§10).
        full
            ? Text(l10n.gratitudeSideFull,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colors.textTertiary,
                  fontFamily: AppTextStyles.bodyFont(context),
                ))
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _addLine(controllers),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded,
                          size: 17, color: colors.accentMuted),
                      const SizedBox(width: 7),
                      Text(l10n.gratitudeAddAnother,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.accentMuted,
                            fontFamily: AppTextStyles.bodyFont(context),
                          )),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}
