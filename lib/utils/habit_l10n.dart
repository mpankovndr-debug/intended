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

typedef _L10nGetter = String Function(AppLocalizations);

const Map<String, _L10nGetter> _categoryNameGetters = {
  'Health': _catHealth,
  'Mood': _catMood,
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
  'Drink a glass of water': _hDrinkWater,
  'Take 3 slow breaths': _hThreeSlowBreaths,
  'Stretch for 10 seconds': _hStretchTenSeconds,
  'Stand up and roll your shoulders': _hRollShoulders,
  'Step outside for 30 seconds': _hStepOutside,
  'Close your eyes for 20 seconds': _hCloseEyes,
  'Do 5 gentle neck rolls': _hNeckRolls,
  'Walk to the window and back': _hWalkToWindow,
  'Take 5 deep belly breaths': _hBellyBreaths,
  '2-minute body scan': _hBodyScan,
  '10 minutes of gentle movement': _hGentleMovement,
  'Eat one meal mindfully': _hMindfulMeal,

  // Mood
  'Ten-second pause': _hTenSecondPause,
  'Notice one thing you feel': _hNoticeFeeling,
  'One grounding breath': _hGroundingBreath,
  'Look away from your screen for 10 seconds': _hLookAway,
  'Name three things you can see': _hNameThreeThings,
  'Notice one sound around you': _hNoticeSound,
  'Feel your feet on the ground': _hFeelFeet,
  'Place hand on heart for a moment': _hHandOnHeart,
  "Notice one thing you're grateful for": _hGratefulThing,
  'Smile gently at yourself': _hSmileGently,
  'Ask yourself "what do I need right now?"': _hAskNeed,
  'Give yourself permission to rest': _hPermissionToRest,

  // Productivity
  'Set one priority': _hSetPriority,
  'Clear one small thing': _hClearSmallThing,
  'Plan tomorrow in one sentence': _hPlanTomorrow,
  'Do a 30-second reset': _hThirtySecondReset,
  'Write down one idea': _hWriteIdea,
  'Finish one tiny task': _hFinishTinyTask,
  'Declutter your desk for 2 minutes': _hDeclutterDesk,
  'Review your calendar': _hReviewCalendar,
  'Turn off one notification': _hTurnOffNotification,
  'Close one browser tab': _hCloseTab,
  'Archive 5 old emails': _hArchiveEmails,
  'Update one to-do item': _hUpdateTodo,

  // Home & organization
  'Tidy one small thing': _hTidyOneThing,
  'Put one thing back where it belongs': _hPutBack,
  'Wipe one surface': _hWipeSurface,
  'Open a window for fresh air': _hFreshAir,
  'Make your bed': _hMakeBed,
  'Clear one shelf': _hClearShelf,
  'Wash 3 dishes': _hWashDishes,
  'Take out one small bag of trash': _hTakeOutTrash,
  'Fold 3 items of clothing': _hFoldClothing,
  'Organize one drawer': _hOrganizeDrawer,
  'Water one plant': _hWaterPlant,
  'Light a candle': _hLightCandle,

  // Relationships
  'Send one message to someone': _hSendMessage,
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
  'Write one sentence': _hWriteSentence,
  'Doodle for 10 seconds': _hDoodle,
  'Capture one idea': _hCaptureIdea,
  'Notice one beautiful thing': _hNoticeBeauty,
  'Take one photo of something you like': _hTakePhoto,
  'Draw one simple shape': _hDrawShape,
  'Hum a tune you enjoy': _hHumTune,
  'Rearrange something small': _hRearrange,
  'Try one new word': _hTryNewWord,
  'Create one tiny thing': _hCreateTinyThing,
  'Play with one creative medium': _hPlayCreative,
  'Imagine one possibility': _hImagine,

  // Finances
  'Check your balance': _hCheckBalance,
  'Move €1 to savings': _hMoveToSavings,
  'Review one subscription': _hReviewSubscription,
  'Note one expense': _hNoteExpense,
  'Read one financial tip': _hFinancialTip,
  'Delete one old receipt': _hDeleteReceipt,
  'Update one budget category': _hUpdateBudget,
  'Review one bill': _hReviewBill,
  'Price-check one item before buying': _hPriceCheck,
  'Wait 24 hours before one purchase': _hWait24Hours,
  'Celebrate one money win': _hCelebrateMoneyWin,
  'Set one small savings goal': _hSavingsGoal,

  // Self-care
  'Sit still for 10 seconds': _hSitStill,
  'Do one kind thing for yourself': _hKindThing,
  'Drink water slowly': _hDrinkSlowly,
  'Stretch your neck': _hStretchNeck,
  'Take one slow breath': _hOneSlowBreath,
  'Notice something you like about yourself': _hNoticeLikeAboutSelf,
  'Give yourself permission to say no': _hPermissionSayNo,
  'Do something that feels good': _hFeelGood,
  'Rest for 2 minutes': _hRestTwoMinutes,
  'Put on something comfortable': _hPutOnComfortable,
  'Listen to one song you love': _hListenToSong,
  'Do absolutely nothing for 30 seconds': _hDoNothing,
};

