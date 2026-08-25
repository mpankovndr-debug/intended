# Giving the slot back — design

*Design only: 0 files changed. Builds on the feasibility audit in
[`completion-timestamps.md`](audit/completion-timestamps.md); every claim below names the file and
line it was checked against on this branch.*

**The feature:** notice when an action has been steady so long it looks like the user's own, and
offer the slot back — "This looks like it's yours now — keep it, or make room for something else?"

**The shape of the answer:** one mechanism, not two. This and `_setAside` are the two branches of
one question — *is this slot still doing something for you?* — so the design is a new
`NudgeKind` inside the existing plan, sharing `_setAside`'s ranking, its accept path, its decline
machinery and its tier. Detection reads `habit_done_*` counts over three closed calendar months and
fires only when the list is at its six-slot ceiling. **No new storage is strictly required** — but
one store (membership spans) should start recording now regardless, because it belongs to the class
of record that can never be backfilled.

---

## 1. NEW STORAGE

The prior audit named three missing stores. Verdicts first, specs after:

| store | verdict |
|---|---|
| `habit_first_adopted_at` | **Not required.** The rule's counts prove tenure by themselves, and it is a projection of the membership store — build one of the two, not both |
| mask change history | **Not required for v1** — candidates are seeded actions, and seeded actions are never masked. Required only if customs become eligible |
| membership history | **Not required by the rule, but start it now.** The only record here that is worthless unless it began recording before it was needed |

### 1a. `habit_first_adopted_at`

**Spec, if built:** a second JSON map `{title: ISO-8601 UTC}` beside `habit_adopted_at`, written by
`_recordAdopted` with the same `putIfAbsent`
([`onboarding_state.dart:218-223`](lib/onboarding_v2/onboarding_state.dart:218)) but persisted by
its own save that **never** runs the `removeWhere` prune
([`:232`](lib/onboarding_v2/onboarding_state.dart:232)). Write sites are `_recordAdopted`'s four
callers: `generateUserHabits` ([`:569`](lib/onboarding_v2/onboarding_state.dart:569)),
`addHabitFromBrowse` ([`:594`](lib/onboarding_v2/onboarding_state.dart:594)), `addHabitsFromPack`
([`:632`](lib/onboarding_v2/onboarding_state.dart:632)), `addCustomHabit`
([`:1138`](lib/onboarding_v2/onboarding_state.dart:1138)). Rename migrates the entry exactly as
`habit_adopted_at` does ([`:1215-1218`](lib/onboarding_v2/onboarding_state.dart:1215)).
`habit_adopted_at` itself stays untouched — `StaleAction.isStale` depends on its
"most recently joined" meaning ([`stale_action_nudge.dart:116`](lib/widgets/stale_action_nudge.dart:116)).

**Why it is not required.** The rule below demands ≥ 12 completion-days in each of three closed
months. A completion-day requires the card to have been on Today that day — an action off the list
has no card to complete (the one sliver: a stale widget, §1c). So the qualifying counts *are* the
proof of tenure; a separate adoption date adds nothing the rule uses. The only thing it buys is the
sentence "you've held this since May" — optional copy that could never render for pre-record users
anyway, since the app deliberately refuses to backfill adoption dates
([`onboarding_state.dart:702-706`](lib/onboarding_v2/onboarding_state.dart:702), per the audit).
The proposed copy (§3) speaks only counts, so nothing is lost. If the membership store below is
rejected as too much, this map is the 10%-cost fallback the audit priced it as.

### 1b. Mask change history

**Spec, if built:** `custom_habit_days_history`, a JSON list `[{days: [1..7], from: ISO}]`,
appended by `setCustomHabitDays` — the single site that stamps `customHabitDaysChangedAtKey`
([`onboarding_state.dart:125-134`](lib/onboarding_v2/onboarding_state.dart:125)) — and migrated on
rename without re-stamping, matching [`:1204-1210`](lib/onboarding_v2/onboarding_state.dart:1204).

**Why the feature doesn't need it.** v1 candidates are seeded actions only (§2, mirroring
`_setAside`'s exclusion), and *"Seeded actions are never keyed — only customs can carry a mask"*
([`onboarding_state.dart:26`](lib/onboarding_v2/onboarding_state.dart:26)). For every candidate,
offered days are calendar days, and a monthly floor of 12 is well-defined with no mask history at
all. The store becomes required exactly when customs become eligible: a Mon/Wed/Fri custom peaks
near 13 days a month, so its honest floor depends on how many offered days that month held — which
only the mask's history can answer for a past month. Build it then, not now; the audit already
established that skipping masked customs costs nothing today.

