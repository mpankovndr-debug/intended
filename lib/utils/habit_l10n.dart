import '../l10n/app_localizations.dart';

/// Translates a stored English habit name to the user's current locale.
/// Custom habits (not in the map) are returned as-is.
String localizeHabitName(String englishName, AppLocalizations l10n) {
  final getter = _habitNameGetters[englishName];
  if (getter != null) return getter(l10n);
  return englishName; // custom habit — not translatable
}

/// Translates a stored English category name to the user's current locale.
String localizeCategoryName(String englishName, AppLocalizations l10n) {
  final getter = _categoryNameGetters[englishName];
  if (getter != null) return getter(l10n);
  return englishName;
}

/// Translates a list of stored English category names and joins them into one
/// phrase in the reader's language.
///
/// The joiner belongs here beside the resolver, not in the screen that needs
/// it: `join(' and ')` in a screen is how a Russian reader ended up with
/// "Health and Mindfulness" inside an otherwise Russian sentence. Anything
/// before the final pair is joined with commas, which both languages share.
String localizeCategoryList(List<String> englishNames, AppLocalizations l10n) {
  final names =
      englishNames.map((n) => localizeCategoryName(n, l10n)).toList();
  if (names.isEmpty) return '';
  if (names.length == 1) return names.first;
  return l10n.commonListAnd(
    names.sublist(0, names.length - 1).join(', '),
    names.last,
  );
}

typedef _L10nGetter = String Function(AppLocalizations);

const Map<String, _L10nGetter> _categoryNameGetters = {
  'Health': _catHealth,
  'Mood': _catMood,
  'Doing one thing': _catProductivity,
  // Renamed from 'Productivity'. Moments recorded before the rename carry
  // the old string and are never rewritten, so both keys must resolve.
  'Productivity': _catProductivity,
  'Home & organization': _catHome,
  'Relationships': _catRelationships,
  'Creativity': _catCreativity,
  'Finances': _catFinances,
  'Self-care': _catSelfCare,
};

String _catHealth(AppLocalizations l10n) => l10n.focusAreaHealth;
String _catMood(AppLocalizations l10n) => l10n.focusAreaMood;
String _catProductivity(AppLocalizations l10n) => l10n.focusAreaProductivity;
String _catHome(AppLocalizations l10n) => l10n.focusAreaHome;
String _catRelationships(AppLocalizations l10n) => l10n.focusAreaRelationships;
String _catCreativity(AppLocalizations l10n) => l10n.focusAreaCreativity;
String _catFinances(AppLocalizations l10n) => l10n.focusAreaFinances;
String _catSelfCare(AppLocalizations l10n) => l10n.focusAreaSelfCare;

