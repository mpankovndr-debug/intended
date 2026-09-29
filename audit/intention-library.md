# Seeded intention library — audit

*Audit of `OnboardingState.habitsByCategory` — `lib/onboarding_v2/onboarding_state.dart:147`.*
*English source strings only. Read-only: no code or content was changed.*

## Scope and two naming notes

**What was audited.** `habitsByCategory` is the single seeded library in the repo — 98 unique
English strings across 8 focus areas. It is the only definition; every other file
(`main.dart`, `reflection_service.dart`, `widget_service.dart`, `milestone_service.dart`,
`curated_pack.dart`, `intention_path.dart`) reads from it or references its strings.

**Note 1 — "intention" vs. what these are.** In this codebase an *intention* is the
path phrase (`IntentionPath.phraseFor`, 10 strings). The 98 items below are what the code
calls habits/actions — the things done *under* an intention. They are what the requested
columns (focusArea, path affinity) and axes (effort floor, opening verb, requires-a-person)
actually describe, so they are what this audit covers.

**Note 2 — there is no `pathAffinity` field.** `grep -rn "pathAffinity"` over the repo
returns nothing. The column is derived, and marks two different relationships:

- **Bold** = *seeded*. The path names this exact action in `IntentionPath.starterActions`
  and always gives it. 5 paths × 4 actions = **20 of 98** items.
- Plain = *pool*. The path lists this item's focus area in `defaultFocusAreas`; the item is
  one candidate among the area's pool, from which 2 are drawn at random
  (`generateUserHabits`, `onboarding_state.dart:374`). Focus areas are user-editable, so
  pool affinity is a default, not a guarantee.
- `—` = no path defaults to this focus area at all.

Path codes: `GM` gentleMornings · `AH` anchorsForHardDays · `QF` quietFocus · `WD` windingDown ·
`SN` softerNights · `LU` lookingUp · `CP` closerToPeople · `ML` movingALittle · `HS` throughAHardSeason.
(`yourOwnWay` is excluded from the picker and has no focus areas.)

**Ids** are assigned by this audit for reference only. The library has no id field — the
English string *is* the key, in `habit_l10n.dart`, in `CuratedPack.habitIds`, in
`starterActions`, and in SharedPreferences.

---

## The library

