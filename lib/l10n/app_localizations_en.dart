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
  String get welcomeSubtitle => 'Build small daily habits\nwithout the guilt.';

  @override
  String get onboardingTagline => 'Intention, not perfection.';

  @override
  String get onboardingDescriptor =>
      'No streaks. No scores. Just small steps that bring you closer to yourself.';

  @override
  String get onboardingNamePrompt => 'What should we call you?';

  @override
  String get onboardingLetsGetStarted => 'Let\'s get started';

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
  String get focusAreaHealthSub => 'Your body will thank you.';

  @override
  String get focusAreaMood => 'Mood';

  @override
  String get focusAreaMoodSub => 'Notice how you feel. That\'s the first step.';

  @override
  String get focusAreaProductivity => 'Productivity';

  @override
  String get focusAreaProductivitySub => 'One thing at a time. That\'s plenty.';

  @override
  String get focusAreaHome => 'Home & organization';

  @override
  String get focusAreaHomeSub => 'Small tidying, big calm.';

  @override
  String get focusAreaRelationships => 'Relationships';

  @override
  String get focusAreaRelationshipsSub => 'The people who matter.';

  @override
  String get focusAreaCreativity => 'Creativity';

  @override
  String get focusAreaCreativitySub => 'Make something. Anything.';

  @override
  String get focusAreaFinances => 'Finances';

  @override
  String get focusAreaFinancesSub => 'Tiny money moves, real peace of mind.';

  @override
  String get focusAreaSelfCare => 'Self-care';

  @override
  String get focusAreaSelfCareSub => 'The small luxuries you keep skipping.';

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
      'Deep Focus and more themes are available with Intended+. Try it free for 7 days after setup.';

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
  String habitRevealSubtitlePath(String pathTitle) {
    return 'Here\'s what your $pathTitle practice looks like.';
  }

  @override
  String get habitRevealSubtitleOwnWay =>
      'Here\'s what your practice looks like.';

  @override
  String get habitRevealDescription =>
      'Pick what feels right. Skip what doesn\'t. There\'s no pressure to do them all — one is enough.';

  @override
  String get habitRevealBegin => 'Let\'s begin';

  @override
  String get focusAreasStartingPointsTitle =>
      'We\'ve picked some starting points for you';

  @override
  String focusAreasStartingPointsSubtext(String pathTitle) {
    return 'Based on the intention path $pathTitle. Add or remove areas anytime.';
  }

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
  String get dailyMessage18 => 'Start wherever you are';

  @override
  String get dailyMessage19 => 'You don\'t need to be ready';

  @override
  String get dailyMessage20 => 'Trust your own rhythm';

  @override
  String get dailyMessage21 => 'It\'s okay to adjust as you go';

  @override
  String get dailyMessage22 => 'Small acts of care matter';

  @override
  String get dailyMessage23 => 'You\'re doing more than you think';

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
  String get customHabitFocusAreaLabel => 'Which area is this for?';

  @override
  String get customHabitSubmit => 'Add to my habits';

  @override
  String get editHabitTitle => 'Edit habit';

  @override
  String get editHabitSave => 'Save';

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
      'Core: 2 custom habits\nIntended+: Unlimited custom habits';

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
      'You\'ve used all your free swaps this month.\n\nIntended+: Unlimited swaps';

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
  String get completionDecline => 'No, not today';

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
  String get completionMsg1 => 'Small steps like this matter.';

  @override
  String get completionMsg3 => 'This is how change happens.';

  @override
  String get completionMsg4 => 'One step closer.';

  @override
  String get completionMsg7 => 'Another small victory.';

  @override
  String get completionMsg8 => 'You made it happen.';

  @override
  String get completionMsg11 => 'This counts.';

  @override
  String get completionMsg12 => 'You kept your word to yourself.';

  @override
  String get completionMsg13 => 'Well done.';

  @override
  String get completionMsg14 => 'You made time for this.';

  @override
  String get completionMsg16 => 'You pushed through.';

  @override
  String get completionMsg17 => 'Another habit built.';

  @override
  String get completionMsg18 => 'You committed and you did it.';

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
  String get warmthMsg4 => 'Not today — and that\'s allowed.';

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
  String get warmthMsg13 => 'You showed up enough today just by being here.';

  @override
  String get warmthMsg15 =>
      'Progress isn\'t only visible. Sometimes it\'s just surviving.';

  @override
  String get notifMsg1 => 'No rush today. Even one small thing counts.';

  @override
  String get notifMsg2 => 'You don\'t have to be productive to deserve rest.';

  @override
  String get notifMsg3 => 'Whatever you do today is enough.';

  @override
  String get notifMsg4 => 'One small action. That\'s all.';

  @override
  String get notifMsg6 => 'Today doesn\'t have to be perfect to be good.';

  @override
  String get notifMsg8 => 'Small steps still move you forward.';

  @override
  String get notifMsg9 => 'It\'s okay to start slow.';

  @override
  String get notifMsg10 => 'You\'re doing better than you think.';

  @override
  String get notifMsg11 => 'Progress doesn\'t always look like progress.';

  @override
  String get notifMsg13 => 'You don\'t have to earn rest.';

  @override
  String get notifMsg14 => 'Kindness to yourself counts as a habit too.';

  @override
  String get notifMsg15 => 'Today is a new chance, not a test.';

  @override
  String get notifMsg16 => 'Even a little is better than nothing.';

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
  String get notifMsg34 => 'Small rituals become the shape of a big life.';

  @override
  String get notifMsg35 => 'You\'re not behind. You\'re exactly where you are.';

  @override
  String get notifMsg37 =>
      'You\'re building a relationship with yourself. Take it slow.';

  @override
  String get notifMsg38 => 'Today\'s small act is next month\'s normal.';

  @override
  String get notifMsg39 =>
      'Habits aren\'t about willpower. They\'re about care.';

  @override
  String get notifMsg41 => 'The goal was never perfection. It was showing up.';

  @override
  String get notifMsg42 =>
      'Some days the habit is just being kind to yourself.';

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
  String get notifMsg53 => 'Small doesn\'t mean insignificant.';

  @override
  String get notifMsg54 => 'Whatever you do today, do it with care.';

  @override
  String get notifMsg55 => 'Your habits are an act of self-respect.';

  @override
  String get notifMsg56 => 'Nothing is lost. You can always begin again.';

  @override
  String get notifMsg58 =>
      'Today\'s effort is invisible now and undeniable later.';

  @override
  String get notifMsg60 => 'This is what taking care of yourself looks like.';

  @override
  String get notifWeeklyBody =>
      'Check in with how your week felt. Your habits were there for you.';

  @override
  String get notifWeeklyPathGentleMornings =>
      'Your week of gentle mornings is ready to look back on.';

  @override
  String get notifWeeklyPathFindingCalm =>
      'A week of finding calm. See how it unfolded.';

  @override
  String get notifWeeklyPathGratitudeSelfLove =>
      'Your week of gratitude is waiting for you to reflect on.';

  @override
  String get notifWeeklyPathWindingDown =>
      'A week of winding down. Take a moment to look back.';

  @override
  String get notifWeeklyPathYourOwnWay =>
      'Your week is ready to reflect on. See what showed up.';

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
  String get momentsSubtitle =>
      'Every habit you complete is saved to your collection.';

  @override
  String get momentsEmptyTitle => 'Your moments will appear here.';

  @override
  String get momentsEmptyMessage =>
      'Every habit you complete becomes part of your collection.';

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
  String momentsShowAll(int count) {
    return 'Show all $count moments';
  }

  @override
  String get paywallTitle => 'See yourself more clearly';

  @override
  String get paywallDescription =>
      'Intended+ turns your daily practice into lasting self-knowledge.';

  @override
  String get paywallCeilingTitle => 'You\'re building something good';

  @override
  String get paywallCeilingDescription =>
      'Intended+ gives you room to grow. But the free version always has what you need.';

  @override
  String get paywallFeature1 =>
      'Monthly & weekly reflections — see how far you\'ve come';

  @override
  String get paywallFeature2 =>
      'A home screen widget that keeps your intentions close';

  @override
  String get paywallFeature3 =>
      '10 beautiful themes & premium app icons — make it yours';

  @override
  String get paywallFeature4 =>
      'Shareable moment cards & curated routines designed for real life';

  @override
  String get paywallFeature5 =>
      'Unlimited habits, swaps, and focus areas — no ceiling on growth';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallMonthlyPrice => '€5.99';

  @override
  String get paywallMonthlyPeriod => 'per month';

  @override
  String get paywallYearly => 'Yearly';

  @override
  String get paywallYearlyPrice => '€44.99';

  @override
  String get paywallYearlyPeriod => 'per year';

  @override
  String get paywallYearlySave => 'Save 37%';

  @override
  String paywallSavePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get paywallLifetime => 'Lifetime';

  @override
  String get paywallLifetimePrice => '€69.99';

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
  String get restoreError => 'Could not restore purchases. Please try again.';

  @override
  String get ok => 'OK';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String get paywallFooter =>
      'New features added regularly. Your subscription supports independent development.\nBuilt by one person who cares about this as much as you do.';

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
      'Thank you for supporting Intended.\nYou\'re helping us build a kinder\nalternative to hustle culture.';

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
  String get profileYourPath => 'Your path';

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
  String get profileNotifDeniedTitle => 'Notifications Disabled';

  @override
  String get profileNotifDeniedMessage =>
      'To enable reminders, please turn on notifications for Intended in your device Settings.';

  @override
  String get profileNotifOpenSettings => 'Open Settings';

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
  String get signOutWarningTitle => 'Sign out?';

  @override
  String get signOutWarningMessage =>
      'Your data stays on this device only. You won\'t be able to access it on other devices or after reinstalling.';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteData => 'Delete profile data';

  @override
  String get profileVersion => 'Intended v1.0.1';

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
  String get profileFocusLimitOptions => '• Intended+: Unlimited';

  @override
  String get profilePayAmount => 'Pay €0.99';

  @override
  String get profilePaymentTitle => 'Payment';

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
  String get profileDeleteErrorMessage =>
      'Could not delete your account. Please try again.';

  @override
  String get profileReauthTitle => 'Sign in again';

  @override
  String get profileReauthMessage =>
      'For security, please sign in again to confirm account deletion.';

  @override
  String get profileReauthButton => 'Sign in';

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
  String get themeSoftDusk => 'Soft Dusk';

  @override
  String get themeDeepFocus => 'Deep Focus';

  @override
  String get themeForestFloor => 'Forest Floor';

  @override
  String get themeGoldenHour => 'Golden Hour';

  @override
  String get themeNightBloom => 'Night Bloom';

  @override
  String get themeSandDune => 'Sand Dune';

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
  String get habitDrinkWater => 'Drink 3 glasses of water';

  @override
  String get habitThreeSlowBreaths => 'Take 3 slow breaths';

  @override
  String get habitStretchTenSeconds => 'Stretch for 30 seconds';

  @override
  String get habitRollShoulders => 'Stand up and roll your shoulders';

  @override
  String get habitStepOutside => 'Step outside for 5 minutes';

  @override
  String get habitCloseEyes => 'Close your eyes for 30 seconds';

  @override
  String get habitNeckRolls => 'Do 5 gentle neck rolls';

  @override
  String get habitWalkToWindow => 'Walk to the window and back';

  @override
  String get habitBellyBreaths => 'Take 5 deep belly breaths';

  @override
  String get habitBodyScan => '2-minute body scan';

  @override
  String get habitGentleMovement => '5 minutes of gentle stretching';

  @override
  String get habitMindfulMeal => 'Eat one meal mindfully';

  @override
  String get habitTenSecondPause => 'One-minute pause';

  @override
  String get habitNoticeFeeling => 'Notice one thing you feel';

  @override
  String get habitGroundingBreath => 'Three grounding breaths';

  @override
  String get habitLookAway => 'Look away from your screen for 30 seconds';

  @override
  String get habitNameThreeThings => 'Name three things you can see';

  @override
  String get habitNoticeSound => 'Notice one sound around you';

  @override
  String get habitFeelFeet => 'Feel your feet on the ground';

  @override
  String get habitHandOnHeart => 'Place hand on heart for 30 seconds';

  @override
  String get habitGratefulThing => 'Name 3 things you\'re grateful for';

  @override
  String get habitSmileGently => 'Smile kindly at yourself';

  @override
  String get habitAskNeed => 'Ask yourself \"what do I need right now?\"';

  @override
  String get habitPermissionToRest => 'Give yourself permission to rest';

  @override
  String get habitSetPriority => 'Set one priority today';

  @override
  String get habitPlanTomorrow => 'Plan tomorrow in one sentence';

  @override
  String get habitThirtySecondReset => 'Do a 1-minute reset';

  @override
  String get habitWriteIdea => 'Unsubscribe from an unnecessary email list';

  @override
  String get habitFinishTinyTask => 'Finish one tiny task';

  @override
  String get habitDeclutterDesk => 'Declutter your desk';

  @override
  String get habitReviewCalendar => 'Review your calendar';

  @override
  String get habitTurnOffNotification => 'Turn off one notification';

  @override
  String get habitCloseTab => 'Close unnecessary browser tabs';

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
  String get habitTakeOutTrash => 'Take out one bag of trash';

  @override
  String get habitFoldClothing => 'Fold 3 items of clothing';

  @override
  String get habitOrganizeDrawer => 'Organize one drawer';

  @override
  String get habitWaterPlant => 'Water your plants';

  @override
  String get habitLightCandle => 'Light a scented candle';

  @override
  String get habitSendMessage => 'Send one message to someone you care about';

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
  String get habitWriteSentence => 'Write a short story';

  @override
  String get habitDoodle => 'Doodle for 5 minutes';

  @override
  String get habitCaptureIdea => 'Capture one idea';

  @override
  String get habitNoticeBeauty => 'Notice one beautiful thing';

  @override
  String get habitTakePhoto => 'Take one photo of something you like';

  @override
  String get habitDrawShape => 'Draw something simple';

  @override
  String get habitHumTune => 'Hum a tune you enjoy';

  @override
  String get habitRearrange => 'Rearrange something small';

  @override
  String get habitTryNewWord => 'Learn one new word';

  @override
  String get habitCreateTinyThing => 'Play a short melody';

  @override
  String get habitPlayCreative => 'Play with one creative medium';

  @override
  String get habitImagine => 'Do a vocal warm-up';

  @override
  String get habitCheckBalance => 'Try one financial tip';

  @override
  String get habitMoveToSavings => 'Move €3/\$3 to savings';

  @override
  String get habitReviewSubscription => 'Review one subscription';

  @override
  String get habitNoteExpense => 'Note 3 expenses';

  @override
  String get habitFinancialTip => 'Read one financial tip';

  @override
  String get habitDeleteReceipt => 'Delete one old receipt';

  @override
  String get habitUpdateBudget => 'Treat yourself';

  @override
  String get habitReviewBill => 'Review necessity of one subscription';

  @override
  String get habitPriceCheck => 'Price-check one item before buying';

  @override
  String get habitWait24Hours => 'Wait 24 hours before a big purchase';

  @override
  String get habitCelebrateMoneyWin => 'Celebrate one money win';

  @override
  String get habitSavingsGoal => 'Set one savings goal';

  @override
  String get habitSitStill => 'Sit still for 1 minute';

  @override
  String get habitKindThing => 'Do one kind thing for yourself';

  @override
  String get habitDrinkSlowly => 'Drink a cup of tasty coffee';

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
  String get habitRestTwoMinutes => 'Rest for 5 minutes';

  @override
  String get habitPutOnComfortable => 'Put on something comfortable';

  @override
  String get habitListenToSong => 'Listen to one song you love';

  @override
  String get habitDoNothing => 'Do absolutely nothing for 5 minutes';

  @override
  String get shareCardWeeklyCheckin => 'Weekly check-in';

  @override
  String get shareCardMilestone => 'Milestone';

  @override
  String get shareCardShowedUpPhrase => 'I showed up for myself this week';

  @override
  String shareCardTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'times',
      one: 'time',
    );
    return '$_temp0';
  }

  @override
  String shareCardFocusedOn(String area) {
    return 'Focused on: $area';
  }

  @override
  String get shareCardTagline => 'intention, not perfection';

  @override
  String get shareCardWeeks => 'weeks';

  @override
  String get shareCardMilestoneSubtext => 'of being gentle with myself';

  @override
  String get shareCardDescriptor => 'intention, not perfection';

  @override
  String get shareCardSubtitleSingular => 'time I showed up this week';

  @override
  String get shareCardSubtitlePlural => 'times I showed up this week';

  @override
  String get shareCardSubtitleDays => 'days I showed up this week';

  @override
  String shareCardInsightTwoDays(String day1, String day2) {
    return '$day1 and $day2 are my days';
  }

  @override
  String shareCardInsightOneDay(String day) {
    return '$day is my day';
  }

  @override
  String shareCardInsightFocus(String area) {
    return 'Drawn to $area this week';
  }

  @override
  String get shareButton => 'Share';

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
  String get boostCardTitle => 'Intended Boost — €1.99';

  @override
  String boostCardTitleDynamic(String price) {
    return 'Intended Boost — $price';
  }

  @override
  String get boostCardSubtitle => 'Unlock both dark themes.';

  @override
  String get boostOrDivider => 'or';

  @override
  String get boostGoUnlimited => 'Want more? Go unlimited with Intended+';

  @override
  String get boostPurchaseError =>
      'Something went wrong with the purchase. Please try again.';

  @override
  String get boostBenefit1 =>
      'Deep Focus and Night Bloom — a calmer look for evening check-ins.';

  @override
  String get boostOfferHabitTitle => 'Want one more habit?';

  @override
  String get boostOfferHabitDesc =>
      'You\'re building something meaningful — give yourself room for one more.';

  @override
  String get boostOfferFocusTitle => 'Need another focus area?';

  @override
  String get boostOfferFocusDesc =>
      'Your growth doesn\'t fit in a box? Expand what you focus on.';

  @override
  String get boostOfferSwapTitle => 'Out of swaps this month?';

  @override
  String get boostOfferSwapDesc =>
      'Finding the right habits takes exploring — get a few more tries.';

  @override
  String get boostOfferShareTitle => 'Share your progress?';

  @override
  String get boostOfferShareDesc =>
      'Your journey is worth celebrating — share it with people you care about.';

  @override
  String get boostOfferThemeTitle => 'Unlock both dark themes';

  @override
  String get boostOfferThemeDesc =>
      'Deep Focus and Night Bloom — a calmer look for evening check-ins.';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get focusLimitFreeTitle => 'Focus area limit reached';

  @override
  String get focusLimitFreeMessage =>
      'Free plan includes 1 focus area. Upgrade to unlock more.';

  @override
  String get focusLimitFreeUpgrade => 'Upgrade';

  @override
  String get focusNudgeTitle => 'Less is more';

  @override
  String get focusNudgeMessage =>
      'Focus on one area at a time for the best results.';

  @override
  String get focusNudgeGotIt => 'Got it';

  @override
  String get shareError => 'Could not share. Please try again.';

  @override
  String get restoreSuccess => 'Purchases restored!';

  @override
  String get restoreNotFound => 'No purchases found.';

  @override
  String get restoreBackupTitle => 'Welcome back!';

  @override
  String get restoreBackupMessage =>
      'We found your data from a previous session. Would you like to restore it?';

  @override
  String get restoreBackupConfirm => 'Restore my data';

  @override
  String get restoreBackupSkip => 'Start fresh';

  @override
  String profileBackedUp(Object time) {
    return 'Backed up $time';
  }

  @override
  String get profileNotBackedUp => 'Not backed up';

  @override
  String get profileBackupNow => 'Back up now';

  @override
  String get profileBackingUp => 'Backing up…';

  @override
  String get profileBackedUpNote => 'Your data is backed up to your account.';

  @override
  String get profileLocalDataNote =>
      'Your data is stored on this device only. Sign in to back it up.';

  @override
  String get onboardingAlreadyHaveAccount => 'Sign in';

  @override
  String get onboardingSignInWithApple => 'Sign in with Apple';

  @override
  String get onboardingSignInWithGoogle => 'Sign in with Google';

  @override
  String get onboardingPhilosophyLabel => 'Before we begin';

  @override
  String get onboardingPhilosophyHeading =>
      'This isn\'t a tracker.\nIt\'s a return to yourself.';

  @override
  String get onboardingPhilosophyBody =>
      'No streaks to maintain. No guilt for skipping.\nYour progress never resets. One small intention is enough.';

  @override
  String get onboardingPhilosophyCta => 'Got it';

  @override
  String get reflectionTitle => 'Your week';

  @override
  String get reflectionAnchor7 =>
      'You showed up every single day this week. Not perfect — present.';

  @override
  String reflectionAnchor56(int days) {
    return 'You showed up $days out of 7 days this week. That\'s $days days you chose to try.';
  }

  @override
  String reflectionAnchor34(int days) {
    return 'You showed up $days days this week. That\'s $days days you chose to try.';
  }

  @override
  String reflectionAnchor12(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days times',
      one: '1 time',
    );
    return 'You checked in $_temp0 this week. Even one day counts — you didn\'t disappear.';
  }

  @override
  String get reflectionAnchor0 =>
      'Quiet week. That\'s okay. You\'re here now, and that\'s what matters.';

  @override
  String reflectionPatternOneDay(String dayName) {
    return 'Looks like $dayName is when you really show up. Three weeks in a row now.';
  }

  @override
  String reflectionPatternTwoDays(String dayName1, String dayName2) {
    return '$dayName1 and $dayName2 seem to be your days.';
  }

  @override
  String get reflectionPatternNone =>
      'Your rhythm is still finding its shape. That\'s normal — keep going.';

  @override
  String reflectionFocusDominant(String area) {
    return 'You\'ve been drawn to $area habits lately. That seems important to you right now.';
  }

  @override
  String reflectionFocusBalanced(String area1, String area2) {
    return 'You spread your energy across $area1 and $area2 this week. A balanced week.';
  }

  @override
  String get reflectionReframeComeback =>
      'Last week was quieter. This week you came back. That\'s the whole point.';

  @override
  String reflectionReframeRefresh(int count) {
    return 'You refreshed your habits $count time(s) this week — that\'s not quitting, that\'s adapting.';
  }

  @override
  String get reflectionReframeSwap =>
      'You swapped out a habit this week. Knowing what doesn\'t work is progress too.';

  @override
  String get reflectionShare => 'Share';

  @override
  String get insightsGrowthHint => 'Insights get sharper every week';

  @override
  String get reflectionTeaser => 'There\'s more to your week';

  @override
  String get reflectionSectionThisWeek => 'THIS WEEK';

  @override
  String get reflectionSectionYourRhythm => 'YOUR RHYTHM';

  @override
  String get reflectionSectionYourFocus => 'YOUR FOCUS';

  @override
  String get reflectionSectionNotice => 'SOMETHING TO NOTICE';

  @override
  String get reflectionPreviewRhythm =>
      'After a few weeks, we\'ll show you which days you\'re most consistent';

  @override
  String get reflectionPreviewFocus =>
      'Complete more habits to see what you\'re drawn to';

  @override
  String get reflectionBlurRhythm =>
      'See which days and patterns work best for you';

  @override
  String get reflectionBlurFocus => 'Discover where your energy goes each week';

  @override
  String get reflectionUnlockPlus => 'See my weekly insights';

  @override
  String get tipPinHabit => 'Long press on a habit to pin it to the top';

  @override
  String get tipCuratedPack =>
      'Try a curated pack — find them in Browse all habits';

  @override
  String get tipWidget =>
      'Add Intended to your home screen — long press your wallpaper and add a widget';

  @override
  String get tipGotIt => 'Got it';

  @override
  String get tipSkipAll => 'Skip tips';

  @override
  String get packSwapTitle => 'Make room for your new pack';

  @override
  String get packSwapSubtitle =>
      'To keep your space focused, pick which habits to set aside. Your custom habits will always stay.';

  @override
  String packSwapConfirm(int count, String packName) {
    return 'Set aside $count and add $packName';
  }

  @override
  String packSwapAdded(int count) {
    return 'added — $count new habits ready to go';
  }

  @override
  String get packSwapAllActive =>
      'All habits from this pack are already active';

  @override
  String get packSectionHeader => 'CURATED PACKS';

  @override
  String packHabitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits',
      one: '1 habit',
    );
    return '$_temp0';
  }

  @override
  String get packFreeBadge => 'Free';

  @override
  String packStartButton(String packName) {
    return 'Start $packName';
  }

  @override
  String get packHabitsInPack => 'HABITS IN THIS PACK';

  @override
  String get packAllActive => 'All habits already active';

  @override
  String get packHabitActive => 'Active';

  @override
  String get packActiveBadge => 'Active';

  @override
  String get packGentleMorningsName => 'Gentle Mornings';

  @override
  String get packGentleMorningsSubtitle =>
      'A small morning ritual that doesn\'t feel like a 5am hustle routine';

  @override
  String get packGentleMorningsDescription =>
      'Four tiny habits that work as a gentle sequence — hydrate, breathe fresh air, center yourself, then orient your day. No alarms at dawn required.';

  @override
  String get packWindingDownName => 'Winding Down';

  @override
  String get packWindingDownSubtitle =>
      'An evening decompression set. Intentionally short.';

  @override
  String get packWindingDownDescription =>
      'A small ritual for letting the day go. Stop, reflect, get comfortable, enjoy one thing. That\'s the whole evening plan.';

  @override
  String get packTinyResetsName => 'Tiny Resets';

  @override
  String get packTinyResetsSubtitle =>
      'For mid-week moments when everything feels chaotic';

  @override
  String get packTinyResetsDescription =>
      'When overwhelm hits, these four micro-actions create a small pocket of control. Not a productivity system — a rescue kit.';

  @override
  String get packCreativeSparkName => 'Creative Spark';

  @override
  String get packCreativeSparkSubtitle =>
      'Small acts of making. No talent required.';

  @override
  String get packCreativeSparkDescription =>
      'Three tiny creative habits that get you out of your head and into your hands. Not about being good — about being playful.';

  @override
  String get packStayConnectedName => 'Stay Connected';

  @override
  String get packStayConnectedSubtitle =>
      'The people who matter, one small gesture at a time.';

  @override
  String get packStayConnectedDescription =>
      'Four micro-habits for staying close to the people in your life. Not grand gestures — just showing up.';

  @override
  String get widgetToday => 'today';

  @override
  String widgetMore(int n) {
    return '+$n more';
  }

  @override
  String get widgetUpgrade => 'Upgrade to see more';

  @override
  String get widgetNoHabits => 'No habits yet';

  @override
  String get widgetAllDone => 'All done for today!';

  @override
  String get appIconSectionTitle => 'APP ICON';

  @override
  String get appIconDefault => 'Default';

  @override
  String get appIconMidnight => 'Midnight';

  @override
  String get appIconRose => 'Rose';

  @override
  String get appIconForest => 'Forest';

  @override
  String get appIconSky => 'Sky';

  @override
  String get legalDisclaimerPrefix => 'By continuing, you agree to our ';

  @override
  String get legalDisclaimerTerms => 'Terms';

  @override
  String get legalDisclaimerAnd => ' and ';

  @override
  String get legalDisclaimerPrivacy => 'Privacy Policy';

  @override
  String get legalDisclaimerSuffix => '.';

  @override
  String get pathGentleMorningsTitle => 'Gentle Mornings';

  @override
  String get pathGentleMorningsSubtitle =>
      'Start your day with calm, not chaos';

  @override
  String get pathFindingCalmTitle => 'Finding Calm';

  @override
  String get pathFindingCalmSubtitle =>
      'Small daily anchors for stress and anxiety';

  @override
  String get pathGratitudeSelfLoveTitle => 'Gratitude & Self-Love';

  @override
  String get pathGratitudeSelfLoveSubtitle =>
      'Build a kinder relationship with yourself';

  @override
  String get pathWindingDownTitle => 'Winding Down';

  @override
  String get pathWindingDownSubtitle => 'End your day peacefully';

  @override
  String get pathYourOwnWayTitle => 'Your Own Way';

  @override
  String get pathYourOwnWaySubtitle =>
      'I know what I need — just give me the tools';

  @override
  String get intentionPathHeadline => 'What brings you here?';

  @override
  String get intentionPathSubtext =>
      'This helps us set up your experience. You can always change it later.';

  @override
  String intentionPathUpdateFocusAreas(String pathName) {
    return 'Update your focus areas to match \"$pathName\"?';
  }

  @override
  String get intentionPathUpdateYes => 'Yes, update focus areas';

  @override
  String get intentionPathUpdateNo => 'No, keep my current areas';

  @override
  String get coachMarkFirstCompletionTitle => 'Your first check-in';

  @override
  String get coachMarkFirstCompletionBody =>
      'That\'s it. That\'s the whole practice. Show up when you can, skip when you can\'t.';

  @override
  String get coachMarkPinningTitle => 'This one\'s sticking';

  @override
  String get coachMarkPinningBody =>
      'Long-press any habit to pin it to the top. Your anchors deserve the spotlight.';

  @override
  String get coachMarkWidgetTitle =>
      'See your intentions without opening the app';

  @override
  String get coachMarkWidgetBody =>
      'Add an Intended widget to your home or lock screen. A quiet reminder of what matters today.';

  @override
  String get coachMarkWeeklyReflectionTitle => 'Your first reflection is here';

  @override
  String get coachMarkWeeklyReflectionBody =>
      'Every week, Intended looks back at your patterns — gently, never critically. Tap to see your week.';

  @override
  String get coachMarkSmartNotificationsTitle =>
      'Your reminders learn from you';

  @override
  String get coachMarkSmartNotificationsBody =>
      'Intended adjusts when and how often it nudges you based on your rhythm. Check in a lot? We step back. Been away? Just one gentle note.';

  @override
  String get coachMarkMonthlyReflectionTitle => 'A month of showing up';

  @override
  String get coachMarkMonthlyReflectionBody =>
      'Your monthly reflection finds patterns across weeks that you might not notice day-to-day. It\'s here whenever you want it.';

  @override
  String get coachMarkReflectionShareTitle => 'Worth sharing?';

  @override
  String get coachMarkReflectionShareBody =>
      'Tap the share button to turn this into a card you can send to someone or post. Your data stays private — only the summary is shared.';

  @override
  String get reviewPromptMessage =>
      'Enjoying Intended? A quick rating helps others find a gentler way to build habits.';

  @override
  String get reviewPromptRate => 'Rate now';

  @override
  String get reviewPromptNotYet => 'Not yet';

  @override
  String get upgradeNudgeBody =>
      'Your practice is growing. Intended+ gives you room to grow with it.';

  @override
  String get upgradeNudgeLearnMore => 'Learn more';

  @override
  String get notifWeeklyDynamic0 =>
      'Your weekly reflection is here. Every week is a fresh start.';

  @override
  String get notifWeeklyDynamic1 =>
      'Your weekly reflection is here — you showed up for yourself this week.';

  @override
  String notifWeeklyDynamicN(int count) {
    return 'Your weekly reflection is here — you showed up $count times for yourself this week.';
  }

  @override
  String get faqSectionGettingStarted => 'Getting Started';

  @override
  String get faqWhatIsIntended => 'What is Intended?';

  @override
  String get faqWhatIsIntendedAnswer =>
      'Intended is a gentle habit app for iOS. It helps you build daily habits without streaks, guilt, or pressure. There\'s no counter that resets when you miss a day — just a calm space to check in with your intentions whenever you\'re ready.';

  @override
  String get faqWhatIsIntentionPath => 'What\'s an Intention Path?';

  @override
  String get faqWhatIsIntentionPathAnswer =>
      'When you first open Intended, you choose a path based on what brings you here — like Finding Calm or Gentle Mornings. Your path shapes your default habits, the tone of your reminders, and your reflection questions. You can change it anytime in your profile.';

  @override
  String get faqChangeIntentionPath => 'Can I change my Intention Path?';

  @override
  String get faqChangeIntentionPathAnswer =>
      'Yes, anytime. Go to your Profile, tap your Intention Path card, and pick a new one. Your history and check-ins stay exactly as they are.';

  @override
  String get faqWhatAreFocusAreas => 'What are Focus Areas?';

  @override
  String get faqWhatAreFocusAreasAnswer =>
      'Focus areas are categories of habits — like Health, Mood, or Self-care. Each area comes with curated habits. Your path pre-selects a couple, but you can add or remove them anytime.';

  @override
  String get faqHowIsDifferent => 'How is Intended different?';

  @override
  String get faqHowIsDifferentAnswer =>
      'Most habit apps use streaks and gamification. Intended takes the opposite approach. No streaks to break, no leaderboards, no guilt. Your progress never resets.';

  @override
  String get faqSectionDailyHabits => 'Daily Habits';

  @override
  String get faqHowToCheckIn => 'How do I check in?';

  @override
  String get faqHowToCheckInAnswer =>
      'Tap any habit card on your home screen. A single tap is all it takes.';

  @override
  String get faqMissedDay => 'What if I miss a day?';

  @override
  String get faqMissedDayAnswer =>
      'Nothing happens. No streaks break, no counters reset. Tomorrow is a new day.';

  @override
  String get faqHowToPin => 'How do I pin a habit?';

  @override
  String get faqHowToPinAnswer =>
      'Long-press any habit card to pin it to the top. You can have one pinned habit at a time.';

  @override
  String get faqCustomHabits => 'Can I add custom habits?';

  @override
  String get faqCustomHabitsAnswer =>
      'Yes! Tap the + button. Free users can have up to 2 custom habits. Intended+ gives you unlimited.';

  @override
  String get faqSwapHabit => 'How do I swap a habit?';

  @override
  String get faqSwapHabitAnswer =>
      'Tap the swap icon on any habit card. Free users get 2 swaps per month.';

  @override
  String get faqRefreshes => 'What are refreshes?';

  @override
  String get faqRefreshesAnswer =>
      'Refreshing gives you new random habits from your focus areas. 3 per day on the free plan.';

  @override
  String get faqSectionReflections => 'Reflections';

  @override
  String get faqWeeklyReflection => 'What is a Weekly Reflection?';

  @override
  String get faqWeeklyReflectionAnswer =>
      'Every week, Intended generates a reflection card based on your check-in patterns — which habits stuck, your most active days, and gentle observations. Never judgments.';

  @override
  String get faqMonthlyReflection => 'What\'s the Monthly Reflection?';

  @override
  String get faqMonthlyReflectionAnswer =>
      'After 30 days, a monthly reflection looks across weeks for patterns you might not notice day-to-day. Available with Intended+.';

  @override
  String get faqShareReflection => 'Can I share my reflection?';

  @override
  String get faqShareReflectionAnswer =>
      'Yes! Tap the share button to turn it into a beautiful card for social media.';

  @override
  String get faqNoReflection => 'Why don\'t I see a reflection?';

  @override
  String get faqNoReflectionAnswer =>
      'Weekly reflections appear after 7 days. Monthly after 30. The more you check in, the richer they become.';

  @override
  String get faqSectionNotifications => 'Notifications';

  @override
  String get faqHowNotifications => 'How do notifications work?';

  @override
  String get faqHowNotificationsAnswer =>
      'Reminders adapt to your rhythm. Check in regularly and they step back. Been away? One gentle nudge — never seven.';

  @override
  String get faqChangeTime => 'Can I change the time?';

  @override
  String get faqChangeTimeAnswer => 'Yes. Profile → Notification Settings.';

  @override
  String get faqPathNotifications => 'Do notifications match my path?';

  @override
  String get faqPathNotificationsAnswer =>
      'Yes. Someone on Finding Calm sees different wording than someone on Gentle Mornings.';

  @override
  String get faqSectionWidgets => 'Widgets';

  @override
  String get faqAddWidget => 'How do I add a widget?';

  @override
  String get faqAddWidgetAnswer =>
      'Long-press your home screen, tap +, search for Intended. You can also add lock screen widgets through iOS Settings.';

  @override
  String get faqWidgetNotUpdating => 'Why isn\'t my widget updating?';

  @override
  String get faqWidgetNotUpdatingAnswer =>
      'iOS controls refresh timing. Open the app briefly to trigger it. Check that Background App Refresh is enabled for Intended.';

  @override
  String get faqSectionPricing => 'Intended+ & Pricing';

  @override
  String get faqWhatIsPlus => 'What is Intended+?';

  @override
  String get faqWhatIsPlusAnswer =>
      'Unlimited custom habits, swaps, refreshes, library access, focus area changes, all themes, monthly reflections, and deeper insights.';

  @override
  String get faqPricing => 'How much does it cost?';

  @override
  String get faqPricingAnswer =>
      'Monthly: €6.99. Yearly: €49.99 (5 months free). Lifetime: €89.99. All include a 7-day free trial.';

  @override
  String get faqBoost => 'What is Intended Boost?';

  @override
  String get faqBoostAnswer =>
      'A one-time €0.99 purchase. Extra themes, +1 custom habit, milestone cards, +1 focus area, 5 swaps per month.';

  @override
  String get faqFreeVersion => 'Can I use it for free?';

  @override
  String get faqFreeVersionAnswer =>
      'Yes. Free includes intention paths, 2 custom habits, 2 focus areas, weekly reflections, smart notifications, and widgets.';

  @override
  String get faqRestore => 'How do I restore my purchase?';

  @override
  String get faqRestoreAnswer => 'Profile → Restore Purchases.';

  @override
  String get faqCancel => 'How do I cancel?';

  @override
  String get faqCancelAnswer =>
      'iPhone Settings → your name → Subscriptions → Intended → Cancel.';

  @override
  String get faqSectionPrivacy => 'Privacy';

  @override
  String get faqDataStorage => 'Where is my data stored?';

  @override
  String get faqDataStorageAnswer =>
      'All data is stored locally on your device. Nothing is uploaded to any server.';

  @override
  String get faqDataSelling => 'Does Intended sell my data?';

  @override
  String get faqDataSellingAnswer =>
      'No. We use anonymous crash reports to fix bugs. Never your habit data.';

  @override
  String get faqDeleteApp => 'What if I delete the app?';

  @override
  String get faqDeleteAppAnswer =>
      'Data is local, so deleting removes everything. Subscriptions can be restored through the App Store.';

  @override
  String get faqSectionTroubleshooting => 'Troubleshooting';

  @override
  String get faqCrash => 'The app crashed.';

  @override
  String get faqCrashAnswer =>
      'Try closing and reopening. Make sure you have the latest version.';

  @override
  String get faqHabitsGone => 'My habits disappeared.';

  @override
  String get faqHabitsGoneAnswer =>
      'Try restarting. If they don\'t return, contact support@intendedapp.com.';

  @override
  String get faqAppleName => 'Apple Sign-In isn\'t showing my name.';

  @override
  String get faqAppleNameAnswer =>
      'Apple only sends your name the first time. Go to iPhone Settings → Apple ID → Password & Security → Apps Using Apple ID → Intended → Stop Using, then sign in again.';

  @override
  String get faqStillHaveQuestion => 'Still have a question?';

  @override
  String get faqContactButton => 'Email us';

  @override
  String get faqWidgetCompletion => 'Can I complete habits from my widget?';

  @override
  String get faqWidgetCompletionAnswer =>
      'Yes! Tap any habit on your home screen widget to mark it done. It syncs when you next open Intended.';

  @override
  String get bloomGentleMornings1 => 'A full morning. That\'s something.';

  @override
  String get bloomGentleMornings2 => 'Every one, gently done.';

  @override
  String get bloomGentleMornings3 => 'Morning complete. You showed up softly.';

  @override
  String get bloomGentleMornings4 => 'All here. The morning was yours.';

  @override
  String get bloomGentleMornings5 => 'Gentle and done. That\'s enough.';

  @override
  String get bloomFindingCalm1 => 'All here. All done. Breathe.';

  @override
  String get bloomFindingCalm2 => 'Calm, found — one habit at a time.';

  @override
  String get bloomFindingCalm3 => 'Everything tended to. Be still now.';

  @override
  String get bloomFindingCalm4 => 'Done with care. The rest is yours.';

  @override
  String get bloomFindingCalm5 => 'You found your anchors today.';

  @override
  String get bloomGratitudeSelfLove1 => 'Every one — a small act of love.';

  @override
  String get bloomGratitudeSelfLove2 => 'All done. You showed up for yourself.';

  @override
  String get bloomGratitudeSelfLove3 => 'That was you, taking care of you.';

  @override
  String get bloomGratitudeSelfLove4 => 'Finished with kindness. Well done.';

  @override
  String get bloomGratitudeSelfLove5 => 'All of it, for you. That matters.';

  @override
  String get bloomWindingDown1 => 'The evening is yours now. Rest.';

  @override
  String get bloomWindingDown2 => 'All wound down. Let the night come.';

  @override
  String get bloomWindingDown3 => 'Done softly. Tomorrow can wait.';

  @override
  String get bloomWindingDown4 => 'Everything settled. You did enough.';

  @override
  String get bloomWindingDown5 => 'Gently closed. Sleep well.';

  @override
  String get bloomYourOwnWay1 => 'You showed up for all of it today.';

  @override
  String get bloomYourOwnWay2 => 'All done, your way. That\'s what counts.';

  @override
  String get bloomYourOwnWay3 => 'Every one, on your terms.';

  @override
  String get bloomYourOwnWay4 => 'Finished. No one else needed to see this.';

  @override
  String get bloomYourOwnWay5 => 'Quietly complete. That\'s yours to keep.';

  @override
  String get notifPathGentleMornings1 =>
      'Good morning. No rush — what feels right today?';

  @override
  String get notifPathGentleMornings2 =>
      'A new morning, a gentle start. You\'ve got this.';

  @override
  String get notifPathGentleMornings3 =>
      'The morning is yours. Begin however feels right.';

  @override
  String get notifPathGentleMornings4 =>
      'Mornings don\'t need to be perfect. Just present.';

  @override
  String get notifPathGentleMornings5 =>
      'Rise gently. One small thing is enough today.';

  @override
  String get notifPathGentleMornings6 =>
      'Your morning ritual is waiting. No pressure, just possibility.';

  @override
  String get notifPathFindingCalm1 =>
      'How are you, really? Take a moment to check in.';

  @override
  String get notifPathFindingCalm2 =>
      'One calm breath can shift the whole day. You know this.';

  @override
  String get notifPathFindingCalm3 =>
      'Your anchors are here when the noise gets loud.';

  @override
  String get notifPathFindingCalm4 =>
      'Stillness doesn\'t need to be earned. It\'s already yours.';

  @override
  String get notifPathFindingCalm5 =>
      'A gentle pause. That\'s all today needs from you.';

  @override
  String get notifPathFindingCalm6 =>
      'You don\'t have to fix anything right now. Just be here.';

  @override
  String get notifPathGratitudeSelfLove1 =>
      'You deserve kindness today — especially from yourself.';

  @override
  String get notifPathGratitudeSelfLove2 =>
      'What\'s one thing you\'re grateful for right now?';

  @override
  String get notifPathGratitudeSelfLove3 =>
      'You\'ve already done enough to deserve gentleness today.';

  @override
  String get notifPathGratitudeSelfLove4 =>
      'A kind thought for yourself is a habit worth keeping.';

  @override
  String get notifPathGratitudeSelfLove5 =>
      'Notice something good about today. It\'s there, even if small.';

  @override
  String get notifPathGratitudeSelfLove6 =>
      'You\'re worthy of the care you give others.';

  @override
  String get notifPathWindingDown1 =>
      'The day is almost done. Let it go gently.';

  @override
  String get notifPathWindingDown2 =>
      'Time to unwind. You carried enough today.';

  @override
  String get notifPathWindingDown3 =>
      'Evening is for letting go, not catching up.';

  @override
  String get notifPathWindingDown4 =>
      'You showed up today. That\'s worth settling into.';

  @override
  String get notifPathWindingDown5 => 'The night is yours. Rest without guilt.';

  @override
  String get notifPathWindingDown6 => 'Slow down. Tomorrow will wait for you.';

  @override
  String get notifPathYourOwnWay1 =>
      'Your practice, your pace. What feels right today?';

  @override
  String get notifPathYourOwnWay2 =>
      'You know what you need. We\'re just here to remind you.';

  @override
  String get notifPathYourOwnWay3 =>
      'Check in when you\'re ready. No schedule, no pressure.';

  @override
  String get notifPathYourOwnWay4 =>
      'Your path is your own. Show up however you want.';

  @override
  String get notifPathYourOwnWay5 =>
      'One intention. That\'s all. The rest is up to you.';

  @override
  String get notifPathYourOwnWay6 =>
      'You built this practice. Trust where it takes you.';

  @override
  String get warmthPathGentleMornings1 =>
      'Not every morning needs to be a fresh start. Some just need quiet.';

  @override
  String get warmthPathGentleMornings2 =>
      'Even mornings have slow days. That\'s allowed.';

  @override
  String get warmthPathGentleMornings3 =>
      'Your morning is still yours, even when you skip this.';

  @override
  String get warmthPathGentleMornings4 =>
      'Tomorrow morning will come gently. It always does.';

  @override
  String get warmthPathGentleMornings5 =>
      'Rest now. The sunrise doesn\'t keep score.';

  @override
  String get warmthPathGentleMornings6 =>
      'A quiet morning is still a morning well spent.';

  @override
  String get warmthPathFindingCalm1 =>
      'Skipping can be its own kind of calm. Let it be.';

  @override
  String get warmthPathFindingCalm2 =>
      'You don\'t need to find calm today. It will find you.';

  @override
  String get warmthPathFindingCalm3 =>
      'Sometimes the most calming thing is letting yourself off the hook.';

  @override
  String get warmthPathFindingCalm4 =>
      'Stillness counts, even when nothing gets checked off.';

  @override
  String get warmthPathFindingCalm5 =>
      'Peace isn\'t earned. It\'s always available to you.';

  @override
  String get warmthPathFindingCalm6 =>
      'Not doing is also a form of being present.';

  @override
  String get warmthPathGratitudeSelfLove1 =>
      'Being kind to yourself includes saying \'not today.\'';

  @override
  String get warmthPathGratitudeSelfLove2 =>
      'Self-love looks like this too — no guilt, just grace.';

  @override
  String get warmthPathGratitudeSelfLove3 =>
      'You don\'t need to perform self-care to practice it.';

  @override
  String get warmthPathGratitudeSelfLove4 =>
      'Forgiving yourself for skipping is the habit that matters most.';

  @override
  String get warmthPathGratitudeSelfLove5 =>
      'Gentleness isn\'t just for good days. It\'s for these days too.';

  @override
  String get warmthPathGratitudeSelfLove6 =>
      'You\'re still worthy of warmth, even when you rest.';

  @override
  String get warmthPathWindingDown1 =>
      'Tonight, just rest. That\'s the whole plan.';

  @override
  String get warmthPathWindingDown2 =>
      'You don\'t need to wind down perfectly. Just stop.';

  @override
  String get warmthPathWindingDown3 => 'Let the day go. You held enough.';

  @override
  String get warmthPathWindingDown4 =>
      'Some evenings are just for existing. This is one of them.';

  @override
  String get warmthPathWindingDown5 =>
      'The night doesn\'t need a routine. It just needs you to let go.';

  @override
  String get warmthPathWindingDown6 =>
      'Sleep well. Tomorrow is already gentler than you think.';

  @override
  String get warmthPathYourOwnWay1 => 'Your own way includes rest. Always has.';

  @override
  String get warmthPathYourOwnWay2 =>
      'Skipping is part of the rhythm you\'re building.';

  @override
  String get warmthPathYourOwnWay3 =>
      'You chose this path. You also get to pause on it.';

  @override
  String get warmthPathYourOwnWay4 =>
      'No one\'s keeping score. Especially not us.';

  @override
  String get warmthPathYourOwnWay5 =>
      'Trust yourself. You\'ll come back when it\'s time.';

  @override
  String get warmthPathYourOwnWay6 => 'Your pace. Your rules. Always.';

  @override
  String get reflectionPathGentleMorningsIntro =>
      'Another week of gentle mornings — or at least trying for them.';

  @override
  String get reflectionPathFindingCalmIntro =>
      'Another week of finding your anchors.';

  @override
  String get reflectionPathGratitudeSelfLoveIntro =>
      'Another week of building warmth with yourself.';

  @override
  String get reflectionPathWindingDownIntro =>
      'Another week of winding down, your way.';

  @override
  String get reflectionPathYourOwnWayIntro => 'Another week on your own terms.';

  @override
  String get reflectionPathGentleMorningsQuiet =>
      'A quiet week for mornings. Some weeks are for sleeping in.';

  @override
  String get reflectionPathFindingCalmQuiet =>
      'A quiet week. Maybe the calm found you in other ways.';

  @override
  String get reflectionPathGratitudeSelfLoveQuiet =>
      'A quiet week. Resting is its own act of self-love.';

  @override
  String get reflectionPathWindingDownQuiet =>
      'A quiet week. Sometimes the best evening ritual is doing nothing at all.';

  @override
  String get reflectionPathYourOwnWayQuiet =>
      'Quiet week. Your path includes pauses too.';

  @override
  String get monthlyReflectionTitle => 'Your month';

  @override
  String get monthlyReflectionSectionOverview => 'THIS MONTH';

  @override
  String get monthlyReflectionSectionTrends => 'TRENDS';

  @override
  String get monthlyReflectionSectionGrowth => 'GROWTH';

  @override
  String monthlyReflectionMonthRange(String month, int year) {
    return '$month $year';
  }

  @override
  String monthlyReflectionOverview(int days, int total) {
    return 'You showed up $days days out of $total this month.';
  }

  @override
  String monthlyReflectionBestWeek(String weekRange, int days) {
    return 'Your strongest week was $weekRange with $days active days.';
  }

  @override
  String monthlyReflectionConsistentHabit(String habit) {
    return '$habit was your most consistent habit this month.';
  }

  @override
  String get monthlyReflectionGrowthUp =>
      'This month was more active than last month. You\'re finding your rhythm.';

  @override
  String get monthlyReflectionGrowthSteady =>
      'Steady month. You\'re maintaining what matters.';

  @override
  String get monthlyReflectionGrowthDown =>
      'Quieter month than last. That\'s okay — some seasons are for resting.';

  @override
  String get monthlyReflectionFirstMonth =>
      'Your first full month. Everything here is a beginning.';

  @override
  String get monthlyReflectionNoData =>
      'Not enough data yet. Keep going — your monthly reflection will arrive soon.';

  @override
  String get monthlyReflectionUnlock => 'See my monthly insights';

  @override
  String get monthlyReflectionSectionNotice => 'SOMETHING TO NOTICE';

  @override
  String monthlyReflectionTopArea(String area) {
    return 'You gravitated toward $area this month. That seems to matter to you right now.';
  }

  @override
  String get adaptiveNotifReducedTitle => 'We\'re stepping back';

  @override
  String get adaptiveNotifReducedBody =>
      'You\'ve been checking in regularly — we\'ll remind you less often.';

  @override
  String get adaptiveNotifReengageBody =>
      'It\'s been a little while. Just a gentle hello.';

  @override
  String get adaptiveNotifSilentBody =>
      'We noticed you\'ve been away. No pressure — we\'ll be here when you\'re ready.';

  @override
  String get a11yTabHabits => 'Habits';

  @override
  String get a11yTabProgress => 'Progress';

  @override
  String get a11yTabProfile => 'Profile';

  @override
  String a11yHabitCardDone(String habit) {
    return '$habit, completed';
  }

  @override
  String a11yHabitCardTodo(String habit) {
    return '$habit, tap to complete';
  }

  @override
  String a11yHabitCardPinned(String habit) {
    return '$habit, pinned, tap to complete';
  }

  @override
  String get a11yEditHabit => 'Edit habit';

  @override
  String get a11yDeleteHabit => 'Delete habit';
}
