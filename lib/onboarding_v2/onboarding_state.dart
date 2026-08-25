import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/intention_path.dart';
import '../services/analytics_service.dart';
import '../services/moments_service.dart';
import '../services/reflection_service.dart';

class OnboardingState extends ChangeNotifier {
  bool _welcomeSeen = false;
  String? _name;
  final List<String> _focusAreas = [];
  bool _dailyReminderEnabled = false;
  String? _reminderTime; // e.g., "09:00"
  bool _onboardingComplete = false;
  List<String> userHabits = [];
  List<String> _customHabits = [];
  Map<String, String> _customHabitFocusAreas = {}; // habitTitle -> focusArea

  /// Which weekdays a custom action appears on: habitTitle -> [1..7], Mon=1,
  /// matching [Moment.localWeekday].
  ///
  /// A title absent from this map means *every* day, so nothing here needs
  /// migrating and an account that never sets a mask behaves exactly as before.
  /// Seeded actions are never keyed — only customs can carry a mask.
  Map<String, List<int>> _customHabitDays = {};
  static const String _customHabitDaysKey = 'custom_habit_days';

  /// When a mask was last created or changed, ISO-8601 UTC.
  ///
  /// Read by the drift card, which compares this week against a rolling
  /// average built before the mask existed — see [Drift.maskSuppressionDays].
  /// Public because the reader is a screen, not this class.
  static const String customHabitDaysChangedAtKey =
      'custom_habit_days_changed_at';

  /// When each action joined Today, in UTC. Written by every add path; absent
  /// for anything adopted before this started being recorded.
  Map<String, DateTime> _habitAdoptedAt = {};
  static const String _habitAdoptedAtKey = 'habit_adopted_at';

  static const int _maxCustomHabitsFree = 2;
  static const int _maxSwapsFree = 2;
  static const int _maxFocusAreasFree = 2;

  /// Hard ceiling on how many actions can sit on Today at once.
  ///
  /// Onboarding happens to generate exactly four (two per focus area, two
  /// areas), so the rule held by accident — but browse and packs both grew the
  /// list with no limit, and nothing enforced it. §7 is explicit that neither
  /// contextual door should grow the list: swap refines, adopt redirects. A
  /// fifth card is how a gentle app becomes a checklist.
  /// Six: four the path generates, plus the two anyone can write themselves.
  /// Raised from four after a habit the user had been completing silently
  /// vanished when a custom pushed the list past the cap — see
  /// [visibleHabits], which no longer truncates anything.
  static const int maxActiveHabits = 6;

  /// Whether another action can be added without breaking that ceiling.
  bool get canAddHabit => userHabits.length < maxActiveHabits;

  /// The actions the user actually sees, in the order they see them: pinned
  /// first, then their own words, then the catalog fills what's left, capped
  /// Everything the user has, pinned first and their own words next — and
  /// never fewer. The cap belongs on *adding*, not on rendering: truncating
  /// here hid a habit that was still in storage, still being completed, and
  /// reachable from nowhere in the app.
  ///
  /// This is the *only* definition of "active" (design review): all-done
  /// detection, pack completion, swap targets, the plan's evidence and the
  /// home-screen widget all read this. The bug it replaces: Today capped the
  /// render while every checker still read the raw list, so a user with
  /// hidden habits could never satisfy "all done" and Quiet Bloom went
  /// unreachable.
  /// [preferred] is consulted only during a rescue: the single card a
  /// returning user sees should be the action they actually lived, not
  /// whatever sorts first (see [Rescue.mostLived]). Ignored when it is no
  /// longer one of their habits, so a removed action can never strand the
  /// reduced screen on nothing.
  List<String> visibleHabits({bool rescue = false, String? preferred}) {
    final pinned = _pinnedHabit;
    final ordered = [
      if (pinned != null && userHabits.contains(pinned)) pinned,
      ...userHabits.where((h) => h != pinned && _customHabits.contains(h)),
      ...userHabits.where((h) => h != pinned && !_customHabits.contains(h)),
    ];
    if (rescue && preferred != null && ordered.contains(preferred)) {
      return [preferred];
    }
    return ordered.take(rescue ? 1 : ordered.length).toList();
  }

  /// [visibleHabits] with today's weekday mask applied — what to *draw* now.
  ///
  /// Deliberately a second method rather than a filter inside [visibleHabits].
  /// That one feeds nine call sites, and they mean two different things by it:
  /// "what to draw right now" (widget, home, all-done) and "which actions are
  /// this user's" (Lift, MonthPlan, the staleness rule). Masking inside it
  /// would silently change both — a ranking that reorders itself by weekday,
  /// and a month plan that forgets an action on its off-days.
  ///
  /// The weekday is [DateTime.now] in the device's current zone: the same
  /// clock `HabitTracker._key` uses for `habit_done_*`, so a card and its own
  /// completion key can never disagree about which day it is. This is *not*
  /// the recorded-offset rule [Moment.localDay] follows — that answers a
  /// different question, about a moment already recorded.
  List<String> habitsForToday({DateTime? now}) {
    final visible = visibleHabits();
    if (_customHabitDays.isEmpty) return visible;

    final weekday = (now ?? DateTime.now()).weekday;
    final todays = visible.where((h) {
      final days = _customHabitDays[h];
      // Absent, or empty through some earlier bad write, means every day.
      if (days == null || days.isEmpty) return true;
      return days.contains(weekday);
    }).toList();

    // A day must never have zero cards. An empty screen reads as "you have
    // nothing to do", which is the one thing a mask must not be able to say.
    return todays.isEmpty ? visible : todays;
  }

