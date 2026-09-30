import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/chapter.dart';
import '../models/intention_path.dart';
import '../services/analytics_service.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import 'onboarding_state.dart';
import 'widgets/hold_to_confirm_button.dart';
import 'widgets/onboarding_scaffold.dart';

/// Onboarding, screen 3 (spec §6): say it your way, then the chapter opens.
///
/// Writing: "I want to …", pre-filled with the path's own words, three other
/// ways to finish it, and a hold to make it yours. Sealed: everything but
/// the phrase blurs away, and the phrase glides into its place as the
/// chapter's title, never leaving the screen, while the page of a chapter
/// opening forms around it:
/// CHAPTER ONE, a rule drawn outward, the three months as a contents list,
/// and the date it runs until. Typography and space make it a book; nothing
/// draws one.
///
/// The hold seals the sentence; the chapter is written only when onboarding
/// finishes, dated from the hold ([OnboardingState.sealSentence]).
class SentenceScreen extends StatefulWidget {
  const SentenceScreen({
    super.key,
    required this.onContinue,
    this.onBack,
    this.now,
  });

  /// Called from the chapter page. The flow decides what comes next.
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  /// The clock, so tests and renders get a fixed date.
  final DateTime Function()? now;

  /// Capped at the add path, and said out loud when reached (CLAUDE.md).
  static const int maxLength = 80;

