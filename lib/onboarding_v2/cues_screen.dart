import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/action_cue.dart';
import '../models/intention_path.dart';
import '../services/action_cues.dart';
import '../services/analytics_service.dart';
import '../theme/category_glyphs.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/text_styles.dart';
import 'onboarding_state.dart';
import 'widgets/blur.dart';
import 'widgets/onboarding_scaffold.dart';

/// Onboarding screen 5, "After I…" (spec §6): each chosen action tied to
/// something the person already does, one action at a time (decided
/// 30 Sep). The cue reads on its own line above the action, in both
/// languages, because Russian action names are imperatives and cannot
/// follow "I'll".
///
/// Skippable. [onContinue] says whether any cue was set: with none, the flow
/// asks about a reminder instead (screen 6).
class CuesScreen extends StatefulWidget {
  const CuesScreen({super.key, required this.onContinue, this.onBack});

  final ValueChanged<bool> onContinue;
  final VoidCallback? onBack;

  static const int maxOwnWords = 40;

  /// How long a chosen cue stays in view before the next action comes in.
  static const Duration beat = Duration(milliseconds: 650);

  /// Where to open: the first action still without a cue, so coming back
  /// picks up where the person left off.
  static int startAt(List<String> actions, Map<String, ActionCue> cues) {
    final open = actions.indexWhere((a) => !cues.containsKey(a));
    return open == -1 ? 0 : open;
  }

  static bool allSet(List<String> actions, Map<String, ActionCue> cues) =>
      actions.isNotEmpty && actions.every(cues.containsKey);

  static bool anySet(List<String> actions, Map<String, ActionCue> cues) =>
      actions.any(cues.containsKey);

  @override
  State<CuesScreen> createState() => _CuesScreenState();
}

class _CuesScreenState extends State<CuesScreen> {
  late final List<String> _actions;
  Map<String, ActionCue> _cues = {};
  bool _loaded = false;
  int _index = 0;
  bool _writingOwn = false;
  int _advance = 0;
  final _own = TextEditingController();

  @override
  void initState() {
    super.initState();
    _actions = List.of(context.read<OnboardingState>().userHabits);
    ActionCues.read().then((all) {
      if (!mounted) return;
      setState(() {
        _cues = {
          for (final a in _actions)
            if (all[a] != null) a: all[a]!,
        };
        _index = CuesScreen.startAt(_actions, _cues);
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _own.dispose();
    super.dispose();
  }

  String get _action => _actions[_index];

  Future<void> _choose(ActionCue cue) async {
    final action = _action;
    final ticket = ++_advance;
    HapticFeedback.selectionClick();
    setState(() {
      _cues[action] = cue;
      _writingOwn = false;
    });
    await ActionCues.set(action, cue);

    // Let the chosen words land, then bring in the next action still
    // without a cue. A newer tap cancels this one.
    await Future<void>.delayed(CuesScreen.beat);
    if (!mounted || ticket != _advance) return;
    final next = _nextOpen();
    if (next != null) _goTo(next);
  }

  int? _nextOpen() {
    for (var i = 1; i < _actions.length; i++) {
      final j = (_index + i) % _actions.length;
      if (!_cues.containsKey(_actions[j])) return j;
    }
    return null;
  }

  void _goTo(int index) {
    _advance++;
    setState(() {
      _index = index;
      _writingOwn = false;
    });
  }

  void _startOwn() {
    _advance++;
    final current = _cues[_action];
    _own.text = current?.ownWords ?? '';
    setState(() => _writingOwn = true);
  }

  void _submitOwn(String words) {
    if (words.trim().isEmpty) {
      setState(() => _writingOwn = false);
      return;
    }
    _choose(ActionCue.own(words));
  }

  void _back() {
    if (_index > 0) {
      _goTo(_index - 1);
    } else {
      widget.onBack?.call();
    }
  }

  void _finish() {
    _advance++;
    AnalyticsService.logOnboardingStepCompleted('cues');
    widget.onContinue(CuesScreen.anySet(_actions, _cues));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final accent = IntentionPath.getById(
            IntentionPathId.fromKey(state.selectedIntentionPath))
        .accentColor;
    final still = MediaQuery.of(context).disableAnimations;

    return OnboardingScaffold(
      step: 2,
      onBack: _back,
      title: l10n.onboardingCuesTitle,
      subtitle: l10n.onboardingCuesSubtitle,
      ctaLabel: l10n.commonContinue,
      onCta: _loaded && CuesScreen.allSet(_actions, _cues) ? _finish : null,
      footer: OnboardingSkip(onPressed: _finish),
      child: !_loaded || _actions.isEmpty
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  28, 36, 28, OnboardingScaffold.contentBottomPadding),
              children: [
                Text(
                  l10n.onboardingCuesPrefix,
                  textAlign: TextAlign.center,
                  style: _prefixStyle(context),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration:
                      still ? Duration.zero : const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: _blur,
                  layoutBuilder: _stackTop,
                  child: _Recipe(
                    key: ValueKey(_index),
                    action: _action,
                    category: state.getCategoryForHabit(_action),
                    cue: _cues[_action],
                    writingOwn: _writingOwn,
                    own: _own,
                    accent: accent,
                    onSubmitOwn: _submitOwn,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in CuePreset.values)
                      _CueChip(
                        text: ActionCue.preset(preset).label(l10n),
                        accent: accent,
                        selected: !_writingOwn &&
                            _cues[_action] == ActionCue.preset(preset),
                        onTap: () => _choose(ActionCue.preset(preset)),
                      ),
                    _CueChip(
                      text: l10n.onboardingCuesOther,
                      accent: accent,
                      selected: _writingOwn || _cues[_action]?.ownWords != null,
                      onTap: _startOwn,
                    ),
                  ],
                ),
                if (_actions.length > 1) ...[
                  const SizedBox(height: 28),
                  _Dots(
                    actions: _actions,
                    index: _index,
                    cues: _cues,
                    accent: accent,
                    onTap: _goTo,
                  ),
                ],
              ],
            ),
    );
  }

  static Widget _blur(Widget child, Animation<double> animation) =>
      AnimatedBuilder(
        animation: animation,
        builder: (context, child) =>
            BlurAppear(amount: animation.value, child: child!),
        child: child,
      );

  static Widget _stackTop(Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, if (current != null) current],
      );
}

