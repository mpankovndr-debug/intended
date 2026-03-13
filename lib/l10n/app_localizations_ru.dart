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
  String get welcomeSubtitle =>
      'Маленькие ежедневные привычки —\nбез чувства вины.';

  @override
  String get onboardingTagline => 'Намерение важнее совершенства.';

  @override
  String get onboardingDescriptor =>
      'Без стриков. Без оценок. Просто маленькие шаги, которые возвращают тебя к себе.';

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
  String get focusAreaHealthSub => 'Твоё тело скажет спасибо.';

  @override
  String get focusAreaMood => 'Настроение';

  @override
  String get focusAreaMoodSub => 'Замечай, как себя чувствуешь. Это уже шаг.';

  @override
  String get focusAreaProductivity => 'Продуктивность';

  @override
  String get focusAreaProductivitySub => 'По одному делу. Этого достаточно.';

  @override
  String get focusAreaHome => 'Дом и порядок';

  @override
  String get focusAreaHomeSub => 'Маленький порядок — большое спокойствие.';

  @override
  String get focusAreaRelationships => 'Отношения';

  @override
  String get focusAreaRelationshipsSub => 'Люди, которые важны.';

  @override
  String get focusAreaCreativity => 'Творчество';

  @override
  String get focusAreaCreativitySub => 'Создавай что угодно.';

  @override
  String get focusAreaFinances => 'Финансы';

  @override
  String get focusAreaFinancesSub => 'Маленькие шаги к спокойствию за деньги.';

  @override
  String get focusAreaSelfCare => 'Забота о себе';

  @override
  String get focusAreaSelfCareSub =>
      'Те маленькие радости, которые ты всё время откладываешь.';

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
  String get focusAreasChangeLater => 'Это всегда можно изменить позже.';

  @override
  String get focusAreasLimitTitle => 'Пока хватит';

  @override
  String get focusAreasLimitMessage =>
      'Можно выбрать до 2 направлений. Убери одно, чтобы выбрать другое.';

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
  String get themeSelectionSubtitle => 'Это всегда можно изменить позже.';

  @override
  String get themeSelectionConfirm => 'Мне это подходит';

  @override
  String get themeSelectionPremiumHint =>
      '«Глубокий фокус» и другие темы доступны с Intended+. Попробуй бесплатно 7 дней после настройки.';

  @override
  String get habitRevealTitle => 'Вот, что мы подобрали для тебя';

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
      'Выбирай то, что подходит. Пропускай то, что нет. Не нужно делать всё — достаточно одного.';

  @override
  String get habitRevealBegin => 'Давай начнём';

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
  String get dailyMessage1 => 'Делай то, что считаешь верным сегодня';

  @override
  String get dailyMessage2 => 'Сегодня новый день';

  @override
  String get dailyMessage3 => 'Даже одна мелочь считается';

  @override
  String get dailyMessage4 => 'Будь добрее к себе сегодня';

  @override
  String get dailyMessage5 => 'Не спеши. Ты справляешься';

  @override
  String get dailyMessage6 => 'Начни с малого, действуй с заботой о себе';

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
  String get dailyMessage17 => 'Одного дела за раз достаточно';

  @override
  String get dailyMessage18 => 'Начни оттуда, где ты сейчас';

  @override
  String get dailyMessage19 => 'Не нужно быть готовым, чтобы начать';

  @override
  String get dailyMessage20 => 'Доверяй своему ритму';

  @override
  String get dailyMessage21 => 'Можно адаптироваться на ходу';

  @override
  String get dailyMessage22 => 'Маленькая забота о себе — тоже забота';

  @override
  String get dailyMessage23 => 'Ты делаешь больше, чем тебе кажется';

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
  String get customHabitFocusAreaLabel => 'К какому направлению это относится?';

  @override
  String get customHabitSubmit => 'Добавить';

  @override
  String get editHabitTitle => 'Редактировать привычку';

  @override
  String get editHabitSave => 'Сохранить';

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
      'Core: 2 свои привычки\nIntended+: без ограничений';

  @override
  String get menuUnpin => 'Открепить';

  @override
  String get menuPinToTop => 'Закрепить';

  @override
  String get menuSwap => 'Заменить';

  @override
  String get replacePinTitle => 'Заменить закрепленную привычку?';

  @override
  String replacePinDescription(String current, String newHabit) {
    return 'Сейчас: $current\nНовая: $newHabit';
  }

  @override
  String get replacePinConfirm => 'Заменить';

  @override
  String get swapCantTitle => 'Нельзя заменить эту привычку';

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
      'Все бесплатные замены в этом месяце использованы.\n\nIntended+: без ограничений';

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
  String get completionQuestion => 'Ты выполнил это сегодня?';

  @override
  String get completionConfirm => 'Да, у меня получилось!';

  @override
  String get completionDecline => 'Нет, не сегодня';

  @override
  String get celebrationNice => 'Отлично';

  @override
  String get celebrationWellDone => 'Молодец';

  @override
  String get celebrationYouDidIt => 'У тебя получилось';

  @override
  String get celebrationGreat => 'Здорово';

  @override
  String get celebrationWayToGo => 'Так держать';

  @override
  String get celebrationGoodJob => 'Хорошая работа';

  @override
  String get celebrationLovely => 'Чудесно';

  @override
  String get completionMsg1 => 'Маленькие шаги, как этот, важны.';

  @override
  String get completionMsg3 => 'Вот так и происходят перемены.';

  @override
  String get completionMsg4 => 'Ещё на шаг ближе.';

  @override
  String get completionMsg7 => 'Ещё одна маленькая победа.';

  @override
  String get completionMsg8 => 'У тебя получилось.';

  @override
  String get completionMsg11 => 'Это считается.';

  @override
  String get completionMsg12 => 'Обещание себе выполнено.';

  @override
  String get completionMsg13 => 'Поздравляю!';

  @override
  String get completionMsg14 => 'На это нашлось время.';

  @override
  String get completionMsg16 => 'Ни шагу назад.';

  @override
  String get completionMsg17 => 'Ещё одна привычка укрепилась.';

  @override
  String get completionMsg18 => 'Задумано — сделано.';

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
      'Завтрак запускает обмен веществ на весь день.';

  @override
  String get insightBreakfast3 =>
      'Те, кто завтракает, лучше справляются с когнитивными задачами.';

  @override
  String get insightPhone1 =>
      'Меньше экранного времени перед сном улучшает качество сна на 30%.';

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
      'Перерывы от экрана помогают регулировать дофамин.';

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
  String get warmthMsg4 => 'Не сегодня — и это нормально.';

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
      'Нет стрика, который можно прервать. Нет оценок, которые можно потерять. Просто ты. Здесь.';

  @override
  String get warmthMsg13 => 'Просто знай, что тебя достаточно.';

  @override
  String get warmthMsg15 =>
      'Прогресс не всегда видим. Иногда это просто выстоять.';

  @override
  String get notifMsg1 => 'Не спеши сегодня. Даже одна мелочь имеет значение.';

  @override
  String get notifMsg2 => 'Продуктивность — не условие для отдыха.';

  @override
  String get notifMsg3 => 'Всё, что ты делаешь сегодня — уже достаточно.';

  @override
  String get notifMsg4 => 'Одно небольшое действие. Этого достаточно.';

  @override
  String get notifMsg6 =>
      'Чтобы день был хороший, ему не нужно быть идеальным.';

  @override
  String get notifMsg8 =>
      'Маленькие шаги всё равно обозначают движение вперед.';

  @override
  String get notifMsg9 => 'Начинать медленно — это нормально.';

  @override
  String get notifMsg10 => 'Ты справляешься лучше, чем тебе кажется.';

  @override
  String get notifMsg11 => 'Прогресс не всегда похож на прогресс.';

  @override
  String get notifMsg13 => 'Не нужно заслуживать отдых.';

  @override
  String get notifMsg14 => 'Доброта к себе — тоже привычка.';

  @override
  String get notifMsg15 => 'Сегодня — новый шанс, а не экзамен.';

  @override
  String get notifMsg16 => 'Даже чуть-чуть — это лучше, чем ничего.';

  @override
  String get notifMsg17 => 'Ты всё ещё здесь. Это важно.';

  @override
  String get notifMsg18 => 'Нет неправильного способа провести хорошо день.';

  @override
  String get notifMsg19 => 'Что бы ни принёс сегодняшний день — ты справишься.';

  @override
  String get notifMsg20 => 'Отдых — тоже часть работы.';

  @override
  String get notifMsg21 => 'Не нужно делать всё. Выбери что-то одно.';

  @override
  String get notifMsg22 => 'Сегодняшние привычки — завтрашний фундамент.';

  @override
  String get notifMsg23 => 'Терпение к себе — тоже сила.';

  @override
  String get notifMsg24 => 'Рост происходит тихо. Доверься миру.';

  @override
  String get notifMsg25 => 'Ты строишь что-то настоящее, не торопясь.';

  @override
  String get notifMsg26 => 'Одна привычка. Один момент. Этого достаточно.';

  @override
  String get notifMsg27 => 'Как ты на самом деле сегодня?';

  @override
  String get notifMsg28 => 'Ты сильнее, чем кажется!';

  @override
  String get notifMsg29 =>
      'Не обязательно делать идеально, чтобы это имело смысл.';

  @override
  String get notifMsg30 => 'Ты имеешь право идти шаг за шагом.';

  @override
  String get notifMsg31 => 'Вчерашняя версия тебя гордится тобой сегодня.';

  @override
  String get notifMsg32 =>
      'Рост тише всего, когда он настоящий. Доверяй процессу.';

  @override
  String get notifMsg34 => 'Маленькие ритуалы складываются в большую жизнь.';

  @override
  String get notifMsg35 => 'Ты не отстаёшь. Ты именно там, где должен быть.';

  @override
  String get notifMsg37 => 'Ты строишь отношения с собой. Не торопись.';

  @override
  String get notifMsg38 =>
      'Сегодняшнее маленькое действие — норма через месяц.';

  @override
  String get notifMsg39 => 'Привычки — не про силу воли. Они про заботу.';

  @override
  String get notifMsg41 =>
      'Цель никогда не была совершенством. Цель — продолжать пробовать.';

  @override
  String get notifMsg42 => 'Иногда привычка дня — просто быть добрее к себе.';

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
      'По одной привычке — вот как на самом деле меняется жизнь.';

  @override
  String get notifMsg51 => 'Сегодня хороший день, чтобы быть мягче к себе.';

  @override
  String get notifMsg53 => 'Маленький — не значит незначительный.';

  @override
  String get notifMsg54 =>
      'Что бы ни происходило сегодня — относись к себе с заботой.';

  @override
  String get notifMsg55 => 'Твои привычки — это форма уважения к себе.';

  @override
  String get notifMsg56 => 'Ничего не потеряно. Всегда можно начать снова.';

  @override
  String get notifMsg58 =>
      'Сегодняшнее усилие незаметно сейчас и неоспоримо потом.';

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
  String get affirmation33 =>
      'Тебе не нужна причина, чтобы быть к себе добрее.';

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
      'Каждая выполненная привычка сохраняется в твою коллекцию.';

  @override
  String get momentsEmptyTitle => 'Здесь появятся твои моменты.';

  @override
  String get momentsEmptyMessage =>
      'Каждая выполненная привычка становится частью твоей коллекции.';

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
  String momentsShowAll(int count) {
    return 'Показать все $count моментов';
  }

  @override
  String get paywallTitle => 'Узнай себя лучше';

  @override
  String get paywallDescription =>
      'Intended+ превращает ежедневную практику в настоящее понимание себя.';

  @override
  String get paywallFeature1 =>
      'Еженедельные инсайты, которые раскрывают твои привычки со временем';

  @override
  String get paywallFeature2 =>
      'Виджет на главном экране — мягкое напоминание о себе';

  @override
  String get paywallFeature3 =>
      'Готовые наборы привычек: ритуалы, созданные под твой ритм жизни';

  @override
  String get paywallFeature4 =>
      '10 тем на любое настроение — включая тёмный режим';

  @override
  String get paywallFeature5 =>
      'Безлимитные привычки, замены и фокусы — расти без ограничений';

  @override
  String get paywallMonthly => 'Ежемесячно';

  @override
  String get paywallMonthlyPrice => '€5,99';

  @override
  String get paywallMonthlyPeriod => 'в месяц';

  @override
  String get paywallYearly => 'Ежегодно';

  @override
  String get paywallYearlyPrice => '€44,99';

  @override
  String get paywallYearlyPeriod => 'в год';

  @override
  String get paywallYearlySave => 'Экономия 37%';

  @override
  String paywallSavePercent(int percent) {
    return 'Экономия $percent%';
  }

  @override
  String get paywallLifetime => 'Навсегда';

  @override
  String get paywallLifetimePrice => '€69,99';

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
  String get restoreError =>
      'Не удалось восстановить покупки. Попробуй ещё раз.';

  @override
  String get ok => 'ОК';

  @override
  String get paywallTerms => 'Условия';

  @override
  String get paywallPrivacy => 'Конфиденциальность';

  @override
  String get paywallFooter =>
      'Новые функции добавляются регулярно. Подписка поддерживает независимую разработку.\nСоздано одним человеком, которому это так же важно, как и тебе.';

  @override
  String get subscriptionTitle => 'Intended+';

  @override
  String get subscriptionSupporter => 'Спасибо, что ты с нами ♥';

  @override
  String get subscriptionPlan => 'Тариф';

  @override
  String get subscriptionPrice => 'Цена';

  @override
  String get subscriptionRenews => 'Продление';

  @override
  String get subscriptionThankYou =>
      'Спасибо, что поддерживаешь Intended.\nТы помогаешь нам строить\nмягкую альтернативу культуре продуктивности.';

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
  String get profileNotifDeniedTitle => 'Уведомления отключены';

  @override
  String get profileNotifDeniedMessage =>
      'Чтобы включить напоминания, разрешите уведомления для Intended в настройках устройства.';

  @override
  String get profileNotifOpenSettings => 'Открыть настройки';

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
  String get signOutWarningTitle => 'Выйти?';

  @override
  String get signOutWarningMessage =>
      'Данные хранятся только на этом устройстве. Они не будут доступны на других устройствах или после переустановки.';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileDeleteData => 'Удалить мои данные';

  @override
  String get profileVersion => 'Intended v1.1.0';

  @override
  String get profileCannotOpenEmail => 'Не удалось открыть почту';

  @override
  String get profileEmailFallback => 'Напиши нам на\nsupport@intendedapp.com';

  @override
  String get profileChangeFocusTitle => 'Изменить направления?';

  @override
  String get profileChangeFocusMessage =>
      'Привычки обновятся на основе новых направлений.';

  @override
  String get profileChangeAreas => 'Изменить направления';

  @override
  String get profileFocusLimitMessage =>
      'Бесплатная замена в этом месяце уже использована.';

  @override
  String get profileFocusLimitOptions => '• Intended+: без ограничений';

  @override
  String get profilePayAmount => 'Оплатить €0,99';

  @override
  String get profilePaymentTitle => 'Оплата';

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
      'Привычки обновлены 3 раза сегодня. Попробуй завтра или открой Intended+ для безлимитных обновлений.';

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
  String get profileDeleteErrorMessage =>
      'Не удалось удалить аккаунт. Попробуй ещё раз.';

  @override
  String get profileReauthTitle => 'Войди снова';

  @override
  String get profileReauthMessage =>
      'Для безопасности, пожалуйста, войди снова, чтобы подтвердить удаление аккаунта.';

  @override
  String get profileReauthButton => 'Войти';

  @override
  String get profileChangeFocusAreasScreenTitle => 'Смена направлений';

  @override
  String get profileChooseUpTo2 => 'Выбери до 2 направлений';

  @override
  String get profileSaveChanges => 'Сохранить';

  @override
  String get themeWarmClay => 'Терракота';

  @override
  String get themeIris => 'Ирис';

  @override
  String get themeClearSky => 'Ясное небо';

  @override
  String get themeMorningSlate => 'Утренний сланец';

  @override
  String get themeSoftDusk => 'Розовые сумерки';

  @override
  String get themeDeepFocus => 'Тёмный уют';

  @override
  String get themeForestFloor => 'Утренний лес';

  @override
  String get themeGoldenHour => 'Золотой час';

  @override
  String get themeNightBloom => 'Ночное небо';

  @override
  String get themeSandDune => 'Тёплый песок';

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
  String get habitDrinkWater => 'Выпей 3 стакана воды';

  @override
  String get habitThreeSlowBreaths => 'Сделай 3 медленных вдоха';

  @override
  String get habitStretchTenSeconds => 'Потянись 30 секунд';

  @override
  String get habitRollShoulders => 'Встань и разомни плечи';

  @override
  String get habitStepOutside => 'Выйди на улицу на 5 минут';

  @override
  String get habitCloseEyes => 'Закрой глаза на 30 секунд';

  @override
  String get habitNeckRolls => 'Сделай 5 мягких вращений шеей';

  @override
  String get habitWalkToWindow => 'Дойди до окна и обратно';

  @override
  String get habitBellyBreaths => 'Сделай 5 глубоких вдохов животом';

  @override
  String get habitBodyScan => 'Последи за телом - 2 минуты';

  @override
  String get habitGentleMovement => '5 минут мягкой разминки';

  @override
  String get habitMindfulMeal => 'Один осознанный приём пищи';

  @override
  String get habitTenSecondPause => 'Пауза на 1 минуту';

  @override
  String get habitNoticeFeeling => 'Заметь, что чувствуешь сейчас';

  @override
  String get habitGroundingBreath => 'Три заземляющих вдоха';

  @override
  String get habitLookAway => 'Отведи взгляд от экрана на 30 секунд';

  @override
  String get habitNameThreeThings => 'Назови три вещи, которые видишь';

  @override
  String get habitNoticeSound => 'Заметь один звук вокруг тебя';

  @override
  String get habitFeelFeet => 'Почувствуй ступни на полу';

  @override
  String get habitHandOnHeart => 'Положи руку на сердце на 30 секунд';

  @override
  String get habitGratefulThing =>
      'Назови 3 вещи, за которые чувствуешь благодарность';

  @override
  String get habitSmileGently => 'Добро улыбнись себе';

  @override
  String get habitAskNeed => 'Спроси себя: «Что мне сейчас нужно?»';

  @override
  String get habitPermissionToRest => 'Разреши себе отдохнуть';

  @override
  String get habitSetPriority => 'Определи один приоритет на сегодня';

  @override
  String get habitPlanTomorrow => 'Опиши завтрашний день одним предложением';

  @override
  String get habitThirtySecondReset => 'Перезагрузка на 1 минуту';

  @override
  String get habitWriteIdea => 'Отпишись от ненужной рассылки';

  @override
  String get habitFinishTinyTask => 'Заверши одно маленькое дело';

  @override
  String get habitDeclutterDesk => 'Убери лишнее со стола';

  @override
  String get habitReviewCalendar => 'Загляни в календарь';

  @override
  String get habitTurnOffNotification => 'Отключи одно уведомление';

  @override
  String get habitCloseTab => 'Закрой ненужные вкладки';

  @override
  String get habitArchiveEmails => 'Архивируй 5 старых имейлов';

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
  String get habitWaterPlant => 'Полей свои растения';

  @override
  String get habitLightCandle => 'Зажги аромасвечу';

  @override
  String get habitSendMessage => 'Напиши одно сообщение тому, кто тебе дорог';

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
  String get habitTellMeaning => 'Скажи кому-то, как ты ценишь этого человека';

  @override
  String get habitOfferHelp => 'Предложи кому-нибудь помощь';

  @override
  String get habitCelebrateOthers => 'Порадуйся за чью-то победу';

  @override
  String get habitWriteSentence => 'Напиши короткий рассказ';

  @override
  String get habitDoodle => 'Рисуй каракули 5 минут';

  @override
  String get habitCaptureIdea => 'Запиши одну идею';

  @override
  String get habitNoticeBeauty => 'Заметь одну красивую вещь';

  @override
  String get habitTakePhoto => 'Сфотографируй что-то, что нравится';

  @override
  String get habitDrawShape => 'Нарисуй что-то простое';

  @override
  String get habitHumTune => 'Напой мелодию, которая нравится';

  @override
  String get habitRearrange => 'Переставь что-нибудь небольшое';

  @override
  String get habitTryNewWord => 'Выучи одно новое слово';

  @override
  String get habitCreateTinyThing => 'Сыграй одну короткую мелодию';

  @override
  String get habitPlayCreative => 'Поиграй с одним творческим материалом';

  @override
  String get habitImagine => 'Сделай одну распевку';

  @override
  String get habitCheckBalance => 'Попробуй один финансовый совет';

  @override
  String get habitMoveToSavings => 'Отложи ₽300 в копилку';

  @override
  String get habitReviewSubscription => 'Проверь одну подписку';

  @override
  String get habitNoteExpense => 'Запиши 3 траты';

  @override
  String get habitFinancialTip => 'Прочитай один финансовый совет';

  @override
  String get habitDeleteReceipt => 'Удали один старый чек';

  @override
  String get habitUpdateBudget => 'Побалуй себя';

  @override
  String get habitReviewBill => 'Проверь необходимость одной подписки';

  @override
  String get habitPriceCheck => 'Сравни цену перед покупкой';

  @override
  String get habitWait24Hours => 'Подожди 24 часа перед большой покупкой';

  @override
  String get habitCelebrateMoneyWin => 'Порадуйся одной финансовой победе';

  @override
  String get habitSavingsGoal => 'Поставь одну цель для накоплений';

  @override
  String get habitSitStill => 'Посиди тихо 1 минуту';

  @override
  String get habitKindThing => 'Сделай одну приятную вещь для себя';

  @override
  String get habitDrinkSlowly => 'Выпей кружку вкусного кофе';

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
  String get habitRestTwoMinutes => 'Отдохни 5 минут';

  @override
  String get habitPutOnComfortable => 'Надень что-нибудь удобное';

  @override
  String get habitListenToSong => 'Послушай одну любимую песню';

  @override
  String get habitDoNothing => 'Ничего не делай 5 минут';

  @override
  String get shareCardWeeklyCheckin => 'Недельный чек-ин';

  @override
  String get shareCardMilestone => 'Достижение';

  @override
  String get shareCardShowedUpPhrase => 'На этой неделе — забота о себе';

  @override
  String shareCardTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'раз',
      one: 'раз',
    );
    return '$_temp0';
  }

  @override
  String shareCardFocusedOn(String area) {
    return 'Фокус: $area';
  }

  @override
  String get shareCardTagline => 'намерение важнее совершенства';

  @override
  String get shareCardWeeks => 'недель';

  @override
  String get shareCardMilestoneSubtext => 'бережного отношения к себе';

  @override
  String get shareCardDescriptor => 'намерение важнее совершенства';

  @override
  String get shareCardSubtitleSingular => 'раз я выбираю себя на этой неделе';

  @override
  String get shareCardSubtitlePlural => 'раз я выбираю себя на этой неделе';

  @override
  String get shareCardSubtitleDays => 'дней я выбираю себя на этой неделе';

  @override
  String shareCardInsightTwoDays(String day1, String day2) {
    return '$day1 и $day2 — мои дни';
  }

  @override
  String shareCardInsightOneDay(String day) {
    return '$day — мой день';
  }

  @override
  String shareCardInsightFocus(String area) {
    return 'На этой неделе тянет к «$area»';
  }

  @override
  String get shareButton => 'Поделиться';

  @override
  String get sharePickerTitle => 'Чем хочешь поделиться?';

  @override
  String get shareWeeklySubtitle =>
      'сколько раз удалось позаботиться о себе на этой неделе';

  @override
  String get shareShowingUpSubtitle => 'по-своему, в своём темпе';

  @override
  String get shareFocusAreaSubtitle => 'то, к чему ты продолжаешь возвращаться';

  @override
  String get shareYourThingSubtitle => 'привычка, которая приживается';

  @override
  String get milestoneShowingUpLabel => 'Забота о себе';

  @override
  String get milestoneAreaLabel => 'Область фокуса';

  @override
  String get milestoneIdentityLabel => 'Это - твоё!';

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
  String get milestoneShowingUpSubtitle =>
      'ты продолжаешь заботиться о себе по-своему';

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
  String get boostCardTitle => 'Intended Boost — €1,99';

  @override
  String boostCardTitleDynamic(String price) {
    return 'Intended Boost — $price';
  }

  @override
  String get boostCardSubtitle => 'Открой обе тёмные темы.';

  @override
  String get boostOrDivider => 'или';

  @override
  String get boostGoUnlimited =>
      'Хочешь больше? Безлимитный доступ с Intended+';

  @override
  String get boostPurchaseError =>
      'Что-то пошло не так с покупкой. Попробуй ещё раз.';

  @override
  String get boostBenefit1 =>
      'Тёмный уют и Ночное небо — спокойный вид для вечерних проверок.';

  @override
  String get boostOfferHabitTitle => 'Хочешь ещё одну привычку?';

  @override
  String get boostOfferHabitDesc =>
      'Ты строишь что-то важное — дай себе место для ещё одной.';

  @override
  String get boostOfferFocusTitle => 'Нужно ещё одно направление?';

  @override
  String get boostOfferFocusDesc =>
      'Твой рост не помещается в рамки? Расширь то, на чём фокусируешься.';

  @override
  String get boostOfferSwapTitle => 'Замены закончились?';

  @override
  String get boostOfferSwapDesc =>
      'Поиск подходящих привычек — это путь. Получи ещё несколько попыток.';

  @override
  String get boostOfferShareTitle => 'Поделиться прогрессом?';

  @override
  String get boostOfferShareDesc =>
      'Твой путь стоит того, чтобы им делиться - поделись им с близкими.';

  @override
  String get boostOfferThemeTitle => 'Открой обе тёмные темы';

  @override
  String get boostOfferThemeDesc =>
      'Тёмный уют и Ночное небо — спокойный вид для вечерних проверок.';

  @override
  String get commonDismiss => 'Закрыть';

  @override
  String get focusLimitFreeTitle => 'Лимит направлений достигнут';

  @override
  String get focusLimitFreeMessage =>
      'Бесплатный план включает одно направление. Перейди на платный, чтобы открыть больше.';

  @override
  String get focusLimitFreeUpgrade => 'Улучшить';

  @override
  String get focusNudgeTitle => 'Меньше — значит больше';

  @override
  String get focusNudgeMessage =>
      'Меньше направлений — глубже рост. Но тебе виднее.';

  @override
  String get focusNudgeGotIt => 'Понятно';

  @override
  String get profileLocalDataNote =>
      'Данные хранятся только на этом устройстве.';

  @override
  String get shareError => 'Не удалось поделиться. Попробуй ещё раз.';

  @override
  String get restoreSuccess => 'Покупки восстановлены!';

  @override
  String get restoreNotFound => 'Покупки не найдены.';

  @override
  String get onboardingAlreadyHaveAccount => 'Войти';

  @override
  String get onboardingSignInWithApple => 'Войти через Apple';

  @override
  String get onboardingSignInWithGoogle => 'Войти через Google';

  @override
  String get onboardingPhilosophyLabel => 'Прежде чем мы начнём';

  @override
  String get onboardingPhilosophyHeading =>
      'Это не трекер.\nЭто возвращение к себе.';

  @override
  String get onboardingPhilosophyBody =>
      'Никаких стриков. Никакой вины за пропуск.\nТвой прогресс не обнуляется. Достаточно одного лишь намерения.';

  @override
  String get onboardingPhilosophyCta => 'Понятно';

  @override
  String get reflectionTitle => 'Твоя неделя';

  @override
  String get reflectionAnchor7 =>
      '7 из 7. Целая неделя заботы о себе — так держать!';

  @override
  String reflectionAnchor56(int days) {
    return '$days из 7 дней. Это $days дней, когда ты выбираешь себя.';
  }

  @override
  String reflectionAnchor34(int days) {
    return '$days дня. Это $days дня, когда ты выбираешь себя.';
  }

  @override
  String reflectionAnchor12(int days) {
    return '$days раз. Даже один день считается — ты не пропадаешь.';
  }

  @override
  String get reflectionAnchor0 =>
      'Тихая неделя. Ничего страшного. Ты здесь сейчас, и это главное.';

  @override
  String reflectionPatternOneDay(String dayName) {
    return 'Похоже, $dayName — это твой день. Уже три недели подряд.';
  }

  @override
  String reflectionPatternTwoDays(String dayName1, String dayName2) {
    return '$dayName1 и $dayName2 — похоже, это твои дни.';
  }

  @override
  String get reflectionPatternNone =>
      'Твой ритм всё ещё формируется. Это нормально — продолжай.';

  @override
  String reflectionFocusDominant(String area) {
    return 'На этой неделе тебя тянет к «$area». Кажется, сейчас это важно.';
  }

  @override
  String reflectionFocusBalanced(String area1, String area2) {
    return 'Энергия этой недели распределилась между «$area1» и «$area2». Сбалансированная неделя.';
  }

  @override
  String get reflectionReframeComeback =>
      'Прошлая неделя была тише. А на этой — возвращение. В этом и смысл.';

  @override
  String reflectionReframeRefresh(int count) {
    return 'Привычки обновились $count раз на этой неделе — это не отказ, это адаптация.';
  }

  @override
  String get reflectionReframeSwap =>
      'Одна привычка заменена на этой неделе. Понять, что не подходит — тоже прогресс.';

  @override
  String get reflectionShare => 'Поделиться';

  @override
  String get insightsGrowthHint => 'Инсайты становятся точнее с каждой неделей';

  @override
  String get reflectionTeaser => 'Узнай больше о своей неделе';

  @override
  String get reflectionSectionThisWeek => 'ЭТА НЕДЕЛЯ';

  @override
  String get reflectionSectionYourRhythm => 'ТВОЙ РИТМ';

  @override
  String get reflectionSectionYourFocus => 'ТВОЙ ФОКУС';

  @override
  String get reflectionSectionNotice => 'НА ЗАМЕТКУ';

  @override
  String get reflectionPreviewRhythm =>
      'Через пару недель мы покажем, в какие дни ты стабильнее всего';

  @override
  String get reflectionPreviewFocus =>
      'Выполняй больше привычек, чтобы увидеть, к чему тебя тянет';

  @override
  String get reflectionBlurRhythm =>
      'Узнай, какие дни и ритмы подходят тебе лучше всего';

  @override
  String get reflectionBlurFocus =>
      'Узнай, на что уходит твоя энергия каждую неделю';

  @override
  String get reflectionUnlockPlus => 'Мои недельные инсайты';

  @override
  String get tipPinHabit => 'Удерживайте привычку, чтобы закрепить её сверху';

  @override
  String get tipCuratedPack =>
      'Попробуйте готовый набор привычек, который можно найти в «Все привычки»';

  @override
  String get tipWidget =>
      'Добавь Intended на главный экран — удерживай экран и добавь виджет';

  @override
  String get tipGotIt => 'Понятно';

  @override
  String get tipSkipAll => 'Пропустить подсказки';

  @override
  String get packSwapTitle => 'Освободите место для нового набора';

  @override
  String get packSwapSubtitle =>
      'Чтобы сохранить порядок, выберите привычки, которые хотите убрать. Ваши собственные привычки будут всегда с вами.';

  @override
  String packSwapConfirm(int count, String packName) {
    return 'Убрать $count и добавить $packName';
  }

  @override
  String packSwapAdded(int count) {
    return 'добавлен — $count новых привычек готовы';
  }

  @override
  String get packSwapAllActive => 'Все привычки из этого набора уже активны';

  @override
  String get packSectionHeader => 'ГОТОВЫЕ НАБОРЫ ПРИВЫЧЕК';

  @override
  String packHabitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count привычек',
      few: '$count привычки',
      one: '1 привычка',
    );
    return '$_temp0';
  }

  @override
  String get packFreeBadge => 'Бесплатно';

  @override
  String packStartButton(String packName) {
    return 'Активировать «$packName»';
  }

  @override
  String get packHabitsInPack => 'ПРИВЫЧКИ В НАБОРЕ';

  @override
  String get packAllActive => 'Все привычки уже активны';

  @override
  String get packHabitActive => 'Активна';

  @override
  String get packActiveBadge => 'Активен';

  @override
  String get packGentleMorningsName => 'Мягкое утро';

  @override
  String get packGentleMorningsSubtitle =>
      'Утренний ритуал, который не похож на подъём в 5 утра';

  @override
  String get packGentleMorningsDescription =>
      'Четыре маленькие привычки как мягкая последовательность — выпить воды, подышать свежим воздухом, сосредоточиться и наметить день. Ранний подъём не нужен.';

  @override
  String get packWindingDownName => 'Вечерний покой';

  @override
  String get packWindingDownSubtitle =>
      'Вечерний набор для перезагрузки. Специально короткий.';

  @override
  String get packWindingDownDescription =>
      'Маленький ритуал, чтобы отпустить день. Остановиться, подумать, устроиться поудобнее, насладиться чем-то одним. Вот и весь вечерний план.';

  @override
  String get packTinyResetsName => 'Мини-перезагрузка';

  @override
  String get packTinyResetsSubtitle =>
      'Когда среди недели всё летит в тартарары';

  @override
  String get packTinyResetsDescription =>
      'Когда накрывает — четыре микро-действия создают островок контроля. Не система продуктивности — набор первой помощи.';

  @override
  String get packCreativeSparkName => 'Творческий импульс';

  @override
  String get packCreativeSparkSubtitle =>
      'Маленькие творческие шаги. Талант не нужен.';

  @override
  String get packCreativeSparkDescription =>
      'Три крошечные творческие привычки, которые помогут выйти из головы и начать делать. Не про мастерство — про игру.';

  @override
  String get packStayConnectedName => 'На связи';

  @override
  String get packStayConnectedSubtitle =>
      'Те, кто важен — один маленький жест за раз.';

  @override
  String get packStayConnectedDescription =>
      'Четыре микро-привычки, чтобы оставаться ближе к своим людям. Не грандиозные жесты — просто быть рядом.';

  @override
  String get widgetToday => 'сегодня';

  @override
  String widgetMore(int n) {
    return 'ещё $n';
  }

  @override
  String get widgetUpgrade => 'Обновите для подробностей';

  @override
  String get widgetNoHabits => 'Пока нет привычек';

  @override
  String get widgetAllDone => 'Всё сделано!';

  @override
  String get appIconSectionTitle => 'ИКОНКА ПРИЛОЖЕНИЯ';

  @override
  String get appIconDefault => 'По умолчанию';

  @override
  String get appIconMidnight => 'Полночь';

  @override
  String get appIconRose => 'Роза';

  @override
  String get appIconForest => 'Лес';

  @override
  String get appIconSky => 'Небо';

  @override
  String get legalDisclaimerPrefix =>
      'Нажимая «Продолжить», вы соглашаетесь с нашими ';

  @override
  String get legalDisclaimerTerms => 'Условиями';

  @override
  String get legalDisclaimerAnd => ' и ';

  @override
  String get legalDisclaimerPrivacy => 'Политикой конфиденциальности';

  @override
  String get legalDisclaimerSuffix => '.';
}