### 1c. Membership history — start this one now

**Spec:** `habit_membership_spans`, JSON `{title: [[fromDay, toDay|null], …]}` — wall-clock days in
`PlanService._wallToday`'s shape ([`plan_service.dart:234-237`](lib/services/plan_service.dart:234)).
A join opens a span (if none is open); a leave closes it; a span opened and closed the same day is
dropped, so refresh churn erases itself. Spans rather than an append-only event list because the
consumer question is "was this held continuously across the window" — and because spans stay
bounded where a raw event log of `generateUserHabits` churn (up to 3 refreshes a day
[`:188`](lib/onboarding_v2/onboarding_state.dart:188), each able to swap four seeded actions)
would not. Event *kinds* (set aside vs graduated vs deleted) are deliberately not stored here —
`AcceptedNudge` already records the why for plan-driven removals
([`plan_service.dart:14-58`](lib/services/plan_service.dart:14)); this store records only the when.

**Write sites, verified complete:**

| event | site |
|---|---|
| join | the four `_recordAdopted` callers (§1a) |
| leave | `setAsideHabits` ([`:604-618`](lib/onboarding_v2/onboarding_state.dart:604)) — which also covers the plan's accept ([`insights_screen.dart:1751`](lib/screens/insights_screen.dart:1751)), the pack swap sheet ([`main.dart:6559`](lib/main.dart:6559)), and pack/path adoption ([`change_path_screen.dart:89`](lib/features/profile/change_path_screen.dart:89)) |
| leave | `removeCustomHabit` ([`:1160-1182`](lib/onboarding_v2/onboarding_state.dart:1160)) |
| leave | the implicit drops inside `generateUserHabits` — the `previous` set diff at [`:564-567`](lib/onboarding_v2/onboarding_state.dart:564), the same place the audit showed `adoptedAt` being silently pruned on refresh and focus-area change |
| rename | migrate the title in place, like [`:1215`](lib/onboarding_v2/onboarding_state.dart:1215) — rewording is not leaving |

Backup includes it automatically — `_excludedKeys` holds only four entries
([`backup_service.dart:20-26`](lib/services/backup_service.dart:20)) — and the first-run
`prefs.clear()` wipes it, which is correct.

**Why now, when the rule survives without it.** Degraded detection (no spans) has exactly one blind
spot: a habit removed and re-adopted *inside* the window whose months still each hold ≥ 12
completion-days. That is nearly impossible — off Today means no card — except through one crack:
the widget keeps serving a removed habit until the next payload sync, and the widget sync path
writes completions with **no membership check**
([`widget_completion_service.dart:50-88`](lib/services/widget_completion_service.dart:50)). So the
feature ships fine without spans. The reason to start the store anyway is the `localHour` lesson:
*stored, not derived — these cannot be backfilled*. Membership history is unreconstructible the day
after it was needed, it retroactively repairs the audit's §3 wound ("adoption date lost on every
focus-area change") for every future feature, and it costs a handful of small writes at sites that
already persist state. Every month it doesn't exist is a month of history gone for good.

