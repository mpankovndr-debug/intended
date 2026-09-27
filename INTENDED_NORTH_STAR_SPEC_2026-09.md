# Intended: North star, chapters, and an Insights page worth opening

Design spec, September 2026. Written from a design conversation; nothing here is built yet.

Code references point at `origin/fix/trial-length-and-stale-prices`, the branch the device build runs.
`main` is 35 commits behind it (Pause, the season rewrite, the store copy), so read the code there, not on `main`.

Copy rule for everything below: **no em dashes in new copy.** Use a colon, a full stop or a comma.
The English ARB on the device branch already has 77 of them; a sweep is a separate job.

---

## 0. The problem this answers

A month on the paid plan, 42 moments, and the Insights page still gives nothing to act on:

- **Every card is a conclusion with no way to see its evidence.** "Continuous" is computed as *no quiet
  stretch of two days or more all month* (`season.dart`, `quietDaysForGap = 2`). The app knows that and
  never says it.
- **The plan forgets what you chose.** Once a nudge is accepted, the card shows only "Done. In four weeks
  this page will tell you whether it changed anything." (`insights_screen.dart:1552`). The app stores what
  you accepted (`AcceptedNudge.kind / subject / acceptedOn / before`, `plan_service.dart:14`) and even has
  the sentences to say it (`planProofMovedReminder`: "On {date} you moved your reminder to {time}."), but
  only shows them four weeks later. By CLAUDE.md's own rule this card is a promise restated: a bug.
- **Nothing connects the moments to what they were for.** 42 squares, and no line anywhere says what they
  are evidence of.
- **The only forward-looking pattern needs 56 days** (`lift.dart:60`). Before that the page has nothing
  new to say most days.
- **Almost nothing is tappable** except the mosaic, so it reads as a printed page.

---

## 1. The North star (the sentence)

One line in the user's own words: **"I want to ___"**, prefilled from the chosen path and editable.

It is Fogg's first step (clarify the aspiration), which onboarding currently skips: it goes from the path
list straight to "One small promise. Two minutes a day." It lives on **Insights** (top of the page) and
in the chapter record. Today keeps the path phrase it already shows (`main.dart:653`).

Prefill per path (EN; RU written at build time, «ты», native read):

| Path | Prefilled sentence |
|---|---|
| Gentle Mornings | I want to start my mornings slower |
| Anchors for Hard Days | I want something that steadies me on hard days |
| Quiet Focus | I want to get things done without burning out |
| Winding Down | I want to let the day go before I sleep |
| Softer Nights | I want to stop fighting my sleep |
| Looking Up | I want to spend less of my day on my phone |
| Closer to People | I want to stay close to the people I care about |
| Moving a Little | I want to move my body more, gently |
| Through a Hard Season | I want to get through this season gently |
| Your Own Way | (empty field, placeholder "…") |

---

## 2. Chapters

### 2.1 Rules

- A chapter is **three months**, ending on the last day of a month (a landmark: Dai, Milkman & Riis 2014).
- **Start rule.** If at least 14 days are left in the month you start in, that month is month 1.
  If fewer, those days fold into month 1, and month 1 is the next calendar month.
- **Stages are the months:** month 1 *Try a few*, month 2 *Keep what stuck*, month 3 *Make it lighter*.
  The monthly plan proposes the next stage from evidence; the person accepts with a button (paid).
  An empty month offers the first step again. There is no "behind".
- **The end is a date, shown as a date**, never a countdown. The person can also end it early.
- **At the end the app asks, the person answers.** No verdict, no "achieved".

Worked examples:

| Start | Month 1 | Ends | Length |
|---|---|---|---|
| 1 Sep | September | 30 Nov | 91 days |
| 17 Sep (14 days left) | September | 30 Nov | 75 days |
| 18 Sep (13 days left) | Sep 18 to Oct 31 | 31 Dec | 105 days |
| **29 Sep** | Sep 29 to Oct 31 | **31 Dec** | 94 days |

