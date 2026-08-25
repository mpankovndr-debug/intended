# Reachability audit — can the 44 be surfaced by any other code path?

*Companion to [`intention-library.md`](intention-library.md). Read-only: no code changed.*
*Every claim below names the file and line it came from.*

## Your premise checks out, and here is its exact composition

You said 44 of 98 may be unreachable at onboarding. **That number is right**, and it is more
precise than the 36 my earlier audit reported. Computed from the code:

| bucket | count | why it is not auto-drawn |
|---|---|---|
| Home & organization | 12 | no path lists it in `defaultFocusAreas` |
| Creativity | 12 | same |
| Finances | 12 | same |
| Relationships | 8 | `closerToPeople` *does* default to Relationships, but it has `starterActions`, so its pool is never drawn. Its 4 seeded items are reachable; the other 8 are not. |
| **Total** | **44** | |

My earlier audit counted only the first three (36). The Relationships 8 are the ones it missed:
a path can default to an area and still never draw from it, because `starterActions` short-circuits
the pool ([`onboarding_state.dart:366-378`](lib/onboarding_v2/onboarding_state.dart:366)).

The complement — **54 items auto-reachable** by accepting a path's defaults — is
Health 13 + Mood 13 + Productivity 11 + Self-care 13, plus the 4 Relationships starters.

---

## 1. SWAP / REFRESH

### 1.1 "Adopt a different intention" is not the swap

`todayAdoptIntention` = "Adopt a different intention" ([`app_en.arb:1763`](lib/l10n/app_en.arb:1763))
has exactly one call site: [`main.dart:2265`](lib/main.dart:2265). It pushes **`ChangePathScreen`**.
It changes the *path*, not an action. The code comment beside it says so:
*"adopting an intention redirects the list rather than growing it. Swap, the other door, lives on
the action cards."*

`ChangePathScreen._apply` ([`change_path_screen.dart:257-268`](lib/features/profile/change_path_screen.dart:257))
branches on a confirm dialog:

| user answer | what runs | effect on the action list |
|---|---|---|
| update areas = **yes** | `applyPathDefaults(path.defaultFocusAreas, key)` → `setSelectedIntentionPath` → `generateUserHabits()` | focus areas **replaced** by the new path's defaults; list regenerated |
| update areas = **no** | `setSelectedIntentionPath` only | **list untouched** — only the Today header phrase changes |

So this door can *narrow* reachability: choosing a path replaces the user's focus areas with that
path's two defaults, dropping Home / Creativity / Finances if they had been selected.

**Persistence defect found here.** `applyPathDefaults`
([`onboarding_state.dart:275-283`](lib/onboarding_v2/onboarding_state.dart:275)) mutates `_focusAreas`
in memory and calls `notifyListeners()` — it never writes `focus_areas` to prefs. Neither does
`generateUserHabits`, which persists only `user_habits` and the adoption stamps. The five functions
that do persist `focus_areas` are `adoptFocusArea` (:470), `applyPackFocusAreas` (:478),
`loadUserHabits` (:548), `changeFocusAreas` (:836) and `completeOnboarding` (:853) — none of them is
on this path. The migration at :541 that could repair it is guarded by `if (_focusAreas.isEmpty …)`,
which is false here. **Net effect: after a path change, the new focus areas do not survive an app
restart** — `loadUserHabits` reads the old saved list back. The regenerated *habits* do persist, so
the user is left holding actions from areas their saved focus list no longer contains.

### 1.2 The actual swap

Backed by **`getAlternativeHabits(currentHabit)`**
([`onboarding_state.dart:788-798`](lib/onboarding_v2/onboarding_state.dart:788)), called from
[`main.dart:3669`](lib/main.dart:3669) on the action card.

```
category  = getCategoryForHabit(currentHabit)      // reverse lookup in habitsByCategory
available = habitsByCategory[category]
              .where((h) => !userHabits.contains(h))
available.shuffle(); return available.take(3)
```

| your question | answer |
|---|---|
| What pool? | **The full category of the habit being swapped.** Not the user's focus areas, not the path's `starterActions`, not the whole library. |
| Can it return an item from an unselected focus area? | **Yes — but only an area the user already holds a habit from.** The category is derived from the current habit, so swap can surface items from an area the user has since deselected, but it can never *introduce* a new area. |
| Can it return an item the user already has? | **No.** `!userHabits.contains(h)` filters them out. |
| How many? | 3, shuffled, so repeated opens re-roll. |
| Gated? | Free tier: **2 swaps per month total** (`_maxSwapsFree = 2`, :27; `getTotalSwapsUsed() < maxSwaps()`, :777). Subscribers bypass at the call site ([`main.dart:3661-3666`](lib/main.dart:3661)). |