const Map<String, _L10nGetter> _habitNameGetters = {
  // Health
  'Drink 3 glasses of water': _hDrinkWater,
  'Screens away 20 minutes before bed': _hScreensAwayBed,
  'Dim the lights an hour before sleep': _hDimLights,
  'One meal without your phone': _hMealWithoutPhone,
  'Take 3 slow breaths': _hThreeSlowBreaths,
  'Stretch for 30 seconds': _hStretchTenSeconds,
  'Stand up and roll your shoulders': _hRollShoulders,
  'Step outside for 5 minutes': _hStepOutside,
  'Close your eyes for 30 seconds': _hCloseEyes,
  'Do 5 gentle neck rolls': _hNeckRolls,
  'Walk to the window and back': _hWalkToWindow,
  'Take 5 slow, deep breaths': _hBellyBreaths,
  '2-minute body scan': _hBodyScan,
  '5 minutes of gentle stretching': _hGentleMovement,
  'Eat one meal mindfully': _hMindfulMeal,
  "Eat after waking up": _hEatAfterWaking,
  "Eat one proper meal": _hProperMeal,
  "Drink something warm": _hDrinkWarm,
  "Take your medication": _hTakeMedication,
  "Get outside for a few minutes": _hGetOutside,
  "Move your body a little": _hMoveBody,
  "Get into bed early": _hBedEarly,

  // Mood
  'One-minute pause': _hTenSecondPause,
  'Notice one thing you feel': _hNoticeFeeling,
  'Three grounding breaths': _hGroundingBreath,
  'Look away from your screen for 30 seconds': _hLookAway,
  'Name three things you can see': _hNameThreeThings,
  'Notice one sound around you': _hNoticeSound,
  'Feel your feet on the ground': _hFeelFeet,
  'Place hand on heart for 30 seconds': _hHandOnHeart,
  "Name 3 things you're grateful for": _hGratefulThing,
  'Smile kindly at yourself': _hSmileGently,
  'Ask yourself "what do I need right now?"': _hAskNeed,
  'Give yourself permission to rest': _hPermissionToRest,

  // Moved here when Doing one thing was removed; stored titles unchanged,
  // so completion history and habit_done_* keys survive.
  'Plan tomorrow in one sentence': _hPlanTomorrow,
  'Do a 1-minute reset': _hThirtySecondReset,

  // Home & organization
  'Tidy one small thing': _hTidyOneThing,
  'Put one thing back where it belongs': _hPutBack,
  'Wipe one surface': _hWipeSurface,
  'Open a window for fresh air': _hFreshAir,
  'Make your bed': _hMakeBed,
  'Clear one shelf': _hClearShelf,
  'Wash 3 dishes': _hWashDishes,
  'Take out one bag of trash': _hTakeOutTrash,
  'Fold 3 items of clothing': _hFoldClothing,
  'Organize one drawer': _hOrganizeDrawer,
  'Water your plants': _hWaterPlant,
  'Light a scented candle': _hLightCandle,

  // Relationships
  'Send one message to someone you care about': _hSendMessage,
  'Think of one person you appreciate': _hAppreciatePerson,
  'Ask someone how they are': _hAskHowAreYou,
  'Give one genuine compliment': _hGiveCompliment,
  'Call someone you care about': _hCallSomeone,
  'Share something that made you smile': _hShareSmile,
  'Thank someone today': _hThankSomeone,
  'Listen without planning your response': _hListenFully,
  'Reach out to someone you miss': _hReachOut,
  'Tell someone what they mean to you': _hTellMeaning,
  'Offer help to someone': _hOfferHelp,
  "Celebrate someone else's win": _hCelebrateOthers,

  // Creativity
  "Write down what's in your head": _hWriteSentence,
  'Doodle for 5 minutes': _hDoodle,
  'Notice one beautiful thing': _hNoticeBeauty,
  'Take one photo of something you like': _hTakePhoto,
  'Hum a tune you enjoy': _hHumTune,
  'Learn one new word': _hTryNewWord,

  // Self-care
  'Sit still for 1 minute': _hSitStill,
  'Do one kind thing for yourself': _hKindThing,
  'Drink a cup of tasty coffee': _hDrinkSlowly,
  'Stretch your neck': _hStretchNeck,
  'Take one slow breath': _hOneSlowBreath,
  'Notice something you like about yourself': _hNoticeLikeAboutSelf,
  'Give yourself permission to say no': _hPermissionSayNo,
  'Do something that feels good': _hFeelGood,
  'Rest for 5 minutes': _hRestTwoMinutes,
  'Put on something comfortable': _hPutOnComfortable,
  'Listen to one song you love': _hListenToSong,
  'Do absolutely nothing for 5 minutes': _hDoNothing,
  "Get out of bed": _hGetOutOfBed,
  "Brush your teeth": _hBrushTeeth,
  "Wash your face": _hWashFace,
  "Take a shower": _hTakeShower,
  "Put on clean clothes": _hCleanClothes,
  "Brush your hair": _hBrushHair,
  "Open the curtains": _hOpenCurtains,
  "Turn on a lamp": _hTurnOnLamp,
  "Leave your phone across the room": _hPhoneAcrossRoom,
  // Renamed titles. The stored string was aligned to what app_en.arb
  // renders, but user_habits and recorded moments still carry the old one
  // and are never rewritten — so both keys must resolve, or a Russian
  // reader sees raw English on a held card and in their month.
  'Drink a glass of water': _hDrinkWater,
  'Stretch for 10 seconds': _hStretchTenSeconds,
  'Step outside for 30 seconds': _hStepOutside,
  'Close your eyes for 20 seconds': _hCloseEyes,
  'Take 5 deep belly breaths': _hBellyBreaths,
  '10 minutes of gentle movement': _hGentleMovement,
  'Ten-second pause': _hTenSecondPause,
  'One grounding breath': _hGroundingBreath,
  'Look away from your screen for 10 seconds': _hLookAway,
  'Place hand on heart for a moment': _hHandOnHeart,
  "Notice one thing you're grateful for": _hGratefulThing,
  'Smile gently at yourself': _hSmileGently,
  'Do a 30-second reset': _hThirtySecondReset,
  'Take out one small bag of trash': _hTakeOutTrash,
  'Water one plant': _hWaterPlant,
  'Light a candle': _hLightCandle,
  'Send one message to someone': _hSendMessage,
  'Doodle for 10 seconds': _hDoodle,
  'Try one new word': _hTryNewWord,
  'Sit still for 10 seconds': _hSitStill,
  'Drink water slowly': _hDrinkSlowly,
  'Rest for 2 minutes': _hRestTwoMinutes,
  'Do absolutely nothing for 30 seconds': _hDoNothing,
};

