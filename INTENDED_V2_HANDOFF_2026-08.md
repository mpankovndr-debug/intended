# Intended v2 — Design & Product Handoff

Working brief from a full audit + redesign session (Aug 2026). Everything below is a decision already made, with the reasoning attached so it can be challenged rather than blindly followed.

---

## 0. Status — what's built, and what needs your eyes

Branch: **`main`**, 31 commits ahead of `origin/main` and unpushed. `restore-point/v2-onboarding-paths` is the pre-v2 restore point, not the work — an earlier version of this section had that the wrong way round.
`flutter analyze`: 0 errors, 0 warnings. `flutter test`: 82 passing.

### Build order progress

| Step | State |
|---|---|
| Prerequisite — per-theme category palettes | ✅ |
| Prerequisite — `Moment` schema + rollup | ✅ |
| 1 Completion sheet, two steps | ✅ |
| 2 Home redesign | ✅ |
| 3 Grid + Insights page | ✅ |
| 4 Returns | ✅ |
| 5 Seasons | ✅ |
| 6 Paid month page | ✅ drift, letter, monthly plan, did-it-work |
| 7 Share cards | ✅ monthly season card; habit names opt-in |
| 8 Paywall move | ✅ fires after the first completed action |
| 9 Packs → intentions | ✅ store killed, inline swap hint, search dropped |
| 10 Free rescue | ✅ gap detection + reduced home screen |
| 11 Later | ✅ what-lifts-you (dormant until ~8 weeks of mood taps; forming state until then) · ✅ retroactive logging (yesterday, via long-press) · Apple Health stays deferred per §6.5 |