**This is what rescues the Relationships 8.** A `closerToPeople` user holds 4 Relationships actions,
so swapping any one of them draws from all 12 — the other 8 are reachable.

**It does not rescue `movingALittle`.** Its 4 `starterActions` are all Health
(`HE-03`, `HE-04`, `HE-08`, `HE-11`), so a user who accepts the defaults holds nothing in Self-care —
its other default area — and swap can never reach it, because swap works from held habits only.

### 1.3 Refresh

`refreshHabits()` ([`onboarding_state.dart:864-877`](lib/onboarding_v2/onboarding_state.dart:864))
→ `generateUserHabits()`. Capped at `_maxDailyRefreshes = 3` per day (:93, :822).

**For the five `starterActions` paths, refresh is a no-op.** `generateUserHabits` begins:

```
final starters = path.starterActions;
if (starters != null) { selectedHabits.addAll(starters); }
else if (_focusAreas.isEmpty) { … } else { …shuffled.take(2)… }
```

The `if` returns the same four strings every time, so a `softerNights`, `lookingUp`,
`closerToPeople`, `movingALittle` or `throughAHardSeason` user can press refresh three times a day
forever and the list never changes. It also means **focus areas are ignored entirely** for these
five paths at generation — selecting Finances during onboarding changes nothing about what you are
given.

### 1.4 Browse — the fourth door

`_getHabitsByCategory` ([`main.dart:5522-5546`](lib/main.dart:5522)) backs the browse sheet. Its own
comment reads *"Get habits only from user's selected focus areas."* It iterates `state.focusAreas`,
takes `habitsByCategory[category]`, and filters out held habits. **This is the only surface that
exposes a whole area at once** — and it is strictly bounded by the selected areas.

---

## 2. FOCUS AREA CHANGES

**Yes, editable after onboarding.** Profile → `_changeFocusAreas()`
([`profile_screen.dart:278`](lib/screens/profile_screen.dart:278)), button at
[`:1328`](lib/screens/profile_screen.dart:1328), applied at
[`:2957`](lib/screens/profile_screen.dart:2957) via `changeFocusAreas(_selectedAreas)`.

- **All 8 areas are offered**, including the three no path defaults to
  ([`focus_areas_screen.dart:22-31`](lib/onboarding_v2/focus_areas_screen.dart:22)).
- `maxSelections = 2` (:44).
- Gate: free users **once per calendar month** (`canChangeFocusAreas()`, :802); subscribers bypass
  ([`profile_screen.dart:283`](lib/screens/profile_screen.dart:283)).

| your question | answer |
|---|---|
| Add an area — immediate or next swap? | **Immediate.** `changeFocusAreas` calls `generateUserHabits()` inline ([:832](lib/onboarding_v2/onboarding_state.dart:832)), which draws 2 per area right away. Not deferred. |
| Remove an area — what happens to its actions? | **They are dropped immediately.** `generateUserHabits` rebuilds from scratch: `userHabits = [...selectedHabits, ..._customHabits]`. Custom habits are preserved explicitly; a pinned habit that no longer exists is cleared and removed from prefs ([:387-395](lib/onboarding_v2/onboarding_state.dart:387)). |
| Caveat | If the path has `starterActions`, `changeFocusAreas` still re-applies those four regardless of which areas were chosen — so for five of nine paths, editing focus areas has **no effect on the action list at all**. |

**Three other writers of `_focusAreas`:**

| function | file:line | behaviour |
|---|---|---|
| `adoptFocusArea` | [:463](lib/onboarding_v2/onboarding_state.dart:463) | Adds one area, persists, **does not regenerate habits**. Paid monthly-plan surface, called from [`insights_screen.dart:1749`](lib/screens/insights_screen.dart:1749). Ignores the 2-area cap by design. |
| `applyPackFocusAreas` | [:474](lib/onboarding_v2/onboarding_state.dart:474) | **Replaces** all areas with the pack's, persists, no cap enforcement — `tinyResets` sets **4** areas, exceeding the free tier's 2. |
| `applyPathDefaults` | [:275](lib/onboarding_v2/onboarding_state.dart:275) | Replaces in memory, **not persisted** (see 1.1). |

**The plan nudge cannot bootstrap a new area.** `_addFocusArea`
([`month_plan.dart:215-237`](lib/models/month_plan.dart:215)) derives its suggestion from
`m.category` over recorded moments, skipping areas already selected. You can only have recorded a
Finances moment if you already held a Finances action. The one exception is a **custom habit
assigned to Finances** via `addCustomHabit(title, focusArea:)` ([:883](lib/onboarding_v2/onboarding_state.dart:883)) —
which still requires the user to name that area deliberately.

---

## 3. OTHER SURFACES

### 3.1 curated_pack.dart — yes, it bypasses focus areas entirely

