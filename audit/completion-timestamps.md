# Completion timestamps — can we detect "this has become automatic"?

*Feasibility audit for a feature that notices a long-consistent action and offers the slot back.*
*Read-only: 0 files changed. Every claim names the file and line it came from.*

## Short answer

**The 30/60/90-day half is a logic feature on existing data. The "since adoption" half and the
"consecutive offered days" half are not — they need new storage.**

Three specific things are missing, and each has a named cause:

1. **`habit_adopted_at` is "most recently joined Today", not "first adopted."** It is pruned on
   every removal, including the implicit removals a refresh and a focus-area change perform.
2. **Nothing records what was *offered* on a past day.** Only the current weekday mask and a single
   "last changed" timestamp exist. Offered-day history is unreconstructible.
3. ~~**The two completion stores disagree.**~~ **Fixed on this branch, going forward only.** The
   retro-log ("yesterday") path now writes both stores, dated yesterday
   ([`main.dart:3093-3097`](lib/main.dart:3093)). **Retro-logs recorded before that commit still
   have a Moment and no `habit_done_` key**, and nothing backfills them — so history predating the
   fix is still short by exactly those days. See §2.

---

## 1. WHAT IS STORED PER COMPLETION, AND FOR HOW LONG

Two parallel stores, written at the same moment, read by different consumers. The shape of each is
already documented in [`completion-model.md` §1](audit/completion-model.md); this section answers
only the retention question.

### 1a. `moments_collection` — rich, but capped

The cap is a hard trim of the **oldest** records, applied on every write
([`moments_service.dart:22-27`](lib/services/moments_service.dart:22)):

```
all.sort((a, b) => b.completedAt.compareTo(a.completedAt));  // newest first
if (all.length > _maxMoments) all.removeRange(_maxMoments, all.length);
```

`_maxMoments = 1000` ([`moments_service.dart:10`](lib/services/moments_service.dart:10)).

**At what rate does the cap start discarding?** It is purely `1000 ÷ moments-per-day`:

| moments/day | days of history retained | ≈ |
|---|---|---|
| 6 (six habits, every one, every day) | 166 | **5 months 15 days** |
| 5 | 200 | 6½ months |
| 4 | 250 | 8 months |
| 3.6 (six habits at 60% adherence) | 277 | **9 months** |
| 3 | 333 | 11 months |
| 2 | 500 | 1 year 4 months |
| 1 | 1000 | 2 years 9 months |

**For your "typical user with 6 habits":** if they complete all six daily, the collection holds
**about five and a half months**. At a realistic 60% adherence, about **nine months**. Either way,
a user who has been going a year has already lost their first months of moments — permanently, since
the trim writes the truncated list back to prefs.

Three consequences that matter for this feature:

- **`MomentRollup.total` is not a lifetime total.** The rollup is rebuilt from the already-trimmed
  list ([`moments_service.dart:28-30`](lib/services/moments_service.dart:28) →
  `_writeRollup(prefs, all)`), so `total` is `min(lifetime, 1000)`. Same for `MomentsService.getCount()`.
- **`gapDays` silently loses early returns** for the same reason.
- **Nothing warns.** The trim is unlogged and unsurfaced.

### 1b. `habit_done_{habitId}_{date}` — thin, but permanent

**Confirmed: never deleted.** I grepped every `prefs.remove` and `.clear()` call in `lib/`. Exactly
three things touch these keys:

| site | what it does |
|---|---|
| [`main.dart:731`](lib/main.dart:731) `prefs.clear()` | first-run only, gated on `first_run` |
| [`onboarding_state.dart:1210-1215`](lib/onboarding_v2/onboarding_state.dart:1210) | rename **migration** — writes the new key, removes the old. History is moved, not lost |
| [`backup_service.dart`](lib/services/backup_service.dart:56) | backs them up (not in `_excludedKeys`); restore rewrites them |

There is **no age-based pruning, no cap, and no cleanup on set-aside or delete**. `reset()`
([`onboarding_state.dart:1256-1282`](lib/onboarding_v2/onboarding_state.dart:1256)) clears eighteen
keys and not one `habit_done_*`.

**What that means for long-range history:** this is your only complete record. A user three years in
still has every completion day for every habit they have ever had, including habits long since set
aside. Volume is trivial — 6 habits × 365 days = ~2,200 booleans a year.

**But it is a much poorer record**, and four caveats bite this feature specifically:

