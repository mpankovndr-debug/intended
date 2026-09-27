# Intended: North star, chapters, and an Insights page worth opening

Design spec, September 2026. Written from a design conversation; nothing here is built yet.

Code references point at `origin/fix/trial-length-and-stale-prices`, the branch the device build runs.
`main` is 35 commits behind it (Pause, the season rewrite, the store copy), so read the code there, not on `main`.

**Decided (27 Sep):** build on `fix/trial-length-and-stale-prices` (going into `main`); the 14-day start
rule, with a short first month asking for less (§2.1); no "hours for yourself" figure (§3.7); the theme
picker moves to Profile; no night sky or stars in onboarding, because the North star is a metaphor, not
a visual.

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

**A short first month asks for less.** Under the 14-day rule, month 1 runs 14 to 31 days, or 31 to 44
when the leftover days fold in.
- **Under 21 days:** onboarding suggests two actions, not three, and says why: "You have 16 days until
  October, so start with two." Fewer actions means each one gets enough tries to be read fairly at the
  first plan. (21 is a starting value; tune it.)
- **The first plan scales its thresholds** to the days month 1 actually had. A set-aside nudge tuned for
  30 days must not fire on 16 (CLAUDE.md: thresholds are set by the sentence). Pure static, unit-tested.
- **Too short or too thin to read:** month 2 stays *Try a few* and says so plainly: "Sixteen days isn't
  long enough to tell what stuck. October is for trying too."
- The sentence and the end date don't change.

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

### 3.7 "Hours for yourself": dropped

Decided against: no action has a recorded duration, and an estimate would need "it's an indication" on
every render. The lens (§3.2) carries the same "in real life" feeling from data that exists. Pause
minutes stay, because they are measured.

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
Visual: a vertical stack of wide glass cards, each tinted with its path's own `accentColor` and a small
line icon. The chosen card brightens and gains a soft glowing edge; the rest stay quiet. No stars or
night sky: the North star is a metaphor, not a picture.
> **What would you like more of?**
> Pick the closest one. You'll say it your own way next.
Options: the existing path titles and subtitles. "Your own way" becomes *Something else*.

**2. Say it your way** (replaces the commitment screen)
> **Say it your way.**
> I want to *[let the day go before I sleep]*
> Chips: *slow down in the evenings* · *stop scrolling in bed* · *sleep a bit earlier*
> Only you see this. You can change it later.
> Button: **Hold to make it yours** (a 1.2 s press with a rising haptic; the fill completes and glows)

Then the sentence settles at the top of the screen:
> **Your first chapter runs until 31 December.**
> At the end, you decide what changed.

**Part card, II · How you'll get there**
> Not by trying hard. By starting small.

**3. Three small things**
> **Start with three small things.**
> Each takes a minute or two. Pick the ones you'd actually do.
> (When month 1 is under 21 days: **Start with two small things.** You have 16 days until October, so
> start with two.)
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

**Theme picker:** moves to Profile (decided); it doesn't serve the story.

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

## 8. ChatGPT concept prompts

Concepts to see the direction, not final designs. Open a new ChatGPT chat, attach the two Insights
screenshots **and one of Today**, paste the setup once, then send **one prompt per message**. Image
models handle one screen far better than a board of ten, and asking for two variations gives you
something to compare.

### Setup (paste first, with the screenshots attached)

```
I'm redesigning screens for Intended, a calm iOS habit app. The attached screenshots are the current
app. Keep its look: deep indigo night background with faint misty pines, one frosted-glass sheet per
screen, Sora type, lavender small-caps labels, rounded-square tiles in four category colours (orange
Health, violet Self-care, sage Mood, ochre Home). iPhone portrait, a realistic UI mockup, not an
illustration.
Never draw: streaks, flames, scores, progress bars toward a goal, countdowns, padlocks, confetti,
trophies, empty squares for missed days, or em dashes.
I'll send one screen per message. For each, show two variations side by side, and use my text exactly.
```

### Today

```
Today screen. Top: small date "Saturday, 27 September", then a large line "Letting the day go".
Under it a thin line of warm light with the words "a minute of breath" (it opens a breathing
exercise). Then four glass action cards:
1. "Take 3 slow breaths" with a small grey line "after I pour my coffee". Done: a very pale violet
   wash and a tiny row of 4 violet tiles at the right edge. Not grey, no strikethrough.
2. "Dim the lights an hour before sleep", line "after dinner". Pending: a thin orange bar on the left.
3. "Write one line about today". Pending, no second line.
4. "Stretch for one minute", line "when I get into bed". Pending.
At the bottom, a quiet line with a small plus: "Add something of your own". Floating glass tab bar.
```

```
A storyboard of four phone frames, left to right, showing one tap on Today:
1. A finger taps "Take 3 slow breaths" and a violet wash spreads across the card from the touch point.
2. A bottom sheet asks "How was it?" with three pills: "Glad I did" (chosen, glowing), "Neutral",
   "Took effort".
3. The card has shrunk into one violet rounded-square tile, flying into the month's mosaic (five rows
   of coloured tiles) inside the sheet; the other violet tiles brighten slightly.
4. The tile has landed in the next free spot with a soft glow and a thin ring around it. Under the
   mosaic: "42 small things this month" and, smaller, "You came back, after 3 quiet days."
```

