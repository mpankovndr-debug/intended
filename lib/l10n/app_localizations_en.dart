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
  String themeSelectionPremiumHint(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Deep Focus and more themes are available with Intended+. Try it free for $_temp0 after setup.';
  }

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
  String focusAreasStartingPointsTitle(String pathTitle) {
    return 'Your $pathTitle practice starts here';
  }

  @override
  String get focusAreasStartingPointsSubtext =>
      'We\'ve picked some starting points. Add or remove areas anytime.';

  @override
  String get habitsHoldForOptions => 'Long press a habit for options';

  @override
  String get habitsCompleteOnboarding => 'Complete onboarding to get started';

  @override
  String get habitsPinned => 'PINNED';

  @override
  String get habitsSuggestions => 'SUGGESTIONS';

  @override
  String get intentionGentleMornings => 'Starting the day gently';

  @override
  String get intentionAnchorsForHardDays => 'Steadier on hard days';

  @override
  String get intentionQuietFocus => 'Focused, without the burnout';

  @override
  String get intentionWindingDown => 'Letting the day go';

  @override
  String get intentionYourOwnWay => 'Your own way';

  @override
  String get habitsAddYourOwn => 'Add something of your own';

  @override
  String get insightsTitle => 'Your month';

  @override
  String get insightsEmptyTitle =>
      'Nothing here yet — and that\'s exactly right.';

  @override
  String get insightsEmptyBody => 'Every small thing you do gets saved here.';

  @override
  String get insightsGridCaption => 'one square = one thing you did';

  @override
  String get insightsTeaserNoGap =>
      'There\'s a why underneath these squares. Intended+ finds it — and turns it into next month\'s plan.';

  @override
  String get driftLabel => 'RIGHT NOW';

  @override
  String driftBody(int thisWeek, int usual) {
    return 'You\'ve collected $thisWeek moments this week. You usually collect $usual.';
  }

  @override
  String get driftFollowed =>
      'The last two times this happened, a quiet stretch followed.';

  @override
  String get driftActionEase => 'Just one action for a few days';

  @override
  String get driftActionFine => 'I\'m fine';

  @override
  String get seasonLabel => 'YOUR SEASON';

  @override
  String get seasonPatternThisMonth => 'Your pattern this month';

  @override
  String get seasonBeginning => 'Beginning';

  @override
  String seasonBeginningLine(int count) {
    return '$count of 10 moments. Your season appears once there\'s enough to read.';
  }

  @override
  String get seasonMorning => 'Early';

  @override
  String get seasonMorningLine =>
      'You come to this early. The day starts with you.';

  @override
  String get seasonEvening => 'Evening';

  @override
  String get seasonEveningLine => 'You come to this once the day has quieted.';

  @override
  String get seasonSteady => 'Steady';

  @override
  String get seasonSteadyLine => 'A little, most days. That\'s the pattern.';

  @override
  String get seasonBursts => 'Bursts';

  @override
  String get seasonBurstsLine =>
      'You arrive in waves, and the waves come back.';

  @override
  String get seasonReturning => 'Returning';

  @override
  String get seasonReturningLine => 'You go quiet, and you find your way back.';

  @override
  String get seasonContinuous => 'Continuous';

  @override
  String get seasonContinuousLine => 'You\'ve kept a thread running all month.';

  @override
  String get seasonFocused => 'Focused';

  @override
  String get seasonFocusedLine => 'One thing had most of your attention.';

  @override
  String get seasonWandering => 'Wandering';

  @override
  String get seasonWanderingLine =>
      'You moved between things, following what you needed.';

  @override
  String get letterLabel => 'YOUR LETTER';

  @override
  String letterCameBack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days passed',
      one: 'A day passed',
    );
    return '$_temp0, and then you came back.';
  }

  @override
  String letterAnchor(String habit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return 'Most of it was $habit — $_temp0.';
  }

  @override
  String letterMood(int glad, int effort) {
    String _temp0 = intl.Intl.pluralLogic(
      effort,
      locale: localeName,
      other: '$effort took effort',
      one: 'One took effort',
    );
    return '$glad of them you were glad you did. $_temp0.';
  }

  @override
  String letterMoodGladOnly(int glad) {
    String _temp0 = intl.Intl.pluralLogic(
      glad,
      locale: localeName,
      other: '$glad of them you were glad you did',
      one: 'One of them you were glad you did',
    );
    return '$_temp0.';
  }

  @override
  String letterMoodEffortOnly(int effort) {
    String _temp0 = intl.Intl.pluralLogic(
      effort,
      locale: localeName,
      other: '$effort of them took effort',
      one: 'One of them took effort',
    );
    return '$_temp0.';
  }

  @override
  String letterShowedUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count different days',
      one: 'one day',
    );
    return 'You showed up on $_temp0.';
  }

  @override
  String planLabel(String month) {
    return 'YOUR $month PLAN';
  }

  @override
  String planNudgeMoveReminder(String time) {
    return 'Move your reminder to $time. That\'s when most of last month\'s moments landed.';
  }

  @override
  String planNudgeSetAside(String habit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You reached for it $count times last month',
      one: 'You reached for it once last month',
      zero: 'You didn\'t reach for it once last month',
    );
    return 'Set aside $habit. $_temp0.';
  }

  @override
  String planNudgeKeepAnchor(String habit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You reached for it $count times',
      one: 'You reached for it once',
    );
    return 'Keep $habit at the top. $_temp0 — more than anything else.';
  }

  @override
  String planNudgeAddFocus(String area, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of last month\'s moments were',
      one: 'One of last month\'s moments was',
    );
    return 'Add $area to your focus. $_temp0 already there.';
  }

  @override
  String get planAcceptMoveReminder => 'Move it';

  @override
  String get planAcceptSetAside => 'Set it aside';

  @override
  String get planAcceptKeepAnchor => 'Pin it';

  @override
  String get planAcceptAddFocus => 'Add it';

  @override
  String get planDecline => 'Not this month';

  @override
  String planMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more when you\'re ready',
      one: 'One more when you\'re ready',
    );
    return '$_temp0';
  }

  @override
  String get planDone =>
      'Done. In four weeks this page will tell you whether it changed anything.';

  @override
  String planProofMovedReminder(String date, String time) {
    return 'On $date you moved your reminder to $time.';
  }

  @override
  String planProofSetAside(String date, String habit) {
    return 'On $date you set aside $habit.';
  }

  @override
  String planProofPinned(String date, String habit) {
    return 'On $date you pinned $habit.';
  }

  @override
  String planProofAddedFocus(String date, String area) {
    return 'On $date you added $area to your focus.';
  }

  @override
  String planProofUp(int after, int before) {
    String _temp0 = intl.Intl.pluralLogic(
      after,
      locale: localeName,
      other: '$after moments',
      one: '1 moment',
    );
    return '$_temp0 in the four weeks after, up from $before.';
  }

  @override
  String planProofDown(int after, int before) {
    String _temp0 = intl.Intl.pluralLogic(
      after,
      locale: localeName,
      other: '$after moments',
      one: '1 moment',
    );
    return '$_temp0 in the four weeks after, down from $before.';
  }

  @override
  String planProofSame(int after) {
    String _temp0 = intl.Intl.pluralLogic(
      after,
      locale: localeName,
      other: '$after moments',
      one: '1 moment',
    );
    return '$_temp0 in the four weeks after — the same as the four weeks before.';
  }

  @override
  String get insightsGapsShortening => 'And they\'re getting shorter.';

  @override
  String get insightsTeaserBody =>
      'There\'s a pattern in this month you can\'t see yet — the gap between the focus you chose and the one you actually lived.';

  @override
  String get insightsTeaserCta => 'See what Intended+ noticed';

  @override
  String get insightsExampleSummary => 'You did 37 small things for yourself.';

  @override
  String get insightsExampleReturns =>
      'Four times you went quiet, and four times you came back.';

  @override
  String insightsReturnsLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count times you went quiet for a few days. $count times you came back',
      one: 'You went quiet for a few days, and then you came back',
    );
    return '$_temp0.';
  }

  @override
  String insightsMostlyAt(String period) {
    return 'Most of them $period.';
  }

  @override
  String get insightsPeriodMorning => 'in the morning';

  @override
  String get insightsPeriodAfternoon => 'in the afternoon';

  @override
  String get insightsPeriodEvening => 'in the evening';

  @override
  String get insightsPeriodLateNight => 'late at night';

  @override
  String get insightsStartingWith => 'WHAT YOU\'RE STARTING WITH';

  @override
  String insightsStartingMeta(String areas, String time) {
    return '$areas · a reminder at $time';
  }

  @override
  String get insightsThisMonth => 'THIS MONTH';

  @override
  String insightsDidThings(int count, String month) {
    return 'You did $count small things for yourself in $month.';
  }

  @override
  String insightsReturns(int count) {
    return '$count times you went quiet for a few days. $count times you came back.';
  }

  @override
  String get insightsExampleLabel => 'EXAMPLE';

  @override
  String get insightsExampleHeader => 'IN A MONTH, THIS PAGE LOOKS LIKE THIS';

  @override
  String get insightsUnlockNote =>
      '✦ Intended+ reads your month and suggests what to change. It unlocks once you have something to read.';

  @override
  String get habitsCreateCustom => 'Write your own intention';

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
  String get customHabitTitle => 'Write your own intention';

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
  String get customHabitLimitTitle => 'Your list is full';

  @override
  String get customHabitLimitMessage =>
      'Six intentions at a time — four from your path and two of your own. Set one aside to make room.';

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
  String get completionHowDidItLand => 'How did that land?';

  @override
  String get completionMoodGlad => 'Glad I did';

  @override
  String get completionMoodNeutral => 'Neutral';

  @override
  String get completionMoodTookEffort => 'Took effort';

  @override
  String get completionAddNote => '+ add a note';

  @override
  String get completionNoteHint => 'Anything you want to remember?';

  @override
  String get completionSkip => 'skip';

  @override
  String completionKept(int count) {
    return 'Kept — $count moments this month.';
  }

  @override
  String get completionKeptOne => 'Kept — your first moment this month.';

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
  String get notifWeeklyPathAnchorsForHardDays =>
      'A week of holding steady. See how you anchored yourself.';

  @override
  String get notifWeeklyPathQuietFocus =>
      'A week of quiet focus. See what got done.';

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
  String get paywallTitle => 'Get the full Intended experience';

  @override
  String get paywallTitleGentleMornings => 'Make your mornings even gentler';

  @override
  String get paywallTitleAnchorsForHardDays => 'More anchors for the hard days';

  @override
  String get paywallTitleQuietFocus => 'Focus that lasts';

  @override
  String get paywallTitleWindingDown => 'An even gentler way to wind down';

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
      'A letter about your month — four lines that end in a question worth keeping';

  @override
  String get paywallFeature2 =>
      'Next month\'s plan from this month\'s evidence — and whether it worked, measured';

  @override
  String get paywallFeature3 =>
      'The drift warning: a quiet word before the gap, not after it';

  @override
  String get paywallFeature4 =>
      'All ten themes, premium icons and home-screen widgets';

  @override
  String get paywallGroupRoom => 'More room';

  @override
  String get paywallGroupRoomA => 'Unlimited habits & focus areas';

  @override
  String get paywallGroupRoomB => 'No ceiling on custom habits';

  @override
  String get paywallGroupDiscovery => 'More discovery';

  @override
  String get paywallGroupDiscoveryA => 'Full habit library & curated routines';

  @override
  String get paywallGroupDiscoveryB => 'Unlimited swaps & refreshes';

  @override
  String get paywallGroupReflection => 'More reflection';

  @override
  String get paywallGroupReflectionA => 'Monthly & weekly insights';

  @override
  String get paywallGroupReflectionB => 'Shareable moment cards';

  @override
  String get paywallGroupYou => 'More you';

  @override
  String get paywallGroupYouA => '10 beautiful themes & app icons';

  @override
  String get paywallGroupYouB => 'Premium widgets for your home screen';

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
  String get paywallYearlyPerMonth => '€3.75';

  @override
  String paywallYearlyAnchor(String price) {
    return '$price/month, billed yearly';
  }

  @override
  String get paywallYearlySave => 'Save 37%';

  @override
  String paywallSavePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get paywallLifetime => 'Lifetime';

  @override
  String get paywallLifetimePrice => '€49.99';

  @override
  String get paywallLifetimePeriod => 'one-time';

  @override
  String get paywallLifetimeBadge => 'Launch price';

  @override
  String paywallCtaTrial(int days) {
    return 'Start $days-day free trial';
  }

  @override
  String get paywallCtaLifetime => 'Get lifetime access';

  @override
  String paywallTrialHint(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 free, then $price. Cancel anytime.';
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
  String get onboardingPaywallTitle => 'Intended+ reads your months';

  @override
  String get onboardingPaywallBody =>
      'The squares show what happened — Intended+ says what it means. A four-line letter about your month. A plan for the next one, built from what actually happened, with an honest answer to whether it worked. A quiet word before you drift, while the week can still change. Plus all ten themes, icons and widgets, yours from day one.';

  @override
  String get onboardingPaywallPrimaryCta => 'Start free trial';

  @override
  String get onboardingPaywallSecondaryCta => 'Not now — keep the free version';

  @override
  String onboardingPaywallDisclaimer(int days, String price, String perMonth) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 free, then $price/year — about $perMonth a month. Cancel anytime.';
  }

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
  String get profileUnlockPlus => 'Try Intended+';

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
  String get profileDeleteData => 'Delete account & data';

  @override
  String get profileVersion => 'Intended v2.0.0';

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
  String get insightsGrowthHint => 'Insights get sharper every week';

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
      'A soft, intentional way to start the day';

  @override
  String get pathAnchorsForHardDaysTitle => 'Anchors for Hard Days';

  @override
  String get pathAnchorsForHardDaysSubtitle =>
      'Small acts that hold you steady when life is loud';

  @override
  String get pathQuietFocusTitle => 'Quiet Focus';

  @override
  String get pathQuietFocusSubtitle => 'Get things done without the burnout';

  @override
  String get pathWindingDownTitle => 'Winding Down';

  @override
  String get pathWindingDownSubtitle => 'A small ritual for letting the day go';

  @override
  String get pathYourOwnWayTitle => 'Your Own Way';

  @override
  String get pathYourOwnWaySubtitle =>
      'I know what I need — just give me the tools';

  @override
  String get intentionPathHeadline => 'What brings you here?';

  @override
  String get intentionPathSubtext =>
      'This shapes the next 30 days. Pick the one that fits today — your future self will thank you.';

  @override
  String intentionPathUpdateFocusAreas(String pathName) {
    return 'Update your focus areas to match \"$pathName\"?';
  }

  @override
  String get intentionPathUpdateYes => 'Yes, update focus areas';

  @override
  String get intentionPathUpdateNo => 'No, keep my current areas';

  @override
  String get tellUsAboutPathHeadline => 'What brings you here?';

  @override
  String get tellUsAboutPathSubtext =>
      'This shapes the next 30 days. Pick the one that fits today — your future self will thank you.';

  @override
  String get tellUsAboutFocusHeadline => 'What feels important right now?';

  @override
  String get tellUsAboutFocusSubtext => 'Pick up to 2. We\'ll start there.';

  @override
  String get commitmentTitle => 'One small promise.';

  @override
  String get commitmentBody => 'Two minutes a day. That\'s the whole ask.';

  @override
  String commitmentEchoFull(String path, String areas) {
    return 'Your path: $path  ·  Your focus: $areas';
  }

  @override
  String commitmentEchoAreasOnly(String areas) {
    return 'Your focus: $areas';
  }

  @override
  String get commitmentCta => 'I\'ll show up for myself';

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
      'Your week\'s page is ready. Every week is a fresh start.';

  @override
  String get notifWeeklyDynamic1 =>
      'Your week is on the page — one moment of care in it.';

  @override
  String notifWeeklyDynamicN(int count) {
    return 'Your week is on the page — $count moments in it.';
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
  String get faqNeedAccount => 'Do I need an account?';

  @override
  String get faqNeedAccountAnswer =>
      'Not to get started. You can use Intended without signing in. Creating an account (via Apple or Google) lets you back up your data to the cloud and restore it if you switch devices.';

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
      'Nothing happens. No streaks break, no counters reset — research on habit formation found a missed day doesn\'t materially set you back. If you were quiet a few days, the first square after is marked as a return, not the gap as a failure. And if you did the thing but didn\'t log it: long-press the card to log yesterday.';

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
  String get faqAllDone => 'What happens when I complete all my habits?';

  @override
  String get faqAllDoneAnswer =>
      'You\'ll see a quiet celebration — a gentle bloom moment. It\'s a small reminder that showing up matters, no matter how many habits you checked off.';

  @override
  String get faqSectionReflections => 'Your month';

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
      'Yes — on Your month, tap Share under your season. It becomes a story-sized card with your grid and your season word, sized for Instagram or TikTok. Habit names are never on it unless you put them there.';

  @override
  String get faqNoReflection => 'Why don\'t I see a reflection?';

  @override
  String get faqNoReflectionAnswer =>
      'Weekly reflections appear after 7 days. Monthly after 30. The more you check in, the richer they become.';

  @override
  String get faqHowReflectionsGenerated => 'How are reflections generated?';

  @override
  String get faqHowReflectionsGeneratedAnswer =>
      'Reflections are generated entirely on your device from your check-in data. No AI, no cloud processing. The app looks at your patterns — active days, favorite habits, consistency — and turns them into gentle observations.';

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
  String get faqTurnOffNotifications => 'Can I turn off notifications?';

  @override
  String get faqTurnOffNotificationsAnswer =>
      'Yes. Go to Profile → Notification Settings and toggle them off. You can also disable just the weekly reflection reminder while keeping daily ones.';

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
      'Intended+ is the reading of your month: the drift warning before a quiet stretch, a four-line letter, next month\'s plan built from this month\'s evidence, what actually lifts you, the season\'s explanation and archive — plus all ten themes, premium icons and widgets.';

  @override
  String get faqPricing => 'How much does it cost?';

  @override
  String faqPricingAnswer(
      String monthly, String yearly, String lifetime, int days) {
    return 'Monthly: $monthly. Yearly: $yearly. Lifetime: $lifetime, one-time. Both subscriptions start with a $days-day free trial.';
  }

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
      'Your moments live on your device first. If you sign in, they\'re also backed up to your private account so a new phone can restore them — that includes mood taps and notes. No one else can see them, and deleting your account deletes the backup.';

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
  String get faqNotificationsNotArriving => 'Notifications aren\'t arriving.';

  @override
  String get faqNotificationsNotArrivingAnswer =>
      'Check that notifications are enabled for Intended in iPhone Settings → Notifications. Also make sure Background App Refresh is on. If you recently reinstalled, open the app once so it can reschedule reminders.';

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
  String get bloomAnchorsForHardDays1 => 'An anchor held.';

  @override
  String get bloomAnchorsForHardDays2 => 'Even when hard, you\'re here.';

  @override
  String get bloomAnchorsForHardDays3 => 'Even when loud, you returned.';

  @override
  String get bloomAnchorsForHardDays4 => 'A small steady win on a hard day.';

  @override
  String get bloomAnchorsForHardDays5 => 'You\'re not gone. You\'re here.';

  @override
  String get bloomQuietFocus1 => 'Focused. Finished.';

  @override
  String get bloomQuietFocus2 => 'Quiet work, fully done.';

  @override
  String get bloomQuietFocus3 => 'One thing, all the way through.';

  @override
  String get bloomQuietFocus4 => 'Steady focus. Real progress.';

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
  String get notifPathAnchorsForHardDays1 =>
      'One small anchor for today. That\'s enough.';

  @override
  String get notifPathAnchorsForHardDays2 =>
      'Today might be heavy. Show up gently anyway.';

  @override
  String get notifPathAnchorsForHardDays3 =>
      'An anchor doesn\'t fix the storm. It holds you steady.';

  @override
  String get notifPathAnchorsForHardDays4 =>
      'Even a small return counts. Especially today.';

  @override
  String get notifPathAnchorsForHardDays5 => 'Pause. Notice. Pick one thing.';

  @override
  String get notifPathAnchorsForHardDays6 =>
      'Hard days are also days that pass. You\'re here.';

  @override
  String get notifPathQuietFocus1 => 'A small block of focus. Then rest.';

  @override
  String get notifPathQuietFocus2 => 'What\'s the one thing today?';

  @override
  String get notifPathQuietFocus3 => 'Focus on less. Finish more.';

  @override
  String get notifPathQuietFocus4 => 'Pick one. Begin.';

  @override
  String get notifPathQuietFocus5 => 'Quiet work, real progress.';

  @override
  String get notifPathQuietFocus6 =>
      'Show up to the work. That\'s the whole secret.';

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

  @override
  String get letterOpenedQuietly => 'You started this month quietly.';

  @override
  String get letterOpenedFull => 'You came into this month at full speed.';

  @override
  String letterMostlyChose(String area) {
    return '$area carried almost the whole month.';
  }

  @override
  String letterQuestionPlanForPart(String month, String lived, String planned) {
    return 'What would $month look like if you planned for $lived instead of $planned?';
  }

  @override
  String letterQuestionShorterQuiet(String month) {
    return 'What would $month look like if the quiet stretches were shorter?';
  }

  @override
  String letterQuestionMoreOfWhat(String month) {
    return 'What do you want more of in $month?';
  }

  @override
  String get letterPartMornings => 'mornings';

  @override
  String get letterPartAfternoons => 'afternoons';

  @override
  String get letterPartEvenings => 'evenings';

  @override
  String get letterPartNights => 'late nights';

  @override
  String get planActionsHeader => 'YOUR ACTIONS';

  @override
  String get planRhythmHeader => 'YOUR RHYTHM';

  @override
  String get planUse => 'Use this plan';

  @override
  String get planAdjust => 'Adjust';

  @override
  String get planSkip => 'Skip';

  @override
  String get planPreviewLabel => 'WHAT INTENDED+ WOULD SUGGEST';

  @override
  String insightsReturnGaps(String gaps) {
    return '$gaps days apart.';
  }

  @override
  String shareSeasonMoments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moments',
      one: '1 moment',
    );
    return '$_temp0';
  }

  @override
  String shareSeasonReturns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'I came back $count times',
      one: 'I came back once',
    );
    return '$_temp0';
  }

  @override
  String get shareIncludeHabitNames => 'Include my habit names';

  @override
  String get todayAdoptIntention => 'Adopt a different intention';

  @override
  String get todaySwapHint => 'Not landing? Hold to swap.';

  @override
  String rescueTitle(int count) {
    return '$count quiet days. That\'s allowed.';
  }

  @override
  String get rescueBody => 'Just this one today?';

  @override
  String get rescueLongTitle => 'It\'s been a while. That\'s allowed.';

  @override
  String get rescueLongBody => 'Nothing here kept score while you were gone.';

  @override
  String get rescueShowAll => 'Show everything';

  @override
  String get menuDidYesterday => 'I did this yesterday';

  @override
  String get toastKeptYesterday => 'Kept — for yesterday.';

  @override
  String get toastAlreadyYesterday => 'Yesterday already has this one.';

  @override
  String get liftLabel => 'WHAT LIFTS YOU';

  @override
  String liftLine(String habit, int glad, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      glad,
      locale: localeName,
      other: '$glad times',
      one: 'once',
    );
    return '$habit — glad you did it $_temp0 out of $total.';
  }

  @override
  String liftForming(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: 'a week',
    );
    return 'Too early to call it a pattern — ask me again in $_temp0.';
  }

  @override
  String get liftWorstLead => 'That last one mostly doesn\'t land.';

  @override
  String get soFarLabel => 'SO FAR';

  @override
  String get soFarGlad => 'glad you did';

  @override
  String get soFarEffort => 'took effort';

  @override
  String get soFarClosing =>
      'Too early to call anything a pattern. This page grows as you do.';

  @override
  String get firstWeekLabel => 'YOUR FIRST WEEK';

  @override
  String firstWeekCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count small things',
      one: 'One small thing',
    );
    return '$_temp0 for yourself in your first week.';
  }

  @override
  String firstWeekGladdest(String habit) {
    return 'The one you were glad about most: $habit.';
  }

  @override
  String get shareSeasonGaps => 'My gaps are getting shorter.';

  @override
  String get pathMoreIntentions => 'MORE INTENTIONS';

  @override
  String get pathSofterNightsTitle => 'Softer Nights';

  @override
  String get pathSofterNightsSubtitle => 'For sleep that doesn\'t fight you';

  @override
  String get intentionSofterNights => 'Sleep that comes easier';

  @override
  String get pathLookingUpTitle => 'Looking Up';

  @override
  String get pathLookingUpSubtitle => 'Less scrolling, more of everything else';

  @override
  String get intentionLookingUp => 'More life outside the screen';

  @override
  String get pathCloserToPeopleTitle => 'Closer to People';

  @override
  String get pathCloserToPeopleSubtitle => 'Small ways to stay in touch';

  @override
  String get intentionCloserToPeople => 'Closer to my people';

  @override
  String get pathMovingALittleTitle => 'Moving a Little';

  @override
  String get pathMovingALittleSubtitle => 'Gentle movement, no gym required';

  @override
  String get intentionMovingALittle => 'Moving a little, most days';

  @override
  String get pathThroughAHardSeasonTitle => 'Through a Hard Season';

  @override
  String get pathThroughAHardSeasonSubtitle =>
      'The smallest steps, for the heaviest months';

  @override
  String get intentionThroughAHardSeason => 'Gentle with myself through this';

  @override
  String get habitScreensAwayBed => 'Screens away 20 minutes before bed';

  @override
  String get habitDimLights => 'Dim the lights an hour before sleep';

  @override
  String get habitMealWithoutPhone => 'One meal without your phone';

  @override
  String insightsFilterLine(String area, int count, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moments',
      one: 'one moment',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: 'one day',
    );
    return '$area — $_temp0 across $_temp1.';
  }

  @override
  String get momentSheetYesterday => 'yesterday';

  @override
  String get insightsPastEmptyTitle => 'A quiet month.';

  @override
  String get insightsPastEmptyBody =>
      'Nothing was collected here — and it kept none of your later months from happening.';

  @override
  String get faqWhatIsMoment => 'What are the squares?';

  @override
  String get faqWhatIsMomentAnswer =>
      'Every action you complete becomes one square — a moment — in your month\'s grid. The grid only grows: there is no square for a day you skipped, because days aren\'t the unit here. Colour is the focus area; the tint is how it landed.';

  @override
  String get faqWhatAreSeasons => 'What is my season?';

  @override
  String get faqWhatAreSeasonsAnswer =>
      'Once a month has about ten moments, Intended names its pattern — Evening, Steady, Returning. It\'s an observation about the month, never a label on you: next month reads fresh, and a closed month\'s word is frozen forever.';

  @override
  String get faqPlusReads => 'What does Intended+ actually do with my month?';

  @override
  String get faqPlusReadsAnswer =>
      'It reads what free shows. The drift warning speaks up before a quiet stretch, while there\'s still a week to change. The letter tells the month back to you in four lines and ends on a question. The plan turns last month\'s evidence into one or two concrete changes — and four weeks later tells you honestly whether the change worked.';

  @override
  String get faqStopPaying => 'Do I lose anything if I stop paying?';

  @override
  String get faqStopPayingAnswer =>
      'Nothing you made. Every moment, note and season stays yours, the grid keeps growing, and the gentle come-back nudge stays free forever. What pauses is the reading: drift, the letter, the plan, and what lifts you.';

  @override
  String get yearInSeasonsTitle => 'Your months';

  @override
  String get widgetCatchupEyebrow => 'FROM YOUR WIDGET';

  @override
  String get profileExportData => 'Export my data';

  @override
  String get profileExportFailed => 'Export didn\'t finish — try again.';

  @override
  String get insightsFilterHint => 'tap a colour = see just those';

  @override
  String get onboardingPaywallStep1 =>
      'Keep small intentions — each one lands as a square in your month';

  @override
  String get onboardingPaywallStep2 =>
      'Read your month — the letter, your season, next month\'s plan';

  @override
  String get onboardingPaywallStep3 =>
      'See what worked — measured honestly, four weeks on';

  @override
  String focusAreasFromPath(String path) {
    return '$path starts with these two. Swap them if something else matters more.';
  }

  @override
  String get focusAreasLimitToast =>
      'Two keeps the focus — set one down first.';

  @override
  String get insightsExampleSeason => 'Returning';

  @override
  String get insightsExampleLetter =>
      'Six days passed, and then you came back.';

  @override
  String get insightsExamplePlan =>
      'Move your reminder to 9 PM — that\'s where this month lived.';

  @override
  String get onboardingPaywallLoop => '…and the next month begins';

  @override
  String letterQuestionStillFits(String path) {
    return 'Is “$path” still what you\'re after?';
  }

  @override
  String get profileExportSubject => 'My Intended moments';

  @override
  String get profileExportEmpty => 'Nothing to export yet.';
}
