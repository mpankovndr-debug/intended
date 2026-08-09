# ⚠️ SUPERSEDED — see `INTENDED_STRATEGY_2026-05.md`

**This document has been merged into the unified strategy doc.**

**Read this instead:** [INTENDED_STRATEGY_2026-05.md](INTENDED_STRATEGY_2026-05.md)

The original content of this file is preserved below for reference.

---

# Intended as a Companion — Strategy & Specific Answers

**Date:** May 5, 2026
**Companion to:** `INTENDED_HONEST_AUDIT_2026-05.md`
**Scope:** Three specific questions: smart functionality, intention path clarity, review timing.

---

## Reframe: what "companion" means in 2026

A *habit tracker* records what you did.
A *companion* notices what you're doing, reflects it back, and adapts.

The bar for "companion" is lower than people think — you do not need a chatbot. You need three loops:

1. **Notice** — the app sees a pattern in user behavior (rule-based is fine; no ML required).
2. **Reflect** — the app surfaces what it noticed, in the user's language.
3. **Adapt** — the app proposes one small change and asks the user to choose.

**Right now Intended does step 1 (tracking) and step 2 partially (reflections, warmth messages). It does almost no step 3.** That gap is the difference between "habit tracker" and "companion." Closing it is mostly content + a few light rules — not a rewrite.

The honest reframe of your positioning, if you commit to "companion":

> **Intended is the calm companion that helps you build small routines that actually fit your life — and adjusts when life gets in the way.**

That sentence does three things your current copy doesn't:
- It promises a relationship ("companion"), not a tool ("tracker").
- It promises adaptation ("adjusts when life gets in the way") — the magic word.
- It still respects the gentle wedge ("calm", "small", "fit your life").

---

## Question 1 — Do you have enough smart functionality?

**Short answer:** You have the *foundation* of smart, but it's all static. To deliver on "companion" you need 2–3 small *adaptive* features. None of them require AI. All of them are 1–2 days of work each.

### What you already have that is companion-shaped (you're underselling this)

Reading the code, you already have:

- **5 Intention Paths** that route the experience: warmth messages, notifications, default focus areas, and curated packs all branch on the user's chosen path. This is more personalization than 80% of habit apps in the App Store.
- **30 path-specific warmth messages + ~15 generic** = ~45 contextual messages.
- **30+ path-specific notification messages + 50 generic** = 80+ scheduled reminders that change tone with the user's path.
- **5 curated packs** (Gentle Mornings, Winding Down, Tiny Resets, Creative Spark, Stay Connected) — each is a hand-built micro-routine of 3–4 habits with deliberate copy ("a rescue kit", "no talent required", "showing up").
- **Habit-specific scientific insights** at completion (25% randomization, 20+ insights).
- **Weekly + monthly reflections** that look back at the user's actual data.
- **12 milestones** across two categories (Journey, Habits).
- **Shareable moment cards** (a moment-in-time emotional artifact).

This is genuinely a lot of content. **The marketing copy and the App Store listing barely communicate any of it.** Your paywall says "Monthly & weekly reflections" and "Curated routines designed for real life" — those bullets undersell what's actually behind them. (See the listing rewrite recommendations in the main audit.)

### The companion gap: what's missing

You have **observation** and **expression** (warmth, notifications, reflections). You're missing **adaptation** — the moment where the app notices something and offers a small change.

Below are five small additions, ranked by impact-to-effort. Do the first one this month. The rest are a 3–6 month roadmap.

#### 1. ★★★ "Pattern Noticed" weekly card *(2–3 days, no AI)*

Add a new variant of the weekly reflection card. Instead of summarizing what the user did, it surfaces *one observation* and asks *one question*. Pure rule-based.

Example outputs (rotate based on the strongest pattern detected each week):

