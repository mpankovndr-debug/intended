import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const int _maxCustomHabitsFree = 2;
  static const int _maxSwapsFree = 2;
  static const int _maxFocusAreasFree = 2;

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
  String? get pinnedHabit => _pinnedHabit;
  List<String> get customHabits => List.unmodifiable(_customHabits);
  Map<String, String> get customHabitFocusAreas =>
      Map.unmodifiable(_customHabitFocusAreas);

  // All available habits by category (EXPANDED TO 12 EACH)
  static const Map<String, List<String>> habitsByCategory = {
    'Health': [
      // Starter (very easy)
      'Drink a glass of water',
      'Take 3 slow breaths',
      'Stretch for 10 seconds',
      // Core
      'Stand up and roll your shoulders',
      'Step outside for 30 seconds',
      'Close your eyes for 20 seconds',
      'Do 5 gentle neck rolls',
      'Walk to the window and back',
      'Take 5 deep belly breaths',
      // Advanced
      '2-minute body scan',
      '10 minutes of gentle movement',
      'Eat one meal mindfully',
    ],
    'Mood': [
      'Ten-second pause',
      'Notice one thing you feel',
      'One grounding breath',
      'Look away from your screen for 10 seconds',
      'Name three things you can see',
      'Notice one sound around you',
      'Feel your feet on the ground',
      'Place hand on heart for a moment',
      'Notice one thing you\'re grateful for',
      'Smile gently at yourself',
      'Ask yourself "what do I need right now?"',
      'Give yourself permission to rest',
    ],
    'Productivity': [
      'Set one priority',
      'Plan tomorrow in one sentence',
      'Do a 30-second reset',
      'Write down one idea',
      'Finish one tiny task',
      'Declutter your desk for 2 minutes',
      'Review your calendar',
      'Turn off one notification',
      'Close one browser tab',
      'Archive 5 old emails',
      'Update one to-do item',
    ],
    'Home & organization': [
      'Tidy one small thing',
      'Put one thing back where it belongs',
      'Wipe one surface',
      'Open a window for fresh air',
      'Make your bed',
      'Clear one shelf',
      'Wash 3 dishes',
      'Take out one small bag of trash',
      'Fold 3 items of clothing',
      'Organize one drawer',
      'Water one plant',
      'Light a candle',
    ],
    'Relationships': [
      'Send one message to someone',
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
      'Write one sentence',
      'Doodle for 10 seconds',
      'Capture one idea',
      'Notice one beautiful thing',
      'Take one photo of something you like',
      'Draw one simple shape',
      'Hum a tune you enjoy',
      'Rearrange something small',
      'Try one new word',
      'Create one tiny thing',
      'Play with one creative medium',
      'Imagine one possibility',
    ],
    'Finances': [
      'Check your balance',
      'Move €1 to savings',
      'Review one subscription',
      'Note one expense',
      'Read one financial tip',
      'Delete one old receipt',
      'Update one budget category',
      'Review one bill',
      'Price-check one item before buying',
      'Wait 24 hours before one purchase',
      'Celebrate one money win',
      'Set one small savings goal',
    ],
    'Self-care': [
      'Sit still for 10 seconds',
      'Do one kind thing for yourself',
      'Drink water slowly',
      'Stretch your neck',
      'Take one slow breath',
      'Notice something you like about yourself',
      'Give yourself permission to say no',
      'Do something that feels good',
      'Rest for 2 minutes',
      'Put on something comfortable',
      'Listen to one song you love',
      'Do absolutely nothing for 30 seconds',
    ],
  };

  void setName(String value) {
    _name = value;
    notifyListeners();
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

    if (_focusAreas.isEmpty) {
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

    // ✅ PRESERVE custom habits - add them back after generating
    userHabits = [...selectedHabits, ..._customHabits];

    // Validate pinned habit still exists in new habit list
    final pinnedCleared = _pinnedHabit != null && !userHabits.contains(_pinnedHabit);
    if (pinnedCleared) {
      _pinnedHabit = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_habits', userHabits);
    if (pinnedCleared) {
      await prefs.remove('pinned_habit');
    }

    notifyListeners();
  }

  Future<void> addHabitFromBrowse(String habit) async {
    if (!userHabits.contains(habit)) {
      userHabits.add(habit);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_habits', userHabits);
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
    notifyListeners();
  }

  /// Adds multiple habits from a curated pack, skipping any already active.
  /// Returns the number of newly added habits.
  Future<int> addHabitsFromPack(List<String> habitIds) async {
    int added = 0;
    for (final habit in habitIds) {
      if (!userHabits.contains(habit)) {
        userHabits.add(habit);
        added++;
      }
    }
    if (added > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_habits', userHabits);
      notifyListeners();
    }
    return added;
  }

  /// Updates focus areas to match a curated pack without regenerating habits.
  Future<void> applyPackFocusAreas(List<String> packFocusAreas) async {
    _focusAreas.clear();
    _focusAreas.addAll(packFocusAreas);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('focus_areas', _focusAreas);
    notifyListeners();
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
    }

    final savedHabits = prefs.getStringList('user_habits');

    if (savedHabits != null && savedHabits.isNotEmpty) {
      userHabits = savedHabits;

      // Load custom habits only if user has saved habits (onboarding was completed)
      final savedCustom = prefs.getStringList('custom_habits');
      if (savedCustom != null) {
        _customHabits = savedCustom;
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
      await prefs.remove('custom_habits');
      await prefs.remove('custom_habit_focus_areas');
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
        }
        await prefs.setStringList('custom_habits', _customHabits);
        await _saveCustomHabitFocusAreas(prefs);
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

  Future<void> addCustomHabit(String habitTitle, {String? focusArea}) async {
    if (!canAddCustomHabit()) return;
    if (userHabits.any((h) => h.toLowerCase() == habitTitle.toLowerCase())) return;

    _customHabits.add(habitTitle);
    userHabits.add(habitTitle);

    // Assign focus area (default to first active focus area)
    final area = focusArea ?? (_focusAreas.isNotEmpty ? _focusAreas.first : null);
    if (area != null) {
      _customHabitFocusAreas[habitTitle] = area;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_habits', _customHabits);
    await prefs.setStringList('user_habits', userHabits);
    await _saveCustomHabitFocusAreas(prefs);

    notifyListeners();
  }

  Future<void> removeCustomHabit(String habitTitle) async {
    _customHabits.remove(habitTitle);
    userHabits.remove(habitTitle);
    _customHabitFocusAreas.remove(habitTitle);

    // Clear pinned habit if the deleted habit was pinned
    if (_pinnedHabit == habitTitle) {
      _pinnedHabit = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_habits', _customHabits);
    await prefs.setStringList('user_habits', userHabits);
    await _saveCustomHabitFocusAreas(prefs);
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_habits', _customHabits);
    await prefs.setStringList('user_habits', userHabits);
    await _saveCustomHabitFocusAreas(prefs);
    if (_pinnedHabit == newTitle) {
      await prefs.setString('pinned_habit', newTitle);
    }

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

  Future<void> reset() async {
    _welcomeSeen = false;
    _name = null;
    _focusAreas.clear();
    _dailyReminderEnabled = false;
    _onboardingComplete = false;
    userHabits.clear();
    _customHabits.clear();
    _customHabitFocusAreas.clear();
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