**The counting store is `habit_done_*`, and it just became trustworthy.** This branch fixed the
audit's #4: the retro-log path now writes both stores
([`main.dart:3093-3097`](lib/main.dart:3093) — *"Both stores, as a live completion writes both"*).
Going forward the permanent store and the moments store agree; the remaining caveats (day keys in
the device's current zone, slug collisions — audit §1b) move a count by at most one at a month
boundary, which the rule's band (§2) absorbs. The 1000-moment cap is irrelevant here:
`habit_done_*` has no cap, so the ≤ 90-day constraint on *moments*-based windows doesn't bind this
feature at all.

---

## 2. THE DETECTION RULE

A new pure static in its own file — `SettledAction` in `lib/models/settled_action.dart`, shaped
like `StaleAction`: no `BuildContext`, all inputs passed in, fully testable. The prefs key-scan
that feeds it (grouping `habit_done_{id}_{yyyy-MM-dd}` keys into per-habit month counts) lives in a
small service file — `HabitTracker` cannot grow this, because it lives in `main.dart`.

**A seeded action is *settled* when all of these hold:**

1. Each of the **last three closed calendar months** holds **≥ 12 days** with a completion.
2. The three monthly counts sit within a **band of 5** (max − min ≤ 5).
3. The list is at its ceiling: `userHabits.length == maxActiveHabits` (6,
   [`onboarding_state.dart:58`](lib/onboarding_v2/onboarding_state.dart:58)).
4. It is not the pinned habit.
5. It is not a custom (v1 — §3 and §5 give the reason).
6. No give-back offer for this habit was declined in the last three plan months — readable from the
   existing `plan_declined_nudges` per-month maps
   ([`plan_service.dart:88, 209-221`](lib/services/plan_service.dart:209)); no new storage.
7. Removing it leaves at least 2 actions — `_setAside`'s own guard, reused
   ([`month_plan.dart:260, 346`](lib/models/month_plan.dart:260)).
8. With spans (§1c): continuously held across the whole window.

When several qualify: highest three-month total, tie broken by `visibleHabits` order — an explicit
stable tiebreak, because Dart's sort is not, and `_setAside` already had to learn this
([`month_plan.dart:264`](lib/models/month_plan.dart:264)).

### Defending each number

**Three closed months.** Lally's ~66-day median for automaticity — the finding
`MomentRollup.gapThresholdDays` already cites ([`moment_rollup.dart:11-16`](lib/models/moment_rollup.dart:11))
— means two months straddles the median: half of habits aren't automatic yet at day 60. Three
closed months clears it with margin for the fast half and reaches it for the slow. It also keeps
the hierarchy of claims honest: Lift needs 56 days of history merely to *rank* actions (audit §4);
a claim that ends in removing an action's support must not be cheaper than the claim that sorts
them. Calendar months rather than rolling windows, because the month is this app's unit — seasons
close on it, the letter reads it — and because a calendar month is the only window the copy can
honestly name: "15 times in July" is checkable; "15 in the 30 days before the 12th" is not a
sentence. Closed months only: the month being lived can't testify yet.

**≥ 12 days a month.** Twelve is already this codebase's own bar for "a month with enough signal to
mean something" — `_minMonthForSetAside = 12`
([`month_plan.dart:344`](lib/models/month_plan.dart:344)). Reused deliberately at habit scale: 12
days in any month is at least roughly three returns a week, every week — a rhythm woven into life,
not an occasional visit. And it is deliberately far below daily: demanding 25+ would be a
perfection bar, which is a streak wearing a threshold's clothes. Note what is *not* computed: 12 is
a floor on a count, never a numerator. The month's length is not consulted, "12 of 30" exists
nowhere, and neither do rate-shaped names — the inputs are `monthCounts`, the band is `countBand`.

**Band of 5.** The threshold is set by the sentence (the CLAUDE.md rule): the card says *you've
reached for it about as often, three months running*, so the months must be about as often. The
band is an absolute count difference — the only trend arithmetic the hard rule permits. Five
absorbs what noise it must — the calendar's own jitter is 3 (28-day February against a 31-day
neighbour), plus a sick weekend — and blocks what it must block: a steep climb (8 → 15 → 22) is a
habit *taking hold*, and pulling the support out mid-climb is the worst possible moment; a slide
(22 → 15 → 12) is a habit fading toward the other branch's territory, where "it's yours now" would
be a compliment wearing a mistake.