So a chapter runs 11 to 15 weeks. If "never longer than a quarter" must be strict, lower the threshold to
7 days (range 69 to 99 days) and accept that month 1 can be as short as 8 days. Signing up on 29 or 30
September means chapter 1 ends on 31 December, which is also the year's end, so the first chapter and
the year view close together.

### 2.2 Model (`lib/models/chapter.dart`, pure, no `BuildContext`)

```dart
enum ChapterAnswer { partOfMe, keepGoing, somethingElse }   // persisted keys, never rename

class Chapter {
  final String id;
  final String sentence;        // the user's words, never localised; editable while open
  final String pathKey;         // IntentionPathId.key at start
  final DateTime startedAt;     // UTC
  final int startOffsetMinutes; // offset at start: local day comes from the recorded offset
  final String month1Key;       // "2026-10": after the 14-day start rule
  final String endMonthKey;     // "2026-12": the chapter ends at the end of this month, local
  final ChapterClose? close;    // null while open

  int stageOn(DateTime localDay);            // 1..3, derived, never stored
  static Chapter start(...);                 // applies the 14-day rule; unit-tested
}

class ChapterClose {
  final DateTime closedAt;
  final ChapterAnswer answer;
  final String? note;           // optional: "Anything you want to remember about these months?"
  final ChapterFacts facts;     // frozen at close, never recomputed
}

class ChapterFacts {
  final int moments;
  final List<int> gapDays;               // returns, as in MomentRollup
  final int lensCount;                   // "evenings", "mornings" or "days" (§3.2)
  final Map<String, int> byCategory;
  final List<String> kept;               // actions still active at close
  final List<String> setAside;           // actions set aside during the chapter
  final Map<String, String> seasonPoles; // monthKey -> frozen season pole
  final int pauseMinutes;                // real: one completed pause = 60 s
}
```

- **Moments are not tagged with a chapter.** A chapter is a range of local days; a moment belongs to it
  by `Moment.localDay`. Nothing in the moment store changes.
- **Persistence:** `ChapterService`, the same pattern as `SeasonService` (`seasons_by_month` in
  SharedPreferences, `season_service.dart:12`), key `chapters`. The backup appears to copy every prefs key
  except a device-only list (`backup_service.dart:21-24`), so check that it picks this key up. Export
  (commit 152a818) must add chapters explicitly.
- **Immutable once closed**, like seasons. The sentence can be edited while the chapter is open and is
  frozen at close.
- **Changing path mid-chapter** asks: "Start a new chapter with this?" If yes, the ending question runs
  first. This also feeds the existing `intention_changed` analytics.
- **Onboarding creates chapter 1.**

### 2.3 The ending

It appears on Insights on the first open after the end date, plus one quiet notification that day.