| id | focusArea | pathAffinity | text | chars |
|---|---|---|---|---|
| HE-01 | Health | GM·WD·SN·ML | Drink a glass of water | 22 |
| HE-02 | Health | GM·WD·SN·ML | Take 3 slow breaths | 19 |
| HE-03 | Health | **ML** | Stretch for 10 seconds | 22 |
| HE-04 | Health | **ML** | Stand up and roll your shoulders | 32 |
| HE-05 | Health | **LU** | Step outside for 30 seconds | 27 |
| HE-06 | Health | GM·WD·SN·ML | Close your eyes for 20 seconds | 30 |
| HE-07 | Health | GM·WD·SN·ML | Do 5 gentle neck rolls | 22 |
| HE-08 | Health | **ML** | Walk to the window and back | 27 |
| HE-09 | Health | **SN** | Take 5 deep belly breaths | 25 |
| HE-10 | Health | GM·WD·SN·ML | 2-minute body scan | 18 |
| HE-11 | Health | **ML** | 10 minutes of gentle movement | 29 |
| HE-12 | Health | GM·WD·SN·ML | Eat one meal mindfully | 22 |
| HE-13 | Health | **SN** | Screens away 20 minutes before bed | 34 |
| MO-01 | Mood | AH·WD·LU·CP·HS | Ten-second pause | 16 |
| MO-02 | Mood | AH·WD·LU·CP·HS | Notice one thing you feel | 25 |
| MO-03 | Mood | AH·WD·LU·CP·HS | One grounding breath | 20 |
| MO-04 | Mood | **LU** | Look away from your screen for 10 seconds | 41 |
| MO-05 | Mood | AH·WD·LU·CP·HS | Name three things you can see | 29 |
| MO-06 | Mood | AH·WD·LU·CP·HS | Notice one sound around you | 27 |
| MO-07 | Mood | AH·WD·LU·CP·HS | Feel your feet on the ground | 28 |
| MO-08 | Mood | **HS** | Place hand on heart for a moment | 32 |
| MO-09 | Mood | AH·WD·LU·CP·HS | Notice one thing you're grateful for | 36 |
| MO-10 | Mood | AH·WD·LU·CP·HS | Smile gently at yourself | 24 |
| MO-11 | Mood | AH·WD·LU·CP·HS | Ask yourself "what do I need right now?" | 40 |
| MO-12 | Mood | **HS** | Give yourself permission to rest | 32 |
| MO-13 | Mood | **LU** | One meal without your phone | 27 |
| PR-01 | Productivity | GM·QF·LU | Set one priority | 16 |
| PR-02 | Productivity | GM·QF·LU | Plan tomorrow in one sentence | 29 |
| PR-03 | Productivity | GM·QF·LU | Do a 30-second reset | 20 |
| PR-04 | Productivity | GM·QF·LU | Write down one idea | 19 |
| PR-05 | Productivity | GM·QF·LU | Finish one tiny task | 20 |
| PR-06 | Productivity | GM·QF·LU | Declutter your desk for 2 minutes | 33 |
| PR-07 | Productivity | GM·QF·LU | Review your calendar | 20 |
| PR-08 | Productivity | **LU** | Turn off one notification | 25 |
| PR-09 | Productivity | GM·QF·LU | Close one browser tab | 21 |
| PR-10 | Productivity | GM·QF·LU | Archive 5 old emails | 20 |
| PR-11 | Productivity | GM·QF·LU | Update one to-do item | 21 |
| HO-01 | Home & organization | — | Tidy one small thing | 20 |
| HO-02 | Home & organization | — | Put one thing back where it belongs | 35 |
| HO-03 | Home & organization | — | Wipe one surface | 16 |
| HO-04 | Home & organization | — | Open a window for fresh air | 27 |
| HO-05 | Home & organization | — | Make your bed | 13 |
| HO-06 | Home & organization | — | Clear one shelf | 15 |
| HO-07 | Home & organization | — | Wash 3 dishes | 13 |
| HO-08 | Home & organization | — | Take out one small bag of trash | 31 |
| HO-09 | Home & organization | — | Fold 3 items of clothing | 24 |
| HO-10 | Home & organization | — | Organize one drawer | 19 |
| HO-11 | Home & organization | — | Water one plant | 15 |
| HO-12 | Home & organization | — | Light a candle | 14 |
| RE-01 | Relationships | **CP** | Send one message to someone | 27 |
| RE-02 | Relationships | **CP** | Think of one person you appreciate | 34 |
| RE-03 | Relationships | **CP** | Ask someone how they are | 24 |
| RE-04 | Relationships | CP | Give one genuine compliment | 27 |
| RE-05 | Relationships | CP | Call someone you care about | 27 |
| RE-06 | Relationships | CP | Share something that made you smile | 35 |
| RE-07 | Relationships | CP | Thank someone today | 19 |
| RE-08 | Relationships | CP | Listen without planning your response | 37 |
| RE-09 | Relationships | **CP** | Reach out to someone you miss | 29 |
| RE-10 | Relationships | CP | Tell someone what they mean to you | 34 |
| RE-11 | Relationships | CP | Offer help to someone | 21 |
| RE-12 | Relationships | CP | Celebrate someone else's win | 28 |
| CR-01 | Creativity | — | Write one sentence | 18 |
| CR-02 | Creativity | — | Doodle for 10 seconds | 21 |
| CR-03 | Creativity | — | Capture one idea | 16 |
| CR-04 | Creativity | — | Notice one beautiful thing | 26 |
| CR-05 | Creativity | — | Take one photo of something you like | 36 |
| CR-06 | Creativity | — | Draw one simple shape | 21 |
| CR-07 | Creativity | — | Hum a tune you enjoy | 20 |
| CR-08 | Creativity | — | Rearrange something small | 25 |
| CR-09 | Creativity | — | Try one new word | 16 |
| CR-10 | Creativity | — | Create one tiny thing | 21 |
| CR-11 | Creativity | — | Play with one creative medium | 29 |
| CR-12 | Creativity | — | Imagine one possibility | 23 |
| FI-01 | Finances | — | Check your balance | 18 |
| FI-02 | Finances | — | Move €1 to savings | 18 |
| FI-03 | Finances | — | Review one subscription | 23 |
| FI-04 | Finances | — | Note one expense | 16 |
| FI-05 | Finances | — | Read one financial tip | 22 |
| FI-06 | Finances | — | Delete one old receipt | 22 |
| FI-07 | Finances | — | Update one budget category | 26 |
| FI-08 | Finances | — | Review one bill | 15 |
| FI-09 | Finances | — | Price-check one item before buying | 34 |
| FI-10 | Finances | — | Wait 24 hours before one purchase | 33 |
| FI-11 | Finances | — | Celebrate one money win | 23 |
| FI-12 | Finances | — | Set one small savings goal | 26 |
| SC-01 | Self-care | AH·QF·SN·ML·HS | Sit still for 10 seconds | 24 |
| SC-02 | Self-care | AH·QF·SN·ML·HS | Do one kind thing for yourself | 30 |
| SC-03 | Self-care | **HS** | Drink water slowly | 18 |
| SC-04 | Self-care | AH·QF·SN·ML·HS | Stretch your neck | 17 |
| SC-05 | Self-care | AH·QF·SN·ML·HS | Take one slow breath | 20 |
| SC-06 | Self-care | AH·QF·SN·ML·HS | Notice something you like about yourself | 40 |
| SC-07 | Self-care | AH·QF·SN·ML·HS | Give yourself permission to say no | 34 |
| SC-08 | Self-care | AH·QF·SN·ML·HS | Do something that feels good | 28 |
| SC-09 | Self-care | **HS** | Rest for 2 minutes | 18 |
| SC-10 | Self-care | AH·QF·SN·ML·HS | Put on something comfortable | 28 |
| SC-11 | Self-care | AH·QF·SN·ML·HS | Listen to one song you love | 27 |
| SC-12 | Self-care | **SN** | Do absolutely nothing for 30 seconds | 36 |
| SC-13 | Self-care | **SN** | Dim the lights an hour before sleep | 35 |

