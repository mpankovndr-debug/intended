# Completion model — present-but-uncompleted vs. not-present

*Feasibility audit for a weekday mask on custom habits. Read-only: no code changed.*
*Every claim names the file and line it came from.*

## Short answer

**Yes — a habit can be absent on a given day without any surface calling it a miss.**
Nothing in the app stores a "not done" record, and no consumer computes a completion rate over
the habit list. Absence is already unrepresentable, exactly as `CLAUDE.md` claims.

The risk is not misses. It is **four consumers that read a lower moment count as a signal about
the user**, and they cannot tell a masked-off day from a skipped one. Details in §5.

---

## 1. COMPLETION RECORD

There are **two parallel stores**, written at the same moment, read by different consumers.

### 1a. `moments_collection` — the event log

| | |
|---|---|
| Key | `moments_collection` (SharedPreferences `String`) |
| Shape | JSON **list** of Moment objects, newest-capped at `_maxMoments = 1000` ([`moments_service.dart:8-10`](lib/services/moments_service.dart:8)) |
| Keyed by date? | **No.** It is an append-only event log. |

Per-record fields ([`moment.dart:31-62`](lib/models/moment.dart:31)):

```
id                 String   — ISO UTC of creation, or caller-supplied (widget sync)
habitName          String   — the English title, the join key to everything else
habitEmoji         String   — default '✦'
completedAt        DateTime — always UTC
category           String?  — focus area, null when unknown
mood               enum?    — glad_i_did | neutral | took_effort, null if skipped
note               String?  — capped at 280
source             String?  — null in-app, 'widget' from the home screen
localHour          int      — 0–23, stored not derived
localWeekday       int      — 1–7 Mon=1, stored not derived
tzOffsetMinutes    int      — the offset that produced the two above
```

**Local or UTC?** `completedAt` is UTC. The user's calendar day is `Moment.localDay`, rebuilt from
the record's *own* `tzOffsetMinutes` ([`moment.dart:73-76`](lib/models/moment.dart:73)) — never from
the device's current zone. Every day-bucketing consumer I read uses this correctly.

### 1b. `habit_done_{habitId}_{YYYY-MM-DD}` — the daily checkbox

| | |
|---|---|
| Key | `habit_done_` + slugified title + `_` + date ([`main.dart:591-594`](lib/main.dart:591)) |
| Shape | `bool`, only ever `true` |
| habitId | lowercase, non-alphanumerics → `_`, collapsed, trimmed ([`main.dart:582-589`](lib/main.dart:582)) |
| Companion | `habit_title_{habitId}` → original title, so history survives a rename |

**Local or UTC?** Local, and by a different rule from Moments: `_key` does
`date.toIso8601String().substring(0, 10)` on `DateTime.now()`, i.e. the **device's current zone at
write time** ([`main.dart:592, 598`](lib/main.dart:592)). This is the one place that does not follow
the recorded-offset rule. It is pre-existing and out of scope here, but a mask that asks "is today a
Monday?" will have to pick which of the two clocks it means.

### 1c. Is anything written when a habit is NOT completed?

**No. Non-completion is purely the absence of a record.** Verified three ways:

- `markDone` writes `setBool(key, true)` and nothing else ([`main.dart:596-602`](lib/main.dart:596)).
- No call site anywhere writes `false` to a `habit_done_*` key, and none removes one except
  `renameCustomHabit`'s key migration ([`onboarding_state.dart:1009-1016`](lib/onboarding_v2/onboarding_state.dart:1009)).
- There is one further store, and it is transient: `widget_pending_completions`, a JSON queue in
  the App Group's UserDefaults (not SharedPreferences). The widget appends a
  `{habitName, dateKey}` entry on tap; `syncPendingCompletions` drains it at next launch into
  **both** stores above and clears it
  ([`widget_completion_service.dart:28-75`](lib/services/widget_completion_service.dart:28)). It
  carries completions only — there is no "not done" entry shape.

Side fact worth knowing: `reset()` clears fourteen keys but **not** `habit_done_*` and **not**
`moments_collection` ([`onboarding_state.dart:1045-1068`](lib/onboarding_v2/onboarding_state.dart:1045)).
Completion history outlives a full app reset.

---

## 2. ABSENCE INTERPRETATION