> **Your first chapter ended on 31 December.**
> You said: *"I want to let the day go before I sleep."*
> Over these three months: 118 small things, on 64 evenings. You came back 6 times, 5, 3, 2, 2, 1 and 1 days apart.
> **Did something change?**
> [ It's part of me now ]  [ Keep going ]  [ Something else now ]
> *Anything you want to remember about these months?* (optional field)

- *It's part of me now* starts a lighter chapter with the same sentence.
- *Keep going* starts a new chapter on the next 1st with the same sentence.
- *Something else now* opens the sentence screen.

Design the "not there yet" feeling first; Breines & Chen (2012) put the motivation in how falling short
is met.

### 2.4 Where closed chapters live

The "Your months" screen (`YearInSeasonsScreen`, `yearInSeasonsTitle`) groups its month rows under
chapters. Nothing moves: a chapter is a frame around month rows that already exist.

```
CHAPTER 1 · SEP 29 TO DEC 31
"I want to let the day go before I sleep."
You said: It's part of me now
"The breathing before bed stuck. The stretching didn't."   ← their note, if any
  December   Steady      ▪▪▪▪▪▪▪▪▪  41
  November   Evening     ▪▪▪▪▪▪▪    38
  October    Returning   ▪▪▪▪▪▪     39
```

The year view is this screen at the year level: one row per chapter. Build it in November.

### 2.5 Free / paid

- **Free:** the sentence, the chapter, the ending question, the note, saved chapters. These are the
  person's own words plus what happened.
- **Paid:** the stage-aware plan, and the explanation layer of long-term patterns (§3.4), in line with
  "season word free, explanation paid".

---

## 3. Insights, rebuilt around three horizons

### 3.1 Structure

```
[ Chapter header: CHAPTER 1 · UNTIL 30 NOVEMBER ]
[ "I want to let the day go before I sleep." ]
[ Sep ● Try a few ][ Oct  Keep what stuck ][ Nov  Make it lighter ]   ← calendar position, not a score

( This week | This month | Over time )      ← segmented control, remembers the last choice
```

- **This week** (short term: what happened, always something by day 2). Facts only, never a pattern.
- **This month:** today's page (mosaic, legend, pause, season word, plan).
- **Over time** (long term: patterns). Each shows **Ready** or **Forming** with its real partial data and
  when it firms up. Never a placeholder.

This split is how people know what to expect: short-term facts arrive immediately, patterns arrive when
there is enough to read, and each one says which it is.

Evidence for doing it this way:
- Harkin et al. 2016: monitoring progress improves goal attainment (138 studies, d ≈ 0.40), more so when
  it is recorded and visible.
- Amabile & Kramer 2011: across about 12,000 daily diaries, progress on meaningful work was the strongest
  driver of a good day. So the week view speaks in the intention's terms, not raw counts.
- Lally 2010 (a median of 66 days to automaticity) is why long-term patterns honestly need weeks.

### 3.2 The lens: counting in the intention's own unit

Where a path is about a time of day, count that unit; otherwise count days. It is computed from
`Moment.localHour` and `Moment.localDay` and **never shown with "of N"**. CLAUDE.md already allows
"9 moments across 7 days".

| Path | Unit | Local hours |
|---|---|---|
| Gentle Mornings | mornings | 05–11 |
| Winding Down | evenings | 18–23 |
| Softer Nights | nights | 21–03 |
| all others | days | any |

### 3.3 This week (free)

Sample, using the September pattern from the device screenshot:

```
THIS WEEK
5 evenings this week, you did something to let the day go.
[ ▪▪▪▪▪▪▪▪▪▪▪ ]  11 small things              ›

You came back on Tuesday, after 2 quiet days.  ›
Most reached for: Take 3 slow breaths, 4 times. You were glad you did, 3 times.  ›
2 minutes of breath. Afterwards you said: a little calmer.  ›
Your plan: on 1 September you moved your reminder to 21:30.  ›
```

Every line returns `null` when it has nothing true to say, and every line opens its evidence (§3.5).
Days appear only as labels on moments; the week never draws a slot for a day without one.

### 3.4 Over time (season word free; explanations paid)

```
YOUR SEASON          Continuous                          Ready  ›
  No quiet stretch of two days or more all month.
WHEN YOU SHOW UP     Evenings                            Ready  ›
  31 of your 42 moments came after 6 pm.
COMING BACK          1 return so far                    Forming ›
  The trend shows after 3.
WHAT LIFTS YOU       Take 3 slow breaths                Forming ›
  Glad you did it 4 times out of 7. Ready in about 3 weeks.
YOUR MONTHS          August: Evening                           ›
```

### 3.5 The deep dive: every claim opens its evidence

This is CLAUDE.md's "never state a finding you haven't computed", made visible: tap the claim and see the
computation. Each finding model gets a pure `explain()` returning structured facts (testable, no
`BuildContext`); each sheet is its own file under `lib/screens/insights/explain/`.

**Season (Continuous)**
- What it means: "You didn't go quiet for two days or more at any point this month."
- The evidence: "You did something on 24 different days. Your longest quiet stretch: 1 day."
- Why this word: a four-line compass, one line per axis (Morning/Evening, Steady/Bursts,
  Returning/Continuous, Focused/Wandering), with a marker at the computed strength. The word is the axis
  the month leaned on hardest. Both ends are named; neither end is bad.
- Last month: "August: Evening."
- Paid: ends in the plan suggestion this points to, if there is one (null otherwise).

**Plan**
- What you chose: "On 1 September you moved your reminder to 21:30." (existing `planProof*` strings,
  shown from day one instead of week four)
- Why it was suggested: the evidence at the time, recomputed from the closed month.
- Since then: "22 moments since, 14 in the same span before." Shown once there are enough days.
- Buttons: [ Keep it ] [ Undo ]

**"Most of them late at night"** → an hour-of-day chart of the month (use the dataviz rules when building).

**What lifts you** → the rated moments themselves, each tappable.

**A tile** → that moment: action, time, mood, note, and a return ring if it was one.

### 3.6 The smallest fix, shippable alone

Show `planProof*` under the plan's "Done" line on the day it is accepted, and put the chevron on the plan
and season rows. That is a day of work, it fixes a CLAUDE.md violation, and it answers "I don't remember
what my September plan was".

### 3.7 "You made 10 hours for yourself": not as an estimate

- No action has a duration today: the catalog is 102 actions with none recorded, and custom actions
  have none.
- Actions are tiny by design ("Two minutes a day. That's the whole ask."). My rough estimate: 42 mostly
  one-to-two-minute actions come to one to one-and-a-half hours, not 10. The number would be either small (it reads
  as failure) or inflated (it's false).
- Needing "it's an indication" on every render is the sign the number isn't backed.
- What is real: **pause minutes** (a pause is recorded only when completed, 60 s). "2 minutes of breath"
  is true today.
- The alternative that gives the same "tangible" feeling honestly is the lens (§3.2): "19 evenings this
  month you did something to let the day go."
- If you still want time after this, build it in full: an authored duration for all 102 catalog actions,
  an optional duration on custom actions, and a stated floor ("at least 1 h 20 min"), never an estimate.

---

## 4. Anchors ("After I…")

The best-supported idea near Tiny Habits: implementation intentions, d = 0.65 across 94 tests
(Gollwitzer & Sheeran 2006).

- **Name in code:** `cue`, not `anchor`, because `keepAnchor` already means "your most-done action"
  in `month_plan.dart`.
- **Storage:** actions are stored as titles (`custom_habits`, `pinned_habit` in `onboarding_state.dart`),
  so cues are a title-keyed map (`action_cues`). The rename-safe pattern already exists: "Everything the
  app stores under an action's *title* has to move when the title does" (`test/rename_keyed_stores_test.dart`).
  Add `ActionCues.rename`, include it in backup and export, and add strings to both ARBs.
- **On Today:** one quiet line under the action title, "after coffee", in secondary text.
- **Setting it:** the hold menu offers "Give it a moment: After I…" *before* the swap. That is Fogg's
  order: fix the prompt, then shrink the action, and only then swap it.
- **Choosing a cue:** chips ("pour my coffee", "brush my teeth", "sit down at my desk", "get into bed")
  plus free text.
- **In onboarding:** step 6 below.
- **Later:** anchored against unanchored actions as an observation in "what lifts you". It is
  confounded, so label it as such.

---

## 5. The completion moment: motion, not copy

Today: tap, mood pills, a tile row, "Kept: 13 moments this month", gone about 2.3 s later
(900 ms tile animation plus a 1.4 s hold, `habit_completion_modal.dart:164`).

Proposed choreography (springs, colour and haptics; no confetti, no praise text):

1. **Tap.** The category colour washes across the action card from the finger (ink fill, about 350 ms)
   with a light haptic.
2. **Mood tap.** The chosen pill blooms briefly in the category colour.
3. **The card becomes a tile.** The wash condenses into a rounded square that travels (a shared-element
   flight) into **the month's real mosaic**, not a row: same layout as Insights, and it lands in its true
   position with one spring settle and a selection haptic on contact.
4. **It joins its colour.** Tiles of the same category brighten once, as a ripple outward from the new
   one: this is what it adds to.
5. **The count rolls** 41 → 42, odometer-style.
6. **If it was a return,** the §4.2 glow ring draws around the tile and one line appears: "You came back,
   after 6 quiet days." (`MomentRollup.gapDays` already has it.)
7. Hold about 2.5 s; tap anywhere to leave sooner.

Needs a real device before shipping. Handoff §0 item 3 already flags the landing animation as never
checked on a phone.

---

## 6. Onboarding, step by step

Current flow (verified): Welcome → path list (`TellUsAboutYouScreen`) → "One small promise."
(`CommitmentScreen`) → reminder → `HabitRevealScreen` → app. The paywall comes after the first
completed action (handoff §5.4). Focus areas already default from the path (`defaultFocusAreas`).

New flow: a short book in four parts. The part cards are the "chapters that explain the concept". They
are full-screen onboarding cards, not overlays on the app (CLAUDE.md keeps overlays for the widget). A
four-mark track (I II III IV) sits at the top and fills as you pass each part; that measures the
onboarding, not the person. The reward is the first tile landing.

**0. Welcome** (existing screen, unchanged)

**Part card, I · What you want** (auto-advances in about 1.5 s, or tap)
> Everything here starts with one sentence. Yours.

**1. Pick a direction** (replaces the path list)
Visual: a night sky; the paths are stars. Tapping one brightens it and shows its title and subtitle; the
rest dim.
> **What would you like more of?**
> Pick the closest one. You'll say it your own way next.
Options: the existing path titles and subtitles. "Your own way" becomes the star *Something else*.

**2. Say it your way** (replaces the commitment screen)
> **Say it your way.**
> I want to *[let the day go before I sleep]*
> Chips: *slow down in the evenings* · *stop scrolling in bed* · *sleep a bit earlier*
> Only you see this. You can change it later.
> Button: **Hold to make it yours** (a 1.2 s press, rising haptic; the star flares)

Then the sentence rises and becomes the star:
> **Your first chapter runs until 31 December.**
> At the end, you decide what changed.

**Part card, II · How you'll get there**
> Not by trying hard. By starting small.

**3. Three small things**
> **Start with three small things.**
> Each takes a minute or two. Pick the ones you'd actually do.
Cards come from the path's `starterActions` plus a few from its catalog. A chosen card drops into a tray
labelled *Your first month*. Focus areas show as small chips with a *change* link (no separate screen).

**4. Give each one a moment** (skippable)
> **When will they happen?**
> Tie each one to something you already do.
> After I *[pour my coffee]*, I'll *take 3 slow breaths*.
The sentence assembles as the chips are tapped. Link: *Skip for now*.

**5. A nudge, if you want one**
> **Want a nudge as well?**
> One quiet reminder a day. Or none.
> [ Remind me at 21:30 ] [ No reminders ]

**Part card, III · How it works**
> No streaks. Nothing to break.

**6. Try it**
A mini mosaic with a demo action. Tap it and a tile lands.
> **Every time you do one, a square appears.**
Second beat: a few days pass (a soft fade), then a tile lands with a glow ring.
> **Miss a few days and nothing is lost.**
> When you come back, the app marks the return, not the gap.

**7. What you'll get back** (sets expectations)
> **Every day:** each thing you do lands in your month.
> **Every week:** what happened, in plain words.
> **As the weeks add up:** your patterns. Some take a few weeks to show.
> **At the end of the chapter:** you decide what changed.

**Part card, IV · Your first moment**

**8. Do one now**
> **Do one now.**
> The three actions. Tapping one runs the real completion flow, and the first tile lands in the person's
> own, otherwise empty mosaic.
> **That's the first square of your chapter.**
> Link: *I'll do it later*

**9. Paywall** (existing, after the first moment, per §5.4)
Headline tie-in: **Intended+ reads your chapter and suggests one change a month.**

**Theme picker:** move it to Profile; it doesn't serve the story. (Your call.)

**Cost:** about 9 decisions against about 5 today. Part cards auto-advance, step 4 is skippable and step 6
is one tap. Track each step's completion in `AnalyticsService` so the drop-off is visible, not guessed.

---

## 7. Content cost, concretely

"Stage content" is the text and the suggested actions each stage shows.

**Written per path:**
- *Softer Nights, month 1:* "Start with one thing before bed. Notice which night it's easiest."
- *Month 2:* "Keep the one you reach for. Put it after something you already do each night."
- *Month 3:* "Make it lighter: the smallest version that still helps you sleep."

That is 9 paths × 3 stages × 2 languages = **54 blocks** to write and proofread. The Russian alone needed
five fix commits on 16 August (aaeb753, 319232d, 4ec6944, 504fa97, 3d161e0).

**Generic (recommended):** 3 stage lines × 2 languages = **6 strings**. The specifics come from data
that already exists:
- *Try a few* shows the path's `starterActions`. For Softer Nights: "Screens away 20 minutes before bed",
  "Dim the lights an hour before sleep", "Take 5 deep belly breaths", "Do absolutely nothing for 30 seconds".
- *Keep what stuck* shows the person's own most-done actions from month 1 (computed).
- *Make it lighter* shows the kept action and its cue.

---

## 8. ChatGPT design prompts

Use one conversation. Attach the two current Insights screenshots, paste the **style block** once, then
send **one screen per message**. Image models handle one dense screen far better than a board of ten.

### 8.1 Style block (paste first)

```
You are designing screens for "Intended", an iOS habit app. The attached screenshots are the current
app: match their visual language exactly.

Canvas: iPhone 15, 393×852 pt, portrait, status bar at the top. Output a single realistic screen.

Visual system (from the attached screenshots):
- Background: deep indigo night, #2A2C47 to #2E314B, with faint misty pine silhouettes at the edges
  and very subtle diagonal rain streaks. Calm, dim, never black.
- One large frosted-glass sheet holds the content: fill about #3B3F67 at partial opacity, 32 pt corner
  radius, 1 pt hairline border slightly lighter than the fill. Sections inside the sheet are separated
  by hairline dividers, not separate cards.
- Type: Sora. Page title 34 pt bold; hero line 30 pt; card headline 20 pt semibold; body 15 pt; meta
  13 pt. Section eyebrows are small caps, letter-spaced, lavender (for example "THIS MONTH").
  Text is warm off-white; secondary text is muted lavender-grey.
- Category colours (sampled from the screenshots): Health burnt orange #B15438, Self-care violet #8169B7,
  Mood sage green #647D53, Home ochre #A37539. Tiles are rounded squares (about 12 pt radius) with a soft
  inner gradient, 8 pt gaps. After the last tile there is exactly one faint ghost tile (#454870); never
  draw empty outlines.
- Legend chips: pill outline, a coloured dot, label and count ("Health 16").
- Floating bottom tab bar: a glass pill with three line icons (check, bar chart, person).

Hard rules:
- No streaks, flames, scores, percentages toward a goal, progress bars toward a goal, or countdowns.
- No padlocks. Locked text fades out mid-sentence instead.
- No confetti, trophies, badges or stars-as-rewards.
- No empty slots for days without activity. Days are never the unit; each square is one thing done.
- No em dashes in any text. Use a colon, a full stop or a comma.
- Use the copy given for each screen exactly, and nothing else.
```

### 8.2 Onboarding screens (one message each)

Use the copy from §6 verbatim. Per-screen direction:

```
Screen: Onboarding 1, "Pick a direction". Same background, no glass sheet. A night sky fills the upper
two thirds: nine small stars, loosely arranged like a constellation, each with a short label beneath in
13 pt lavender (Gentle Mornings, Anchors for Hard Days, Quiet Focus, Winding Down, Softer Nights,
Looking Up, Closer to People, Moving a Little, Through a Hard Season) and a tenth, dimmer star labelled
"Something else". "Winding Down" is selected: brighter, with a soft halo, while the others dim to 40%.
Below the sky, a small glass card shows "Winding Down" and "A small ritual for letting the day go".
Top: four tiny marks "I II III IV", with I highlighted. Title near the bottom: "What would you like more
of?" Subtitle: "Pick the closest one. You'll say it your own way next." Primary button: "Continue".
```

```
Screen: Onboarding 2, "Say it your way". The selected star is now centred near the top with a soft halo.
Big 30 pt text: "I want to" followed on the next line by an editable, underlined field containing
"let the day go before I sleep" with a text cursor. Beneath: three outline chips, "slow down in the
evenings", "stop scrolling in bed", "sleep a bit earlier". Meta line: "Only you see this. You can
change it later." Bottom: a wide pill button "Hold to make it yours" with a fill sweeping left to
right, about 60% complete, to show a press-and-hold. Marks "I II III IV" at the top, I highlighted.
```

```
Screen: Onboarding 3, "Three small things". Title "Start with three small things." Subtitle "Each takes
a minute or two. Pick the ones you'd actually do." Six action cards in a 2-column grid, each a glass
tile with a category-colour dot and a label: "Screens away 20 minutes before bed", "Dim the lights an
hour before sleep", "Take 5 deep belly breaths", "Do absolutely nothing for 30 seconds", "Take 3 slow
breaths", "Write one line about today". Three are selected, with a category wash and a check. At the
bottom a tray labelled "Your first month" holds three small coloured tiles. Small chips "Health" and
"Self-care" with a "change" link. Marks: II highlighted.
```

```
Screen: Onboarding 4, "When will they happen?" Title "When will they happen?" Subtitle "Tie each one to
something you already do." Three glass rows, each a sentence: "After I [pour my coffee], I'll take 3
slow breaths." The bracketed part is a violet pill. The second row's pill is empty and focused, with
chips below it: "brush my teeth", "sit down at my desk", "get into bed", "Other". Link at the bottom:
"Skip for now". Marks: II highlighted.
```

```
Screen: Onboarding 6, "Try it". Centre: a small glass sheet with a mosaic of 5 tiles (orange, violet,
green, violet, orange) and one ghost tile; a sixth violet tile is mid-flight, landing with a soft glow.
Title "Every time you do one, a square appears." Below, smaller: "Miss a few days and nothing is lost.
When you come back, the app marks the return, not the gap." One tile carries a thin glowing ring.
Marks: III highlighted.
```

```
Screen: Onboarding 8, "Do one now". Title "Do one now." Three action cards stacked; the top one is
pressed, with a violet wash spreading from the touch point. Below, the person's own mosaic: one violet
tile, freshly landed with a glow, and one ghost tile. Caption under it: "That's the first square of
your chapter." Link: "I'll do it later". Marks: IV highlighted.
```

For the part cards (I–IV), one message is enough:

```
Screen: an onboarding part card. Full-bleed background only. Centred: a large Roman numeral "II" in Sora
at 64 pt, low-opacity lavender; beneath it "How you'll get there" at 30 pt; beneath that, in 17 pt
muted text, "Not by trying hard. By starting small." Nothing else on screen.
```

### 8.3 Insights screens (one message each)

```
Screen: Insights, "This week". Top: an eyebrow "CHAPTER 1 · UNTIL 30 NOVEMBER"; below it the sentence
in 26 pt, in quotes: "I want to let the day go before I sleep." Below that, a three-part calendar track:
three rounded segments labelled "Sep · Try a few" (highlighted), "Oct · Keep what stuck" and
"Nov · Make it lighter" (dim). It marks position in time only and must not look like a progress bar.
Below, a segmented control: "This week" (selected), "This month", "Over time".
Then one glass sheet with hairline-separated rows, each ending in a small chevron:
1. Eyebrow "THIS WEEK". Headline: "5 evenings this week, you did something to let the day go."
   A single row of 11 small tiles in category colours, then "11 small things".
2. A small tile with a glowing ring, then "You came back on Tuesday, after 2 quiet days."
3. "Most reached for: Take 3 slow breaths, 4 times. You were glad you did, 3 times."
4. Two small violet circles with a dot in the centre, then "2 minutes of breath. Afterwards you said:
   a little calmer."
5. Eyebrow "YOUR SEPTEMBER PLAN". "On 1 September you moved your reminder to 21:30."
Floating tab bar at the bottom, middle icon active.
```

```
Screen: Insights, "Over time". The same chapter header and segmented control, with "Over time" selected.
One glass sheet of rows, each with an eyebrow, a value, a status pill on the right ("Ready" in
off-white, or "Forming" in muted lavender) and a chevron:
1. YOUR SEASON: "Continuous", Ready. "No quiet stretch of two days or more all month."
2. WHEN YOU SHOW UP: "Evenings", Ready. "31 of your 42 moments came after 6 pm."
3. COMING BACK: "1 return so far", Forming. "The trend shows after 3."
4. WHAT LIFTS YOU: "Take 3 slow breaths", Forming. "Glad you did it 4 times out of 7. Ready in about
   3 weeks."
5. YOUR MONTHS: "August: Evening".
```

```
Screen: Insights deep-dive sheet for the season "Continuous". A bottom sheet over the dimmed Insights
page, with a grabber. Eyebrow "YOUR SEASON · SEPTEMBER". Title "Continuous" at 30 pt.
"What it means" (meta), then: "You didn't go quiet for two days or more at any point this month."
"The evidence" (meta), then two facts in large numerals with small captions: "24 different days you did
something" and "1 day, your longest quiet stretch".
"Why this word" (meta): four horizontal lines, each with both ends labelled in 13 pt and a small glowing
marker: Morning to Evening (marker far right), Steady to Bursts (marker left of centre), Returning to
Continuous (marker at the far right, brightest, labelled "strongest"), Focused to Wandering (marker
near the centre). Caption: "Your month is named after the line it leaned on hardest."
Footer row: "August: Evening" with a chevron.
```

```
Screen: Insights deep-dive sheet for the plan. Eyebrow "YOUR SEPTEMBER PLAN". Title "Reminder at 21:30".
"What you chose": "On 1 September you moved your reminder to 21:30."
"Why it was suggested": "In August, 18 of your 39 moments came after 21:00."
"Since then": a quiet two-bar comparison labelled "26 days before: 14" and "26 days since: 22", no axes.
Two buttons: "Keep it" (filled) and "Undo" (outline).
```

A third prompt for the completion motion (§5) is best done as a storyboard: "six frames left to right
showing…" plus the §5 steps.

---

## 9. Build order

1. **Plan says what you chose; chevrons and deep-dive sheets for season and plan** (§3.5, §3.6). This is
   the answer to "a month paid and I don't see the value".
2. **This week and the lens** (§3.2, §3.3).
3. **Completion motion** (§5), on a device.
4. **Sentence, chapters and the new onboarding** (§1, §2, §6).
5. **Cues** (§4), which can ship with onboarding step 4.
6. **Year view** (§2.4), in November.

Every new string goes into both ARBs, then `flutter gen-l10n`. Russian display type uses Montserrat.

## Sources

- Gollwitzer & Sheeran 2006, implementation intentions meta-analysis: https://www.researchgate.net/publication/37367696
- Harkin et al. 2016, monitoring goal progress: https://eprints.whiterose.ac.uk/id/eprint/87431/
- Amabile & Kramer 2011, the power of small wins: https://hbr.org/2011/05/the-power-of-small-wins
- Dai, Milkman & Riis 2014, the fresh start effect: https://pubsonline.informs.org/doi/10.1287/mnsc.2014.1901
- Breines & Chen 2012, self-compassion and self-improvement motivation: https://journals.sagepub.com/doi/abs/10.1177/0146167212445599
- Fogg, Behavior Design steps: https://www.shortform.com/blog/steps-to-achieving-goals/