- **Boolean only.** No mood, no hour, no focus area, no `source`. Frequency and nothing else.
- **The day key uses the device's current zone at write time** —
  `date.toIso8601String().substring(0, 10)` on `DateTime.now()`
  ([`main.dart:591-593`](lib/main.dart:591)). This is the one store that does *not* follow the
  recorded-offset rule. A user who flies east and completes at 01:00 books the completion on the
  wrong local day, and it is unrecoverable — there is no offset stored to correct it.
- ~~**The two stores disagree.**~~ **Fixed, forward-dated.** The "log yesterday" path used to
  record a Moment and never call `HabitTracker.markDone`, so every retro-logged completion sat in
  `moments_collection` and was absent from `habit_done_*`. It now writes both, keyed to *yesterday*
  rather than today ([`main.dart:3093-3097`](lib/main.dart:3093)) — `markDone` grew an optional
  date for it ([`:607`](lib/main.dart:607)). The widget sync already wrote both
  ([`widget_completion_service.dart:58-75`](lib/services/widget_completion_service.dart:58)), as did
  the two live paths.

  **The residual, which matters to any rule counting from `habit_done_*`:** completions
  retro-logged *before* that commit are still missing their key. They are reconstructible in
  principle — the Moment carries the day — but nothing does it, so a user who used "log yesterday"
  in the past has months that read low. Every such error is in the conservative direction: a rule
  with a floor under-fires rather than over-fires.
- **The id is a slug, and slugs can collide.** `habitId` lowercases and collapses non-alphanumerics
  ([`main.dart:583-589`](lib/main.dart:583)), so "Walk 10 min" and "Walk-10-min" share a key.
  `addCustomHabit` rejects case-insensitive duplicates
  ([`onboarding_state.dart:1107-1109`](lib/onboarding_v2/onboarding_state.dart:1107)) but not
  slug-collisions. Rare, but it silently merges two habits' histories.

---

## 2. WHAT CAN BE COMPUTED PER HABIT

| # | question | verdict | from what |
|---|---|---|---|
| a | total completions since adoption | **Partial** | `habit_done_*` now agrees with the moments store going forward, but still misses retro-logs made before the fix; moments are capped at 1000; and "since adoption" has no reliable start date (§3) |
| b | completions in last 30 / 60 / 90 days | **Yes, today** | either store; 90 days at 6/day = 540 moments, inside the cap for every user |
| c | longest run of consecutive **offered** days completed | **No** | offered-day history does not exist |
| d | rate rising / flat / falling | **Yes, today** — with a product caveat | two-window comparison over either store |

### 2a. Total completions since adoption — partial

Counting is trivial: scan `prefs.getKeys()` once for `habit_done_{id}_` prefixes, as
[`main.dart:613-628`](lib/main.dart:613) already does per-date, or group `moments` by `habitName` as
[`milestone_service.dart:52-56`](lib/services/milestone_service.dart:52) already does.

What's missing is the **"since adoption"** part, and it is §3's problem, not a counting problem. The
`habit_done_` keys carry their own dates, so you can take the earliest key as a proxy for adoption —
but that is *first completion*, not adoption, and a habit adopted and ignored for three weeks reads
as three weeks younger than it is.

Also missing: **there is no all-time total anywhere in the app.** `MilestoneService.topHabitCount` is
the closest, and it is capped (§1a) and computed only for the single argmax habit.

### 2b. Completions in the last 30 / 60 / 90 days — yes

Fully available from either store today, and 90 days sits comfortably inside the moments cap even at
maximum activity. Use `Moment.localDay` ([`moment.dart:72-76`](lib/models/moment.dart:72)) for
bucketing — never `.toLocal()`. `Drift.read` already demonstrates the correct pattern of rebuilding
one comparison space from each moment's own offset
([`drift.dart:67-74`](lib/models/drift.dart:67)).

If you go via `habit_done_*` instead, note the zone caveat in §1b: the two stores will put a small
number of completions on different days.

### 2c. Longest run of consecutive offered days — no, and this is the hard one

"Offered" means *was on the screen that day*. Three separate things determine it, and **none of them
is recorded historically.**

**(i) The weekday mask has no history.** `_customHabitDays` holds only the *current* mask
([`onboarding_state.dart:27`](lib/onboarding_v2/onboarding_state.dart:27)), and
`custom_habit_days_changed_at` holds only the *last* change instant
([`onboarding_state.dart:35-36`](lib/onboarding_v2/onboarding_state.dart:35)). A user who ran
Mon/Wed/Fri for two months and switched to daily last week leaves nothing behind that says the first
two months were Mon/Wed/Fri. You can compute offered days back to the last change and no further.

**(ii) `habitsForToday` has an unrecorded fallback.** When a mask would empty the screen, it returns
the *full* visible list instead ([`onboarding_state.dart:119-122`](lib/onboarding_v2/onboarding_state.dart:119)):