98 items · shortest 13 · longest 41 · mean 24.9 characters.

---
## A. DUPLICATES

Grouped by what the user actually does. 52 of the 98 items fall into a group where at
least one other item asks for the same act. No two strings are byte-identical (all 98 are
unique), so every group below is a *near*-duplicate.

**A1 — Breathing (4)**

| id | text |
|---|---|
| HE-02 | Take 3 slow breaths |
| HE-09 | Take 5 deep belly breaths |
| MO-03 | One grounding breath |
| SC-05 | Take one slow breath |

Four items for one act, separated only by a count and an adjective. HE-02 and SC-05 differ by number alone.

**A2 — Stopping / stillness for N seconds (5)**

| id | text |
|---|---|
| MO-01 | Ten-second pause |
| HE-06 | Close your eyes for 20 seconds |
| SC-01 | Sit still for 10 seconds |
| SC-12 | Do absolutely nothing for 30 seconds |
| SC-09 | Rest for 2 minutes |

One act — stop moving — at 10s, 20s, 10s, 30s and 2min. MO-01 and SC-01 are the same duration in different areas.

**A3 — Stretching the neck and shoulders (4)**

| id | text |
|---|---|
| HE-03 | Stretch for 10 seconds |
| HE-04 | Stand up and roll your shoulders |
| HE-07 | Do 5 gentle neck rolls |
| SC-04 | Stretch your neck |

HE-07 and SC-04 are the same body part; HE-03 is the unspecified superset of both.

**A4 — Drinking water (2)**

| id | text |
|---|---|
| HE-01 | Drink a glass of water |
| SC-03 | Drink water slowly |

Same act; SC-03 adds an adverb, HE-01 adds a container.

**A5 — Recording an idea (2)**

| id | text |
|---|---|
| PR-04 | Write down one idea |
| CR-03 | Capture one idea |

Functionally identical. 'Capture' and 'write down' name one action in two registers.

**A6 — Contacting someone remotely (3)**

| id | text |
|---|---|
| RE-01 | Send one message to someone |
| RE-09 | Reach out to someone you miss |
| RE-05 | Call someone you care about |

RE-01 and RE-09 both resolve to sending a message; RE-09 adds a reason. RE-05 differs only by channel.

**A7 — Saying something warm to someone (4)**

| id | text |
|---|---|
| RE-04 | Give one genuine compliment |
| RE-07 | Thank someone today |
| RE-10 | Tell someone what they mean to you |
| RE-06 | Share something that made you smile |

Four framings of one act: say a good thing to a person.

**A8 — Granting yourself permission (2)**

| id | text |
|---|---|
| MO-12 | Give yourself permission to rest |
| SC-07 | Give yourself permission to say no |

Identical frame, different object.

**A9 — Noticing one good thing (5)**

| id | text |
|---|---|
| MO-02 | Notice one thing you feel |
| MO-06 | Notice one sound around you |
| MO-09 | Notice one thing you're grateful for |
| CR-04 | Notice one beautiful thing |
| SC-06 | Notice something you like about yourself |

One verb, one grammatical shape, five objects. Spread across three focus areas.

**A10 — Undefined kindness to yourself (2)**

| id | text |
|---|---|
| SC-02 | Do one kind thing for yourself |
| SC-08 | Do something that feels good |

Same act, and neither states what it is. See also E.

**A11 — Tidying one item (5)**

| id | text |
|---|---|
| HO-01 | Tidy one small thing |
| HO-02 | Put one thing back where it belongs |
| HO-06 | Clear one shelf |
| HO-10 | Organize one drawer |
| PR-06 | Declutter your desk for 2 minutes |

