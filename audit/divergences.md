# Divergences — the stored title and the string the user actually reads

*Audit only, 2026-08-24. No code changed. Companion to [`intention-library.md`](intention-library.md).*

Every seeded intention exists twice: once as the **stored English title** — the key in
`OnboardingState.habitsByCategory`, the string written into `Moment.habitName`, and the string
`habit_done_*` prefs keys are built from — and once as the **rendered string** the user reads,
looked up through `habit_l10n.dart` → `app_en.arb`. When those two disagree, the history says one
thing and the person did another.

**23 of the 87 seeded intentions diverge.** Computed by joining the three sources
(`habitsByCategory` → `_habitNameGetters` → `app_en.arb`) and comparing; reproduce with the script
at the end of this file.

## Summary

| class | count | what it means |
|---|---|---|
| **DRIFT** | **17** | same act, different quantity, duration or adverb |
| **WORDING** | **5** | same act, same magnitude, different phrasing |
| **SUBSTITUTION** | **1** | a different act — doing the rendered one does not mean you did the stored one |

**Three-way mismatches: none.** In all 23 cases the Russian string tracks the **rendered** English,
not the stored title. Russian and English readers see the same intention as each other; both differ
from what gets written into the archive. The defect is one-sided, not a three-way split.

---

## SUBSTITUTION — 1

| # | stored (written to `Moment.habitName`) | rendered (what the user reads) | RU | RU gloss | RU tracks |
|---|---|---|---|---|---|
| 21 | `Drink water slowly` | **Drink a cup of tasty coffee** | Выпей кружку вкусного кофе | "Drink a mug of tasty coffee" | rendered |

Area: Self-care. The stored title and the rendered string share no object and no intent — one is
water, deliberately slow; the other is coffee, framed as a treat. A moment recorded here says the
person drank water slowly. They drank coffee.

---

## DRIFT — 17

| # | area | stored | rendered | RU | RU gloss | RU tracks |
|---|---|---|---|---|---|---|
| 1 | Creativity | `Doodle for 10 seconds` | Doodle for 5 minutes | Рисуй каракули 5 минут | "Doodle for 5 minutes" | rendered |
| 3 | Health | `10 minutes of gentle movement` | 5 minutes of gentle stretching | 5 минут мягкой разминки | "5 minutes of gentle warm-up" | rendered |
| 4 | Health | `Close your eyes for 20 seconds` | Close your eyes for 30 seconds | Закрой глаза на 30 секунд | "…for 30 seconds" | rendered |
| 5 | Health | `Drink a glass of water` | Drink 3 glasses of water | Выпей 3 стакана воды | "Drink 3 glasses of water" | rendered |
| 6 | Health | `Step outside for 30 seconds` | Step outside for 5 minutes | Выйди на улицу на 5 минут | "Go outside for 5 minutes" | rendered |
| 7 | Health | `Stretch for 10 seconds` | Stretch for 30 seconds | Потянись 30 секунд | "Stretch for 30 seconds" | rendered |
| 10 | Home & org | `Take out one small bag of trash` | Take out one bag of trash | Вынеси один мешок мусора | "Take out one bag of trash" | rendered |
| 11 | Home & org | `Water one plant` | Water your plants | Полей свои растения | "Water your plants" | rendered |
| 12 | Mood | `Look away from your screen for 10 seconds` | Look away from your screen for 30 seconds | Отведи взгляд от экрана на 30 секунд | "…for 30 seconds" | rendered |
| 13 | Mood | `Notice one thing you're grateful for` | Name 3 things you're grateful for | Назови 3 вещи, за которые чувствуешь благодарность | "Name 3 things you feel grateful for" | rendered |
| 14 | Mood | `One grounding breath` | Three grounding breaths | Три заземляющих вдоха | "Three grounding breaths" | rendered |
| 15 | Mood | `Place hand on heart for a moment` | Place hand on heart for 30 seconds | Положи руку на сердце на 30 секунд | "…for 30 seconds" | rendered |
| 17 | Mood | `Ten-second pause` | One-minute pause | Пауза на 1 минуту | "A 1-minute pause" | rendered |
| 19 | Self-care | `Do a 30-second reset` | Do a 1-minute reset | Перезагрузка на 1 минуту | "A 1-minute reset" | rendered |
| 20 | Self-care | `Do absolutely nothing for 30 seconds` | Do absolutely nothing for 5 minutes | Ничего не делай 5 минут | "Do nothing for 5 minutes" | rendered |
| 22 | Self-care | `Rest for 2 minutes` | Rest for 5 minutes | Отдохни 5 минут | "Rest for 5 minutes" | rendered |
| 23 | Self-care | `Sit still for 10 seconds` | Sit still for 1 minute | Посиди тихо 1 минуту | "Sit quietly for 1 minute" | rendered |

