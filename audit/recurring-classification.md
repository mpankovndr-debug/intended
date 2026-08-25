# Seeded intentions — RECURRING / ONE-SHOT / BORDERLINE

**Scope.** All 98 entries of `OnboardingState.habitsByCategory`
(`lib/onboarding_v2/onboarding_state.dart:244`), joined through
`lib/utils/habit_l10n.dart` (`_habitNameGetters` → getter → `l10n.<key>`) to the
English value in `lib/l10n/app_en.arb`.

**Resolution result.** 98 of 98 entries resolved. No entry is missing from
`_habitNameGetters`, no getter is missing an ARB key, no ARB key is absent.
**Nothing unresolved.** 38 of the 98 render differently from the stored string —
matching the premise exactly.

**Everything below classifies the RENDERED string.** The stored English is what
sits in `SharedPreferences`; the string a user actually reads on the home screen,
in the widget and in the completion modal is the ARB value.

**Why the axis matters here.** These 6 intentions persist until manually swapped
or refreshed — they are not regenerated daily — and a free user gets 2 swaps a
month. A ONE-SHOT intention therefore does not become stale for a day; it
occupies 1 of 6 slots indefinitely, and clearing it costs half of a free user's
monthly swap budget.

---

## 1. Full table

| Focus area | Rendered string | Class | Reason |
|---|---|---|---|
| Health | Drink 3 glasses of water | RECURRING | Thirst returns; today's water does not cover tomorrow. |
| Health | Take 3 slow breaths | RECURRING | A momentary practice with no completed state. |
| Health | Stretch for 30 seconds | RECURRING | Tension re-accumulates daily. |
| Health | Stand up and roll your shoulders | RECURRING | Sitting recurs, so the relief does too. |
| Health | Step outside for 5 minutes | RECURRING | Going out today leaves nothing done for tomorrow. |
| Health | Close your eyes for 30 seconds | RECURRING | Pure practice, no depleting object. |
| Health | Do 5 gentle neck rolls | RECURRING | Physical practice, repeatable indefinitely. |
| Health | Walk to the window and back | RECURRING | The window does not get used up. |
| Health | Take 5 slow, deep breaths | RECURRING | Practice, not a task with a finish line. |
| Health | 2-minute body scan | RECURRING | A meditation, meaningful every day. |
| Health | 5 minutes of gentle stretching | RECURRING | Bodily maintenance, daily by nature. |
| Health | Eat one meal mindfully | RECURRING | Meals happen every day. |
| Health | Screens away 20 minutes before bed | RECURRING | Bedtime is a daily occasion. |
| Mood | One-minute pause | RECURRING | A pause taken today does not exempt tomorrow. |
| Mood | Notice one thing you feel | RECURRING | Feelings change hourly; always something new. |
| Mood | Three grounding breaths | RECURRING | Practice with no completed state. |
| Mood | Look away from your screen for 30 seconds | RECURRING | Screen time recurs daily. |
| Mood | Name three things you can see | RECURRING | Surroundings are always available. |
| Mood | Notice one sound around you | RECURRING | Sound is continuously present. |
| Mood | Feel your feet on the ground | RECURRING | Body-attention practice, endlessly repeatable. |
| Mood | Place hand on heart for 30 seconds | RECURRING | Self-soothing gesture, repeatable every day. |
| Mood | Name 3 things you're grateful for | RECURRING | Gratitude is renewed, not consumed. |
| Mood | Smile kindly at yourself | RECURRING | A gesture, not a task. |
| Mood | Ask yourself "what do I need right now?" | RECURRING | "Right now" changes every day. |
| Mood | Give yourself permission to rest | RECURRING | Permission is re-granted, never permanently issued. |
| Mood | One meal without your phone | RECURRING | There is a meal every day. |
| Productivity | Set one priority today | RECURRING | "Today" scopes it to the day; a new day needs a new priority. |
| Productivity | Plan tomorrow in one sentence | RECURRING | There is always a next tomorrow. |
| Productivity | Do a 1-minute reset | RECURRING | Timeboxed practice with no end state. |
| Productivity | **Unsubscribe from an unnecessary email list** | **ONE-SHOT** | A permanent settings change against a small, depleting stock of subscriptions. |
| Productivity | Finish one tiny task | RECURRING | New tiny tasks arrive continuously. |
| Productivity | Declutter your desk | BORDERLINE | Names a *state* of the desk, reached and then held for days. |
| Productivity | Review your calendar | RECURRING | The calendar's contents change every day. |
| Productivity | **Turn off one notification** | **ONE-SHOT** | Same shape as unsubscribing: a persistent config change against a stock that runs out in days. |
| Productivity | Close unnecessary browser tabs | BORDERLINE | Sweep to a clean state; recurs only once tabs re-accumulate. |
| Productivity | Archive 5 old emails | RECURRING | Mail arrives daily and becomes old; the supply is self-refilling. |
| Productivity | Update one to-do item | RECURRING | The list changes daily, so there is always one to update. |
| Home & organization | Tidy one small thing | RECURRING | Small disorder regenerates every day. |
| Home & organization | Put one thing back where it belongs | RECURRING | Things leave their place daily through ordinary use. |
| Home & organization | Wipe one surface | RECURRING | Surfaces get dirty again. |
| Home & organization | Open a window for fresh air | RECURRING | Air goes stale daily. |
| Home & organization | Make your bed | RECURRING | Sleeping unmakes it every night. |
| Home & organization | Clear one shelf | BORDERLINE | A cleared shelf stays cleared for weeks; the home holds a finite number of shelves. |
| Home & organization | Wash 3 dishes | RECURRING | Eating generates dishes every day. |
| Home & organization | Take out one bag of trash | BORDERLINE | Gated on a bin actually being full — a two-to-four-day cycle, not daily. |
| Home & organization | Fold 3 items of clothing | BORDERLINE | Gated on clean unfolded laundry existing, which follows a weekly wash cycle. |
| Home & organization | Organize one drawer | BORDERLINE | An organized drawer stays organized for months; drawers are a finite, depleting inventory. |
| Home & organization | Water your plants | BORDERLINE | Plants need water on a several-day cycle; watering daily is actively wrong. |
| Home & organization | Light a scented candle | RECURRING | Lighting it does not use it up; any evening qualifies. |
| Relationships | Send one message to someone you care about | RECURRING | Different person, different day; nothing is consumed. |
| Relationships | Think of one person you appreciate | RECURRING | Internal act, endlessly repeatable. |
| Relationships | Ask someone how they are | RECURRING | The answer is different every day. |
| Relationships | Give one genuine compliment | RECURRING | New occasions arise daily. |
| Relationships | Call someone you care about | RECURRING | Calls do not deplete the people worth calling. |
| Relationships | Share something that made you smile | RECURRING | Something small amuses most people most days. |
| Relationships | Thank someone today | RECURRING | "Today" scopes it; new thanks are owed daily. |
| Relationships | Listen without planning your response | RECURRING | A manner of listening, applied in every conversation. |
| Relationships | Reach out to someone you miss | BORDERLINE | The set of missed people is small and is spent by reaching out; it refills over months. |
| Relationships | Tell someone what they mean to you | BORDERLINE | A high-disclosure act; the small circle it applies to is exhausted in a few days. |
| Relationships | Offer help to someone | RECURRING | Someone nearby needs something most days. |
| Relationships | Celebrate someone else's win | BORDERLINE | Gated on somebody near you actually having a win — not a daily event. |
| Creativity | Write a short story | BORDERLINE | Repeatable in principle, but one story is a multi-session project; the natural interval is weeks. |
| Creativity | Doodle for 5 minutes | RECURRING | Timeboxed practice, no end state. |
| Creativity | Capture one idea | RECURRING | Ideas keep arriving. |
| Creativity | Notice one beautiful thing | RECURRING | Beauty is not consumed by being noticed. |
| Creativity | Take one photo of something you like | RECURRING | New subjects every day. |
| Creativity | Draw something simple | RECURRING | Drawing today does not finish drawing. |
| Creativity | Hum a tune you enjoy | RECURRING | Repeatable indefinitely. |
| Creativity | Rearrange something small | RECURRING | Rooms and desks always offer another small thing. |
| Creativity | Learn one new word | RECURRING | The language's supply of unknown words is effectively infinite. |
| Creativity | Play a short melody | RECURRING | Repeatable daily by whoever has an instrument. (Capability gate, not a daily condition — see §4.) |
| Creativity | Play with one creative medium | RECURRING | Open-ended practice. |
| Creativity | Do a vocal warm-up | RECURRING | Warm-ups are by definition repeated. |
| Finances | Try one financial tip | BORDERLINE | Repeats only as fast as you meet a new tip, and most tips are one-time structural changes. |
| Finances | Move €3/$3 to savings | RECURRING | A transfer today does not preclude one tomorrow. |
| Finances | Review one subscription | BORDERLINE | Subscriptions are a finite list (typically under fifteen); a review holds for months. |
| Finances | Note 3 expenses | RECURRING | Spending generates new expenses daily. |
| Finances | Read one financial tip | RECURRING | Reading (unlike trying) costs nothing and the supply is unlimited. |
| Finances | Delete one old receipt | BORDERLINE | Works off a finite backlog that depletes; refills only as slowly as receipts age. |
| Finances | Treat yourself | RECURRING | A treat today does not make treating yourself done. |
| Finances | Review necessity of one subscription | BORDERLINE | Same finite list as "Review one subscription" above — and a near-duplicate of it. |
| Finances | Price-check one item before buying | BORDERLINE | Gated on you buying something that day, which is not a daily event for most. |
| Finances | **Wait 24 hours before a big purchase** | **ONE-SHOT** | Gated on a *big* purchase — an occasion that arises a handful of times a year. |
| Finances | Celebrate one money win | BORDERLINE | Gated on a money win occurring; wins are occasional, not daily. |
| Finances | **Set one savings goal** | **ONE-SHOT** | A goal, once set, stands. Setting a new one daily would empty the word. |
| Self-care | Sit still for 1 minute | RECURRING | Practice with no completed state. |
| Self-care | Do one kind thing for yourself | RECURRING | Kindness is not spent. |
| Self-care | Drink a cup of tasty coffee | RECURRING | Daily by nature. |
| Self-care | Stretch your neck | RECURRING | Tension re-accumulates. |
| Self-care | Take one slow breath | RECURRING | Endlessly repeatable. |
| Self-care | Notice something you like about yourself | RECURRING | Renewable observation, not a checklist. |
| Self-care | Give yourself permission to say no | RECURRING | Permission is re-granted each time it is needed. |
| Self-care | Do something that feels good | RECURRING | Open-ended, no end state. |
| Self-care | Rest for 5 minutes | RECURRING | Rest is consumed and needed again. |
| Self-care | Put on something comfortable | RECURRING | Dressing happens every day. |
| Self-care | Listen to one song you love | RECURRING | Songs survive being played. |
| Self-care | Do absolutely nothing for 5 minutes | RECURRING | Timeboxed practice. |
| Self-care | Dim the lights an hour before sleep | RECURRING | Sleep is a nightly occasion. |