| consumer | distinguishes "existed and not done" from "did not exist"? | how it decides |
|---|---|---|
| **Return / "came back"** — `Rescue.read` ([`rescue.dart:38-51`](lib/models/rescue.dart:38)) | **No — and it does not need to.** It never reads the habit list at all. | Days since the newest moment's `localDay`. Fires at `minQuietDays = 5`. |
| **Grid returns** — `MomentGrid.returnIndicesFor` ([`moment_grid.dart:111-126`](lib/widgets/moment_grid.dart:111)) | **No.** Habit-list-independent. | A moment is a "return" when ≥ `gapThresholdDays` quiet days precede it. |
| **Gap rollup** — `MomentRollup.from` ([`moment_rollup.dart:90-95`](lib/models/moment_rollup.dart:90)) | **No.** Habit-list-independent. | Gaps between consecutive `activeDays` — days holding ≥1 moment. |
| **Re-engagement nudge** — `StaleAction.isStale` ([`stale_action_nudge.dart:47-64`](lib/widgets/stale_action_nudge.dart:47)) | **No — this one is per-habit and does read absence.** | `afterDays = 10` with no completion **of that habit**. See §5. |
| **Drift** — `Drift.read` ([`drift.dart:44-60`](lib/models/drift.dart:44)) | **No.** Habit-list-independent. | This week's moment count vs. a 4-week rolling average, below `_threshold = 0.5`. |
| **milestone_service** ([`milestone_service.dart:36-78`](lib/services/milestone_service.dart:36)) | **No — and safe.** Counts only. | Groups moments by `habitName` and by area. No denominator, no habit list. |
| **reflection_service** daily/weekly ([`reflection_service.dart:76-92`](lib/services/reflection_service.dart:76)) | **No — and safe.** | `dailyActivity[i] = completedIds.isNotEmpty` — *activity*, not compliance. The habit list is used only to cache display titles. |
| **reflection_service** monthly / focus areas ([`:102-121`](lib/services/reflection_service.dart:102)) | **No — and safe.** | Ratios are area-share **of completions**, never of opportunities. |
| **week_stats_service** ([`week_stats_service.dart:23-57`](lib/services/week_stats_service.dart:23)) | **No — and safe.** Its own comment says it scans all completions "regardless of whether the habits are still in the user's active list." | `completionCount` = days with any activity, out of 7. |
| **insights_screen** patterns — `Lift.read` ([`lift.dart:82-115`](lib/models/lift.dart:82)) | **No, but it filters by the *current* list.** | `if (!activeHabits.contains(m.habitName)) continue;` — see §3. |
| **month_plan** — `_setAside` ([`month_plan.dart:245-284`](lib/models/month_plan.dart:245)) | **No — reads a low count as "didn't work out".** | Lowest-count active habit, gated on `busiest ≥ (chosenCount+1)*3`. **Excludes customs.** |
| **month_plan** — `_keepAnchor` ([`:293-315`](lib/models/month_plan.dart:293)) | **No.** Ranking only. | Highest-count active habit. |
| **month_plan** — `_addFocusArea` ([`:215-237`](lib/models/month_plan.dart:215)) | **No.** | Counts moments in unselected areas. |
| **widget_service** ([`widget_service.dart:57-72`](lib/services/widget_service.dart:57)) | **Yes — this is the only surface that renders the distinction.** | Iterates the passed habit list and emits `'done': completedIds.contains(id)` per habit. A habit not in the list is simply not on the widget. |
| **Seasons** ([`season.dart`](lib/models/season.dart)) | **No.** Grepped: it never references `activeHabits`, `userHabits` or `habitName`. Purely moment-derived. | — |

**Does anything read absence as a miss?** No surface computes "expected minus completed" as a
failure. The closest thing is `_areAllHabitsDone` / `_checkAllDoneAndBloom`
([`main.dart:3015-3045`](lib/main.dart:3015)), which does `habits.every(...)` over
`visibleHabits()` — but that is a **live today-only** check gating the Quiet Bloom celebration, and
a shorter list makes it *easier* to satisfy, not harder. No negative consequence exists for failing
it.

---

## 3. HISTORY INTEGRITY

### Would a hidden day render a hole, a zero, or a broken chart?

| view | behaviour on a fully-masked, zero-completion day |
|---|---|
| Moment grid | **Nothing.** It indexes by moment, never by date — there is no cell for a day. |
| `dailyActivity[7]` in reflection + week stats | **A false-looking `false`.** The day reads as inactive. Not labelled a miss, but `daysActive` drops and the weekly line ("active on 4 days") shifts. |
| Seasons | Nothing. Moment-derived only. |
| Widget | Nothing historical; it is a today view. |
| Charts | No per-day chart exists to break. |