**Direction is not random. 16 of the 17 drift *upward*** — the rendered ask is longer, more, or
bigger than the stored one (10s→30s, 30s→5min, 1→3, a moment→30 seconds, and #10 dropping "small"
so the bag gets bigger). Exactly **one** shrinks: #3, `10 minutes of gentle movement` → 5 minutes,
which is also the one whose act narrows. The stored library is the smaller, gentler set; the
rendered library is the one users are actually asked to do.

---

## WORDING — 5

| # | area | stored | rendered | RU | RU gloss | RU tracks |
|---|---|---|---|---|---|---|
| 2 | Creativity | `Try one new word` | Learn one new word | Выучи одно новое слово | "Learn one new word" | rendered |
| 8 | Health | `Take 5 deep belly breaths` | Take 5 slow, deep breaths | Сделай 5 медленных глубоких вдохов | "Take 5 slow deep breaths" | rendered |
| 9 | Home & org | `Light a candle` | Light a scented candle | Зажги аромасвечу | "Light a scented candle" | rendered |
| 16 | Mood | `Smile gently at yourself` | Smile kindly at yourself | Добро улыбнись себе | "Smile kindly at yourself" | rendered |
| 18 | Relationships | `Send one message to someone` | Send one message to someone you care about | Напиши одно сообщение тому, кто тебе дорог | "Write one message to someone dear to you" | rendered |

---

## Borderline calls — where I could be argued out of the classification

Four of the 23 sit near a boundary. Flagged so the call is yours, not silently mine:

| # | call | the argument against it |
|---|---|---|
| 2 | WORDING | *Try* a word means using it; *learn* a word means acquiring it. You can learn one without ever trying it, so by the strict test ("doing the rendered one does not mean you did the stored one") this is SUBSTITUTION. I kept WORDING because the object is identical — one new word — and the magnitude is unchanged. It is the weakest WORDING of the five. |
| 3 | DRIFT | The noun narrows as well as the number: *movement* → *stretching*. Stretching is a kind of movement, so doing the rendered one does imply the stored one — which is why it stays DRIFT — but this is the only DRIFT where the act itself changes shape, and the duration halves at the same time. |
| 8 | WORDING | Belly breathing is a named diaphragmatic technique; "slow, deep breaths" is generic. Someone taking five generic breaths has not necessarily done belly breaths. Count is identical at 5, which is why it is not DRIFT. |
| 13 | DRIFT | The count change (1→3) is plain drift, but the verb also moves from *notice* (internal) to *name* (spoken or written). "Observation, never assessment" is untouched either way, so I let the count decide. |

## One Russian-quality note, incidental

№16 «Добро улыбнись себе» is grammatical but reads oddly — the adverb is doing work it does not
normally do in this position. «Улыбнись себе по-доброму» or «Улыбнись себе с теплотой» is how a
native speaker would put it. Unrelated to the divergence; noted because it was in front of me.

---

## Recorded moments in local simulator containers

**Question asked:** how many recorded moments carry a stored title from the SUBSTITUTION group —
histories that do not describe what the person actually did.

**Answer: zero.**