  /// How long the chapter page takes to form after the hold.
  static const Duration opening = Duration(milliseconds: 2200);

  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen>
    with SingleTickerProviderStateMixin {
  final _text = TextEditingController();
  final _stackKey = GlobalKey();
  final _phraseKey = GlobalKey();
  final _slotKey = GlobalKey();
  late final AnimationController _open =
      AnimationController(vsync: this, duration: SentenceScreen.opening)
        ..addListener(_feelLanding);

  bool _prefilled = false;
  bool _landed = false;
  int _attempt = 0;
  Chapter? _chapter;
  String _sealed = '';

  /// Where the phrase was written, and its place on the chapter page.
  Rect? _from;
  Rect? _to;

  /// The phrase keeps the line breaks it was written with and only scales,
  /// so no word jumps lines on the way.
  static const double _titleScale = 0.88;

  // The beats of the opening, as parts of its 2.2 s.
  static const _blurOut = Interval(0.0, 0.2, curve: Curves.easeIn);
  static const _travel = Interval(0.1, 0.45, curve: Curves.easeInOutCubic);
  static const _label = Interval(0.35, 0.5, curve: Curves.easeOut);
  static const _rule = Interval(0.45, 0.58, curve: Curves.easeOutCubic);
  static const _footer = Interval(0.78, 0.9, curve: Curves.easeOut);
  static const _cta = Interval(0.84, 1.0, curve: Curves.easeOut);
  static Interval _row(int i) =>
      Interval(0.52 + i * 0.07, 0.66 + i * 0.07, curve: Curves.easeOut);

  double _t(Interval beat) => beat.transform(_open.value);

  IntentionPath get _path => IntentionPath.getById(
        IntentionPathId.fromKey(
            context.read<OnboardingState>().selectedIntentionPath),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final state = context.read<OnboardingState>();
    // Their own words survive a trip back, unless they changed direction:
    // then the sentence starts again from the new path's words.
    final own = state.sentence != null &&
        state.sentencePathKey == state.selectedIntentionPath;
    _text.text =
        own ? state.sentence! : _path.sentence(AppLocalizations.of(context));
  }

  @override
  void dispose() {
    _open.dispose();
    _text.dispose();
    super.dispose();
  }

  void _feelLanding() {
    if (!_landed &&
        _open.status == AnimationStatus.forward &&
        _open.value >= _travel.end) {
      _landed = true;
      HapticFeedback.mediumImpact();
    }
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
  }

  Future<void> _seal() async {
    final sentence = _text.text.trim();
    if (sentence.isEmpty) return;
    final state = context.read<OnboardingState>();
    final at = (widget.now ?? DateTime.now)();
    FocusScope.of(context).unfocus();
    await state.sealSentence(
      sentence,
      pathKey: state.selectedIntentionPath,
      at: at,
    );
    AnalyticsService.logOnboardingStepCompleted('sentence');
    if (!mounted) return;
    final from = _rectOf(_phraseKey);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    setState(() {
      _sealed = sentence;
      _from = from;
      _to = null;
      _landed = false;
      // A preview of the chapter onboarding will write: same sentence, same
      // instant, same offset, so the date shown is the date it gets.
      _chapter = Chapter.start(
        id: 'preview',
        sentence: sentence,
        pathKey: state.selectedIntentionPath,
        startedAt: at,
        offsetMinutes: at.toLocal().timeZoneOffset.inMinutes,
      );
    });
    // The page lays itself out first, so the phrase's place on it is known
    // before the phrase moves there.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _to = _rectOf(_slotKey));
      if (reduceMotion) {
        _open.value = 1; // Reduce Motion: the page, without the journey.
      } else {
        _open.forward(from: 0);
      }
    });
  }

  void _back() {
    if (_chapter != null) {
      // Back from the chapter is back to the words, not out of the screen.
      _open.stop();
      setState(() {
        _open.value = 0;
        _chapter = null;
        _from = null;
        _to = null;
        _attempt++;
      });
      return;
    }
    widget.onBack?.call();
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    AnalyticsService.logOnboardingStepCompleted('chapter');
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _open,
      builder: (context, _) {
        final sealed = _chapter != null;
        final ctaIn = sealed ? _t(_cta) : 0.0;
        return OnboardingScaffold(
          step: 1,
          onBack: widget.onBack == null && !sealed ? null : _back,
          cta: Stack(
            children: [
              IgnorePointer(
                ignoring: sealed,
                child: _Veil(
                  amount: sealed ? _t(_blurOut) : 0,
                  child: HoldToConfirmButton(
                    key: ValueKey('hold-$_attempt'),
                    label: l10n.onboardingSentenceHold,
                    enabled: _text.text.trim().isNotEmpty,
                    onConfirmed: _seal,
                  ),
                ),
              ),
              if (sealed)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: ctaIn < 0.9,
                    child: _Appear(
                      amount: ctaIn,
                      child: OnboardingCta(
                        label: l10n.commonContinue,
                        onPressed: _continue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          child: Stack(
            key: _stackKey,
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                ignoring: sealed,
                child: _Writing(
                  controller: _text,
                  phraseKey: _phraseKey,
                  path: _path,
                  veil: sealed ? _t(_blurOut) : 0,
                  // Sealed, the phrase is carried by its static twin below.
                  hidePhrase: sealed && _from != null,
                  onChanged: () => setState(() {}),
                ),
              ),
              if (sealed)
                _ChapterPage(
                  chapter: _chapter!,
                  slotKey: _slotKey,
                  slotHeight: (_from?.height ?? 0) * _titleScale,
                  label: _t(_label),
                  rule: _t(_rule),
                  rows: [for (var i = 0; i < 3; i++) _t(_row(i))],
                  footer: _t(_footer),
                ),
              if (sealed && _from != null)
                _Phrase(
                  sentence: _sealed,
                  from: _from!,
                  to: _to ?? _from!,
                  progress: _t(_travel),
                  scale: _titleScale,
                  underline: 1 - _t(_blurOut),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Blurs and fades its child away as [amount] goes from 0 to 1.
class _Veil extends StatelessWidget {
  const _Veil({required this.amount, required this.child});

  final double amount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return child;
    return Opacity(
      opacity: (1 - amount).clamp(0.0, 1.0),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 12 * amount, sigmaY: 12 * amount),
        child: child,
      ),
    );
  }
}

/// Brings its child in from a soft blur as [amount] goes from 0 to 1.
class _Appear extends StatelessWidget {
  const _Appear({required this.amount, required this.child});

  final double amount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (amount >= 1) return child;
    final blur = 8 * (1 - amount);
    return Opacity(
      opacity: amount.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 6 * (1 - amount)),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }
}

TextStyle _sentenceStyle(BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  return TextStyle(
    fontFamily: AppTextStyles.displayFontFor(locale),
    fontSize: locale.startsWith('ru') ? 30 : 34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.2,
    color: context.watch<ThemeProvider>().colors.textPrimary,
  );
}

TextStyle _prefixStyle(BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  return TextStyle(
    fontFamily: AppTextStyles.displayFontFor(locale),
    fontSize: locale.startsWith('ru') ? 24 : 26,
    fontWeight: FontWeight.w400,
    color: context
        .watch<ThemeProvider>()
        .colors
        .textPrimary
        .withValues(alpha: 0.85),
  );
}

/// The phrase as one block: "I want to" over the sentence. The editable
/// field and its static twin share this layout, so the swap at the seal is
/// invisible and the phrase never leaves the screen.
class _PhraseLayout extends StatelessWidget {
  const _PhraseLayout({required this.sentence});

  final Widget sentence;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).onboardingSentencePrefix,
          textAlign: TextAlign.center,
          style: _prefixStyle(context),
        ),
        const SizedBox(height: 10),
        sentence,
      ],
    );
  }
}