/// One action's recipe: the cue (or the blank waiting for one) over the
/// action it leads to.
class _Recipe extends StatelessWidget {
  const _Recipe({
    super.key,
    required this.action,
    required this.category,
    required this.cue,
    required this.writingOwn,
    required this.own,
    required this.accent,
    required this.onSubmitOwn,
  });

  final String action;
  final String? category;
  final ActionCue? cue;
  final bool writingOwn;
  final TextEditingController own;
  final Color accent;
  final ValueChanged<String> onSubmitOwn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final style = _cueStyle(context);

    final Widget blank;
    if (writingOwn) {
      blank = CupertinoTextField(
        key: const Key('cue-own-words'),
        controller: own,
        autofocus: true,
        textAlign: TextAlign.center,
        maxLength: CuesScreen.maxOwnWords,
        // Two lines, so the hint and longer words wrap instead of cutting
        // off; Done still submits.
        minLines: 1,
        maxLines: 2,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitOwn,
        placeholder: l10n.onboardingCuesOtherHint,
        placeholderStyle:
            style.copyWith(color: colors.textPrimary.withValues(alpha: 0.3)),
        style: style,
        cursorColor: accent,
        decoration: null,
        padding: EdgeInsets.zero,
      );
    } else {
      blank = AnimatedSwitcher(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 300),
        transitionBuilder: _CuesScreenState._blur,
        child: cue == null
            // The blank of "After I ___": a line to write on, the height
            // of the words that will fill it.
            ? SizedBox(
                key: const ValueKey('blank'),
                width: 140,
                height: style.fontSize! * style.height!,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: accent.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              )
            : Text(
                cue!.label(l10n),
                key: ValueKey(cue),
                textAlign: TextAlign.center,
                style: style,
              ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: cue == null
              ? l10n.onboardingCuesPrefix
              : '${l10n.onboardingCuesPrefix} ${cue!.label(l10n)}',
          excludeSemantics: !writingOwn,
          child: blank,
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(CategoryGlyphs.of(category), width: 28, height: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                localizeHabitName(action, l10n),
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: colors.textPrimary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CueChip extends StatelessWidget {
  const _CueChip({
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

/// Where the person is among their actions. Each dot is a way back to that
/// action; the ones with a cue sit a shade deeper.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.actions,
    required this.index,
    required this.cues,
    required this.accent,
    required this.onTap,
  });

  final List<String> actions;
  final int index;
  final Map<String, ActionCue> cues;
  final Color accent;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < actions.length; i++)
          Semantics(
            button: true,
            selected: i == index,
            label: localizeHabitName(actions[i], l10n),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == index ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: accent.withValues(
                      alpha: i == index
                          ? 0.85
                          : cues.containsKey(actions[i])
                              ? 0.45
                              : 0.18,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

TextStyle _cueStyle(BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  return TextStyle(
    fontFamily: AppTextStyles.displayFontFor(locale),
    fontSize: locale.startsWith('ru') ? 27 : 30,
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
    fontSize: locale.startsWith('ru') ? 20 : 22,
    fontWeight: FontWeight.w400,
    color: context
        .watch<ThemeProvider>()
        .colors
        .textPrimary
        .withValues(alpha: 0.85),
  );
}