  /// Sets or clears [habitTitle]'s weekday mask, and stamps the change.
  ///
  /// Passing null, an empty list, or all seven days *clears* the entry rather
  /// than storing it: absent already means every day, and a redundant mask
  /// would suppress the drift card for four weeks while changing nothing.
  /// A write that does not change the mask is not a change, and does not
  /// re-stamp.
  Future<void> setCustomHabitDays(String habitTitle, List<int>? days) async {
    // Seeded actions are never masked.
    if (!_customHabits.contains(habitTitle)) return;

    final normalized = days == null
        ? const <int>[]
        : (days.where((d) => d >= 1 && d <= 7).toSet().toList()..sort());
    final clears = normalized.isEmpty || normalized.length == 7;

    final previous = _customHabitDays[habitTitle];
    if (clears) {
      if (previous == null) return;
      _customHabitDays.remove(habitTitle);
    } else {
      // Both sides are sorted and deduped, so joining compares them.
      if (previous != null && previous.join(',') == normalized.join(',')) {
        return;
      }
      _customHabitDays[habitTitle] = normalized;
    }

    final prefs = await SharedPreferences.getInstance();
    await _saveCustomHabitDays(prefs);
    await prefs.setString(
      customHabitDaysChangedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );

    notifyListeners();
  }

  // Intention path
  String _selectedIntentionPath = 'your_own_way';
  String? _lastPreselectedPathKey;

  /// The path key whose [IntentionPath.starterActions] have already been
  /// handed out. Null until a starters path generates for the first time.
  ///
  /// Comparing this against the current path key is also the reset: pick a
  /// different path and it no longer matches, so that path seeds its own
  /// starters once before falling back to its pool.
  String? _startersAppliedForPath;
  static const String _startersAppliedForPathKey = 'starters_applied_for_path';

  // NEW: Pin tracking
  String? _pinnedHabit;

  // NEW: Swap tracking
  final Map<String, int> _swapsUsed = {}; // category -> swaps used this month
  DateTime? _lastSwapReset;

  // NEW: Focus area change tracking
  DateTime? _lastFocusAreaChange;

  DateTime? _lastHabitRefresh;
  int _habitRefreshCount = 0;
  static const int _maxDailyRefreshes = 3;

  // Getters
  bool get welcomeSeen => _welcomeSeen;
  String? get name => _name;
  List<String> get focusAreas => List.unmodifiable(_focusAreas);
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  String? get reminderTime => _reminderTime;
  bool get onboardingComplete => _onboardingComplete;
  String get selectedIntentionPath => _selectedIntentionPath;
  String? get lastPreselectedPathKey => _lastPreselectedPathKey;
  String? get pinnedHabit => _pinnedHabit;
  List<String> get customHabits => List.unmodifiable(_customHabits);
  Map<String, String> get customHabitFocusAreas =>
      Map.unmodifiable(_customHabitFocusAreas);
  Map<String, List<int>> get customHabitDays =>
      Map.unmodifiable(_customHabitDays);

  /// When each active action joined Today, for the actions that have it
  /// recorded. Read by the staleness rule, which needs the *action's* age
  /// rather than the account's; anything missing here is treated as old
  /// enough, so users who predate this record see no change.
  Map<String, DateTime> get habitAdoptedAt =>
      Map.unmodifiable(_habitAdoptedAt);

  /// Marks [titles] as joining Today now.
  ///
  /// `putIfAbsent`, not assignment: a refresh that happens to redraw an action
  /// the user already had must not restart its clock, and adding one action
  /// must not restamp the others.
  void _recordAdopted(Iterable<String> titles) {
    final stamp = DateTime.now().toUtc();
    for (final title in titles) {
      _habitAdoptedAt.putIfAbsent(title, () => stamp);
    }
  }

  /// Persists the adoption stamps, forgetting anything that has since left
  /// Today.
  ///
  /// The pruning lives here rather than at each removal so no removal path can
  /// forget it: an action set aside and taken up again months later is a new
  /// adoption, and gets its fair chance over again.
  Future<void> _saveHabitAdoptions(SharedPreferences prefs) async {
    _habitAdoptedAt.removeWhere((title, _) => !userHabits.contains(title));
    await prefs.setString(
      _habitAdoptedAtKey,
      jsonEncode(
        _habitAdoptedAt.map(
          (title, at) => MapEntry(title, at.toUtc().toIso8601String()),
        ),
      ),
    );
  }