`_adoptPack` ([`change_path_screen.dart:82-93`](lib/features/profile/change_path_screen.dart:82)) and
`_PackSwapSheet._confirm` ([`main.dart:6088-6100`](lib/main.dart:6088)) both run
`addHabitsFromPack(pack.habitIds)` ([:438](lib/onboarding_v2/onboarding_state.dart:438)), which adds
the named strings **without consulting focus areas at all**, then `applyPackFocusAreas` rewrites the
areas to the pack's. Capped by `canAddHabit` (`maxActiveHabits = 6`, :41).

Every `habitId` in the file, with its focus area:

| pack | tier | habitId | focus area |
|---|---|---|---|
| gentleMornings | **free** | Drink a glass of water | Health |
| | | Step outside for 30 seconds | Health |
| | | Take 3 slow breaths | Health |
| | | Set one priority | Productivity |
| windingDown | premium | Do absolutely nothing for 30 seconds | Self-care |
| | | Notice one thing you're grateful for | Mood |
| | | Put on something comfortable | Self-care |
| | | Listen to one song you love | Self-care |
| tinyResets | premium | Do a 30-second reset | Productivity |
| | | **Tidy one small thing** | **Home & organization** |
| | | Take 3 slow breaths | Health |
| | | Do one kind thing for yourself | Self-care |
| creativeSpark | premium | **Draw one simple shape** | **Creativity** |
| | | **Capture one idea** | **Creativity** |
| | | **Take one photo of something you like** | **Creativity** |
| stayConnected | premium | Send one message to someone | Relationships |
| | | Reach out to someone you miss | Relationships |
| | | **Give one genuine compliment** | **Relationships** |
| | | Ask someone how they are | Relationships |

All 19 habitIds resolve to real library strings — no pack names a string outside
`habitsByCategory`. Bold = an item in the 44.

**Packs are the only non-manual route into Home & organization and Creativity**, and both are
premium. `creativeSpark` sets `focusAreas: ['Creativity']`, which then opens all 12 Creativity items
to Browse, swap and refresh. `tinyResets` does the same for Home & organization.

**No pack names a Finances habit, and no pack sets Finances as a focus area.**

### 3.2 The three services — none surfaces anything

| service | line | what it does with `habitsByCategory` |
|---|---|---|
| `milestone_service.dart` | [:27-33](lib/services/milestone_service.dart:27) | `_categoryForHabit` — reverse lookup habit → category |
| `reflection_service.dart` | [:340-346](lib/services/reflection_service.dart:340) | `_categoryForHabit` — same |
| `widget_service.dart` | [:223-226](lib/services/widget_service.dart:223) | `_categoryForHabit` — same |

All three read the map **only to colour or group a habit the user already holds**. None iterates it
to offer a new one. **Answer: no.**

---

## 4. STRING DRIFT

**The strings in `habitsByCategory` are not what is rendered.** Every one of the ~20 render sites
goes through `localizeHabitName(englishName, l10n)`
([`habit_l10n.dart:5`](lib/utils/habit_l10n.dart:5)), which looks the stored string up in
`_habitNameGetters` and returns an l10n value. All 98 have an entry, so **all 98 are rewritten
through the l10n layer** — the stored string is never displayed.

Both strings you asked about exist:

| | stored in `habitsByCategory` | rendered on screen | source |
|---|---|---|---|
| desk | `Declutter your desk for 2 minutes` ([:187](lib/onboarding_v2/onboarding_state.dart:187)) | **`Declutter your desk`** | [`app_en.arb:1125`](lib/l10n/app_en.arb:1125) |
| stretching | `10 minutes of gentle movement` ([:173](lib/onboarding_v2/onboarding_state.dart:173)) | **`5 minutes of gentle stretching`** | [`app_en.arb:1106`](lib/l10n/app_en.arb:1106) |

### 4.1 Full diff — 38 of 98 differ