// Health
String _hDrinkWater(AppLocalizations l) => l.habitDrinkWater;
String _hScreensAwayBed(AppLocalizations l) => l.habitScreensAwayBed;
String _hDimLights(AppLocalizations l) => l.habitDimLights;
String _hMealWithoutPhone(AppLocalizations l) => l.habitMealWithoutPhone;
String _hThreeSlowBreaths(AppLocalizations l) => l.habitThreeSlowBreaths;
String _hStretchTenSeconds(AppLocalizations l) => l.habitStretchTenSeconds;
String _hRollShoulders(AppLocalizations l) => l.habitRollShoulders;
String _hStepOutside(AppLocalizations l) => l.habitStepOutside;
String _hCloseEyes(AppLocalizations l) => l.habitCloseEyes;
String _hNeckRolls(AppLocalizations l) => l.habitNeckRolls;
String _hWalkToWindow(AppLocalizations l) => l.habitWalkToWindow;
String _hBellyBreaths(AppLocalizations l) => l.habitBellyBreaths;
String _hBodyScan(AppLocalizations l) => l.habitBodyScan;
String _hGentleMovement(AppLocalizations l) => l.habitGentleMovement;
String _hMindfulMeal(AppLocalizations l) => l.habitMindfulMeal;
String _hEatAfterWaking(AppLocalizations l) => l.habitEatAfterWaking;
String _hProperMeal(AppLocalizations l) => l.habitProperMeal;
String _hDrinkWarm(AppLocalizations l) => l.habitDrinkWarm;
String _hTakeMedication(AppLocalizations l) => l.habitTakeMedication;
String _hGetOutside(AppLocalizations l) => l.habitGetOutside;
String _hMoveBody(AppLocalizations l) => l.habitMoveBody;
String _hBedEarly(AppLocalizations l) => l.habitBedEarly;

// Mood
String _hTenSecondPause(AppLocalizations l) => l.habitTenSecondPause;
String _hNoticeFeeling(AppLocalizations l) => l.habitNoticeFeeling;
String _hGroundingBreath(AppLocalizations l) => l.habitGroundingBreath;
String _hLookAway(AppLocalizations l) => l.habitLookAway;
String _hNameThreeThings(AppLocalizations l) => l.habitNameThreeThings;
String _hNoticeSound(AppLocalizations l) => l.habitNoticeSound;
String _hFeelFeet(AppLocalizations l) => l.habitFeelFeet;
String _hHandOnHeart(AppLocalizations l) => l.habitHandOnHeart;
String _hGratefulThing(AppLocalizations l) => l.habitGratefulThing;
String _hSmileGently(AppLocalizations l) => l.habitSmileGently;
String _hAskNeed(AppLocalizations l) => l.habitAskNeed;
String _hPermissionToRest(AppLocalizations l) => l.habitPermissionToRest;

// Moved from Doing one thing
String _hPlanTomorrow(AppLocalizations l) => l.habitPlanTomorrow;
String _hThirtySecondReset(AppLocalizations l) => l.habitThirtySecondReset;