The one caveat is that this only bites if **every** habit is masked off that day *and* nothing else
is completed. A mask that leaves at least one card standing produces a moment, and every day-level
consumer above is satisfied by a single moment.

### Are past days recomputed from the current habit list?

**Yes, in four places.** This is the more consequential half of the question.

| where | what it recomputes | effect |
|---|---|---|
| `Lift.read` ([`lift.dart:91`](lib/models/lift.dart:91)) | Filters *all* historical moments against the current `visibleHabits()` | If a mask removes a habit from the visible list on off-days, opening Insights on an off-day **erases that habit's entire rating history** from the ranking |
| `month_plan._setAside` / `_keepAnchor` | Ranks last month's counts against the current `activeHabits` ([`insights_screen.dart:1462`](lib/screens/insights_screen.dart:1462)) | Same day-dependence |
| `_categoryForHabit` in milestone / reflection / widget services | Resolves a past moment's focus area from today's `habitsByCategory` + today's custom map | Pre-existing; a deleted custom loses its colour retroactively |
| `visibleHabits()` ([`onboarding_state.dart:64-75`](lib/onboarding_v2/onboarding_state.dart:64)) | The single chokepoint feeding all of the above | — |

`visibleHabits()` is called from nine places: the widget push ([`main.dart:678`](lib/main.dart:678)),
notifications (`:1609`), the home list (`:1748`), both all-done checks (`:3019`, `:3029`), the stale
nudge (`:3113`), swap (`:4992`), and the month plan twice
([`insights_screen.dart:201`, `:1462`](lib/screens/insights_screen.dart:201)). **A mask implemented
inside `visibleHabits()` would silently reach all nine** — including the three that should not see it.

---

## 4. CUSTOM HABITS

### 4a. Stored shape — every field

`addCustomHabit(String habitTitle, {String? focusArea})`
([`onboarding_state.dart:912-944`](lib/onboarding_v2/onboarding_state.dart:912)) writes across
**four** keys. There is no custom-habit object; the title is the primary key everywhere.

| key | type | value |
|---|---|---|
| `custom_habits` | `List<String>` | titles, custom only |
| `user_habits` | `List<String>` | titles, **customs and seeded together** |
| `custom_habit_focus_areas` | `String` (JSON) | `{title: focusArea}` — defaults to `_focusAreas.first` |
| `habit_adopted_at` | `String` (JSON) | `{title: ISO-8601 UTC}` |

Plus, on first completion: `habit_title_{habitId}` and `habit_done_{habitId}_{date}`.

**There is no field for a schedule, a weekday set, an emoji, or any per-habit metadata beyond focus
area.** A mask needs a fifth key — `custom_habits` is a plain `List<String>` and cannot carry one.

Guards: `canAddHabit` (`maxActiveHabits = 6`), case-insensitive duplicate rejection, and a
`ReflectionService.loadCustomHabitFocusAreas()` refresh so the static cache does not hand the new
custom a null category.

### 4b. Separate list or same list?

**Both.** A custom lives in `_customHabits` *and* in `userHabits`. `_customHabits` is the membership
test used to protect them; `userHabits` is what renders.

### 4c. Do they survive `generateUserHabits()` and `changeFocusAreas()`?

**Yes, both.** `generateUserHabits` rebuilds as
`userHabits = [...selectedHabits, ..._customHabits]` ([`:411`](lib/onboarding_v2/onboarding_state.dart:411)),
so customs are re-appended by construction. `changeFocusAreas` calls `generateUserHabits`, so it
inherits the same protection. `setAsideHabits` skips them explicitly
(`if (_customHabits.contains(habit)) continue;`, [`:450`](lib/onboarding_v2/onboarding_state.dart:450)),
and `_setAside` never proposes them. There is also a stale-entry repair at
[`:601-608`](lib/onboarding_v2/onboarding_state.dart:601) that drops customs missing from `userHabits`.

### 4d. Where they are created and edited

| action | file | class / route |
|---|---|---|
| Create | [`main.dart:2351`](lib/main.dart:2351) | `_CreateCustomHabitScreen` (declared line 2314) — a pushed screen, reached from the "add your own" door on Today |
| Rename | [`main.dart:4232`](lib/main.dart:4232) | `_HabitCardState` (line 2766) — a sheet on the card itself |
| Delete | [`main.dart:4399`](lib/main.dart:4399) | `_HabitCardState` — same sheet |

### 4e. Is there an edit sheet at all?