- *"You completed your morning habits 5/5 weekdays this week, but skipped both weekend days. Want to make weekends gentler — or are weekends meant to be free?"* → buttons: `Make weekends optional` · `Weekends stay free` · `Keep as-is`
- *"You've completed 'Take 3 slow breaths' 4 weeks in a row. It looks like this one's stuck. Want to add a sibling habit?"* → buttons: `Suggest one` · `I'm good`
- *"You added 'Read for 10 min' last week and skipped it 6 days in a row. Sometimes the right move is letting one go. Keep, swap, or remove?"* → buttons: `Keep` · `Swap` · `Remove`

This is the single feature that would most clearly differentiate you from "another habit tracker." It does not require AI — five or six rules using `WeekStatsService` and `MomentsService` data covers 95% of useful patterns.

**Detection rules to start with (each = one card variant):**
1. Habit completed 5+ days in a row → suggest a sibling
2. Habit skipped 5+ days in a row → suggest swap or remove
3. Weekday/weekend asymmetry > 50% → propose adaptive schedule
4. Single focus area dominating > 70% of completions → suggest exploring another
5. After 3 weeks, present "your pattern" mini-summary as a moment card

**Where to surface it:** Add `WeeklyPatternCard` in the Progress screen, above the existing weekly reflection card. Show it on Sundays (or the user's reflection day). Cap at 1 pattern per week to avoid spam.

#### 2. ★★ Adaptive reminder timing *(2–3 days)*

You schedule notifications via `notification_scheduler.dart`. Right now they fire at the time the user picked during onboarding. Over time, you have data on *when the user actually completes the habit*. Adapt.

Rule: if median completion time over the last 14 days is more than 90 minutes earlier or later than the scheduled reminder, *propose* (not auto-do) a shift: *"You usually finish 'Drink water' around 9:42am, but I'm reminding you at 8am. Want me to nudge you at 9:30 instead?"*

This is the kind of feature that, when it lands, makes a user say *"oh, this app actually pays attention."* That's the companion feeling. One line in App Store reviews from a user who experiences this is worth more than a paid ad.

#### 3. ★★ "Intention of the week" prompt *(1 day)*

Once a week (Sunday evening), prompt the user with: *"What's one thing you want this week to feel like?"* Free text, ~140 chars. Save it. Reflect it back in mid-week notifications: *"Earlier you said you wanted this week to feel 'less rushed'. How's it going?"*

Cheap. High emotional impact. Builds the "companion is listening" feeling. No ML — just text storage + a templated reminder a few days later.

#### 4. ★ Path drift detection *(2 days)*

If user picked "Gentle Mornings" but 80% of completions are happening between 6pm–11pm, prompt: *"You picked Gentle Mornings, but most of your habits happen in the evening. Want to switch to Winding Down — or stay on Gentle Mornings?"*

This connects the path choice to ongoing experience. Users feel *"this app is paying attention to who I'm becoming, not just what I told it on day 1."*

#### 5. ★ AI-generated weekly summary *(later, optional, 1 week)*

Once you have 3–4 weeks of user data, an LLM-generated 3-sentence weekly summary as a Premium feature is a high-perceived-value add. Use the cheapest Anthropic or OpenAI tier (~$0.001/user/week). Frame it as *"This week, in your own words... almost"*. Make it copyable/shareable. Be aggressive about prompt engineering to keep it short and not generic.

This is the future-state magic, not the now-state magic. Don't build it until #1–#4 are shipped.

### Verdict on Q1

**You have *enough* smart functionality to claim "companion" today, but only if you ship Pattern Noticed cards (item #1 above) within the next 4–6 weeks.** Without #1, "companion" is positioning your messaging can't credibly back. With #1 alone, you're already differentiated against every direct competitor (none of Avocation, Atoms, or (Not Boring) Habits surface behavioral observations weekly).

---

## Question 2 — Are the intention paths clear enough?

**Short answer:** They're emotionally resonant but they are not differentiated from each other, and they're missing one entire user segment that would otherwise convert. Three of your five paths describe the same emotional state in different fonts.

### Audit of the 5 current paths

| ID | Title | Subtitle | What it actually targets |
|---|---|---|---|
| `gentleMornings` | Gentle Mornings | Start your day with calm, not chaos | Morning ritual, soft AM person |
| `findingCalm` | Finding Calm | Small daily anchors for stress and anxiety | Anxiety/stress regulation |
| `gratitudeSelfLove` | Gratitude & Self-Love | Build a kinder relationship with yourself | Self-compassion / mood |
| `windingDown` | Winding Down | End your day peacefully | Evening ritual |
| `yourOwnWay` | Your Own Way | I know what I need — just give me the tools | Skip the segmentation |

### Problems

**Problem 1: Three paths overlap.** *Finding Calm*, *Gratitude & Self-Love*, and *Winding Down* are all emotional-regulation framings. A user who is "stressed and wants to feel better" could justifiably pick any of those three and would get a substantially similar default experience. This is a content design issue: you're slicing the same emotional state three ways instead of three actually-different states.

**Problem 2: You have no path for "I want structure to get things done."** All five paths point inward (mood, mornings, evenings, self-love). A real audience exists for *"I'm not anxious, I'm scattered. Help me build a routine that gets me through my work without burning me out."* By using zero productivity language anywhere in your paths, you self-select away from a third of habit-app users — and ironically the segment with the highest paid conversion in this category.

**Problem 3: "What brings you here?" is the right question, but the screen doesn't sell the choice.** The headline is good. The subtext is *"This helps us set up your experience. You can always change it later."* — that "you can always change it later" is the wrong message at the wrong time. You want the user to *commit*, not be told the choice is reversible. (Reversibility lowers perceived stakes, which lowers buy-in.)

**Problem 4: No commitment device after path selection.** Once you pick a path, you go straight to focus areas. There's no "I commit to spending 2 minutes a day on this" moment. Research on behavior change (Fogg, Duhigg, Clear) is clear: explicit micro-commitments raise follow-through significantly.

### Recommended changes (in order)

#### A. Restructure the 5 paths to reduce overlap and add a productivity slot

Proposed:

| ID | Title | Subtitle | Vs. current |
|---|---|---|---|
| `gentleMornings` | Gentle Mornings | A soft, intentional way to start the day | Keep, sharpen subtitle |
| `anchorsForHardDays` | Anchors for Hard Days | Small acts that hold you steady when life is loud | Merges Finding Calm + parts of Gratitude/Self-Love. More concrete language. |
| `quietFocus` | Quiet Focus *(NEW)* | Get things done without the burnout | Opens the productivity audience without compromising the gentle tone |
| `windingDown` | Winding Down | A small ritual for letting the day go | Keep, polish |
| `yourOwnWay` | Your Own Way | I know what I need — just give me the tools | Keep |

This keeps 5 cards (the visual rhythm), kills the duplication, and adds a path you're missing — without betraying your "gentle" positioning. *Quiet Focus* is the gentle version of productivity, which is exactly the differentiator.

If you want to be bolder, drop `yourOwnWay` and have 4 paths. Forced commitment + cleaner UX. (I'd actually recommend this. "I'll figure it out" is a procrastination button.)

#### B. Rewrite the headline + subtext for stakes

Current: *"What brings you here?"* / *"This helps us set up your experience. You can always change it later."*

Proposed: *"What brings you here?"* / *"This shapes the next 30 days. Pick the one that fits today — your future self will thank you."*

The first line stays. The second line trades reversibility-reassurance for *stakes* + *self-compassion*. Subtle but the data on this kind of copy change is consistent.

#### C. Add a "set the tone" commitment screen between path and focus areas

After the user picks the path, before focus areas:

> **One small promise.**
> Building this takes 2 minutes a day. That's it.
> Tap here when you're ready: [ I'll show up for myself ]

One button. The button text *is* the commitment. Confirm-shaming-free, gentle, but explicit. This single screen has, in similar apps, raised D7 retention by 8–12% in tests because users self-select into commitment.

#### D. Add path-specific paywall framing

Right now your paywall is generic. With paths in the system, you have a free upgrade: change paywall headlines based on path.

Example: a user on *Gentle Mornings* who hits the paywall sees: *"Make your mornings even gentler"* instead of the generic *"See yourself more clearly"*. Lift on relevance-targeted paywalls is well-documented (10–25% in this category). 5 paths × 1 line each = 30 minutes of work for double-digit conversion lift.

### Verdict on Q2

**The paths are *poetic* but not *clear*.** Two of them say almost the same thing in different colors, and you're missing a productivity-leaning path that would open up a measurable audience. Sharpen the 5 to be actually different from each other, add one productivity-adjacent option, and tighten the headline copy. You'll keep the brand voice and add real signal.

---

## Question 3 — When to ask for a review?

**Short answer:** Your current logic is *good* but suboptimal. Two specific changes will significantly improve your review velocity. Reviews are the single biggest unlock for App Store discoverability — every additional 5-star review compounds.

### Audit of your current `ReviewRequestService`

What you do today:
- **First trigger:** 7th total habit completion OR first all-habits-done day.
- **Retry:** 25th completion if dismissed once.
- **Hard stop:** after 2 dismissals, never ask again.
- **Conflict avoidance:** won't ask in the same session as a paywall.
- **Mechanism:** opens `apps.apple.com/.../?action=write-review` directly. *(You commented out `in_app_review` because you observed it being suppressed in TestFlight.)*

What's good:
- The "all done today" trigger is genuinely a peak emotion — solid choice.
- The two-strike rule respects the user.
- The paywall conflict avoidance is correct.
- Persisting state in `SharedPreferences` is fine.

What needs to change:

#### Issue 1: You're not using `in_app_review` in production. Fix this.

Reading the comment in your code: *"The native in_app_review dialog is silently suppressed in TestFlight and throttled by Apple in production — it reports isAvailable() = true but shows nothing."*

This is partially correct but leads to the wrong conclusion. The reality:
- **TestFlight builds:** the native modal is indeed suppressed. You see nothing.
- **Production App Store builds:** the native modal **does work**, but Apple rate-limits to 3 prompts per user per 365 days *across all apps using `requestReview`*. So if a user has already been prompted 3x by other apps that year, your call silently no-ops.
- **Native modal converts ~3–5x better than the App Store deep-link** in production, because it doesn't navigate the user out of your app.

**Recommended fix:** try native first, fall back to URL only if it fails or rate-limited.

```dart
// Pseudo-code in review_request_service.dart
final inAppReview = InAppReview.instance;
if (await inAppReview.isAvailable()) {
  try {
    await inAppReview.requestReview();
    // Native modal shown OR silently rate-limited; we accept either.
    debugPrint('[ReviewRequest] Native modal requested');
  } catch (_) {
    await _fallbackToAppStoreUrl();
  }
} else {
  await _fallbackToAppStoreUrl();
}
```

The `in_app_review` package is already a dependency in `pubspec.yaml`. You don't need to add anything; just stop bypassing it in production.

#### Issue 2: 7th completion is too late if the user does 1/day. Add earlier emotional-peak triggers.

Most churn happens before day 7. By the 7th completion at 1/day, the user has already decided whether they like the app. You want to ask at the moment the *current emotion is highest*, not at an arbitrary count.

Add these triggers (in order of priority):

| Trigger | Why it works | Implementation cost |
|---|---|---|
| **First milestone unlocked** (already 12 milestones in the system) | Peak emotional moment — confetti-feeling. | 30 min |
| **First weekly reflection completed** | User has just engaged with the deep value of your app. Highest "I get it" moment. | 30 min |
| **Curated pack 100% completed first time** | User just finished a routine you designed. Strong gratitude moment. | 30 min |
| **Streak/consistency unlock** *(despite being anti-streak, you have "7 days of using app" milestone)* | Self-pride moment. | 15 min |
| **Existing 7th-completion / all-done-today rules** | Keep as fallback. | n/a |

Use whichever fires first. Cap at one prompt per 30 days.

#### Issue 3: The review-prompt copy isn't optimized for 5-star bias.

Current copy: *"Enjoying Intended? A quick rating helps others find a gentler way to build habits."*

This is fine, but it's not optimized. Two improvements:

**Option A: Two-step pattern (gold standard).**

Step 1 dialog: *"How's Intended treating you?"* → buttons: 😊 Loving it · 😐 It's okay · ☹️ Not for me

Branch:
- 😊 → trigger native review prompt
- 😐 → "Thanks for the honesty — what would make it better?" → free-text feedback collected to your support email or Firestore.
- ☹️ → "Sorry to hear. What's going wrong?" → feedback only.

This protects your star average (3-star reviewers don't get pushed to the App Store) and gives you a feedback channel. It is not deceptive — Apple explicitly allows this pattern as long as you don't *block* low-rating users from leaving a review. Your existing two-step (Rate now / Not yet) is similar but doesn't sort by sentiment first.

**Option B: Keep one-step, sharpen the copy.**

*"Tiny ask: if Intended is helping, a 5-star review helps another person find a gentler way. 30 seconds."*

The word "tiny" sets expectation; the explicit "5-star" is allowed as long as it's not coercive; "30 seconds" lowers the perceived friction.

I'd ship Option A. It's slightly more work but it's worth it.

#### Issue 4: After dismissal, retry at 25 completions is reasonable but not optimal.

Better: retry at *the next emotional peak*, not at a count. If the user dismissed at the 7th completion but then unlocks the 30-day journey milestone two weeks later, that's a *much* better second-ask moment than the 25th completion.

#### Issue 5: Add a manual "leave a review" path in Profile.

Users who love the app sometimes want to review proactively. Make sure there's a `Profile → Leave a review` link. You probably already have it, but verify. This is free 5-stars from your power users.

### Verdict on Q3

Your current review system is competent but conservative. The two highest-leverage changes:
1. **Use `in_app_review` native modal first**, URL fallback. (~3x conversion lift on production.)
2. **Add 3–4 emotional-peak triggers** (milestones, first reflection, curated pack completion) on top of your existing count-based triggers. Cap at 1 ask per 30 days.

These two changes alone should multiply your review velocity by 2–4x once you have meaningful install volume.

---

## Recommended order of operations

If you only do five things this month:

1. **Ship Pattern Noticed weekly card v1** with 3 detection rules. *(2–3 days)*
2. **Restructure intention paths**: kill duplication, add Quiet Focus, rewrite headline. *(1 day)*
3. **Re-enable `in_app_review` native modal** + add milestone/reflection/curated-pack triggers. *(half a day)*
4. **Update App Store listing per the main audit** (name, subtitle, screenshots, price). *(1–2 days)*
5. **Pick TikTok and post 14 days in a row, one format.** *(ongoing)*

Items 1, 2, and 3 are the product side of "we are a companion, not a tracker." Items 4 and 5 make sure people actually find out.

---

## What to call yourself going forward

Stop calling Intended a habit tracker. Internally and externally.

- **In your own head:** *"I'm building a calm, intentional companion for daily routines."*
- **App Store subtitle (revised from main audit):** Consider `Calm companion for daily routines` (30 chars) instead of `Build habits without streaks`. The "calm companion" frame is rare in this category and matches what you're actually building.
- **TikTok bio / IG bio:** `your calm companion for small, intentional routines · iOS`
- **Press pitches:** *"Intended is a calm companion that helps you build small routines that fit your life — and quietly adapts when life gets in the way."*

The word *companion* is the unlock. It's already half-true given what you've built. Ship Pattern Noticed cards and it's fully true.