---

## 2. Counts — class × focus area

| Focus area | RECURRING | BORDERLINE | ONE-SHOT | Total |
|---|---:|---:|---:|---:|
| Health | 13 | 0 | 0 | 13 |
| Mood | 13 | 0 | 0 | 13 |
| Productivity | 7 | 2 | 2 | 11 |
| Home & organization | 7 | 5 | 0 | 12 |
| Relationships | 9 | 3 | 0 | 12 |
| Creativity | 11 | 1 | 0 | 12 |
| Finances | 4 | 6 | 2 | 12 |
| Self-care | 13 | 0 | 0 | 13 |
| **Total** | **77** | **17** | **4** | **98** |

Concentration is the finding, not the totals: Health, Mood and Self-care are
100% recurring, while Finances is only 4/12 recurring and Home 7/12. A user
whose focus areas are Health + Mood + Self-care can draw nothing but recurring
intentions. A user on Finances draws a non-daily intention two times in three.

---

## 3. The ONE-SHOT list, grouped by focus area

**Productivity (2)**
- Unsubscribe from an unnecessary email list
- Turn off one notification

**Finances (2)**
- Wait 24 hours before a big purchase
- Set one savings goal

**Health, Mood, Home & organization, Relationships, Creativity, Self-care:** none.

Note that two of the four are *rendered-only* problems in the sense that the
stored string differs — "Unsubscribe from an unnecessary email list" is stored as
"Write down one idea". See §5.