**At the ceiling.** "Make room for something else" is only a true sentence when there is no room.
At 4 of 6 the second clause is false — there is room — and a card must not speak a clause its data
contradicts (*never state a finding you haven't computed*). Below the cap the honest offer
degenerates to "want the app to stop holding this?", whose benefit the app cannot name: the slot
returns to nothing. The ceiling condition also makes the offer structurally rare — which is right
for the largest thing the plan will ever propose.

**Not pinned.** Pinning is the user's own declaration that this slot is load-bearing
([`insights_screen.dart:1753`](lib/screens/insights_screen.dart:1753)). It also dissolves a
contradiction: `_keepAnchor` proposes pinning the highest-count action
([`month_plan.dart:293-315`](lib/models/month_plan.dart:293)) — very possibly the settled one — and
the plan must never be able to propose pinning X one month and releasing X the next (§3 finishes
this argument).

**Cooldown of three months, not the per-month decline.** For `_setAside` the per-month decline
([`plan_service.dart:131-140`](lib/services/plan_service.dart:131)) suffices because next month's
evidence is new. Settled evidence barely moves month to month — steady is steady — so the same
machinery would re-ask every month, and a monthly "are you sure it's not yours?" is a nag wearing a
compliment. Declining "it's yours now" means *keep holding it for me*; that deserves a season of
quiet.

**What needs no clause.** A rescue-grade silence anywhere in the window drags that month under 12
and the floor disqualifies by itself. Likewise membership in degraded mode: 12 completion-days in a
month require the card to have been there. The rule self-guards against both.

**What the rule is not measuring.** Steadiness of return — which is all the counts can testify to —
is not automaticity, the psychological state. The copy must therefore claim only the computed thing
("about as often, three months running") plus a hedged reading ("*looks like* it's yours now"), and
§6 presses hard on whether even that is honest enough.

---

## 3. ONE MECHANISM WITH `_setAside`

Two branches of one question — *is this slot still doing something for you?* `_setAside`: the slot
holds an action you don't reach for. Give-back: the slot holds an action that no longer needs
holding. Designed as one mechanism:

**A fifth `NudgeKind` — `giveBack` — in the actions group.** It slots into the existing enum
([`month_plan.dart:13-41`](lib/models/month_plan.dart:13)), placed after `setAside` so the declared-
order tiebreak ([`:154-159`](lib/models/month_plan.dart:154)) stays meaningful. Storage is safe:
kinds persist by `name`, and a record whose kind an older build doesn't know is dropped rather than
guessed at ([`plan_service.dart:46-50`](lib/services/plan_service.dart:46)). One model change:
`PlanNudge` carries a single `count`, and this card quotes three — it needs an optional
`monthCounts: List<int>` (the copy's evidence, in the nudge, per the class's own rule that a nudge
carries the evidence that produced it).

**Detection feeds the plan; the plan stays the only ranker.** `MonthPlan.read` receives only last
month's moments ([`insights_screen.dart:1465-1475`](lib/screens/insights_screen.dart:1465)), and
the settled rule needs three months of `habit_done_*` — a different source. So `SettledAction.read`
runs beside it (computed in the insights load, like drift's `maskChangedAt` is), and its candidate
is handed to `MonthPlan.read` as a parameter, the way `hasPinnedHabit` already is. `MonthPlan`
remains the single place "one decision per month" is enforced: `topAction` still picks exactly one
actions-group nudge ([`month_plan.dart:107-119`](lib/models/month_plan.dart:107)), an accepted
month still shows `planDone` and stops proposing
([`insights_screen.dart:1516-1522`](lib/screens/insights_screen.dart:1516)).

**Which branch wins: `_setAside`, by ranking, and here is why.** Confidence encodes the priority in
the machinery that already exists:

| nudge | confidence |
|---|---|
| `setAside` | 0.25 – 1.0 (existing: [`month_plan.dart:279-281`](lib/models/month_plan.dart:279)) |
| `giveBack` | **fixed 0.22** — a constant, not a computed share; nothing rate-shaped enters this feature even internally |
| `keepAnchor` | 0.2 (existing: [`:349`](lib/models/month_plan.dart:349)) |

The same habit can never qualify for both branches — ≤ 3 moments and ≥ 12 completion-days in
overlapping windows are disjoint now that both stores are written together (§1c). But two
*different* habits can, and then set-aside speaks first, for three reasons. First, error asymmetry:
a wrong set-aside removes something unused — near-zero cost, and it returns to the browse pool; a
wrong give-back removes the scaffolding under the user's strongest practice. When unsure which
conversation to open, open the one that is cheap if wrong. Second, cost of waiting: the fading
habit costs the user every day it sits there — a card asking and not being answered; the settled
habit costs nothing to leave another month, and waiting only strengthens its own evidence. Third,
at the ceiling — the only place give-back fires — freeing the *least alive* slot is strictly the
better trade for whatever wants in. The counter — that a user with one perpetually-fading habit
never sees the rarer, kinder offer — is answered by the machinery itself: a set-aside accepted
frees the ceiling condition (give-back stops firing, correctly: room now exists), and a set-aside
declined is silenced for that month ([`month_plan.dart:149`](lib/models/month_plan.dart:149)),
letting give-back surface.

And `giveBack` above `keepAnchor` closes the contradiction the audit flagged: when the settled
habit is also the month's highest-count habit, the plan will show "make room" and never "pin it" —
one voice. The reverse order would propose anchoring an action the app believes is finished with
its slot. If the user declines the give-back, a later pin proposal is coherent — they just said it
still belongs.

**Same button, same door.** Accepting calls `onboarding.setAsideHabits([habit])` — the identical
write `_setAside`'s accept already uses
([`insights_screen.dart:1750-1751`](lib/screens/insights_screen.dart:1750)), with the identical
"returns to the browse pool" semantics, recorded through `PlanService.accept` like every other
change. Declining uses the existing decline plus the three-month cooldown read (§2.6). No new
state machine, no new removal semantics, no second place where removal happens.

**Where it surfaces.** The plan card, YOUR ACTIONS — the paid branch of the insights page
([`insights_screen.dart:300-310`](lib/screens/insights_screen.dart:300)). And, unchanged by any of
this, the free teaser: it already renders the top nudge's real sentence with the second dissolving
([`insights_screen.dart:972-1008`](lib/screens/insights_screen.dart:972)), so in a month where
give-back ranks top, a free user reads the finding and the decision stays behind the tier. That is
the teaser doing precisely its job — one real suggestion, computed from their own month.

**The family, so nothing overlaps.** `StaleAction` (free, home screen, 10 offered days, offers a
*different intention* — [`stale_action_nudge.dart:33`](lib/widgets/stale_action_nudge.dart:33)),
`setAside` (paid, plan, one month of quiet, offers the pool), `giveBack` (paid, plan, a season of
steadiness, offers the slot). Days, a month, a season — three tempos, one question, no two of them
able to speak about the same habit in the same month: a stale habit has ≤ 0 moments in 10 days and
cannot hold 12-day months; the count gates make the other pair disjoint.

**Proposed copy** (EN shown; RU follows the standing rules — «ты» throughout, real ICU plurals for
«раз/раза», months named in whatever case Russian grammar wants, via per-locale placeholders):

> YOUR ACTIONS
> **Morning walk looks like it's yours now** — 15 times in July, 14 in June, 16 in May. Keep it
> here, or make room for something new?
>
> [ Make room ]  [ Skip ]

Every number the card speaks comes from the same store the rule computed on — the audit's closing
warning about one store's rule re-stated in the other store's numbers is a design input here, not a
footnote.

---

## 4. FREE OR PAID: PAID

**The line itself decides it.** Free says what happened; paid says what to do about it. This card
is maximally "what to do about it": a proposal about next month's list, ending in a button that
writes a real setting — the exact admission test the `NudgeKind` doc states for the paid plan
([`month_plan.dart:3-8`](lib/models/month_plan.dart:3)).

**The precedent binds.** `_setAside` exists only inside the plan, and the plan renders only in the
paid branch ([`insights_screen.dart:300-310`](lib/screens/insights_screen.dart:300)). These are two
branches of one mechanism sharing one slot and one button; splitting the tier between them would
make the boundary incoherent — the app would remove your quiet action for free but release your
strong one for money, or worse the reverse.

**Reactive vs predictive.** Nothing happened to react to. No silence fell, no wall was hit, the
user asked nothing — the app is anticipating a need the user hasn't voiced, from three months of
pattern. That is the predictive side by definition.

**"Never paywall the rescue" is not touched.** The qualifying user has returned three-plus times a
week, every week, for a season — the measurably farthest point from needing rescue this app can
express. Gap detection, the gentle notification, the reduced screen: all free, all untouched by
this design.

**And free keeps every door, which keeps the tier honest.** A free user can set aside any seeded
action by hand in the pack swap sheet ([`main.dart:6553-6559`](lib/main.dart:6553)), replace their
path's actions wholesale ([`change_path_screen.dart:82-94`](lib/features/profile/change_path_screen.dart:82)),
and delete a custom ([`main.dart:4550-4554`](lib/main.dart:4550)). The capability was never paid.
What is paid is the *noticing* — which of six steady-looking cards is actually finished — and the
free teaser still shows that sentence in the months it tops the plan, per §5.3's own design.

---

## 5. WHAT BREAKS

Accepting give-back is `setAsideHabits([X])` for a seeded, unpinned X. Every consumer, checked:

| consumer | what happens | verdict |
|---|---|---|
| `user_habits` / `visibleHabits` | X leaves Today and every reader of the one "active" definition — all-done detection, swap targets, pack completion, rescue pool, the plan's evidence ([`onboarding_state.dart:70-75`](lib/onboarding_v2/onboarding_state.dart:70)) | intended |
| `habit_adopted_at` | X's entry pruned by `_saveHabitAdoptions` ([`:232`](lib/onboarding_v2/onboarding_state.dart:232)); on re-adoption it restamps, so `StaleAction`'s fair-chance guard works again | correct — this is the semantics the audit said not to break, unbroken |
| `habit_done_*` | orphaned, permanent, by design (audit §1b); resumes seamlessly on re-adoption — and it is what lets *this* feature recognise a re-adopted habit again years later | by design |
| `moments_collection` | untouched. X's moments keep rendering everywhere history renders — grid cells, legend, letter ([`letter.dart:231`](lib/models/letter.dart:231) counts by the moment's own `habitName`), milestones — because a moment carries its own name and category ([`moment.dart:32-40`](lib/models/moment.dart:32)) | correct: the month happened |
| Seasons | closed months are immutable and `season_service` appears nowhere in the `visibleHabits`/`userHabits` consumer set (grep) — it reads moments | unaffected |
| `MonthPlan`, later months | X drops out of `activeHabits`: no keep-anchor, no set-aside, no second give-back for it | intended |
| **`PlanProof`** | **the real break.** Proof compares *total* moments in 28-day windows ([`plan_service.dart:113-117, 201-205`](lib/services/plan_service.dart:113)). Releasing a 15-a-month action guarantees "down from" by construction — the card would report the user's success as decline. Give-back must be excluded from `proof()` (silence beats a false measurement). `_setAside` has the same shape today, bounded to ≤ 3 — pre-existing, tolerable. If a measurement is ever wanted, the honest one excludes the released habit's own moments from both windows | must handle in v1 |
| Lift | X's rated moments filtered out on the next read ([`lift.dart:91`](lib/models/lift.dart:91)) — the ranking can shift or the card vanish | acceptable: Lift describes the active list, and now does |
| Pin | can't fire — pinned habits are disqualified (§2.4), so the pin-clear at [`:609`](lib/onboarding_v2/onboarding_state.dart:609) never runs on this path | n/a |
| Widget | the payload rebuilt by `WidgetService.updateWidget` drops X on the next sync; until then the widget still offers X, and the sync path records taps with no membership check ([`widget_completion_service.dart:50-88`](lib/services/widget_completion_service.dart:50)) — a post-release tap still writes a real moment | tolerable — the tap happened; call `updateWidget` in the accept flow to shrink the window to seconds |
| Notifications | the stats path reads prefs key `'habits'`, which nothing in `lib/` writes (grep: no `setStringList('habits'`) — [`notification_scheduler.dart:322`](lib/services/notification_scheduler.dart:322) | unaffected; pre-existing oddity, worth its own look outside this feature |
| Export / backup | export already serialises `acceptedPlanChanges` from `acceptedNudges()` (profile screen), so the new kind appears automatically; backup excludes nothing relevant ([`backup_service.dart:20-26`](lib/services/backup_service.dart:20)) | fine |
| Older builds | an accepted `giveBack` record is dropped on read, not crashed on ([`plan_service.dart:46-50`](lib/services/plan_service.dart:46)) | safe |
| Re-adoption | X sits in the browse pool; `addHabitFromBrowse` restamps adoption; the membership span reopens; the cooldown (a declined-offers read) doesn't block re-adding | intact |

**Customs, and why v1 excludes them.** `_setAside` excludes customs because `setAsideHabits`
refuses to remove them ([`onboarding_state.dart:606`](lib/onboarding_v2/onboarding_state.dart:606))
— a custom has no pool to return to. The only removal for a custom is `removeCustomHabit`
([`:1160-1182`](lib/onboarding_v2/onboarding_state.dart:1160)), which deletes the definition, its
focus-area mapping and its mask (moments and `habit_done_*` survive). Philosophically, "it's yours
now" fits a custom *best* — it is the user's own words, lived. But mechanically the accept would be
a hard delete of those words, behind a button styled as a gift. If customs ever join (v2), the
accept must archive the definition (title + area) rather than delete it, so the record can still
speak — and that is a new storage decision, which is exactly why it is not in v1. Until then the
exclusion also keeps the two branches mechanically identical: one write path, one semantics.

---

## 6. THE CASE AGAINST

The strongest version, argued to win:

**1. It rebuilds this app's worst historical bug and calls it a feature.** The `.take(4)` scar: a
habit still being completed, still recorded, reachable from nowhere — the failure this codebase
documents as its nightmare. Give-back manufactures that exact end state, deliberately, for the
user's *strongest* action, on the strength of one tap made on a card that was praising them.
February's tap is May's "where did my morning walk go?" Consent and a browse-pool road back exist —
but the scar's lesson was that users don't experience storage truths; they experience the screen,
and the screen will have lost the thing they did most.

**2. It removes the evidence the subscription sells.** The paid object is the mirror: the mosaic,
the letter, the archive — *"the month is a mosaic of moments, and the app reads that month back to
you."* Release a 15-a-month action and every future month is fifteen moments paler; the letter
loses its most reliable protagonist (it names the action that carried the month —
[`letter.dart:231-245`](lib/models/letter.dart:231)); the grid thins exactly where the story got
good. The archive keeps who you were; the mirror goes quiet about who you are. A paid feature that
thins the paid surface for the app's most successful users is churn, engineered in-house, and §5's
Lift row shows the same erosion sideways: even the insight cards start losing their material.

**3. The core sentence is an assessment in observation's clothes.** "You come back most often in
the evenings" observes. "This looks like it's yours now" *diagnoses* — an internal state
(automaticity) inferred from external counts. Steadiness is not automaticity: the card, the widget,
the reminder may be the *cause* of the steadiness, and the accept button removes those exact cues.
Habit research is blunt that context and cue removal risk collapse — Lally measures formation, not
what survives amputation of the tracker. The hedge ("looks like") does not rescue it, because the
button acts on the diagnosis; if the habit collapses after release, the app told the user it was
theirs and then took away the thing that made it so. Under this project's own rules that is a
sentence shipped without its finding — at the feature's very heart, not at its edge.

**4. It re-crowns the arc this app deleted.** Graduation is the streak's final form: a finish line,
a diploma, "you made it." This app removed streaks, scores and completion itself — there are only
returns. A release ceremony is achievement psychology re-entering through the softest door, and it
occupies the scarcest channel the app has: one decision per month. Every month the plan spends on
"you're done with this" is a month it didn't propose something with live behavioral value — a
reminder moved to where the moments land, an area adopted that was already being lived.

And the deflating practical note: ceiling-of-six *and* three steady months *and* not pinned *and*
not custom is a thin population. The build — a new kind, a new model, a new store, copy in two
languages, a proof exemption — is real, and most users will never see the card.

**What keeps it alive despite all four.** The cap makes slots real: a user at 6/6 whose walk is
settled genuinely cannot try the next thing unless the app either stays silent or helps choose, and
of the two removal conversations the app can start, this is the only one that frees a slot without
naming a failure. If that user exists and the app says nothing, the alternative they reach for is
the pack-swap sheet — where they'll remove *something* with no evidence at all. But the case
against is strong enough that the burden of proof sits on shipping, not on skipping.

---

## 7. VERDICT

Two separable decisions:

**Start `habit_membership_spans` now, regardless of the feature.** It is the one piece that cannot
be built later (§1c), it repairs a documented wound for every future longitudinal feature, and it
is a day of work with no user-facing surface.

**The card itself is a product call, not a design call, and it hinges on §6.2.** The mechanism
above is sound, cheap once built as `_setAside`'s twin, and honest within the counts-only rule.
Arguments 6.1, 6.3 and 6.4 are answerable by the design (rarity, hedged copy, ranking below
set-aside). Argument 6.2 — that the feature thins the very mirror the subscription sells — is the
one this design cannot answer, only bound. Decide on that one; everything else is ready.

**Open decisions if it ships:** the `monthCounts` field on `PlanNudge`; proof exclusion vs a
remaining-total variant (§5); an immediate `updateWidget` in the accept flow; customs-in-v2 as
archive-not-delete; and whether the give-back acceptance deserves a line in that month's letter —
the one place a farewell to an action could live without being a ceremony.

---

*Design only. 0 files modified. Read on this branch: `month_plan.dart`, `stale_action_nudge.dart`,
`plan_service.dart`, `moment.dart`, `lift.dart`, `letter.dart`, `onboarding_state.dart`,
`insights_screen.dart`, `profile_screen.dart`, `change_path_screen.dart`, `main.dart` (regions),
`widget_completion_service.dart`, `widget_service.dart`, `notification_scheduler.dart`,
`backup_service.dart`, `reflection_service.dart`, plus `audit/completion-timestamps.md`.*