**Next up.** Steps 1–10 are built, and §12's week-one gap is now closed in code: day 2–7 gets the SO FAR chronicle (each moment as a row, honest "too early to call a pattern" confidence line) and the first-week keepsake card. What-actually-lifts-you and retroactive logging shipped too — §11 now means only Apple Health, still deferred per §6.5. Genuinely open: the **App Store page** (§12's only compounding channel — subtitle, keywords, screenshots; lead with the "What you're starting with" card), a **native Russian proofread** (the corpus now speaks ты consistently, but it is my ты, not a native's), and the Known-issues list below.

A ten-finding code review (Aug 13) was fixed in full — the largest: `momentsForMonth` double-shifted its anchor by the UTC offset, which showed every user west of UTC the previous month and froze seasons under wrong archive keys; onboarding left routes under MainTabs that stray pops could land on; and the paid gap intervals printed reversed. `visibleHabits()` on OnboardingState is now the single definition of "active" — Today, the widget, all-done detection, packs, swaps and the plan all read it. The orphaned pre-v2 reflection cluster (ten files) is deleted, and **Boost is retired from sale** (entitlement still honoured; the ceiling sheet only opens the real paywall now).

**Notifications, current state:** adaptive *cadence* exists (normal / reduced / re-engage tiers), the weekly summary exists and now points at the month page. Not yet built, in priority order: the paywall surface rewrite (stale copy, $39.99 fallback — the audit's top funnel issue), the plan nudge on the 1st, drift-as-notification, and the consented adaptive-timing toggle.

Four design-review rounds were applied against live simulator screenshots (share story card on the theme background, one-card Insights, done-card treatment, nine paths with fixed starter actions, path adoption end-to-end). The letter's rewritten voice, the two-group plan, the moved paywall and the rescue screen have been verified by tests and the analyzer; the rest has had eyes on it.

**What step 6 turned out to need.** The page now splits by tier, which it didn't before: paid gets drift, season, letter and plan; free gets season and the teaser; day one belongs to neither (§5.4). The drift card had shipped ungated.

The plan's four nudges each write a real setting — move the reminder, set aside an action, pin the anchor, adopt a lived focus area. §6.2's "lighter on Wednesdays" is deliberately absent: there is no setting behind it, so accepting would change nothing, and §4.5 makes that disqualifying. `OnboardingState.adoptFocusArea` is new for the same reason — `toggleFocusArea` holds the free tier's cap of two and never writes to disk, so the accept button would have silently done nothing.

§6.3 compares equal windows, four weeks either side, and reports a fall as plainly as a rise. The proof line does not appear until a full four weeks have passed since the change.

### ⚠️ Needs you — cannot be done or seen from a dev machine

1. **Set Lifetime to €49.99 in App Store Connect.** The in-app value is only the pre-load fallback; RevenueCat supplies the real price. Until you change it there, users still see €69.99. *The only outstanding item with money attached.*
2. **The review prompt → App Store redirect**, on a real device. Neither in-app review nor App Store links work in the Simulator.
3. **The step-2 tile-landing animation.** The sheet auto-dismisses ~2.3s after the mood tap, faster than a scripted screenshot. §5.2 warns that if the landing doesn't read, drop the tile row for words.
4. **Day-one Insights and the EXAMPLE card** — only render on a fresh install.
5. **Real season words and the return glow** — need ≥10 moments and gaps between them. Only "Beginning" and gapless months have been seen.
6. **The archive and month-freezing** — need a month boundary to cross.
7. **The category palette on all 10 themes.** Tests guarantee 3:1 contrast everywhere, but legible is not the same as beautiful. Check `warmClay`, `goldenHour`, and both dark themes.
8. **Russian copy** across the new strings — completion sheet, seasons, drift, insights, and now the letter and the plan. Mine is serviceable, not native. The plural forms are done properly (one/few/many), but the phrasing wants a native ear.
9. **The plan card's prominence.** §5.3 calls it the most prominent card on screen; it currently gets a denser glass and a brighter edge and nothing else, which on the simulator is *subtle*. If it doesn't read as the anchor of the page, it needs more than opacity.
10. **The §6.3 proof line after a real four weeks.** Seen with seeded data, never with a change actually made four weeks earlier.

Items 3–6 are covered by tests for *behaviour*, not appearance.

**Verified on an iPhone 17 Pro Max simulator** (Aug 2026 data, both tiers): the letter reads *"You came back on Friday, after 3 quiet days. / Most of the month was Take 3 slow breaths — 7 times. / 7 of them you were glad you did. 2 took effort. / What brought you back that day?"* The plan opened with its proof line, offered one decision, held three behind "3 more when you're ready", and accepting wrote the reminder to 22:00 and recorded the baseline. Free tier showed season and teaser only.

### Known issues, not yet fixed

- **Paywall sheet scrolls under the status bar / Dynamic Island** — top bullet clipped, missing safe-area inset.
- **"Let's begin" on habit reveal is green** while every other primary CTA is taupe.
- **`lib/main.dart` is ~6,600 lines.**
- **`lib/main.dart.bak`** is a stale copy still in the repo.
- **The home-screen widget still shows a rotating affirmation**, not the intention — worth revisiting once the Today header change proves itself.

### Decisions taken, with reasons

- **Per-theme category palettes.** Hue carries meaning and never changes; saturation is the per-theme knob; **lightness is solved for**, driven to the luminance that hits a contrast target. Saturation is the wrong lever for softness — dropping Iris 0.58→0.26 barely changed the tiles because the contrast target pins luminance. `CategoryColors.of()` uses 3.4:1 for grids where colour is the only information; `onCard()` uses 2.1:1 where text names the thing anyway.
- **Completed card** = wash + tile with glow + full-opacity text. **No fade** (reads as disabled), **no strikethrough** (reads as cancelled), no outline. The tile's presence is the non-colour cue.
- **Today header is the intention phrase** ("Steadier on hard days"), not the path name — a product category would test a weaker claim than §4.1 makes.
- **Notes** stored on `Moment`, capped 280 chars, **not** analysed.
- **Seasons**: word from the strongest axis, not an average; ≥10 moments or it says "Beginning" with a count; open month recomputed every read, closed months frozen.
- **Drift** compares to the user's own rolling average, never a target, and returns null unless there is something honest to say.
- The new Insights page replaces `progress_screen.dart`. `moments_collection_screen.dart` is date-indexed and contradicts §4.2 — it should go once the grid proves itself.

### Two things worth carrying forward

**The tests never caught the design failures.** Muddy wash, loud wash, opaque wash, cramped bar, uneven margins, inverted type hierarchy — all passed every automated check. Contrast tests prove legibility, not meaning. Get eyes on new surfaces early.

**Check whether a sentence is true before shipping it.** The teaser card asserted "the gap between the focus you chose and the one you actually lived" with nothing computing it — false for any user whose focus matched. §5.3 names this exact failure. It is now computed. Any copy that states a finding needs the finding.

---

## 1. The core diagnosis

**The app is called Intended, onboarding asks for an intention — and then every screen says "habits" and shows a checklist.** The brand promise and the product were two different things.

Three consequences that shaped everything else:

1. **Streaks were removed without replacing the return mechanic.** Every competitor has a unit that pulls you back (Finch's pet needs feeding, Habitica's character levels, Streaks' unbroken chain). Intended removed the punishment and left the checklist bare.
2. **Premium was mostly cosmetic.** Themes, widget sizes, and "unlimited habits/swaps/focus areas" are removed restrictions, not features. Only weekly reflections was a real capability — and it ran on completion counts alone, so it could only ever say "you did 4 things."
3. **The free tier sat below market bar** while the paid tier delivered a promise it couldn't keep inside a 7-day trial.

Marketing failure was separate but related: prior content (API key leaks, RevenueCat, App Store approval, founder story) reached builders, who don't download habit trackers.

---

## 2. Competitive position

| App | Scale / price | What it owns |
|---|---|---|
| **Finch** | 10M+ downloads, 4.9 from 700k+ ratings, free | Gentle self-care + emotional attachment (pet). Already owns "forgiving." |
| **Daylio** | 4.7 from 500k+ ratings | Two-tap mood logging, Year in Pixels. Criticised for paywalling core utility. |
| **Streaks** | $5.99 one-time | Apple Health + Shortcuts integration |
| **Way of Life** | $79.99 lifetime | Charts, data export |
| **Keelify** | — | Grace days, strength score, milestones explicitly mapped to Lally |

**Critical finding: "gentle / no streaks" is no longer a differentiator.** It was a wedge in 2025; by 2026 it's a category norm. Intended cannot win on tone — only on what it *does* with the tone.

**Missing table stakes:** Apple Health, Apple Watch, iCloud sync, data export, retroactive logging.

---

## 3. Evidence base

**Philosophy (defensible):**
- Lally et al. 2010: missing one opportunity **did not materially affect habit formation**. Median 66 days to automaticity, range 18–254. Overall consistency matters, not an unbroken clock.

**Friction:**
- Daylio's success rests on: the barrier to journaling isn't lack of things to say, it's the friction of having to write. Hence two-tap entry.
- Daylio's stated ceiling: it captures *what* you felt and did, but not *why*. ← Intended's opening.

**Conversion:**
- 90% of trial starts and 44.5% of all purchases happen on Day 0. Users who don't convert during onboarding mostly never return to the paywall.
- Onboarding and paywall are **one funnel** — what happens before the paywall determines conversion more than paywall design.
- Paywalls triggered after a measurable value moment see **2.1x higher trial start rates**. One documented restructure: 8.2% → 19.7% in six weeks.
- Health & Fitness benchmarks: median trial start 5–7% of installs (top 5%: 12–15%); trial-to-paid ~62%.

**Pricing:**
- High-priced apps earn **3x the LTV** of low-priced ones. In Health & Fitness, expensive annual plans earn **4.5x more per user**. Annual = 60.6% of H&F revenue.
- Discount-acquired users churn faster at renewal.

---

## 4. Conceptual changes (the spine)

### 4.1 Intention is the primary object

Habits become **actions** underneath an intention. Moments become **evidence** you're living it. Today's header is the user's intention ("Being more present"), not a generic affirmation.

⚠️ **This is the least evidence-backed decision in the doc.** No competitor does it — either an opening or something already tried and abandoned. **Test cheaply first:** rename the Today header to the intention and add the intention line to the completion sheet. One day of work. If Day-7 retention doesn't move, don't build the rest.

### 4.2 Moments = tiles indexed by moment, not date

**The single most important structural decision.**

- GitHub's contribution graph and Daylio's Year in Pixels both index by **date** — so an empty cell means "you failed." That's a streak with better manners.
- Intended indexes by **moment**. Cell 1 is your first moment, cell 47 your forty-seventh. There is no cell for a skipped Tuesday because days aren't the unit.
- **The grid only ever grows. Absence is structurally unrepresentable.**
- Colour = focus area (coral Health / violet Self-care / sage Mood). Brightness or size = mood.
- Never outline empty cells — a bounded grid of 300 empty slots is "look how much you haven't done." Tiles fill and stop, with one faint ghost tile after the last.
- **Gaps are shown as returns, not absences.** The first tile after a gap gets a soft glowing ring. Tap it: *"You came back here, after 6 quiet days."*

**Failed approaches (don't revisit):** lights scattered on a landscape painting (unreadable — decoration, not data); dark landscape revealed by lights (still unreadable). The grid works; the painting doesn't. Data displays and aesthetic artifacts can't be the same object.

### 4.3 Returns replace streaks

Count **returns** — how many times someone came back after a gap, and whether gaps are shortening. `"You came back 4 times — 9, 6, 4, 2 days apart."` A streak says *you broke it*. This says *you're getting better at coming back.*

### 4.4 Seasons, not personalities

Monthly, recomputed, **never fixed identity**. "This month you've been ___" not "You are ___."

- Four axes, none with a bad end: Morning↔Evening, Steady↔Bursts, Returning↔Continuous, Focused↔Wandering.
- Threshold: don't show until ~10 moments; show forming state with a count before that.
- Copy is observation, never assessment: *"you came back most often in the evenings"* not *"you are an evening person."*
- Season **word** is free; the **explanation and archive** are paid.
- Precedent: Spotify's listening personality was assigned automatically from behaviour, drove a 21% download increase in Wrapped week, and its removal in 2024 drew complaints. Risk to avoid: reading as "zodiac signs for music."

### 4.5 Free = what happened. Paid = what to do about it.

**Every paid insight must end in a button that changes something.** A mirror doesn't justify a subscription. Diagnostic that caught this: the paid screen was all observations ("you've been reaching for rest") and the one forward-looking element (reminder nudge) had been put in the free tier.

### 4.6 Never paywall the rescue

Gap detection, the gentle notification after silence, and the reduced home screen are **free forever**. Someone who's disappeared for nine days is the person who most needs help and is least likely to be a subscriber. Free catches you when you fall; paid helps you fall less often.

---

## 5. Screens

### 5.1 Today

- Header: **the intention** + date. Not "SUGGESTIONS" (wrong word — these are what the user chose, calling them suggestions makes them feel algorithmic and lowers commitment).
- Four action cards, thin coloured left bar = pending.
- **Completed card:** no left bar, very pale coral wash at low opacity, text in soft violet, small row of tiny tiles at the right edge. **Not grey** (means disabled/deleted), **not saturated** (reads as selected/alert), **no strikethrough** (reads as cancelled — contradicts "collected").
- Bottom: one quiet line with a small plus icon, "Add something of your own." No large dashed CTA — over-collecting in week one is the documented abandonment path.
- Swap lives on long-press + tutorial. ⚠️ Long-press is undiscoverable; back it with **just-in-time hints** — when an action sits untouched ~2 weeks, show inline on that card: *"Not landing? Hold to swap."*
- **Screen should know what week it is.** After a gap: single card, *"Eight days. That's allowed. Just this one today?"*

### 5.2 Completion — two steps, one modal

**Delete the "Did you do this today?" confirmation entirely.** Nobody taps a habit card by accident; it's friction phrased as an interrogation.

**Step 1:** action name, timestamp, "How did that land?", three pills, small "skip". No tile, no Done button.

**Step 2 (after tap):** row of this month's tiles with the new one **animating in** at the end with a glow. Then action name, "1:12 AM · Glad I did", and *"Kept — 13 moments this month."* Auto-dismisses.

⚠️ **The animation is not optional.** A static row of 13 tiles is just a row; the tile landing is what explains the system. Without animation, drop the row and use words only.

**Mood scale: "Glad I did · Neutral · Took effort."**
Rejected "heavy / okay / light" — it's a *sensation* scale that breaks on non-somatic actions, and it carries a hidden judgement (light=good, heavy=bad), so hard valuable work gets labelled negatively. The chosen scale works across all categories, has no bad end, and captures *worth* rather than pleasantness — which is the more useful correlation later.

**Mood tap, not a text field.** Optional note behind a small "+". This is what makes weekly/monthly insights real rather than counts.

### 5.3 Month (insights)

Free and paid share the same cards and quality; paid has more of them.

**Free:**
1. The grid + legend + "You came back 4 times"
2. Season **word** only + Share
3. One softer card: real content **fading out mid-sentence** (not padlocks) + "✦ Unlock Intended+"

**Paid:**
1. Grid + legend + returns *with gap intervals*
2. **Right now** — drift warning (see 6.1)
3. **Your season** — word + explanation + past seasons + Share
4. **Your letter** — 4 lines, ending in a **question** not a comfort
5. **Your September plan** (see 6.2) — most prominent card on screen

**Fade, not padlocks.** A lock is a hard metal object in a world of mist and glass — the only element that looks borrowed from another app. It says *blocked*; a sentence dissolving says *there's more here*. Show real content fading, not grey placeholders.

**One decision per month, not three.** Earlier version had three nudges and six buttons — a dashboard demanding optimisation. Rank them, show the top one, hold the rest behind "2 more when you're ready."

**Never ship an empty paid state.** The original bug: free showed a lock reading "See which days work best"; paid showed "After a few weeks, we'll show you..." — the user bought a promise and received a reworded promise. Either a section has real content or it isn't on the screen. Partial data with honest confidence instead: *"So far: Monday, Friday, Saturday. Too early to call it a pattern — ask me again in two weeks."*

### 5.4 Day one

Not zero data — they just finished onboarding. Three cards:

1. *"Nothing here yet — and that's exactly right."* + one row of 8 empty outlines + caption *"one square = one thing you did"*
2. **"WHAT YOU'RE STARTING WITH"** — their intention, their three actions, focus areas + reminder time. ⚠️ **This card tested as the strongest thing on the page** — it's the only place the intention is visible and it explains the app to a stranger in one glance. Use it as the lead App Store screenshot; consider echoing it on Today.
3. An **EXAMPLE** card showing what the page looks like in a month + one line: *"✦ Intended+ reads your month and suggests what to change. It unlocks once you have something to read."*

**No paywall on day one.** There's genuinely nothing behind a lock yet — upgrading would unlock three empty cards. The Day-0 conversion window belongs to the onboarding paywall (moved to just after the first completed action), not to this tab.

⚠️ Mark the EXAMPLE card unmistakably (dashed border / clearly reduced opacity). At current styling someone could screenshot it thinking it's their data.

### 5.5 Share cards — two, with different jobs

**Weekly card** — the workhorse. Humble, frequent, personal. 52 chances a year. Includes habit names (they're aspirational, not embarrassing) with an **opt-in toggle: "Include my habit names," off by default.**

**Monthly season card** — rare, event-like. Season word as hero (not the number — "3" invites comparison and looks small), grid, "37 moments · I came back 4 times", logo, and **"intention, not perfection" promoted to legible size** (it's the strongest line and was the smallest text).

⚠️ **Honest expectation:** user-generated sharing cannot bootstrap from zero. Wrapped works because millions post simultaneously. One user posting to 200 followers gets a couple of likes. **The card's real near-term job is as *your* marketing asset** — you post it. Build it once, cheaply, and stop tuning it.

### 5.6 Coach marks — the dim-and-explain pattern doesn't survive

Five coach marks exist today, each a full-screen dim plus a tooltip card. That's an interruption pattern in an app whose whole pitch is not interrupting you, and §5.2 now teaches the core concept better than a tooltip can. Per-mark decisions:

- **`firstCompletion` — delete.** §5.2 step 2 *is* this moment: the tile animates in and says "Kept — 13 moments this month." An overlay firing straight after is the same lesson twice. It's also the mark that needed a `just_completed_onboarding` guard to stop it appearing at the wrong time — a symptom of the pattern not fitting.
- **`pinning` — rework into an inline hint.** It currently teaches long-press = pin, but §7 reassigns long-press on an action card to **swap**. Shipped unchanged, it teaches a gesture that no longer exists. Replace with §5.1's just-in-time hint on the card itself: *"Not landing? Hold to swap."*
- **`widget` — keep, but not as a dim.** The widget lives outside the app so it can't be hinted inline. A quiet card on Insights or Profile does the job.
- **`smartNotifications` — drop.** Low value, and adaptive timing should be felt, not announced.
- **`weeklyReflection` — fold into the Month page.** Once §5.3 exists, the page is its own explanation.

**Rule going forward:** gesture discovery happens inline, next to the thing, at the moment it's relevant. Overlays are reserved for what genuinely lives outside the app.

---

## 6. New paid capabilities

### 6.1 Drift warning (build first — cheapest, most on-brand)

Warn **before** the gap, using existing data:

> You've collected 2 moments this week. You usually collect 6.
> The last two times this happened, a quiet stretch followed.
> **Just one action for a few days** · **I'm fine**

Only forward-looking feature in the app. Finch, Streaks and Daylio all *react* to absence; none anticipate it. Low cost: rolling average vs. baseline.

### 6.2 Your [Month] Plan

On the 1st, propose next month from last month's evidence, as one accept-or-adjust flow. **Absorbs the scattered nudges** so they stop being loose buttons.

Grouped under two sub-headers (test whether these help at 4 items or just add overhead):
- **YOUR ACTIONS** — Keep (your anchor) / Retire (only 3 times)
- **YOUR RHYTHM** — Lighter Wed & Thu / Reminder at 10pm + add Self-care to focus

Opens with proof: *"In July you moved your reminder to 10pm. 22 moments since, up from 14."*

Changes the subscription from *reviewing the past* to *planning the next month* — which is what makes someone open it in month seven.

### 6.3 Did it work (the renewal mechanic)

Every accepted nudge becomes a measurable before/after. Month one the app tells you things about yourself; month eight it tells you whether what you changed is working. **This is what stops insights running out of novelty around month four.** Now folded into the plan card's opening line.

### 6.4 What actually lifts you (later — needs mood tap + ~8 weeks data)

Rank actions by how they land: *"Body scan — glad I did it 8 times out of 10. Drink water — 2 out of 10."* → **Swap the water one**. The only feature that tells someone which habits are worth keeping.

### 6.5 Deferred

- **Apple Health** — real value, but it's Streaks' moat and doesn't answer "why pay." Not this year.
- **Retroactive check-in** — ship it (its absence is embarrassing for a self-compassion app), but it's a papercut fix, not a growth lever.
- **Year in Moments** — annual artifact has zero value in week one. The rolling grid replaces it.

---

## 7. Packs & the library

**Packs and onboarding intentions are the same feature under two names.** "Winding Down — an evening decompression set" *is* an intention. Merge them: packs become **intentions you can adopt**, reachable at onboarding and later.

**All intentions free.** "Gentle Mornings free / Winding Down premium" is the weakest possible paywall — content is the easiest thing for a competitor to give away, and users resent locked lists more than locked analytics (exactly Daylio's criticism). Charge for seasons, the why, and the archive.

**Kill the global "Browse all habits" entry.** It's a store; the implied verb is *acquire*, and the only action available is making your list longer. Replace with two contextual doors:
- **Swap** — from an action card, filtered to the same focus area. Verb: *refine*.
- **Adopt an intention** — from the Today header. Verb: *redirect*.

Same content, same sheet, opposite psychology. Neither door grows the list.

Also: drop the search bar (pointless at 20 items, earns its place ~50+), and fix the count inconsistency (home said "8 more," sheet said "20 available").

**Keep custom creation deliberately constrained.** 50-char limit, category chips, no frequency/targets/scheduling — that's the productivity-app trap and it imports the pressure the app exists to remove. Way of Life and Strides already own numeric target tracking. Change: create the action *inside an intention* ("What small action serves being more present?") — a constrained prompt beats a blank field.

---

## 8. Pricing

| Plan | Price | Notes |
|---|---|---|
| Monthly | €5.99 | |
| **Yearly** | **€44.99** | **Hero.** Anchor as "€3.75/month, billed yearly" against the €5.99 monthly |
| Lifetime | €49.99 | Down from €69.99. An option, not the hero |

**Do not discount to acquire.** Discount-acquired users churn faster at renewal.

⚠️ **Correction on record:** an earlier recommendation to cut Lifetime to €29.99 was wrong and contradicted by the data (high-priced apps earn 3x LTV; H&F annual plans 4.5x per user). €49.99 is the revised position.

**Move the onboarding paywall to immediately after the first completed action**, with the moment card on screen. Currently it asks people to buy pattern-insights before they have a single data point — an unverifiable promise.

**Paywall copy:** cut "Unlimited habits, swaps, and focus areas" entirely — it contradicts the entire brand. Lead with what's deliverable inside 7 days (themes/dark mode, widgets, packs), with weekly reflections lower.

---

## 9. Language rules

**Plain language beats clever design.** A cold reader ("I've no idea what this all means" after 3 seconds) failed on invented vocabulary. Fixes:

| Instead of | Write |
|---|---|
| "37 moments. Most of them after 11pm." | "**You did 37 small things for yourself in August.** Most of them late at night." |
| *(no caption)* | "one square = one thing you did" — under the grid |
| "You came back 4 times — 9, 6, 4, 2 days apart" | "Four times you went quiet for a few days. Four times you came back." |
| "You showed up 3 days. That's 3 days you chose to try." | "You showed up 3 days this week." ("chose to try" reads apologetic) |
| "SUGGESTIONS" | The user's intention |
| Stock quote ("Consistency is important, but so is self-compassion") | The weekly letter |

**Voice:** observation, never assessment. Warm without being congratulatory. The letter can name intimate things ("you came back on Friday after three quiet days"); the share card cannot.

**Kept copy that works:** "Nothing here yet — and that's exactly right." · "Kept." · "2 more when you're ready" · "It unlocks once you have something to read." · "intention, not perfection."

---

## 10. Data architecture

Compute everything **on device**. At ~4 completions/week this is a tiny dataset. No Cloud Functions, works offline, costs nothing.

```
users/{uid}
  ├─ profile      → name, intention, focusAreas, theme
  ├─ moments/{id} → title, category, source,
  │                 completedAtUtc, tzOffsetMin,
  │                 localHour, localWeekday, mood
  ├─ seasons/{yyyy-MM} → code, axes, sampleSize, computedAt
  └─ rollup/current    → counts by hour/weekday/category,
                         gap stats, lastMomentAt
```

1. **Store `localHour` and `localWeekday` as fields**, not just UTC. Morning↔Evening and Steady↔Bursts are computed from them; deriving at read time breaks silently the moment someone travels.
2. **Keep `rollup/current`.** The widget can't run a month-wide query cheaply. Update it in the same write as the moment.
3. **Seasons are immutable once the month closes.** A season that changes retroactively destroys "this was who I was in September" — and that permanence is what makes the archive worth paying for.
4. **Compute trigger:** on app open, if current month has ≥10 moments and no season doc exists, compute and write. Otherwise show the forming state.

### Auth — highest-risk area

- **Use `linkWithCredential`, NOT `signInWithCredential`** when an anonymous user signs in with Apple/Google. Link preserves the UID and all their moments. Sign-in creates a new UID and **silently orphans everything**. Invisible in testing unless you explicitly check the old data survived.
- Handle `credential-already-in-use`: sign into the existing account, and if the anonymous one had moments, batch-copy them over.
- **Apple returns the full name only on the very first authorization, ever.** Persist it in that callback — there is no second chance, and re-authorizing won't return it.
- **In-app account deletion is required by Apple** for any app with account creation. Currently missing → rejection risk on next submission.
- Mood data reads as health-adjacent. State plainly in the FAQ what's stored and where.

---

## 11. Build order

The original list sequenced only part of §4–§10. This is the full order, with the missing sections folded in and dependencies corrected.

**Cross-cutting prerequisites** — neither is a screen, both block the ones that are:

- **Per-theme category palettes.** §4.2 fixes coral/violet/sage as focus-area colours, but the app has 10 themes (2 dark). Fixed colours clash on `warmClay`, `nightBloom` and others, so each theme needs its own tuned trio. The share card picks one.
- **Data foundation (§10).** Extend `Moment` with mood, category, note, `localHour`, `localWeekday`, tz offset; add the rollup. Must come first: `localHour`/`localWeekday` **cannot be backfilled** — a UTC timestamp doesn't record what the user's clock said — and steps 4, 5 and 6 all compute from them.

| # | Work | Sections |
|---|---|---|
| 1 | Completion modal, two steps + tile-landing animation; delete the confirm dialog and the `firstCompletion` coach mark | §5.2, §5.6 |
| 2 | Home redesign — completed-card treatment, intention as header, "Add something of your own" | §5.1, §4.1 |
| 3 | Grid + day-one Insights (replaces `progress_screen.dart`) | §4.2, §5.4 |
| 4 | Returns — "four times you went quiet, four times you came back" | §4.3 |
| 5 | **Seasons** — four axes, ≥10-moment threshold, monthly compute, archive | §4.4 |
| 6 | Paid Month page — drift warning, letter, monthly plan; absorb the `weeklyReflection` coach mark ✅ *(the coach mark itself is still to remove)* | §5.3, §6.1–6.3 |
| 7 | Share cards — weekly workhorse + monthly season card, both with the "one square =" caption | §5.5 |
| 8 | Paywall moved to after the first completed action + copy rewrite | §8 |
| 9 | Packs → adoptable intentions; kill "Browse all habits"; long-press becomes swap + inline hint. **Nine paths now**: the original four plus Softer Nights, Looking Up, Closer to People, Moving a Little, Through a Hard Season — each with fixed starter actions (a random Health draw could hand a sleep-seeker a glass of water). New paths borrow an elder path's notification/warmth copy via `IntentionPathVoice` until they earn their own. Path titles resolve on the model (`IntentionPath.title`) — three screens each carried a copy of that switch and all three missed the new paths. | §7, §5.6 |
| 10 | Free rescue — gap detection, gentle nudge after silence, reduced home screen | §4.6 |
| 11 | Later — what-actually-lifts-you, Apple Health, retroactive logging | §6.4, §6.5 |

**Done:** §8 pricing and paywall copy (Lifetime €49.99, "Unlimited everything" bullet cut, per-month anchoring derived from the live App Store price).

Plain-language rewrite (§9) isn't a step — it applies to every screen as it's built, not as a pass afterwards.

---

## 12. Still undesigned

- **Week one (~day 5).** 4 moments, no season, no plan, nothing to say. **This is where people decide whether to keep the app** — day one and month one are both easy by comparison. Highest-priority gap.
- **App Store page.** Subtitle, keyword field, screenshots, preview video — almost certainly still launch-day defaults. Only channel that compounds while you're not working on it. Lead screenshot: the widget in situ, or the "What you're starting with" card.
- **Gap-aware Today screen** — designed in principle, not drawn.
- **FAQ** — answer objections not features: Is it free? What if I miss a day? Why no streaks? Do I lose anything if I stop paying? Is my data private? What's actually in Intended+?

---

## 13. Reality check

The product was never the binding constraint. **~25–30 paying customers ≈ 700–1,000 installs** at realistic conversion. Distribution is the problem; prior content aimed at builders produced nothing.

At 3–5 hours a week, everything above is more than the rest of 2026. Sequence ruthlessly, and get a version in front of real people before designing further — three insights-page redesigns happened before a single stranger saw any of them.