// Home & organization
String _hTidyOneThing(AppLocalizations l) => l.habitTidyOneThing;
String _hPutBack(AppLocalizations l) => l.habitPutBack;
String _hWipeSurface(AppLocalizations l) => l.habitWipeSurface;
String _hFreshAir(AppLocalizations l) => l.habitFreshAir;
String _hMakeBed(AppLocalizations l) => l.habitMakeBed;
String _hClearShelf(AppLocalizations l) => l.habitClearShelf;
String _hWashDishes(AppLocalizations l) => l.habitWashDishes;
String _hTakeOutTrash(AppLocalizations l) => l.habitTakeOutTrash;
String _hFoldClothing(AppLocalizations l) => l.habitFoldClothing;
String _hOrganizeDrawer(AppLocalizations l) => l.habitOrganizeDrawer;
String _hWaterPlant(AppLocalizations l) => l.habitWaterPlant;
String _hLightCandle(AppLocalizations l) => l.habitLightCandle;

// Relationships
String _hSendMessage(AppLocalizations l) => l.habitSendMessage;
String _hAppreciatePerson(AppLocalizations l) => l.habitAppreciatePerson;
String _hAskHowAreYou(AppLocalizations l) => l.habitAskHowAreYou;
String _hGiveCompliment(AppLocalizations l) => l.habitGiveCompliment;
String _hCallSomeone(AppLocalizations l) => l.habitCallSomeone;
String _hShareSmile(AppLocalizations l) => l.habitShareSmile;
String _hThankSomeone(AppLocalizations l) => l.habitThankSomeone;
String _hListenFully(AppLocalizations l) => l.habitListenFully;
String _hReachOut(AppLocalizations l) => l.habitReachOut;
String _hTellMeaning(AppLocalizations l) => l.habitTellMeaning;
String _hOfferHelp(AppLocalizations l) => l.habitOfferHelp;
String _hCelebrateOthers(AppLocalizations l) => l.habitCelebrateOthers;

// Creativity
String _hWriteSentence(AppLocalizations l) => l.habitWriteSentence;
String _hDoodle(AppLocalizations l) => l.habitDoodle;
String _hNoticeBeauty(AppLocalizations l) => l.habitNoticeBeauty;
String _hTakePhoto(AppLocalizations l) => l.habitTakePhoto;
String _hHumTune(AppLocalizations l) => l.habitHumTune;
String _hTryNewWord(AppLocalizations l) => l.habitTryNewWord;

// Self-care
String _hSitStill(AppLocalizations l) => l.habitSitStill;
String _hKindThing(AppLocalizations l) => l.habitKindThing;
String _hDrinkSlowly(AppLocalizations l) => l.habitDrinkSlowly;
String _hStretchNeck(AppLocalizations l) => l.habitStretchNeck;
String _hOneSlowBreath(AppLocalizations l) => l.habitOneSlowBreath;
String _hNoticeLikeAboutSelf(AppLocalizations l) => l.habitNoticeLikeAboutSelf;
String _hPermissionSayNo(AppLocalizations l) => l.habitPermissionSayNo;
String _hFeelGood(AppLocalizations l) => l.habitFeelGood;
String _hRestTwoMinutes(AppLocalizations l) => l.habitRestTwoMinutes;
String _hPutOnComfortable(AppLocalizations l) => l.habitPutOnComfortable;
String _hListenToSong(AppLocalizations l) => l.habitListenToSong;
String _hDoNothing(AppLocalizations l) => l.habitDoNothing;
String _hGetOutOfBed(AppLocalizations l) => l.habitGetOutOfBed;
String _hBrushTeeth(AppLocalizations l) => l.habitBrushTeeth;
String _hWashFace(AppLocalizations l) => l.habitWashFace;
String _hTakeShower(AppLocalizations l) => l.habitTakeShower;
String _hCleanClothes(AppLocalizations l) => l.habitCleanClothes;
String _hBrushHair(AppLocalizations l) => l.habitBrushHair;
String _hOpenCurtains(AppLocalizations l) => l.habitOpenCurtains;
String _hTurnOnLamp(AppLocalizations l) => l.habitTurnOnLamp;
String _hPhoneAcrossRoom(AppLocalizations l) => l.habitPhoneAcrossRoom;