**Yes.** `renameCustomHabit` ([`onboarding_state.dart:968-1024`](lib/onboarding_v2/onboarding_state.dart:968))
is a full edit path, and a careful one — it migrates the focus-area mapping, preserves `adoptedAt`
("rewording an action is not adopting a new one"), moves the pin, rewrites every
`habit_done_{oldId}_*` key to the new id, and migrates the title cache. **A weekday mask has an
existing sheet to live in and an existing migration routine to extend.**

---

## 5. VERDICT

### Can a habit be absent on a given day without any surface treating it as a miss?

**Yes.** No store records non-completion, and no consumer computes a rate over the habit list. The
data model already assumes absence carries no meaning.

### But four consumers will misread a masked day. None calls it a miss; all four draw a conclusion.

| # | consumer | what goes wrong | severity |
|---|---|---|---|
| 1 | `StaleAction.isStale` ([`stale_action_nudge.dart:47`](lib/widgets/stale_action_nudge.dart:47)) | `afterDays = 10`. A weekly habit done every week peaks at a 7-day gap and is safe. **Miss one occurrence → 14 days → the "this may not fit" card fires** on a habit the user deliberately scheduled. Any mask sparser than weekly is stale by construction. | **highest** |
| 2 | `Lift.read` ([`lift.dart:91`](lib/models/lift.dart:91)) | Filters history by the *current* visible list. If the mask hides the habit on off-days, its whole rating history disappears from Insights on those days — and reappears on-day. A ranking that changes by weekday. | **high** |
| 3 | `Drift.read` ([`drift.dart:44`](lib/models/drift.dart:44)) | Compares this week's moment count against a 4-week average built **before** the mask existed. Masking habits lowers the weekly count; drift reads the drop as running below baseline and warns. | **medium** — one-off, self-corrects after ~4 weeks |
| 4 | `Rescue.read` ([`rescue.dart:38`](lib/models/rescue.dart:38)) + gap/return logic | Only bites if a mask leaves a day with **no** cards at all and the user does nothing else. Five such days → the reduced rescue screen; two → a "return" marker in the month's history. | **low** — needs a fully-empty day |

### What would need to change first

| must change | why |
|---|---|
| `StaleAction.isStale` / `.primary` | Needs the mask, so the window counts *offered* days rather than calendar days. Today it takes only `habit`, `moments`, `now`, `adoptedAt`. |
| The `visibleHabits()` call sites at [`insights_screen.dart:201`](lib/screens/insights_screen.dart:201) and [`:1462`](lib/screens/insights_screen.dart:1462) | These pass the render list to `Lift` and `MonthPlan` as *"which habits are mine"*. A mask inside `visibleHabits()` changes their meaning to *"which habits are mine today"*. They need the unmasked list. |
| A fifth storage key | `custom_habits` is a `List<String>`; there is nowhere to put a weekday set. |
| `renameCustomHabit` | Its migration block must carry the mask across a rename, as it already does for focus area, `adoptedAt`, pin and `habit_done_*`. |
| `reset()` | Must clear the new key, as it does for the other custom-habit keys. |

### Two things that need no change

- **`_setAside` is safe by construction.** It excludes customs outright —
  `.where((h) => !customHabits.contains(h))` ([`month_plan.dart:257`](lib/models/month_plan.dart:257)) —
  and the mask is custom-only. The nudge most likely to punish a low count cannot see masked habits.
- **`_areAllHabitsDone` / Quiet Bloom** ([`main.dart:3015`](lib/main.dart:3015)) already reads
  `visibleHabits()` live. A mask there makes the bloom easier to reach on light days, which is
  probably what you want.

### The design fork this forces

`visibleHabits()` is one chokepoint feeding nine call sites, and they mean two different things by
it — *"what to draw right now"* (widget, home, bloom, swap) and *"which habits are the user's"*
(Lift, MonthPlan, StaleAction). A mask applied inside it silently changes both. **Whether the mask
belongs in `visibleHabits()` or in a second method beside it is the first decision to make**, and
this audit does not make it.

---

*Audit only. 0 files modified. Read: `moment.dart`, `moments_service.dart`, `moment_rollup.dart`,
`rescue.dart`, `drift.dart`, `lift.dart`, `season.dart`, `month_plan.dart`, `moment_grid.dart`,
`stale_action_nudge.dart`, `milestone_service.dart`, `reflection_service.dart`,
`week_stats_service.dart`, `widget_service.dart`, `onboarding_state.dart`, `insights_screen.dart`,
`main.dart`.*