Produced by joining `habitsByCategory` → `_habitNameGetters` → getter → `app_localizations_en.dart`.
`habitAskNeed` and `habitNoticeLikeAboutSelf` were checked by hand and **match** (the first only
appeared to differ because of Dart's `\"` escape).

**A. The action itself changes — 8**

| focusArea | stored | renders |
|---|---|---|
| Productivity | Write down one idea | **Unsubscribe from an unnecessary email list** |
| Creativity | Create one tiny thing | **Play a short melody** |
| Creativity | Imagine one possibility | **Do a vocal warm-up** |
| Creativity | Write one sentence | **Write a short story** |
| Finances | Check your balance | **Try one financial tip** |
| Finances | Update one budget category | **Treat yourself** |
| Finances | Review one bill | **Review necessity of one subscription** |
| Self-care | Drink water slowly | **Drink a cup of tasty coffee** |

**B. The effort floor is inflated — 16**

| stored | renders | factor |
|---|---|---|
| Doodle for 10 seconds | Doodle for 5 minutes | ×30 |
| Step outside for 30 seconds | Step outside for 5 minutes | ×10 |
| Do absolutely nothing for 30 seconds | Do absolutely nothing for 5 minutes | ×10 |
| Sit still for 10 seconds | Sit still for 1 minute | ×6 |
| Ten-second pause | One-minute pause | ×6 |
| Stretch for 10 seconds | Stretch for 30 seconds | ×3 |
| Look away from your screen for 10 seconds | Look away from your screen for 30 seconds | ×3 |
| One grounding breath | Three grounding breaths | ×3 |
| Drink a glass of water | Drink 3 glasses of water | ×3 |
| Note one expense | Note 3 expenses | ×3 |
| Move €1 to savings | Move €3/\$3 to savings | ×3 |
| Notice one thing you're grateful for | Name 3 things you're grateful for | ×3 |
| Do a 30-second reset | Do a 1-minute reset | ×2 |
| Rest for 2 minutes | Rest for 5 minutes | ×2.5 |
| Close your eyes for 20 seconds | Close your eyes for 30 seconds | ×1.5 |
| 10 minutes of gentle movement | 5 minutes of gentle stretching | ÷2 (only one that shrinks) |

**C. Scope or wording widened — 14**

| stored | renders |
|---|---|
| Take 5 deep belly breaths | Take 5 slow, deep breaths |
| Smile gently at yourself | Smile kindly at yourself |
| Set one priority | Set one priority today |
| Declutter your desk for 2 minutes | Declutter your desk |
| Close one browser tab | Close unnecessary browser tabs |
| Take out one small bag of trash | Take out one bag of trash |
| Water one plant | Water your plants |
| Light a candle | Light a scented candle |
| Send one message to someone | Send one message to someone you care about |
| Draw one simple shape | Draw something simple |
| Try one new word | Learn one new word |
| Wait 24 hours before one purchase | Wait 24 hours before a big purchase |
| Set one small savings goal | Set one savings goal |
| Place hand on heart for a moment | Place hand on heart for 30 seconds |

### 4.2 What this invalidates in the previous audit

Yesterday's audit measured the **stored** strings. For these 38 items, its character counts, effort
floors (G2), opening verbs (G4) and object requirements (G7) describe text no user has ever seen.
Two examples: `Imagine one possibility` was classified *mind / under a minute / body-only* — it
renders as `Do a vocal warm-up`, which is *body / needs no object but is a different act entirely*.
`Update one budget category` was counted among the 13 possession-gated Finances items — it renders
as `Treat yourself`, which is not a Finances action at all.

The **Russian** side was out of scope for this audit and has not been checked.

---

## 5. VERDICT

**Items that cannot reach a user through any code path: 0 of 98.**

Every string is reachable, because all 8 focus areas are selectable by every user — at onboarding
and once per calendar month thereafter — and the Browse sheet exposes every unheld item in a
selected area. Reachability is gated, not blocked. The honest answer is a tier list, not a zero:

| tier | items | what the user must do |
|---|---|---|
| **T0 — auto** | **54** | Nothing. Accept the path's defaults. |
| **T1 — one tap, free** | **8** (Relationships) | Hold a `closerToPeople` starter and use a swap (2/month free). |
| **T2 — premium pack, or manual area selection** | **24** (Home & organization 12, Creativity 12) | Buy `tinyResets` / `creativeSpark`, **or** deliberately select the area. |
| **T3 — manual area selection only** | **12** (Finances) | **No path and no pack ever introduces Finances.** The only route is the user choosing it in the picker, spending one of two slots, once a month. |
| **unreachable** | **0** | — |

### The three findings that most affect this

1. **Finances is T3 alone.** Twelve items — 12% of the library — behind a deliberate act no surface
   ever suggests. The one mechanism that could suggest it (`_addFocusArea`) is structurally unable
   to, because it reads from moments the user has already recorded in that area.

2. **`movingALittle` strands its own second focus area.** All four of its `starterActions` are
   Health, so Self-care — its other `defaultFocusArea` — is held by nothing, and swap (which works
   from held habits) can never reach it. `softerNights` and `throughAHardSeason` split their four
   across both areas and do not have this problem.

3. **Refresh is inert for five of nine paths, and the path-change focus-area write is not
   persisted** (1.1, 1.3). Both narrow the practical reach of the doors that exist.

---

*Audit only. 0 files modified. Claims verified by reading `onboarding_state.dart`, `main.dart`,
`change_path_screen.dart`, `profile_screen.dart`, `focus_areas_screen.dart`, `curated_pack.dart`,
`month_plan.dart`, `habit_l10n.dart`, `app_localizations_en.dart` and the three services.*