  // All available habits by category (EXPANDED TO 12 EACH)
  static const Map<String, List<String>> habitsByCategory = {
    'Health': [
      // Starter (very easy)
      'Drink 3 glasses of water',
      'Take 3 slow breaths',
      'Stretch for 30 seconds',
      // Core
      'Stand up and roll your shoulders',
      'Step outside for 5 minutes',
      'Close your eyes for 30 seconds',
      'Do 5 gentle neck rolls',
      'Walk to the window and back',
      'Take 5 slow, deep breaths',
      // Advanced
      '2-minute body scan',
      '5 minutes of gentle stretching',
      'Eat one meal mindfully',
      'Screens away 20 minutes before bed',
      'Drink something warm',
      'Get outside for a few minutes',
      'Move your body a little',
      'Get into bed early',
    ],
    'Mood': [
      'One-minute pause',
      'Notice one thing you feel',
      'Three grounding breaths',
      'Look away from your screen for 30 seconds',
      'Name three things you can see',
      'Notice one sound around you',
      'Feel your feet on the ground',
      'Place hand on heart for 30 seconds',
      'Name 3 things you\'re grateful for',
      'Smile kindly at yourself',
      'Ask yourself "what do I need right now?"',
      'Give yourself permission to rest',
      'One meal without your phone',
      'Plan tomorrow in one sentence',
    ],
    'Home & organization': [
      'Tidy one small thing',
      'Put one thing back where it belongs',
      'Wipe one surface',
      'Open a window for fresh air',
      'Make your bed',
      'Clear one shelf',
      'Wash 3 dishes',
      'Take out one bag of trash',
      'Fold 3 items of clothing',
      'Organize one drawer',
      'Water your plants',
      'Light a scented candle',
    ],
    'Relationships': [
      'Send one message to someone you care about',
      'Think of one person you appreciate',
      'Ask someone how they are',
      'Give one genuine compliment',
      'Call someone you care about',
      'Share something that made you smile',
      'Thank someone today',
      'Listen without planning your response',
      'Reach out to someone you miss',
      'Tell someone what they mean to you',
      'Offer help to someone',
      'Celebrate someone else\'s win',
    ],
    'Creativity': [
      'Write down what\'s in your head',
      'Doodle for 5 minutes',
      'Notice one beautiful thing',
      'Take one photo of something you like',
      'Hum a tune you enjoy',
      'Learn one new word',
    ],
    'Self-care': [
      'Sit still for 1 minute',
      'Do one kind thing for yourself',
      'Drink a cup of tasty coffee',
      'Stretch your neck',
      'Take one slow breath',
      'Notice something you like about yourself',
      'Give yourself permission to say no',
      'Do something that feels good',
      'Rest for 5 minutes',
      'Put on something comfortable',
      'Listen to one song you love',
      'Do absolutely nothing for 5 minutes',
      'Dim the lights an hour before sleep',
      'Get out of bed',
      'Eat after waking up',
      'Eat one proper meal',
      'Take your medication',
      'Brush your teeth',
      'Wash your face',
      'Take a shower',
      'Put on clean clothes',
      'Brush your hair',
      'Open the curtains',
      'Turn on a lamp',
      'Leave your phone across the room',
      'Do a 1-minute reset',
    ],
  };

  /// Actions from focus areas the app no longer offers, and the area that
  /// inherits them.
  ///
  /// Finances was removed as a focus area, then Doing one thing. Their actions
  /// stay resolvable because a user who *held* one keeps it until they swap or
  /// refresh, and because `_categoryForHabit` returning null is how a completed
  /// action becomes a grey uncategorised square with no legend chip. One map,
  /// read by all three services, rather than the same strings copied three
  /// times — the resolver-duplication scar.
  ///
  /// This governs *new* moments only. Moments already written carry their own
  /// `category: 'Finances'` or `'Doing one thing'` and are never rewritten.
  ///
  /// Retirement chains. 'Write down one idea' and 'Close one browser tab' were
  /// retired *into* Doing one thing; removing that area orphaned them, so they
  /// move on to Self-care. A replacement that is itself retired resolves to a
  /// category with no hue, no legend chip and no swap pool — pinned by the
  /// 'every inheriting area is a real focus area' test.
  static const Map<String, String> retiredHabitCategories = {
    // Titles renamed to match what the ARB actually renders. A user still
    // holding the old card resolves and swaps through these.
    'Drink a glass of water': 'Health',
    'Stretch for 10 seconds': 'Health',
    'Step outside for 30 seconds': 'Health',
    'Close your eyes for 20 seconds': 'Health',
    'Take 5 deep belly breaths': 'Health',
    '10 minutes of gentle movement': 'Health',
    'Ten-second pause': 'Mood',
    'One grounding breath': 'Mood',
    'Look away from your screen for 10 seconds': 'Mood',
    'Place hand on heart for a moment': 'Mood',
    "Notice one thing you're grateful for": 'Mood',
    'Smile gently at yourself': 'Mood',
    'Do a 30-second reset': 'Self-care',
    'Take out one small bag of trash': 'Home & organization',
    'Water one plant': 'Home & organization',
    'Light a candle': 'Home & organization',
    'Send one message to someone': 'Relationships',
    'Doodle for 10 seconds': 'Creativity',
    'Try one new word': 'Creativity',
    'Sit still for 10 seconds': 'Self-care',
    'Drink water slowly': 'Self-care',
    'Rest for 2 minutes': 'Self-care',
    'Do absolutely nothing for 30 seconds': 'Self-care',
    'Capture one idea': 'Creativity',
    'Draw one simple shape': 'Creativity',
    'Rearrange something small': 'Creativity',
    'Play with one creative medium': 'Creativity',
    'Imagine one possibility': 'Creativity',
    'Create one tiny thing': 'Creativity',
    'Set one priority': 'Self-care',
    'Finish one tiny task': 'Self-care',
    'Declutter your desk for 2 minutes': 'Self-care',
    'Review your calendar': 'Self-care',
    'Turn off one notification': 'Self-care',
    'Archive 5 old emails': 'Self-care',
    'Update one to-do item': 'Self-care',
    'Write down one idea': 'Self-care',
    'Close one browser tab': 'Self-care',
    'Write one sentence': 'Creativity',
    'Check your balance': 'Home & organization',
    'Move €1 to savings': 'Home & organization',
    'Review one subscription': 'Home & organization',
    'Note one expense': 'Home & organization',
    'Read one financial tip': 'Home & organization',
    'Delete one old receipt': 'Home & organization',
    'Update one budget category': 'Home & organization',
    'Review one bill': 'Home & organization',
    'Price-check one item before buying': 'Home & organization',
    'Wait 24 hours before one purchase': 'Home & organization',
    'Celebrate one money win': 'Home & organization',
    'Set one small savings goal': 'Home & organization',
  };

