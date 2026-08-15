# Working on Intended

Rules earned the hard way. Each one names the bug that produced it, because a
rule without its scar gets argued away.

The full reasoning lives in `INTENDED_V2_HANDOFF_2026-08.md` — this file is
the part you must not violate without deciding to.

---

## What this app is

A gentle habit app whose primary object is an **intention**, not a checklist.
Habits are *actions* under it; completions are *moments* — evidence you're
living it. The month is a mosaic of moments, and the app reads that month back
to you.

Free says **what happened**. Paid says **what to do about it**. That line
decides every feature placement; if you can't say which side something is on,
it isn't designed yet.

---

## Product rules

**Never state a finding you haven't computed.** The teaser once claimed "the
gap between the focus you chose and the one you actually lived" with nothing
calculating it — false for anyone whose focus matched. Every sentence that
asserts something must be backed by the thing it asserts, or not render.

**Silence beats filler.** Drift, the letter, the plan, what-lifts-you all
return `null` when they have nothing honest to say, and their card simply
isn't on the screen. Never ship a section that exists to restate a promise:
"After a few weeks we'll show you…" is the failure this replaced.

**Absence is unrepresentable.** The grid indexes by *moment*, never by date —
cell 1 is your first moment, cell 47 your forty-seventh. There is no cell for
a skipped Tuesday because days are not the unit. Never render empty slots,
never outline them, never let a filter empty the grid (dim to 0.38, don't
remove). A bounded grid of empty squares is "look how much you haven't done."

**No streaks, no scores, no denominators.** "Health — 9 moments across 7 days"
is fact. "7 of 12 days" is a target wearing a fact's clothes. Gaps are shown
as *returns*, never absences.

**Observation, never assessment.** "You come back most often in the evenings",
not "you are an evening person". Warm without being congratulatory — "and you
did them anyway" is praise, cut it.

**Every paid insight ends in a button that changes something.** A mirror
doesn't justify a subscription. This is why §6.2's "lighter on Wednesdays"
nudge doesn't exist: there's no setting behind it, so accepting would change
nothing.

**Never paywall the rescue.** Gap detection, the gentle notification after
silence, and the reduced home screen are free forever. Someone who's
disappeared for nine days needs help most and subscribes least.

**Fade, never padlock.** A lock is a hard metal object in a world of mist —
the only element that looks borrowed from another app. Locked content shows
real text dissolving mid-sentence.

**One decision per month.** The plan shows one suggestion under YOUR ACTIONS
and one under YOUR RHYTHM. Four items with four buttons is a dashboard
demanding optimisation — the exact pressure this app removes.

**Discovery happens inline, next to the thing.** Overlays and coach marks are
reserved for what lives *outside* the app (the widget). The legend chips teach
their own tap with a caption in the grid's own voice, shown until first use.

---

## Data rules

**Always read the wall clock from the moment's own recorded offset.** Use
`Moment.localWallClock` / `Moment.localDay`. Never `DateTime.now()`, never
`.toLocal()`, never the device's current zone.
*Scar:* `momentsForMonth` added the anchor's offset to an already-local
anchor. Every user west of UTC saw the previous month's data for a whole
month, and seasons froze into the archive under the wrong key — permanently,
since closed seasons are never recomputed.

**`localHour` and `localWeekday` are stored, not derived.** A UTC timestamp
doesn't record what the user's clock said. These cannot be backfilled.

**Never truncate a user's list at render.** Cap at the *add* path and say so
out loud when it's full.
*Scar:* `visibleHabits` did `.take(4)`, so adding a custom pushed a habit the
user had been completing out of sight — still in storage, still recorded,
reachable from nowhere in the app.

**Static caches must refresh on write.**
*Scar:* `ReflectionService` loaded the custom-habit → focus-area map once at
launch. Any custom made mid-session recorded `category: null` — a grey square,
absent from the legend, matched by no colour chip.

**Dart's `sort` is not stable.** Any ranking needs an explicit tiebreak.
*Scar:* the plan could offer a different decision on each visit when two
nudges tied on confidence.

**Seasons are immutable once a month closes.** A season that changes
retroactively destroys "this is who I was in September" — and that permanence
is what makes the archive worth paying for.

---

## Code rules

**Nothing new goes in `main.dart`.** It's ~6,900 lines. Every screen, widget,
model and service added since v2 lives in its own file; keep it that way. When
extracting, go safest-first: `_RescueCard`, then `_HabitCard`, then the modal
sheets — one per commit, suite green between each, never during a launch week.

**Resolvers live on the model, not in screens.**
*Scar:* `titleKey` → localised string was switch-copied into six screens.
Adding five paths shipped `pathSofterNightsTitle` raw to users, because three
of those copies were missed.

**Logic that needs a `BuildContext` can't be tested — so don't put logic
there.** Extract the rules as a pure static and test that.
*Scar:* the widget catch-up's entire selection policy (source, 48-hour window,
ordering, cap) sat inside a method requiring a Navigator. Zero coverage.

**A `mounted` check is not a route check.** Before popping after an `await`,
verify `ModalRoute.of(context)?.isCurrent == true` — a State stays mounted for
the whole exit transition, so a late pop lands on the route *below*.

**Prefer `null` returns over empty states** in every model that feeds a card.

---

## Copy & localization

**Russian speaks «ты» everywhere.** The v2 strings once mixed «вы» into a
«ты» app; a native reader feels it instantly.

**Russian needs real ICU plurals** — `one` / `few` / `many` / `other`.
"{count} раза" is wrong for 5+.

**Sora has no Cyrillic.** Use Montserrat for Russian display type. Tofu boxes
shipped into a store screenshot once already.

**Per-locale phrasing beats shared placeholders.** English says "on Friday";
Russian can't put a nominative weekday there, so it names the date. Pass both
and let each ARB use what its grammar allows.

**Plain language beats clever.** "You did 37 small things for yourself in
August", not "37 moments." A cold reader who says "I've no idea what this
means" after three seconds is the test.

**Thresholds are set by the sentence, not the other way round.** "Most of the
month was X" requires X to actually be most of it. If you loosen a threshold,
change the copy too.

---

## Before you commit

1. `flutter analyze` — **0 errors, 0 warnings** (the ~600 `withOpacity` infos
   are pre-existing).
2. `flutter test` — all green.
3. Every new user-facing string exists in **both** `app_en.arb` and
   `app_ru.arb`, then `flutter gen-l10n`.
4. **Get eyes on new surfaces.** Tests never caught a single design failure in
   this project — muddy washes, cramped bars, inverted hierarchy, invisible
   cards all passed every automated check. Contrast tests prove legibility,
   not meaning.

## Before you ship

- Bump `version:` in `pubspec.yaml` — App Store Connect rejects duplicates.
- `flutter build ipa --release`, then upload the `.ipa` via Transporter.
- Verify the claim before you make it. Twice in review I called something a
  bug that wasn't, and once the reverse. Read the code, then speak.

---

## Two things worth carrying forward

**The tests never caught the design failures.** Get a human looking at any new
surface early.

**Check whether a sentence is true before shipping it.** Any copy that states
a finding needs the finding.