// Health
String _hDrinkWater(AppLocalizations l) => l.habitDrinkWater;
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

// Productivity
String _hSetPriority(AppLocalizations l) => l.habitSetPriority;
String _hClearSmallThing(AppLocalizations l) => l.habitClearSmallThing;
String _hPlanTomorrow(AppLocalizations l) => l.habitPlanTomorrow;
String _hThirtySecondReset(AppLocalizations l) => l.habitThirtySecondReset;
String _hWriteIdea(AppLocalizations l) => l.habitWriteIdea;
String _hFinishTinyTask(AppLocalizations l) => l.habitFinishTinyTask;
String _hDeclutterDesk(AppLocalizations l) => l.habitDeclutterDesk;
String _hReviewCalendar(AppLocalizations l) => l.habitReviewCalendar;
String _hTurnOffNotification(AppLocalizations l) => l.habitTurnOffNotification;
String _hCloseTab(AppLocalizations l) => l.habitCloseTab;
String _hArchiveEmails(AppLocalizations l) => l.habitArchiveEmails;
String _hUpdateTodo(AppLocalizations l) => l.habitUpdateTodo;

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
String _hCaptureIdea(AppLocalizations l) => l.habitCaptureIdea;
String _hNoticeBeauty(AppLocalizations l) => l.habitNoticeBeauty;
String _hTakePhoto(AppLocalizations l) => l.habitTakePhoto;
String _hDrawShape(AppLocalizations l) => l.habitDrawShape;
String _hHumTune(AppLocalizations l) => l.habitHumTune;
String _hRearrange(AppLocalizations l) => l.habitRearrange;
String _hTryNewWord(AppLocalizations l) => l.habitTryNewWord;
String _hCreateTinyThing(AppLocalizations l) => l.habitCreateTinyThing;
String _hPlayCreative(AppLocalizations l) => l.habitPlayCreative;
String _hImagine(AppLocalizations l) => l.habitImagine;

// Finances
String _hCheckBalance(AppLocalizations l) => l.habitCheckBalance;
String _hMoveToSavings(AppLocalizations l) => l.habitMoveToSavings;
String _hReviewSubscription(AppLocalizations l) => l.habitReviewSubscription;
String _hNoteExpense(AppLocalizations l) => l.habitNoteExpense;
String _hFinancialTip(AppLocalizations l) => l.habitFinancialTip;
String _hDeleteReceipt(AppLocalizations l) => l.habitDeleteReceipt;
String _hUpdateBudget(AppLocalizations l) => l.habitUpdateBudget;
String _hReviewBill(AppLocalizations l) => l.habitReviewBill;
String _hPriceCheck(AppLocalizations l) => l.habitPriceCheck;
String _hWait24Hours(AppLocalizations l) => l.habitWait24Hours;
String _hCelebrateMoneyWin(AppLocalizations l) => l.habitCelebrateMoneyWin;
String _hSavingsGoal(AppLocalizations l) => l.habitSavingsGoal;

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