---

## 4. Could a small edit make it recurring?

Described as the change required, not as replacement copy.

### ONE-SHOT

| String | Fixable? | What would have to change |
|---|---|---|
| Unsubscribe from an unnecessary email list | No | The act is a permanent, external state change, and the stock it draws on (your own subscriptions) is small and never refills. No wording keeps it true on day 30. Only replacing the *act* helps — a daily-renewing inbox act rather than a config change. |
| Turn off one notification | No | Same shape. A phone has perhaps a dozen notifications worth disabling; after those, the intention asks for something that no longer exists. Wording cannot manufacture more of them. |
| Wait 24 hours before a big purchase | Yes, by loosening the gate | The blocker is the qualifier "big", which fires a few times a year. If the trigger became any discretionary purchase, or better, if the act became a daily reflective one applied to whatever you are currently tempted by, the occasion arises most days. The 24-hour rule itself is fine; the rarity of the trigger is the problem. |
| Set one savings goal | Yes, by shifting the verb | "Set" describes a state that persists once reached. Moving the act from *establishing* the goal to *engaging with* an already-existing goal — checking it, moving it forward, adjusting it — is true again tomorrow. This is a verb change, not a topic change. |

### BORDERLINE

| String | Fixable? | What would have to change |
|---|---|---|
| Declutter your desk | Yes | The stored string already contains the fix: a duration turns the state ("desk is clear") into a practice ("two minutes of clearing"), which is true on a clear desk too. The ARB dropped the duration. |
| Close unnecessary browser tabs | Yes | Plural + "unnecessary" makes it a sweep to a clean state. A singular, unqualified unit — one tab, whatever is open — is available every day. Again, the stored string is the fix. |
| Clear one shelf | Yes | The unit is too large. A shelf-sized unit exhausts the house; a surface-agnostic small unit does not. |
| Take out one bag of trash | Partly | The gate is a full bin. Removing the "bag" unit and asking for whatever waste is currently around makes it daily; the improvement is real but modest, since it overlaps with existing tidy actions. |
| Fold 3 items of clothing | Partly | Gated on the weekly laundry cycle. A clothing act not tied to washing — putting away, hanging up, dealing with the chair pile — recurs daily; folding specifically does not. |
| Organize one drawer | Yes | Same as "Clear one shelf": the container is the problem. Shrink the unit below drawer scale and the supply stops running out. |
| Water your plants | No, not by wording | The rhythm belongs to the plant, not the sentence. Any phrasing that makes it daily makes it botanically wrong. The honest fix is a different plant-adjacent act (checking, turning toward light) or accepting the slower rhythm. |
| Reach out to someone you miss | Partly | "Miss" is what narrows it to a handful of people. Widening the relation — anyone you have not spoken to lately — enlarges the pool considerably without changing the act. It still will not be truly daily. |
| Tell someone what they mean to you | No | Its whole value is its rarity and weight. Making it daily would make it hollow, which is worse than borderline. Leave it slow. |
| Celebrate someone else's win | Partly | Depends on someone else's event. Broadening from "win" to any good thing in another person's day makes the condition hold most days, at some cost to the word "celebrate". |
| Write a short story | Yes | Only the scale is wrong. The stored string is one sentence — a unit that fits inside a day. Anything sub-session-sized recurs; a story does not. |
| Try one financial tip | Yes | Two problems: the supply of new tips, and the fact that most tips are one-time changes. Shifting from *adopting new tips* to a concrete recurring money act (the stored string, checking your balance, is exactly that) resolves both. |
| Review one subscription | Yes | The finite list is the constraint. Rotating the object away from subscriptions to whatever you spent money on recently makes the supply renew daily. |
| Delete one old receipt | Partly | Works off a backlog. Broadening from receipts to any financial clutter enlarges the backlog but does not make it self-renewing; the interval improves from weeks to days, not to daily. |
| Review necessity of one subscription | Yes, and it is redundant | Same fix as "Review one subscription" — and note that within Finances these two render as near-duplicates of each other, so one slot in the pool is effectively wasted regardless of class. |
| Price-check one item before buying | Yes | The gate is "before buying". Detaching the act from a purchase event — comparing prices on something you already pay for, or on a recurring cost — removes the dependence on shopping that day. |