One act applied to an unnamed thing, a shelf, a drawer and a desk. HO-01 and HO-02 are the closest pair.

**A12 — Celebrating a win (2)**

| id | text |
|---|---|
| RE-12 | Celebrate someone else's win |
| FI-11 | Celebrate one money win |

Same verb, same frame, different owner of the win.

**A13 — Making a mark on paper (2)**

| id | text |
|---|---|
| CR-02 | Doodle for 10 seconds |
| CR-06 | Draw one simple shape |

Doodling a shape and drawing a simple shape are the same act.

**A14 — Undefined creative act (2)**

| id | text |
|---|---|
| CR-10 | Create one tiny thing |
| CR-11 | Play with one creative medium |

Both resolve to 'make something'. Neither names the something. See also E.

**A15 — Checking one money record (4)**

| id | text |
|---|---|
| FI-03 | Review one subscription |
| FI-08 | Review one bill |
| FI-04 | Note one expense |
| FI-07 | Update one budget category |

FI-03 and FI-08 are the same act on two documents; FI-04 and FI-07 are the same act on a ledger.

**A16 — A meal with attention (2)**

| id | text |
|---|---|
| HE-12 | Eat one meal mindfully |
| MO-13 | One meal without your phone |

In practice the same meal. MO-13 names the distraction removed; HE-12 names the adverb.

**A17 — Moving indoors (2)**

| id | text |
|---|---|
| HE-08 | Walk to the window and back |
| HE-11 | 10 minutes of gentle movement |

HE-11 is HE-08 and HE-03 as a superset, at 10 minutes.

**Cross-area repeats.** Six of these groups place near-identical items in *different*
focus areas, so both can be drawn at once: A2 (Mood/Health/Self-care), A3 (Health/Self-care),
A4 (Health/Self-care), A5 (Productivity/Creativity), A9 (Mood/Creativity/Self-care),
A11 (Home/Productivity), A12 (Relationships/Finances), A16 (Health/Mood).

---

## B. WORKPLACE VOCABULARY

**Literal matches from the supplied word list — 2 of 98.** Whole-word search over
desk, office, work, job, boss, manager, colleague, meeting, email, inbox, laptop, commute,
shift, deadline, client, project.

| id | focusArea | word | text |
|---|---|---|---|
| PR-06 | Productivity | desk | Declutter your desk for 2 minutes |
| PR-10 | Productivity | emails | Archive 5 old emails |

None of the other 14 words appears anywhere in the library.

**Adjacent, listed separately because they are not on your list.** Six further items carry
an office context through objects rather than through the supplied vocabulary:

| id | focusArea | text | carrier |
|---|---|---|---|
| PR-05 | Productivity | Finish one tiny task | task |
| PR-07 | Productivity | Review your calendar | calendar |
| PR-09 | Productivity | Close one browser tab | browser tab |
| PR-11 | Productivity | Update one to-do item | to-do item |
| PR-08 | Productivity | Turn off one notification | notification |
| MO-04 | Mood | Look away from your screen for 10 seconds | screen |

Eight of Productivity's 11 items are in one of these two tables.

---

## C. LENGTH OUTLIERS

**Over 40 characters — 1 of 98.**

| id | chars | text |
|---|---|---|
| MO-04 | 41 | Look away from your screen for 10 seconds |

**Under 12 characters — 0 of 98.** The shortest items are 13 characters
(`HO-05` Make your bed, `HO-07` Wash 3 dishes), then 14 (`HO-12` Light a candle).

**At the 40-character line.** Two more items sit exactly on the threshold and would cross it
with one more word:

| id | chars | text |
|---|---|---|
| MO-11 | 40 | Ask yourself "what do I need right now?" |
| SC-06 | 40 | Notice something you like about yourself |

Distribution: 13–19 chars 23 items · 20–29 chars 52 · 30–39 chars 20 · 40+ chars 3.

---

## D. FORM INCONSISTENCY

92 of 98 open with a plain imperative verb. The exceptions:

**D1 — Verbless noun phrases (6).** No imperative at all; these read as labels, not instructions.

| id | focusArea | text | form |
|---|---|---|---|
| HE-10 | Health | 2-minute body scan | noun phrase |
| HE-11 | Health | 10 minutes of gentle movement | noun phrase |
| MO-01 | Mood | Ten-second pause | noun phrase |
| MO-03 | Mood | One grounding breath | noun phrase |
| MO-13 | Mood | One meal without your phone | noun phrase |
| HE-13 | Health | Screens away 20 minutes before bed | verbless / elliptical |

Note that four of the six are also seeded starter actions
(`HE-11`, `HE-13` and `MO-13` are given directly by ML, SN and LU), so they reach users
as the first thing a path hands them.

