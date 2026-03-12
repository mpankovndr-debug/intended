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

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

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

  /// No description provided for @appUnlockPlus.
  ///
  /// In en, this message translates to:
  /// **'Unlock Intended+'**
  String get appUnlockPlus;

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

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkipForNow;

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
  /// **'Productivity'**
  String get focusAreaProductivity;

  /// No description provided for @focusAreaProductivitySub.
  ///
  /// In en, this message translates to:
  /// **'One thing at a time. That\'s plenty.'**
  String get focusAreaProductivitySub;

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

  /// No description provided for @focusAreaFinancesSub.
  ///
  /// In en, this message translates to:
  /// **'Tiny money moves, real peace of mind.'**
  String get focusAreaFinancesSub;

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

  /// No description provided for @focusAreasTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus areas'**
  String get focusAreasTitle;

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

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderTitle;

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
  /// **'Every Sunday evening'**
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
  /// **'Deep Focus and more themes are available with Intended+. Try it free for 7 days after setup.'**
  String get themeSelectionPremiumHint;

  /// No description provided for @habitRevealTitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what we picked for you'**
  String get habitRevealTitle;

  /// No description provided for @habitRevealSubtitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Based on your preferences'**
  String get habitRevealSubtitleDefault;

  /// No description provided for @habitRevealSubtitleOneArea.
  ///
  /// In en, this message translates to:
  /// **'Based on {area}'**
  String habitRevealSubtitleOneArea(String area);

  /// No description provided for @habitRevealSubtitleTwoAreas.
  ///
  /// In en, this message translates to:
  /// **'Based on {area1} & {area2}'**
  String habitRevealSubtitleTwoAreas(String area1, String area2);

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

  /// No description provided for @habitsHoldForOptions.
  ///
  /// In en, this message translates to:
  /// **'Long press a habit for options'**
  String get habitsHoldForOptions;

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

  /// No description provided for @habitsSuggestions.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTIONS'**
  String get habitsSuggestions;

  /// No description provided for @habitsCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create custom habit'**
  String get habitsCreateCustom;

  /// No description provided for @habitsBrowseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all habits'**
  String get habitsBrowseAll;

  /// No description provided for @habitsMoreAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} more available'**
  String habitsMoreAvailable(int count);

  /// No description provided for @habitBreath.
  ///
  /// In en, this message translates to:
  /// **'Three slow breaths'**
  String get habitBreath;

  /// No description provided for @habitPause.
  ///
  /// In en, this message translates to:
  /// **'Ten-second pause'**
  String get habitPause;

  /// No description provided for @habitWater.
  ///
  /// In en, this message translates to:
  /// **'Mindful water'**
  String get habitWater;

  /// No description provided for @habitStretch.
  ///
  /// In en, this message translates to:
  /// **'Gentle stretch'**
  String get habitStretch;

  /// No description provided for @habitPriority.
  ///
  /// In en, this message translates to:
  /// **'One priority'**
  String get habitPriority;

  /// No description provided for @habitCheckin.
  ///
  /// In en, this message translates to:
  /// **'Honest check-in'**
  String get habitCheckin;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayShortMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayShortMon;

  /// No description provided for @dayShortTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayShortTue;

  /// No description provided for @dayShortWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayShortWed;

  /// No description provided for @dayShortThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayShortThu;

  /// No description provided for @dayShortFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayShortFri;

  /// No description provided for @dayShortSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dayShortSat;

  /// No description provided for @dayShortSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dayShortSun;

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

  /// No description provided for @dailyMessage1.
  ///
  /// In en, this message translates to:
  /// **'Do what feels right today'**
  String get dailyMessage1;

  /// No description provided for @dailyMessage2.
  ///
  /// In en, this message translates to:
  /// **'Today is a fresh start'**
  String get dailyMessage2;

  /// No description provided for @dailyMessage3.
  ///
  /// In en, this message translates to:
  /// **'Just one small thing counts'**
  String get dailyMessage3;

  /// No description provided for @dailyMessage4.
  ///
  /// In en, this message translates to:
  /// **'Be kind to yourself today'**
  String get dailyMessage4;

  /// No description provided for @dailyMessage5.
  ///
  /// In en, this message translates to:
  /// **'No rush. You\'re doing well'**
  String get dailyMessage5;

  /// No description provided for @dailyMessage6.
  ///
  /// In en, this message translates to:
  /// **'Start small, stay gentle'**
  String get dailyMessage6;

  /// No description provided for @dailyMessage7.
  ///
  /// In en, this message translates to:
  /// **'Your pace is your own'**
  String get dailyMessage7;

  /// No description provided for @dailyMessage8.
  ///
  /// In en, this message translates to:
  /// **'Even one step is progress'**
  String get dailyMessage8;

  /// No description provided for @dailyMessage9.
  ///
  /// In en, this message translates to:
  /// **'Take what works, leave the rest'**
  String get dailyMessage9;

  /// No description provided for @dailyMessage10.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to do it all'**
  String get dailyMessage10;

  /// No description provided for @dailyMessage11.
  ///
  /// In en, this message translates to:
  /// **'Small moments add up'**
  String get dailyMessage11;

  /// No description provided for @dailyMessage12.
  ///
  /// In en, this message translates to:
  /// **'Be where you are right now'**
  String get dailyMessage12;

  /// No description provided for @dailyMessage13.
  ///
  /// In en, this message translates to:
  /// **'There\'s no wrong way to begin'**
  String get dailyMessage13;

  /// No description provided for @dailyMessage14.
  ///
  /// In en, this message translates to:
  /// **'Listen to what you need today'**
  String get dailyMessage14;

  /// No description provided for @dailyMessage15.
  ///
  /// In en, this message translates to:
  /// **'Progress looks different every day'**
  String get dailyMessage15;

  /// No description provided for @dailyMessage16.
  ///
  /// In en, this message translates to:
  /// **'You\'re allowed to take your time'**
  String get dailyMessage16;

  /// No description provided for @dailyMessage17.
  ///
  /// In en, this message translates to:
  /// **'One thing at a time is enough'**
  String get dailyMessage17;

  /// No description provided for @dailyMessage18.
  ///
  /// In en, this message translates to:
  /// **'Start wherever you are'**
  String get dailyMessage18;

  /// No description provided for @dailyMessage19.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to be ready'**
  String get dailyMessage19;

  /// No description provided for @dailyMessage20.
  ///
  /// In en, this message translates to:
  /// **'Trust your own rhythm'**
  String get dailyMessage20;

  /// No description provided for @dailyMessage21.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to adjust as you go'**
  String get dailyMessage21;

  /// No description provided for @dailyMessage22.
  ///
  /// In en, this message translates to:
  /// **'Small acts of care matter'**
  String get dailyMessage22;

  /// No description provided for @dailyMessage23.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing more than you think'**
  String get dailyMessage23;

  /// No description provided for @customHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Create custom habit'**
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

  /// No description provided for @editHabitSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editHabitSave;

  /// No description provided for @customHabitCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit created'**
  String get customHabitCreatedTitle;

  /// No description provided for @customHabitCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has been added to your habits.'**
  String customHabitCreatedMessage(String title);

  /// No description provided for @customHabitLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Create more habits?'**
  String get customHabitLimitTitle;

  /// No description provided for @customHabitLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Core: 2 custom habits\nIntended+: Unlimited custom habits'**
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

  /// No description provided for @swapErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t swap this habit. Please try again.'**
  String get swapErrorMessage;

  /// No description provided for @swapLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap this habit?'**
  String get swapLimitTitle;

  /// No description provided for @swapLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your free swaps this month.\n\nIntended+: Unlimited swaps'**
  String get swapLimitMessage;

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

  /// No description provided for @completionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did you do this today?'**
  String get completionQuestion;

  /// No description provided for @completionConfirm.
  ///
  /// In en, this message translates to:
  /// **'I did it'**
  String get completionConfirm;

  /// No description provided for @completionDecline.
  ///
  /// In en, this message translates to:
  /// **'No, not today'**
  String get completionDecline;

  /// No description provided for @celebrationNice.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get celebrationNice;

  /// No description provided for @celebrationWellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done'**
  String get celebrationWellDone;

  /// No description provided for @celebrationYouDidIt.
  ///
  /// In en, this message translates to:
  /// **'You did it'**
  String get celebrationYouDidIt;

  /// No description provided for @celebrationGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get celebrationGreat;

  /// No description provided for @celebrationWayToGo.
  ///
  /// In en, this message translates to:
  /// **'Way to go'**
  String get celebrationWayToGo;

  /// No description provided for @celebrationGoodJob.
  ///
  /// In en, this message translates to:
  /// **'Good job'**
  String get celebrationGoodJob;

  /// No description provided for @celebrationLovely.
  ///
  /// In en, this message translates to:
  /// **'Lovely'**
  String get celebrationLovely;

  /// No description provided for @celebrationThatCounts.
  ///
  /// In en, this message translates to:
  /// **'That counts'**
  String get celebrationThatCounts;

  /// No description provided for @completionMsg1.
  ///
  /// In en, this message translates to:
  /// **'Small steps like this matter.'**
  String get completionMsg1;

  /// No description provided for @completionMsg2.
  ///
  /// In en, this message translates to:
  /// **'You showed up today.'**
  String get completionMsg2;

  /// No description provided for @completionMsg3.
  ///
  /// In en, this message translates to:
  /// **'This is how change happens.'**
  String get completionMsg3;

  /// No description provided for @completionMsg4.
  ///
  /// In en, this message translates to:
  /// **'One step closer.'**
  String get completionMsg4;

  /// No description provided for @completionMsg5.
  ///
  /// In en, this message translates to:
  /// **'You did what you said you would.'**
  String get completionMsg5;

  /// No description provided for @completionMsg6.
  ///
  /// In en, this message translates to:
  /// **'That took effort. Good.'**
  String get completionMsg6;

  /// No description provided for @completionMsg7.
  ///
  /// In en, this message translates to:
  /// **'Another small victory.'**
  String get completionMsg7;

  /// No description provided for @completionMsg8.
  ///
  /// In en, this message translates to:
  /// **'You made it happen.'**
  String get completionMsg8;

  /// No description provided for @completionMsg9.
  ///
  /// In en, this message translates to:
  /// **'Progress is progress.'**
  String get completionMsg9;

  /// No description provided for @completionMsg10.
  ///
  /// In en, this message translates to:
  /// **'You followed through.'**
  String get completionMsg10;

  /// No description provided for @completionMsg11.
  ///
  /// In en, this message translates to:
  /// **'This counts.'**
  String get completionMsg11;

  /// No description provided for @completionMsg12.
  ///
  /// In en, this message translates to:
  /// **'You kept your word to yourself.'**
  String get completionMsg12;

  /// No description provided for @completionMsg13.
  ///
  /// In en, this message translates to:
  /// **'Well done.'**
  String get completionMsg13;

  /// No description provided for @completionMsg14.
  ///
  /// In en, this message translates to:
  /// **'You made time for this.'**
  String get completionMsg14;

  /// No description provided for @completionMsg15.
  ///
  /// In en, this message translates to:
  /// **'That\'s growth right there.'**
  String get completionMsg15;

  /// No description provided for @completionMsg16.
  ///
  /// In en, this message translates to:
  /// **'You pushed through.'**
  String get completionMsg16;

  /// No description provided for @completionMsg17.
  ///
  /// In en, this message translates to:
  /// **'Another habit built.'**
  String get completionMsg17;

  /// No description provided for @completionMsg18.
  ///
  /// In en, this message translates to:
  /// **'You committed and you did it.'**
  String get completionMsg18;

  /// No description provided for @completionMsg19.
  ///
  /// In en, this message translates to:
  /// **'This adds up.'**
  String get completionMsg19;

  /// No description provided for @completionMsg20.
  ///
  /// In en, this message translates to:
  /// **'You honored your intention.'**
  String get completionMsg20;

  /// No description provided for @insightWater1.
  ///
  /// In en, this message translates to:
  /// **'Even mild dehydration can affect mood and concentration.'**
  String get insightWater1;

  /// No description provided for @insightWater2.
  ///
  /// In en, this message translates to:
  /// **'Your brain is 75% water. Hydration affects cognitive function.'**
  String get insightWater2;

  /// No description provided for @insightWater3.
  ///
  /// In en, this message translates to:
  /// **'Drinking water can reduce fatigue by up to 14%.'**
  String get insightWater3;

  /// No description provided for @insightExercise1.
  ///
  /// In en, this message translates to:
  /// **'Just 10 minutes of movement increases blood flow to your brain.'**
  String get insightExercise1;

  /// No description provided for @insightExercise2.
  ///
  /// In en, this message translates to:
  /// **'Exercise releases endorphins that improve mood for hours.'**
  String get insightExercise2;

  /// No description provided for @insightExercise3.
  ///
  /// In en, this message translates to:
  /// **'Regular movement reduces anxiety as effectively as meditation.'**
  String get insightExercise3;

  /// No description provided for @insightWalk1.
  ///
  /// In en, this message translates to:
  /// **'Walking outdoors reduces cortisol levels within 20 minutes.'**
  String get insightWalk1;

  /// No description provided for @insightWalk2.
  ///
  /// In en, this message translates to:
  /// **'A 10-minute walk can boost creativity by 60%.'**
  String get insightWalk2;

  /// No description provided for @insightWalk3.
  ///
  /// In en, this message translates to:
  /// **'Walking improves memory recall by increasing hippocampal activity.'**
  String get insightWalk3;

  /// No description provided for @insightStretch1.
  ///
  /// In en, this message translates to:
  /// **'Stretching increases blood flow and reduces muscle tension.'**
  String get insightStretch1;

  /// No description provided for @insightStretch2.
  ///
  /// In en, this message translates to:
  /// **'Regular stretching can improve flexibility by 20% in just weeks.'**
  String get insightStretch2;

  /// No description provided for @insightStretch3.
  ///
  /// In en, this message translates to:
  /// **'Stretching triggers the parasympathetic nervous system, reducing stress.'**
  String get insightStretch3;

  /// No description provided for @insightSleep1.
  ///
  /// In en, this message translates to:
  /// **'Quality sleep strengthens memory consolidation by 40%.'**
  String get insightSleep1;

  /// No description provided for @insightSleep2.
  ///
  /// In en, this message translates to:
  /// **'Consistent sleep schedules regulate circadian rhythm and mood.'**
  String get insightSleep2;

  /// No description provided for @insightSleep3.
  ///
  /// In en, this message translates to:
  /// **'Sleep deprivation reduces cognitive performance like alcohol does.'**
  String get insightSleep3;

  /// No description provided for @insightBed1.
  ///
  /// In en, this message translates to:
  /// **'A consistent bedtime routine signals your brain to prepare for sleep.'**
  String get insightBed1;

  /// No description provided for @insightBed2.
  ///
  /// In en, this message translates to:
  /// **'Going to bed at the same time improves sleep quality by 25%.'**
  String get insightBed2;

  /// No description provided for @insightBed3.
  ///
  /// In en, this message translates to:
  /// **'Your body\'s natural melatonin production peaks with routine.'**
  String get insightBed3;

  /// No description provided for @insightBreathe1.
  ///
  /// In en, this message translates to:
  /// **'Deep breathing activates the vagus nerve, calming your nervous system.'**
  String get insightBreathe1;

  /// No description provided for @insightBreathe2.
  ///
  /// In en, this message translates to:
  /// **'Controlled breathing can reduce stress hormones within minutes.'**
  String get insightBreathe2;

  /// No description provided for @insightBreathe3.
  ///
  /// In en, this message translates to:
  /// **'Box breathing is used by Navy SEALs to manage high-stress situations.'**
  String get insightBreathe3;

  /// No description provided for @insightMeditate1.
  ///
  /// In en, this message translates to:
  /// **'Just 10 minutes of meditation increases gray matter in the brain.'**
  String get insightMeditate1;

  /// No description provided for @insightMeditate2.
  ///
  /// In en, this message translates to:
  /// **'Regular meditation reduces the size of the amygdala (fear center).'**
  String get insightMeditate2;

  /// No description provided for @insightMeditate3.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness practice improves emotional regulation over time.'**
  String get insightMeditate3;

  /// No description provided for @insightRead1.
  ///
  /// In en, this message translates to:
  /// **'Reading for 6 minutes can reduce stress levels by 68%.'**
  String get insightRead1;

  /// No description provided for @insightRead2.
  ///
  /// In en, this message translates to:
  /// **'Regular reading strengthens neural pathways and connectivity.'**
  String get insightRead2;

  /// No description provided for @insightRead3.
  ///
  /// In en, this message translates to:
  /// **'Reading before bed improves sleep quality more than screens.'**
  String get insightRead3;

  /// No description provided for @insightCall1.
  ///
  /// In en, this message translates to:
  /// **'Social connection is as important to health as exercise and diet.'**
  String get insightCall1;

  /// No description provided for @insightCall2.
  ///
  /// In en, this message translates to:
  /// **'A 10-minute conversation can reduce feelings of loneliness.'**
  String get insightCall2;

  /// No description provided for @insightCall3.
  ///
  /// In en, this message translates to:
  /// **'Voice contact releases oxytocin, the bonding hormone.'**
  String get insightCall3;

  /// No description provided for @insightFriend1.
  ///
  /// In en, this message translates to:
  /// **'Strong social ties can increase longevity by 50%.'**
  String get insightFriend1;

  /// No description provided for @insightFriend2.
  ///
  /// In en, this message translates to:
  /// **'Quality friendships reduce stress hormones significantly.'**
  String get insightFriend2;

  /// No description provided for @insightFriend3.
  ///
  /// In en, this message translates to:
  /// **'Social connection boosts immune system function.'**
  String get insightFriend3;

  /// No description provided for @insightWrite1.
  ///
  /// In en, this message translates to:
  /// **'Writing about emotions activates the prefrontal cortex, reducing stress.'**
  String get insightWrite1;

  /// No description provided for @insightWrite2.
  ///
  /// In en, this message translates to:
  /// **'Journaling can improve immune function and reduce symptoms.'**
  String get insightWrite2;

  /// No description provided for @insightWrite3.
  ///
  /// In en, this message translates to:
  /// **'Expressive writing helps process difficult experiences.'**
  String get insightWrite3;

  /// No description provided for @insightJournal1.
  ///
  /// In en, this message translates to:
  /// **'Daily journaling increases self-awareness and emotional clarity.'**
  String get insightJournal1;

  /// No description provided for @insightJournal2.
  ///
  /// In en, this message translates to:
  /// **'Writing down worries reduces rumination and anxiety.'**
  String get insightJournal2;

  /// No description provided for @insightJournal3.
  ///
  /// In en, this message translates to:
  /// **'Gratitude journaling rewires the brain for positivity over time.'**
  String get insightJournal3;

  /// No description provided for @insightVegetable1.
  ///
  /// In en, this message translates to:
  /// **'Eating vegetables increases gut bacteria diversity, improving mood.'**
  String get insightVegetable1;

  /// No description provided for @insightVegetable2.
  ///
  /// In en, this message translates to:
  /// **'Plant nutrients support neurotransmitter production.'**
  String get insightVegetable2;

  /// No description provided for @insightVegetable3.
  ///
  /// In en, this message translates to:
  /// **'Colorful vegetables contain antioxidants that protect brain cells.'**
  String get insightVegetable3;

  /// No description provided for @insightBreakfast1.
  ///
  /// In en, this message translates to:
  /// **'Eating breakfast stabilizes blood sugar and improves focus.'**
  String get insightBreakfast1;

  /// No description provided for @insightBreakfast2.
  ///
  /// In en, this message translates to:
  /// **'Morning nutrition jumpstarts your metabolism for the day.'**
  String get insightBreakfast2;

  /// No description provided for @insightBreakfast3.
  ///
  /// In en, this message translates to:
  /// **'Breakfast eaters have better cognitive performance.'**
  String get insightBreakfast3;

  /// No description provided for @insightPhone1.
  ///
  /// In en, this message translates to:
  /// **'Reducing screen time before bed improves sleep quality by 30%.'**
  String get insightPhone1;

  /// No description provided for @insightPhone2.
  ///
  /// In en, this message translates to:
  /// **'Blue light suppresses melatonin production for up to 3 hours.'**
  String get insightPhone2;

  /// No description provided for @insightPhone3.
  ///
  /// In en, this message translates to:
  /// **'Taking breaks from screens reduces eye strain and headaches.'**
  String get insightPhone3;

  /// No description provided for @insightScreen1.
  ///
  /// In en, this message translates to:
  /// **'Every hour away from screens improves mental clarity.'**
  String get insightScreen1;

  /// No description provided for @insightScreen2.
  ///
  /// In en, this message translates to:
  /// **'Digital detoxes reduce anxiety and improve real-world connection.'**
  String get insightScreen2;

  /// No description provided for @insightScreen3.
  ///
  /// In en, this message translates to:
  /// **'Screen breaks help maintain healthy dopamine regulation.'**
  String get insightScreen3;

  /// No description provided for @insightClean1.
  ///
  /// In en, this message translates to:
  /// **'A tidy space reduces cortisol levels and mental clutter.'**
  String get insightClean1;

  /// No description provided for @insightClean2.
  ///
  /// In en, this message translates to:
  /// **'Organized environments improve focus and productivity by 25%.'**
  String get insightClean2;

  /// No description provided for @insightClean3.
  ///
  /// In en, this message translates to:
  /// **'Cleaning is a form of physical activity that reduces stress.'**
  String get insightClean3;

  /// No description provided for @insightOrganize1.
  ///
  /// In en, this message translates to:
  /// **'Organization reduces decision fatigue throughout your day.'**
  String get insightOrganize1;

  /// No description provided for @insightOrganize2.
  ///
  /// In en, this message translates to:
  /// **'Clutter-free spaces improve cognitive processing.'**
  String get insightOrganize2;

  /// No description provided for @insightOrganize3.
  ///
  /// In en, this message translates to:
  /// **'An organized environment correlates with better sleep quality.'**
  String get insightOrganize3;

  /// No description provided for @insightDraw1.
  ///
  /// In en, this message translates to:
  /// **'Creative activities increase dopamine production naturally.'**
  String get insightDraw1;

  /// No description provided for @insightDraw2.
  ///
  /// In en, this message translates to:
  /// **'Art engages both brain hemispheres, improving neural connectivity.'**
  String get insightDraw2;

  /// No description provided for @insightDraw3.
  ///
  /// In en, this message translates to:
  /// **'Drawing reduces stress hormones within 45 minutes.'**
  String get insightDraw3;

  /// No description provided for @insightMusic1.
  ///
  /// In en, this message translates to:
  /// **'Playing music strengthens the corpus callosum in the brain.'**
  String get insightMusic1;

  /// No description provided for @insightMusic2.
  ///
  /// In en, this message translates to:
  /// **'Musical practice improves executive function and memory.'**
  String get insightMusic2;

  /// No description provided for @insightMusic3.
  ///
  /// In en, this message translates to:
  /// **'Music activates the reward system, releasing dopamine.'**
  String get insightMusic3;

  /// No description provided for @warmthMsg1.
  ///
  /// In en, this message translates to:
  /// **'That\'s okay. Tomorrow is still yours.'**
  String get warmthMsg1;

  /// No description provided for @warmthMsg2.
  ///
  /// In en, this message translates to:
  /// **'Rest counts too.'**
  String get warmthMsg2;

  /// No description provided for @warmthMsg3.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to every day. Just sometimes.'**
  String get warmthMsg3;

  /// No description provided for @warmthMsg4.
  ///
  /// In en, this message translates to:
  /// **'Not today — and that\'s allowed.'**
  String get warmthMsg4;

  /// No description provided for @warmthMsg5.
  ///
  /// In en, this message translates to:
  /// **'Be as kind to yourself as you\'d be to a friend.'**
  String get warmthMsg5;

  /// No description provided for @warmthMsg6.
  ///
  /// In en, this message translates to:
  /// **'The habit will be here when you\'re ready.'**
  String get warmthMsg6;

  /// No description provided for @warmthMsg7.
  ///
  /// In en, this message translates to:
  /// **'Even stepping back gently is still showing up.'**
  String get warmthMsg7;

  /// No description provided for @warmthMsg8.
  ///
  /// In en, this message translates to:
  /// **'Nothing is lost. You\'re still here.'**
  String get warmthMsg8;

  /// No description provided for @warmthMsg9.
  ///
  /// In en, this message translates to:
  /// **'Some days are for resting. This might be one of them.'**
  String get warmthMsg9;

  /// No description provided for @warmthMsg10.
  ///
  /// In en, this message translates to:
  /// **'Kindness toward yourself is a habit worth keeping.'**
  String get warmthMsg10;

  /// No description provided for @warmthMsg11.
  ///
  /// In en, this message translates to:
  /// **'No streak to break. No score to lose. Just you.'**
  String get warmthMsg11;

  /// No description provided for @warmthMsg12.
  ///
  /// In en, this message translates to:
  /// **'The gentlest days matter too.'**
  String get warmthMsg12;

  /// No description provided for @warmthMsg13.
  ///
  /// In en, this message translates to:
  /// **'You showed up enough today just by being here.'**
  String get warmthMsg13;

  /// No description provided for @warmthMsg14.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to let this one go.'**
  String get warmthMsg14;

  /// No description provided for @warmthMsg15.
  ///
  /// In en, this message translates to:
  /// **'Progress isn\'t only visible. Sometimes it\'s just surviving.'**
  String get warmthMsg15;

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
  /// **'Just checking in. Whatever you do today is enough.'**
  String get notifMsg3;

  /// No description provided for @notifMsg4.
  ///
  /// In en, this message translates to:
  /// **'One small habit. That\'s all.'**
  String get notifMsg4;

  /// No description provided for @notifMsg5.
  ///
  /// In en, this message translates to:
  /// **'You showed up yesterday. That already matters.'**
  String get notifMsg5;

  /// No description provided for @notifMsg6.
  ///
  /// In en, this message translates to:
  /// **'Today doesn\'t have to be perfect to be good.'**
  String get notifMsg6;

  /// No description provided for @notifMsg7.
  ///
  /// In en, this message translates to:
  /// **'Be as gentle with yourself as you\'d be with a friend.'**
  String get notifMsg7;

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

  /// No description provided for @notifMsg12.
  ///
  /// In en, this message translates to:
  /// **'One thing at a time. No pressure.'**
  String get notifMsg12;

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
  /// **'Even a little is more than nothing.'**
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

  /// No description provided for @notifMsg33.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been showing up. That consistency is rare.'**
  String get notifMsg33;

  /// No description provided for @notifMsg34.
  ///
  /// In en, this message translates to:
  /// **'Small rituals become the shape of a life.'**
  String get notifMsg34;

  /// No description provided for @notifMsg35.
  ///
  /// In en, this message translates to:
  /// **'You\'re not behind. You\'re exactly where you are.'**
  String get notifMsg35;

  /// No description provided for @notifMsg36.
  ///
  /// In en, this message translates to:
  /// **'The gentlest habits are often the most lasting.'**
  String get notifMsg36;

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

  /// No description provided for @notifMsg40.
  ///
  /// In en, this message translates to:
  /// **'You know yourself better than any app does. Trust that.'**
  String get notifMsg40;

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

  /// No description provided for @notifMsg43.
  ///
  /// In en, this message translates to:
  /// **'You\'ve made it through harder days than this.'**
  String get notifMsg43;

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

  /// No description provided for @notifMsg52.
  ///
  /// In en, this message translates to:
  /// **'You showed up. That\'s the whole thing.'**
  String get notifMsg52;

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

  /// No description provided for @notifMsg57.
  ///
  /// In en, this message translates to:
  /// **'You\'re in this for the long run. Slow is fine.'**
  String get notifMsg57;

  /// No description provided for @notifMsg58.
  ///
  /// In en, this message translates to:
  /// **'Today\'s effort is invisible now and undeniable later.'**
  String get notifMsg58;

  /// No description provided for @notifMsg59.
  ///
  /// In en, this message translates to:
  /// **'You are allowed to be a work in progress.'**
  String get notifMsg59;

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

  /// No description provided for @affirmation1.
  ///
  /// In en, this message translates to:
  /// **'Missing days doesn\'t erase what you\'ve already done.'**
  String get affirmation1;

  /// No description provided for @affirmation2.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to earn rest.'**
  String get affirmation2;

  /// No description provided for @affirmation3.
  ///
  /// In en, this message translates to:
  /// **'Three habits or one — both are enough.'**
  String get affirmation3;

  /// No description provided for @affirmation4.
  ///
  /// In en, this message translates to:
  /// **'The fact that you\'re here says something good about you.'**
  String get affirmation4;

  /// No description provided for @affirmation5.
  ///
  /// In en, this message translates to:
  /// **'Progress isn\'t about perfection, it\'s about showing up.'**
  String get affirmation5;

  /// No description provided for @affirmation6.
  ///
  /// In en, this message translates to:
  /// **'You\'re allowed to have off days.'**
  String get affirmation6;

  /// No description provided for @affirmation7.
  ///
  /// In en, this message translates to:
  /// **'Small actions count, even when they feel small.'**
  String get affirmation7;

  /// No description provided for @affirmation8.
  ///
  /// In en, this message translates to:
  /// **'You\'re not behind. You\'re exactly where you need to be.'**
  String get affirmation8;

  /// No description provided for @affirmation9.
  ///
  /// In en, this message translates to:
  /// **'Consistency is important, but so is self-compassion.'**
  String get affirmation9;

  /// No description provided for @affirmation10.
  ///
  /// In en, this message translates to:
  /// **'Your worth isn\'t measured by what you check off.'**
  String get affirmation10;

  /// No description provided for @affirmation11.
  ///
  /// In en, this message translates to:
  /// **'Some weeks are harder than others. That\'s just being human.'**
  String get affirmation11;

  /// No description provided for @affirmation12.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to do everything to be doing enough.'**
  String get affirmation12;

  /// No description provided for @affirmation13.
  ///
  /// In en, this message translates to:
  /// **'Rest is part of progress, not the opposite of it.'**
  String get affirmation13;

  /// No description provided for @affirmation14.
  ///
  /// In en, this message translates to:
  /// **'Showing up imperfectly is still showing up.'**
  String get affirmation14;

  /// No description provided for @affirmation15.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing better than you think you are.'**
  String get affirmation15;

  /// No description provided for @affirmation16.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to start over as many times as you need.'**
  String get affirmation16;

  /// No description provided for @affirmation17.
  ///
  /// In en, this message translates to:
  /// **'Your pace is your own. Comparison won\'t help.'**
  String get affirmation17;

  /// No description provided for @affirmation18.
  ///
  /// In en, this message translates to:
  /// **'Every attempt matters, even the ones that feel small.'**
  String get affirmation18;

  /// No description provided for @affirmation19.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to feel motivated to deserve kindness.'**
  String get affirmation19;

  /// No description provided for @affirmation20.
  ///
  /// In en, this message translates to:
  /// **'Progress can look like simply trying again tomorrow.'**
  String get affirmation20;

  /// No description provided for @affirmation21.
  ///
  /// In en, this message translates to:
  /// **'You\'re allowed to adjust your expectations.'**
  String get affirmation21;

  /// No description provided for @affirmation22.
  ///
  /// In en, this message translates to:
  /// **'Taking breaks doesn\'t mean you\'ve failed.'**
  String get affirmation22;

  /// No description provided for @affirmation23.
  ///
  /// In en, this message translates to:
  /// **'The hardest part is often just beginning. You did that.'**
  String get affirmation23;

  /// No description provided for @affirmation24.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need permission to take care of yourself.'**
  String get affirmation24;

  /// No description provided for @affirmation25.
  ///
  /// In en, this message translates to:
  /// **'Your best today might look different than yesterday. That\'s okay.'**
  String get affirmation25;

  /// No description provided for @affirmation26.
  ///
  /// In en, this message translates to:
  /// **'Struggling doesn\'t mean you\'re doing it wrong.'**
  String get affirmation26;

  /// No description provided for @affirmation27.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already done hard things. You can do this too.'**
  String get affirmation27;

  /// No description provided for @affirmation28.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay if your progress doesn\'t look like anyone else\'s.'**
  String get affirmation28;

  /// No description provided for @affirmation29.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to prove anything to anyone.'**
  String get affirmation29;

  /// No description provided for @affirmation30.
  ///
  /// In en, this message translates to:
  /// **'Sometimes just surviving the day is progress enough.'**
  String get affirmation30;

  /// No description provided for @affirmation31.
  ///
  /// In en, this message translates to:
  /// **'You\'re learning, even when it doesn\'t feel like it.'**
  String get affirmation31;

  /// No description provided for @affirmation32.
  ///
  /// In en, this message translates to:
  /// **'Being gentle with yourself is not giving up.'**
  String get affirmation32;

  /// No description provided for @affirmation33.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need a reason to be kind to yourself.'**
  String get affirmation33;

  /// No description provided for @affirmation34.
  ///
  /// In en, this message translates to:
  /// **'What you\'re doing right now is enough.'**
  String get affirmation34;

  /// No description provided for @affirmation35.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow is always a chance to try again.'**
  String get affirmation35;

  /// No description provided for @progressOnboardingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete onboarding to see your week'**
  String get progressOnboardingPrompt;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get progressTitle;

  /// No description provided for @progressWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY SUMMARY'**
  String get progressWeeklySummary;

  /// No description provided for @progressWeekBeginning.
  ///
  /// In en, this message translates to:
  /// **'Your week is just beginning.'**
  String get progressWeekBeginning;

  /// No description provided for @progressShowedUpOnce.
  ///
  /// In en, this message translates to:
  /// **'You showed up once this week.'**
  String get progressShowedUpOnce;

  /// No description provided for @progressShowedUpCount.
  ///
  /// In en, this message translates to:
  /// **'You showed up {count} times this week.'**
  String progressShowedUpCount(int count);

  /// No description provided for @progressMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String progressMore(int count);

  /// No description provided for @progressSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get progressSeeAll;

  /// No description provided for @progressShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get progressShowLess;

  /// No description provided for @progressYourMoments.
  ///
  /// In en, this message translates to:
  /// **'YOUR MOMENTS'**
  String get progressYourMoments;

  /// No description provided for @progressEarlierToday.
  ///
  /// In en, this message translates to:
  /// **'Earlier today'**
  String get progressEarlierToday;

  /// No description provided for @progressYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get progressYesterday;

  /// No description provided for @progressDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String progressDaysAgo(int count);

  /// No description provided for @progressMomentsCollected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 moment collected} other{{count} moments collected}}'**
  String progressMomentsCollected(int count);

  /// No description provided for @momentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your moments'**
  String get momentsTitle;

  /// No description provided for @momentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every habit you complete is saved to your collection.'**
  String get momentsSubtitle;

  /// No description provided for @momentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your moments will appear here.'**
  String get momentsEmptyTitle;

  /// No description provided for @momentsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Every habit you complete becomes part of your collection.'**
  String get momentsEmptyMessage;

  /// No description provided for @momentsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get momentsToday;

  /// No description provided for @momentsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get momentsYesterday;

  /// No description provided for @monthSummaryMoments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 moment in {month}} other{{count} moments in {month}}}'**
  String monthSummaryMoments(int count, String month);

  /// No description provided for @monthSummaryIntentions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 intention this month} other{{count} intentions this month}}'**
  String monthSummaryIntentions(int count);

  /// No description provided for @monthSummaryTopIntention.
  ///
  /// In en, this message translates to:
  /// **'Your most frequent intention: {intention}'**
  String monthSummaryTopIntention(String intention);

  /// No description provided for @momentsShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} moments'**
  String momentsShowAll(int count);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'See yourself more clearly'**
  String get paywallTitle;

  /// No description provided for @paywallDescription.
  ///
  /// In en, this message translates to:
  /// **'Intended+ turns your daily practice into lasting self-knowledge.'**
  String get paywallDescription;

  /// No description provided for @paywallFeature1.
  ///
  /// In en, this message translates to:
  /// **'Weekly reflections that reveal your patterns over time'**
  String get paywallFeature1;

  /// No description provided for @paywallFeature2.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget to stay gently connected'**
  String get paywallFeature2;

  /// No description provided for @paywallFeature3.
  ///
  /// In en, this message translates to:
  /// **'Curated packs: routines designed around how you actually live'**
  String get paywallFeature3;

  /// No description provided for @paywallFeature4.
  ///
  /// In en, this message translates to:
  /// **'10 themes to match your mood — including dark mode'**
  String get paywallFeature4;

  /// No description provided for @paywallFeature5.
  ///
  /// In en, this message translates to:
  /// **'Unlimited habits, swaps, and focus areas — grow without limits'**
  String get paywallFeature5;

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
  /// **'€39.99'**
  String get paywallYearlyPrice;

  /// No description provided for @paywallYearlyPeriod.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get paywallYearlyPeriod;

  /// No description provided for @paywallYearlySave.
  ///
  /// In en, this message translates to:
  /// **'Save 44%'**
  String get paywallYearlySave;

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
  /// **'€69.99'**
  String get paywallLifetimePrice;

  /// No description provided for @paywallLifetimePeriod.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get paywallLifetimePeriod;

  /// No description provided for @paywallLifetimeBadge.
  ///
  /// In en, this message translates to:
  /// **'Launch price'**
  String get paywallLifetimeBadge;

  /// No description provided for @paywallCtaTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day free trial'**
  String get paywallCtaTrial;

  /// No description provided for @paywallCtaLifetime.
  ///
  /// In en, this message translates to:
  /// **'Get lifetime access'**
  String get paywallCtaLifetime;

  /// No description provided for @paywallTrialHint.
  ///
  /// In en, this message translates to:
  /// **'7 days free, then {price}. Cancel anytime.'**
  String paywallTrialHint(String price);

  /// No description provided for @paywallLifetimeHint.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. No subscription.'**
  String get paywallLifetimeHint;

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
  /// **'UNLOCK INTENDED+'**
  String get profileUnlockPlus;

  /// No description provided for @profileFocusAreas.
  ///
  /// In en, this message translates to:
  /// **'Focus areas'**
  String get profileFocusAreas;

  /// No description provided for @profileYourMoments.
  ///
  /// In en, this message translates to:
  /// **'Your moments'**
  String get profileYourMoments;

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
  /// **'Every Sunday evening'**
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
  /// **'Delete profile data'**
  String get profileDeleteData;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Intended v1.0.0'**
  String get profileVersion;

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

  /// No description provided for @profileFocusLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your free change this month.'**
  String get profileFocusLimitMessage;

  /// No description provided for @profileFocusLimitOptions.
  ///
  /// In en, this message translates to:
  /// **'• Intended+: Unlimited'**
  String get profileFocusLimitOptions;

  /// No description provided for @profilePayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay €0.99'**
  String get profilePayAmount;

  /// No description provided for @profilePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get profilePaymentTitle;

  /// No description provided for @profileChangeSpace.
  ///
  /// In en, this message translates to:
  /// **'Change your space'**
  String get profileChangeSpace;

  /// No description provided for @profileRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh habits?'**
  String get profileRefreshTitle;

  /// No description provided for @profileRefreshMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a new set of habits based on your focus areas.'**
  String get profileRefreshMessage;

  /// No description provided for @profileRefreshSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits refreshed'**
  String get profileRefreshSuccessTitle;

  /// No description provided for @profileRefreshSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You have a new set of habits waiting for you.'**
  String get profileRefreshSuccessMessage;

  /// No description provided for @profileDailyLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get profileDailyLimitTitle;

  /// No description provided for @profileDailyLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve refreshed your habits 3 times today. Try again tomorrow, or upgrade to Intended+ for unlimited refreshes.'**
  String get profileDailyLimitMessage;

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

  /// No description provided for @profileChooseUpTo2.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 2 areas'**
  String get profileChooseUpTo2;

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

  /// No description provided for @browseHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Habits'**
  String get browseHabitsTitle;

  /// No description provided for @browseHabitsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} habits available'**
  String browseHabitsAvailable(int count);

  /// No description provided for @browseHabitsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search habits...'**
  String get browseHabitsSearch;

  /// No description provided for @browseAlreadyAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get browseAlreadyAddedTitle;

  /// No description provided for @browseAlreadyAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{habit}\" is already in your habits.'**
  String browseAlreadyAddedMessage(String habit);

  /// No description provided for @browseSwapLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap limit reached'**
  String get browseSwapLimitTitle;

  /// No description provided for @browseSwapConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap an existing habit?'**
  String get browseSwapConfirmTitle;

  /// No description provided for @browseSwapConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Replace one of your current habits with \"{habit}\".'**
  String browseSwapConfirmMessage(String habit);

  /// No description provided for @browseSwapRemainingCount.
  ///
  /// In en, this message translates to:
  /// **'You have {count} {count, plural, =1{swap} other{swaps}} remaining this month.'**
  String browseSwapRemainingCount(int count);

  /// No description provided for @browseChooseHabitToSwap.
  ///
  /// In en, this message translates to:
  /// **'Choose habit to swap'**
  String get browseChooseHabitToSwap;

  /// No description provided for @browseWhichToReplace.
  ///
  /// In en, this message translates to:
  /// **'Which habit to replace?'**
  String get browseWhichToReplace;

  /// No description provided for @browseChooseToReplaceMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose one of your current habits to replace with \"{habit}\"'**
  String browseChooseToReplaceMessage(String habit);

  /// No description provided for @browseHabitAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit added'**
  String get browseHabitAddedTitle;

  /// No description provided for @browseHabitAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{habit}\" has been added to your habits.'**
  String browseHabitAddedMessage(String habit);

  /// No description provided for @browseHabitAddedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get browseHabitAddedConfirm;

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
  /// **'Take 5 deep belly breaths'**
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

  /// No description provided for @habitSetPriority.
  ///
  /// In en, this message translates to:
  /// **'Set one priority today'**
  String get habitSetPriority;

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

  /// No description provided for @habitWriteIdea.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe from an unnecessary email list'**
  String get habitWriteIdea;

  /// No description provided for @habitFinishTinyTask.
  ///
  /// In en, this message translates to:
  /// **'Finish one tiny task'**
  String get habitFinishTinyTask;

  /// No description provided for @habitDeclutterDesk.
  ///
  /// In en, this message translates to:
  /// **'Declutter your desk'**
  String get habitDeclutterDesk;

  /// No description provided for @habitReviewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Review your calendar'**
  String get habitReviewCalendar;

  /// No description provided for @habitTurnOffNotification.
  ///
  /// In en, this message translates to:
  /// **'Turn off one notification'**
  String get habitTurnOffNotification;

  /// No description provided for @habitCloseTab.
  ///
  /// In en, this message translates to:
  /// **'Close unnecessary browser tabs'**
  String get habitCloseTab;

  /// No description provided for @habitArchiveEmails.
  ///
  /// In en, this message translates to:
  /// **'Archive 5 old emails'**
  String get habitArchiveEmails;

  /// No description provided for @habitUpdateTodo.
  ///
  /// In en, this message translates to:
  /// **'Update one to-do item'**
  String get habitUpdateTodo;

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
  /// **'Write a short story'**
  String get habitWriteSentence;

  /// No description provided for @habitDoodle.
  ///
  /// In en, this message translates to:
  /// **'Doodle for 5 minutes'**
  String get habitDoodle;

  /// No description provided for @habitCaptureIdea.
  ///
  /// In en, this message translates to:
  /// **'Capture one idea'**
  String get habitCaptureIdea;

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

  /// No description provided for @habitDrawShape.
  ///
  /// In en, this message translates to:
  /// **'Draw something simple'**
  String get habitDrawShape;

  /// No description provided for @habitHumTune.
  ///
  /// In en, this message translates to:
  /// **'Hum a tune you enjoy'**
  String get habitHumTune;

  /// No description provided for @habitRearrange.
  ///
  /// In en, this message translates to:
  /// **'Rearrange something small'**
  String get habitRearrange;

  /// No description provided for @habitTryNewWord.
  ///
  /// In en, this message translates to:
  /// **'Learn one new word'**
  String get habitTryNewWord;

  /// No description provided for @habitCreateTinyThing.
  ///
  /// In en, this message translates to:
  /// **'Play a short melody'**
  String get habitCreateTinyThing;

  /// No description provided for @habitPlayCreative.
  ///
  /// In en, this message translates to:
  /// **'Play with one creative medium'**
  String get habitPlayCreative;

  /// No description provided for @habitImagine.
  ///
  /// In en, this message translates to:
  /// **'Do a vocal warm-up'**
  String get habitImagine;

  /// No description provided for @habitCheckBalance.
  ///
  /// In en, this message translates to:
  /// **'Try one financial tip'**
  String get habitCheckBalance;

  /// No description provided for @habitMoveToSavings.
  ///
  /// In en, this message translates to:
  /// **'Move €3/\$3 to savings'**
  String get habitMoveToSavings;

  /// No description provided for @habitReviewSubscription.
  ///
  /// In en, this message translates to:
  /// **'Review one subscription'**
  String get habitReviewSubscription;

  /// No description provided for @habitNoteExpense.
  ///
  /// In en, this message translates to:
  /// **'Note 3 expenses'**
  String get habitNoteExpense;

  /// No description provided for @habitFinancialTip.
  ///
  /// In en, this message translates to:
  /// **'Read one financial tip'**
  String get habitFinancialTip;

  /// No description provided for @habitDeleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete one old receipt'**
  String get habitDeleteReceipt;

  /// No description provided for @habitUpdateBudget.
  ///
  /// In en, this message translates to:
  /// **'Treat yourself'**
  String get habitUpdateBudget;

  /// No description provided for @habitReviewBill.
  ///
  /// In en, this message translates to:
  /// **'Review necessity of one subscription'**
  String get habitReviewBill;

  /// No description provided for @habitPriceCheck.
  ///
  /// In en, this message translates to:
  /// **'Price-check one item before buying'**
  String get habitPriceCheck;

  /// No description provided for @habitWait24Hours.
  ///
  /// In en, this message translates to:
  /// **'Wait 24 hours before a big purchase'**
  String get habitWait24Hours;

  /// No description provided for @habitCelebrateMoneyWin.
  ///
  /// In en, this message translates to:
  /// **'Celebrate one money win'**
  String get habitCelebrateMoneyWin;

  /// No description provided for @habitSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Set one savings goal'**
  String get habitSavingsGoal;

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

  /// No description provided for @shareCardWeeklyCheckin.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get shareCardWeeklyCheckin;

  /// No description provided for @shareCardMilestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get shareCardMilestone;

  /// No description provided for @shareCardShowedUpPhrase.
  ///
  /// In en, this message translates to:
  /// **'I showed up for myself this week'**
  String get shareCardShowedUpPhrase;

  /// No description provided for @shareCardTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{time} other{times}}'**
  String shareCardTimes(int count);

  /// No description provided for @shareCardFocusedOn.
  ///
  /// In en, this message translates to:
  /// **'Focused on: {area}'**
  String shareCardFocusedOn(String area);

  /// No description provided for @shareCardTagline.
  ///
  /// In en, this message translates to:
  /// **'intention, not perfection'**
  String get shareCardTagline;

  /// No description provided for @shareCardWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get shareCardWeeks;

  /// No description provided for @shareCardMilestoneSubtext.
  ///
  /// In en, this message translates to:
  /// **'of being gentle with myself'**
  String get shareCardMilestoneSubtext;

  /// No description provided for @shareCardDescriptor.
  ///
  /// In en, this message translates to:
  /// **'intention, not perfection'**
  String get shareCardDescriptor;

  /// No description provided for @shareCardSubtitleSingular.
  ///
  /// In en, this message translates to:
  /// **'time I showed up this week'**
  String get shareCardSubtitleSingular;

  /// No description provided for @shareCardSubtitlePlural.
  ///
  /// In en, this message translates to:
  /// **'times I showed up this week'**
  String get shareCardSubtitlePlural;

  /// No description provided for @shareCardSubtitleDays.
  ///
  /// In en, this message translates to:
  /// **'days I showed up this week'**
  String get shareCardSubtitleDays;

  /// No description provided for @shareCardInsightTwoDays.
  ///
  /// In en, this message translates to:
  /// **'{day1} and {day2} are my days'**
  String shareCardInsightTwoDays(String day1, String day2);

  /// No description provided for @shareCardInsightOneDay.
  ///
  /// In en, this message translates to:
  /// **'{day} is my day'**
  String shareCardInsightOneDay(String day);

  /// No description provided for @shareCardInsightFocus.
  ///
  /// In en, this message translates to:
  /// **'Drawn to {area} this week'**
  String shareCardInsightFocus(String area);

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @sharePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to share?'**
  String get sharePickerTitle;

  /// No description provided for @shareWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'how many times you showed up this week'**
  String get shareWeeklySubtitle;

  /// No description provided for @shareShowingUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'your own way, your own pace'**
  String get shareShowingUpSubtitle;

  /// No description provided for @shareFocusAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'the area you keep returning to'**
  String get shareFocusAreaSubtitle;

  /// No description provided for @shareYourThingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'the habit that\'s sticking'**
  String get shareYourThingSubtitle;

  /// No description provided for @milestoneShowingUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Showing up'**
  String get milestoneShowingUpLabel;

  /// No description provided for @milestoneAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus area'**
  String get milestoneAreaLabel;

  /// No description provided for @milestoneIdentityLabel.
  ///
  /// In en, this message translates to:
  /// **'Your thing'**
  String get milestoneIdentityLabel;

  /// No description provided for @milestoneShowingUpHero.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{week} other{weeks}}'**
  String milestoneShowingUpHero(int count);

  /// No description provided for @milestoneShowingUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'of showing up — in your own way'**
  String get milestoneShowingUpSubtitle;

  /// No description provided for @milestoneAreaHero.
  ///
  /// In en, this message translates to:
  /// **'{area}'**
  String milestoneAreaHero(String area);

  /// No description provided for @milestoneAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'you keep coming back to what matters'**
  String get milestoneAreaSubtitle;

  /// No description provided for @milestoneIdentityHero.
  ///
  /// In en, this message translates to:
  /// **'{habit}'**
  String milestoneIdentityHero(String habit);

  /// No description provided for @milestoneIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'is becoming your thing'**
  String get milestoneIdentitySubtitle;

  /// No description provided for @boostCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Intended Boost — €1.99'**
  String get boostCardTitle;

  /// No description provided for @boostCardTitleDynamic.
  ///
  /// In en, this message translates to:
  /// **'Intended Boost — {price}'**
  String boostCardTitleDynamic(String price);

  /// No description provided for @boostCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock both dark themes.'**
  String get boostCardSubtitle;

  /// No description provided for @boostOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get boostOrDivider;

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

  /// No description provided for @boostBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus and Night Bloom — a calmer look for evening check-ins.'**
  String get boostBenefit1;

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

  /// No description provided for @boostOfferShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your progress?'**
  String get boostOfferShareTitle;

  /// No description provided for @boostOfferShareDesc.
  ///
  /// In en, this message translates to:
  /// **'Your journey is worth celebrating — share it with people you care about.'**
  String get boostOfferShareDesc;

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

  /// No description provided for @profileLocalDataNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on this device only.'**
  String get profileLocalDataNote;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Could not share. Please try again.'**
  String get shareError;

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

  /// No description provided for @reflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get reflectionTitle;

  /// No description provided for @reflectionAnchor7.
  ///
  /// In en, this message translates to:
  /// **'You showed up every single day this week. Not perfect — present.'**
  String get reflectionAnchor7;

  /// No description provided for @reflectionAnchor56.
  ///
  /// In en, this message translates to:
  /// **'You showed up {days} out of 7 days this week. That\'s {days} days you chose to try.'**
  String reflectionAnchor56(int days);

  /// No description provided for @reflectionAnchor34.
  ///
  /// In en, this message translates to:
  /// **'You showed up {days} days this week. That\'s {days} days you chose to try.'**
  String reflectionAnchor34(int days);

  /// No description provided for @reflectionAnchor12.
  ///
  /// In en, this message translates to:
  /// **'You checked in {days, plural, =1{1 time} other{{days} times}} this week. Even one day counts — you didn\'t disappear.'**
  String reflectionAnchor12(int days);

  /// No description provided for @reflectionAnchor0.
  ///
  /// In en, this message translates to:
  /// **'Quiet week. That\'s okay. You\'re here now, and that\'s what matters.'**
  String get reflectionAnchor0;

  /// No description provided for @reflectionPatternOneDay.
  ///
  /// In en, this message translates to:
  /// **'Looks like {dayName} is when you really show up. Three weeks in a row now.'**
  String reflectionPatternOneDay(String dayName);

  /// No description provided for @reflectionPatternTwoDays.
  ///
  /// In en, this message translates to:
  /// **'{dayName1} and {dayName2} seem to be your days.'**
  String reflectionPatternTwoDays(String dayName1, String dayName2);

  /// No description provided for @reflectionPatternNone.
  ///
  /// In en, this message translates to:
  /// **'Your rhythm is still finding its shape. That\'s normal — keep going.'**
  String get reflectionPatternNone;

  /// No description provided for @reflectionFocusDominant.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been drawn to {area} habits lately. That seems important to you right now.'**
  String reflectionFocusDominant(String area);

  /// No description provided for @reflectionFocusBalanced.
  ///
  /// In en, this message translates to:
  /// **'You spread your energy across {area1} and {area2} this week. A balanced week.'**
  String reflectionFocusBalanced(String area1, String area2);

  /// No description provided for @reflectionReframeComeback.
  ///
  /// In en, this message translates to:
  /// **'Last week was quieter. This week you came back. That\'s the whole point.'**
  String get reflectionReframeComeback;

  /// No description provided for @reflectionReframeRefresh.
  ///
  /// In en, this message translates to:
  /// **'You refreshed your habits {count} time(s) this week — that\'s not quitting, that\'s adapting.'**
  String reflectionReframeRefresh(int count);

  /// No description provided for @reflectionReframeSwap.
  ///
  /// In en, this message translates to:
  /// **'You swapped out a habit this week. Knowing what doesn\'t work is progress too.'**
  String get reflectionReframeSwap;

  /// No description provided for @reflectionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get reflectionShare;

  /// No description provided for @insightsGrowthHint.
  ///
  /// In en, this message translates to:
  /// **'Insights get sharper every week'**
  String get insightsGrowthHint;

  /// No description provided for @reflectionTeaser.
  ///
  /// In en, this message translates to:
  /// **'There\'s more to your week'**
  String get reflectionTeaser;

  /// No description provided for @reflectionSectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get reflectionSectionThisWeek;

  /// No description provided for @reflectionSectionYourRhythm.
  ///
  /// In en, this message translates to:
  /// **'YOUR RHYTHM'**
  String get reflectionSectionYourRhythm;

  /// No description provided for @reflectionSectionYourFocus.
  ///
  /// In en, this message translates to:
  /// **'YOUR FOCUS'**
  String get reflectionSectionYourFocus;

  /// No description provided for @reflectionSectionNotice.
  ///
  /// In en, this message translates to:
  /// **'SOMETHING TO NOTICE'**
  String get reflectionSectionNotice;

  /// No description provided for @reflectionPreviewRhythm.
  ///
  /// In en, this message translates to:
  /// **'After a few weeks, we\'ll show you which days you\'re most consistent'**
  String get reflectionPreviewRhythm;

  /// No description provided for @reflectionPreviewFocus.
  ///
  /// In en, this message translates to:
  /// **'Complete more habits to see what you\'re drawn to'**
  String get reflectionPreviewFocus;

  /// No description provided for @reflectionBlurRhythm.
  ///
  /// In en, this message translates to:
  /// **'See which days and patterns work best for you'**
  String get reflectionBlurRhythm;

  /// No description provided for @reflectionBlurFocus.
  ///
  /// In en, this message translates to:
  /// **'Discover where your energy goes each week'**
  String get reflectionBlurFocus;

  /// No description provided for @reflectionUnlockPlus.
  ///
  /// In en, this message translates to:
  /// **'See my weekly insights'**
  String get reflectionUnlockPlus;

  /// No description provided for @tipPinHabit.
  ///
  /// In en, this message translates to:
  /// **'Long press on a habit to pin it to the top'**
  String get tipPinHabit;

  /// No description provided for @tipCuratedPack.
  ///
  /// In en, this message translates to:
  /// **'Try a curated pack — find them in Browse all habits'**
  String get tipCuratedPack;

  /// No description provided for @tipWidget.
  ///
  /// In en, this message translates to:
  /// **'Add Intended to your home screen — long press your wallpaper and add a widget'**
  String get tipWidget;

  /// No description provided for @tipGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tipGotIt;

  /// No description provided for @tipSkipAll.
  ///
  /// In en, this message translates to:
  /// **'Skip tips'**
  String get tipSkipAll;

  /// No description provided for @packSwapTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for your new pack'**
  String get packSwapTitle;

  /// No description provided for @packSwapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To keep your space focused, pick which habits to set aside. Your custom habits will always stay.'**
  String get packSwapSubtitle;

  /// No description provided for @packSwapConfirm.
  ///
  /// In en, this message translates to:
  /// **'Set aside {count} and add {packName}'**
  String packSwapConfirm(int count, String packName);

  /// No description provided for @packSwapAdded.
  ///
  /// In en, this message translates to:
  /// **'added — {count} new habits ready to go'**
  String packSwapAdded(int count);

  /// No description provided for @packSwapAllActive.
  ///
  /// In en, this message translates to:
  /// **'All habits from this pack are already active'**
  String get packSwapAllActive;

  /// No description provided for @packSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'CURATED PACKS'**
  String get packSectionHeader;

  /// No description provided for @packHabitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 habit} other{{count} habits}}'**
  String packHabitsCount(int count);

  /// No description provided for @packFreeBadge.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get packFreeBadge;

  /// No description provided for @packStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start {packName}'**
  String packStartButton(String packName);

  /// No description provided for @packHabitsInPack.
  ///
  /// In en, this message translates to:
  /// **'HABITS IN THIS PACK'**
  String get packHabitsInPack;

  /// No description provided for @packAllActive.
  ///
  /// In en, this message translates to:
  /// **'All habits already active'**
  String get packAllActive;

  /// No description provided for @packHabitActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get packHabitActive;

  /// No description provided for @packActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get packActiveBadge;

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

  /// No description provided for @packGentleMorningsDescription.
  ///
  /// In en, this message translates to:
  /// **'Four tiny habits that work as a gentle sequence — hydrate, breathe fresh air, center yourself, then orient your day. No alarms at dawn required.'**
  String get packGentleMorningsDescription;

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

  /// No description provided for @packWindingDownDescription.
  ///
  /// In en, this message translates to:
  /// **'A small ritual for letting the day go. Stop, reflect, get comfortable, enjoy one thing. That\'s the whole evening plan.'**
  String get packWindingDownDescription;

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

  /// No description provided for @packTinyResetsDescription.
  ///
  /// In en, this message translates to:
  /// **'When overwhelm hits, these four micro-actions create a small pocket of control. Not a productivity system — a rescue kit.'**
  String get packTinyResetsDescription;

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

  /// No description provided for @packCreativeSparkDescription.
  ///
  /// In en, this message translates to:
  /// **'Three tiny creative habits that get you out of your head and into your hands. Not about being good — about being playful.'**
  String get packCreativeSparkDescription;

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

  /// No description provided for @packStayConnectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Four micro-habits for staying close to the people in your life. Not grand gestures — just showing up.'**
  String get packStayConnectedDescription;

  /// No description provided for @widgetToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get widgetToday;

  /// No description provided for @widgetMore.
  ///
  /// In en, this message translates to:
  /// **'+{n} more'**
  String widgetMore(int n);

  /// No description provided for @widgetUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to see more'**
  String get widgetUpgrade;

  /// No description provided for @widgetNoHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get widgetNoHabits;

  /// No description provided for @widgetAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get widgetAllDone;

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
