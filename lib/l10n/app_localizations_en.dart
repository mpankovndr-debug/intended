// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonGreat => 'Great';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonStart => 'Start';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get appNameIntended => 'Intended';

  @override
  String get appNameIntendedPlus => 'Intended+';

  @override
  String get appPlanCore => 'Core';

  @override
  String get appPlanBoost => 'Boost';

  @override
  String get appUnlockPlus => 'Unlock Intended+';

  @override
  String get welcomeTitle => 'Welcome to Intended';

  @override
  String welcomeTitleWithName(String name) {
    return 'Welcome to Intended,\n$name';
  }

  @override
  String get welcomeSubtitle => 'Small steps.\nNo pressure.';

  @override
  String get onboardingTagline => 'Intention, not perfection.';

  @override
  String get onboardingNamePrompt => 'What should we call you?';

  @override
  String get onboardingSkipForNow => 'Skip for now';

  @override
  String onboardingNameTooLong(int max) {
    return 'Name should be under $max characters';
  }

  @override
  String get onboardingNameInappropriate =>
      'Please choose a more appropriate name';

  @override
  String get onboardingOops => 'Oops';

  @override
  String get focusAreaHealth => 'Health';

  @override
  String get focusAreaMood => 'Mood';

  @override
  String get focusAreaProductivity => 'Productivity';

  @override
  String get focusAreaHome => 'Home & organization';

  @override
  String get focusAreaRelationships => 'Relationships';

  @override
  String get focusAreaCreativity => 'Creativity';

  @override
  String get focusAreaFinances => 'Finances';

  @override
  String get focusAreaSelfCare => 'Self-care';

  @override
  String get focusAreasTitle => 'Focus areas';

  @override
  String focusAreasPromptWithName(String name) {
    return 'What matters to you right now, $name?';
  }

  @override
  String get focusAreasPrompt => 'What matters to you right now?';

  @override
  String focusAreasChooseCount(int count, int max) {
    return 'Choose up to two areas ($count/$max)';
  }

  @override
  String get focusAreasChangeLater => 'You can change this later.';

  @override
  String get focusAreasLimitTitle => 'Limit Reached';

  @override
  String get focusAreasLimitMessage =>
      'You can select up to 2 areas. Deselect one to choose another.';

  @override
  String get focusLimitFreeTitle => 'Two is a great start';

  @override
  String get focusLimitFreeMessage =>
      'Want to explore more? Upgrade to Intended+ for unlimited focus areas.';

  @override
  String get focusLimitFreeUpgrade => 'Upgrade';

  @override
  String get focusNudgeTitle => 'A gentle thought';

  @override
  String get focusNudgeMessage =>
      "You can choose as many as you'd like! Focusing on fewer areas tends to lead to deeper growth. But you know yourself best.";

  @override
  String get focusNudgeGotIt => 'Got it';

  @override
  String get reminderTitle => 'Reminder';

  @override
  String get reminderSubtitle => 'Want a gentle daily reminder?';

  @override
  String get reminderDescription => 'Just once a day. No pressure.';

  @override
  String get reminderDailyToggle => 'Gentle daily reminder';

  @override
  String reminderAroundTime(String time) {
    return 'Around $time';
  }

  @override
  String get reminderTimeLabel => 'Remind me at';

  @override
  String get reminderTimePicker => 'Set reminder time';

  @override
  String get reminderSwitchHint =>
      'Switch this on to pick the time for your daily reminder.';

  @override
  String get reminderNoWorries =>
      'No worries — you can turn these on anytime from your profile.';

  @override
  String get reminderWeeklySummary => 'Weekly summary';

  @override
  String get reminderWeeklySubtitle => 'Every Sunday evening';

  @override
  String reminderLetsGo(String name) {
    return 'Let\'s go, $name';
  }

  @override
  String get themeSelectionTitle => 'Choose your space';

  @override
  String get themeSelectionSubtitle => 'You can always change this later.';

  @override
  String get themeSelectionConfirm => 'This feels right';

  @override
  String get themeSelectionPremiumHint =>
      'Clear Sky and Morning Slate are available with Intended+. Try it free for 7 days after setup.';

  @override
  String get habitRevealTitle => 'Here\'s what we picked for you';

  @override
  String get habitRevealSubtitleDefault => 'Based on your preferences';

  @override
  String habitRevealSubtitleOneArea(String area) {
    return 'Based on $area';
  }

  @override
  String habitRevealSubtitleTwoAreas(String area1, String area2) {
    return 'Based on $area1 & $area2';
  }

  @override
  String get habitRevealDescription =>
      'You can add, remove, or browse more habits anytime. There\'s no pressure to do them all.';

  @override
  String get habitRevealBegin => 'Let\'s begin';

  @override
  String get habitsHoldForOptions => 'Long press a habit for options';

  @override
  String get habitsCompleteOnboarding => 'Complete onboarding to get started';

  @override
  String get habitsPinned => 'PINNED';

  @override
  String get habitsSuggestions => 'SUGGESTIONS';

  @override
  String get habitsCreateCustom => 'Create custom habit';

  @override
  String get habitsBrowseAll => 'Browse all habits';

  @override
  String habitsMoreAvailable(int count) {
    return '$count more available';
  }

  @override
  String get habitBreath => 'Three slow breaths';

  @override
  String get habitPause => 'Ten-second pause';

  @override
  String get habitWater => 'Mindful water';

  @override
  String get habitStretch => 'Gentle stretch';

  @override
  String get habitPriority => 'One priority';

  @override
  String get habitCheckin => 'Honest check-in';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayShortMon => 'M';

  @override
  String get dayShortTue => 'T';

  @override
  String get dayShortWed => 'W';

  @override
  String get dayShortThu => 'T';

  @override
  String get dayShortFri => 'F';

  @override
  String get dayShortSat => 'S';

  @override
  String get dayShortSun => 'S';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get dailyMessage1 => 'Do what feels right today';

  @override
  String get dailyMessage2 => 'Today is a fresh start';

  @override
  String get dailyMessage3 => 'Just one small thing counts';

  @override
  String get dailyMessage4 => 'Be kind to yourself today';

  @override
  String get dailyMessage5 => 'No rush. You\'re doing well';

  @override
  String get dailyMessage6 => 'Start small, stay gentle';

  @override
  String get dailyMessage7 => 'Your pace is your own';

  @override
  String get dailyMessage8 => 'Even one step is progress';

  @override
  String get dailyMessage9 => 'Take what works, leave the rest';

  @override
  String get dailyMessage10 => 'You don\'t have to do it all';

  @override
  String get dailyMessage11 => 'Small moments add up';

  @override
  String get dailyMessage12 => 'Be where you are right now';

  @override
  String get dailyMessage13 => 'There\'s no wrong way to begin';

  @override
  String get dailyMessage14 => 'Listen to what you need today';

  @override
  String get dailyMessage15 => 'Progress looks different every day';

  @override
  String get dailyMessage16 => 'You\'re allowed to take your time';

  @override
  String get dailyMessage17 => 'One thing at a time is enough';

  @override
  String get dailyMessage18 => 'Give yourself permission to rest';

  @override
  String get dailyMessage19 => 'Start wherever you are';

  @override
  String get dailyMessage20 => 'You don\'t need to be ready';

  @override
  String get dailyMessage21 => 'Trust your own rhythm';

  @override
  String get dailyMessage22 => 'It\'s okay to adjust as you go';

  @override
  String get dailyMessage23 => 'Gentle is good enough';

  @override
  String get dailyMessage24 => 'Small acts of care matter';

  @override
  String get dailyMessage25 => 'You\'re doing more than you think';

  @override
  String get customHabitTitle => 'Create custom habit';

  @override
  String get customHabitPrompt => 'What small action would you like to take?';

  @override
  String get customHabitHint => 'Keep it simple and specific.';

  @override
  String get customHabitPlaceholder => 'e.g., Take a 5-minute walk';

  @override
  String customHabitCharCount(int count) {
    return '$count/50 characters';
  }

  @override
  String get customHabitSubmit => 'Add to my habits';

  @override
  String get customHabitCreatedTitle => 'Habit created';

  @override
  String customHabitCreatedMessage(String title) {
    return '\"$title\" has been added to your habits.';
  }

  @override
  String get customHabitLimitTitle => 'Create more habits?';

  @override
  String get customHabitLimitMessage =>
      'Core: 2 custom habits\nBoost: 3 custom habits\nIntended+: Unlimited custom habits';

  @override
  String get menuUnpin => 'Unpin';

  @override
  String get menuPinToTop => 'Pin to top';

  @override
  String get menuSwap => 'Swap for another';

  @override
  String get replacePinTitle => 'Replace pin?';

  @override
  String replacePinDescription(String current, String newHabit) {
    return 'Current: $current\nNew: $newHabit';
  }

  @override
  String get replacePinConfirm => 'Replace pin';

  @override
  String get swapCantTitle => 'Can\'t swap this habit';

  @override
  String get swapCantMessage =>
      'Custom habits can\'t be swapped. You can delete it and add a new one instead.';

  @override
  String swapTitle(String title) {
    return 'Swap \"$title\"?';
  }

  @override
  String swapCategoryHabits(String category) {
    return 'More $category habits:';
  }

  @override
  String swapFreeRemaining(int remaining) {
    return 'Free swaps left: $remaining';
  }

  @override
  String get swapSuccessTitle => 'Habit swapped';

  @override
  String swapSuccessMessage(String habit) {
    return 'Replaced with \"$habit\"';
  }

  @override
  String get swapErrorTitle => 'Something went wrong';

  @override
  String get swapErrorMessage =>
      'We couldn\'t swap this habit. Please try again.';

  @override
  String get swapLimitTitle => 'Swap this habit?';

  @override
  String get swapLimitMessage =>
      'You\'ve used all your free swaps this month.\n\nBoost: 3 swaps/month\nIntended+: Unlimited swaps';

  @override
  String get swapNoAltTitle => 'No alternatives';

  @override
  String get swapNoAltMessage =>
      'You\'re already using all available habits from this category.';

  @override
  String get deleteHabitTitle => 'Delete habit?';

  @override
  String deleteHabitMessage(String title) {
    return '\"$title\" will be removed and any progress lost.';
  }

  @override
  String get completionQuestion => 'Did you do this today?';

  @override
  String get completionConfirm => 'I did it';

  @override
  String get completionDecline => 'Not today';

  @override
  String get celebrationNice => 'Nice';

  @override
  String get celebrationWellDone => 'Well done';

  @override
  String get celebrationYouDidIt => 'You did it';

  @override
  String get celebrationGreat => 'Great';

  @override
  String get celebrationWayToGo => 'Way to go';

  @override
  String get celebrationGoodJob => 'Good job';

  @override
  String get celebrationLovely => 'Lovely';

  @override
  String get celebrationThatCounts => 'That counts';

  @override
  String get completionMsg1 => 'Small steps like this matter.';

  @override
  String get completionMsg2 => 'You showed up today.';

  @override
  String get completionMsg3 => 'This is how change happens.';

  @override
  String get completionMsg4 => 'One step closer.';

  @override
  String get completionMsg5 => 'You did what you said you would.';

  @override
  String get completionMsg6 => 'That took effort. Good.';

  @override
  String get completionMsg7 => 'Another small victory.';

  @override
  String get completionMsg8 => 'You made it happen.';

  @override
  String get completionMsg9 => 'Progress is progress.';

  @override
  String get completionMsg10 => 'You followed through.';

  @override
  String get completionMsg11 => 'This counts.';

  @override
  String get completionMsg12 => 'You kept your word to yourself.';

  @override
  String get completionMsg13 => 'Well done.';

  @override
  String get completionMsg14 => 'You made time for this.';

  @override
  String get completionMsg15 => 'That\'s growth right there.';

  @override
  String get completionMsg16 => 'You pushed through.';

  @override
  String get completionMsg17 => 'Another habit built.';

  @override
  String get completionMsg18 => 'You committed and you did it.';

  @override
  String get completionMsg19 => 'This adds up.';

  @override
  String get completionMsg20 => 'You honored your intention.';

  @override
  String get insightWater1 =>
      'Even mild dehydration can affect mood and concentration.';

  @override
  String get insightWater2 =>
      'Your brain is 75% water. Hydration affects cognitive function.';

  @override
  String get insightWater3 => 'Drinking water can reduce fatigue by up to 14%.';

  @override
  String get insightExercise1 =>
      'Just 10 minutes of movement increases blood flow to your brain.';

  @override
  String get insightExercise2 =>
      'Exercise releases endorphins that improve mood for hours.';

  @override
  String get insightExercise3 =>
      'Regular movement reduces anxiety as effectively as meditation.';

  @override
  String get insightWalk1 =>
      'Walking outdoors reduces cortisol levels within 20 minutes.';

  @override
  String get insightWalk2 => 'A 10-minute walk can boost creativity by 60%.';

  @override
  String get insightWalk3 =>
      'Walking improves memory recall by increasing hippocampal activity.';

  @override
  String get insightStretch1 =>
      'Stretching increases blood flow and reduces muscle tension.';

  @override
  String get insightStretch2 =>
      'Regular stretching can improve flexibility by 20% in just weeks.';

  @override
  String get insightStretch3 =>
      'Stretching triggers the parasympathetic nervous system, reducing stress.';

  @override
  String get insightSleep1 =>
      'Quality sleep strengthens memory consolidation by 40%.';

  @override
  String get insightSleep2 =>
      'Consistent sleep schedules regulate circadian rhythm and mood.';

  @override
  String get insightSleep3 =>
      'Sleep deprivation reduces cognitive performance like alcohol does.';

  @override
  String get insightBed1 =>
      'A consistent bedtime routine signals your brain to prepare for sleep.';

  @override
  String get insightBed2 =>
      'Going to bed at the same time improves sleep quality by 25%.';

  @override
  String get insightBed3 =>
      'Your body\'s natural melatonin production peaks with routine.';

  @override
  String get insightBreathe1 =>
      'Deep breathing activates the vagus nerve, calming your nervous system.';

  @override
  String get insightBreathe2 =>
      'Controlled breathing can reduce stress hormones within minutes.';

  @override
  String get insightBreathe3 =>
      'Box breathing is used by Navy SEALs to manage high-stress situations.';

  @override
  String get insightMeditate1 =>
      'Just 10 minutes of meditation increases gray matter in the brain.';

  @override
  String get insightMeditate2 =>
      'Regular meditation reduces the size of the amygdala (fear center).';

  @override
  String get insightMeditate3 =>
      'Mindfulness practice improves emotional regulation over time.';

  @override
  String get insightRead1 =>
      'Reading for 6 minutes can reduce stress levels by 68%.';

  @override
  String get insightRead2 =>
      'Regular reading strengthens neural pathways and connectivity.';

  @override
  String get insightRead3 =>
      'Reading before bed improves sleep quality more than screens.';

  @override
  String get insightCall1 =>
      'Social connection is as important to health as exercise and diet.';

  @override
  String get insightCall2 =>
      'A 10-minute conversation can reduce feelings of loneliness.';

  @override
  String get insightCall3 =>
      'Voice contact releases oxytocin, the bonding hormone.';

  @override
  String get insightFriend1 =>
      'Strong social ties can increase longevity by 50%.';

  @override
  String get insightFriend2 =>
      'Quality friendships reduce stress hormones significantly.';

  @override
  String get insightFriend3 =>
      'Social connection boosts immune system function.';

  @override
  String get insightWrite1 =>
      'Writing about emotions activates the prefrontal cortex, reducing stress.';

  @override
  String get insightWrite2 =>
      'Journaling can improve immune function and reduce symptoms.';

  @override
  String get insightWrite3 =>
      'Expressive writing helps process difficult experiences.';

  @override
  String get insightJournal1 =>
      'Daily journaling increases self-awareness and emotional clarity.';

  @override
  String get insightJournal2 =>
      'Writing down worries reduces rumination and anxiety.';

  @override
  String get insightJournal3 =>
      'Gratitude journaling rewires the brain for positivity over time.';

  @override
  String get insightVegetable1 =>
      'Eating vegetables increases gut bacteria diversity, improving mood.';

  @override
  String get insightVegetable2 =>
      'Plant nutrients support neurotransmitter production.';

  @override
  String get insightVegetable3 =>
      'Colorful vegetables contain antioxidants that protect brain cells.';

  @override
  String get insightBreakfast1 =>
      'Eating breakfast stabilizes blood sugar and improves focus.';

  @override
  String get insightBreakfast2 =>
      'Morning nutrition jumpstarts your metabolism for the day.';

  @override
  String get insightBreakfast3 =>
      'Breakfast eaters have better cognitive performance.';

  @override
  String get insightPhone1 =>
      'Reducing screen time before bed improves sleep quality by 30%.';

  @override
  String get insightPhone2 =>
      'Blue light suppresses melatonin production for up to 3 hours.';

  @override
  String get insightPhone3 =>
      'Taking breaks from screens reduces eye strain and headaches.';

  @override
  String get insightScreen1 =>
      'Every hour away from screens improves mental clarity.';

  @override
  String get insightScreen2 =>
      'Digital detoxes reduce anxiety and improve real-world connection.';

  @override
  String get insightScreen3 =>
      'Screen breaks help maintain healthy dopamine regulation.';

  @override
  String get insightClean1 =>
      'A tidy space reduces cortisol levels and mental clutter.';

  @override
  String get insightClean2 =>
      'Organized environments improve focus and productivity by 25%.';

  @override
  String get insightClean3 =>
      'Cleaning is a form of physical activity that reduces stress.';

  @override
  String get insightOrganize1 =>
      'Organization reduces decision fatigue throughout your day.';

  @override
  String get insightOrganize2 =>
      'Clutter-free spaces improve cognitive processing.';

  @override
  String get insightOrganize3 =>
      'An organized environment correlates with better sleep quality.';

  @override
  String get insightDraw1 =>
      'Creative activities increase dopamine production naturally.';

  @override
  String get insightDraw2 =>
      'Art engages both brain hemispheres, improving neural connectivity.';

  @override
  String get insightDraw3 =>
      'Drawing reduces stress hormones within 45 minutes.';

  @override
  String get insightMusic1 =>
      'Playing music strengthens the corpus callosum in the brain.';

  @override
  String get insightMusic2 =>
      'Musical practice improves executive function and memory.';

  @override
  String get insightMusic3 =>
      'Music activates the reward system, releasing dopamine.';

  @override
  String get warmthMsg1 => 'That\'s okay. Tomorrow is still yours.';

  @override
  String get warmthMsg2 => 'Rest counts too.';

  @override
  String get warmthMsg3 => 'You don\'t have to every day. Just sometimes.';

  @override
  String get warmthMsg4 => 'Not today — and that\'s allowed.';

  @override
  String get warmthMsg5 => 'Be as kind to yourself as you\'d be to a friend.';

  @override
  String get warmthMsg6 => 'The habit will be here when you\'re ready.';

  @override
  String get warmthMsg7 => 'Even stepping back gently is still showing up.';

  @override
  String get warmthMsg8 => 'Nothing is lost. You\'re still here.';

  @override
  String get warmthMsg9 =>
      'Some days are for resting. This might be one of them.';

  @override
  String get warmthMsg10 =>
      'Kindness toward yourself is a habit worth keeping.';

  @override
  String get warmthMsg11 => 'No streak to break. No score to lose. Just you.';

  @override
  String get warmthMsg12 => 'The gentlest days matter too.';

  @override
  String get warmthMsg13 => 'You showed up enough today just by being here.';

  @override
  String get warmthMsg14 => 'It\'s okay to let this one go.';

  @override
  String get warmthMsg15 =>
      'Progress isn\'t only visible. Sometimes it\'s just surviving.';

  @override
  String get notifMsg1 => 'No rush today. Even one small thing counts.';

  @override
  String get notifMsg2 => 'You don\'t have to be productive to deserve rest.';

  @override
  String get notifMsg3 => 'Just checking in. Whatever you do today is enough.';

  @override
  String get notifMsg4 => 'One small habit. That\'s all.';

  @override
  String get notifMsg5 => 'You showed up yesterday. That already matters.';

  @override
  String get notifMsg6 => 'Today doesn\'t have to be perfect to be good.';

  @override
  String get notifMsg7 =>
      'Be as gentle with yourself as you\'d be with a friend.';

  @override
  String get notifMsg8 => 'Small steps still move you forward.';

  @override
  String get notifMsg9 => 'It\'s okay to start slow.';

  @override
  String get notifMsg10 => 'You\'re doing better than you think.';

  @override
  String get notifMsg11 => 'Progress doesn\'t always look like progress.';

  @override
  String get notifMsg12 => 'One thing at a time. No pressure.';

  @override
  String get notifMsg13 => 'You don\'t have to earn rest.';

  @override
  String get notifMsg14 => 'Kindness to yourself counts as a habit too.';

  @override
  String get notifMsg15 => 'Today is a new chance, not a test.';

  @override
  String get notifMsg16 => 'Even a little is more than nothing.';

  @override
  String get notifMsg17 => 'You\'re still here. That\'s something.';

  @override
  String get notifMsg18 => 'There\'s no wrong way to have a gentle day.';

  @override
  String get notifMsg19 => 'Whatever today holds, you can handle it softly.';

  @override
  String get notifMsg20 => 'Rest is part of the work too.';

  @override
  String get notifMsg21 => 'You don\'t have to do everything. Just one thing.';

  @override
  String get notifMsg22 => 'Today\'s habits are tomorrow\'s foundation.';

  @override
  String get notifMsg23 => 'Be patient with yourself today.';

  @override
  String get notifMsg24 => 'Growth is quiet. Trust it.';

  @override
  String get notifMsg25 => 'You\'re building something real, slowly.';

  @override
  String get notifMsg26 => 'One habit. One moment. That\'s enough.';

  @override
  String get notifMsg27 => 'Check in with yourself today — how are you really?';

  @override
  String get notifMsg28 =>
      'You\'ve done hard things before. Today can be gentle.';

  @override
  String get notifMsg29 => 'Nothing has to be perfect to be worth doing.';

  @override
  String get notifMsg30 => 'You\'re allowed to take this one step at a time.';

  @override
  String get notifMsg31 =>
      'The version of you who started this would be proud.';

  @override
  String get notifMsg32 =>
      'Growth is quietest when it\'s most real. Trust the process.';

  @override
  String get notifMsg33 => 'You\'ve been showing up. That consistency is rare.';

  @override
  String get notifMsg34 => 'Small rituals become the shape of a life.';

  @override
  String get notifMsg35 => 'You\'re not behind. You\'re exactly where you are.';

  @override
  String get notifMsg36 => 'The gentlest habits are often the most lasting.';

  @override
  String get notifMsg37 =>
      'You\'re building a relationship with yourself. Take it slow.';

  @override
  String get notifMsg38 => 'Today\'s small act is next month\'s normal.';

  @override
  String get notifMsg39 =>
      'Habits aren\'t about willpower. They\'re about care.';

  @override
  String get notifMsg40 =>
      'You know yourself better than any app does. Trust that.';

  @override
  String get notifMsg41 => 'The goal was never perfection. It was showing up.';

  @override
  String get notifMsg42 =>
      'Some days the habit is just being kind to yourself.';

  @override
  String get notifMsg43 => 'You\'ve made it through harder days than this.';

  @override
  String get notifMsg44 => 'Every gentle choice adds up.';

  @override
  String get notifMsg45 =>
      'You don\'t need motivation. You just need one moment.';

  @override
  String get notifMsg46 => 'Your pace is your own. No comparisons needed.';

  @override
  String get notifMsg47 => 'The quiet days count just as much.';

  @override
  String get notifMsg48 => 'You\'re not starting over — you\'re continuing.';

  @override
  String get notifMsg49 => 'Consistency is kindness applied repeatedly.';

  @override
  String get notifMsg50 => 'One habit at a time is how lives actually change.';

  @override
  String get notifMsg51 => 'Today is a good day to be gentle with yourself.';

  @override
  String get notifMsg52 => 'You showed up. That\'s the whole thing.';

  @override
  String get notifMsg53 => 'Small doesn\'t mean insignificant.';

  @override
  String get notifMsg54 => 'Whatever you do today, do it with care.';

  @override
  String get notifMsg55 => 'Your habits are an act of self-respect.';

  @override
  String get notifMsg56 => 'Nothing is lost. You can always begin again.';

  @override
  String get notifMsg57 => 'You\'re in this for the long run. Slow is fine.';

  @override
  String get notifMsg58 =>
      'Today\'s effort is invisible now and undeniable later.';

  @override
  String get notifMsg59 => 'You are allowed to be a work in progress.';

  @override
  String get notifMsg60 => 'This is what taking care of yourself looks like.';

  @override
  String get notifWeeklyBody =>
      'Check in with how your week felt. Your habits were there for you.';

  @override
  String get notifDailyChannelName => 'Daily Reminders';

  @override
  String get notifDailyChannelDesc => 'Gentle daily habit reminders';

  @override
  String get notifWeeklyChannelName => 'Weekly Reminders';

  @override
  String get notifWeeklyChannelDesc => 'Weekly reflection reminders';

  @override
  String get affirmation1 =>
      'Missing days doesn\'t erase what you\'ve already done.';

  @override
  String get affirmation2 => 'You don\'t need to earn rest.';

  @override
  String get affirmation3 => 'Three habits or one — both are enough.';

  @override
  String get affirmation4 =>
      'The fact that you\'re here says something good about you.';

  @override
  String get affirmation5 =>
      'Progress isn\'t about perfection, it\'s about showing up.';

  @override
  String get affirmation6 => 'You\'re allowed to have off days.';

  @override
  String get affirmation7 => 'Small actions count, even when they feel small.';

  @override
  String get affirmation8 =>
      'You\'re not behind. You\'re exactly where you need to be.';

  @override
  String get affirmation9 =>
      'Consistency is important, but so is self-compassion.';

  @override
  String get affirmation10 =>
      'Your worth isn\'t measured by what you check off.';

  @override
  String get affirmation11 =>
      'Some weeks are harder than others. That\'s just being human.';

  @override
  String get affirmation12 =>
      'You don\'t need to do everything to be doing enough.';

  @override
  String get affirmation13 =>
      'Rest is part of progress, not the opposite of it.';

  @override
  String get affirmation14 => 'Showing up imperfectly is still showing up.';

  @override
  String get affirmation15 => 'You\'re doing better than you think you are.';

  @override
  String get affirmation16 =>
      'It\'s okay to start over as many times as you need.';

  @override
  String get affirmation17 => 'Your pace is your own. Comparison won\'t help.';

  @override
  String get affirmation18 =>
      'Every attempt matters, even the ones that feel small.';

  @override
  String get affirmation19 =>
      'You don\'t have to feel motivated to deserve kindness.';

  @override
  String get affirmation20 =>
      'Progress can look like simply trying again tomorrow.';

  @override
  String get affirmation21 => 'You\'re allowed to adjust your expectations.';

  @override
  String get affirmation22 => 'Taking breaks doesn\'t mean you\'ve failed.';

  @override
  String get affirmation23 =>
      'The hardest part is often just beginning. You did that.';

  @override
  String get affirmation24 =>
      'You don\'t need permission to take care of yourself.';

  @override
  String get affirmation25 =>
      'Your best today might look different than yesterday. That\'s okay.';

  @override
  String get affirmation26 =>
      'Struggling doesn\'t mean you\'re doing it wrong.';

  @override
  String get affirmation27 =>
      'You\'ve already done hard things. You can do this too.';

  @override
  String get affirmation28 =>
      'It\'s okay if your progress doesn\'t look like anyone else\'s.';

  @override
  String get affirmation29 => 'You don\'t have to prove anything to anyone.';

  @override
  String get affirmation30 =>
      'Sometimes just surviving the day is progress enough.';

  @override
  String get affirmation31 =>
      'You\'re learning, even when it doesn\'t feel like it.';

  @override
  String get affirmation32 => 'Being gentle with yourself is not giving up.';

  @override
  String get affirmation33 =>
      'You don\'t need a reason to be kind to yourself.';

  @override
  String get affirmation34 => 'What you\'re doing right now is enough.';

  @override
  String get affirmation35 => 'Tomorrow is always a chance to try again.';

  @override
  String get progressOnboardingPrompt => 'Complete onboarding to see your week';

  @override
  String get progressTitle => 'Your week';

  @override
  String get progressWeeklySummary => 'WEEKLY SUMMARY';

  @override
  String get progressWeekBeginning => 'Your week is just beginning.';

  @override
  String get progressShowedUpOnce => 'You showed up once this week.';

  @override
  String progressShowedUpCount(int count) {
    return 'You showed up $count times this week.';
  }

  @override
  String progressMore(int count) {
    return '+$count more';
  }

  @override
  String get progressSeeAll => 'See all';

  @override
  String get progressShowLess => 'Show less';

  @override
  String get progressYourMoments => 'YOUR MOMENTS';

  @override
  String get progressEarlierToday => 'Earlier today';

  @override
  String get progressYesterday => 'Yesterday';

  @override
  String progressDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String progressMomentsCollected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moments collected',
      one: '1 moment collected',
    );
    return '$_temp0';
  }

  @override
  String get momentsTitle => 'Your moments';

  @override
  String get momentsSubtitle => 'Every habit you completed, kept forever.';

  @override
  String get momentsEmptyTitle => 'Your moments will appear here.';

  @override
  String get momentsEmptyMessage =>
      'Every habit you complete becomes part of your collection — permanently.';

  @override
  String get momentsToday => 'Today';

  @override
  String get momentsYesterday => 'Yesterday';

  @override
  String monthSummaryMoments(int count, String month) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moments in $month',
      one: '1 moment in $month',
    );
    return '$_temp0';
  }

  @override
  String monthSummaryIntentions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentions this month',
      one: '1 intention this month',
    );
    return '$_temp0';
  }

  @override
  String monthSummaryTopIntention(String intention) {
    return 'Your most frequent intention: $intention';
  }

  @override
  String get paywallTitle => 'Intended+';

  @override
  String get paywallDescription =>
      'Intended is free forever. Intended+ gives you more freedom to make it yours.';

  @override
  String get paywallFeature1 => 'Create habits that truly fit your life';

  @override
  String get paywallFeature2 => 'Change your habits whenever life changes';

  @override
  String get paywallFeature3 => 'Shareable milestone achievement cards';

  @override
  String get paywallFeature4 => 'Adjust your focus areas as often as you need';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallMonthlyPrice => '€6.99';

  @override
  String get paywallMonthlyPeriod => 'per month';

  @override
  String get paywallYearly => 'Yearly';

  @override
  String get paywallYearlyPrice => '€49.99';

  @override
  String get paywallYearlyPeriod => 'per year';

  @override
  String get paywallYearlySave => 'Save 40%';

  @override
  String get paywallLifetime => 'Lifetime';

  @override
  String get paywallLifetimePrice => '€89.99';

  @override
  String get paywallLifetimePeriod => 'one-time';

  @override
  String get paywallLifetimeBadge => 'Launch price';

  @override
  String get paywallCtaTrial => 'Start 7-day free trial';

  @override
  String get paywallCtaLifetime => 'Get lifetime access';

  @override
  String paywallTrialHint(String price) {
    return '7 days free, then $price. Cancel anytime.';
  }

  @override
  String get paywallLifetimeHint => 'One-time purchase. No subscription.';

  @override
  String get paywallContinueFree => 'Continue with Core';

  @override
  String get paywallRestorePurchases => 'Restore Purchases';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String get subscriptionTitle => 'Intended+';

  @override
  String get subscriptionSupporter => 'You\'re a supporter ♥';

  @override
  String get subscriptionPlan => 'Plan';

  @override
  String get subscriptionPrice => 'Price';

  @override
  String get subscriptionRenews => 'Renews';

  @override
  String get subscriptionThankYou =>
      'Thank you for supporting Intended.\nYour subscription helps us keep\nbuilding a kinder way to grow.';

  @override
  String get subscriptionManage => 'Manage in App Store';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNameError => 'Hmm';

  @override
  String get profileNameErrorMessage => 'Please choose a different name';

  @override
  String get profileYourName => 'Your name';

  @override
  String get profileAddName => 'Add your name';

  @override
  String get profileEnterName => 'Enter your name';

  @override
  String get profilePlan => 'Plan';

  @override
  String get profileManage => 'Manage';

  @override
  String get profileUnlockPlus => 'UNLOCK INTENDED+';

  @override
  String get profileFocusAreas => 'Focus areas';

  @override
  String get profileYourMoments => 'Your moments';

  @override
  String get profileMomentsNone => 'None yet';

  @override
  String profileMomentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moments',
      one: '1 moment',
    );
    return '$_temp0';
  }

  @override
  String get profileSettings => 'SETTINGS';

  @override
  String get profileDailyReminders => 'Daily reminders';

  @override
  String get profileRemindAt => 'Remind me at';

  @override
  String get profileWeeklySummary => 'Weekly summary';

  @override
  String get profileWeeklySubtitle => 'Every Sunday evening';

  @override
  String get profileNotifDenied =>
      'No worries — you can enable notifications in your device Settings.';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileSupport => 'SUPPORT';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profilePrivacy => 'Privacy Policy';

  @override
  String get profileTerms => 'Terms of Use';

  @override
  String get profileConnectAccount => 'CONNECT ACCOUNT';

  @override
  String get profileSignInGoogle => 'Sign in with Google';

  @override
  String get profileSignInApple => 'Sign in with Apple';

  @override
  String get profileSignedInGoogle => 'Signed in with Google';

  @override
  String get profileSignedInApple => 'Signed in with Apple';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteData => 'Delete profile data';

  @override
  String get profileVersion => 'Intended v1.0.0';

  @override
  String get profileCannotOpenEmail => 'Cannot open email';

  @override
  String get profileEmailFallback =>
      'Please email us at\nsupport@intendedapp.com';

  @override
  String get profileChangeFocusTitle => 'Change focus areas?';

  @override
  String get profileChangeFocusMessage =>
      'Your habits will refresh based on new areas.';

  @override
  String get profileChangeAreas => 'Change areas';

  @override
  String get profileFocusLimitMessage =>
      'You\'ve used your free change this month.';

  @override
  String get profileFocusLimitOptions =>
      '• Boost: Extra changes\n• Intended+: Unlimited';

  @override
  String get profilePayAmount => 'Pay €0.99';

  @override
  String get profilePaymentTitle => 'Payment';

  @override
  String get profilePaymentMessage => 'In-app purchase coming soon!';

  @override
  String get profileChangeSpace => 'Change your space';

  @override
  String get profileRefreshTitle => 'Refresh habits?';

  @override
  String get profileRefreshMessage =>
      'You\'ll get a new set of habits based on your focus areas.';

  @override
  String get profileRefreshSuccessTitle => 'Habits refreshed';

  @override
  String get profileRefreshSuccessMessage =>
      'You have a new set of habits waiting for you.';

  @override
  String get profileDailyLimitTitle => 'Daily limit reached';

  @override
  String get profileDailyLimitMessage =>
      'You\'ve refreshed your habits 3 times today. Try again tomorrow, or upgrade to Intended+ for unlimited refreshes.';

  @override
  String get profileCannotOpenLink => 'Cannot open link';

  @override
  String get profilePrivacyFallback =>
      'Please visit intendedapp.com/privacy in your browser';

  @override
  String get profileTermsFallback =>
      'Please visit intendedapp.com/terms in your browser';

  @override
  String get profileDeleteAllTitle => 'Delete all data?';

  @override
  String get profileDeleteAllMessage =>
      'This will permanently delete all your habits, progress, and settings. This action cannot be undone.';

  @override
  String get profileChangeFocusAreasScreenTitle => 'Change Focus Areas';

  @override
  String get profileChooseUpTo2 => 'Choose up to 2 areas';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get themeWarmClay => 'Warm Clay';

  @override
  String get themeIris => 'Iris';

  @override
  String get themeClearSky => 'Clear Sky';

  @override
  String get themeMorningSlate => 'Morning Slate';

  @override
  String get browseHabitsTitle => 'Browse Habits';

  @override
  String browseHabitsAvailable(int count) {
    return '$count habits available';
  }

  @override
  String get browseHabitsSearch => 'Search habits...';

  @override
  String get browseAlreadyAddedTitle => 'Already added';

  @override
  String browseAlreadyAddedMessage(String habit) {
    return '\"$habit\" is already in your habits.';
  }

  @override
  String get browseSwapLimitTitle => 'Swap limit reached';

  @override
  String get browseSwapConfirmTitle => 'Swap an existing habit?';

  @override
  String browseSwapConfirmMessage(String habit) {
    return 'Replace one of your current habits with \"$habit\".';
  }

  @override
  String browseSwapRemainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'swaps',
      one: 'swap',
    );
    return 'You have $count $_temp0 remaining this month.';
  }

  @override
  String get browseChooseHabitToSwap => 'Choose habit to swap';

  @override
  String get browseWhichToReplace => 'Which habit to replace?';

  @override
  String browseChooseToReplaceMessage(String habit) {
    return 'Choose one of your current habits to replace with \"$habit\"';
  }

  @override
  String get browseHabitAddedTitle => 'Habit added';

  @override
  String browseHabitAddedMessage(String habit) {
    return '\"$habit\" has been added to your habits.';
  }

  @override
  String get browseHabitAddedConfirm => 'Great!';

  @override
  String get habitDrinkWater => 'Drink a glass of water';

  @override
  String get habitThreeSlowBreaths => 'Take 3 slow breaths';

  @override
  String get habitStretchTenSeconds => 'Stretch for 10 seconds';

  @override
  String get habitRollShoulders => 'Stand up and roll your shoulders';

  @override
  String get habitStepOutside => 'Step outside for 30 seconds';

  @override
  String get habitCloseEyes => 'Close your eyes for 20 seconds';

  @override
  String get habitNeckRolls => 'Do 5 gentle neck rolls';

  @override
  String get habitWalkToWindow => 'Walk to the window and back';

  @override
  String get habitBellyBreaths => 'Take 5 deep belly breaths';

  @override
  String get habitBodyScan => '2-minute body scan';

  @override
  String get habitGentleMovement => '10 minutes of gentle movement';

  @override
  String get habitMindfulMeal => 'Eat one meal mindfully';

  @override
  String get habitTenSecondPause => 'Ten-second pause';

  @override
  String get habitNoticeFeeling => 'Notice one thing you feel';

  @override
  String get habitGroundingBreath => 'One grounding breath';

  @override
  String get habitLookAway => 'Look away from your screen for 10 seconds';

  @override
  String get habitNameThreeThings => 'Name three things you can see';

  @override
  String get habitNoticeSound => 'Notice one sound around you';

  @override
  String get habitFeelFeet => 'Feel your feet on the ground';

  @override
  String get habitHandOnHeart => 'Place hand on heart for a moment';

  @override
  String get habitGratefulThing => 'Notice one thing you\'re grateful for';

  @override
  String get habitSmileGently => 'Smile gently at yourself';

  @override
  String get habitAskNeed => 'Ask yourself \"what do I need right now?\"';

  @override
  String get habitPermissionToRest => 'Give yourself permission to rest';

  @override
  String get habitSetPriority => 'Set one priority';

  @override
  String get habitClearSmallThing => 'Clear one small thing';

  @override
  String get habitPlanTomorrow => 'Plan tomorrow in one sentence';

  @override
  String get habitThirtySecondReset => 'Do a 30-second reset';

  @override
  String get habitWriteIdea => 'Write down one idea';

  @override
  String get habitFinishTinyTask => 'Finish one tiny task';

  @override
  String get habitDeclutterDesk => 'Declutter your desk for 2 minutes';

  @override
  String get habitReviewCalendar => 'Review your calendar';

  @override
  String get habitTurnOffNotification => 'Turn off one notification';

  @override
  String get habitCloseTab => 'Close one browser tab';

  @override
  String get habitArchiveEmails => 'Archive 5 old emails';

  @override
  String get habitUpdateTodo => 'Update one to-do item';

  @override
  String get habitTidyOneThing => 'Tidy one small thing';

  @override
  String get habitPutBack => 'Put one thing back where it belongs';

  @override
  String get habitWipeSurface => 'Wipe one surface';

  @override
  String get habitFreshAir => 'Open a window for fresh air';

  @override
  String get habitMakeBed => 'Make your bed';

  @override
  String get habitClearShelf => 'Clear one shelf';

  @override
  String get habitWashDishes => 'Wash 3 dishes';

  @override
  String get habitTakeOutTrash => 'Take out one small bag of trash';

  @override
  String get habitFoldClothing => 'Fold 3 items of clothing';

  @override
  String get habitOrganizeDrawer => 'Organize one drawer';

  @override
  String get habitWaterPlant => 'Water one plant';

  @override
  String get habitLightCandle => 'Light a candle';

  @override
  String get habitSendMessage => 'Send one message to someone';

  @override
  String get habitAppreciatePerson => 'Think of one person you appreciate';

  @override
  String get habitAskHowAreYou => 'Ask someone how they are';

  @override
  String get habitGiveCompliment => 'Give one genuine compliment';

  @override
  String get habitCallSomeone => 'Call someone you care about';

  @override
  String get habitShareSmile => 'Share something that made you smile';

  @override
  String get habitThankSomeone => 'Thank someone today';

  @override
  String get habitListenFully => 'Listen without planning your response';

  @override
  String get habitReachOut => 'Reach out to someone you miss';

  @override
  String get habitTellMeaning => 'Tell someone what they mean to you';

  @override
  String get habitOfferHelp => 'Offer help to someone';

  @override
  String get habitCelebrateOthers => 'Celebrate someone else\'s win';

  @override
  String get habitWriteSentence => 'Write one sentence';

  @override
  String get habitDoodle => 'Doodle for 10 seconds';

  @override
  String get habitCaptureIdea => 'Capture one idea';

  @override
  String get habitNoticeBeauty => 'Notice one beautiful thing';

  @override
  String get habitTakePhoto => 'Take one photo of something you like';

  @override
  String get habitDrawShape => 'Draw one simple shape';

  @override
  String get habitHumTune => 'Hum a tune you enjoy';

  @override
  String get habitRearrange => 'Rearrange something small';

  @override
  String get habitTryNewWord => 'Try one new word';

  @override
  String get habitCreateTinyThing => 'Create one tiny thing';

  @override
  String get habitPlayCreative => 'Play with one creative medium';

  @override
  String get habitImagine => 'Imagine one possibility';

  @override
  String get habitCheckBalance => 'Check your balance';

  @override
  String get habitMoveToSavings => 'Move €1 to savings';

  @override
  String get habitReviewSubscription => 'Review one subscription';

  @override
  String get habitNoteExpense => 'Note one expense';

  @override
  String get habitFinancialTip => 'Read one financial tip';

  @override
  String get habitDeleteReceipt => 'Delete one old receipt';

  @override
  String get habitUpdateBudget => 'Update one budget category';

  @override
  String get habitReviewBill => 'Review one bill';

  @override
  String get habitPriceCheck => 'Price-check one item before buying';

  @override
  String get habitWait24Hours => 'Wait 24 hours before one purchase';

  @override
  String get habitCelebrateMoneyWin => 'Celebrate one money win';

  @override
  String get habitSavingsGoal => 'Set one small savings goal';

  @override
  String get habitSitStill => 'Sit still for 10 seconds';

  @override
  String get habitKindThing => 'Do one kind thing for yourself';

  @override
  String get habitDrinkSlowly => 'Drink water slowly';

  @override
  String get habitStretchNeck => 'Stretch your neck';

  @override
  String get habitOneSlowBreath => 'Take one slow breath';

  @override
  String get habitNoticeLikeAboutSelf =>
      'Notice something you like about yourself';

  @override
  String get habitPermissionSayNo => 'Give yourself permission to say no';

  @override
  String get habitFeelGood => 'Do something that feels good';

  @override
  String get habitRestTwoMinutes => 'Rest for 2 minutes';

  @override
  String get habitPutOnComfortable => 'Put on something comfortable';

  @override
  String get habitListenToSong => 'Listen to one song you love';

  @override
  String get habitDoNothing => 'Do absolutely nothing for 30 seconds';

  @override
  String get shareCardWeeklyCheckin => 'Weekly check-in';

  @override
  String get shareCardMilestone => 'Milestone';

  @override
  String get shareCardShowedUpPhrase => 'I showed up for myself this week';

  @override
  String get shareCardTimes => 'times';

  @override
  String get shareCardTagline => 'intention, not perfection';

  @override
  String get shareCardWeeks => 'weeks';

  @override
  String get shareCardMilestoneSubtext => 'of being gentle with myself';

  @override
  String get shareCardDescriptor => 'intention, not perfection';

  @override
  String get sharePickerTitle => 'What would you like to share?';

  @override
  String get shareWeeklySubtitle => 'how many times you showed up this week';

  @override
  String get shareShowingUpSubtitle => 'your own way, your own pace';

  @override
  String get shareFocusAreaSubtitle => 'the area you keep returning to';

  @override
  String get shareYourThingSubtitle => 'the habit that\'s sticking';

  @override
  String get milestoneShowingUpLabel => 'Showing up';

  @override
  String get milestoneAreaLabel => 'Focus area';

  @override
  String get milestoneIdentityLabel => 'Your thing';

  @override
  String milestoneShowingUpHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$count $_temp0';
  }

  @override
  String get milestoneShowingUpSubtitle => 'of showing up — in your own way';

  @override
  String milestoneAreaHero(String area) {
    return '$area';
  }

  @override
  String get milestoneAreaSubtitle => 'you keep coming back to what matters';

  @override
  String milestoneIdentityHero(String habit) {
    return '$habit';
  }

  @override
  String get milestoneIdentitySubtitle => 'is becoming your thing';

  @override
  String get boostCardTitle => 'Intended Boost — €1.99 one-time';

  @override
  String get boostCardSubtitle => 'A little extra room to grow.';

  @override
  String get boostOrDivider => 'or';

  @override
  String get boostGoUnlimited => 'Go unlimited with Intended+';

  @override
  String get boostPurchaseError =>
      'Something went wrong with the purchase. Please try again.';

  @override
  String get boostBenefit1 => '3 custom habits';

  @override
  String get boostBenefit1Detail => 'up from 2';

  @override
  String get boostBenefit2 => '3 focus areas';

  @override
  String get boostBenefit2Detail => 'up from 2';

  @override
  String get boostBenefit3 => '3 habit swaps/month';

  @override
  String get boostBenefit3Detail => 'up from 2';

  @override
  String get boostBenefit4 => 'Shareable progress cards';

  @override
  String get boostOfferHabitTitle => 'Want one more habit?';

  @override
  String get boostOfferHabitDesc =>
      'You\'re building something meaningful — give yourself room for one more.';

  @override
  String get boostOfferFocusTitle => 'Need another focus area?';

  @override
  String get boostOfferFocusDesc =>
      'Your growth doesn\'t fit in a box — expand what you focus on.';

  @override
  String get boostOfferSwapTitle => 'Out of swaps this month?';

  @override
  String get boostOfferSwapDesc =>
      'Finding the right habits takes exploring — get a few more tries.';

  @override
  String get boostOfferShareTitle => 'Share your progress?';

  @override
  String get boostOfferShareDesc =>
      'Your journey is worth celebrating — share it with people who care.';
}