class _Writing extends StatelessWidget {
  const _Writing({
    required this.controller,
    required this.phraseKey,
    required this.path,
    required this.veil,
    required this.hidePhrase,
    required this.onChanged,
  });

  final TextEditingController controller;
  final GlobalKey phraseKey;
  final IntentionPath path;
  final double veil;
  final bool hidePhrase;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final body = AppTextStyles.bodyFont(context);
    final atLimit = controller.text.length >= SentenceScreen.maxLength;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        28,
        40,
        28,
        OnboardingScaffold.contentBottomPadding,
      ),
      child: Column(
        children: [
          _Veil(
            amount: veil,
            child: Text(
              l10n.onboardingSentenceTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: body,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: colors.ctaSecondary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // The phrase: the largest text on the screen, the thing being made.
          Opacity(
            opacity: hidePhrase ? 0 : 1,
            child: KeyedSubtree(
              key: phraseKey,
              child: _PhraseLayout(
                sentence: CupertinoTextField(
                  controller: controller,
                  onChanged: (_) => onChanged(),
                  maxLength: SentenceScreen.maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  minLines: 1,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  padding: const EdgeInsets.only(bottom: 10),
                  placeholder: '…',
                  style: _sentenceStyle(context),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: path.accentColor.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _Veil(
            amount: veil,
            child: Column(
              children: [
                if (atLimit) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingSentenceLimit(SentenceScreen.maxLength),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: body,
                      fontSize: 13,
                      color: colors.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final idea in path.sentenceIdeas(l10n))
                      _IdeaChip(
                        text: idea,
                        accent: path.accentColor,
                        selected: controller.text.trim() == idea,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.value = TextEditingValue(
                            text: idea,
                            selection:
                                TextSelection.collapsed(offset: idea.length),
                          );
                          onChanged();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.onboardingSentencePrivacy,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: body,
                    fontSize: 13,
                    height: 1.4,
                    color: colors.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The phrase once sealed: the static twin of what was written, in the same
/// place and layout, which then moves and scales into its place on the
/// chapter page and stays there. It never leaves the screen.
class _Phrase extends StatelessWidget {
  const _Phrase({
    required this.sentence,
    required this.from,
    required this.to,
    required this.progress,
    required this.scale,
    required this.underline,
  });

  final String sentence;
  final Rect from;
  final Rect to;
  final double progress;
  final double scale;

  /// How much of the writing line is left, 1 to 0.
  final double underline;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final shift = (to.center - from.center) * progress;
    return Positioned.fromRect(
      rect: from,
      child: IgnorePointer(
        child: Transform.translate(
          offset: shift,
          child: Transform.scale(
            scale: 1 + (scale - 1) * progress,
            child: _PhraseLayout(
              sentence: Container(
                key: const Key('chapter-phrase'),
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.ctaSecondary
                          .withValues(alpha: 0.3 * underline.clamp(0, 1)),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  sentence,
                  textAlign: TextAlign.center,
                  style: _sentenceStyle(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A chapter's opening page: its number, a place for the phrase, a rule, the
/// three months as a contents list, and the date it runs until. Each part is
/// given how far it has appeared, 0 to 1.
class _ChapterPage extends StatelessWidget {
  const _ChapterPage({
    required this.chapter,
    required this.slotKey,
    required this.slotHeight,
    required this.label,
    required this.rule,
    required this.rows,
    required this.footer,
  });

  final Chapter chapter;
  final GlobalKey slotKey;

  /// The phrase lands here; it is drawn by [_Phrase], not by the page.
  final double slotHeight;
  final double label;
  final double rule;
  final List<double> rows;
  final double footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final body = AppTextStyles.bodyFont(context);
    // A non-breaking space keeps "31 December" from splitting across lines.
    final until = DateFormat('d MMMM', locale)
        .format(chapter.lastDay)
        .replaceAll(' ', ' ');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        32,
        24,
        32,
        OnboardingScaffold.contentBottomPadding,
      ),
      child: Column(
        children: [
          _Appear(
            amount: label,
            child: Text(
              l10n.onboardingChapterOne.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: body,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                color: colors.ctaSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            key: slotKey,
            width: double.infinity,
            height: slotHeight,
          ),
          const SizedBox(height: 22),
          // A rule drawn outward from the centre.
          Container(
            width: 64 * rule,
            height: 1.5,
            color: colors.ctaSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 26),
          for (var i = 0; i < 3; i++)
            _Appear(
              amount: rows[i],
              child: _ContentsRow(
                month: _monthName(chapter.months[i], locale),
                stage: Chapter.stageName(i + 1, l10n),
                current: i == 0,
              ),
            ),
          const SizedBox(height: 26),
          _Appear(
            amount: footer,
            child: Text(
              '${l10n.onboardingChapterUntil(until)}\n'
              '${l10n.onboardingChapterDecide}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: body,
                fontSize: 15,
                height: 1.5,
                color: colors.ctaSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "October", «Октябрь»: the standalone month, capitalised for a list.
  static String _monthName(DateTime month, String locale) {
    final name = DateFormat.LLLL(locale).format(month);
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }
}

class _IdeaChip extends StatelessWidget {
  const _IdeaChip({
    required this.text,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFFFFFFFF)
                .withValues(alpha: selected ? 0.78 : 0.5),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.75)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.65),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

/// One line of the chapter's contents: month, dot leaders, stage. The month
/// being lived reads strongest; nothing fills, counts or completes.
class _ContentsRow extends StatelessWidget {
  const _ContentsRow({
    required this.month,
    required this.stage,
    required this.current,
  });

  final String month;
  final String stage;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final style = TextStyle(
      fontFamily: AppTextStyles.bodyFont(context),
      fontSize: 16,
      height: 1.3,
      fontWeight: current ? FontWeight.w600 : FontWeight.w400,
      color: colors.textPrimary.withValues(alpha: current ? 1 : 0.6),
    );
    final leader = Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: CustomPaint(
          size: const Size.fromHeight(2),
          painter: _Leader(
            colors.textPrimary.withValues(alpha: current ? 0.45 : 0.3),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Set like a contents page: the stage flush right, dots between.
          // At large text sizes the stage wraps instead of overflowing.
          final scaler = MediaQuery.textScalerOf(context);
          double width(String text) => (TextPainter(
                text: TextSpan(text: text, style: style),
                textDirection: TextDirection.ltr,
                textScaler: scaler,
              )..layout())
                  .width;
          final fits = width(month) + width(stage) + 40 <= constraints.maxWidth;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(month, style: style),
              leader,
              if (fits)
                Text(stage, style: style)
              else
                Flexible(
                  flex: 3,
                  child: Text(stage, style: style, textAlign: TextAlign.end),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Leader extends CustomPainter {
  _Leader(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 1.0; x < size.width; x += 6) {
      canvas.drawCircle(Offset(x, size.height / 2), 1, paint);
    }
  }

  @override
  bool shouldRepaint(_Leader old) => old.color != color;
}