  /// Focus areas that no longer exist, and what a saved selection becomes.
  static const Map<String, String> retiredFocusAreas = {
    'Finances': 'Home & organization',
    // Both names for one area: 'Productivity' from before the rename,
    // 'Doing one thing' from after it. Either can be sitting in prefs.
    'Productivity': 'Self-care',
    'Doing one thing': 'Self-care',
  };

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  /// Clears current focus-area selections and applies [defaults] as the
  /// pre-selection for [pathKey]. Tracks which path was last applied so
  /// FocusAreasScreen can detect when the path changed and re-apply.
  ///
  /// Persists, like [changeFocusAreas]. It used to mutate memory only, so a
  /// path change from ChangePathScreen was lost on restart: `loadUserHabits`
  /// read the old saved list back, leaving the user holding actions from areas
  /// their focus list no longer contained.
  Future<void> applyPathDefaults(List<String> defaults, String pathKey) async {
    _focusAreas.clear();
    for (final area in defaults) {
      _focusAreas.add(area);
    }
    _lastPreselectedPathKey = pathKey;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('focus_areas', _focusAreas);
  }

  Future<void> setSelectedIntentionPath(String pathKey) async {
    final previous = _selectedIntentionPath;
    _selectedIntentionPath = pathKey;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    // A *change* — not the onboarding pick — is the event worth counting.
    // Somebody who redirects their whole practice is somebody for whom the
    // intention is a real object rather than a header they scroll past.
    if (_onboardingComplete && previous != pathKey) {
      final setAt = prefs.getString('intention_path_set_at');
      final days = setAt == null
          ? 0
          : DateTime.now().difference(DateTime.parse(setAt)).inDays;
      AnalyticsService.logIntentionChanged(
        from: previous,
        to: pathKey,
        daysOnPrevious: days,
      );
    }

    await prefs.setString('selected_intention_path', pathKey);
    await prefs.setString(
        'intention_path_set_at', DateTime.now().toIso8601String());
    AnalyticsService.setIntentionPath(pathKey);
  }