```
// A day must never have zero cards.
return todays.isEmpty ? visible : todays;
```

So on those days a masked-off habit **was** offered. Whether that fallback fired on any past day
depends on the full mask set that day, which (i) says you cannot reconstruct.

**(iii) Membership history does not exist.** `visibleHabits()` answers only "is this habit mine
*now*". A habit set aside in March and re-adopted in June has a three-month hole in its offered days
that no store records — and §3 shows even the re-adoption date is only the latest one.

**The one piece that already exists and is worth reusing:**
`StaleAction.cutoffFor` ([`stale_action_nudge.dart:53-70`](lib/widgets/stale_action_nudge.dart:53))
already walks backwards over calendar dates counting *offered* days against a mask, and does it
DST-safely by stepping dates rather than subtracting durations. It is the exact primitive this
feature needs — it just applies the *current* mask to the whole window, which is fine for a 10-day
question and wrong for a 90-day one.

**The honest fallback:** for a seeded habit or an unmasked custom, offered days *are* calendar days,
and the longest run is computable from `habit_done_*` alone. That covers most of the list. For a
masked custom you would either refuse to render, or limit the window to
`custom_habit_days_changed_at`.

### 2d. Rising / flat / falling — yes, with a product caveat

Comparing two adjacent windows (last 30 vs. the 30 before) is available today from either store, and
`Drift.read` already does exactly this shape against a 4-week rolling average
([`drift.dart:81-94`](lib/models/drift.dart:81)) — per *user*, not per habit, but the arithmetic
transfers unchanged.

**The caveat is a product rule, not a data gap.** A *rate* needs a denominator, and `CLAUDE.md` says
"No streaks, no scores, no denominators — `7 of 12 days` is a target wearing a fact's clothes."
A trend expressed as counts ("14 times last month, 15 the month before") stays on the right side of
that line; the same trend expressed as "88% adherence, down from 94%" does not. **This is worth
deciding before building, because the two need identical data and produce opposite-feeling screens.**

---

## 3. `adoptedAt`

**Where:** `habit_adopted_at`, a SharedPreferences `String` holding JSON `{title: ISO-8601 UTC}`
([`onboarding_state.dart:40-41`](lib/onboarding_v2/onboarding_state.dart:40)). Exposed read-only as
`habitAdoptedAt` ([`:210-211`](lib/onboarding_v2/onboarding_state.dart:210)).

**Set for both seeded and custom?** **Yes.** Every add path calls `_recordAdopted`:

| path | line |
|---|---|
| `generateUserHabits` (onboarding, refresh, focus-area change) | [`:544`](lib/onboarding_v2/onboarding_state.dart:544) |
| `addHabitFromBrowse` | [`:569`](lib/onboarding_v2/onboarding_state.dart:569) |
| `addHabitsFromPack` | [`:607`](lib/onboarding_v2/onboarding_state.dart:607) |
| `addCustomHabit` | [`:1113`](lib/onboarding_v2/onboarding_state.dart:1113) |

**One gap:** it is **absent for anyone who adopted before this record existed**, and deliberately so
— `loadUserHabits` does not backfill, and the comment says why
([`:702-706`](lib/onboarding_v2/onboarding_state.dart:702)): stamping them now would silence a
staleness nudge those users were already seeing. For this feature, those users have no adoption date
at all.

### Does it survive?

| event | survives? | why |
|---|---|---|
| **Rename** | **Yes** | Explicitly migrated: `_habitAdoptedAt.remove(oldTitle)` → `[newTitle]` ([`:1190-1192`](lib/onboarding_v2/onboarding_state.dart:1190)), with the comment "rewording an action is not adopting a new one" |
| **Refresh that keeps the habit** | **Yes** | `_recordAdopted` uses `putIfAbsent`, not assignment ([`:218-223`](lib/onboarding_v2/onboarding_state.dart:218)) — a redraw does not restart the clock |
| **Refresh that drops the habit** | **No — lost permanently** | see below |
| **Focus-area change** | **No, for habits in the dropped area** | `changeFocusAreas` calls `generateUserHabits` ([`:1050`](lib/onboarding_v2/onboarding_state.dart:1050)), so it inherits the same prune |
| **Set aside → re-adopt** | **No — resets to the re-adoption date** | same prune, via `setAsideHabits` ([`:591`](lib/onboarding_v2/onboarding_state.dart:591)) |

**The prune** is in `_saveHabitAdoptions`
([`:231-241`](lib/onboarding_v2/onboarding_state.dart:231)):

```
_habitAdoptedAt.removeWhere((title, _) => !userHabits.contains(title));
```