**D2 — Embedded first-person question (1).** `MO-11` Ask yourself "what do I need right now?"
is the only item in the library containing quotation marks or a question mark, and the only
one containing a first-person pronoun. The outer frame is imperative; the quoted clause is not.

**D3 — Imperative + gerund complement (2).** Grammatically imperative, listed because the
gerund is what carries the instruction:

| id | text |
|---|---|
| RE-08 | Listen without planning your response |
| FI-09 | Price-check one item before buying |

**D4 — Reflexive register (6).** Plain imperative in form, but the object is the reader
themselves, which reads differently from the other 86:

| id | text |
|---|---|
| MO-10 | Smile gently at yourself |
| MO-11 | Ask yourself "what do I need right now?" |
| MO-12 | Give yourself permission to rest |
| SC-02 | Do one kind thing for yourself |
| SC-06 | Notice something you like about yourself |
| SC-07 | Give yourself permission to say no |

**Not found:** no "you should" (0), no "try to" (0), no "remember to" (0), no bare gerund
openers (0), no questions other than D2. `CR-09` Try one new word uses *try* as the main
imperative verb, not as a hedge.

---

## E. VAGUE VERBS

None of the words you named appears in the library: *reflect* (0), *be present* (0),
*embrace* (0), *honour/honor* (0), *cultivate* (0), *connect with* (0),
*practise mindfulness* (0). *Mindfully* appears once, in `HE-12`.

The pattern does occur, carried by three other constructions.

**E1 — Undefined object (7).** The verb is concrete; what it acts on is not named, so
nothing observable distinguishes done from not-done.

| id | focusArea | text | undefined term |
|---|---|---|---|
| PR-03 | Productivity | Do a 30-second reset | a 30-second reset |
| PR-05 | Productivity | Finish one tiny task | one tiny task |
| SC-02 | Self-care | Do one kind thing for yourself | one kind thing |
| SC-08 | Self-care | Do something that feels good | something that feels good |
| CR-10 | Creativity | Create one tiny thing | one tiny thing |
| CR-11 | Creativity | Play with one creative medium | one creative medium |
| CR-08 | Creativity | Rearrange something small | something small |

**E2 — Internal stance, not an act (5).** These complete entirely inside the reader; there
is no moment at which they visibly happen.

| id | focusArea | text |
|---|---|---|
| MO-12 | Mood | Give yourself permission to rest |
| SC-07 | Self-care | Give yourself permission to say no |
| RE-02 | Relationships | Think of one person you appreciate |
| CR-12 | Creativity | Imagine one possibility |
| FI-11 | Finances | Celebrate one money win |

**E3 — The adverb carries the whole instruction (5).** Strip the adverb and the item
becomes something the reader was going to do anyway.

| id | text | adverb / modifier |
|---|---|---|
| HE-12 | Eat one meal mindfully | mindfully |
| SC-03 | Drink water slowly | slowly |
| MO-10 | Smile gently at yourself | gently |
| HE-07 | Do 5 gentle neck rolls | gentle |
| RE-08 | Listen without planning your response | without planning your response |

**E4 — Undefined verb (2).** `RE-12` Celebrate someone else's win and `FI-11` Celebrate one
money win use a verb that names an attitude rather than an action.

16 distinct items across E1–E4 (`MO-12`, `SC-07`, `RE-08`, `MO-10` and `FI-11` each appear twice).

---
## F. COVERAGE COUNT

**F1 — Per focus area.**

| focusArea | intentions | share |
|---|---|---|
| Health | 13 | 13% |
| Mood | 13 | 13% |
| Productivity | 11 | 11% |
| Home & organization | 12 | 12% |
| Relationships | 12 | 12% |
| Creativity | 12 | 12% |
| Finances | 12 | 12% |
| Self-care | 13 | 13% |
| **Total** | **98** | **100%** |

The comment above the map reads "EXPANDED TO 12 EACH"; the actual counts are 11–13.
Health, Mood and Self-care have 13; Productivity has 11.

**F2 — Per path.** Two mechanisms, so two numbers per path. *Seeded* is the fixed list in
`starterActions`. *Reachable pool* is the union of the path's `defaultFocusAreas` — the
candidates from which `generateUserHabits` draws 2 per area. A path with seeded actions
never draws from the pool.