  Future<void> loadSelectedIntentionPath() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedIntentionPath =
        prefs.getString('selected_intention_path') ?? 'your_own_way';
    notifyListeners();
    // Re-assert on every launch: user properties don't survive reinstall,
    // and the D7 segmentation is only as good as the property being there.
    AnalyticsService.setIntentionPath(_selectedIntentionPath);
  }

  void markWelcomeSeen() {
    _welcomeSeen = true;
    notifyListeners();
  }

  /// Max focus areas for the user's current tier (free or boost).
  /// Subscription users get unlimited focus areas.
  int maxFocusAreas() => _maxFocusAreasFree;

  void toggleFocusArea(String area) {
    if (_focusAreas.contains(area)) {
      _focusAreas.remove(area);
    } else {
      if (_focusAreas.length >= maxFocusAreas()) return;
      _focusAreas.add(area);
    }
    notifyListeners();
  }

  bool isSelected(String area) {
    return _focusAreas.contains(area);
  }

  void setDailyReminder(bool enabled) {
    _dailyReminderEnabled = enabled;
    notifyListeners();
  }

  void setReminderTime(String time) {
    _reminderTime = time;
    notifyListeners();
  }

  // Generate habits and save them
  Future<void> generateUserHabits() async {
    final random = Random();
    final selectedHabits = <String>[];

    // A path that knows its own actions seeds exactly those (§7): a random
    // draw from "Health" could hand a sleep-seeker a glass of water.
    //
    // That holds for the *first* generation on a path. Applying them on every
    // generation made refresh a no-op for the five starters paths and made
    // their focus-area choice mean nothing — so after the first, they draw
    // from their areas like the other four.
    final pathKey = _selectedIntentionPath;
    final path = IntentionPath.getById(IntentionPathId.fromKey(pathKey));
    final starters = path.starterActions;
    final useStarters = starters != null && _startersAppliedForPath != pathKey;
    if (useStarters) {
      selectedHabits.addAll(starters);
    } else if (_focusAreas.isEmpty) {
      selectedHabits.addAll([
        'Drink a glass of water',
        'Take 3 slow breaths',
      ]);
    } else {
      for (final area in _focusAreas) {
        final categoryHabits = habitsByCategory[area] ?? [];
        final shuffled = List<String>.from(categoryHabits)..shuffle(random);
        selectedHabits.addAll(shuffled.take(2));
      }
    }

    // This path has now spent its starters; the next generation draws pool.
    if (useStarters) _startersAppliedForPath = pathKey;

    // Only what wasn't here a moment ago counts as newly adopted: this runs
    // again on every refresh and focus-area change, and an action that
    // survives a reshuffle has not just been taken up.
    final previous = userHabits.toSet();

    // ✅ PRESERVE custom habits - add them back after generating
    userHabits = [...selectedHabits, ..._customHabits];

    _recordAdopted(userHabits.where((h) => !previous.contains(h)));

    // Validate pinned habit still exists in new habit list
    final pinnedCleared = _pinnedHabit != null && !userHabits.contains(_pinnedHabit);
    if (pinnedCleared) {
      _pinnedHabit = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_habits', userHabits);
    await _saveHabitAdoptions(prefs);
    if (useStarters) {
      await prefs.setString(_startersAppliedForPathKey, pathKey);
    }
    if (pinnedCleared) {
      await prefs.remove('pinned_habit');
    }

    notifyListeners();
  }

  Future<void> addHabitFromBrowse(String habit) async {
    if (!canAddHabit) return;
    if (!userHabits.contains(habit)) {
      userHabits.add(habit);
      _recordAdopted([habit]);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_habits', userHabits);
      await _saveHabitAdoptions(prefs);
      notifyListeners();
    }
  }

  /// Removes habits from the active list (returns them to the browse pool).
  /// Custom habits are never removed by this method.
  Future<void> setAsideHabits(List<String> habitsToRemove) async {
    for (final habit in habitsToRemove) {
      if (_customHabits.contains(habit)) continue;
      userHabits.remove(habit);
    }
    if (_pinnedHabit != null && !userHabits.contains(_pinnedHabit)) {
      _pinnedHabit = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pinned_habit');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_habits', userHabits);
    await _saveHabitAdoptions(prefs);
    notifyListeners();
  }

  /// Adds multiple habits from a curated pack, skipping any already active.
  /// Returns the number of newly added habits.
  Future<int> addHabitsFromPack(List<String> habitIds) async {
    final adopted = <String>[];
    for (final habit in habitIds) {
      if (!canAddHabit) break;
      if (!userHabits.contains(habit)) {
        userHabits.add(habit);
        adopted.add(habit);
      }
    }
    if (adopted.isNotEmpty) {
      _recordAdopted(adopted);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_habits', userHabits);
      await _saveHabitAdoptions(prefs);
      notifyListeners();
    }
    return adopted.length;
  }

  /// Adds a focus area from the monthly plan, and writes it down.
  ///
  /// Separate from [toggleFocusArea] on both counts. That one is the
  /// onboarding picker: it holds the free tier's cap, and it leaves the choice
  /// in memory for the screen that saves it afterwards. Neither is right here
  /// — the plan is a paid surface, and its accept button has to change
  /// something that survives the app closing (§4.5), not silently do nothing
  /// because two areas were already chosen.
  Future<void> adoptFocusArea(String area) async {
    if (_focusAreas.contains(area)) return;
    _focusAreas.add(area);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('focus_areas', _focusAreas);
  }

  /// Updates focus areas to match a curated pack without regenerating habits.
  Future<void> applyPackFocusAreas(List<String> packFocusAreas) async {
    _focusAreas.clear();
    _focusAreas.addAll(packFocusAreas);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('focus_areas', _focusAreas);
    notifyListeners();
  }

  /// Replaces retired focus areas in the saved selection with the area that
  /// inherited them, in place, and persists the result.
  ///
  /// Runs inside [loadUserHabits] the moment `focus_areas` is read, before any
  /// screen can see the stale value. Lazy migration is not enough: the change
  /// -focus-areas picker seeds its own selection list from [focusAreas] and
  /// renders cards from a fixed catalogue, so a retired area would sit there
  /// invisible, occupying one of the two (or four) selection slots and getting
  /// written straight back on save.
  ///
  /// A user whose replacement is already selected ends up with one area rather
  /// than a duplicate. That is deliberate: one real area beats two names for
  /// the same pool. Held actions are untouched — [userHabits] keeps whatever a
  /// user was already using until they swap or refresh it themselves.
  Future<void> _migrateRetiredFocusAreas(SharedPreferences prefs) async {
    if (!_focusAreas.any(retiredFocusAreas.containsKey)) return;

    final migrated = <String>[];
    for (final area in _focusAreas) {
      final replacement = retiredFocusAreas[area] ?? area;
      if (!migrated.contains(replacement)) migrated.add(replacement);
    }

    _focusAreas
      ..clear()
      ..addAll(migrated);
    await prefs.setStringList('focus_areas', _focusAreas);
  }

  // Load habits from storage
  Future<void> loadUserHabits() async {
    final prefs = await SharedPreferences.getInstance();

    // Load onboarding completion state
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    // Sync daily reminder state from persisted notification preferences
    _dailyReminderEnabled = prefs.getBool('notifications_enabled') ?? false;

    // Load focus areas
    final savedFocusAreas = prefs.getStringList('focus_areas');
    if (savedFocusAreas != null) {
      _focusAreas.clear();
      _focusAreas.addAll(savedFocusAreas);
      await _migrateRetiredFocusAreas(prefs);
    }

    _startersAppliedForPath = prefs.getString(_startersAppliedForPathKey);

    final savedHabits = prefs.getStringList('user_habits');

    if (savedHabits != null && savedHabits.isNotEmpty) {
      userHabits = savedHabits;

      // Load custom habits only if user has saved habits (onboarding was completed)
      final savedCustom = prefs.getStringList('custom_habits');
      if (savedCustom != null) {
        _customHabits = savedCustom;
      }

      // Load adoption stamps. Anything missing here stays missing: it means
      // the action predates this record, and the staleness rule reads unknown
      // as old enough. Stamping them now would silence a nudge those users
      // were already being shown.
      final adoptedJson = prefs.getString(_habitAdoptedAtKey);
      if (adoptedJson != null) {
        try {
          _habitAdoptedAt = (jsonDecode(adoptedJson) as Map).map(
            (title, at) => MapEntry(
              title as String,
              DateTime.parse(at as String).toUtc(),
            ),
          );
        } catch (_) {
          _habitAdoptedAt = {};
        }
      }

      // Load custom habit focus area mapping
      final focusAreasJson = prefs.getString('custom_habit_focus_areas');
      if (focusAreasJson != null) {
        try {
          _customHabitFocusAreas = Map<String, String>.from(
              jsonDecode(focusAreasJson) as Map);
        } catch (_) {
          _customHabitFocusAreas = {};
        }
      }

      // Load custom habit weekday masks. An absent title means every day, so
      // accounts made before masks existed load with an empty map and behave
      // exactly as they did.
      final daysJson = prefs.getString(_customHabitDaysKey);
      if (daysJson != null) {
        try {
          _customHabitDays = (jsonDecode(daysJson) as Map).map(
            (key, value) => MapEntry(
              key as String,
              (value as List).map((d) => d as int).toList(),
            ),
          );
        } catch (_) {
          _customHabitDays = {};
        }
      }

      // Migration: infer focus areas from existing habits for users who
      // completed onboarding before focus areas were persisted.
      if (_focusAreas.isEmpty && _onboardingComplete) {
        for (final entry in habitsByCategory.entries) {
          if (userHabits.any((h) => entry.value.contains(h))) {
            _focusAreas.add(entry.key);
          }
        }
        if (_focusAreas.isNotEmpty) {
          await prefs.setStringList('focus_areas', _focusAreas);
        }
      }
    } else {
      // No saved habits = fresh start — clear any stale custom habits from prefs
      _customHabits.clear();
      _customHabitFocusAreas.clear();
      _customHabitDays.clear();
      _habitAdoptedAt.clear();
      await prefs.remove('custom_habits');
      await prefs.remove('custom_habit_focus_areas');
      await prefs.remove(_customHabitDaysKey);
      await prefs.remove(customHabitDaysChangedAtKey);
      await prefs.remove(_habitAdoptedAtKey);
      await prefs.remove('pinned_habit');
    }
    
    // Load pinned habit and validate it still exists in user's habits
    _pinnedHabit = prefs.getString('pinned_habit');
    if (_pinnedHabit != null && !userHabits.contains(_pinnedHabit)) {
      // Pinned habit no longer in user's list — clear stale reference
      _pinnedHabit = null;
      await prefs.remove('pinned_habit');
    }

    // Validate custom habits still exist in user's habits list
    if (_customHabits.isNotEmpty) {
      final stale = _customHabits.where((h) => !userHabits.contains(h)).toList();
      if (stale.isNotEmpty) {
        _customHabits.removeWhere((h) => stale.contains(h));
        for (final h in stale) {
          _customHabitFocusAreas.remove(h);
          _customHabitDays.remove(h);
        }
        await prefs.setStringList('custom_habits', _customHabits);
        await _saveCustomHabitFocusAreas(prefs);
        await _saveCustomHabitDays(prefs);
      }

      // Migration: assign first active focus area to custom habits without one
      bool migrated = false;
      for (final habit in _customHabits) {
        if (!_customHabitFocusAreas.containsKey(habit) &&
            _focusAreas.isNotEmpty) {
          _customHabitFocusAreas[habit] = _focusAreas.first;
          migrated = true;
        }
      }
      if (migrated) {
        await _saveCustomHabitFocusAreas(prefs);
      }
    }

    // Load swap tracking
    final swapsRaw = prefs.getString('swaps_used');
    if (swapsRaw != null) {
      _swapsUsed.clear();
      try {
        final map = Map<String, String>.from(jsonDecode(swapsRaw) as Map);
        map.forEach((k, v) {
          _swapsUsed[k] = int.tryParse(v) ?? 0;
        });
      } catch (_) {
        // Fallback: old query string format for existing users
        Uri.splitQueryString(swapsRaw).forEach((k, v) {
          _swapsUsed[k] = int.tryParse(v) ?? 0;
        });
      }
    }
    
    final lastSwapStr = prefs.getString('last_swap_reset');
    if (lastSwapStr != null) {
      _lastSwapReset = DateTime.parse(lastSwapStr);
    }
    
    final lastFocusStr = prefs.getString('last_focus_change');
    if (lastFocusStr != null) {
      _lastFocusAreaChange = DateTime.parse(lastFocusStr);
    }
    
    _habitRefreshCount = prefs.getInt('habit_refresh_count') ?? 0;
    final lastRefreshStr = prefs.getString('last_habit_refresh');
    if (lastRefreshStr != null) {
      _lastHabitRefresh = DateTime.parse(lastRefreshStr);
    }
    
    // Check if we need to reset monthly limits
    _checkMonthlyReset();

    _checkDailyReset();
    
    notifyListeners();
  }

  // Check and reset monthly limits
  void _checkMonthlyReset() {
    final now = DateTime.now();
    
    // Reset swaps if it's a new month
    if (_lastSwapReset == null || 
        _lastSwapReset!.month != now.month || 
        _lastSwapReset!.year != now.year) {
      _swapsUsed.clear();
      _lastSwapReset = now;
      _saveSwapData();
    }
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    
    // Reset habit refresh count if it's a new day
    if (_lastHabitRefresh == null ||
        _lastHabitRefresh!.day != now.day ||
        _lastHabitRefresh!.month != now.month ||
        _lastHabitRefresh!.year != now.year) {
      _habitRefreshCount = 0;
    }
  }

  Future<void> _saveSwapData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save swaps as JSON
    final jsonStr = jsonEncode(_swapsUsed.map((k, v) => MapEntry(k, v.toString())));
    await prefs.setString('swaps_used', jsonStr);
    
    if (_lastSwapReset != null) {
      await prefs.setString('last_swap_reset', _lastSwapReset!.toIso8601String());
    }
  }

  // Pin a habit
  Future<void> pinHabit(String habitTitle) async {
    _pinnedHabit = habitTitle;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pinned_habit', habitTitle);
    
    // ❌ DO NOT mark habit as done here!
    // ❌ DO NOT call HabitTracker.markDone()!
  }

  // Unpin habit
  Future<void> unpinHabit() async {
    _pinnedHabit = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pinned_habit');
  }

  // Check if user can pin (Core: 1, Intended+: unlimited)
  bool canPinHabit() {
    // For now, allow 1 pinned habit (Core plan logic)
    return _pinnedHabit == null;
  }

  // Get category for a habit (includes custom habit focus areas)
  String? getCategoryForHabit(String habit) {
    for (final entry in habitsByCategory.entries) {
      if (entry.value.contains(habit)) {
        return entry.key;
      }
    }
    // An action from a retired focus area, still held by whoever had it.
    // This copy is the one `_handleSwap` consults: null here is not a grey
    // square but a dead end — "can't swap", and the card cannot be replaced
    // except by refreshing every action at once.
    final retired = retiredHabitCategories[habit];
    if (retired != null) return retired;
    // Check custom habit focus areas
    return _customHabitFocusAreas[habit];
  }

  /// Max swaps for the user's current tier (free or boost).
  /// Subscription users bypass this entirely at the call site.
  int maxSwaps() => _maxSwapsFree;

  // Check if user can swap (free: 2/month, boost: 3/month)
  bool canSwapInCategory(String category) {
    _checkMonthlyReset();
    return getTotalSwapsUsed() < maxSwaps();
  }

  // Get remaining swaps (global, not per-category)
  int getRemainingSwaps(String category) {
    _checkMonthlyReset();
    return maxSwaps() - getTotalSwapsUsed();
  }

  // Swap a habit
  Future<bool> swapHabit(String oldHabit, String newHabit, {bool isPremium = false}) async {
    final category = getCategoryForHabit(oldHabit);
    if (category == null) return false;

    if (!isPremium && !canSwapInCategory(category)) return false;

    final index = userHabits.indexOf(oldHabit);
    if (index == -1) return false;

    userHabits[index] = newHabit;

    // The incoming action starts from nothing, however long the one it
    // replaced had been here — saving below drops the outgoing one's stamp.
    _recordAdopted([newHabit]);

    // If the swapped habit was pinned, transfer the pin
    if (_pinnedHabit == oldHabit) {
      _pinnedHabit = newHabit;
    }

    // Increment swap count
    _swapsUsed[category] = (_swapsUsed[category] ?? 0) + 1;
    ReflectionService.incrementSwapCount();

    // Notify UI immediately so cards update before async saves
    notifyListeners();

    // Persist in background
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_habits', userHabits);
    await _saveHabitAdoptions(prefs);
    if (_pinnedHabit == newHabit) {
      await prefs.setString('pinned_habit', newHabit);
    }
    await _saveSwapData();

    return true;
  }

  // Get total swaps used across all categories (for Browse flow)
  int getTotalSwapsUsed() {
    _checkMonthlyReset();
    return _swapsUsed.values.fold(0, (sum, count) => sum + count);
  }

  // Check if user can swap from Browse (free: 2/month, boost: 3/month)
  bool canSwapFromBrowse() {
    return getTotalSwapsUsed() < maxSwaps();
  }

  // Get remaining Browse swaps
  int getRemainingBrowseSwaps() {
    return maxSwaps() - getTotalSwapsUsed();
  }



  // Get alternative habits for swapping
  List<String> getAlternativeHabits(String currentHabit) {
    final category = getCategoryForHabit(currentHabit);
    if (category == null) return [];
    
    final allInCategory = habitsByCategory[category] ?? [];
    final available = allInCategory
        .where((h) => !userHabits.contains(h))
        .toList();
    
    available.shuffle();
    return available.take(3).toList();
  }

  // Check if user can change focus areas
  bool canChangeFocusAreas() {
    if (_lastFocusAreaChange == null) return true;
    
    final now = DateTime.now();
    return _lastFocusAreaChange!.month != now.month || 
           _lastFocusAreaChange!.year != now.year;
  }

  bool canRefreshHabits() {
    final now = DateTime.now();
    
    if (_lastHabitRefresh == null ||
        _lastHabitRefresh!.day != now.day ||
        _lastHabitRefresh!.month != now.month ||
        _lastHabitRefresh!.year != now.year) {
      // New day - reset counter
      _habitRefreshCount = 0;
      return true;
    }
  
    return _habitRefreshCount < _maxDailyRefreshes;
  }

  // Change focus areas
  Future<void> changeFocusAreas(List<String> newAreas) async {
    _focusAreas.clear();
    _focusAreas.addAll(newAreas);
    _lastFocusAreaChange = DateTime.now();
    
    // Generate new habits (custom habits will be preserved inside this method now)
    await generateUserHabits();
    
    // Save focus areas and timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('focus_areas', _focusAreas);
    await prefs.setString('last_focus_change', _lastFocusAreaChange!.toIso8601String());
    
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;

    if (userHabits.isEmpty) {
      await generateUserHabits();
    }

    // Persist onboarding completion
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setBool('just_completed_onboarding', true);
    await prefs.setStringList('focus_areas', _focusAreas);

    notifyListeners();
  }

  Future<void> refreshHabits() async {
    if (!canRefreshHabits()) return;

    _habitRefreshCount++;
    _lastHabitRefresh = DateTime.now();
    ReflectionService.incrementRefreshCount();
    
    // Save state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('habit_refresh_count', _habitRefreshCount);
    await prefs.setString('last_habit_refresh', _lastHabitRefresh!.toIso8601String());
    
    await generateUserHabits();
  }

  /// Max custom habits for the user's current tier (free or boost).
  /// Subscription users bypass this entirely at the call site.
  int maxCustomHabits() => _maxCustomHabitsFree;

  bool canAddCustomHabit() {
    return _customHabits.length < maxCustomHabits();
  }

  /// False when the list is already full — the caller shows the swap door
  /// rather than the habit quietly failing to appear.
  Future<bool> addCustomHabit(String habitTitle, {String? focusArea}) async {
    if (!canAddHabit) return false;
    // Tier limits live at the entry point (_createCustomHabit shows the
    // paywall at the free cap). Guarding again here silently blocked *paid*
    // users at two, because this layer cannot see the subscription.
    if (userHabits.any((h) => h.toLowerCase() == habitTitle.toLowerCase())) {
      return false;
    }

    _customHabits.add(habitTitle);
    userHabits.add(habitTitle);
    _recordAdopted([habitTitle]);

    // Assign focus area (default to first active focus area)
    final area = focusArea ?? (_focusAreas.isNotEmpty ? _focusAreas.first : null);
    if (area != null) {
      _customHabitFocusAreas[habitTitle] = area;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_habits', _customHabits);
    await prefs.setStringList('user_habits', userHabits);
    await _saveCustomHabitFocusAreas(prefs);
    await _saveHabitAdoptions(prefs);
    // The recorder reads a static map loaded once at launch. Without this,
    // a custom made mid-session is recorded with no focus area at all —
    // a grey tile, absent from the legend, matched by no colour chip.
    await ReflectionService.loadCustomHabitFocusAreas();

    notifyListeners();
    return true;
  }

  Future<void> removeCustomHabit(String habitTitle) async {
    _customHabits.remove(habitTitle);
    userHabits.remove(habitTitle);
    _customHabitFocusAreas.remove(habitTitle);
    _customHabitDays.remove(habitTitle);

    // Clear pinned habit if the deleted habit was pinned
    if (_pinnedHabit == habitTitle) {
      _pinnedHabit = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_habits', _customHabits);
    await prefs.setStringList('user_habits', userHabits);
    await _saveCustomHabitFocusAreas(prefs);
    await _saveCustomHabitDays(prefs);
    await _saveHabitAdoptions(prefs);
    if (_pinnedHabit == null) {
      await prefs.remove('pinned_habit');
    }

    notifyListeners();
  }

  Future<void> renameCustomHabit(String oldTitle, String newTitle) async {
    final idx = _customHabits.indexOf(oldTitle);
    if (idx == -1) return;
    _customHabits[idx] = newTitle;

    final hIdx = userHabits.indexOf(oldTitle);
    if (hIdx != -1) {
      userHabits[hIdx] = newTitle;
    }

    if (_pinnedHabit == oldTitle) {
      _pinnedHabit = newTitle;
    }

    // Migrate focus area mapping
    final area = _customHabitFocusAreas.remove(oldTitle);
    if (area != null) {
      _customHabitFocusAreas[newTitle] = area;
    }

    // Migrate the weekday mask. Rewording an action does not reschedule it,
    // and this is not a mask *change* — so it must not re-stamp
    // [customHabitDaysChangedAtKey] and suppress drift for another month.
    final days = _customHabitDays.remove(oldTitle);
    if (days != null) {
      _customHabitDays[newTitle] = days;
    }

    // Rewording an action is not adopting a new one, so it keeps its age.
    // Otherwise renaming a two-day-old custom would hand it a fresh unknown
    // stamp and make it eligible for the nudge straight away.
    final adoptedAt = _habitAdoptedAt.remove(oldTitle);
    if (adoptedAt != null) {
      _habitAdoptedAt[newTitle] = adoptedAt;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_habits', _customHabits);
    await prefs.setStringList('user_habits', userHabits);
    await _saveCustomHabitFocusAreas(prefs);
    await _saveCustomHabitDays(prefs);
    await _saveHabitAdoptions(prefs);
    if (_pinnedHabit == newTitle) {
      await prefs.setString('pinned_habit', newTitle);
    }

    // Move the moments too. Outside the id guard below on purpose: a rename
    // that only changes case or punctuation slugs to the same id, so the
    // completion keys need no migration while `habitName` — the full title,
    // and the key everything else joins on — still changed.
    await MomentsService.renameHabit(oldTitle, newTitle);

    // Migrate completion history keys
    final oldId = _habitId(oldTitle);
    final newId = _habitId(newTitle);
    if (oldId != newId) {
      for (final key in prefs.getKeys().toList()) {
        if (key.startsWith('habit_done_${oldId}_')) {
          final date = key.substring('habit_done_${oldId}_'.length);
          final value = prefs.getBool(key) ?? false;
          await prefs.setBool('habit_done_${newId}_$date', value);
          await prefs.remove(key);
        }
      }
      // Migrate title cache
      final cachedTitle = prefs.getString('habit_title_$oldId');
      if (cachedTitle != null) {
        await prefs.setString('habit_title_$newId', newTitle);
        await prefs.remove('habit_title_$oldId');
      }
    }

    notifyListeners();
  }

  static String _habitId(String habitTitle) {
    return habitTitle
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  bool isCustomHabit(String habitTitle) {
    return _customHabits.contains(habitTitle);
  }

  /// Persists custom habit → focus area mapping as JSON.
  Future<void> _saveCustomHabitFocusAreas(SharedPreferences prefs) async {
    await prefs.setString(
        'custom_habit_focus_areas', jsonEncode(_customHabitFocusAreas));
  }

  /// Persists custom habit → weekday mask as JSON. Mirrors
  /// [_saveCustomHabitFocusAreas]: same shape, same lifecycle, same call sites.
  Future<void> _saveCustomHabitDays(SharedPreferences prefs) async {
    await prefs.setString(_customHabitDaysKey, jsonEncode(_customHabitDays));
  }

  Future<void> reset() async {
    _welcomeSeen = false;
    _name = null;
    _focusAreas.clear();
    _lastPreselectedPathKey = null;
    _startersAppliedForPath = null;
    _dailyReminderEnabled = false;
    _onboardingComplete = false;
    userHabits.clear();
    _customHabits.clear();
    _customHabitFocusAreas.clear();
    _customHabitDays.clear();
    _habitAdoptedAt.clear();
    _pinnedHabit = null;
    _swapsUsed.clear();
    _lastSwapReset = null;
    _lastFocusAreaChange = null;
    _habitRefreshCount = 0;
    _lastHabitRefresh = null;
    notifyListeners();

    // Also clear persisted habit data so stale data doesn't reload
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_habits');
    await prefs.remove('custom_habits');
    await prefs.remove('custom_habit_focus_areas');
    await prefs.remove(_customHabitDaysKey);
    await prefs.remove(customHabitDaysChangedAtKey);
    await prefs.remove(_habitAdoptedAtKey);
    await prefs.remove(_startersAppliedForPathKey);
    await prefs.remove('pinned_habit');
    await prefs.remove('swaps_used');
    await prefs.remove('last_swap_reset');
    await prefs.remove('habit_refresh_count');
    await prefs.remove('last_habit_refresh');
    await prefs.remove('focus_areas');
    await prefs.remove('onboarding_complete');
    await prefs.remove('last_focus_change');
    await prefs.remove('just_completed_onboarding');
  }
}