Its own comment states the intent plainly: *"an action set aside and taken up again months later is
a new adoption, and gets its fair chance over again."*

**That intent is correct for `StaleAction` and wrong for this feature.** `habit_adopted_at` means
*"when this most recently joined Today"*. A user who has done "Drink water" every day for eight
months, whose focus areas shifted in June and shifted back in July, reads as adopted **six weeks
ago** — while their `habit_done_*` keys still hold all eight months. A feature that offers the slot
back on the strength of long consistency would refuse to fire for exactly the user it is for.

Do **not** fix this by removing the prune. `StaleAction.isStale` depends on the current semantics
([`stale_action_nudge.dart:116`](lib/widgets/stale_action_nudge.dart:116)) — changing them silently
changes which users get the "this may not fit" card.

---

## 4. WHAT ALREADY COMPUTES SOMETHING LIKE THIS

| | computes | window | per-habit? | answers "automatic"? |
|---|---|---|---|---|
| **Lift** | glad-share ranking | all moments; matures at 56 days of *rated* history | yes | **No** |
| **Drift** | this week vs. 4-week average | 5 weeks | **no** | **No** |
| **MonthPlan._keepAnchor** | highest-count habit | **one month** | yes | **No — closest in spirit, far off in scale** |
| **MilestoneService** | all-time argmax habit | all moments (capped) | one habit only | **No** |
| **StaleAction** | the *inverse* — has it gone quiet | 10 **offered** days | yes | **No, but owns the right primitive** |

### Lift — [`lift.dart:82-129`](lib/models/lift.dart:82)

Counts, per active habit, moments marked `gladIDid` over moments carrying any mood, and ranks by the
ratio. Gates at `minSpanDays = 56` from the earliest rated moment and `minRatedMature = 6` ratings
per habit.

**Why it can't answer this:** it measures how a habit *lands*, not how often it happens. Its
denominator is rated moments only — unrated ones are excluded by design
([`lift.dart:88`](lib/models/lift.dart:88)). A habit done daily for a year and never mood-tapped is
invisible to Lift entirely. If anything the relationship runs the wrong way: an action that has
become automatic is one the user is likely to stop annotating.

### Drift — [`drift.dart:44-119`](lib/models/drift.dart:44)

This week's **total** moment count against a 4-week rolling average, firing below `_threshold = 0.5`.

**Why it can't answer this:** it has no habit dimension at all. `countBetween` filters by date only
([`drift.dart:76-80`](lib/models/drift.dart:76)); `habitName` is never read. It is an aggregate about
the user, and per-habit is not a small change to it — it is a different function that happens to
share the two-window arithmetic.

### MonthPlan._keepAnchor — [`month_plan.dart:293-315`](lib/models/month_plan.dart:293)

Ranks active habits by count in **last calendar month**, and proposes pinning the top one. Fires only
when: nothing is pinned already, at least two habits have counts, the top has
`_minAnchorCount = 3` or more, and there is **no tie** at the top. Fixed low confidence,
`_keepAnchorConfidence = 0.2` ([`:349`](lib/models/month_plan.dart:349)). The whole plan is gated at
`minMoments = 10` for the month ([`:122`](lib/models/month_plan.dart:122)).

**Why it can't answer this:** the bar is **three completions in a month**, and the window is one
month. That is "the action that carried this month", not "this has become automatic". There is no
comparison to any earlier month — `MonthPlan.read` receives only `lastMonth`
([`insights_screen.dart:1465-1467`](lib/screens/insights_screen.dart:1465)), so nothing longitudinal
is even in scope.

**Worth flagging as a product collision, not a data one:** `_setAside`
([`month_plan.dart:245-284`](lib/models/month_plan.dart:245)) already proposes removing a habit —
because the count was *low*. Your feature proposes removing a habit because the count was *high*.
Both end in the same button taking a card off the screen. Under the "one decision per month" rule the
plan shows one nudge under YOUR ACTIONS, so they compete for the same slot, and a user who sees
"set aside X — you only reached for it twice" one month and "give back Y's slot — you always do it"
the next has been told the same thing twice for opposite reasons. `_setAside` excludes customs
([`:256-257`](lib/models/month_plan.dart:256)); `_keepAnchor` does not.

### MilestoneService — [`milestone_service.dart:38-83`](lib/services/milestone_service.dart:38)

`topHabitName` + `topHabitCount` (all-time argmax over `MomentsService.getAll()`), `topArea`, and
`weekCount` from `AppUsageService`. Cached per session, invalidated on completion.

