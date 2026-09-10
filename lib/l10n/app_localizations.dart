import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get commonGreat;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @appNameIntended.
  ///
  /// In en, this message translates to:
  /// **'Intended'**
  String get appNameIntended;

  /// No description provided for @appNameIntendedPlus.
  ///
  /// In en, this message translates to:
  /// **'Intended+'**
  String get appNameIntendedPlus;

  /// No description provided for @appPlanCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get appPlanCore;

  /// No description provided for @appPlanBoost.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get appPlanBoost;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Intended'**
  String get welcomeTitle;

  /// No description provided for @welcomeTitleWithName.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Intended,\n{name}'**
  String welcomeTitleWithName(String name);

  /// The brief overlay after 7–13 days away, when a name is stored.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}! You came back — that\'s what\'s important.'**
  String welcomeBackReturnWithName(String name);

  /// No description provided for @welcomeBackReturn.
  ///
  /// In en, this message translates to:
  /// **'Hi! You came back — that\'s what\'s important.'**
  String get welcomeBackReturn;

  /// The brief overlay after 14+ days away.
  ///
  /// In en, this message translates to:
  /// **'Hey, you. We kept the light on.'**
  String get welcomeBackLongAway;

  /// The brief overlay after 3–6 days away.
  ///
  /// In en, this message translates to:
  /// **'You\'re back. No catching up needed.'**
  String get welcomeBackShortAway;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build small daily habits\nwithout the guilt.'**
  String get welcomeSubtitle;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Intention, not perfection.'**
  String get onboardingTagline;

  /// No description provided for @onboardingDescriptor.
  ///
  /// In en, this message translates to:
  /// **'No streaks. No scores. Just small steps that bring you closer to yourself.'**
  String get onboardingDescriptor;

  /// No description provided for @onboardingNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingNamePrompt;

  /// No description provided for @onboardingLetsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get onboardingLetsGetStarted;

  /// No description provided for @onboardingContinueWithoutName.
  ///
  /// In en, this message translates to:
  /// **'Continue without a name'**
  String get onboardingContinueWithoutName;

  /// No description provided for @onboardingNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name should be under {max} characters'**
  String onboardingNameTooLong(int max);

  /// No description provided for @onboardingNameInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Please choose a more appropriate name'**
  String get onboardingNameInappropriate;

  /// No description provided for @onboardingOops.
  ///
  /// In en, this message translates to:
  /// **'Oops'**
  String get onboardingOops;

  /// No description provided for @focusAreaHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get focusAreaHealth;

  /// No description provided for @focusAreaHealthSub.
  ///
  /// In en, this message translates to:
  /// **'Your body will thank you.'**
  String get focusAreaHealthSub;

  /// No description provided for @focusAreaMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get focusAreaMood;

  /// No description provided for @focusAreaMoodSub.
  ///
  /// In en, this message translates to:
  /// **'Notice how you feel. That\'s the first step.'**
  String get focusAreaMoodSub;

  /// No description provided for @focusAreaProductivity.
  ///
  /// In en, this message translates to:
  /// **'Doing one thing'**
  String get focusAreaProductivity;

  /// No description provided for @focusAreaHome.
  ///
  /// In en, this message translates to:
  /// **'Home & organization'**
  String get focusAreaHome;

  /// No description provided for @focusAreaHomeSub.
  ///
  /// In en, this message translates to:
  /// **'Small tidying, big calm.'**
  String get focusAreaHomeSub;

  /// No description provided for @focusAreaRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get focusAreaRelationships;

  /// No description provided for @focusAreaRelationshipsSub.
  ///
  /// In en, this message translates to:
  /// **'The people who matter.'**
  String get focusAreaRelationshipsSub;

  /// No description provided for @focusAreaCreativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get focusAreaCreativity;

  /// No description provided for @focusAreaCreativitySub.
  ///
  /// In en, this message translates to:
  /// **'Make something. Anything.'**
  String get focusAreaCreativitySub;

  /// No description provided for @focusAreaFinances.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get focusAreaFinances;

  /// No description provided for @focusAreaSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Self-care'**
  String get focusAreaSelfCare;

  /// No description provided for @focusAreaSelfCareSub.
  ///
  /// In en, this message translates to:
  /// **'The small luxuries you keep skipping.'**
  String get focusAreaSelfCareSub;

  /// No description provided for @focusAreasPromptWithName.
  ///
  /// In en, this message translates to:
  /// **'What matters to you right now, {name}?'**
  String focusAreasPromptWithName(String name);

  /// No description provided for @focusAreasPrompt.
  ///
  /// In en, this message translates to:
  /// **'What matters to you right now?'**
  String get focusAreasPrompt;

  /// No description provided for @focusAreasChooseCount.
  ///
  /// In en, this message translates to:
  /// **'Choose up to two areas ({count}/{max})'**
  String focusAreasChooseCount(int count, int max);

  /// No description provided for @focusAreasChangeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this later.'**
  String get focusAreasChangeLater;

  /// No description provided for @focusAreasLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get focusAreasLimitTitle;

  /// No description provided for @focusAreasLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 2 areas. Deselect one to choose another.'**
  String get focusAreasLimitMessage;

  /// No description provided for @reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Want a gentle daily reminder?'**
  String get reminderSubtitle;

  /// No description provided for @reminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Just once a day. No pressure.'**
  String get reminderDescription;

  /// No description provided for @reminderDailyToggle.
  ///
  /// In en, this message translates to:
  /// **'Gentle daily reminder'**
  String get reminderDailyToggle;

  /// No description provided for @reminderAroundTime.
  ///
  /// In en, this message translates to:
  /// **'Around {time}'**
  String reminderAroundTime(String time);

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get reminderTimeLabel;

  /// No description provided for @reminderTimePicker.
  ///
  /// In en, this message translates to:
  /// **'Set reminder time'**
  String get reminderTimePicker;

  /// No description provided for @reminderSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Switch this on to pick the time for your daily reminder.'**
  String get reminderSwitchHint;

  /// No description provided for @reminderNoWorries.
  ///
  /// In en, this message translates to:
  /// **'No worries — you can turn these on anytime from your profile.'**
  String get reminderNoWorries;

  /// No description provided for @reminderWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get reminderWeeklySummary;

  /// No description provided for @reminderWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every Sunday morning'**
  String get reminderWeeklySubtitle;

  /// No description provided for @reminderLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go, {name}'**
  String reminderLetsGo(String name);

  /// No description provided for @themeSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your space'**
  String get themeSelectionTitle;

  /// No description provided for @themeSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can always change this later.'**
  String get themeSelectionSubtitle;

  /// No description provided for @themeSelectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'This feels right'**
  String get themeSelectionConfirm;

  /// No description provided for @themeSelectionPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus and more themes are available with Intended+. Try it free for {days, plural, =1{1 day} other{{days} days}} after setup.'**
  String themeSelectionPremiumHint(int days);

  /// The theme hint before the store has confirmed the trial length — names a trial, never measures it.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus and more themes are available with Intended+. Try it free after setup.'**
  String get themeSelectionPremiumHintUnspecified;

  /// The theme hint when the store reports no free trial on the yearly plan.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus and more themes are available with Intended+.'**
  String get themeSelectionPremiumHintNoTrial;

  /// No description provided for @habitRevealTitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what we picked for you'**
  String get habitRevealTitle;

  /// No description provided for @habitRevealSubtitlePath.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what your {pathTitle} practice looks like.'**
  String habitRevealSubtitlePath(String pathTitle);

  /// No description provided for @habitRevealSubtitleOwnWay.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what your practice looks like.'**
  String get habitRevealSubtitleOwnWay;

  /// No description provided for @habitRevealDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick what feels right. Skip what doesn\'t. There\'s no pressure to do them all — one is enough.'**
  String get habitRevealDescription;

  /// No description provided for @habitRevealBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get habitRevealBegin;

  /// No description provided for @focusAreasStartingPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {pathTitle} practice starts here'**
  String focusAreasStartingPointsTitle(String pathTitle);

  /// No description provided for @focusAreasStartingPointsSubtext.
  ///
  /// In en, this message translates to:
  /// **'We\'ve picked some starting points. Add or remove areas anytime.'**
  String get focusAreasStartingPointsSubtext;

  /// No description provided for @habitsCompleteOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Complete onboarding to get started'**
  String get habitsCompleteOnboarding;

  /// No description provided for @habitsPinned.
  ///
  /// In en, this message translates to:
  /// **'PINNED'**
  String get habitsPinned;

  /// No description provided for @intentionGentleMornings.
  ///
  /// In en, this message translates to:
  /// **'Starting the day gently'**
  String get intentionGentleMornings;

  /// No description provided for @intentionAnchorsForHardDays.
  ///
  /// In en, this message translates to:
  /// **'Steadier on hard days'**
  String get intentionAnchorsForHardDays;

  /// No description provided for @intentionQuietFocus.
  ///
  /// In en, this message translates to:
  /// **'Focused, without the burnout'**
  String get intentionQuietFocus;

  /// No description provided for @intentionWindingDown.
  ///
  /// In en, this message translates to:
  /// **'Letting the day go'**
  String get intentionWindingDown;

  /// No description provided for @intentionYourOwnWay.
  ///
  /// In en, this message translates to:
  /// **'Your own way'**
  String get intentionYourOwnWay;

  /// No description provided for @habitsAddYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Add something of your own'**
  String get habitsAddYourOwn;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your month'**
  String get insightsTitle;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet — and that\'s exactly right.'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Every small thing you do gets saved here.'**
  String get insightsEmptyBody;

  /// No description provided for @insightsGridCaption.
  ///
  /// In en, this message translates to:
  /// **'one square = one thing you did'**
  String get insightsGridCaption;

  /// No description provided for @insightsTeaserNoGap.
  ///
  /// In en, this message translates to:
  /// **'There\'s a why underneath these squares. Intended+ finds it — and turns it into next month\'s plan.'**
  String get insightsTeaserNoGap;

  /// No description provided for @driftLabel.
  ///
  /// In en, this message translates to:
  /// **'RIGHT NOW'**
  String get driftLabel;

  /// No description provided for @driftBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve collected {thisWeek} moments this week. You usually collect {usual}.'**
  String driftBody(int thisWeek, int usual);

  /// No description provided for @driftFollowed.
  ///
  /// In en, this message translates to:
  /// **'The last two times this happened, a quiet stretch followed.'**
  String get driftFollowed;

  /// No description provided for @driftActionEase.
  ///
  /// In en, this message translates to:
  /// **'Just one action for a few days'**
  String get driftActionEase;

  /// No description provided for @driftActionFine.
  ///
  /// In en, this message translates to:
  /// **'I\'m fine'**
  String get driftActionFine;

  /// No description provided for @seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR SEASON'**
  String get seasonLabel;

  /// No description provided for @seasonPatternThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Your pattern this month'**
  String get seasonPatternThisMonth;

  /// No description provided for @seasonBeginning.
  ///
  /// In en, this message translates to:
  /// **'Beginning'**
  String get seasonBeginning;

  /// No description provided for @seasonBeginningLine.
  ///
  /// In en, this message translates to:
  /// **'{count} of 10 moments. Your season appears once there\'s enough to read.'**
  String seasonBeginningLine(int count);

  /// No description provided for @seasonMorning.
  ///
  /// In en, this message translates to:
  /// **'Early'**
  String get seasonMorning;

  /// No description provided for @seasonMorningLine.
  ///
  /// In en, this message translates to:
  /// **'You come to this early. The day starts with you.'**
  String get seasonMorningLine;

  /// No description provided for @seasonEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get seasonEvening;

  /// No description provided for @seasonEveningLine.
  ///
  /// In en, this message translates to:
  /// **'You come to this once the day has quieted.'**
  String get seasonEveningLine;

  /// No description provided for @seasonSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get seasonSteady;

  /// No description provided for @seasonSteadyLine.
  ///
  /// In en, this message translates to:
  /// **'A little, most days. That\'s the pattern.'**
  String get seasonSteadyLine;

  /// No description provided for @seasonBursts.
  ///
  /// In en, this message translates to:
  /// **'Bursts'**
  String get seasonBursts;

  /// No description provided for @seasonBurstsLine.
  ///
  /// In en, this message translates to:
  /// **'You arrive in waves, and the waves come back.'**
  String get seasonBurstsLine;

  /// No description provided for @seasonReturning.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get seasonReturning;

  /// No description provided for @seasonReturningLine.
  ///
  /// In en, this message translates to:
  /// **'You go quiet, and you find your way back.'**
  String get seasonReturningLine;

  /// No description provided for @seasonContinuous.
  ///
  /// In en, this message translates to:
  /// **'Continuous'**
  String get seasonContinuous;

  /// No description provided for @seasonContinuousLine.
  ///
  /// In en, this message translates to:
  /// **'You\'ve kept a thread running all month.'**
  String get seasonContinuousLine;

  /// No description provided for @seasonFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get seasonFocused;

  /// No description provided for @seasonFocusedLine.
  ///
  /// In en, this message translates to:
  /// **'One thing had most of your attention.'**
  String get seasonFocusedLine;

  /// No description provided for @seasonWandering.
  ///
  /// In en, this message translates to:
  /// **'Wandering'**
  String get seasonWandering;

  /// No description provided for @seasonWanderingLine.
  ///
  /// In en, this message translates to:
  /// **'You moved between things, following what you needed.'**
  String get seasonWanderingLine;

  /// No description provided for @letterLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR LETTER'**
  String get letterLabel;

  /// No description provided for @letterCameBack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{A day passed} other{{count} days passed}}, and then you came back.'**
  String letterCameBack(int count);

  /// No description provided for @letterAnchor.
  ///
  /// In en, this message translates to:
  /// **'Most of it was {habit} — {count, plural, =1{once} other{{count} times}}.'**
  String letterAnchor(String habit, int count);

  /// No description provided for @letterMood.
  ///
  /// In en, this message translates to:
  /// **'{glad} of them you were glad you did. {effort, plural, =1{One took effort} other{{effort} took effort}}.'**
  String letterMood(int glad, int effort);

  /// No description provided for @letterMoodGladOnly.
  ///
  /// In en, this message translates to:
  /// **'{glad, plural, =1{One of them you were glad you did} other{{glad} of them you were glad you did}}.'**
  String letterMoodGladOnly(int glad);

  /// No description provided for @letterMoodEffortOnly.
  ///
  /// In en, this message translates to:
  /// **'{effort, plural, =1{One of them took effort} other{{effort} of them took effort}}.'**
  String letterMoodEffortOnly(int effort);

  /// No description provided for @letterShowedUp.
  ///
  /// In en, this message translates to:
  /// **'You showed up on {count, plural, =1{one day} other{{count} different days}}.'**
  String letterShowedUp(int count);

  /// Month name arrives already uppercased by the caller, so the label matches the other all-caps card eyebrows without a locale-specific casing rule here.
  ///
  /// In en, this message translates to:
  /// **'YOUR {month} PLAN'**
  String planLabel(String month);

  /// No description provided for @planNudgeMoveReminder.
  ///
  /// In en, this message translates to:
  /// **'Move your reminder to {time}. That\'s when most of last month\'s moments landed.'**
  String planNudgeMoveReminder(String time);

  /// No description provided for @planNudgeSetAside.
  ///
  /// In en, this message translates to:
  /// **'Set aside {habit}. {count, plural, =0{You didn\'t reach for it once last month} =1{You reached for it once last month} other{You reached for it {count} times last month}}.'**
  String planNudgeSetAside(String habit, int count);

  /// No description provided for @planNudgeKeepAnchor.
  ///
  /// In en, this message translates to:
  /// **'Keep {habit} at the top. {count, plural, =1{You reached for it once} other{You reached for it {count} times}} — more than anything else.'**
  String planNudgeKeepAnchor(String habit, int count);

  /// No description provided for @planNudgeAddFocus.
  ///
  /// In en, this message translates to:
  /// **'Add {area} to your focus. {count, plural, =1{One of last month\'s moments was} other{{count} of last month\'s moments were}} already there.'**
  String planNudgeAddFocus(String area, int count);

  /// No description provided for @planAcceptMoveReminder.
  ///
  /// In en, this message translates to:
  /// **'Move it'**
  String get planAcceptMoveReminder;

  /// No description provided for @planAcceptSetAside.
  ///
  /// In en, this message translates to:
  /// **'Set it aside'**
  String get planAcceptSetAside;

  /// No description provided for @planAcceptKeepAnchor.
  ///
  /// In en, this message translates to:
  /// **'Pin it'**
  String get planAcceptKeepAnchor;

  /// No description provided for @planNudgeGiveBack.
  ///
  /// In en, this message translates to:
  /// **'{habit} looks like it\'s yours now — {c1, plural, =1{once} other{{c1} times}} in {m1}, {c2} in {m2}, {c3} in {m3}. Keep it here, or make room for something new?'**
  String planNudgeGiveBack(
      String habit, int c1, String m1, int c2, String m2, int c3, String m3);

  /// No description provided for @planAcceptGiveBack.
  ///
  /// In en, this message translates to:
  /// **'Make room'**
  String get planAcceptGiveBack;

  /// No description provided for @planProofGaveBack.
  ///
  /// In en, this message translates to:
  /// **'On {date} you gave {habit} its slot back.'**
  String planProofGaveBack(String date, String habit);

  /// No description provided for @planAcceptAddFocus.
  ///
  /// In en, this message translates to:
  /// **'Add it'**
  String get planAcceptAddFocus;

  /// No description provided for @planDone.
  ///
  /// In en, this message translates to:
  /// **'Done. In four weeks this page will tell you whether it changed anything.'**
  String get planDone;

  /// No description provided for @planProofMovedReminder.
  ///
  /// In en, this message translates to:
  /// **'On {date} you moved your reminder to {time}.'**
  String planProofMovedReminder(String date, String time);

  /// No description provided for @planProofSetAside.
  ///
  /// In en, this message translates to:
  /// **'On {date} you set aside {habit}.'**
  String planProofSetAside(String date, String habit);

  /// No description provided for @planProofPinned.
  ///
  /// In en, this message translates to:
  /// **'On {date} you pinned {habit}.'**
  String planProofPinned(String date, String habit);

  /// No description provided for @planProofAddedFocus.
  ///
  /// In en, this message translates to:
  /// **'On {date} you added {area} to your focus.'**
  String planProofAddedFocus(String date, String area);

  /// No description provided for @planProofUp.
  ///
  /// In en, this message translates to:
  /// **'{after, plural, =1{1 moment} other{{after} moments}} in the four weeks after, up from {before}.'**
  String planProofUp(int after, int before);

  /// No description provided for @planProofDown.
  ///
  /// In en, this message translates to:
  /// **'{after, plural, =1{1 moment} other{{after} moments}} in the four weeks after, down from {before}.'**
  String planProofDown(int after, int before);

  /// No description provided for @planProofSame.
  ///
  /// In en, this message translates to:
  /// **'{after, plural, =1{1 moment} other{{after} moments}} in the four weeks after — the same as the four weeks before.'**
  String planProofSame(int after);

  /// No description provided for @insightsGapsShortening.
  ///
  /// In en, this message translates to:
  /// **'And they\'re getting shorter.'**
  String get insightsGapsShortening;

  /// No description provided for @insightsTeaserBody.
  ///
  /// In en, this message translates to:
  /// **'There\'s a pattern in this month you can\'t see yet — the gap between the focus you chose and the one you actually lived.'**
  String get insightsTeaserBody;

  /// No description provided for @insightsTeaserReturns.
  ///
  /// In en, this message translates to:
  /// **'This month\'s quiet stretches have a shape — how far apart your returns really were. Intended+ reads it back to you.'**
  String get insightsTeaserReturns;

  /// No description provided for @insightsTeaserCta.
  ///
  /// In en, this message translates to:
  /// **'See what Intended+ noticed'**
  String get insightsTeaserCta;

  /// No description provided for @insightsExampleSummary.
  ///
  /// In en, this message translates to:
  /// **'You did 37 small things for yourself.'**
  String get insightsExampleSummary;

  /// No description provided for @insightsExampleReturns.
  ///
  /// In en, this message translates to:
  /// **'Four times you went quiet, and four times you came back.'**
  String get insightsExampleReturns;

  /// No description provided for @insightsReturnsLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You went quiet for a few days, and then you came back} other{{count} times you went quiet for a few days. {count} times you came back}}.'**
  String insightsReturnsLine(int count);

  /// No description provided for @insightsMostlyAt.
  ///
  /// In en, this message translates to:
  /// **'Most of them {period}.'**
  String insightsMostlyAt(String period);

  /// No description provided for @insightsPeriodMorning.
  ///
  /// In en, this message translates to:
  /// **'in the morning'**
  String get insightsPeriodMorning;

  /// No description provided for @insightsPeriodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'in the afternoon'**
  String get insightsPeriodAfternoon;

  /// No description provided for @insightsPeriodEvening.
  ///
  /// In en, this message translates to:
  /// **'in the evening'**
  String get insightsPeriodEvening;

  /// No description provided for @insightsPeriodLateNight.
  ///
  /// In en, this message translates to:
  /// **'late at night'**
  String get insightsPeriodLateNight;

  /// No description provided for @insightsStartingWith.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU\'RE STARTING WITH'**
  String get insightsStartingWith;

  /// No description provided for @insightsStartingMeta.
  ///
  /// In en, this message translates to:
  /// **'{areas} · a reminder at {time}'**
  String insightsStartingMeta(String areas, String time);

  /// Joins the last two entries of a list. The caller joins anything before them with commas, so this only ever sees the final pair.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second}'**
  String commonListAnd(String first, String second);

  /// No description provided for @insightsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get insightsThisMonth;

  /// No description provided for @insightsDidThings.
  ///
  /// In en, this message translates to:
  /// **'You did {count} small things for yourself in {month}.'**
  String insightsDidThings(int count, String month);

  /// No description provided for @insightsExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'EXAMPLE'**
  String get insightsExampleLabel;

  /// No description provided for @insightsExampleHeader.
  ///
  /// In en, this message translates to:
  /// **'IN A MONTH, THIS PAGE LOOKS LIKE THIS'**
  String get insightsExampleHeader;

  /// No description provided for @insightsUnlockNote.
  ///
  /// In en, this message translates to:
  /// **'✦ Intended+ reads your month and suggests what to change. It unlocks once you have something to read.'**
  String get insightsUnlockNote;

  /// No description provided for @habitsCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Write your own intention'**
  String get habitsCreateCustom;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @customHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your own intention'**
  String get customHabitTitle;

  /// No description provided for @customHabitPrompt.
  ///
  /// In en, this message translates to:
  /// **'What small action would you like to take?'**
  String get customHabitPrompt;

  /// No description provided for @customHabitHint.
  ///
  /// In en, this message translates to:
  /// **'Keep it simple and specific.'**
  String get customHabitHint;

  /// No description provided for @customHabitPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., Take a 5-minute walk'**
  String get customHabitPlaceholder;

  /// No description provided for @customHabitCharCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/50 characters'**
  String customHabitCharCount(int count);

  /// No description provided for @customHabitFocusAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Which area is this for?'**
  String get customHabitFocusAreaLabel;

  /// No description provided for @customHabitSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add to my habits'**
  String get customHabitSubmit;

  /// No description provided for @editHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabitTitle;

  /// No description provided for @habitShowOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Show this on'**
  String get habitShowOnLabel;

  /// No description provided for @editHabitSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editHabitSave;

  /// No description provided for @customHabitCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Intention created'**
  String get customHabitCreatedTitle;

  /// No description provided for @customHabitCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has been added to your intentions.'**
  String customHabitCreatedMessage(String title);

  /// No description provided for @customHabitLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Six intentions at a time — four from your path and two of your own. Set one aside to make room.'**
  String get customHabitLimitMessage;

  /// No description provided for @menuUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get menuUnpin;

  /// No description provided for @menuPinToTop.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get menuPinToTop;

  /// No description provided for @menuSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap for another'**
  String get menuSwap;

  /// No description provided for @replacePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace pin?'**
  String get replacePinTitle;

  /// No description provided for @replacePinDescription.
  ///
  /// In en, this message translates to:
  /// **'Current: {current}\nNew: {newHabit}'**
  String replacePinDescription(String current, String newHabit);

  /// No description provided for @replacePinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace pin'**
  String get replacePinConfirm;

  /// No description provided for @swapCantTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t swap this habit'**
  String get swapCantTitle;

  /// No description provided for @swapCantMessage.
  ///
  /// In en, this message translates to:
  /// **'Custom habits can\'t be swapped. You can delete it and add a new one instead.'**
  String get swapCantMessage;

  /// No description provided for @swapTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap \"{title}\"?'**
  String swapTitle(String title);

  /// No description provided for @swapCategoryHabits.
  ///
  /// In en, this message translates to:
  /// **'More {category} habits:'**
  String swapCategoryHabits(String category);

  /// No description provided for @swapFreeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Free swaps left: {remaining}'**
  String swapFreeRemaining(int remaining);

  /// No description provided for @swapSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit swapped'**
  String get swapSuccessTitle;

  /// No description provided for @swapSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Replaced with \"{habit}\"'**
  String swapSuccessMessage(String habit);

  /// No description provided for @swapErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get swapErrorTitle;

  /// No description provided for @swapNoAltTitle.
  ///
  /// In en, this message translates to:
  /// **'No alternatives'**
  String get swapNoAltTitle;

  /// No description provided for @swapNoAltMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re already using all available habits from this category.'**
  String get swapNoAltMessage;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get deleteHabitTitle;

  /// No description provided for @deleteHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed and any progress lost.'**
  String deleteHabitMessage(String title);

  /// No description provided for @completionHowDidItLand.
  ///
  /// In en, this message translates to:
  /// **'How was it?'**
  String get completionHowDidItLand;

  /// No description provided for @completionMoodGlad.
  ///
  /// In en, this message translates to:
  /// **'Glad I did'**
  String get completionMoodGlad;

  /// No description provided for @completionMoodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get completionMoodNeutral;

  /// No description provided for @completionMoodTookEffort.
  ///
  /// In en, this message translates to:
  /// **'Took effort'**
  String get completionMoodTookEffort;

  /// No description provided for @completionAddNote.
  ///
  /// In en, this message translates to:
  /// **'add a note'**
  String get completionAddNote;

  /// No description provided for @completionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything you want to remember?'**
  String get completionNoteHint;

  /// No description provided for @completionSkip.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get completionSkip;

  /// No description provided for @completionKept.
  ///
  /// In en, this message translates to:
  /// **'Kept — {count} moments this month.'**
  String completionKept(int count);

  /// No description provided for @completionKeptOne.
  ///
  /// In en, this message translates to:
  /// **'Kept — your first moment this month.'**
  String get completionKeptOne;

  /// No description provided for @notifMsg1.
  ///
  /// In en, this message translates to:
  /// **'No rush today. Even one small thing counts.'**
  String get notifMsg1;

  /// No description provided for @notifMsg2.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to be productive to deserve rest.'**
  String get notifMsg2;

  /// No description provided for @notifMsg3.
  ///
  /// In en, this message translates to:
  /// **'Whatever you do today is enough.'**
  String get notifMsg3;

  /// No description provided for @notifMsg4.
  ///
  /// In en, this message translates to:
  /// **'One small action. That\'s all.'**
  String get notifMsg4;

  /// No description provided for @notifMsg6.
  ///
  /// In en, this message translates to:
  /// **'Today doesn\'t have to be perfect to be good.'**
  String get notifMsg6;

  /// No description provided for @notifMsg8.
  ///
  /// In en, this message translates to:
  /// **'Small steps still move you forward.'**
  String get notifMsg8;

  /// No description provided for @notifMsg9.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to start slow.'**
  String get notifMsg9;

  /// No description provided for @notifMsg10.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing better than you think.'**
  String get notifMsg10;

  /// No description provided for @notifMsg11.
  ///
  /// In en, this message translates to:
  /// **'Progress doesn\'t always look like progress.'**
  String get notifMsg11;

  /// No description provided for @notifMsg13.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to earn rest.'**
  String get notifMsg13;

  /// No description provided for @notifMsg14.
  ///
  /// In en, this message translates to:
  /// **'Kindness to yourself counts as a habit too.'**
  String get notifMsg14;

  /// No description provided for @notifMsg15.
  ///
  /// In en, this message translates to:
  /// **'Today is a new chance, not a test.'**
  String get notifMsg15;

  /// No description provided for @notifMsg16.
  ///
  /// In en, this message translates to:
  /// **'Even a little is better than nothing.'**
  String get notifMsg16;

  /// No description provided for @notifMsg17.
  ///
  /// In en, this message translates to:
  /// **'You\'re still here. That\'s something.'**
  String get notifMsg17;

  /// No description provided for @notifMsg18.
  ///
  /// In en, this message translates to:
  /// **'There\'s no wrong way to have a gentle day.'**
  String get notifMsg18;

  /// No description provided for @notifMsg19.
  ///
  /// In en, this message translates to:
  /// **'Whatever today holds, you can handle it softly.'**
  String get notifMsg19;

  /// No description provided for @notifMsg20.
  ///
  /// In en, this message translates to:
  /// **'Rest is part of the work too.'**
  String get notifMsg20;

  /// No description provided for @notifMsg21.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to do everything. Just one thing.'**
  String get notifMsg21;

  /// No description provided for @notifMsg22.
  ///
  /// In en, this message translates to:
  /// **'Today\'s habits are tomorrow\'s foundation.'**
  String get notifMsg22;

  /// No description provided for @notifMsg23.
  ///
  /// In en, this message translates to:
  /// **'Be patient with yourself today.'**
  String get notifMsg23;

  /// No description provided for @notifMsg24.
  ///
  /// In en, this message translates to:
  /// **'Growth is quiet. Trust it.'**
  String get notifMsg24;

  /// No description provided for @notifMsg25.
  ///
  /// In en, this message translates to:
  /// **'You\'re building something real, slowly.'**
  String get notifMsg25;

  /// No description provided for @notifMsg26.
  ///
  /// In en, this message translates to:
  /// **'One habit. One moment. That\'s enough.'**
  String get notifMsg26;

  /// No description provided for @notifMsg27.
  ///
  /// In en, this message translates to:
  /// **'Check in with yourself today — how are you really?'**
  String get notifMsg27;

  /// No description provided for @notifMsg28.
  ///
  /// In en, this message translates to:
  /// **'You\'ve done hard things before. Today can be gentle.'**
  String get notifMsg28;

  /// No description provided for @notifMsg29.
  ///
  /// In en, this message translates to:
  /// **'Nothing has to be perfect to be worth doing.'**
  String get notifMsg29;

  /// No description provided for @notifMsg30.
  ///
  /// In en, this message translates to:
  /// **'You\'re allowed to take this one step at a time.'**
  String get notifMsg30;

  /// No description provided for @notifMsg31.
  ///
  /// In en, this message translates to:
  /// **'The version of you who started this would be proud.'**
  String get notifMsg31;

  /// No description provided for @notifMsg32.
  ///
  /// In en, this message translates to:
  /// **'Growth is quietest when it\'s most real. Trust the process.'**
  String get notifMsg32;

  /// No description provided for @notifMsg34.
  ///
  /// In en, this message translates to:
  /// **'Small rituals become the shape of a big life.'**
  String get notifMsg34;

  /// No description provided for @notifMsg35.
  ///
  /// In en, this message translates to:
  /// **'You\'re not behind. You\'re exactly where you are.'**
  String get notifMsg35;

  /// No description provided for @notifMsg37.
  ///
  /// In en, this message translates to:
  /// **'You\'re building a relationship with yourself. Take it slow.'**
  String get notifMsg37;

  /// No description provided for @notifMsg38.
  ///
  /// In en, this message translates to:
  /// **'Today\'s small act is next month\'s normal.'**
  String get notifMsg38;

  /// No description provided for @notifMsg39.
  ///
  /// In en, this message translates to:
  /// **'Habits aren\'t about willpower. They\'re about care.'**
  String get notifMsg39;

  /// No description provided for @notifMsg41.
  ///
  /// In en, this message translates to:
  /// **'The goal was never perfection. It was showing up.'**
  String get notifMsg41;

  /// No description provided for @notifMsg42.
  ///
  /// In en, this message translates to:
  /// **'Some days the habit is just being kind to yourself.'**
  String get notifMsg42;

  /// No description provided for @notifMsg44.
  ///
  /// In en, this message translates to:
  /// **'Every gentle choice adds up.'**
  String get notifMsg44;

  /// No description provided for @notifMsg45.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need motivation. You just need one moment.'**
  String get notifMsg45;

  /// No description provided for @notifMsg46.
  ///
  /// In en, this message translates to:
  /// **'Your pace is your own. No comparisons needed.'**
  String get notifMsg46;

  /// No description provided for @notifMsg47.
  ///
  /// In en, this message translates to:
  /// **'The quiet days count just as much.'**
  String get notifMsg47;

  /// No description provided for @notifMsg48.
  ///
  /// In en, this message translates to:
  /// **'You\'re not starting over — you\'re continuing.'**
  String get notifMsg48;

  /// No description provided for @notifMsg49.
  ///
  /// In en, this message translates to:
  /// **'Consistency is kindness applied repeatedly.'**
  String get notifMsg49;

  /// No description provided for @notifMsg50.
  ///
  /// In en, this message translates to:
  /// **'One habit at a time is how lives actually change.'**
  String get notifMsg50;

  /// No description provided for @notifMsg51.
  ///
  /// In en, this message translates to:
  /// **'Today is a good day to be gentle with yourself.'**
  String get notifMsg51;

  /// No description provided for @notifMsg53.
  ///
  /// In en, this message translates to:
  /// **'Small doesn\'t mean insignificant.'**
  String get notifMsg53;

  /// No description provided for @notifMsg54.
  ///
  /// In en, this message translates to:
  /// **'Whatever you do today, do it with care.'**
  String get notifMsg54;

  /// No description provided for @notifMsg55.
  ///
  /// In en, this message translates to:
  /// **'Your habits are an act of self-respect.'**
  String get notifMsg55;

  /// No description provided for @notifMsg56.
  ///
  /// In en, this message translates to:
  /// **'Nothing is lost. You can always begin again.'**
  String get notifMsg56;

  /// No description provided for @notifMsg58.
  ///
  /// In en, this message translates to:
  /// **'Today\'s effort is invisible now and undeniable later.'**
  String get notifMsg58;

  /// No description provided for @notifMsg60.
  ///
  /// In en, this message translates to:
  /// **'This is what taking care of yourself looks like.'**
  String get notifMsg60;

  /// No description provided for @notifWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'Check in with how your week felt. Your habits were there for you.'**
  String get notifWeeklyBody;

  /// No description provided for @notifWeeklyPathGentleMornings.
  ///
  /// In en, this message translates to:
  /// **'Your week of gentle mornings is ready to look back on.'**
  String get notifWeeklyPathGentleMornings;

  /// No description provided for @notifWeeklyPathAnchorsForHardDays.
  ///
  /// In en, this message translates to:
  /// **'A week of holding steady. See how you anchored yourself.'**
  String get notifWeeklyPathAnchorsForHardDays;

  /// No description provided for @notifWeeklyPathQuietFocus.
  ///
  /// In en, this message translates to:
  /// **'A week of quiet focus. See what got done.'**
  String get notifWeeklyPathQuietFocus;

  /// No description provided for @notifWeeklyPathWindingDown.
  ///
  /// In en, this message translates to:
  /// **'A week of winding down. Take a moment to look back.'**
  String get notifWeeklyPathWindingDown;

  /// No description provided for @notifWeeklyPathYourOwnWay.
  ///
  /// In en, this message translates to:
  /// **'Your week is ready to reflect on. See what showed up.'**
  String get notifWeeklyPathYourOwnWay;

  /// No description provided for @notifDailyChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get notifDailyChannelName;

  /// No description provided for @notifDailyChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Gentle daily habit reminders'**
  String get notifDailyChannelDesc;

  /// No description provided for @notifWeeklyChannelName.
  ///
  /// In en, this message translates to:
  /// **'Weekly Reminders'**
  String get notifWeeklyChannelName;

  /// No description provided for @notifWeeklyChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Weekly reflection reminders'**
  String get notifWeeklyChannelDesc;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Get the full Intended experience'**
  String get paywallTitle;

  /// No description provided for @paywallTitleGentleMornings.
  ///
  /// In en, this message translates to:
  /// **'Make your mornings even gentler'**
  String get paywallTitleGentleMornings;

  /// No description provided for @paywallTitleAnchorsForHardDays.
  ///
  /// In en, this message translates to:
  /// **'More anchors for the hard days'**
  String get paywallTitleAnchorsForHardDays;

  /// No description provided for @paywallTitleQuietFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus that lasts'**
  String get paywallTitleQuietFocus;

  /// No description provided for @paywallTitleWindingDown.
  ///
  /// In en, this message translates to:
  /// **'An even gentler way to wind down'**
  String get paywallTitleWindingDown;

  /// No description provided for @paywallDescription.
  ///
  /// In en, this message translates to:
  /// **'Intended+ turns your daily practice into lasting self-knowledge.'**
  String get paywallDescription;

  /// No description provided for @paywallCeilingTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re building something good'**
  String get paywallCeilingTitle;

  /// No description provided for @paywallCeilingDescription.
  ///
  /// In en, this message translates to:
  /// **'Intended+ gives you room to grow. But the free version always has what you need.'**
  String get paywallCeilingDescription;

  /// No description provided for @paywallFeature1.
  ///
  /// In en, this message translates to:
  /// **'A letter about your month — four lines that end in a question worth keeping'**
  String get paywallFeature1;

  /// No description provided for @paywallFeature2.
  ///
  /// In en, this message translates to:
  /// **'Next month\'s plan from this month\'s evidence — and whether it worked, measured'**
  String get paywallFeature2;

  /// No description provided for @paywallFeature3.
  ///
  /// In en, this message translates to:
  /// **'The drift warning: a quiet word before the gap, not after it'**
  String get paywallFeature3;

  /// No description provided for @paywallFeature4.
  ///
  /// In en, this message translates to:
  /// **'All ten themes, premium icons and home-screen widgets'**
  String get paywallFeature4;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€5.99'**
  String get paywallMonthlyPrice;

  /// No description provided for @paywallMonthlyPeriod.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get paywallMonthlyPeriod;

  /// No description provided for @paywallYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paywallYearly;

  /// No description provided for @paywallYearlyPrice.
  ///
  /// In en, this message translates to:
  /// **'€44.99'**
  String get paywallYearlyPrice;

  /// No description provided for @paywallYearlyPeriod.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get paywallYearlyPeriod;

  /// Price with its billing period. Russian cannot take a slashed adverb, so each locale spells this itself — never build it by lowercasing the plan label.
  ///
  /// In en, this message translates to:
  /// **'{price}/year'**
  String paywallPricePerYear(String price);

  /// See paywallPricePerYear.
  ///
  /// In en, this message translates to:
  /// **'{price}/month'**
  String paywallPricePerMonth(String price);

  /// No description provided for @paywallYearlyAnchor.
  ///
  /// In en, this message translates to:
  /// **'{price}/month, billed yearly'**
  String paywallYearlyAnchor(String price);

  /// No description provided for @paywallSavePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String paywallSavePercent(int percent);

  /// No description provided for @paywallLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get paywallLifetime;

  /// No description provided for @paywallLifetimePrice.
  ///
  /// In en, this message translates to:
  /// **'€49.99'**
  String get paywallLifetimePrice;

  /// No description provided for @paywallLifetimePeriod.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get paywallLifetimePeriod;

  /// No description provided for @paywallCtaTrial.
  ///
  /// In en, this message translates to:
  /// **'Start {days}-day free trial'**
  String paywallCtaTrial(int days);

  /// No description provided for @paywallCtaLifetime.
  ///
  /// In en, this message translates to:
  /// **'Get lifetime access'**
  String get paywallCtaLifetime;

  /// First line of the trial timeline. {price} is the store's own formatted price for the free intro offer, e.g. $0.00.
  ///
  /// In en, this message translates to:
  /// **'Today — {price}. Full access, nothing charged.'**
  String paywallTimelineToday(String price);

  /// Second line of the trial timeline for the yearly plan. Billing period is spelled per locale — never glue the price to the plan label.
  ///
  /// In en, this message translates to:
  /// **'Day {days} — {price}/year, renews automatically unless you cancel.'**
  String paywallTimelineRenewsYearly(int days, String price);

  /// Second line of the trial timeline for the monthly plan.
  ///
  /// In en, this message translates to:
  /// **'Day {days} — {price}/month, renews automatically unless you cancel.'**
  String paywallTimelineRenewsMonthly(int days, String price);

  /// No description provided for @paywallTimelineCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime in Settings.'**
  String get paywallTimelineCancel;

  /// No description provided for @paywallLifetimeHint.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. No subscription.'**
  String get paywallLifetimeHint;

  /// Inline line under the purchase button when offerings could not be loaded. The button itself becomes the retry.
  ///
  /// In en, this message translates to:
  /// **'Prices didn\'t load. Try again.'**
  String get paywallPricesUnavailable;

  /// No description provided for @paywallRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get paywallRetry;

  /// Purchase button for a subscription plan whose store product has no free intro offer — no trial is claimed.
  ///
  /// In en, this message translates to:
  /// **'Continue with Intended+'**
  String get paywallCtaSubscribe;

  /// Disclaimer for the yearly plan when the store reports no free trial. Billing period is spelled per locale.
  ///
  /// In en, this message translates to:
  /// **'{price}/year. Renews automatically until you cancel.'**
  String paywallHintYearlyNoTrial(String price);

  /// Disclaimer for the monthly plan when the store reports no free trial. Billing period is spelled per locale.
  ///
  /// In en, this message translates to:
  /// **'{price}/month. Renews automatically until you cancel.'**
  String paywallHintMonthlyNoTrial(String price);

  /// No description provided for @paywallContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue with Core'**
  String get paywallContinueFree;

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases. Please try again.'**
  String get restoreError;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get paywallTerms;

  /// No description provided for @paywallPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get paywallPrivacy;

  /// No description provided for @paywallFooter.
  ///
  /// In en, this message translates to:
  /// **'New features added regularly. Your subscription supports independent development.\nBuilt by one person who cares about this as much as you do.'**
  String get paywallFooter;

  /// No description provided for @onboardingPaywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Intended+ reads your months'**
  String get onboardingPaywallTitle;

  /// No description provided for @onboardingPaywallPrimaryCta.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get onboardingPaywallPrimaryCta;

  /// No description provided for @onboardingPaywallSecondaryCta.
  ///
  /// In en, this message translates to:
  /// **'Not now — keep the free version'**
  String get onboardingPaywallSecondaryCta;

  /// The onboarding disclaimer when the store reports no free trial on the yearly plan.
  ///
  /// In en, this message translates to:
  /// **'{price}/year — about {perMonth} a month. Renews automatically until you cancel.'**
  String onboardingPaywallDisclaimerNoTrial(String price, String perMonth);

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Intended+'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionSupporter.
  ///
  /// In en, this message translates to:
  /// **'You\'re a supporter ♥'**
  String get subscriptionSupporter;

  /// No description provided for @subscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get subscriptionPlan;

  /// No description provided for @subscriptionPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get subscriptionPrice;

  /// No description provided for @subscriptionRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get subscriptionRenews;

  /// No description provided for @subscriptionThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Intended.\nYou\'re helping us build a kinder\nalternative to hustle culture.'**
  String get subscriptionThankYou;

  /// No description provided for @subscriptionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage in App Store'**
  String get subscriptionManage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNameError.
  ///
  /// In en, this message translates to:
  /// **'Hmm'**
  String get profileNameError;

  /// No description provided for @profileNameErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please choose a different name'**
  String get profileNameErrorMessage;

  /// No description provided for @profileYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileYourName;

  /// No description provided for @profileAddName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get profileAddName;

  /// No description provided for @profileEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileEnterName;

  /// No description provided for @profilePlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get profilePlan;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManage;

  /// No description provided for @profileUnlockPlus.
  ///
  /// In en, this message translates to:
  /// **'Try Intended+'**
  String get profileUnlockPlus;

  /// No description provided for @profileFocusAreas.
  ///
  /// In en, this message translates to:
  /// **'Focus areas'**
  String get profileFocusAreas;

  /// No description provided for @profileMomentsNone.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get profileMomentsNone;

  /// No description provided for @profileMomentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 moment} other{{count} moments}}'**
  String profileMomentsCount(int count);

  /// No description provided for @profileYourPath.
  ///
  /// In en, this message translates to:
  /// **'Your path'**
  String get profileYourPath;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get profileSettings;

  /// No description provided for @profileDailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get profileDailyReminders;

  /// No description provided for @profileRemindAt.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get profileRemindAt;

  /// No description provided for @profileWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get profileWeeklySummary;

  /// No description provided for @profileWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every Sunday morning'**
  String get profileWeeklySubtitle;

  /// No description provided for @profileNotifDenied.
  ///
  /// In en, this message translates to:
  /// **'No worries — you can enable notifications in your device Settings.'**
  String get profileNotifDenied;

  /// No description provided for @profileNotifDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications Disabled'**
  String get profileNotifDeniedTitle;

  /// No description provided for @profileNotifDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'To enable reminders, please turn on notifications for Intended in your device Settings.'**
  String get profileNotifDeniedMessage;

  /// No description provided for @profileNotifOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get profileNotifOpenSettings;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get profileSupport;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Intended'**
  String get profileRateApp;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacy;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get profileTerms;

  /// No description provided for @profileConnectAccount.
  ///
  /// In en, this message translates to:
  /// **'CONNECT ACCOUNT'**
  String get profileConnectAccount;

  /// No description provided for @profileSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get profileSignInGoogle;

  /// No description provided for @profileSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get profileSignInApple;

  /// No description provided for @profileSignedInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get profileSignedInGoogle;

  /// No description provided for @profileSignedInApple.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Apple'**
  String get profileSignedInApple;

  /// No description provided for @signOutWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutWarningTitle;

  /// No description provided for @signOutWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device only. You won\'t be able to access it on other devices or after reinstalling.'**
  String get signOutWarningMessage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete account & data'**
  String get profileDeleteData;

  /// Version label at the foot of the profile; {version} is the live bundle version from package_info_plus.
  ///
  /// In en, this message translates to:
  /// **'Intended v{version}'**
  String profileVersion(String version);

  /// No description provided for @profileTesterModeOn.
  ///
  /// In en, this message translates to:
  /// **'Tester mode on'**
  String get profileTesterModeOn;

  /// No description provided for @profileTesterModeOff.
  ///
  /// In en, this message translates to:
  /// **'Tester mode off'**
  String get profileTesterModeOff;

  /// No description provided for @profileCannotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Cannot open email'**
  String get profileCannotOpenEmail;

  /// No description provided for @profileEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'Please email us at\nsupport@intendedapp.com'**
  String get profileEmailFallback;

  /// No description provided for @profileChangeFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Change focus areas?'**
  String get profileChangeFocusTitle;

  /// No description provided for @profileChangeFocusMessage.
  ///
  /// In en, this message translates to:
  /// **'Your habits will refresh based on new areas.'**
  String get profileChangeFocusMessage;

  /// No description provided for @profileChangeAreas.
  ///
  /// In en, this message translates to:
  /// **'Change areas'**
  String get profileChangeAreas;

  /// No description provided for @profileChangeSpace.
  ///
  /// In en, this message translates to:
  /// **'Change your space'**
  String get profileChangeSpace;

  /// No description provided for @profileCannotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Cannot open link'**
  String get profileCannotOpenLink;

  /// No description provided for @profilePrivacyFallback.
  ///
  /// In en, this message translates to:
  /// **'Please visit intendedapp.com/privacy in your browser'**
  String get profilePrivacyFallback;

  /// No description provided for @profileTermsFallback.
  ///
  /// In en, this message translates to:
  /// **'Please visit intendedapp.com/terms in your browser'**
  String get profileTermsFallback;

  /// No description provided for @profileDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get profileDeleteAllTitle;

  /// No description provided for @profileDeleteAllMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your habits, progress, and settings. This action cannot be undone.'**
  String get profileDeleteAllMessage;

  /// No description provided for @profileDeleteErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get profileDeleteErrorMessage;

  /// No description provided for @profileReauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get profileReauthTitle;

  /// No description provided for @profileReauthMessage.
  ///
  /// In en, this message translates to:
  /// **'For security, please sign in again to confirm account deletion.'**
  String get profileReauthMessage;

  /// No description provided for @profileReauthButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileReauthButton;

  /// No description provided for @profileChangeFocusAreasScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Focus Areas'**
  String get profileChangeFocusAreasScreenTitle;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @themeWarmClay.
  ///
  /// In en, this message translates to:
  /// **'Warm Clay'**
  String get themeWarmClay;

  /// No description provided for @themeIris.
  ///
  /// In en, this message translates to:
  /// **'Iris'**
  String get themeIris;

  /// No description provided for @themeClearSky.
  ///
  /// In en, this message translates to:
  /// **'Clear Sky'**
  String get themeClearSky;

  /// No description provided for @themeMorningSlate.
  ///
  /// In en, this message translates to:
  /// **'Morning Slate'**
  String get themeMorningSlate;

  /// No description provided for @themeSoftDusk.
  ///
  /// In en, this message translates to:
  /// **'Soft Dusk'**
  String get themeSoftDusk;

  /// No description provided for @themeDeepFocus.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus'**
  String get themeDeepFocus;

  /// No description provided for @themeForestFloor.
  ///
  /// In en, this message translates to:
  /// **'Forest Floor'**
  String get themeForestFloor;

  /// No description provided for @themeGoldenHour.
  ///
  /// In en, this message translates to:
  /// **'Golden Hour'**
  String get themeGoldenHour;

  /// No description provided for @themeNightBloom.
  ///
  /// In en, this message translates to:
  /// **'Night Bloom'**
  String get themeNightBloom;

  /// No description provided for @themeSandDune.
  ///
  /// In en, this message translates to:
  /// **'Sand Dune'**
  String get themeSandDune;

  /// No description provided for @habitDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink 3 glasses of water'**
  String get habitDrinkWater;

  /// No description provided for @habitThreeSlowBreaths.
  ///
  /// In en, this message translates to:
  /// **'Take 3 slow breaths'**
  String get habitThreeSlowBreaths;

  /// No description provided for @habitStretchTenSeconds.
  ///
  /// In en, this message translates to:
  /// **'Stretch for 30 seconds'**
  String get habitStretchTenSeconds;

  /// No description provided for @habitRollShoulders.
  ///
  /// In en, this message translates to:
  /// **'Stand up and roll your shoulders'**
  String get habitRollShoulders;

  /// No description provided for @habitStepOutside.
  ///
  /// In en, this message translates to:
  /// **'Step outside for 5 minutes'**
  String get habitStepOutside;

  /// No description provided for @habitCloseEyes.
  ///
  /// In en, this message translates to:
  /// **'Close your eyes for 30 seconds'**
  String get habitCloseEyes;

  /// No description provided for @habitCheckBalance.
  ///
  /// In en, this message translates to:
  /// **'Check your balance'**
  String get habitCheckBalance;

  /// No description provided for @habitReviewBill.
  ///
  /// In en, this message translates to:
  /// **'Review one bill'**
  String get habitReviewBill;

  /// No description provided for @habitReviewSubscription.
  ///
  /// In en, this message translates to:
  /// **'Review one subscription'**
  String get habitReviewSubscription;

  /// No description provided for @habitNoteExpense.
  ///
  /// In en, this message translates to:
  /// **'Note one expense'**
  String get habitNoteExpense;

  /// No description provided for @habitMoveToSavings.
  ///
  /// In en, this message translates to:
  /// **'Move €1 to savings'**
  String get habitMoveToSavings;

  /// No description provided for @habitSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Set one small savings goal'**
  String get habitSavingsGoal;

  /// No description provided for @habitUpdateBudget.
  ///
  /// In en, this message translates to:
  /// **'Update one budget category'**
  String get habitUpdateBudget;

  /// No description provided for @habitDeleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete one old receipt'**
  String get habitDeleteReceipt;

  /// No description provided for @habitFinancialTip.
  ///
  /// In en, this message translates to:
  /// **'Read one financial tip'**
  String get habitFinancialTip;

  /// No description provided for @habitMoneyWin.
  ///
  /// In en, this message translates to:
  /// **'Celebrate one money win'**
  String get habitMoneyWin;

  /// No description provided for @habitPriceCheck.
  ///
  /// In en, this message translates to:
  /// **'Price-check one item before buying'**
  String get habitPriceCheck;

  /// No description provided for @habitWait24Hours.
  ///
  /// In en, this message translates to:
  /// **'Wait 24 hours before one purchase'**
  String get habitWait24Hours;

  /// No description provided for @habitSetPriority.
  ///
  /// In en, this message translates to:
  /// **'Set one priority'**
  String get habitSetPriority;

  /// No description provided for @habitFinishTinyTask.
  ///
  /// In en, this message translates to:
  /// **'Finish one tiny task'**
  String get habitFinishTinyTask;

  /// No description provided for @habitCloseTab.
  ///
  /// In en, this message translates to:
  /// **'Close one browser tab'**
  String get habitCloseTab;

  /// No description provided for @habitTurnOffNotification.
  ///
  /// In en, this message translates to:
  /// **'Turn off one notification'**
  String get habitTurnOffNotification;

  /// No description provided for @habitArchiveEmails.
  ///
  /// In en, this message translates to:
  /// **'Archive 5 old emails'**
  String get habitArchiveEmails;

  /// No description provided for @habitReviewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Review your calendar'**
  String get habitReviewCalendar;

  /// No description provided for @habitUpdateTodo.
  ///
  /// In en, this message translates to:
  /// **'Update one to-do item'**
  String get habitUpdateTodo;

  /// No description provided for @habitDeclutterDesk.
  ///
  /// In en, this message translates to:
  /// **'Declutter your desk for 2 minutes'**
  String get habitDeclutterDesk;

  /// No description provided for @habitRearrangeSmall.
  ///
  /// In en, this message translates to:
  /// **'Rearrange something small'**
  String get habitRearrangeSmall;

  /// No description provided for @habitWriteOneSentence.
  ///
  /// In en, this message translates to:
  /// **'Write one sentence'**
  String get habitWriteOneSentence;

  /// No description provided for @habitWriteIdea.
  ///
  /// In en, this message translates to:
  /// **'Write down one idea'**
  String get habitWriteIdea;

  /// No description provided for @habitCaptureIdea.
  ///
  /// In en, this message translates to:
  /// **'Capture one idea'**
  String get habitCaptureIdea;

  /// No description provided for @habitDrawShape.
  ///
  /// In en, this message translates to:
  /// **'Draw one simple shape'**
  String get habitDrawShape;

  /// No description provided for @habitCreateTinyThing.
  ///
  /// In en, this message translates to:
  /// **'Create one tiny thing'**
  String get habitCreateTinyThing;

  /// No description provided for @habitCreativeMedium.
  ///
  /// In en, this message translates to:
  /// **'Play with one creative medium'**
  String get habitCreativeMedium;

  /// No description provided for @habitImaginePossibility.
  ///
  /// In en, this message translates to:
  /// **'Imagine one possibility'**
  String get habitImaginePossibility;

  /// No description provided for @habitNeckRolls.
  ///
  /// In en, this message translates to:
  /// **'Do 5 gentle neck rolls'**
  String get habitNeckRolls;

  /// No description provided for @habitWalkToWindow.
  ///
  /// In en, this message translates to:
  /// **'Walk to the window and back'**
  String get habitWalkToWindow;

  /// No description provided for @habitBellyBreaths.
  ///
  /// In en, this message translates to:
  /// **'Take 5 slow, deep breaths'**
  String get habitBellyBreaths;

  /// No description provided for @habitBodyScan.
  ///
  /// In en, this message translates to:
  /// **'2-minute body scan'**
  String get habitBodyScan;

  /// No description provided for @habitGentleMovement.
  ///
  /// In en, this message translates to:
  /// **'5 minutes of gentle stretching'**
  String get habitGentleMovement;

  /// No description provided for @habitMindfulMeal.
  ///
  /// In en, this message translates to:
  /// **'Eat one meal mindfully'**
  String get habitMindfulMeal;

  /// No description provided for @habitEatAfterWaking.
  ///
  /// In en, this message translates to:
  /// **'Eat after waking up'**
  String get habitEatAfterWaking;

  /// No description provided for @habitProperMeal.
  ///
  /// In en, this message translates to:
  /// **'Eat one proper meal'**
  String get habitProperMeal;

  /// No description provided for @habitDrinkWarm.
  ///
  /// In en, this message translates to:
  /// **'Drink something warm'**
  String get habitDrinkWarm;

  /// No description provided for @habitTakeMedication.
  ///
  /// In en, this message translates to:
  /// **'Take your medication'**
  String get habitTakeMedication;

  /// No description provided for @habitGetOutside.
  ///
  /// In en, this message translates to:
  /// **'Get outside for a few minutes'**
  String get habitGetOutside;

  /// No description provided for @habitMoveBody.
  ///
  /// In en, this message translates to:
  /// **'Move your body a little'**
  String get habitMoveBody;

  /// No description provided for @habitBedEarly.
  ///
  /// In en, this message translates to:
  /// **'Get into bed early'**
  String get habitBedEarly;

  /// No description provided for @habitTenSecondPause.
  ///
  /// In en, this message translates to:
  /// **'One-minute pause'**
  String get habitTenSecondPause;

  /// No description provided for @habitNoticeFeeling.
  ///
  /// In en, this message translates to:
  /// **'Notice one thing you feel'**
  String get habitNoticeFeeling;

  /// No description provided for @habitGroundingBreath.
  ///
  /// In en, this message translates to:
  /// **'Three grounding breaths'**
  String get habitGroundingBreath;

  /// No description provided for @habitLookAway.
  ///
  /// In en, this message translates to:
  /// **'Look away from your screen for 30 seconds'**
  String get habitLookAway;

  /// No description provided for @habitNameThreeThings.
  ///
  /// In en, this message translates to:
  /// **'Name three things you can see'**
  String get habitNameThreeThings;

  /// No description provided for @habitNoticeSound.
  ///
  /// In en, this message translates to:
  /// **'Notice one sound around you'**
  String get habitNoticeSound;

  /// No description provided for @habitFeelFeet.
  ///
  /// In en, this message translates to:
  /// **'Feel your feet on the ground'**
  String get habitFeelFeet;

  /// No description provided for @habitHandOnHeart.
  ///
  /// In en, this message translates to:
  /// **'Place hand on heart for 30 seconds'**
  String get habitHandOnHeart;

  /// No description provided for @habitGratefulThing.
  ///
  /// In en, this message translates to:
  /// **'Name 3 things you\'re grateful for'**
  String get habitGratefulThing;

  /// No description provided for @habitSmileGently.
  ///
  /// In en, this message translates to:
  /// **'Smile kindly at yourself'**
  String get habitSmileGently;

  /// No description provided for @habitAskNeed.
  ///
  /// In en, this message translates to:
  /// **'Ask yourself \"what do I need right now?\"'**
  String get habitAskNeed;

  /// No description provided for @habitPermissionToRest.
  ///
  /// In en, this message translates to:
  /// **'Give yourself permission to rest'**
  String get habitPermissionToRest;

  /// No description provided for @habitPlanTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow in one sentence'**
  String get habitPlanTomorrow;

  /// No description provided for @habitThirtySecondReset.
  ///
  /// In en, this message translates to:
  /// **'Do a 1-minute reset'**
  String get habitThirtySecondReset;

  /// No description provided for @habitTidyOneThing.
  ///
  /// In en, this message translates to:
  /// **'Tidy one small thing'**
  String get habitTidyOneThing;

  /// No description provided for @habitPutBack.
  ///
  /// In en, this message translates to:
  /// **'Put one thing back where it belongs'**
  String get habitPutBack;

  /// No description provided for @habitWipeSurface.
  ///
  /// In en, this message translates to:
  /// **'Wipe one surface'**
  String get habitWipeSurface;

  /// No description provided for @habitFreshAir.
  ///
  /// In en, this message translates to:
  /// **'Open a window for fresh air'**
  String get habitFreshAir;

  /// No description provided for @habitMakeBed.
  ///
  /// In en, this message translates to:
  /// **'Make your bed'**
  String get habitMakeBed;

  /// No description provided for @habitClearShelf.
  ///
  /// In en, this message translates to:
  /// **'Clear one shelf'**
  String get habitClearShelf;

  /// No description provided for @habitWashDishes.
  ///
  /// In en, this message translates to:
  /// **'Wash 3 dishes'**
  String get habitWashDishes;

  /// No description provided for @habitTakeOutTrash.
  ///
  /// In en, this message translates to:
  /// **'Take out one bag of trash'**
  String get habitTakeOutTrash;

  /// No description provided for @habitFoldClothing.
  ///
  /// In en, this message translates to:
  /// **'Fold 3 items of clothing'**
  String get habitFoldClothing;

  /// No description provided for @habitOrganizeDrawer.
  ///
  /// In en, this message translates to:
  /// **'Organize one drawer'**
  String get habitOrganizeDrawer;

  /// No description provided for @habitWaterPlant.
  ///
  /// In en, this message translates to:
  /// **'Water your plants'**
  String get habitWaterPlant;

  /// No description provided for @habitLightCandle.
  ///
  /// In en, this message translates to:
  /// **'Light a scented candle'**
  String get habitLightCandle;

  /// No description provided for @habitSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send one message to someone you care about'**
  String get habitSendMessage;

  /// No description provided for @habitAppreciatePerson.
  ///
  /// In en, this message translates to:
  /// **'Think of one person you appreciate'**
  String get habitAppreciatePerson;

  /// No description provided for @habitAskHowAreYou.
  ///
  /// In en, this message translates to:
  /// **'Ask someone how they are'**
  String get habitAskHowAreYou;

  /// No description provided for @habitGiveCompliment.
  ///
  /// In en, this message translates to:
  /// **'Give one genuine compliment'**
  String get habitGiveCompliment;

  /// No description provided for @habitCallSomeone.
  ///
  /// In en, this message translates to:
  /// **'Call someone you care about'**
  String get habitCallSomeone;

  /// No description provided for @habitShareSmile.
  ///
  /// In en, this message translates to:
  /// **'Share something that made you smile'**
  String get habitShareSmile;

  /// No description provided for @habitThankSomeone.
  ///
  /// In en, this message translates to:
  /// **'Thank someone today'**
  String get habitThankSomeone;

  /// No description provided for @habitListenFully.
  ///
  /// In en, this message translates to:
  /// **'Listen without planning your response'**
  String get habitListenFully;

  /// No description provided for @habitReachOut.
  ///
  /// In en, this message translates to:
  /// **'Reach out to someone you miss'**
  String get habitReachOut;

  /// No description provided for @habitTellMeaning.
  ///
  /// In en, this message translates to:
  /// **'Tell someone what they mean to you'**
  String get habitTellMeaning;

  /// No description provided for @habitOfferHelp.
  ///
  /// In en, this message translates to:
  /// **'Offer help to someone'**
  String get habitOfferHelp;

  /// No description provided for @habitCelebrateOthers.
  ///
  /// In en, this message translates to:
  /// **'Celebrate someone else\'s win'**
  String get habitCelebrateOthers;

  /// No description provided for @habitWriteSentence.
  ///
  /// In en, this message translates to:
  /// **'Write down what\'s in your head'**
  String get habitWriteSentence;

  /// No description provided for @habitDoodle.
  ///
  /// In en, this message translates to:
  /// **'Doodle for 5 minutes'**
  String get habitDoodle;

  /// No description provided for @habitNoticeBeauty.
  ///
  /// In en, this message translates to:
  /// **'Notice one beautiful thing'**
  String get habitNoticeBeauty;

  /// No description provided for @habitTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take one photo of something you like'**
  String get habitTakePhoto;

  /// No description provided for @habitHumTune.
  ///
  /// In en, this message translates to:
  /// **'Hum a tune you enjoy'**
  String get habitHumTune;

  /// No description provided for @habitTryNewWord.
  ///
  /// In en, this message translates to:
  /// **'Learn one new word'**
  String get habitTryNewWord;

  /// No description provided for @habitSitStill.
  ///
  /// In en, this message translates to:
  /// **'Sit still for 1 minute'**
  String get habitSitStill;

  /// No description provided for @habitKindThing.
  ///
  /// In en, this message translates to:
  /// **'Do one kind thing for yourself'**
  String get habitKindThing;

  /// No description provided for @habitDrinkSlowly.
  ///
  /// In en, this message translates to:
  /// **'Drink a cup of tasty coffee'**
  String get habitDrinkSlowly;

  /// No description provided for @habitStretchNeck.
  ///
  /// In en, this message translates to:
  /// **'Stretch your neck'**
  String get habitStretchNeck;

  /// No description provided for @habitOneSlowBreath.
  ///
  /// In en, this message translates to:
  /// **'Take one slow breath'**
  String get habitOneSlowBreath;

  /// No description provided for @habitNoticeLikeAboutSelf.
  ///
  /// In en, this message translates to:
  /// **'Notice something you like about yourself'**
  String get habitNoticeLikeAboutSelf;

  /// No description provided for @habitPermissionSayNo.
  ///
  /// In en, this message translates to:
  /// **'Give yourself permission to say no'**
  String get habitPermissionSayNo;

  /// No description provided for @habitFeelGood.
  ///
  /// In en, this message translates to:
  /// **'Do something that feels good'**
  String get habitFeelGood;

  /// No description provided for @habitRestTwoMinutes.
  ///
  /// In en, this message translates to:
  /// **'Rest for 5 minutes'**
  String get habitRestTwoMinutes;

  /// No description provided for @habitPutOnComfortable.
  ///
  /// In en, this message translates to:
  /// **'Put on something comfortable'**
  String get habitPutOnComfortable;

  /// No description provided for @habitListenToSong.
  ///
  /// In en, this message translates to:
  /// **'Listen to one song you love'**
  String get habitListenToSong;

  /// No description provided for @habitDoNothing.
  ///
  /// In en, this message translates to:
  /// **'Do absolutely nothing for 5 minutes'**
  String get habitDoNothing;

  /// No description provided for @habitGetOutOfBed.
  ///
  /// In en, this message translates to:
  /// **'Get out of bed'**
  String get habitGetOutOfBed;

  /// No description provided for @habitBrushTeeth.
  ///
  /// In en, this message translates to:
  /// **'Brush your teeth'**
  String get habitBrushTeeth;

  /// No description provided for @habitWashFace.
  ///
  /// In en, this message translates to:
  /// **'Wash your face'**
  String get habitWashFace;

  /// No description provided for @habitTakeShower.
  ///
  /// In en, this message translates to:
  /// **'Take a shower'**
  String get habitTakeShower;

  /// No description provided for @habitCleanClothes.
  ///
  /// In en, this message translates to:
  /// **'Put on clean clothes'**
  String get habitCleanClothes;

  /// No description provided for @habitBrushHair.
  ///
  /// In en, this message translates to:
  /// **'Brush your hair'**
  String get habitBrushHair;

  /// No description provided for @habitOpenCurtains.
  ///
  /// In en, this message translates to:
  /// **'Open the curtains'**
  String get habitOpenCurtains;

  /// No description provided for @habitTurnOnLamp.
  ///
  /// In en, this message translates to:
  /// **'Turn on a lamp'**
  String get habitTurnOnLamp;

  /// No description provided for @habitPhoneAcrossRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave your phone across the room'**
  String get habitPhoneAcrossRoom;

  /// No description provided for @shareCardTagline.
  ///
  /// In en, this message translates to:
  /// **'intention, not perfection'**
  String get shareCardTagline;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @boostGoUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Want more? Go unlimited with Intended+'**
  String get boostGoUnlimited;

  /// No description provided for @boostPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with the purchase. Please try again.'**
  String get boostPurchaseError;

  /// No description provided for @boostOfferHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Want one more habit?'**
  String get boostOfferHabitTitle;

  /// No description provided for @boostOfferHabitDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'re building something meaningful — give yourself room for one more.'**
  String get boostOfferHabitDesc;

  /// No description provided for @boostOfferFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Need another focus area?'**
  String get boostOfferFocusTitle;

  /// No description provided for @boostOfferFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Your growth doesn\'t fit in a box? Expand what you focus on.'**
  String get boostOfferFocusDesc;

  /// No description provided for @boostOfferSwapTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of swaps this month?'**
  String get boostOfferSwapTitle;

  /// No description provided for @boostOfferSwapDesc.
  ///
  /// In en, this message translates to:
  /// **'Finding the right habits takes exploring — get a few more tries.'**
  String get boostOfferSwapDesc;

  /// No description provided for @boostOfferThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock both dark themes'**
  String get boostOfferThemeTitle;

  /// No description provided for @boostOfferThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus and Night Bloom — a calmer look for evening check-ins.'**
  String get boostOfferThemeDesc;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @focusLimitFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus area limit reached'**
  String get focusLimitFreeTitle;

  /// No description provided for @focusLimitFreeMessage.
  ///
  /// In en, this message translates to:
  /// **'Free plan includes 1 focus area. Upgrade to unlock more.'**
  String get focusLimitFreeMessage;

  /// No description provided for @focusLimitFreeUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get focusLimitFreeUpgrade;

  /// No description provided for @focusNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Less is more'**
  String get focusNudgeTitle;

  /// No description provided for @focusNudgeMessage.
  ///
  /// In en, this message translates to:
  /// **'Focus on one area at a time for the best results.'**
  String get focusNudgeMessage;

  /// No description provided for @focusNudgeGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get focusNudgeGotIt;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored!'**
  String get restoreSuccess;

  /// No description provided for @restoreNotFound.
  ///
  /// In en, this message translates to:
  /// **'No purchases found.'**
  String get restoreNotFound;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'We found your data from a previous session. Would you like to restore it?'**
  String get restoreBackupMessage;

  /// No description provided for @restoreBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore my data'**
  String get restoreBackupConfirm;

  /// No description provided for @restoreBackupSkip.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get restoreBackupSkip;

  /// No description provided for @profileBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Backed up {time}'**
  String profileBackedUp(Object time);

  /// No description provided for @profileBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get profileBackupNow;

  /// No description provided for @profileBackingUp.
  ///
  /// In en, this message translates to:
  /// **'Backing up…'**
  String get profileBackingUp;

  /// No description provided for @profileBackedUpNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is backed up to your account.'**
  String get profileBackedUpNote;

  /// No description provided for @profileLocalDataNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on this device only. Sign in to back it up.'**
  String get profileLocalDataNote;

  /// No description provided for @onboardingAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get onboardingAlreadyHaveAccount;

  /// No description provided for @onboardingSignInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get onboardingSignInWithApple;

  /// No description provided for @onboardingSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get onboardingSignInWithGoogle;

  /// No description provided for @onboardingPhilosophyLabel.
  ///
  /// In en, this message translates to:
  /// **'Before we begin'**
  String get onboardingPhilosophyLabel;

  /// No description provided for @onboardingPhilosophyHeading.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a tracker.\nIt\'s a return to yourself.'**
  String get onboardingPhilosophyHeading;

  /// No description provided for @onboardingPhilosophyBody.
  ///
  /// In en, this message translates to:
  /// **'No streaks to maintain. No guilt for skipping.\nYour progress never resets. One small intention is enough.'**
  String get onboardingPhilosophyBody;

  /// No description provided for @onboardingPhilosophyCta.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get onboardingPhilosophyCta;

  /// No description provided for @tipGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tipGotIt;

  /// No description provided for @packGentleMorningsName.
  ///
  /// In en, this message translates to:
  /// **'Gentle Mornings'**
  String get packGentleMorningsName;

  /// No description provided for @packGentleMorningsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A small morning ritual that doesn\'t feel like a 5am hustle routine'**
  String get packGentleMorningsSubtitle;

  /// No description provided for @packWindingDownName.
  ///
  /// In en, this message translates to:
  /// **'Winding Down'**
  String get packWindingDownName;

  /// No description provided for @packWindingDownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An evening decompression set. Intentionally short.'**
  String get packWindingDownSubtitle;

  /// No description provided for @packTinyResetsName.
  ///
  /// In en, this message translates to:
  /// **'Tiny Resets'**
  String get packTinyResetsName;

  /// No description provided for @packTinyResetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For mid-week moments when everything feels chaotic'**
  String get packTinyResetsSubtitle;

  /// No description provided for @packCreativeSparkName.
  ///
  /// In en, this message translates to:
  /// **'Creative Spark'**
  String get packCreativeSparkName;

  /// No description provided for @packCreativeSparkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small acts of making. No talent required.'**
  String get packCreativeSparkSubtitle;

  /// No description provided for @packStayConnectedName.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected'**
  String get packStayConnectedName;

  /// No description provided for @packStayConnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The people who matter, one small gesture at a time.'**
  String get packStayConnectedSubtitle;

  /// No description provided for @appIconSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'APP ICON'**
  String get appIconSectionTitle;

  /// No description provided for @appIconDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get appIconDefault;

  /// No description provided for @appIconMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get appIconMidnight;

  /// No description provided for @appIconRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get appIconRose;

  /// No description provided for @appIconForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get appIconForest;

  /// No description provided for @appIconSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get appIconSky;

  /// No description provided for @legalDisclaimerPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get legalDisclaimerPrefix;

  /// No description provided for @legalDisclaimerTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get legalDisclaimerTerms;

  /// No description provided for @legalDisclaimerAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get legalDisclaimerAnd;

  /// No description provided for @legalDisclaimerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalDisclaimerPrivacy;

  /// No description provided for @legalDisclaimerSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get legalDisclaimerSuffix;

  /// No description provided for @pathGentleMorningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle Mornings'**
  String get pathGentleMorningsTitle;

  /// No description provided for @pathGentleMorningsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A soft, intentional way to start the day'**
  String get pathGentleMorningsSubtitle;

  /// No description provided for @pathAnchorsForHardDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Anchors for Hard Days'**
  String get pathAnchorsForHardDaysTitle;

  /// No description provided for @pathAnchorsForHardDaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small acts that hold you steady when life is loud'**
  String get pathAnchorsForHardDaysSubtitle;

  /// No description provided for @pathQuietFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet Focus'**
  String get pathQuietFocusTitle;

  /// No description provided for @pathQuietFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get things done without the burnout'**
  String get pathQuietFocusSubtitle;

  /// No description provided for @pathWindingDownTitle.
  ///
  /// In en, this message translates to:
  /// **'Winding Down'**
  String get pathWindingDownTitle;

  /// No description provided for @pathWindingDownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A small ritual for letting the day go'**
  String get pathWindingDownSubtitle;

  /// No description provided for @pathYourOwnWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Own Way'**
  String get pathYourOwnWayTitle;

  /// No description provided for @pathYourOwnWaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'I know what I need — just give me the tools'**
  String get pathYourOwnWaySubtitle;

  /// No description provided for @intentionPathHeadline.
  ///
  /// In en, this message translates to:
  /// **'What brings you here?'**
  String get intentionPathHeadline;

  /// No description provided for @intentionPathSubtext.
  ///
  /// In en, this message translates to:
  /// **'This shapes the next 30 days. Pick the one that fits today — your future self will thank you.'**
  String get intentionPathSubtext;

  /// No description provided for @intentionPathUpdateFocusAreas.
  ///
  /// In en, this message translates to:
  /// **'Update your focus areas to match \"{pathName}\"?'**
  String intentionPathUpdateFocusAreas(String pathName);

  /// No description provided for @intentionPathUpdateYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, update focus areas'**
  String get intentionPathUpdateYes;

  /// No description provided for @intentionPathUpdateNo.
  ///
  /// In en, this message translates to:
  /// **'No, keep my current areas'**
  String get intentionPathUpdateNo;

  /// No description provided for @tellUsAboutPathHeadline.
  ///
  /// In en, this message translates to:
  /// **'What brings you here?'**
  String get tellUsAboutPathHeadline;

  /// No description provided for @tellUsAboutPathSubtext.
  ///
  /// In en, this message translates to:
  /// **'This shapes the next 30 days. Pick the one that fits today — your future self will thank you.'**
  String get tellUsAboutPathSubtext;

  /// No description provided for @tellUsAboutFocusHeadline.
  ///
  /// In en, this message translates to:
  /// **'What feels important right now?'**
  String get tellUsAboutFocusHeadline;

  /// No description provided for @tellUsAboutFocusSubtext.
  ///
  /// In en, this message translates to:
  /// **'Pick up to 2. We\'ll start there.'**
  String get tellUsAboutFocusSubtext;

  /// No description provided for @commitmentTitle.
  ///
  /// In en, this message translates to:
  /// **'One small promise.'**
  String get commitmentTitle;

  /// No description provided for @commitmentBody.
  ///
  /// In en, this message translates to:
  /// **'Two minutes a day. That\'s the whole ask.'**
  String get commitmentBody;

  /// No description provided for @commitmentEchoFull.
  ///
  /// In en, this message translates to:
  /// **'Your path: {path}  ·  Your focus: {areas}'**
  String commitmentEchoFull(String path, String areas);

  /// No description provided for @commitmentEchoAreasOnly.
  ///
  /// In en, this message translates to:
  /// **'Your focus: {areas}'**
  String commitmentEchoAreasOnly(String areas);

  /// No description provided for @commitmentCta.
  ///
  /// In en, this message translates to:
  /// **'I\'ll show up for myself'**
  String get commitmentCta;

  /// No description provided for @coachMarkWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'See your intentions without opening the app'**
  String get coachMarkWidgetTitle;

  /// No description provided for @coachMarkWidgetBody.
  ///
  /// In en, this message translates to:
  /// **'Add an Intended widget to your home or lock screen. A quiet reminder of what matters today.'**
  String get coachMarkWidgetBody;

  /// No description provided for @coachMarkSmartNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reminders learn from you'**
  String get coachMarkSmartNotificationsTitle;

  /// No description provided for @coachMarkSmartNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Intended adjusts when and how often it nudges you based on your rhythm. Check in a lot? We step back. Been away? Just one gentle note.'**
  String get coachMarkSmartNotificationsBody;

  /// No description provided for @upgradeNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'Your practice is growing. Intended+ gives you room to grow with it.'**
  String get upgradeNudgeBody;

  /// No description provided for @upgradeNudgeLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get upgradeNudgeLearnMore;

  /// No description provided for @notifWeeklyDynamic0.
  ///
  /// In en, this message translates to:
  /// **'Your week\'s page is ready. Every week is a fresh start.'**
  String get notifWeeklyDynamic0;

  /// No description provided for @notifWeeklyDynamic1.
  ///
  /// In en, this message translates to:
  /// **'Your week is on the page — one moment of care in it.'**
  String get notifWeeklyDynamic1;

  /// No description provided for @notifWeeklyDynamicN.
  ///
  /// In en, this message translates to:
  /// **'Your week is on the page — {count} moments in it.'**
  String notifWeeklyDynamicN(int count);

  /// No description provided for @notifMonthlyLetter.
  ///
  /// In en, this message translates to:
  /// **'Your {month} letter is ready.'**
  String notifMonthlyLetter(String month);

  /// No description provided for @faqSectionGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get faqSectionGettingStarted;

  /// No description provided for @faqWhatIsIntended.
  ///
  /// In en, this message translates to:
  /// **'What is Intended?'**
  String get faqWhatIsIntended;

  /// No description provided for @faqWhatIsIntendedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Intended is a gentle habit app for iOS. It helps you build daily habits without streaks, guilt, or pressure. There\'s no counter that resets when you miss a day — just a calm space to check in with your intentions whenever you\'re ready.'**
  String get faqWhatIsIntendedAnswer;

  /// No description provided for @faqWhatIsIntentionPath.
  ///
  /// In en, this message translates to:
  /// **'What\'s an Intention Path?'**
  String get faqWhatIsIntentionPath;

  /// No description provided for @faqWhatIsIntentionPathAnswer.
  ///
  /// In en, this message translates to:
  /// **'When you first open Intended, you choose a path based on what brings you here — like Finding Calm or Gentle Mornings. Your path shapes your default habits, the tone of your reminders, and your reflection questions. You can change it anytime in your profile.'**
  String get faqWhatIsIntentionPathAnswer;

  /// No description provided for @faqChangeIntentionPath.
  ///
  /// In en, this message translates to:
  /// **'Can I change my Intention Path?'**
  String get faqChangeIntentionPath;

  /// No description provided for @faqChangeIntentionPathAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, anytime. Go to your Profile, tap your Intention Path card, and pick a new one. Your history and check-ins stay exactly as they are.'**
  String get faqChangeIntentionPathAnswer;

  /// No description provided for @faqWhatAreFocusAreas.
  ///
  /// In en, this message translates to:
  /// **'What are Focus Areas?'**
  String get faqWhatAreFocusAreas;

  /// No description provided for @faqWhatAreFocusAreasAnswer.
  ///
  /// In en, this message translates to:
  /// **'Focus areas are categories of habits — like Health, Mood, or Self-care. Each area comes with curated habits. Your path pre-selects a couple, but you can add or remove them anytime.'**
  String get faqWhatAreFocusAreasAnswer;

  /// No description provided for @faqHowIsDifferent.
  ///
  /// In en, this message translates to:
  /// **'How is Intended different?'**
  String get faqHowIsDifferent;

  /// No description provided for @faqHowIsDifferentAnswer.
  ///
  /// In en, this message translates to:
  /// **'Most habit apps use streaks and gamification. Intended takes the opposite approach. No streaks to break, no leaderboards, no guilt. Your progress never resets.'**
  String get faqHowIsDifferentAnswer;

  /// No description provided for @faqNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'Do I need an account?'**
  String get faqNeedAccount;

  /// No description provided for @faqNeedAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Not to get started. You can use Intended without signing in. Creating an account (via Apple or Google) lets you back up your data to the cloud and restore it if you switch devices.'**
  String get faqNeedAccountAnswer;

  /// No description provided for @faqSectionDailyHabits.
  ///
  /// In en, this message translates to:
  /// **'Daily Habits'**
  String get faqSectionDailyHabits;

  /// No description provided for @faqHowToCheckIn.
  ///
  /// In en, this message translates to:
  /// **'How do I check in?'**
  String get faqHowToCheckIn;

  /// No description provided for @faqHowToCheckInAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap any habit card on your home screen. A single tap is all it takes.'**
  String get faqHowToCheckInAnswer;

  /// No description provided for @faqMissedDay.
  ///
  /// In en, this message translates to:
  /// **'What if I miss a day?'**
  String get faqMissedDay;

  /// No description provided for @faqMissedDayAnswer.
  ///
  /// In en, this message translates to:
  /// **'Nothing happens. No streaks break, no counters reset — research on habit formation found a missed day doesn\'t materially set you back. If you were quiet a few days, the first square after is marked as a return, not the gap as a failure. And if you did the thing but didn\'t log it: long-press the card to log yesterday.'**
  String get faqMissedDayAnswer;

  /// No description provided for @faqHowToPin.
  ///
  /// In en, this message translates to:
  /// **'How do I pin a habit?'**
  String get faqHowToPin;

  /// No description provided for @faqHowToPinAnswer.
  ///
  /// In en, this message translates to:
  /// **'Long-press any habit card to pin it to the top. You can have one pinned habit at a time.'**
  String get faqHowToPinAnswer;

  /// No description provided for @faqCustomHabits.
  ///
  /// In en, this message translates to:
  /// **'Can I add custom habits?'**
  String get faqCustomHabits;

  /// No description provided for @faqCustomHabitsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Tap the + button. Free users can have up to 2 custom habits. Intended+ gives you unlimited.'**
  String get faqCustomHabitsAnswer;

  /// No description provided for @faqSwapHabit.
  ///
  /// In en, this message translates to:
  /// **'How do I swap a habit?'**
  String get faqSwapHabit;

  /// No description provided for @faqSwapHabitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the swap icon on any habit card. Free users get 2 swaps per month.'**
  String get faqSwapHabitAnswer;

  /// No description provided for @faqRefreshes.
  ///
  /// In en, this message translates to:
  /// **'What are refreshes?'**
  String get faqRefreshes;

  /// No description provided for @faqRefreshesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Refreshing gives you new random habits from your focus areas. 3 per day on the free plan.'**
  String get faqRefreshesAnswer;

  /// No description provided for @faqAllDone.
  ///
  /// In en, this message translates to:
  /// **'What happens when I complete all my habits?'**
  String get faqAllDone;

  /// No description provided for @faqAllDoneAnswer.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see a quiet celebration — a gentle bloom moment. It\'s a small reminder that showing up matters, no matter how many habits you checked off.'**
  String get faqAllDoneAnswer;

  /// No description provided for @faqSectionReflections.
  ///
  /// In en, this message translates to:
  /// **'Your month'**
  String get faqSectionReflections;

  /// No description provided for @faqShareReflection.
  ///
  /// In en, this message translates to:
  /// **'Can I share my reflection?'**
  String get faqShareReflection;

  /// No description provided for @faqShareReflectionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes — on Your month, tap Share under your season. It becomes a story-sized card with your grid and your season word, sized for Instagram or TikTok. Habit names are never on it unless you put them there.'**
  String get faqShareReflectionAnswer;

  /// No description provided for @faqHowReflectionsGenerated.
  ///
  /// In en, this message translates to:
  /// **'How are reflections generated?'**
  String get faqHowReflectionsGenerated;

  /// No description provided for @faqHowReflectionsGeneratedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Reflections are generated entirely on your device from your check-in data. No AI, no cloud processing. The app looks at your patterns — active days, favorite habits, consistency — and turns them into gentle observations.'**
  String get faqHowReflectionsGeneratedAnswer;

  /// No description provided for @faqSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get faqSectionNotifications;

  /// No description provided for @faqHowNotifications.
  ///
  /// In en, this message translates to:
  /// **'How do notifications work?'**
  String get faqHowNotifications;

  /// No description provided for @faqHowNotificationsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Reminders adapt to your rhythm. Check in regularly and they step back. Been away? One gentle nudge — never seven.'**
  String get faqHowNotificationsAnswer;

  /// No description provided for @faqChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Can I change the time?'**
  String get faqChangeTime;

  /// No description provided for @faqChangeTimeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Profile → Notification Settings.'**
  String get faqChangeTimeAnswer;

  /// No description provided for @faqPathNotifications.
  ///
  /// In en, this message translates to:
  /// **'Do notifications match my path?'**
  String get faqPathNotifications;

  /// No description provided for @faqPathNotificationsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Someone on Finding Calm sees different wording than someone on Gentle Mornings.'**
  String get faqPathNotificationsAnswer;

  /// No description provided for @faqTurnOffNotifications.
  ///
  /// In en, this message translates to:
  /// **'Can I turn off notifications?'**
  String get faqTurnOffNotifications;

  /// No description provided for @faqTurnOffNotificationsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Go to Profile → Notification Settings and toggle them off. You can also disable just the weekly reflection reminder while keeping daily ones.'**
  String get faqTurnOffNotificationsAnswer;

  /// No description provided for @faqSectionWidgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get faqSectionWidgets;

  /// No description provided for @faqAddWidget.
  ///
  /// In en, this message translates to:
  /// **'How do I add a widget?'**
  String get faqAddWidget;

  /// No description provided for @faqAddWidgetAnswer.
  ///
  /// In en, this message translates to:
  /// **'Long-press your home screen, tap +, search for Intended. You can also add lock screen widgets through iOS Settings. There\'s a Pause widget too — one tap, and you\'re already breathing.'**
  String get faqAddWidgetAnswer;

  /// No description provided for @faqWidgetNotUpdating.
  ///
  /// In en, this message translates to:
  /// **'Why isn\'t my widget updating?'**
  String get faqWidgetNotUpdating;

  /// No description provided for @faqWidgetNotUpdatingAnswer.
  ///
  /// In en, this message translates to:
  /// **'iOS controls refresh timing. Open the app briefly to trigger it. Check that Background App Refresh is enabled for Intended.'**
  String get faqWidgetNotUpdatingAnswer;

  /// No description provided for @faqSectionPricing.
  ///
  /// In en, this message translates to:
  /// **'Intended+ & Pricing'**
  String get faqSectionPricing;

  /// No description provided for @faqWhatIsPlus.
  ///
  /// In en, this message translates to:
  /// **'What is Intended+?'**
  String get faqWhatIsPlus;

  /// No description provided for @faqWhatIsPlusAnswer.
  ///
  /// In en, this message translates to:
  /// **'Intended+ is the reading of your month: the drift warning before a quiet stretch, a four-line letter, next month\'s plan built from this month\'s evidence, what actually lifts you, the season\'s explanation and archive — plus all ten themes, premium icons, and the widget that shows your whole month in colour.'**
  String get faqWhatIsPlusAnswer;

  /// No description provided for @faqPricing.
  ///
  /// In en, this message translates to:
  /// **'How much does it cost?'**
  String get faqPricing;

  /// No description provided for @faqPricingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Monthly: {monthly}. Yearly: {yearly}. Lifetime: {lifetime}, one-time. Both subscriptions start with a {days}-day free trial.'**
  String faqPricingAnswer(
      String monthly, String yearly, String lifetime, int days);

  /// The pricing answer before the store has confirmed a trial length shared by both subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Monthly: {monthly}. Yearly: {yearly}. Lifetime: {lifetime}, one-time. Both subscriptions start with a free trial.'**
  String faqPricingAnswerUnspecified(
      String monthly, String yearly, String lifetime);

  /// The pricing answer when the store reports no free trial (or lengths that differ between the two subscriptions).
  ///
  /// In en, this message translates to:
  /// **'Monthly: {monthly}. Yearly: {yearly}. Lifetime: {lifetime}, one-time.'**
  String faqPricingAnswerNoTrial(
      String monthly, String yearly, String lifetime);

  /// No description provided for @faqFreeVersion.
  ///
  /// In en, this message translates to:
  /// **'Can I use it for free?'**
  String get faqFreeVersion;

  /// No description provided for @faqFreeVersionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Free includes intention paths, 2 custom habits, 2 focus areas, weekly reflections, smart notifications, and widgets.'**
  String get faqFreeVersionAnswer;

  /// No description provided for @faqRestore.
  ///
  /// In en, this message translates to:
  /// **'How do I restore my purchase?'**
  String get faqRestore;

  /// No description provided for @faqRestoreAnswer.
  ///
  /// In en, this message translates to:
  /// **'Profile → Restore Purchases.'**
  String get faqRestoreAnswer;

  /// No description provided for @faqCancel.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel?'**
  String get faqCancel;

  /// No description provided for @faqCancelAnswer.
  ///
  /// In en, this message translates to:
  /// **'iPhone Settings → your name → Subscriptions → Intended → Cancel.'**
  String get faqCancelAnswer;

  /// No description provided for @faqSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get faqSectionPrivacy;

  /// No description provided for @faqDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Where is my data stored?'**
  String get faqDataStorage;

  /// No description provided for @faqDataStorageAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your moments live on your device first. If you sign in, they\'re also backed up to your private account so a new phone can restore them — that includes mood taps and notes. No one else can see them, and deleting your account deletes the backup.'**
  String get faqDataStorageAnswer;

  /// No description provided for @faqDataSelling.
  ///
  /// In en, this message translates to:
  /// **'Does Intended sell my data?'**
  String get faqDataSelling;

  /// No description provided for @faqDataSellingAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. We use anonymous crash reports to fix bugs. Never your habit data.'**
  String get faqDataSellingAnswer;

  /// No description provided for @faqDeleteApp.
  ///
  /// In en, this message translates to:
  /// **'What if I delete the app?'**
  String get faqDeleteApp;

  /// No description provided for @faqDeleteAppAnswer.
  ///
  /// In en, this message translates to:
  /// **'Data is local, so deleting removes everything. Subscriptions can be restored through the App Store.'**
  String get faqDeleteAppAnswer;

  /// Count hint under each FAQ category card. Live counts run 3-8, so Russian needs few/many, not a single form.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String faqQuestionCount(int count);

  /// No description provided for @faqSectionTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get faqSectionTroubleshooting;

  /// No description provided for @faqCrash.
  ///
  /// In en, this message translates to:
  /// **'The app crashed.'**
  String get faqCrash;

  /// No description provided for @faqCrashAnswer.
  ///
  /// In en, this message translates to:
  /// **'Try closing and reopening. Make sure you have the latest version.'**
  String get faqCrashAnswer;

  /// No description provided for @faqHabitsGone.
  ///
  /// In en, this message translates to:
  /// **'My habits disappeared.'**
  String get faqHabitsGone;

  /// No description provided for @faqHabitsGoneAnswer.
  ///
  /// In en, this message translates to:
  /// **'Try restarting. If they don\'t return, contact support@intendedapp.com.'**
  String get faqHabitsGoneAnswer;

  /// No description provided for @faqAppleName.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In isn\'t showing my name.'**
  String get faqAppleName;

  /// No description provided for @faqAppleNameAnswer.
  ///
  /// In en, this message translates to:
  /// **'Apple only sends your name the first time. Go to iPhone Settings → Apple ID → Password & Security → Apps Using Apple ID → Intended → Stop Using, then sign in again.'**
  String get faqAppleNameAnswer;

  /// No description provided for @faqNotificationsNotArriving.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t arriving.'**
  String get faqNotificationsNotArriving;

  /// No description provided for @faqNotificationsNotArrivingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check that notifications are enabled for Intended in iPhone Settings → Notifications. Also make sure Background App Refresh is on. If you recently reinstalled, open the app once so it can reschedule reminders.'**
  String get faqNotificationsNotArrivingAnswer;

  /// No description provided for @faqStillHaveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Still have a question?'**
  String get faqStillHaveQuestion;

  /// No description provided for @faqContactButton.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get faqContactButton;

  /// No description provided for @faqWidgetCompletion.
  ///
  /// In en, this message translates to:
  /// **'Can I complete habits from my widget?'**
  String get faqWidgetCompletion;

  /// No description provided for @faqWidgetCompletionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Tap any habit on your home screen widget to mark it done. It syncs when you next open Intended.'**
  String get faqWidgetCompletionAnswer;

  /// No description provided for @faqWhatIsPause.
  ///
  /// In en, this message translates to:
  /// **'What\'s \"a minute of breath\"?'**
  String get faqWhatIsPause;

  /// No description provided for @faqWhatIsPauseAnswer.
  ///
  /// In en, this message translates to:
  /// **'The Pause. Tap the line above your actions and the screen breathes with you — five slow rounds, in and out, then one quiet question about how you feel. It isn\'t an action and nothing counts it; leave whenever you\'ve had enough. It also opens from the widget and the lock screen, and it\'s free.'**
  String get faqWhatIsPauseAnswer;

  /// No description provided for @faqHabitDays.
  ///
  /// In en, this message translates to:
  /// **'Can an action appear only on some days?'**
  String get faqHabitDays;

  /// No description provided for @faqHabitDaysAnswer.
  ///
  /// In en, this message translates to:
  /// **'For actions you created, yes. Long-press the card and pick days under \"Show this on\". On its off-days the card simply steps aside — nothing is missed, nothing resets. Built-in actions appear every day.'**
  String get faqHabitDaysAnswer;

  /// No description provided for @faqHealthData.
  ///
  /// In en, this message translates to:
  /// **'Does Intended read my Apple Health data?'**
  String get faqHealthData;

  /// No description provided for @faqHealthDataAnswer.
  ///
  /// In en, this message translates to:
  /// **'No — Intended never reads anything from Health. If you say yes after a pause, each completed pause is saved to Apple Health as a mindful minute, along with your answer. It\'s a one-way door, and you can close it anytime in iPhone Settings → Privacy & Security → Health.'**
  String get faqHealthDataAnswer;

  /// No description provided for @bloomGentleMornings1.
  ///
  /// In en, this message translates to:
  /// **'A full morning. That\'s something.'**
  String get bloomGentleMornings1;

  /// No description provided for @bloomGentleMornings2.
  ///
  /// In en, this message translates to:
  /// **'Every one, gently done.'**
  String get bloomGentleMornings2;

  /// No description provided for @bloomGentleMornings3.
  ///
  /// In en, this message translates to:
  /// **'Morning complete. You showed up softly.'**
  String get bloomGentleMornings3;

  /// No description provided for @bloomGentleMornings4.
  ///
  /// In en, this message translates to:
  /// **'All here. The morning was yours.'**
  String get bloomGentleMornings4;

  /// No description provided for @bloomGentleMornings5.
  ///
  /// In en, this message translates to:
  /// **'Gentle and done. That\'s enough.'**
  String get bloomGentleMornings5;

  /// No description provided for @bloomAnchorsForHardDays1.
  ///
  /// In en, this message translates to:
  /// **'An anchor held.'**
  String get bloomAnchorsForHardDays1;

  /// No description provided for @bloomAnchorsForHardDays2.
  ///
  /// In en, this message translates to:
  /// **'Even when hard, you\'re here.'**
  String get bloomAnchorsForHardDays2;

  /// No description provided for @bloomAnchorsForHardDays3.
  ///
  /// In en, this message translates to:
  /// **'Even when loud, you returned.'**
  String get bloomAnchorsForHardDays3;

  /// No description provided for @bloomAnchorsForHardDays4.
  ///
  /// In en, this message translates to:
  /// **'A small steady win on a hard day.'**
  String get bloomAnchorsForHardDays4;

  /// No description provided for @bloomAnchorsForHardDays5.
  ///
  /// In en, this message translates to:
  /// **'You\'re not gone. You\'re here.'**
  String get bloomAnchorsForHardDays5;

  /// No description provided for @bloomQuietFocus1.
  ///
  /// In en, this message translates to:
  /// **'Focused. Finished.'**
  String get bloomQuietFocus1;

  /// No description provided for @bloomQuietFocus2.
  ///
  /// In en, this message translates to:
  /// **'Quiet work, fully done.'**
  String get bloomQuietFocus2;

  /// No description provided for @bloomQuietFocus3.
  ///
  /// In en, this message translates to:
  /// **'One thing, all the way through.'**
  String get bloomQuietFocus3;

  /// No description provided for @bloomQuietFocus4.
  ///
  /// In en, this message translates to:
  /// **'Steady focus. Real progress.'**
  String get bloomQuietFocus4;

  /// No description provided for @bloomWindingDown1.
  ///
  /// In en, this message translates to:
  /// **'The evening is yours now. Rest.'**
  String get bloomWindingDown1;

  /// No description provided for @bloomWindingDown2.
  ///
  /// In en, this message translates to:
  /// **'All wound down. Let the night come.'**
  String get bloomWindingDown2;

  /// No description provided for @bloomWindingDown3.
  ///
  /// In en, this message translates to:
  /// **'Done softly. Tomorrow can wait.'**
  String get bloomWindingDown3;

  /// No description provided for @bloomWindingDown4.
  ///
  /// In en, this message translates to:
  /// **'Everything settled. You did enough.'**
  String get bloomWindingDown4;

  /// No description provided for @bloomWindingDown5.
  ///
  /// In en, this message translates to:
  /// **'Gently closed. Sleep well.'**
  String get bloomWindingDown5;

  /// No description provided for @bloomYourOwnWay1.
  ///
  /// In en, this message translates to:
  /// **'You showed up for all of it today.'**
  String get bloomYourOwnWay1;

  /// No description provided for @bloomYourOwnWay2.
  ///
  /// In en, this message translates to:
  /// **'All done, your way. That\'s what counts.'**
  String get bloomYourOwnWay2;

  /// No description provided for @bloomYourOwnWay3.
  ///
  /// In en, this message translates to:
  /// **'Every one, on your terms.'**
  String get bloomYourOwnWay3;

  /// No description provided for @bloomYourOwnWay4.
  ///
  /// In en, this message translates to:
  /// **'Finished. No one else needed to see this.'**
  String get bloomYourOwnWay4;

  /// No description provided for @bloomYourOwnWay5.
  ///
  /// In en, this message translates to:
  /// **'Quietly complete. That\'s yours to keep.'**
  String get bloomYourOwnWay5;

  /// No description provided for @notifPathGentleMornings1.
  ///
  /// In en, this message translates to:
  /// **'Good morning. No rush — what feels right today?'**
  String get notifPathGentleMornings1;

  /// No description provided for @notifPathGentleMornings2.
  ///
  /// In en, this message translates to:
  /// **'A new morning, a gentle start. You\'ve got this.'**
  String get notifPathGentleMornings2;

  /// No description provided for @notifPathGentleMornings3.
  ///
  /// In en, this message translates to:
  /// **'The morning is yours. Begin however feels right.'**
  String get notifPathGentleMornings3;

  /// No description provided for @notifPathGentleMornings4.
  ///
  /// In en, this message translates to:
  /// **'Mornings don\'t need to be perfect. Just present.'**
  String get notifPathGentleMornings4;

  /// No description provided for @notifPathGentleMornings5.
  ///
  /// In en, this message translates to:
  /// **'Rise gently. One small thing is enough today.'**
  String get notifPathGentleMornings5;

  /// No description provided for @notifPathGentleMornings6.
  ///
  /// In en, this message translates to:
  /// **'Your morning ritual is waiting. No pressure, just possibility.'**
  String get notifPathGentleMornings6;

  /// No description provided for @notifPathAnchorsForHardDays1.
  ///
  /// In en, this message translates to:
  /// **'One small anchor for today. That\'s enough.'**
  String get notifPathAnchorsForHardDays1;

  /// No description provided for @notifPathAnchorsForHardDays2.
  ///
  /// In en, this message translates to:
  /// **'Today might be heavy. Show up gently anyway.'**
  String get notifPathAnchorsForHardDays2;

  /// No description provided for @notifPathAnchorsForHardDays3.
  ///
  /// In en, this message translates to:
  /// **'An anchor doesn\'t fix the storm. It holds you steady.'**
  String get notifPathAnchorsForHardDays3;

  /// No description provided for @notifPathAnchorsForHardDays4.
  ///
  /// In en, this message translates to:
  /// **'Even a small return counts. Especially today.'**
  String get notifPathAnchorsForHardDays4;

  /// No description provided for @notifPathAnchorsForHardDays5.
  ///
  /// In en, this message translates to:
  /// **'Pause. Notice. Pick one thing.'**
  String get notifPathAnchorsForHardDays5;

  /// No description provided for @notifPathAnchorsForHardDays6.
  ///
  /// In en, this message translates to:
  /// **'Hard days are also days that pass. You\'re here.'**
  String get notifPathAnchorsForHardDays6;

  /// No description provided for @notifPathQuietFocus1.
  ///
  /// In en, this message translates to:
  /// **'A small block of focus. Then rest.'**
  String get notifPathQuietFocus1;

  /// No description provided for @notifPathQuietFocus2.
  ///
  /// In en, this message translates to:
  /// **'What\'s the one thing today?'**
  String get notifPathQuietFocus2;

  /// No description provided for @notifPathQuietFocus3.
  ///
  /// In en, this message translates to:
  /// **'Focus on less. Finish more.'**
  String get notifPathQuietFocus3;

  /// No description provided for @notifPathQuietFocus4.
  ///
  /// In en, this message translates to:
  /// **'Pick one. Begin.'**
  String get notifPathQuietFocus4;

  /// No description provided for @notifPathQuietFocus5.
  ///
  /// In en, this message translates to:
  /// **'Quiet work, real progress.'**
  String get notifPathQuietFocus5;

  /// No description provided for @notifPathQuietFocus6.
  ///
  /// In en, this message translates to:
  /// **'Show up to the work. That\'s the whole secret.'**
  String get notifPathQuietFocus6;

  /// No description provided for @notifPathWindingDown1.
  ///
  /// In en, this message translates to:
  /// **'The day is almost done. Let it go gently.'**
  String get notifPathWindingDown1;

  /// No description provided for @notifPathWindingDown2.
  ///
  /// In en, this message translates to:
  /// **'Time to unwind. You carried enough today.'**
  String get notifPathWindingDown2;

  /// No description provided for @notifPathWindingDown3.
  ///
  /// In en, this message translates to:
  /// **'Evening is for letting go, not catching up.'**
  String get notifPathWindingDown3;

  /// No description provided for @notifPathWindingDown4.
  ///
  /// In en, this message translates to:
  /// **'You showed up today. That\'s worth settling into.'**
  String get notifPathWindingDown4;

  /// No description provided for @notifPathWindingDown5.
  ///
  /// In en, this message translates to:
  /// **'The night is yours. Rest without guilt.'**
  String get notifPathWindingDown5;

  /// No description provided for @notifPathWindingDown6.
  ///
  /// In en, this message translates to:
  /// **'Slow down. Tomorrow will wait for you.'**
  String get notifPathWindingDown6;

  /// No description provided for @notifPathYourOwnWay1.
  ///
  /// In en, this message translates to:
  /// **'Your practice, your pace. What feels right today?'**
  String get notifPathYourOwnWay1;

  /// No description provided for @notifPathYourOwnWay2.
  ///
  /// In en, this message translates to:
  /// **'You know what you need. We\'re just here to remind you.'**
  String get notifPathYourOwnWay2;

  /// No description provided for @notifPathYourOwnWay3.
  ///
  /// In en, this message translates to:
  /// **'Check in when you\'re ready. No schedule, no pressure.'**
  String get notifPathYourOwnWay3;

  /// No description provided for @notifPathYourOwnWay4.
  ///
  /// In en, this message translates to:
  /// **'Your path is your own. Show up however you want.'**
  String get notifPathYourOwnWay4;

  /// No description provided for @notifPathYourOwnWay5.
  ///
  /// In en, this message translates to:
  /// **'One intention. That\'s all. The rest is up to you.'**
  String get notifPathYourOwnWay5;

  /// No description provided for @notifPathYourOwnWay6.
  ///
  /// In en, this message translates to:
  /// **'You built this practice. Trust where it takes you.'**
  String get notifPathYourOwnWay6;

  /// No description provided for @adaptiveNotifReengageBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a little while. Just a gentle hello.'**
  String get adaptiveNotifReengageBody;

  /// No description provided for @adaptiveNotifSilentBody.
  ///
  /// In en, this message translates to:
  /// **'We noticed you\'ve been away. No pressure — we\'ll be here when you\'re ready.'**
  String get adaptiveNotifSilentBody;

  /// No description provided for @a11yTabHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get a11yTabHabits;

  /// No description provided for @a11yTabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get a11yTabProgress;

  /// No description provided for @a11yTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get a11yTabProfile;

  /// No description provided for @a11yHabitCardDone.
  ///
  /// In en, this message translates to:
  /// **'{habit}, completed'**
  String a11yHabitCardDone(String habit);

  /// No description provided for @a11yHabitCardTodo.
  ///
  /// In en, this message translates to:
  /// **'{habit}, tap to complete'**
  String a11yHabitCardTodo(String habit);

  /// No description provided for @a11yHabitCardPinned.
  ///
  /// In en, this message translates to:
  /// **'{habit}, pinned, tap to complete'**
  String a11yHabitCardPinned(String habit);

  /// No description provided for @a11yEditHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get a11yEditHabit;

  /// No description provided for @a11yDeleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get a11yDeleteHabit;

  /// No description provided for @letterOpenedQuietly.
  ///
  /// In en, this message translates to:
  /// **'You started this month quietly.'**
  String get letterOpenedQuietly;

  /// No description provided for @letterOpenedFull.
  ///
  /// In en, this message translates to:
  /// **'You came into this month at full speed.'**
  String get letterOpenedFull;

  /// No description provided for @letterMostlyChose.
  ///
  /// In en, this message translates to:
  /// **'{area} carried almost the whole month.'**
  String letterMostlyChose(String area);

  /// No description provided for @letterQuestionPlanForPart.
  ///
  /// In en, this message translates to:
  /// **'What would {month} look like if you planned for {lived} instead of {planned}?'**
  String letterQuestionPlanForPart(String month, String lived, String planned);

  /// No description provided for @letterQuestionShorterQuiet.
  ///
  /// In en, this message translates to:
  /// **'What would {month} look like if the quiet stretches were shorter?'**
  String letterQuestionShorterQuiet(String month);

  /// No description provided for @letterQuestionMoreOfWhat.
  ///
  /// In en, this message translates to:
  /// **'What do you want more of in {month}?'**
  String letterQuestionMoreOfWhat(String month);

  /// No description provided for @letterPartMornings.
  ///
  /// In en, this message translates to:
  /// **'mornings'**
  String get letterPartMornings;

  /// No description provided for @letterPartAfternoons.
  ///
  /// In en, this message translates to:
  /// **'afternoons'**
  String get letterPartAfternoons;

  /// No description provided for @letterPartEvenings.
  ///
  /// In en, this message translates to:
  /// **'evenings'**
  String get letterPartEvenings;

  /// No description provided for @letterPartNights.
  ///
  /// In en, this message translates to:
  /// **'late nights'**
  String get letterPartNights;

  /// No description provided for @planActionsHeader.
  ///
  /// In en, this message translates to:
  /// **'YOUR ACTIONS'**
  String get planActionsHeader;

  /// No description provided for @planRhythmHeader.
  ///
  /// In en, this message translates to:
  /// **'YOUR RHYTHM'**
  String get planRhythmHeader;

  /// No description provided for @planUse.
  ///
  /// In en, this message translates to:
  /// **'Use this plan'**
  String get planUse;

  /// No description provided for @planAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get planAdjust;

  /// No description provided for @planSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get planSkip;

  /// No description provided for @planPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT INTENDED+ WOULD SUGGEST'**
  String get planPreviewLabel;

  /// Comma-joined gap lengths, longest-ago first: '9, 6, 4, 2'. Paid only (§5.3) — free gets the count without the intervals.
  ///
  /// In en, this message translates to:
  /// **'{gaps} days apart.'**
  String insightsReturnGaps(String gaps);

  /// No description provided for @shareSeasonMoments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 moment} other{{count} moments}}'**
  String shareSeasonMoments(int count);

  /// No description provided for @shareSeasonReturns.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{I came back once} other{I came back {count} times}}'**
  String shareSeasonReturns(int count);

  /// No description provided for @todayAdoptIntention.
  ///
  /// In en, this message translates to:
  /// **'Adopt a different intention'**
  String get todayAdoptIntention;

  /// No description provided for @staleNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'This one doesn\'t seem to fit'**
  String get staleNudgeTitle;

  /// No description provided for @staleNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'No moments here in the last ten days. Want to try a different intention?'**
  String get staleNudgeBody;

  /// No description provided for @staleNudgeChange.
  ///
  /// In en, this message translates to:
  /// **'Change my intention'**
  String get staleNudgeChange;

  /// No description provided for @staleNudgeKeep.
  ///
  /// In en, this message translates to:
  /// **'Leave it as is'**
  String get staleNudgeKeep;

  /// No description provided for @rescueTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} quiet days. That\'s allowed.'**
  String rescueTitle(int count);

  /// No description provided for @rescueBody.
  ///
  /// In en, this message translates to:
  /// **'Just this one today?'**
  String get rescueBody;

  /// No description provided for @rescueLongTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while. That\'s allowed.'**
  String get rescueLongTitle;

  /// No description provided for @rescueLongBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing here kept score while you were gone.'**
  String get rescueLongBody;

  /// No description provided for @rescueShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show everything'**
  String get rescueShowAll;

  /// No description provided for @menuDidYesterday.
  ///
  /// In en, this message translates to:
  /// **'I did this yesterday'**
  String get menuDidYesterday;

  /// No description provided for @toastAlreadyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday already has this one.'**
  String get toastAlreadyYesterday;

  /// No description provided for @liftLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT LIFTS YOU'**
  String get liftLabel;

  /// No description provided for @liftLine.
  ///
  /// In en, this message translates to:
  /// **'{habit} — glad you did it {glad, plural, =1{once} other{{glad} times}} out of {total}.'**
  String liftLine(String habit, int glad, int total);

  /// No description provided for @liftForming.
  ///
  /// In en, this message translates to:
  /// **'Too early to call it a pattern — ask me again in {weeks, plural, =1{a week} other{{weeks} weeks}}.'**
  String liftForming(int weeks);

  /// No description provided for @liftWorstLead.
  ///
  /// In en, this message translates to:
  /// **'That last one mostly doesn\'t land.'**
  String get liftWorstLead;

  /// No description provided for @soFarLabel.
  ///
  /// In en, this message translates to:
  /// **'SO FAR'**
  String get soFarLabel;

  /// No description provided for @soFarGlad.
  ///
  /// In en, this message translates to:
  /// **'glad you did'**
  String get soFarGlad;

  /// No description provided for @soFarEffort.
  ///
  /// In en, this message translates to:
  /// **'took effort'**
  String get soFarEffort;

  /// No description provided for @soFarClosing.
  ///
  /// In en, this message translates to:
  /// **'Too early to call anything a pattern. This page grows as you do.'**
  String get soFarClosing;

  /// No description provided for @firstWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST WEEK'**
  String get firstWeekLabel;

  /// No description provided for @firstWeekCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One small thing} other{{count} small things}} for yourself in your first week.'**
  String firstWeekCount(int count);

  /// No description provided for @firstWeekGladdest.
  ///
  /// In en, this message translates to:
  /// **'The one you were glad about most: {habit}.'**
  String firstWeekGladdest(String habit);

  /// No description provided for @shareSeasonGaps.
  ///
  /// In en, this message translates to:
  /// **'and the gaps are getting shorter'**
  String get shareSeasonGaps;

  /// No description provided for @shareSeasonLabel.
  ///
  /// In en, this message translates to:
  /// **'MY SEASON'**
  String get shareSeasonLabel;

  /// Subject line (Mail, Messages) when sharing the season card. Month is the bare month name (DateFormat.LLLL), so Russian gets the nominative «сентябрь»; every Russian month is masculine, so «Мой» always agrees.
  ///
  /// In en, this message translates to:
  /// **'My {month} on Intended'**
  String shareSeasonSubject(String month);

  /// No description provided for @shareSeasonMorningLine.
  ///
  /// In en, this message translates to:
  /// **'I come to this before the day starts.'**
  String get shareSeasonMorningLine;

  /// No description provided for @shareSeasonEveningLine.
  ///
  /// In en, this message translates to:
  /// **'I come to this once the day has quieted.'**
  String get shareSeasonEveningLine;

  /// No description provided for @shareSeasonSteadyLine.
  ///
  /// In en, this message translates to:
  /// **'A little, most days.'**
  String get shareSeasonSteadyLine;

  /// No description provided for @shareSeasonBurstsLine.
  ///
  /// In en, this message translates to:
  /// **'I arrive in waves, and they come back.'**
  String get shareSeasonBurstsLine;

  /// No description provided for @shareSeasonReturningLine.
  ///
  /// In en, this message translates to:
  /// **'I go quiet, and I find my way back.'**
  String get shareSeasonReturningLine;

  /// No description provided for @shareSeasonContinuousLine.
  ///
  /// In en, this message translates to:
  /// **'I keep a thread running all month.'**
  String get shareSeasonContinuousLine;

  /// No description provided for @shareSeasonFocusedLine.
  ///
  /// In en, this message translates to:
  /// **'One thing has most of my attention.'**
  String get shareSeasonFocusedLine;

  /// No description provided for @shareSeasonWanderingLine.
  ///
  /// In en, this message translates to:
  /// **'I follow what I need.'**
  String get shareSeasonWanderingLine;

  /// No description provided for @pathMoreIntentions.
  ///
  /// In en, this message translates to:
  /// **'MORE INTENTIONS'**
  String get pathMoreIntentions;

  /// No description provided for @pathSofterNightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Softer Nights'**
  String get pathSofterNightsTitle;

  /// No description provided for @pathSofterNightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For sleep that doesn\'t fight you'**
  String get pathSofterNightsSubtitle;

  /// No description provided for @intentionSofterNights.
  ///
  /// In en, this message translates to:
  /// **'Sleep that comes easier'**
  String get intentionSofterNights;

  /// No description provided for @pathLookingUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking Up'**
  String get pathLookingUpTitle;

  /// No description provided for @pathLookingUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Less scrolling, more of everything else'**
  String get pathLookingUpSubtitle;

  /// No description provided for @intentionLookingUp.
  ///
  /// In en, this message translates to:
  /// **'More life outside the screen'**
  String get intentionLookingUp;

  /// No description provided for @pathCloserToPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Closer to People'**
  String get pathCloserToPeopleTitle;

  /// No description provided for @pathCloserToPeopleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small ways to stay in touch'**
  String get pathCloserToPeopleSubtitle;

  /// No description provided for @intentionCloserToPeople.
  ///
  /// In en, this message translates to:
  /// **'Closer to my people'**
  String get intentionCloserToPeople;

  /// No description provided for @pathMovingALittleTitle.
  ///
  /// In en, this message translates to:
  /// **'Moving a Little'**
  String get pathMovingALittleTitle;

  /// No description provided for @pathMovingALittleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle movement, no gym required'**
  String get pathMovingALittleSubtitle;

  /// No description provided for @intentionMovingALittle.
  ///
  /// In en, this message translates to:
  /// **'Moving a little, most days'**
  String get intentionMovingALittle;

  /// No description provided for @pathThroughAHardSeasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Through a Hard Season'**
  String get pathThroughAHardSeasonTitle;

  /// No description provided for @pathThroughAHardSeasonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The smallest steps, for the heaviest months'**
  String get pathThroughAHardSeasonSubtitle;

  /// No description provided for @intentionThroughAHardSeason.
  ///
  /// In en, this message translates to:
  /// **'Gentle with myself through this'**
  String get intentionThroughAHardSeason;

  /// No description provided for @habitScreensAwayBed.
  ///
  /// In en, this message translates to:
  /// **'Screens away 20 minutes before bed'**
  String get habitScreensAwayBed;

  /// No description provided for @habitDimLights.
  ///
  /// In en, this message translates to:
  /// **'Dim the lights an hour before sleep'**
  String get habitDimLights;

  /// No description provided for @habitMealWithoutPhone.
  ///
  /// In en, this message translates to:
  /// **'One meal without your phone'**
  String get habitMealWithoutPhone;

  /// No description provided for @insightsFilterLine.
  ///
  /// In en, this message translates to:
  /// **'{area} — {count, plural, =1{one moment} other{{count} moments}} across {days, plural, =1{one day} other{{days} days}}.'**
  String insightsFilterLine(String area, int count, int days);

  /// No description provided for @insightsPastEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'A quiet month.'**
  String get insightsPastEmptyTitle;

  /// No description provided for @insightsPastEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing was collected here — and it kept none of your later months from happening.'**
  String get insightsPastEmptyBody;

  /// No description provided for @faqWhatIsMoment.
  ///
  /// In en, this message translates to:
  /// **'What are the squares?'**
  String get faqWhatIsMoment;

  /// No description provided for @faqWhatIsMomentAnswer.
  ///
  /// In en, this message translates to:
  /// **'Every action you complete becomes one square — a moment — in your month\'s grid. The grid only grows: there is no square for a day you skipped, because days aren\'t the unit here. Colour is the focus area; the tint is how it landed.'**
  String get faqWhatIsMomentAnswer;

  /// No description provided for @faqWhatAreSeasons.
  ///
  /// In en, this message translates to:
  /// **'What is my season?'**
  String get faqWhatAreSeasons;

  /// No description provided for @faqWhatAreSeasonsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Once a month has about ten moments, Intended names its pattern — Evening, Steady, Returning. It\'s an observation about the month, never a label on you: next month reads fresh, and a closed month\'s word is frozen forever.'**
  String get faqWhatAreSeasonsAnswer;

  /// No description provided for @faqPlusReads.
  ///
  /// In en, this message translates to:
  /// **'What does Intended+ actually do with my month?'**
  String get faqPlusReads;

  /// No description provided for @faqPlusReadsAnswer.
  ///
  /// In en, this message translates to:
  /// **'It reads what free shows. The drift warning speaks up before a quiet stretch, while there\'s still a week to change. The letter tells the month back to you in four lines and ends on a question. The plan turns last month\'s evidence into one or two concrete changes — and four weeks later tells you honestly whether the change worked.'**
  String get faqPlusReadsAnswer;

  /// No description provided for @faqStopPaying.
  ///
  /// In en, this message translates to:
  /// **'Do I lose anything if I stop paying?'**
  String get faqStopPaying;

  /// No description provided for @faqStopPayingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Nothing you made. Every moment, note and season stays yours, the grid keeps growing, and the gentle come-back nudge stays free forever. What pauses is the reading: drift, the letter, the plan, and what lifts you.'**
  String get faqStopPayingAnswer;

  /// No description provided for @yearInSeasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your months'**
  String get yearInSeasonsTitle;

  /// No description provided for @widgetCatchupEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FROM YOUR WIDGET'**
  String get widgetCatchupEyebrow;

  /// No description provided for @profileExportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get profileExportData;

  /// No description provided for @profileExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export didn\'t finish — try again.'**
  String get profileExportFailed;

  /// No description provided for @insightsFilterHint.
  ///
  /// In en, this message translates to:
  /// **'tap a colour = see just those'**
  String get insightsFilterHint;

  /// No description provided for @onboardingPaywallStep1.
  ///
  /// In en, this message translates to:
  /// **'Keep small intentions — each one lands as a square in your month'**
  String get onboardingPaywallStep1;

  /// No description provided for @onboardingPaywallStep2.
  ///
  /// In en, this message translates to:
  /// **'Read your month — the letter, your season, next month\'s plan'**
  String get onboardingPaywallStep2;

  /// No description provided for @onboardingPaywallStep3.
  ///
  /// In en, this message translates to:
  /// **'See what worked — measured honestly, four weeks on'**
  String get onboardingPaywallStep3;

  /// No description provided for @focusAreasFromPath.
  ///
  /// In en, this message translates to:
  /// **'{path} starts with these two. Swap them if something else matters more.'**
  String focusAreasFromPath(String path);

  /// No description provided for @focusAreasLimitToast.
  ///
  /// In en, this message translates to:
  /// **'Two keeps the focus — set one down first.'**
  String get focusAreasLimitToast;

  /// No description provided for @insightsExampleSeason.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get insightsExampleSeason;

  /// No description provided for @insightsExampleLetter.
  ///
  /// In en, this message translates to:
  /// **'Six days passed, and then you came back.'**
  String get insightsExampleLetter;

  /// No description provided for @insightsExamplePlan.
  ///
  /// In en, this message translates to:
  /// **'Move your reminder to 9 PM — that\'s where this month lived.'**
  String get insightsExamplePlan;

  /// No description provided for @onboardingPaywallLoop.
  ///
  /// In en, this message translates to:
  /// **'…and the next month begins'**
  String get onboardingPaywallLoop;

  /// No description provided for @letterQuestionStillFits.
  ///
  /// In en, this message translates to:
  /// **'Is “{path}” still what you\'re after?'**
  String letterQuestionStillFits(String path);

  /// No description provided for @pauseEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'a minute of breath'**
  String get pauseEntryTitle;

  /// No description provided for @pauseLeave.
  ///
  /// In en, this message translates to:
  /// **'enough for now'**
  String get pauseLeave;

  /// No description provided for @pauseBreathIn.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get pauseBreathIn;

  /// No description provided for @pauseBreathOut.
  ///
  /// In en, this message translates to:
  /// **'out'**
  String get pauseBreathOut;

  /// No description provided for @pauseCheckInQuestion.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling now?'**
  String get pauseCheckInQuestion;

  /// No description provided for @pauseCheckInTense.
  ///
  /// In en, this message translates to:
  /// **'Still tense'**
  String get pauseCheckInTense;

  /// No description provided for @pauseCheckInNeutral.
  ///
  /// In en, this message translates to:
  /// **'A little calmer'**
  String get pauseCheckInNeutral;

  /// No description provided for @pauseCheckInCalm.
  ///
  /// In en, this message translates to:
  /// **'It lifted'**
  String get pauseCheckInCalm;

  /// No description provided for @pauseNotifAction.
  ///
  /// In en, this message translates to:
  /// **'A minute of breath'**
  String get pauseNotifAction;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get healthTitle;

  /// No description provided for @healthAnswered.
  ///
  /// In en, this message translates to:
  /// **'iOS asks this only once, and it already has. Use the steps below to change it.'**
  String get healthAnswered;

  /// No description provided for @healthConnect.
  ///
  /// In en, this message translates to:
  /// **'Save pauses to Apple Health'**
  String get healthConnect;

  /// No description provided for @healthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Health isn\'t available on this device.'**
  String get healthUnavailable;

  /// No description provided for @healthManageNote.
  ///
  /// In en, this message translates to:
  /// **'You can turn this off anytime in iPhone Settings → Privacy & Security → Health → Intended.'**
  String get healthManageNote;

  /// No description provided for @pauseHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Save to Apple Health?'**
  String get pauseHealthTitle;

  /// No description provided for @pauseHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Each completed pause can appear in Apple Health as a mindful minute — your answer here too. Intended never reads anything from Health.'**
  String get pauseHealthBody;

  /// No description provided for @pauseHealthSave.
  ///
  /// In en, this message translates to:
  /// **'Save to Health'**
  String get pauseHealthSave;

  /// No description provided for @breathCircleCaption.
  ///
  /// In en, this message translates to:
  /// **'one circle = one minute of breath'**
  String get breathCircleCaption;

  /// No description provided for @returnOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'If you\'re ever away again'**
  String get returnOfferTitle;

  /// No description provided for @returnOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Intended can send you one gentle note. Right now we can\'t reach you: notifications are off.'**
  String get returnOfferBody;

  /// No description provided for @returnOfferAccept.
  ///
  /// In en, this message translates to:
  /// **'Send me a note next time'**
  String get returnOfferAccept;

  /// No description provided for @returnOfferDismiss.
  ///
  /// In en, this message translates to:
  /// **'I\'ll come back on my own'**
  String get returnOfferDismiss;

  /// Widget eyebrow: how many moments this month. Joined with ' · ' to the month name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} moment} other{{count} moments}}'**
  String widgetMomentsCount(int count);

  /// Widget eyebrow: returns after quiet stretches this month. Only rendered when count > 0.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{back once} other{back {count} times}}'**
  String widgetReturnsCount(int count);

  /// Large widget, not subscribed: caption under the faded month mosaic.
  ///
  /// In en, this message translates to:
  /// **'Intended+ — the whole month in colour'**
  String get widgetMonthUnlock;

  /// No description provided for @gratitudeDoor.
  ///
  /// In en, this message translates to:
  /// **'a page of gratitude'**
  String get gratitudeDoor;

  /// No description provided for @gratitudeTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you thankful for?'**
  String get gratitudeTitle;

  /// No description provided for @gratitudeHint.
  ///
  /// In en, this message translates to:
  /// **'Five each is plenty. Fewer is fine.'**
  String get gratitudeHint;

  /// No description provided for @gratitudeToYourself.
  ///
  /// In en, this message translates to:
  /// **'TO YOURSELF'**
  String get gratitudeToYourself;

  /// No description provided for @gratitudeToOthers.
  ///
  /// In en, this message translates to:
  /// **'TO OTHERS'**
  String get gratitudeToOthers;

  /// No description provided for @gratitudeSelfPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'something you\'re glad you did'**
  String get gratitudeSelfPlaceholder;

  /// No description provided for @gratitudeOthersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'someone you\'re glad about, and why'**
  String get gratitudeOthersPlaceholder;

  /// No description provided for @gratitudeAddAnother.
  ///
  /// In en, this message translates to:
  /// **'add another'**
  String get gratitudeAddAnother;

  /// No description provided for @gratitudeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get gratitudeDone;

  /// No description provided for @gratitudeSideFull.
  ///
  /// In en, this message translates to:
  /// **'Ten is as many as a page holds.'**
  String get gratitudeSideFull;

  /// No description provided for @gratitudePagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} page} other{{count} pages}}'**
  String gratitudePagesCount(int count);

  /// No description provided for @gratitudePastPages.
  ///
  /// In en, this message translates to:
  /// **'Past pages'**
  String get gratitudePastPages;

  /// No description provided for @gratitudeCadenceTitle.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get gratitudeCadenceTitle;

  /// No description provided for @gratitudeCadenceBody.
  ///
  /// In en, this message translates to:
  /// **'Weekly keeps it fresh for some people. Daily builds the rhythm for others.'**
  String get gratitudeCadenceBody;

  /// No description provided for @gratitudeCadenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get gratitudeCadenceDaily;

  /// No description provided for @gratitudeCadenceDailySub.
  ///
  /// In en, this message translates to:
  /// **'A page each night.'**
  String get gratitudeCadenceDailySub;

  /// No description provided for @gratitudeCadenceFew.
  ///
  /// In en, this message translates to:
  /// **'A few days a week'**
  String get gratitudeCadenceFew;

  /// No description provided for @gratitudeCadenceFewSub.
  ///
  /// In en, this message translates to:
  /// **'Three evenings a week.'**
  String get gratitudeCadenceFewSub;

  /// No description provided for @gratitudeCadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Once a week'**
  String get gratitudeCadenceWeekly;

  /// No description provided for @gratitudeCadenceWeeklySub.
  ///
  /// In en, this message translates to:
  /// **'One longer sit.'**
  String get gratitudeCadenceWeeklySub;

  /// No description provided for @gratitudeRemindAt.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get gratitudeRemindAt;

  /// No description provided for @gratitudeChangeWhenever.
  ///
  /// In en, this message translates to:
  /// **'Change it whenever.'**
  String get gratitudeChangeWhenever;

  /// No description provided for @gratitudeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get gratitudeStart;

  /// No description provided for @notifGratitudeBody.
  ///
  /// In en, this message translates to:
  /// **'A page of thanks, if you have a minute.'**
  String get notifGratitudeBody;

  /// No description provided for @notifGratitudeChannelName.
  ///
  /// In en, this message translates to:
  /// **'Gratitude page'**
  String get notifGratitudeChannelName;

  /// No description provided for @notifGratitudeChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'The evening reminder for your gratitude page'**
  String get notifGratitudeChannelDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