### Insights

```
Insights screen, "This week". Top: small caps "CHAPTER 1 · UNTIL 30 NOVEMBER", then in quotes, large:
"I want to let the day go before I sleep." Under it three small segments in a row: "Sep · Try a few"
(lit), "Oct · Keep what stuck" and "Nov · Make it lighter" (dim). They show where you are in time and
must not look like a progress bar. Then a segmented control: "This week" (selected), "This month",
"Over time". One glass sheet, rows split by hairlines, each ending in a chevron:
"5 evenings this week, you did something to let the day go." above a single row of 11 small tiles.
"You came back on Tuesday, after 2 quiet days." beside one tile wearing a glowing ring.
"Most reached for: Take 3 slow breaths, 4 times."
"2 minutes of breath. Afterwards: a little calmer."
"Your plan: on 1 September you moved your reminder to 21:30."
```

```
Insights screen, "Over time". Same header, with "Over time" selected. Rows, each with a small status
pill on the right ("Ready" bright, "Forming" muted) and a chevron:
YOUR SEASON: "Continuous", Ready. "No quiet stretch of two days or more all month."
WHEN YOU SHOW UP: "Evenings", Ready. "31 of your 42 moments came after 6 pm."
COMING BACK: "1 return so far", Forming. "The trend shows after 3."
WHAT LIFTS YOU: "Take 3 slow breaths", Forming. "Glad you did it 4 of 7 times. Ready in about 3 weeks."
```

```
A bottom sheet opened by tapping "Continuous" on Insights. Title "Continuous". Text: "You didn't go
quiet for two days or more at any point this month." Two large numbers with small captions: "24" /
"days you did something" and "1" / "day, your longest quiet stretch". Then four thin horizontal lines,
each with a word at both ends (Morning and Evening, Steady and Bursts, Returning and Continuous,
Focused and Wandering) and a small glowing dot showing where September sat; the Continuous dot is
the brightest. Caption: "Your month is named after the line it leaned on hardest."
```

### Onboarding

The flow borrows three well-known patterns (from memory of these apps, not checked this session):
- **One question per screen, big calm type**, as Headspace and Calm do.
- **Questions interleaved with full-screen cards that teach the idea**, Noom's pattern. This is where
  the "chapters that explain the concept" go.
- **A plan you seal yourself**, as in Fabulous's signed contract. Here it's the "hold to make it yours"
  button.

Take the mechanics, not their aesthetic, the same lesson as commit d278169.

```
Onboarding, step 1. No glass sheet, just the background. A thin four-part indicator at the very top,
first part lit. Title: "What would you like more of?" Subtitle: "Pick the closest one. You'll say it
your own way next." A vertical stack of wide glass cards, each softly tinted in its own colour with a
small line icon: "Gentle Mornings · A soft, intentional way to start the day", "Winding Down · A small
ritual for letting the day go" (selected: brighter, glowing edge, a check), "Softer Nights · For sleep
that doesn't fight you", "Quiet Focus · Get things done without the burnout", "Something else".
No stars, no night sky.
```

```
Onboarding, step 2. Calm and mostly empty. Large text in the middle: "I want to", and on the next line,
underlined and editable with a cursor: "let the day go before I sleep". Three small outline chips below:
"slow down in the evenings", "stop scrolling in bed", "sleep a bit earlier". A small grey line: "Only
you see this. You can change it later." At the bottom, a wide pill button "Hold to make it yours" with
its fill sweeping left to right, about half full.
```

```
Onboarding explainer card, shown between steps. Only the background and centred text: a small "II" in
lavender, the line "How you'll get there" large, and under it "Not by trying hard. By starting small."
The four-part indicator at the top, second part lit.
```

```
Onboarding, step 3. Title: "Start with two small things." Subtitle: "You have 16 days until October,
so start with two." Six glass action cards in two columns: "Screens away 20 minutes before bed", "Dim
the lights an hour before sleep", "Take 5 deep belly breaths", "Do absolutely nothing for 30 seconds",
"Take 3 slow breaths", "Write one line about today". Two are chosen (a colour wash and a check).
A tray at the bottom labelled "Your first weeks" holds two small tiles.
```

```
Onboarding, "Try it". A small glass sheet in the middle holds a mosaic of 5 coloured tiles and one
faint ghost tile; a sixth violet tile is landing with a soft glow, and one earlier tile has a thin
glowing ring. Above: "Every time you do one, a square appears." Below: "Miss a few days and nothing is
lost. When you come back, the app marks the return, not the gap." A demo card "Take 3 slow breaths"
with a gently pulsing "Tap to try".
```

```
Onboarding, the last step before the paywall. Title "Do one now." Three action cards; the top one is
mid-tap with a violet wash. Below, an otherwise empty glass sheet holding exactly one fresh violet tile
with a glow, and one faint ghost tile after it. Caption: "That's the first square of your chapter."
Small link: "I'll do it later".
```

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
