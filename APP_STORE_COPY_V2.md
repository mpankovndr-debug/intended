# App Store copy — v2

Ships **with** the v2 submission. Description and promotional text are both version metadata, so writing them now costs nothing and writing them later costs a review cycle.

---

## Promotional text (170 max)

The only field you can change any day without a new build. Two options.

**A — evergreen. 165 characters.**

```
Nine days away, and it asks for one small thing — not an apology. Four small actions a day. Nothing breaks, nothing resets. It counts how many times you came back.
```

**B — for the v2 launch, then swap back to A. 160 characters.**

```
New: your month, read back to you. A mosaic of everything you did, a season word for who you were, and a letter that ends in a question. Still nothing to break.
```

Start with **A**. It carries the differentiator, and it's the line a stranger remembers.

---

## Description

Opens on the hook rather than restating the subtitle — the old version's first sentence duplicated the line directly above it, spending the only three lines most people read.

```
No streaks to protect. No scores to chase. No guilt when life gets in the way.

Intended counts something else: how many times you came back.

Every small thing you do becomes a square, and the squares only ever grow. There is no empty slot for a day you missed, because days aren't the unit. Go quiet for a week and nothing resets — come back, and the app notices that instead.

HOW IT WORKS
- Choose an intention: Gentle Mornings, Winding Down, Through a Hard Season, and six more. Or build your own.
- Four small actions sit underneath it. Swap any of them, or add your own.
- Tap one when you've done it, and say how it landed — glad I did, neutral, took effort.
- That's the whole thing. There is nothing to maintain.

YOUR MONTH, READ BACK TO YOU
- A mosaic of everything you did, coloured by focus area
- How many times you went quiet, and how many times you came back
- A season word for the month — Evening, Steady, Returning — drawn from what actually happened. Never a fixed personality, and it's different next month.

WHEN LIFE GETS IN THE WAY
- Disappear for a while and Intended doesn't scold you. It clears the screen down to one action and asks whether today might be the day.
- Forgot to log yesterday? Add it.
- This part is free, and always will be. Someone who's been away for nine days needs a way back most, and is least likely to be paying for one.

INTENDED+
- A letter about your month — four lines, ending in a question rather than a comfort
- Next month's plan, built from what actually happened, with an honest answer to whether the last change worked
- A quiet word before you drift, while the week can still change
- What actually lifts you: which of your actions you're glad you did, and which you aren't
- Your season explained, and every past season kept
- Ten themes including dark mode, home and lock screen widgets, and custom app icons

Eight focus areas to draw from: Health, Mood, Self-care, Productivity, Relationships, Creativity, Home & organization, Finances.

Your moments are yours — export them whenever you like.

Built by one person who cares about this as much as you do.

Terms of Use: https://intendedapp.com/terms
```

---

## What changed, and why

**Cut — these were false or off-brand:**

| Removed | Reason |
|---|---|
| "Unlimited habits, swaps, and focus areas" | Handoff §8: *"cut entirely — it contradicts the entire brand."* Still live in the current listing. |
| "All curated packs" under INTENDED+ | §7 made every intention free. Selling them as premium is now untrue. |
| "Try curated packs like Gentle Mornings…" | Packs became adoptable intentions; the store was killed. |
| "Gentle weekly reflections" | Replaced by the month page — mosaic, season, letter, plan. |
| "An app that celebrates showing up, not showing off" | *Celebrates* is congratulatory, which the voice rules exclude. It's also a slogan about the app rather than a statement about the reader. |
| The opening sentence | It repeated the subtitle verbatim, two inches below it. |

**Added — built in v2 and absent from the current description:**

the mosaic and what makes it different from every other grid · returns ("how many times you came back") · seasons · the letter · the monthly plan and its did-it-work proof · the drift warning · what actually lifts you · the free rescue screen · retroactive logging · data export

**Kept:** the scannable ALL-CAPS section structure, the eight focus areas, "Built by one person", and the terms link.

**The one deliberate risk:** the free-rescue paragraph explains *why* it's free. Most listings don't argue with themselves like that. It's the most trust-building sentence available to you, and no competitor can copy it without changing their pricing.

---

## Character counts, measured

| Field | Limit | This copy |
|---|---|---|
| Promotional text A | 170 | **165** |
| Promotional text B | 170 | **160** |
| Description | 4,000 | **2,179** |

Counted with `wc -m`, not by eye — Apple counts characters, and the em dashes are one character each but three bytes, which is what makes hand-counting go wrong.

## Checked before writing

- **8 focus areas** — confirmed in `app_en.arb`: Health, Mood, Productivity, Home & organization, Relationships, Creativity, Finances, Self-care.
- **9 intentions + Your Own Way** — confirmed: Gentle Mornings, Anchors for Hard Days, Quiet Focus, Winding Down, Softer Nights, Looking Up, Closer to People, Moving a Little, Through a Hard Season, plus Your Own Way.
- **Season words** — Evening, Steady and Returning are real axis ends per handoff §4.4, and Evening appears in your own screenshots.
- **Ten themes, two dark** — handoff §11.
- **Export** — "JSON export lives in the profile", handoff launch flags.

Every claim above corresponds to something that exists. Nothing here describes a feature you'd have to build to make the sentence true.