| path | defaultFocusAreas | seeded | reachable pool | actions given at start |
|---|---|---|---|---|
| gentleMornings | Health, Productivity | 0 | 24 | 4 (2 per area, random) |
| anchorsForHardDays | Mood, Self-care | 0 | 26 | 4 (2 per area, random) |
| quietFocus | Productivity, Self-care | 0 | 24 | 4 (2 per area, random) |
| windingDown | Health, Mood | 0 | 26 | 4 (2 per area, random) |
| softerNights | Health, Self-care | **4** | 26 *(unused)* | 4 |
| lookingUp | Mood, Productivity | **4** | 24 *(unused)* | 4 |
| closerToPeople | Relationships, Mood | **4** | 25 *(unused)* | 4 |
| movingALittle | Health, Self-care | **4** | 26 *(unused)* | 4 |
| throughAHardSeason | Self-care, Mood | **4** | 26 *(unused)* | 4 |
| yourOwnWay *(legacy, not in picker)* | — | 0 | 0 | 2 hardcoded |

**F3 — Focus areas no path defaults to.** Home & organization, Creativity and Finances
appear in no `defaultFocusAreas` list. Their **36 intentions — 37% of the library — are
unreachable unless the user adds the focus area themselves** on the focus-areas screen.

| focusArea | paths defaulting to it | intentions |
|---|---|---|
| Health | GM, WD, SN, ML | 13 |
| Mood | AH, WD, LU, CP, HS | 13 |
| Productivity | GM, QF, LU | 11 |
| Home & organization | **none** | 12 |
| Relationships | CP | 12 |
| Creativity | **none** | 12 |
| Finances | **none** | 12 |
| Self-care | AH, QF, SN, ML, HS | 13 |

**F4 — Seeded coverage.** 20 of 98 items (20%) are named by a path; 78 are pool-only.
All 20 seeded strings exist in `habitsByCategory` — no path seeds a string outside the library.

| focusArea | seeded by a path | pool-only |
|---|---|---|
| Health | 7 | 6 |
| Mood | 4 | 9 |
| Productivity | 1 | 10 |
| Home & organization | 0 | 12 |
| Relationships | 4 | 8 |
| Creativity | 0 | 12 |
| Finances | 0 | 12 |
| Self-care | 4 | 9 |
| **Total** | **20** | **78** |

---

## G. COVERAGE MAP

Classification only. Each item gets exactly one value per axis. Rules are stated so each
call can be checked against the string.

### G1. Time of day implied

*Rule: only what the text itself entails. A path's name and a curated pack's framing are
not counted — `HE-01` Drink a glass of water sits in the Gentle Mornings pack but the string
carries no time.*

| bucket | count |
|---|---|
| morning | 1 |
| daytime | 6 |
| evening | 3 |
| night | 0 |
| none | 88 |
| **Total** | **98** |

| id | focusArea | text | bucket |
|---|---|---|---|
| HE-13 | Health | Screens away 20 minutes before bed | evening |
| MO-04 | Mood | Look away from your screen for 10 seconds | daytime |
| PR-02 | Productivity | Plan tomorrow in one sentence | evening |
| PR-06 | Productivity | Declutter your desk for 2 minutes | daytime |
| PR-07 | Productivity | Review your calendar | daytime |
| PR-09 | Productivity | Close one browser tab | daytime |
| PR-10 | Productivity | Archive 5 old emails | daytime |
| PR-11 | Productivity | Update one to-do item | daytime |
| HO-05 | Home & organization | Make your bed | morning |
| SC-13 | Self-care | Dim the lights an hour before sleep | evening |

The 6 daytime items are exactly the screen-and-desk items from section B. **Night is empty:**
the two closest, `HE-13` and `SC-13`, are both *before* sleep. One morning item, `HO-05`.

### G2. Effort floor — smallest version of the action

*Rule: the floor is the shortest honest completion. `SC-13` Dim the lights an hour before
sleep is under a minute — "an hour" is the timing, not the duration. `HE-13` Screens away
20 minutes before bed is 15+ — the 20 minutes is the duration.*

| bucket | count |
|---|---|
| under a minute | 73 |
| a few minutes | 11 |
| 15 min or more | 3 |
| unclear | 11 |
| **Total** | **98** |

**A few minutes (11):** `HE-10`, `HE-11`, `HO-05`, `HO-06`, `HO-07`, `HO-08`, `HO-10`, `RE-05`, `FI-09`, `SC-09`, `SC-11`

**15 min or more (3):**

| id | focusArea | text |
|---|---|---|
| HE-12 | Health | Eat one meal mindfully |
| HE-13 | Health | Screens away 20 minutes before bed |
| MO-13 | Mood | One meal without your phone |

**Unclear (11)** — no duration is derivable from the string. Overlaps heavily with E:

| id | focusArea | text |
|---|---|---|
| MO-12 | Mood | Give yourself permission to rest |
| PR-05 | Productivity | Finish one tiny task |
| RE-08 | Relationships | Listen without planning your response |
| RE-12 | Relationships | Celebrate someone else's win |
| CR-10 | Creativity | Create one tiny thing |
| CR-11 | Creativity | Play with one creative medium |
| FI-10 | Finances | Wait 24 hours before one purchase |
| FI-11 | Finances | Celebrate one money win |
| SC-02 | Self-care | Do one kind thing for yourself |
| SC-07 | Self-care | Give yourself permission to say no |
| SC-08 | Self-care | Do something that feels good |

### G3. Body / mind / environment / people

*Rule: what the action operates on. **body** — your own physical body (breath, muscle,
posture, hydration, food, rest, location of yourself). **mind** — attention, thought,
feeling, self-directed speech. **environment** — an object, device, space or money.
**people** — another person. Where an act needs a medium to exist (write, draw, photograph)
it is environment; where it completes internally (imagine, notice) it is mind.*

| bucket | count |
|---|---|
| body | 23 |
| mind | 21 |
| environment | 43 |
| people | 11 |
| **Total** | **98** |

**Cross-tabulated against focus area:**

| focusArea | body | mind | environment | people | n |
|---|---|---|---|---|---|
| Health | 12 | 0 | 1 | 0 | 13 |
| Mood | 4 | 7 | 2 | 0 | 13 |
| Productivity | 0 | 3 | 8 | 0 | 11 |
| Home & organization | 0 | 0 | 12 | 0 | 12 |
| Relationships | 0 | 1 | 0 | 11 | 12 |
| Creativity | 1 | 3 | 8 | 0 | 12 |
| Finances | 0 | 2 | 10 | 0 | 12 |
| Self-care | 6 | 5 | 2 | 0 | 13 |
| **Total** | **23** | **21** | **43** | **11** | **98** |

Four areas are single-bucket or near it: Home & organization is 12/12 environment,
Relationships 11/12 people, Health 12/13 body, Finances 10/12 environment. Mood and Self-care
are the mixed ones.
### G4. Distinct opening verb

*92 of 98 items open with an imperative verb; the other 6 are the verbless noun phrases in
D1 and are listed at the end. Phrasal verbs are counted whole where the particle changes the
sense (`Take out` ≠ `Take`).*

**69 distinct verbs across 92 items.** 56 verbs are used exactly once.

| verb | count | ids |
|---|---|---|
| Do | 5 | HE-07, PR-03, SC-02, SC-08, SC-12 |
| Notice | 5 | MO-02, MO-06, MO-09, CR-04, SC-06 |
| Take | 4 | HE-02, HE-09, CR-05, SC-05 |
| Give | 3 | MO-12, RE-04, SC-07 |
| Review | 3 | PR-07, FI-03, FI-08 |
| Ask | 2 | MO-11, RE-03 |
| Celebrate | 2 | RE-12, FI-11 |
| Close | 2 | HE-06, PR-09 |
| Drink | 2 | HE-01, SC-03 |
| Listen | 2 | RE-08, SC-11 |
| Set | 2 | PR-01, FI-12 |
| Stretch | 2 | HE-03, SC-04 |
| Update | 2 | PR-11, FI-07 |

**Used once (56):** Archive, Call, Capture, Check, Clear, Create, Declutter, Delete, Dim, Doodle, Draw, Eat, Feel, Finish, Fold, Hum, Imagine, Light, Look away, Make, Move, Name, Note, Offer, Open, Organize, Place, Plan, Play, Price-check, Put, Put on, Reach out, Read, Rearrange, Rest, Send, Share, Sit, Smile, Stand up, Step, Take out, Tell, Thank, Think, Tidy, Try, Turn off, Wait, Walk, Wash, Water, Wipe, Write, Write down

**No opening verb (6):** `HE-10`, `HE-11`, `HE-13`, `MO-01`, `MO-03`, `MO-13`

The head of the distribution is generic: *Do* (5), *Notice* (5), *Take* (4) and *Give* (3)
account for 17 items and none of the four names a specific act on its own — each depends
entirely on its object. The long tail (56 verbs used once) is where the concrete acts are.

### G5. Requires another person

*Rule: the action cannot be completed alone — another person must receive, answer or
participate. Physical co-presence is noted separately, since most can be done over a channel.*

**11 of 98 (11%).** All 11 are in Relationships; that area's 12th item, `RE-02` Think
of one person you appreciate, completes alone. No other focus area contains one.