---

## 5. Stored vs. rendered where the two get DIFFERENT classes

Six of the 38 divergences change the classification. **The rendered string is the
one users see and therefore the one that governs.** In five of the six, the
stored string is the *better* one — the ARB value is the regression.

| # | Stored (class) | Rendered — **what users see** (class) | Why the class moves |
|---|---|---|---|
| 1 | Productivity — "Write down one idea" — **RECURRING** | **"Unsubscribe from an unnecessary email list"** — **ONE-SHOT** | Not a rewording but a different act. Ideas arrive daily and can be captured forever; unsubscribing is a permanent config change against a stock that runs out. The single largest class regression in the set. |
| 2 | Productivity — "Declutter your desk for 2 minutes" — **RECURRING** | **"Declutter your desk"** — **BORDERLINE** | Dropping the duration converts a timeboxed practice into a state to be reached. Two minutes of clearing is true on an already-clear desk; "declutter your desk" is not. |
| 3 | Productivity — "Close one browser tab" — **RECURRING** | **"Close unnecessary browser tabs"** — **BORDERLINE** | Singular-and-unqualified became plural-and-conditional. One tab is always closeable; "unnecessary tabs" may not exist tomorrow. |
| 4 | Creativity — "Write one sentence" — **RECURRING** | **"Write a short story"** — **BORDERLINE** | A scale jump from a sub-minute act to a multi-session project. The natural repeat interval moves from a day to weeks. |
| 5 | Finances — "Check your balance" — **RECURRING** | **"Try one financial tip"** — **BORDERLINE** | Checking a balance is a daily observation; trying a tip depends on encountering a new tip, and most tips are one-time structural changes. |
| 6 | Finances — "Update one budget category" — **BORDERLINE** | **"Treat yourself"** — **RECURRING** | The only divergence that improves the class. Budget categories are a finite monthly-rhythm list; treating yourself has no completed state. |

**Direction of the drift:** five of six move toward *less* repeatable, one toward
more. Combined with §3, the practical consequence is that four of the six named
Productivity/Finances problems exist only in the ARB — the stored corpus these
were seeded from was materially more recurring than the corpus users read.

---

*Classification only, as requested. No copy written, no cuts recommended, no
source file modified.*
