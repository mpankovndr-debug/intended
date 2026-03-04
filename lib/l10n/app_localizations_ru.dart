// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get commonOk => 'ОК';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonGreat => 'Отлично';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonNotNow => 'Не сейчас';

  @override
  String get commonDismiss => 'Закрыть';

  @override
  String get commonStart => 'Начать';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonRefresh => 'Обновить';

  @override
  String get appNameIntended => 'Intended';

  @override
  String get appNameIntendedPlus => 'Intended+';

  @override
  String get appPlanCore => 'Core';

  @override
  String get appPlanBoost => 'Boost';

  @override
  String get appUnlockPlus => 'Перейти на Intended+';

  @override
  String get welcomeTitle => 'Добро пожаловать в Intended';

  @override
  String welcomeTitleWithName(String name) {
    return 'Добро пожаловать\nв Intended, $name';
  }

  @override
  String get welcomeSubtitle => 'Маленькие шаги.\nБез давления.';

  @override
  String get onboardingTagline => 'Намерение, а не перфекционизм.';

  @override
  String get onboardingNamePrompt => 'Как тебя зовут?';

  @override
  String get onboardingSkipForNow => 'Пропустить';

  @override
  String onboardingNameTooLong(int max) {
    return 'Имя должно быть короче $max символов';
  }

  @override
  String get onboardingNameInappropriate => 'Пожалуйста, выбери другое имя';

  @override
  String get onboardingOops => 'Упс';

  @override
  String get focusAreaHealth => 'Здоровье';

  @override
  String get focusAreaMood => 'Настроение';

  @override
  String get focusAreaProductivity => 'Продуктивность';

  @override
  String get focusAreaHome => 'Дом и порядок';

  @override
  String get focusAreaRelationships => 'Отношения';

  @override
  String get focusAreaCreativity => 'Творчество';

  @override
  String get focusAreaFinances => 'Финансы';

  @override
  String get focusAreaSelfCare => 'Забота о себе';

  @override
  String get focusAreasTitle => 'Направления';

  @override
  String focusAreasPromptWithName(String name) {
    return 'Что тебе сейчас важно, $name?';
  }

  @override
  String get focusAreasPrompt => 'Что тебе сейчас важно?';

  @override
  String focusAreasChooseCount(int count, int max) {
    return 'Выбери до двух направлений ($count/$max)';
  }

  @override
  String get focusAreasChangeLater => 'Это всегда можно изменить.';

  @override
  String get focusAreasLimitTitle => 'Лимит достигнут';

  @override
  String get focusAreasLimitMessage =>
      'Можно выбрать до 2 направлений. Убери одно, чтобы выбрать другое.';

  @override
  String get focusLimitFreeTitle => 'Два — отличное начало';

  @override
  String get focusLimitFreeMessage =>
      'Хочешь больше? Перейди на Intended+, чтобы выбирать без ограничений.';

  @override
  String get focusLimitFreeUpgrade => 'Улучшить';

  @override
  String get focusNudgeTitle => 'Мягкая мысль';

  @override
  String get focusNudgeMessage =>
      'Ты можешь выбрать сколько угодно! Но фокус на меньшем часто ведёт к более глубокому росту. Впрочем, тебе виднее.';

  @override
  String get focusNudgeGotIt => 'Понятно';

  @override
  String get reminderTitle => 'Напоминание';

  @override
  String get reminderSubtitle => 'Хочешь ненавязчивое ежедневное напоминание?';

  @override
  String get reminderDescription => 'Всего раз в день. Без давления.';

  @override
  String get reminderDailyToggle => 'Ежедневное напоминание';

  @override
  String reminderAroundTime(String time) {
    return 'Около $time';
  }

  @override
  String get reminderTimeLabel => 'Напомнить в';

  @override
  String get reminderTimePicker => 'Время напоминания';

  @override
  String get reminderSwitchHint =>
      'Включи, чтобы выбрать время ежедневного напоминания.';

  @override
  String get reminderNoWorries =>
      'Ничего страшного — включить можно в любой момент в профиле.';

  @override
  String get reminderWeeklySummary => 'Итоги недели';

  @override
  String get reminderWeeklySubtitle => 'Каждое воскресенье вечером';

  @override
  String reminderLetsGo(String name) {
    return 'Поехали, $name';
  }

  @override
  String get themeSelectionTitle => 'Выбери своё пространство';

  @override
  String get themeSelectionSubtitle => 'Это всегда можно изменить.';

  @override
  String get themeSelectionConfirm => 'Мне нравится';

  @override
  String get themeSelectionPremiumHint =>
      'Clear Sky и Morning Slate доступны с Intended+. Попробуй бесплатно 7 дней после настройки.';

  @override
  String get habitRevealTitle => 'Вот что мы подобрали для тебя';

  @override
  String get habitRevealSubtitleDefault => 'На основе твоих предпочтений';

  @override
  String habitRevealSubtitleOneArea(String area) {
    return 'На основе направления «$area»';
  }

  @override
  String habitRevealSubtitleTwoAreas(String area1, String area2) {
    return 'На основе «$area1» и «$area2»';
  }

  @override
  String get habitRevealDescription =>
      'Ты можешь добавлять, убирать или искать другие привычки в любое время. Не нужно делать всё сразу.';

  @override
  String get habitRevealBegin => 'Начнём';

  @override
  String get habitsHoldForOptions => 'Удерживай привычку для опций';

  @override
  String get habitsCompleteOnboarding => 'Заверши настройку, чтобы начать';

  @override
  String get habitsPinned => 'ЗАКРЕПЛЁННЫЕ';

  @override
  String get habitsSuggestions => 'ПРЕДЛОЖЕНИЯ';

  @override
  String get habitsCreateCustom => 'Создать свою привычку';

  @override
  String get habitsBrowseAll => 'Все привычки';

  @override
  String habitsMoreAvailable(int count) {
    return 'Ещё $count доступно';
  }

  @override
  String get habitBreath => 'Три медленных вдоха';

  @override
  String get habitPause => 'Десять секунд тишины';

  @override
  String get habitWater => 'Осознанный глоток воды';

  @override
  String get habitStretch => 'Мягкая растяжка';

  @override
  String get habitPriority => 'Один приоритет';

  @override
  String get habitCheckin => 'Честная проверка себя';

  @override
  String get dayMonday => 'Понедельник';

  @override
  String get dayTuesday => 'Вторник';

  @override
  String get dayWednesday => 'Среда';

  @override
  String get dayThursday => 'Четверг';

  @override
  String get dayFriday => 'Пятница';

  @override
  String get daySaturday => 'Суббота';

  @override
  String get daySunday => 'Воскресенье';

  @override
  String get dayShortMon => 'П';

  @override
  String get dayShortTue => 'В';

  @override
  String get dayShortWed => 'С';

  @override
  String get dayShortThu => 'Ч';

  @override
  String get dayShortFri => 'П';

  @override
  String get dayShortSat => 'С';

  @override
  String get dayShortSun => 'В';

  @override
  String get monthJanuary => 'Январь';

  @override
  String get monthFebruary => 'Февраль';

  @override
  String get monthMarch => 'Март';

  @override
  String get monthApril => 'Апрель';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJune => 'Июнь';

  @override
  String get monthJuly => 'Июль';

  @override
  String get monthAugust => 'Август';

  @override
  String get monthSeptember => 'Сентябрь';

  @override
  String get monthOctober => 'Октябрь';

  @override
  String get monthNovember => 'Ноябрь';

  @override
  String get monthDecember => 'Декабрь';

  @override
  String get dailyMessage1 => 'Делай то, что чувствуется правильным сегодня';

  @override
  String get dailyMessage2 => 'Сегодня — чистый лист';

  @override
  String get dailyMessage3 => 'Даже одна мелочь — это уже что-то';

  @override
  String get dailyMessage4 => 'Будь добрее к себе сегодня';

  @override
  String get dailyMessage5 => 'Не спеши. Ты справляешься';

  @override
  String get dailyMessage6 => 'Начни с малого, действуй мягко';

  @override
  String get dailyMessage7 => 'Твой темп — только твой';

  @override
  String get dailyMessage8 => 'Даже один шаг — это прогресс';

  @override
  String get dailyMessage9 => 'Бери то, что подходит, остальное оставь';

  @override
  String get dailyMessage10 => 'Не нужно делать всё сразу';

  @override
  String get dailyMessage11 => 'Маленькие моменты складываются в большое';

  @override
  String get dailyMessage12 => 'Будь здесь и сейчас';

  @override
  String get dailyMessage13 => 'Нет неправильного способа начать';

  @override
  String get dailyMessage14 => 'Прислушайся к тому, что тебе нужно сегодня';

  @override
  String get dailyMessage15 => 'Прогресс каждый день выглядит по-разному';

  @override
  String get dailyMessage16 => 'Ты имеешь право не торопиться';

  @override
  String get dailyMessage17 => 'Одно дело за раз — этого достаточно';

  @override
  String get dailyMessage18 => 'Разреши себе отдохнуть';

  @override
  String get dailyMessage19 => 'Начни оттуда, где ты сейчас';

  @override
  String get dailyMessage20 => 'Не нужно быть готовым, чтобы начать';

  @override
  String get dailyMessage21 => 'Доверяй своему ритму';

  @override
  String get dailyMessage22 => 'Можно подстраиваться на ходу';

  @override
  String get dailyMessage23 => 'Мягко — уже достаточно';

  @override
  String get dailyMessage24 => 'Маленькая забота о себе — тоже забота';

  @override
  String get dailyMessage25 => 'Ты делаешь больше, чем тебе кажется';

  @override
  String get customHabitTitle => 'Создать свою привычку';

  @override
  String get customHabitPrompt =>
      'Какое маленькое действие ты хочешь добавить?';

  @override
  String get customHabitHint => 'Просто и конкретно.';

  @override
  String get customHabitPlaceholder => 'Например: прогулка 5 минут';

  @override
  String customHabitCharCount(int count) {
    return '$count/50 символов';
  }

  @override
  String get customHabitSubmit => 'Добавить';

  @override
  String get customHabitCreatedTitle => 'Привычка создана';

  @override
  String customHabitCreatedMessage(String title) {
    return '«$title» добавлена в твои привычки.';
  }

  @override
  String get customHabitLimitTitle => 'Создать ещё?';

  @override
  String get customHabitLimitMessage =>
      'Core: 2 свои привычки\nBoost: 3 свои привычки\nIntended+: без ограничений';

  @override
  String get menuUnpin => 'Открепить';

  @override
  String get menuPinToTop => 'Закрепить';

  @override
  String get menuSwap => 'Заменить';

  @override
  String get replacePinTitle => 'Заменить закреплённую?';

  @override
  String replacePinDescription(String current, String newHabit) {
    return 'Сейчас: $current\nНовая: $newHabit';
  }

  @override
  String get replacePinConfirm => 'Заменить';

  @override
  String get swapCantTitle => 'Нельзя заменить';

  @override
  String get swapCantMessage =>
      'Свои привычки нельзя заменить. Ты можешь удалить её и добавить новую.';

  @override
  String swapTitle(String title) {
    return 'Заменить «$title»?';
  }

  @override
  String swapCategoryHabits(String category) {
    return 'Другие привычки из «$category»:';
  }

  @override
  String swapFreeRemaining(int remaining) {
    return 'Бесплатных замен: $remaining';
  }

  @override
  String get swapSuccessTitle => 'Привычка заменена';

  @override
  String swapSuccessMessage(String habit) {
    return 'Заменена на «$habit»';
  }

  @override
  String get swapErrorTitle => 'Что-то пошло не так';

  @override
  String get swapErrorMessage =>
      'Не удалось заменить привычку. Попробуй ещё раз.';

  @override
  String get swapLimitTitle => 'Заменить привычку?';

  @override
  String get swapLimitMessage =>
      'Ты использовал все бесплатные замены в этом месяце.\n\nBoost: 3 замены/мес.\nIntended+: без ограничений';

  @override
  String get swapNoAltTitle => 'Нет альтернатив';

  @override
  String get swapNoAltMessage =>
      'Ты уже используешь все привычки из этой категории.';

  @override
  String get deleteHabitTitle => 'Удалить привычку?';

  @override
  String deleteHabitMessage(String title) {
    return '«$title» будет удалена, а прогресс потерян.';
  }

  @override
  String get completionQuestion => 'Ты это сделал сегодня?';

  @override
  String get completionConfirm => 'Да, сделал';

  @override
  String get completionDecline => 'Не сегодня';

  @override
  String get celebrationNice => 'Отлично';

  @override
  String get celebrationWellDone => 'Молодец';

  @override
  String get celebrationYouDidIt => 'Получилось';

  @override
  String get celebrationGreat => 'Здорово';

  @override
  String get celebrationWayToGo => 'Так держать';

  @override
  String get celebrationGoodJob => 'Хорошая работа';

  @override
  String get celebrationLovely => 'Чудесно';

  @override
  String get celebrationThatCounts => 'Это считается';

  @override
  String get completionMsg1 => 'Такие маленькие шаги важны.';

  @override
  String get completionMsg2 => 'Ты пришёл сегодня.';

  @override
  String get completionMsg3 => 'Вот так и происходят перемены.';

  @override
  String get completionMsg4 => 'Ещё на шаг ближе.';

  @override
  String get completionMsg5 => 'Ты сделал то, что задумал.';

  @override
  String get completionMsg6 => 'Это потребовало усилий. Молодец.';

  @override
  String get completionMsg7 => 'Ещё одна маленькая победа.';

  @override
  String get completionMsg8 => 'У тебя получилось.';

  @override
  String get completionMsg9 => 'Прогресс — это прогресс.';

  @override
  String get completionMsg10 => 'Ты довёл дело до конца.';

  @override
  String get completionMsg11 => 'Это считается.';

  @override
  String get completionMsg12 => 'Ты сдержал слово перед собой.';

  @override
  String get completionMsg13 => 'Молодец.';

  @override
  String get completionMsg14 => 'Ты нашёл на это время.';

  @override
  String get completionMsg15 => 'Вот он — рост.';

  @override
  String get completionMsg16 => 'Ты не сдался.';

  @override
  String get completionMsg17 => 'Ещё одна привычка укрепилась.';

  @override
  String get completionMsg18 => 'Ты решил — и сделал.';

  @override
  String get completionMsg19 => 'Всё складывается.';

  @override
  String get completionMsg20 => 'Ты следуешь своему намерению.';

  @override
  String get insightWater1 =>
      'Даже лёгкое обезвоживание влияет на настроение и концентрацию.';

  @override
  String get insightWater2 =>
      'Мозг на 75% состоит из воды. Гидратация влияет на ясность мышления.';

  @override
  String get insightWater3 => 'Стакан воды может снизить усталость на 14%.';

  @override
  String get insightExercise1 =>
      'Всего 10 минут движения улучшают кровообращение в мозге.';

  @override
  String get insightExercise2 =>
      'Движение высвобождает эндорфины, которые поднимают настроение на часы.';

  @override
  String get insightExercise3 =>
      'Регулярное движение снижает тревогу так же эффективно, как медитация.';

  @override
  String get insightWalk1 =>
      'Прогулка на свежем воздухе снижает уровень кортизола за 20 минут.';

  @override
  String get insightWalk2 =>
      '10-минутная прогулка может повысить креативность на 60%.';

  @override
  String get insightWalk3 => 'Ходьба улучшает память, активируя гиппокамп.';

  @override
  String get insightStretch1 =>
      'Растяжка улучшает кровообращение и снимает мышечное напряжение.';

  @override
  String get insightStretch2 =>
      'Регулярная растяжка улучшает гибкость на 20% всего за несколько недель.';

  @override
  String get insightStretch3 =>
      'Растяжка активирует парасимпатическую нервную систему, снижая стресс.';

  @override
  String get insightSleep1 => 'Качественный сон укрепляет память на 40%.';

  @override
  String get insightSleep2 =>
      'Регулярный режим сна улучшает циркадные ритмы и настроение.';

  @override
  String get insightSleep3 =>
      'Недосып влияет на мышление так же, как алкоголь.';

  @override
  String get insightBed1 => 'Ритуал перед сном подготавливает мозг к отдыху.';

  @override
  String get insightBed2 =>
      'Ложиться в одно время улучшает качество сна на 25%.';

  @override
  String get insightBed3 => 'Мелатонин вырабатывается лучше, когда есть режим.';

  @override
  String get insightBreathe1 =>
      'Глубокое дыхание активирует блуждающий нерв и успокаивает нервную систему.';

  @override
  String get insightBreathe2 =>
      'Осознанное дыхание снижает гормоны стресса за считанные минуты.';

  @override
  String get insightBreathe3 =>
      'Квадратное дыхание используют спецназовцы для управления стрессом.';

  @override
  String get insightMeditate1 =>
      'Всего 10 минут медитации увеличивают серое вещество мозга.';

  @override
  String get insightMeditate2 =>
      'Регулярная медитация уменьшает миндалевидное тело — центр страха.';

  @override
  String get insightMeditate3 =>
      'Практика осознанности улучшает эмоциональную регуляцию.';

  @override
  String get insightRead1 => '6 минут чтения снижают стресс на 68%.';

  @override
  String get insightRead2 => 'Регулярное чтение укрепляет нейронные связи.';

  @override
  String get insightRead3 =>
      'Чтение перед сном улучшает его качество лучше, чем экраны.';

  @override
  String get insightCall1 =>
      'Общение так же важно для здоровья, как спорт и питание.';

  @override
  String get insightCall2 =>
      '10-минутный разговор может уменьшить чувство одиночества.';

  @override
  String get insightCall3 =>
      'Голосовое общение высвобождает окситоцин — гормон привязанности.';

  @override
  String get insightFriend1 =>
      'Крепкие дружеские связи могут продлить жизнь на 50%.';

  @override
  String get insightFriend2 =>
      'Хорошая дружба значительно снижает гормоны стресса.';

  @override
  String get insightFriend3 => 'Общение с друзьями укрепляет иммунитет.';

  @override
  String get insightWrite1 =>
      'Письмо о чувствах активирует префронтальную кору, снижая стресс.';

  @override
  String get insightWrite2 =>
      'Ведение записей может улучшить иммунитет и уменьшить симптомы.';

  @override
  String get insightWrite3 =>
      'Экспрессивное письмо помогает пережить трудный опыт.';

  @override
  String get insightJournal1 =>
      'Ежедневные записи повышают самосознание и эмоциональную ясность.';

  @override
  String get insightJournal2 =>
      'Запись тревожных мыслей уменьшает навязчивые переживания.';

  @override
  String get insightJournal3 =>
      'Дневник благодарности перестраивает мозг на позитив.';

  @override
  String get insightVegetable1 =>
      'Овощи улучшают микробиом кишечника, влияя на настроение.';

  @override
  String get insightVegetable2 =>
      'Растительные нутриенты поддерживают выработку нейромедиаторов.';

  @override
  String get insightVegetable3 =>
      'Яркие овощи содержат антиоксиданты, защищающие клетки мозга.';

  @override
  String get insightBreakfast1 =>
      'Завтрак стабилизирует уровень сахара и улучшает концентрацию.';

  @override
  String get insightBreakfast2 =>
      'Утренняя еда запускает обмен веществ на весь день.';

  @override
  String get insightBreakfast3 =>
      'Те, кто завтракает, лучше справляются с когнитивными задачами.';

  @override
  String get insightPhone1 =>
      'Меньше экранов перед сном улучшает качество сна на 30%.';

  @override
  String get insightPhone2 => 'Синий свет подавляет мелатонин до 3 часов.';

  @override
  String get insightPhone3 =>
      'Перерывы от экрана уменьшают усталость глаз и головные боли.';

  @override
  String get insightScreen1 =>
      'Каждый час без экрана улучшает ясность мышления.';

  @override
  String get insightScreen2 =>
      'Цифровой детокс снижает тревогу и улучшает живое общение.';

  @override
  String get insightScreen3 =>
      'Перерывы от экранов помогают регулировать дофамин.';

  @override
  String get insightClean1 =>
      'Порядок вокруг снижает уровень кортизола и мысленный хаос.';

  @override
  String get insightClean2 =>
      'Организованное пространство улучшает концентрацию на 25%.';

  @override
  String get insightClean3 =>
      'Уборка — это форма физической активности, снижающая стресс.';

  @override
  String get insightOrganize1 =>
      'Порядок уменьшает усталость от принятия решений в течение дня.';

  @override
  String get insightOrganize2 =>
      'Пространство без хаоса улучшает когнитивные процессы.';

  @override
  String get insightOrganize3 => 'Организованная среда улучшает качество сна.';

  @override
  String get insightDraw1 =>
      'Творчество естественным образом повышает уровень дофамина.';

  @override
  String get insightDraw2 =>
      'Рисование задействует оба полушария, улучшая нейронные связи.';

  @override
  String get insightDraw3 => 'Рисование снижает гормоны стресса за 45 минут.';

  @override
  String get insightMusic1 =>
      'Занятия музыкой укрепляют мозолистое тело в мозге.';

  @override
  String get insightMusic2 =>
      'Музыкальная практика улучшает исполнительные функции и память.';

  @override
  String get insightMusic3 =>
      'Музыка активирует систему вознаграждения, высвобождая дофамин.';

  @override
  String get warmthMsg1 => 'Ничего страшного. Завтра всё ещё впереди.';

  @override
  String get warmthMsg2 => 'Отдых тоже считается.';

  @override
  String get warmthMsg3 => 'Не каждый день. Просто иногда.';

  @override
  String get warmthMsg4 => 'Не сегодня — и это нормально.';

  @override
  String get warmthMsg5 => 'Будь к себе так же добр, как был бы к другу.';

  @override
  String get warmthMsg6 => 'Привычка никуда не денется. Она подождёт.';

  @override
  String get warmthMsg7 => 'Даже мягкий шаг назад — это всё ещё участие.';

  @override
  String get warmthMsg8 => 'Ничего не потеряно. Ты здесь.';

  @override
  String get warmthMsg9 => 'Некоторые дни — для отдыха. Может, сегодня такой.';

  @override
  String get warmthMsg10 =>
      'Доброта к себе — привычка, которую стоит сохранить.';

  @override
  String get warmthMsg11 =>
      'Нет серии, которую можно прервать. Нет очков, которые можно потерять. Просто ты.';

  @override
  String get warmthMsg12 => 'Самые мягкие дни тоже важны.';

  @override
  String get warmthMsg13 =>
      'Ты уже сделал достаточно сегодня — просто тем, что ты здесь.';

  @override
  String get warmthMsg14 => 'Можно отпустить эту.';

  @override
  String get warmthMsg15 =>
      'Прогресс не всегда видим. Иногда это просто — выстоять.';

  @override
  String get notifMsg1 => 'Не спеши сегодня. Даже одна мелочь имеет значение.';

  @override
  String get notifMsg2 => 'Не нужно быть продуктивным, чтобы заслужить отдых.';

  @override
  String get notifMsg3 =>
      'Просто заглянул. Что бы ты ни сделал сегодня — этого достаточно.';

  @override
  String get notifMsg4 => 'Одна маленькая привычка. Вот и всё.';

  @override
  String get notifMsg5 => 'Ты пришёл вчера. Это уже важно.';

  @override
  String get notifMsg6 =>
      'Сегодня не должен быть идеальным, чтобы быть хорошим.';

  @override
  String get notifMsg7 => 'Будь к себе так же мягок, как был бы к другу.';

  @override
  String get notifMsg8 => 'Маленькие шаги всё равно двигают вперёд.';

  @override
  String get notifMsg9 => 'Начинать медленно — это нормально.';

  @override
  String get notifMsg10 => 'Ты справляешься лучше, чем тебе кажется.';

  @override
  String get notifMsg11 => 'Прогресс не всегда похож на прогресс.';

  @override
  String get notifMsg12 => 'По одному делу. Без давления.';

  @override
  String get notifMsg13 => 'Не нужно заслуживать отдых.';

  @override
  String get notifMsg14 => 'Доброта к себе — тоже привычка.';

  @override
  String get notifMsg15 => 'Сегодня — новый шанс, а не экзамен.';

  @override
  String get notifMsg16 => 'Даже чуть-чуть — это больше, чем ничего.';

  @override
  String get notifMsg17 => 'Ты всё ещё здесь. Это уже кое-что.';

  @override
  String get notifMsg18 => 'Нет неправильного способа провести мягкий день.';

  @override
  String get notifMsg19 =>
      'Что бы ни принёс сегодняшний день — ты справишься мягко.';

  @override
  String get notifMsg20 => 'Отдых — тоже часть работы.';

  @override
  String get notifMsg21 => 'Не нужно делать всё. Просто одно дело.';

  @override
  String get notifMsg22 => 'Сегодняшние привычки — завтрашний фундамент.';

  @override
  String get notifMsg23 => 'Будь терпелив с собой сегодня.';

  @override
  String get notifMsg24 => 'Рост происходит тихо. Доверяй ему.';

  @override
  String get notifMsg25 => 'Ты строишь что-то настоящее, не торопясь.';

  @override
  String get notifMsg26 => 'Одна привычка. Один момент. Этого достаточно.';

  @override
  String get notifMsg27 => 'Как ты на самом деле сегодня?';

  @override
  String get notifMsg28 =>
      'Ты уже справлялся с трудным. Сегодня может быть мягко.';

  @override
  String get notifMsg29 => 'Не нужно совершенство, чтобы стоило делать.';

  @override
  String get notifMsg30 => 'Ты имеешь право идти шаг за шагом.';

  @override
  String get notifMsg31 => 'Тот ты, что начал этот путь, гордился бы тобой.';

  @override
  String get notifMsg32 =>
      'Рост тише всего, когда он настоящий. Доверяй процессу.';

  @override
  String get notifMsg33 => 'Ты приходишь раз за разом. Это редкость.';

  @override
  String get notifMsg34 => 'Маленькие ритуалы складываются в жизнь.';

  @override
  String get notifMsg35 => 'Ты не отстаёшь. Ты именно там, где есть.';

  @override
  String get notifMsg36 => 'Самые мягкие привычки — часто самые стойкие.';

  @override
  String get notifMsg37 => 'Ты строишь отношения с собой. Не торопись.';

  @override
  String get notifMsg38 =>
      'Сегодняшнее маленькое действие — норма через месяц.';

  @override
  String get notifMsg39 => 'Привычки — не про силу воли. Они про заботу.';

  @override
  String get notifMsg40 =>
      'Ты знаешь себя лучше любого приложения. Доверяй себе.';

  @override
  String get notifMsg41 =>
      'Цель никогда не была совершенством. Цель — приходить.';

  @override
  String get notifMsg42 => 'Иногда привычка дня — просто быть добрее к себе.';

  @override
  String get notifMsg43 => 'Ты переживал дни и потруднее.';

  @override
  String get notifMsg44 => 'Каждый мягкий выбор складывается.';

  @override
  String get notifMsg45 => 'Не нужна мотивация. Нужен один момент.';

  @override
  String get notifMsg46 => 'Твой темп — только твой. Без сравнений.';

  @override
  String get notifMsg47 => 'Тихие дни важны не меньше.';

  @override
  String get notifMsg48 => 'Ты не начинаешь заново — ты продолжаешь.';

  @override
  String get notifMsg49 => 'Постоянство — это доброта, повторённая много раз.';

  @override
  String get notifMsg50 =>
      'По одной привычке — вот как на самом деле меняются жизни.';

  @override
  String get notifMsg51 => 'Сегодня хороший день, чтобы быть мягче к себе.';

  @override
  String get notifMsg52 => 'Ты пришёл. В этом и суть.';

  @override
  String get notifMsg53 => 'Маленький — не значит незначительный.';

  @override
  String get notifMsg54 => 'Что бы ты ни делал сегодня — делай с заботой.';

  @override
  String get notifMsg55 => 'Твои привычки — это форма уважения к себе.';

  @override
  String get notifMsg56 => 'Ничего не потеряно. Всегда можно начать снова.';

  @override
  String get notifMsg57 => 'Ты в этом надолго. Медленно — нормально.';

  @override
  String get notifMsg58 =>
      'Сегодняшнее усилие незаметно сейчас и неоспоримо потом.';

  @override
  String get notifMsg59 => 'Ты имеешь право быть в процессе.';

  @override
  String get notifMsg60 => 'Вот так и выглядит забота о себе.';

  @override
  String get notifWeeklyBody =>
      'Оглянись на свою неделю. Твои привычки были рядом.';

  @override
  String get notifDailyChannelName => 'Ежедневные напоминания';

  @override
  String get notifDailyChannelDesc =>
      'Мягкие ежедневные напоминания о привычках';

  @override
  String get notifWeeklyChannelName => 'Еженедельные напоминания';

  @override
  String get notifWeeklyChannelDesc => 'Напоминания для недельной рефлексии';

  @override
  String get affirmation1 =>
      'Пропущенные дни не отменяют того, что ты уже сделал.';

  @override
  String get affirmation2 => 'Не нужно заслуживать отдых.';

  @override
  String get affirmation3 => 'Три привычки или одна — обе формы достаточны.';

  @override
  String get affirmation4 => 'То, что ты здесь, уже говорит о тебе хорошее.';

  @override
  String get affirmation5 =>
      'Прогресс — не про совершенство, а про то, чтобы приходить.';

  @override
  String get affirmation6 => 'У тебя есть право на нелёгкие дни.';

  @override
  String get affirmation7 =>
      'Маленькие действия считаются, даже когда кажутся маленькими.';

  @override
  String get affirmation8 => 'Ты не отстаёшь. Ты именно там, где нужно.';

  @override
  String get affirmation9 => 'Постоянство важно, но самосострадание тоже.';

  @override
  String get affirmation10 =>
      'Твоя ценность не измеряется количеством галочек.';

  @override
  String get affirmation11 =>
      'Некоторые недели труднее. Это просто быть человеком.';

  @override
  String get affirmation12 => 'Не нужно делать всё, чтобы делать достаточно.';

  @override
  String get affirmation13 =>
      'Отдых — часть прогресса, а не его противоположность.';

  @override
  String get affirmation14 =>
      'Приходить несовершенным — это всё равно приходить.';

  @override
  String get affirmation15 => 'Ты справляешься лучше, чем тебе кажется.';

  @override
  String get affirmation16 =>
      'Можно начинать заново столько раз, сколько нужно.';

  @override
  String get affirmation17 => 'Твой темп — только твой. Сравнение не поможет.';

  @override
  String get affirmation18 =>
      'Каждая попытка имеет значение, даже та, что кажется мелкой.';

  @override
  String get affirmation19 =>
      'Не нужна мотивация, чтобы заслужить доброту к себе.';

  @override
  String get affirmation20 =>
      'Прогресс может выглядеть просто как «попробую завтра».';

  @override
  String get affirmation21 => 'Ты имеешь право пересматривать свои ожидания.';

  @override
  String get affirmation22 => 'Перерыв — не значит провал.';

  @override
  String get affirmation23 => 'Самое трудное — начать. А ты уже это сделал.';

  @override
  String get affirmation24 => 'Не нужно разрешение, чтобы позаботиться о себе.';

  @override
  String get affirmation25 =>
      'Твой максимум сегодня может отличаться от вчерашнего. Это нормально.';

  @override
  String get affirmation26 =>
      'Трудности не значат, что ты делаешь что-то не так.';

  @override
  String get affirmation27 =>
      'Ты уже справлялся с трудным. Справишься и с этим.';

  @override
  String get affirmation28 =>
      'Твой прогресс может не быть похож на чужой. И это нормально.';

  @override
  String get affirmation29 => 'Тебе не нужно никому ничего доказывать.';

  @override
  String get affirmation30 =>
      'Иногда просто пережить день — уже достаточный прогресс.';

  @override
  String get affirmation31 => 'Ты учишься, даже когда так не кажется.';

  @override
  String get affirmation32 => 'Быть мягче к себе — это не сдаваться.';

  @override
  String get affirmation33 => 'Не нужна причина, чтобы быть к себе добрее.';

  @override
  String get affirmation34 => 'То, что ты делаешь прямо сейчас — достаточно.';

  @override
  String get affirmation35 => 'Завтра — всегда шанс попробовать снова.';

  @override
  String get progressOnboardingPrompt =>
      'Заверши настройку, чтобы увидеть свою неделю';

  @override
  String get progressTitle => 'Твоя неделя';

  @override
  String get progressWeeklySummary => 'ИТОГИ НЕДЕЛИ';

  @override
  String get progressWeekBeginning => 'Неделя только начинается.';

  @override
  String get progressShowedUpOnce => 'Ты отметился один раз на этой неделе.';

  @override
  String progressShowedUpCount(int count) {
    return 'Ты отметился $count раз на этой неделе.';
  }

  @override
  String progressMore(int count) {
    return '+$count ещё';
  }

  @override
  String get progressSeeAll => 'Показать все';

  @override
  String get progressShowLess => 'Свернуть';

  @override
  String get progressYourMoments => 'ТВОИ МОМЕНТЫ';

  @override
  String get progressEarlierToday => 'Ранее сегодня';

  @override
  String get progressYesterday => 'Вчера';

  @override
  String progressDaysAgo(int count) {
    return '$count дн. назад';
  }

  @override
  String progressMomentsCollected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count моментов собрано',
      few: '$count момента собрано',
      one: '1 момент собран',
    );
    return '$_temp0';
  }

  @override
  String get momentsTitle => 'Твои моменты';

  @override
  String get momentsSubtitle =>
      'Каждая привычка, которую ты выполнил, сохранена навсегда.';

  @override
  String get momentsEmptyTitle => 'Здесь появятся твои моменты.';

  @override
  String get momentsEmptyMessage =>
      'Каждая выполненная привычка становится частью твоей коллекции — навсегда.';

  @override
  String get momentsToday => 'Сегодня';

  @override
  String get momentsYesterday => 'Вчера';

  @override
  String monthSummaryMoments(int count, String month) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count моментов в $month',
      few: '$count момента в $month',
      one: '1 момент в $month',
    );
    return '$_temp0';
  }

  @override
  String monthSummaryIntentions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count намерений в этом месяце',
      few: '$count намерения в этом месяце',
      one: '1 намерение в этом месяце',
    );
    return '$_temp0';
  }

  @override
  String monthSummaryTopIntention(String intention) {
    return 'Чаще всего: $intention';
  }

  @override
  String get paywallTitle => 'Intended+';

  @override
  String get paywallDescription =>
      'Intended бесплатен навсегда. Intended+ даёт больше свободы сделать его по-своему.';

  @override
  String get paywallFeature1 =>
      'Создавай привычки, которые подходят именно тебе';

  @override
  String get paywallFeature2 => 'Меняй привычки, когда меняется жизнь';

  @override
  String get paywallFeature3 => 'Карточки достижений для друзей';

  @override
  String get paywallFeature4 => 'Меняй направления так часто, как нужно';

  @override
  String get paywallMonthly => 'Ежемесячно';

  @override
  String get paywallMonthlyPrice => '€6,99';

  @override
  String get paywallMonthlyPeriod => 'в месяц';

  @override
  String get paywallYearly => 'Ежегодно';

  @override
  String get paywallYearlyPrice => '€49,99';

  @override
  String get paywallYearlyPeriod => 'в год';

  @override
  String get paywallYearlySave => 'Экономия 40%';

  @override
  String get paywallLifetime => 'Навсегда';

  @override
  String get paywallLifetimePrice => '€89,99';

  @override
  String get paywallLifetimePeriod => 'один раз';

  @override
  String get paywallLifetimeBadge => 'Цена запуска';

  @override
  String get paywallCtaTrial => 'Начать 7-дневный пробный период';

  @override
  String get paywallCtaLifetime => 'Получить навсегда';

  @override
  String paywallTrialHint(String price) {
    return '7 дней бесплатно, затем $price. Отмена в любое время.';
  }

  @override
  String get paywallLifetimeHint => 'Разовая покупка. Без подписки.';

  @override
  String get paywallContinueFree => 'Продолжить с Core';

  @override
  String get paywallRestorePurchases => 'Восстановить покупки';

  @override
  String get paywallTerms => 'Условия';

  @override
  String get paywallPrivacy => 'Конфиденциальность';

  @override
  String get subscriptionTitle => 'Intended+';

  @override
  String get subscriptionSupporter => 'Ты наш сторонник ♥';

  @override
  String get subscriptionPlan => 'Тариф';

  @override
  String get subscriptionPrice => 'Цена';

  @override
  String get subscriptionRenews => 'Продление';

  @override
  String get subscriptionThankYou =>
      'Спасибо, что поддерживаешь Intended.\nТвоя подписка помогает нам\nстроить более мягкий путь к росту.';

  @override
  String get subscriptionManage => 'Управление в App Store';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileNameError => 'Хм';

  @override
  String get profileNameErrorMessage => 'Пожалуйста, выбери другое имя';

  @override
  String get profileYourName => 'Твоё имя';

  @override
  String get profileAddName => 'Добавь имя';

  @override
  String get profileEnterName => 'Введи своё имя';

  @override
  String get profilePlan => 'Тариф';

  @override
  String get profileManage => 'Управлять';

  @override
  String get profileUnlockPlus => 'ПЕРЕЙТИ НА INTENDED+';

  @override
  String get profileFocusAreas => 'Направления';

  @override
  String get profileYourMoments => 'Твои моменты';

  @override
  String get profileMomentsNone => 'Пока нет';

  @override
  String profileMomentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count моментов',
      few: '$count момента',
      one: '1 момент',
    );
    return '$_temp0';
  }

  @override
  String get profileSettings => 'НАСТРОЙКИ';

  @override
  String get profileDailyReminders => 'Ежедневные напоминания';

  @override
  String get profileRemindAt => 'Напомнить в';

  @override
  String get profileWeeklySummary => 'Итоги недели';

  @override
  String get profileWeeklySubtitle => 'Каждое воскресенье вечером';

  @override
  String get profileNotifDenied =>
      'Ничего страшного — включить уведомления можно в настройках устройства.';

  @override
  String get profileAppearance => 'Внешний вид';

  @override
  String get profileSupport => 'ПОДДЕРЖКА';

  @override
  String get profileHelpSupport => 'Помощь и поддержка';

  @override
  String get profilePrivacy => 'Политика конфиденциальности';

  @override
  String get profileTerms => 'Условия использования';

  @override
  String get profileConnectAccount => 'ПОДКЛЮЧИТЬ АККАУНТ';

  @override
  String get profileSignInGoogle => 'Войти через Google';

  @override
  String get profileSignInApple => 'Войти через Apple';

  @override
  String get profileSignedInGoogle => 'Вход выполнен через Google';

  @override
  String get profileSignedInApple => 'Вход выполнен через Apple';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileDeleteData => 'Удалить данные профиля';

  @override
  String get profileVersion => 'Intended v1.0.0';

  @override
  String get profileCannotOpenEmail => 'Не удалось открыть почту';

  @override
  String get profileEmailFallback => 'Напиши нам на\nsupport@intendedapp.com';

  @override
  String get profileChangeFocusTitle => 'Сменить направления?';

  @override
  String get profileChangeFocusMessage =>
      'Привычки обновятся на основе новых направлений.';

  @override
  String get profileChangeAreas => 'Сменить направления';

  @override
  String get profileFocusLimitMessage =>
      'Бесплатная смена в этом месяце уже использована.';

  @override
  String get profileFocusLimitOptions =>
      '• Boost: Доп. смены\n• Intended+: без ограничений';

  @override
  String get profilePayAmount => 'Оплатить €0,99';

  @override
  String get profilePaymentTitle => 'Оплата';

  @override
  String get profilePaymentMessage => 'Встроенные покупки скоро появятся!';

  @override
  String get profileChangeSpace => 'Сменить пространство';

  @override
  String get profileRefreshTitle => 'Обновить привычки?';

  @override
  String get profileRefreshMessage =>
      'Ты получишь новый набор привычек на основе своих направлений.';

  @override
  String get profileRefreshSuccessTitle => 'Привычки обновлены';

  @override
  String get profileRefreshSuccessMessage =>
      'Новый набор привычек уже ждёт тебя.';

  @override
  String get profileDailyLimitTitle => 'Дневной лимит достигнут';

  @override
  String get profileDailyLimitMessage =>
      'Ты обновил привычки 3 раза сегодня. Попробуй завтра или открой Intended+ для безлимитных обновлений.';

  @override
  String get profileCannotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get profilePrivacyFallback =>
      'Открой intendedapp.com/privacy в браузере';

  @override
  String get profileTermsFallback => 'Открой intendedapp.com/terms в браузере';

  @override
  String get profileDeleteAllTitle => 'Удалить все данные?';

  @override
  String get profileDeleteAllMessage =>
      'Все привычки, прогресс и настройки будут удалены безвозвратно.';

  @override
  String get profileChangeFocusAreasScreenTitle => 'Смена направлений';

  @override
  String get profileChooseUpTo2 => 'Выбери до 2 направлений';

  @override
  String get profileSaveChanges => 'Сохранить';

  @override
  String get themeWarmClay => 'Обоженная глина';

  @override
  String get themeIris => 'Ирис';

  @override
  String get themeClearSky => 'Ясное небо';

  @override
  String get themeMorningSlate => 'Утренний сланец';

  @override
  String get browseHabitsTitle => 'Все привычки';

  @override
  String browseHabitsAvailable(int count) {
    return 'Доступно привычек: $count';
  }

  @override
  String get browseHabitsSearch => 'Поиск привычек...';

  @override
  String get browseAlreadyAddedTitle => 'Уже добавлена';

  @override
  String browseAlreadyAddedMessage(String habit) {
    return '«$habit» уже есть в твоих привычках.';
  }

  @override
  String get browseSwapLimitTitle => 'Лимит замен достигнут';

  @override
  String get browseSwapConfirmTitle => 'Заменить одну из привычек?';

  @override
  String browseSwapConfirmMessage(String habit) {
    return 'Заменить одну из текущих привычек на «$habit».';
  }

  @override
  String browseSwapRemainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count замен',
      few: 'Осталось $count замены',
      one: 'Осталась $count замена',
    );
    return '$_temp0 в этом месяце.';
  }

  @override
  String get browseChooseHabitToSwap => 'Выбери привычку для замены';

  @override
  String get browseWhichToReplace => 'Какую привычку заменить?';

  @override
  String browseChooseToReplaceMessage(String habit) {
    return 'Выбери, какую из текущих привычек заменить на «$habit»';
  }

  @override
  String get browseHabitAddedTitle => 'Привычка добавлена';

  @override
  String browseHabitAddedMessage(String habit) {
    return '«$habit» добавлена в твои привычки.';
  }

  @override
  String get browseHabitAddedConfirm => 'Отлично!';

  @override
  String get habitDrinkWater => 'Выпей стакан воды';

  @override
  String get habitThreeSlowBreaths => 'Сделай 3 медленных вдоха';

  @override
  String get habitStretchTenSeconds => 'Потянись 10 секунд';

  @override
  String get habitRollShoulders => 'Встань и разомни плечи';

  @override
  String get habitStepOutside => 'Выйди на улицу на 30 секунд';

  @override
  String get habitCloseEyes => 'Закрой глаза на 20 секунд';

  @override
  String get habitNeckRolls => '5 мягких вращений шеей';

  @override
  String get habitWalkToWindow => 'Дойди до окна и обратно';

  @override
  String get habitBellyBreaths => '5 глубоких вдохов животом';

  @override
  String get habitBodyScan => 'Сканирование тела — 2 минуты';

  @override
  String get habitGentleMovement => '10 минут мягкого движения';

  @override
  String get habitMindfulMeal => 'Один осознанный приём пищи';

  @override
  String get habitTenSecondPause => 'Пауза на 10 секунд';

  @override
  String get habitNoticeFeeling => 'Заметь одно ощущение';

  @override
  String get habitGroundingBreath => 'Один заземляющий вдох';

  @override
  String get habitLookAway => 'Отведи взгляд от экрана на 10 секунд';

  @override
  String get habitNameThreeThings => 'Назови три вещи, которые видишь';

  @override
  String get habitNoticeSound => 'Заметь один звук вокруг';

  @override
  String get habitFeelFeet => 'Почувствуй ступни на полу';

  @override
  String get habitHandOnHeart => 'Положи руку на сердце на мгновение';

  @override
  String get habitGratefulThing => 'Заметь одну вещь, за которую благодарен';

  @override
  String get habitSmileGently => 'Мягко улыбнись себе';

  @override
  String get habitAskNeed => 'Спроси себя: «Что мне сейчас нужно?»';

  @override
  String get habitPermissionToRest => 'Разреши себе отдохнуть';

  @override
  String get habitSetPriority => 'Определи один приоритет';

  @override
  String get habitClearSmallThing => 'Разберись с одной мелочью';

  @override
  String get habitPlanTomorrow => 'Опиши завтрашний день одним предложением';

  @override
  String get habitThirtySecondReset => 'Перезагрузка на 30 секунд';

  @override
  String get habitWriteIdea => 'Запиши одну идею';

  @override
  String get habitFinishTinyTask => 'Заверши одно маленькое дело';

  @override
  String get habitDeclutterDesk => 'Разбери стол за 2 минуты';

  @override
  String get habitReviewCalendar => 'Загляни в календарь';

  @override
  String get habitTurnOffNotification => 'Отключи одно уведомление';

  @override
  String get habitCloseTab => 'Закрой одну вкладку';

  @override
  String get habitArchiveEmails => 'Архивируй 5 старых писем';

  @override
  String get habitUpdateTodo => 'Обнови один пункт в списке дел';

  @override
  String get habitTidyOneThing => 'Убери одну мелочь';

  @override
  String get habitPutBack => 'Положи одну вещь на место';

  @override
  String get habitWipeSurface => 'Протри одну поверхность';

  @override
  String get habitFreshAir => 'Открой окно для свежего воздуха';

  @override
  String get habitMakeBed => 'Заправь кровать';

  @override
  String get habitClearShelf => 'Разбери одну полку';

  @override
  String get habitWashDishes => 'Помой 3 тарелки';

  @override
  String get habitTakeOutTrash => 'Вынеси один мешок мусора';

  @override
  String get habitFoldClothing => 'Сложи 3 вещи';

  @override
  String get habitOrganizeDrawer => 'Разбери один ящик';

  @override
  String get habitWaterPlant => 'Полей одно растение';

  @override
  String get habitLightCandle => 'Зажги свечу';

  @override
  String get habitSendMessage => 'Напиши одно сообщение кому-нибудь';

  @override
  String get habitAppreciatePerson => 'Подумай о человеке, которого ценишь';

  @override
  String get habitAskHowAreYou => 'Спроси кого-нибудь, как дела';

  @override
  String get habitGiveCompliment => 'Сделай один искренний комплимент';

  @override
  String get habitCallSomeone => 'Позвони тому, кто тебе дорог';

  @override
  String get habitShareSmile => 'Поделись тем, что вызвало улыбку';

  @override
  String get habitThankSomeone => 'Поблагодари кого-нибудь сегодня';

  @override
  String get habitListenFully => 'Слушай, не планируя ответ';

  @override
  String get habitReachOut => 'Напиши тому, по кому скучаешь';

  @override
  String get habitTellMeaning => 'Скажи кому-то, как он тебе важен';

  @override
  String get habitOfferHelp => 'Предложи кому-нибудь помощь';

  @override
  String get habitCelebrateOthers => 'Порадуйся за чью-то победу';

  @override
  String get habitWriteSentence => 'Напиши одно предложение';

  @override
  String get habitDoodle => 'Рисуй каракули 10 секунд';

  @override
  String get habitCaptureIdea => 'Запиши одну идею';

  @override
  String get habitNoticeBeauty => 'Заметь одну красивую вещь';

  @override
  String get habitTakePhoto => 'Сфотографируй что-то, что нравится';

  @override
  String get habitDrawShape => 'Нарисуй одну простую фигуру';

  @override
  String get habitHumTune => 'Напой мелодию, которая нравится';

  @override
  String get habitRearrange => 'Переставь что-нибудь по мелочи';

  @override
  String get habitTryNewWord => 'Попробуй одно новое слово';

  @override
  String get habitCreateTinyThing => 'Создай одну маленькую вещь';

  @override
  String get habitPlayCreative => 'Поиграй с одним творческим материалом';

  @override
  String get habitImagine => 'Представь одну возможность';

  @override
  String get habitCheckBalance => 'Проверь баланс';

  @override
  String get habitMoveToSavings => 'Отложи €1 в копилку';

  @override
  String get habitReviewSubscription => 'Проверь одну подписку';

  @override
  String get habitNoteExpense => 'Запиши одну трату';

  @override
  String get habitFinancialTip => 'Прочитай один финансовый совет';

  @override
  String get habitDeleteReceipt => 'Удали один старый чек';

  @override
  String get habitUpdateBudget => 'Обнови одну категорию бюджета';

  @override
  String get habitReviewBill => 'Проверь один счёт';

  @override
  String get habitPriceCheck => 'Сравни цену перед покупкой';

  @override
  String get habitWait24Hours => 'Подожди 24 часа перед одной покупкой';

  @override
  String get habitCelebrateMoneyWin => 'Порадуйся одной финансовой победе';

  @override
  String get habitSavingsGoal => 'Поставь одну маленькую цель для накоплений';

  @override
  String get habitSitStill => 'Посиди тихо 10 секунд';

  @override
  String get habitKindThing => 'Сделай одну приятную вещь для себя';

  @override
  String get habitDrinkSlowly => 'Выпей воды не торопясь';

  @override
  String get habitStretchNeck => 'Потяни шею';

  @override
  String get habitOneSlowBreath => 'Один медленный вдох';

  @override
  String get habitNoticeLikeAboutSelf =>
      'Заметь что-то, что тебе в себе нравится';

  @override
  String get habitPermissionSayNo => 'Разреши себе сказать «нет»';

  @override
  String get habitFeelGood => 'Сделай что-то приятное';

  @override
  String get habitRestTwoMinutes => 'Отдохни 2 минуты';

  @override
  String get habitPutOnComfortable => 'Надень что-нибудь удобное';

  @override
  String get habitListenToSong => 'Послушай одну любимую песню';

  @override
  String get habitDoNothing => 'Ничего не делай 30 секунд';

  @override
  String get shareCardWeeklyCheckin => 'За неделю';

  @override
  String get shareCardMilestone => 'Достижение';

  @override
  String get shareCardShowedUpPhrase => 'На этой неделе я позаботился о себе';

  @override
  String get shareCardTimes => 'раз';

  @override
  String get shareCardTagline => 'намерение, а не совершенство';

  @override
  String get shareCardWeeks => 'недель';

  @override
  String get shareCardMilestoneSubtext => 'бережного отношения к себе';

  @override
  String get shareCardDescriptor => 'намерение, а не совершенство';

  @override
  String get sharePickerTitle => 'Чем бы ты хотел поделиться?';

  @override
  String get shareWeeklySubtitle =>
      'сколько раз ты позаботился о себе на этой неделе';

  @override
  String get shareShowingUpSubtitle => 'по-своему, в своём темпе';

  @override
  String get shareFocusAreaSubtitle => 'то, к чему ты возвращаешься';

  @override
  String get shareYourThingSubtitle => 'привычка, которая приживается';

  @override
  String get milestoneShowingUpLabel => 'Ты здесь';

  @override
  String get milestoneAreaLabel => 'Фокус';

  @override
  String get milestoneIdentityLabel => 'Твоё';

  @override
  String milestoneShowingUpHero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'недель',
      few: 'недели',
      one: 'неделя',
    );
    return '$count $_temp0';
  }

  @override
  String get milestoneShowingUpSubtitle => 'ты продолжаешь по-своему';

  @override
  String milestoneAreaHero(String area) {
    return '$area';
  }

  @override
  String get milestoneAreaSubtitle => 'ты возвращаешься к тому, что важно';

  @override
  String milestoneIdentityHero(String habit) {
    return '$habit';
  }

  @override
  String get milestoneIdentitySubtitle => 'становится твоей привычкой';

  @override
  String get boostCardTitle => 'Intended Boost — €1,99 разово';

  @override
  String get boostCardSubtitle => 'Немного больше пространства для роста.';

  @override
  String get boostOrDivider => 'или';

  @override
  String get boostGoUnlimited => 'Безлимит с Intended+';

  @override
  String get boostPurchaseError =>
      'Что-то пошло не так с покупкой. Попробуй ещё раз.';

  @override
  String get boostBenefit1 => '3 свои привычки';

  @override
  String get boostBenefit1Detail => 'вместо 2';

  @override
  String get boostBenefit2 => '3 направления';

  @override
  String get boostBenefit2Detail => 'вместо 2';

  @override
  String get boostBenefit3 => '3 замены/месяц';

  @override
  String get boostBenefit3Detail => 'вместо 2';

  @override
  String get boostBenefit4 => 'Карточки прогресса для друзей';

  @override
  String get boostOfferHabitTitle => 'Хочешь ещё одну привычку?';

  @override
  String get boostOfferHabitDesc =>
      'Ты строишь что-то важное — дай себе место для ещё одной.';

  @override
  String get boostOfferFocusTitle => 'Нужно ещё одно направление?';

  @override
  String get boostOfferFocusDesc =>
      'Твой рост не помещается в рамки — расширь то, на чём фокусируешься.';

  @override
  String get boostOfferSwapTitle => 'Замены закончились?';

  @override
  String get boostOfferSwapDesc =>
      'Поиск подходящих привычек — это путь. Получи ещё несколько попыток.';

  @override
  String get boostOfferShareTitle => 'Поделиться прогрессом?';

  @override
  String get boostOfferShareDesc =>
      'Твой путь стоит того, чтобы им делиться — покажи его близким.';
}