| id | focusArea | text | channel |
|---|---|---|---|
| RE-01 | Relationships | Send one message to someone | remote or in person |
| RE-03 | Relationships | Ask someone how they are | remote or in person |
| RE-04 | Relationships | Give one genuine compliment | remote or in person |
| RE-05 | Relationships | Call someone you care about | call |
| RE-06 | Relationships | Share something that made you smile | remote or in person |
| RE-07 | Relationships | Thank someone today | remote or in person |
| RE-08 | Relationships | Listen without planning your response | live conversation |
| RE-09 | Relationships | Reach out to someone you miss | remote or in person |
| RE-10 | Relationships | Tell someone what they mean to you | remote or in person |
| RE-11 | Relationships | Offer help to someone | remote or in person |
| RE-12 | Relationships | Celebrate someone else's win | remote or in person |

**Strictly requiring physical co-presence: 0.** Every one of the 11 can be completed by
message or call. `RE-08` Listen without planning your response comes closest — it needs a
live conversation, but a phone call satisfies it.

### G6. Requires leaving the home

*Rule: the action cannot be completed inside the dwelling.*

| bucket | count |
|---|---|
| requires leaving | 1 |
| conditional | 1 |
| does not require leaving | 96 |
| **Total** | **98** |

| id | focusArea | text | note |
|---|---|---|---|
| HE-05 | Health | Step outside for 30 seconds | the whole action is the leaving |
| HO-08 | Home & organization | Take out one small bag of trash | conditional — a chute or bin inside the building satisfies it |

Two adjacent items deliberately stay indoors: `HE-08` Walk to the window and back and
`HO-04` Open a window for fresh air. `HE-11` 10 minutes of gentle movement and `FI-09`
Price-check one item before buying can each be done either way and are counted as not requiring it.

### G7. Requires an object or a purchase

*Rule: the action needs something beyond the reader's own body. Split by what kind, and
separately by whether the reader is likely to already have it.*

| bucket | count |
|---|---|
| requires an object | 51 |
| body only | 47 |
| **Total** | **98** |

**By kind of object:**

| kind | count | ids |
|---|---|---|
| device | 24 | HE-13, MO-04, MO-13, PR-07, PR-08, PR-09, PR-10, PR-11, RE-01, RE-05, RE-06, CR-03, CR-05, SC-11, FI-01, FI-02, FI-03, FI-04, FI-05, FI-06, FI-07, FI-08, FI-09, FI-12 |
| household | 18 | HE-01, HE-12, HO-01, HO-02, HO-03, HO-04, HO-05, HO-06, HO-07, HO-08, HO-09, HO-10, HO-11, HO-12, SC-03, SC-10, SC-13, PR-06 |
| writing/art | 8 | PR-02, PR-04, CR-01, CR-02, CR-06, CR-08, CR-10, CR-11 |
| **Total** | **50** | |

**Possession- or purchase-gated (13).** These need a specific thing the reader may not own,
as opposed to a phone or a kitchen tap. If the thing is absent, the intention cannot be
completed at all:

| id | focusArea | text | requires |
|---|---|---|---|
| HO-11 | Home & organization | Water one plant | a houseplant |
| HO-12 | Home & organization | Light a candle | a candle |
| SC-13 | Self-care | Dim the lights an hour before sleep | lights that dim |
| CR-11 | Creativity | Play with one creative medium | art materials |
| FI-02 | Finances | Move €1 to savings | a savings account, plus €1 |
| FI-03 | Finances | Review one subscription | a paid subscription |
| FI-07 | Finances | Update one budget category | an existing budget |
| FI-08 | Finances | Review one bill | a bill on hand |
| FI-10 | Finances | Wait 24 hours before one purchase | a purchase already intended |
| FI-12 | Finances | Set one small savings goal | a savings account |
| PR-06 | Productivity | Declutter your desk for 2 minutes | a desk |
| PR-07 | Productivity | Review your calendar | a calendar you keep |
| PR-11 | Productivity | Update one to-do item | a to-do list you keep |

Six of the twelve Finances items are gated. `FI-02` Move €1 to savings is the only item in
the library that names a currency, and the only one that costs money to complete.

**Body only (47)** — completable with nothing but yourself:

`HE-02`, `HE-03`, `HE-04`, `HE-05`, `HE-06`, `HE-07`, `HE-08`, `HE-09`, `HE-10`, `HE-11`, `MO-01`, `MO-02`, `MO-03`, `MO-05`, `MO-06`, `MO-07`, `MO-08`, `MO-09`, `MO-10`, `MO-11`, `MO-12`, `PR-01`, `PR-03`, `PR-05`, `RE-02`, `RE-03`, `RE-04`, `RE-07`, `RE-08`, `RE-09`, `RE-10`, `RE-11`, `RE-12`, `CR-04`, `CR-07`, `CR-09`, `CR-12`, `FI-11`, `SC-01`, `SC-02`, `SC-04`, `SC-05`, `SC-06`, `SC-07`, `SC-08`, `SC-09`, `SC-12`

---

*End of audit. 98 intentions examined; no code or content modified.*