**Why it can't answer this:** it is a single all-time argmax with no time dimension. `topHabitCount`
is a lifetime total truncated by the 1000 cap (§1a), so for a long-running user it is not even a
correct lifetime total. Nothing here distinguishes 200 completions spread evenly over a year from 200
crammed into two months.

### StaleAction — [`stale_action_nudge.dart:33-160`](lib/widgets/stale_action_nudge.dart:33)

The mirror image of your feature: it notices an action that has been on the screen `afterDays = 10`
offered days without being reached for, and offers to take it away.

**It owns the primitive you need.** `cutoffFor(now, days)`
([`:53-70`](lib/widgets/stale_action_nudge.dart:53)) walks back over calendar dates counting only
days the mask offers, DST-safely. It also already threads `adoptedAt` as a fair-chance guard
([`:116`](lib/widgets/stale_action_nudge.dart:116)) and takes masks per-habit through `primary`
([`:144`](lib/widgets/stale_action_nudge.dart:144)). It is a pure static with no `BuildContext` — the
shape any new rule here should copy.

---

## 5. VERDICT

**Roughly two-thirds scheduling/logic on existing data, one-third new data modelling.** The split is
clean and falls on the word "long".

### What you can build today, with no new storage

A rule of the form *"completed on at least N of the last 60 days, and the last 30 look like the 30
before"* is fully computable now, for every habit, seeded or custom, from either store. `Drift`
supplies the two-window arithmetic, `StaleAction.cutoffFor` supplies the offered-day walk, and 60–90
days sits inside the moments cap for every user at every activity level. Lally's ~66-day median for
automaticity — the finding `MomentRollup.gapThresholdDays` already cites
([`moment_rollup.dart:11-16`](lib/models/moment_rollup.dart:11)) — lands comfortably inside that
window, which is the useful coincidence here.

### What needs new data, named exactly

| # | what's missing | new storage | notes |
|---|---|---|---|
| 1 | a first-adoption date that survives set-aside and focus-area changes | **`habit_first_adopted_at`** — a second JSON map, written by `_recordAdopted` with `putIfAbsent` and **never pruned** | Add a key; do **not** un-prune `habit_adopted_at`. `StaleAction` depends on its current "most recently joined" meaning ([`stale_action_nudge.dart:116`](lib/widgets/stale_action_nudge.dart:116)) |
| 2 | offered-day history for masked customs | **`custom_habit_days_history`** — `[{days, from}]` replacing the single `custom_habit_days_changed_at` instant | Only needed if you want masked customs eligible. Skipping them costs you nothing for seeded habits, where offered days = calendar days |
| 3 | membership history (was this habit on the list in March?) | **`habit_adoption_log`** — append-only `[{title, event, at}]` | The only exact fix for a set-aside/re-adopt gap. #1 gets you 90% of the value for 10% of the work; add this only if the feature must reason past a gap rather than merely survive one |
| 4 | agreement between the two stores | **no new key — a one-line fix** | [`main.dart:3089`](lib/main.dart:3089) records a Moment without `HabitTracker.markDone`. Either add the call, or commit to `moments_collection` as the sole source and accept the 1000 cap |

**Not recommended: a per-day offered snapshot** (`habit_offered_{id}_{date}`). It would make offered
days exact, including the `habitsForToday` empty-fallback at
[`onboarding_state.dart:119-122`](lib/onboarding_v2/onboarding_state.dart:119), but it doubles the
key volume, needs a daily write with no natural trigger, and is worthless retroactively — it starts
knowing nothing about the users who already qualify.

### The one decision to make before building

**Which store is the source of truth**, because they disagree and each is incomplete in a different
direction: `moments_collection` is rich and capped at ~5–9 months for an active user;
`habit_done_*` is permanent and boolean, misses retro-logs made before the fix above, and books
days by the device's current zone. A rule reading one and copy re-stating the other will eventually print a number the
user can disprove — which is precisely the failure `CLAUDE.md`'s "never state a finding you haven't
computed" exists to prevent.

**My read:** `habit_done_*` for the long-range consistency test, since permanence is the whole point
of the feature; `moments_collection` for anything needing mood, hour or focus area. And fix #4 first
regardless — one line, and it stops the two stores from drifting further apart.

---

*Audit only. 0 files modified. Read: `moments_service.dart`, `moment.dart`, `moment_rollup.dart`,
`lift.dart`, `drift.dart`, `month_plan.dart`, `season.dart`, `milestone_service.dart`,
`week_stats_service.dart`, `backup_service.dart`, `widget_completion_service.dart`,
`stale_action_nudge.dart`, `onboarding_state.dart`, `insights_screen.dart`, `main.dart`.*