Twelve simulator devices exist under `~/Library/Developer/CoreSimulator/Devices`. Three hold the
app's preferences file with a `flutter.moments_collection` key. Moments are stored as a JSON string
in `SharedPreferences` (`MomentsService._key = 'moments_collection'`), which on iOS lands in
`data/Library/Preferences/com.intendedapp.ios.plist` under the `flutter.` prefix.

| device | moments | distinct titles | date range | SUBSTITUTION hits |
|---|---|---|---|---|
| `7607F387…` | 23 | 3 | 2026-08-01 → 2026-08-16 | **0** |
| `889E89FB…` | 37 | 5 | 2026-08-01 → 2026-08-23 | **0** |
| `C3464F10…` | 44 | 9 | 2026-07-24 → 2026-08-18 | **0** |
| **total** | **104** | **17** | | **0** |

`'Drink water slowly'` — the entire SUBSTITUTION group — appears in none of the 104.

The three `group.com.intendedapp.ios` app-group containers were checked too. They hold widget
mirror keys only (`widget_habits`, `widget_month_tiles`, `widget_legend`, …), no moment history,
and the string `Drink water slowly` appears in none of them.

### What those 104 moments *do* carry

**24 of 104 (23%) carry a divergent stored title** — all DRIFT, none SUBSTITUTION:

| count | stored title | rendered |
|---|---|---|
| 9 | `Stretch for 10 seconds` | Stretch for 30 seconds |
| 6 | `Rest for 2 minutes` | Rest for 5 minutes |
| 4 | `Sit still for 10 seconds` | Sit still for 1 minute |
| 3 | `One grounding breath` | Three grounding breaths |
| 2 | `10 minutes of gentle movement` | 5 minutes of gentle stretching |

So the exposure that exists locally is the mild kind: a history that says "stretch for 10 seconds"
for someone who was asked to stretch for 30. Nobody's archive claims they drank water when they
drank coffee.

### Incidental — five recorded titles resolve to nothing

Not asked for, but it surfaced from the same query. Five of the 17 recorded titles are in neither
`habitsByCategory` nor `retiredHabitCategories`:

| count | title | likely |
|---|---|---|
| 14 | `Прогулка` | custom habit (user-typed) |
| 14 | `Take a walk outside` | seeded title dropped without a retirement entry, **or** custom |
| 5 | `Дыхание` | custom habit |
| 4 | `Дневник` | custom habit |
| 1 | `Write down 3 priorities` | seeded title dropped without a retirement entry, **or** custom |

The Cyrillic three are almost certainly customs — `localizeHabitName` returns them as-is by design.
The two English ones are ambiguous from the data alone: they could be customs typed during testing,
or seeded titles removed before `retiredHabitCategories` existed. Distinguishing them needs the
`custom_habits` prefs key, which none of the three containers holds.

---

## Reproducing this

```python
import re, json
en = json.load(open('lib/l10n/app_en.arb'))
hl = open('lib/utils/habit_l10n.dart').read()
getter = dict(re.findall(r"String (_h\w+)\(AppLocalizations l\) => l\.(\w+);", hl))
hb = re.search(r'habitsByCategory\s*=\s*\{(.*?)\n  \};',
               open('lib/onboarding_v2/onboarding_state.dart').read(), re.S).group(1)
pool = {(m.group(1) or m.group(2)).replace("\\'", "'")
        for m in re.finditer(r"\n      (?:'((?:[^'\\]|\\.)*)'|\"([^\"]+)\")\s*,", hb)}
for a, b, fn in re.findall(r"\n  (?:'((?:[^'\\]|\\.)*)'|\"([^\"]+)\"): (_h\w+),", hl):
    stored = (a or b).replace("\\'", "'")
    k = getter.get(fn)
    if stored in pool and k and en.get(k) and en[k] != stored:
        print(repr(stored), '->', repr(en[k]))
```

Moment counts: read `flutter.moments_collection` from each
`~/Library/Developer/CoreSimulator/Devices/*/data/Library/Preferences/com.intendedapp.ios.plist`
with `plistlib`, `json.loads` the value, and count `habitName`.
