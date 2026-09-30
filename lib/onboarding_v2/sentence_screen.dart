import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

/// Onboarding, screen 3 (spec §6): say it your way, then the chapter.
///
/// One screen, two states. Writing: "I want to …", pre-filled with the
/// path's own words, three other ways to finish it, and a hold to seal it.
/// Sealed: the sentence moves up into quotes and the first chapter appears,
/// with its end date and its three months.
///
/// The hold saves the sentence; the chapter is written only when onboarding
/// finishes, dated from the hold ([OnboardingState.sealSentence]).
class SentenceScreen extends StatefulWidget {
  const SentenceScreen({
    super.key,
    required this.onContinue,
    this.onBack,
    this.now,
  });

  /// Called from the sealed state. The flow decides what comes next.
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  /// The clock, so tests and renders get a fixed date.
  final DateTime Function()? now;

  /// Capped at the add path, and said out loud when reached (CLAUDE.md).
  static const int maxLength = 80;

  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen> {
  final _text = TextEditingController();
  bool _prefilled = false;
  Chapter? _chapter;

  bool get _sealed => _chapter != null;

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
    _text.dispose();
    super.dispose();
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
    setState(() {
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
  }

  void _back() {
    if (_sealed) {
      // Back from the chapter is back to the words, not out of the screen.
      setState(() => _chapter = null);
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
    return OnboardingScaffold(
      step: 1,
      onBack: widget.onBack == null && !_sealed ? null : _back,
      cta: _sealed
          ? OnboardingCta(label: l10n.commonContinue, onPressed: _continue)
          : HoldToConfirmButton(
              key: const ValueKey('hold'),
              label: l10n.onboardingSentenceHold,
              enabled: _text.text.trim().isNotEmpty,
              onConfirmed: _seal,
            ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          OnboardingScaffold.contentBottomPadding,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topLeft,
            children: [...previous, if (current != null) current],
          ),
          child: _sealed
              ? _ChapterReveal(
                  key: const ValueKey('sealed'),
                  sentence: _text.text.trim(),
                  chapter: _chapter!,
                )
              : _Writing(
                  key: const ValueKey('writing'),
                  controller: _text,
                  path: _path,
                  onChanged: () => setState(() {}),
                ),
        ),
      ),
    );
  }
}

class _Writing extends StatelessWidget {
  const _Writing({
    super.key,
    required this.controller,
    required this.path,
    required this.onChanged,
  });

  final TextEditingController controller;
  final IntentionPath path;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final ru = locale.startsWith('ru');
    final display = AppTextStyles.displayFontFor(locale);
    final body = AppTextStyles.bodyFont(context);
    final atLimit = controller.text.length >= SentenceScreen.maxLength;
    final ideas = path.sentenceIdeas(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingSentenceTitle,
          style: TextStyle(
            fontFamily: display,
            fontSize: ru ? 26 : 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.25,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.onboardingSentencePrefix,
          style: TextStyle(
            fontFamily: body,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: colors.ctaSecondary,
          ),
        ),
        const SizedBox(height: 6),
        // The largest text on the screen: it is the thing being made.
        CupertinoTextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          maxLength: SentenceScreen.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          minLines: 1,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          padding: const EdgeInsets.only(bottom: 10),
          placeholder: '…',
          style: TextStyle(
            fontFamily: display,
            fontSize: ru ? 28 : 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2,
            color: colors.textPrimary,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: path.accentColor.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
          ),
        ),
        if (atLimit) ...[
          const SizedBox(height: 8),
          Text(
            l10n.onboardingSentenceLimit(SentenceScreen.maxLength),
            style: TextStyle(
              fontFamily: body,
              fontSize: 13,
              color: colors.textPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
        const SizedBox(height: 22),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final idea in ideas)
              _IdeaChip(
                text: idea,
                accent: path.accentColor,
                selected: controller.text.trim() == idea,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.value = TextEditingValue(
                    text: idea,
                    selection: TextSelection.collapsed(offset: idea.length),
                  );
                  onChanged();
                },
              ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          l10n.onboardingSentencePrivacy,
          style: TextStyle(
            fontFamily: body,
            fontSize: 13,
            height: 1.4,
            color: colors.textPrimary.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
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
                .withValues(alpha: selected ? 0.75 : 0.45),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.75)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.6),
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

class _ChapterReveal extends StatelessWidget {
  const _ChapterReveal({
    super.key,
    required this.sentence,
    required this.chapter,
  });

  final String sentence;
  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final ru = locale.startsWith('ru');
    final body = AppTextStyles.bodyFont(context);
    // A non-breaking space keeps "31 December" from splitting across lines.
    final until = DateFormat('d MMMM', locale)
        .format(chapter.lastDay)
        .replaceAll(' ', '\u00A0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // What they said, whole: the prefix is part of the sentence.
          ru
              ? '«${l10n.onboardingSentencePrefix} $sentence»'
              : '“${l10n.onboardingSentencePrefix} $sentence”',
          style: TextStyle(
            fontFamily: body,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            height: 1.4,
            color: colors.ctaSecondary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.onboardingChapterUntil(until),
          style: TextStyle(
            fontFamily: AppTextStyles.displayFontFor(locale),
            fontSize: ru ? 28 : 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.2,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingChapterDecide,
          style: TextStyle(
            fontFamily: body,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: colors.ctaSecondary,
          ),
        ),
        const SizedBox(height: 28),
        MonthTrack(chapter: chapter, current: 1),
      ],
    );
  }
}

/// The chapter's three months, each named for its stage. It shows where
/// you are in time, never how much you have done: every segment is the
/// same size and none of them fills.
class MonthTrack extends StatelessWidget {
  const MonthTrack({super.key, required this.chapter, required this.current});

  final Chapter chapter;

  /// The stage being lived, 1 to 3.
  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final body = AppTextStyles.bodyFont(context);
    final months = chapter.months;

    // Equal heights, whichever stage name wraps.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < months.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFFFFFFF)
                      .withValues(alpha: i + 1 == current ? 0.78 : 0.32),
                  border: Border.all(
                    color: i + 1 == current
                        ? colors.ctaPrimary.withValues(alpha: 0.55)
                        : const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                    width: i + 1 == current ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _monthLabel(months[i], locale),
                      style: TextStyle(
                        fontFamily: body,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary
                            .withValues(alpha: i + 1 == current ? 1 : 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Chapter.stageName(i + 1, l10n),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: body,
                        fontSize: 12,
                        height: 1.3,
                        color: colors.textPrimary
                            .withValues(alpha: i + 1 == current ? 0.75 : 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// "Oct", «Окт.»: the standalone short month, capitalised for a label.
  static String _monthLabel(DateTime month, String locale) {
    final label = DateFormat.LLL(locale).format(month);
    return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
  }
}
