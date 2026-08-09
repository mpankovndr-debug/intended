# Intended — Strategy, Diagnosis & 30-Day Plan

**Date:** May 5, 2026
**Status:** Live on iOS for ~1.5 months. Zero paid trials. <100 product page views/month.
**Supersedes:** `INTENDED_HONEST_AUDIT_2026-05.md` and `COMPANION_STRATEGY_2026-05.md`.
**Tone:** Honest. No sugarcoating. The product is well-built; the reasons it's not making money are addressable.

---

## TL;DR

Three things, in order of severity:

1. **Nobody knows it exists.** <100 product page views/month means the funnel doesn't exist yet — no marketing motion is feeding it. This is a distribution problem, not a product problem.
2. **The listing doesn't sell what's actually different.** The copy is poetic, not utility-clear. The name doesn't index for any productivity search. The first screenshots don't communicate the wedge.
3. **The product is positioned wrong in your own head.** You're calling it a habit tracker, but you've actually built the foundation of a *calm companion for daily routines*. Owning that positioning — internally and externally — is the strategic unlock that makes everything else easier.

The 30-day plan below fixes all three. Most of the work is days, not weeks. Almost none of it requires new features.

---

## Part 1 — The strategic reframe: companion, not tracker

A *habit tracker* records what you did.
A *companion* notices what you're doing, reflects it back, and adapts.

The bar for "companion" in 2026 is lower than people think. You do not need a chatbot. You need three loops:

1. **Notice** — the app sees a pattern in user behavior (rule-based; no ML required).
2. **Reflect** — the app surfaces what it noticed, in the user's language.
3. **Adapt** — the app proposes one small change and asks the user to choose.

Right now Intended does step 1 (tracking) and step 2 partially (reflections, warmth messages). It does almost no step 3. Closing that gap is the difference between "another habit app" and a defensible companion product. **It's mostly content + a few light rules — not a rewrite.**

**The honest one-liner you should commit to:**

> Intended is the calm companion that helps you build small routines that actually fit your life — and adjusts when life gets in the way.

That sentence does three things your current copy doesn't:
- Promises a *relationship* ("companion"), not a tool ("tracker").
- Promises *adaptation* ("adjusts when life gets in the way") — the magic word in this category.
- Still respects the gentle wedge ("calm", "small", "fit your life").

**Stop calling Intended a habit tracker. Internally and externally.**

- In your own head: *"I'm building a calm, intentional companion for daily routines."*
- App Store name & subtitle (see Part 5).
- TikTok / IG bio: *"your calm companion for small, intentional routines · iOS"*.
- Press: *"Intended is a calm companion that helps you build small routines that fit your life — and quietly adapts when life gets in the way."*

The word *companion* is the unlock. It's already half-true given what you've built. Ship the Pattern Noticed cards (Part 4) and it's fully true.

---

## Part 2 — What you've actually built

Stripped of poetry, here is your app the way a reviewer would describe it:

> Intended is a Flutter-based iOS app positioned as the gentle, anti-streak alternative to gamified habit apps. Warm glassmorphism aesthetics (Sora + DM Sans, beige/brown palette), Firebase for sync, RevenueCat for IAP, English + Russian localization. Free tier ("Core") covers basic habit tracking with caps on focus areas, custom habits, and swaps. Premium ("Intended+", €5.99/mo · €44.99/yr · €69.99 lifetime, 7-day free trial) unlocks weekly + monthly reflections, a home widget, 10 themes, alternate icons, curated routine packs, shareable moment cards, and removes all caps.

What you're underselling: this is more content personalization than 80% of apps in this category, and the App Store listing barely communicates any of it. Specifically you have:

- **5 Intention Paths** that route warmth messages, notifications, default focus areas, and curated packs.
- **30 path-specific warmth messages + ~15 generic** = ~45 contextual messages.
- **80+ scheduled notifications** that change tone with the user's path.
- **5 hand-built curated packs** (Gentle Mornings, Winding Down, Tiny Resets, Creative Spark, Stay Connected) with deliberate copy ("a rescue kit", "no talent required", "showing up").
- **Habit-specific scientific insights** at completion (25% randomization, 20+ insights).
- **Weekly + monthly reflections** that look back at real user data.
- **12 milestones** across two categories (Journey, Habits).
- **Shareable moment cards** — emotional artifacts.
- **Russian localization** that you're not yet leveraging in marketing.

This is genuinely a lot. The marketing copy and the App Store listing barely communicate any of it.

---

## Part 3 — Strengths and weaknesses

### Strengths (real, not flattery)

1. **Visual craft is top 10% of the category.** The glassmorphism, color system, and Sora + DM Sans pairing is genuinely polished. Most indie habit apps look like a 2018 Notion clone. Yours doesn't.
2. **The "no streaks, no scores" wedge is real.** Streak-pressure burnout is a documented complaint in r/getdisciplined and r/productivity, and apps like Finch (40M+ downloads) prove there's a paying audience for gentler tracking.
3. **Reflection system is a genuine differentiator.** Weekly + monthly reflections + shareable moment cards + curated milestones is more substantive than what most habit apps offer at this price point.
4. **Tech stack is sound.** Flutter + Firebase + RevenueCat + Apple/Google sign-in + Crashlytics. You're not going to ship-debug your way out of a sale.
5. **Russian localization is in.** This is a real lever you're not pulling (more in Part 5, Week 3).
6. **Trial flow is well-designed.** Yearly correctly defaulted, lifetime "launch price" is good anchoring, 7-day trial copy is clean.

### Weaknesses (the honest list)

**1. Your one-line description does not communicate utility.**
- Tagline: *"Intention, not perfection."*
- Descriptor: *"No streaks. No scores. Just small steps that bring you closer to yourself."*

A user scrolling the App Store has 5–7 seconds and is asking *"will this help me build routines?"* — not *"what is this developer's philosophy of life?"* Compare:
- **Finch:** "Self-care pet" → instantly clear what's different.
- **Streaks:** "The To-Do List That Helps You Form New Habits" → instantly clear.
- **Avocation:** "Habit Tracker" → boring but searchable.
- **Intended:** "Intention, not perfection." → reads like a candle scent.

**2. Your name is an SEO problem.**
"Intended" is a high-frequency English dictionary word ("the intended consequence", "as intended"). On the App Store search results for "habits" or "routines" you will not rank, because the word "Intended" matches nothing relevant in those queries.

**3. Your wedge is real but crowded.**
The "anti-streak, gentle, beautiful" pocket is currently held by **Finch (40M+), Avocation, Atoms (James Clear), (Not Boring) Habits, Loop, Habi**. Every one of them is positioned almost identically. You don't have a single concrete reason a stranger picks Intended over Avocation today. *That changes when you commit to "companion" and ship adaptive features (Part 4).*

**4. Your price is too high for an unproven brand.**
- Intended yearly: **€44.99 (~$48)**
- Finch yearly: **$96** (40M users, Apple Editor's Choice, virtual pet hook)
- Atoms yearly: **~$50** (James Clear's brand)
- Avocation yearly: **~$24**
- Stoic: **~$30**
- Streaks: **$5 once**
- Stride: **free**

Apple Search Ads CPI for "habit tracker" is roughly $3–6 in 2026. A strong indie listing in this category typically converts install→trial at 8–15% and trial→paid at 15–25%. At €44.99/yr that math can work — but only after the listing is tuned and social proof exists. Right now you're priced like an established brand and selling like an unknown one.

**5. Your paywall is reactive, not strategic.**
The paywall fires from these places: `'focus_area_limit'` (ceiling), `'custom_habit_limit'` (ceiling), `'browse_habits'`, `'monthly_reflection'`, `'reflection_card'`, `'upgrade_nudge'`, `'profile'`, `'boost'`. **There is no soft paywall after onboarding.** Users complete onboarding, use the app casually, never hit a ceiling, never reflect (reflections need data), and never see the paywall. Hitting a ceiling is the *worst* place to first see "pay €44.99" — the user has just been told *"no, you can't do this thing."*

**6. Your onboarding is too long.**
Welcome → Name → Intention path → Focus areas → Habit reveal → Daily reminder → Theme = **7 steps before first habit.** Best-in-class onboarding in this category (Finch's pattern) is 4–5 steps with a personalization quiz that doubles as a soft paywall.

**7. Zero distribution.**
This is the biggest one. <100 product page views/month means the App Store algorithm has nothing to optimize on. Even at 10% install conversion you'd see <10 installs/mo and proportionally near-zero trials. Organic posting on four channels (TikTok/IG/X/Reddit) without a defined format is, in 2026, almost noise — the algorithm rewards consistency and one identifiable visual style maintained for 2–4 weeks.

**8. No reviews, no social proof, no chicken-egg breaker.**
Zero reviews because near-zero installs. Out: ask every install at the right moment, *and* get the first 20 from your network deliberately.

**9. Russian-market strategy is being ignored.**
You shipped Russian localization but you're posting in English. The Russian-language App Store has dramatically less competition in the gentle-routines niche, lower paid-acquisition costs, and a strong cultural fit for the warm/intentional aesthetic. VK, Telegram channels for self-development, vc.ru — wide open.

---

## Part 4 — Three core product questions

These are the questions you asked. Honest answers.

### Q1: Do you have enough smart functionality for "companion"?

**Short answer:** You have the *foundation* of smart, but it's all static. To deliver on "companion" you need 2–3 small *adaptive* features. None require AI. All are 1–3 days each.

You already have observation (tracking) and expression (warmth, notifications, reflections). You're missing **adaptation** — the moment where the app notices something and offers a small change.

#### The single highest-leverage feature: "Pattern Noticed" weekly card *(2–3 days, no AI)*

Add a new variant of the weekly reflection card. Instead of summarizing what the user did, it surfaces *one observation* and asks *one question*. Pure rule-based.

Example outputs (rotate based on the strongest pattern detected):

- *"You completed your morning habits 5/5 weekdays this week, but skipped both weekend days. Want to make weekends gentler — or are weekends meant to be free?"* → buttons: `Make weekends optional` · `Weekends stay free` · `Keep as-is`
- *"You've completed 'Take 3 slow breaths' 4 weeks in a row. It looks like this one's stuck. Want to add a sibling habit?"* → buttons: `Suggest one` · `I'm good`
- *"You added 'Read for 10 min' last week and skipped it 6 days in a row. Sometimes the right move is letting one go. Keep, swap, or remove?"* → buttons: `Keep` · `Swap` · `Remove`

**Five detection rules to start with (each = one card variant):**
1. Habit completed 5+ days in a row → suggest a sibling.
2. Habit skipped 5+ days in a row → suggest swap or remove.
3. Weekday/weekend asymmetry > 50% → propose adaptive schedule.
4. Single focus area dominating > 70% of completions → suggest exploring another.
5. After 3 weeks, present "your pattern" mini-summary as a moment card.

**Where to surface it:** add `WeeklyPatternCard` in the Progress screen, above the existing weekly reflection card. Show it on Sundays (or the user's reflection day). Cap at 1 pattern per week.

This is the single feature that most clearly differentiates you from "another habit tracker." It does not require AI — `WeekStatsService` and `MomentsService` already have the data. Once shipped, you can credibly call yourself a companion.

#### Three more, in priority order

**2. Adaptive reminder timing *(2–3 days)*** — if median completion time over 14 days is >90 min off the scheduled reminder, *propose* a shift: *"You usually finish 'Drink water' around 9:42am, but I'm reminding you at 8am. Want me to nudge you at 9:30 instead?"*

**3. "Intention of the week" prompt *(1 day)*** — Sunday evening: *"What's one thing you want this week to feel like?"* Free text, ~140 chars. Mid-week notification: *"Earlier you said you wanted this week to feel 'less rushed'. How's it going?"* Cheap. Strong "the app is listening" feeling.

**4. Path drift detection *(2 days)*** — if user picked Gentle Mornings but 80% of completions are 6pm–11pm, prompt: *"You picked Gentle Mornings, but most of your habits happen in the evening. Want to switch to Winding Down — or stay?"*

**(Later, optional) AI-generated weekly summary** — once you have 3–4 weeks of data, an LLM-generated 3-sentence weekly summary as a Premium feature is high-perceived-value. Cheapest Anthropic/OpenAI tier ~$0.001/user/week. Don't build until #1–#4 are shipped.

**Verdict on Q1:** You have *enough* to claim "companion" today, but only if you ship Pattern Noticed cards within the next 4–6 weeks. Without it, "companion" is positioning your messaging can't credibly back. With it, you're already differentiated against every direct competitor.

---

### Q2: Are the intention paths clear enough?

**Short answer:** Emotionally resonant but not differentiated, and missing one entire user segment.

#### Audit of the 5 current paths

| ID | Title | Subtitle | What it actually targets |
|---|---|---|---|
| `gentleMornings` | Gentle Mornings | Start your day with calm, not chaos | Morning ritual |
| `findingCalm` | Finding Calm | Small daily anchors for stress and anxiety | Anxiety/stress regulation |
| `gratitudeSelfLove` | Gratitude & Self-Love | Build a kinder relationship with yourself | Self-compassion / mood |
| `windingDown` | Winding Down | End your day peacefully | Evening ritual |
| `yourOwnWay` | Your Own Way | I know what I need — just give me the tools | Skip segmentation |

**Problems:**

1. **Three paths overlap.** *Finding Calm*, *Gratitude & Self-Love*, *Winding Down* are all emotional-regulation framings. A stressed user could pick any of them and get a substantively similar product. You're slicing the same emotional state three ways.

2. **No path for "I want structure to get things done without burning out."** All five paths point inward. By using zero productivity language, you self-select away from a third of habit-app users — and ironically the segment with the highest paid conversion.

3. **The screen subtext lowers stakes.** *"You can always change it later"* is the wrong message at the wrong time. You want the user to *commit*, not be told the choice is reversible.

4. **No commitment device after path selection.** Behavior-change research is consistent: explicit micro-commitments raise follow-through significantly.

#### Proposed restructure

| ID | Title | Subtitle | Vs. current |
|---|---|---|---|
| `gentleMornings` | Gentle Mornings | A soft, intentional way to start the day | Keep, sharpen subtitle |
| `anchorsForHardDays` | Anchors for Hard Days | Small acts that hold you steady when life is loud | Merges Finding Calm + Gratitude/Self-Love. More concrete. |
| `quietFocus` | Quiet Focus *(NEW)* | Get things done without the burnout | Opens productivity audience without compromising "gentle" |
| `windingDown` | Winding Down | A small ritual for letting the day go | Keep, polish |
| `yourOwnWay` | Your Own Way | I know what I need — just give me the tools | Keep |

If bolder: drop `yourOwnWay` and ship 4 paths. Cleaner UX, forced commitment. Recommended.

#### Headline + subtext rewrite

Current: *"What brings you here?"* / *"This helps us set up your experience. You can always change it later."*

Proposed: *"What brings you here?"* / *"This shapes the next 30 days. Pick the one that fits today — your future self will thank you."*

#### Add a commitment screen between path and focus areas

> **One small promise.**
> Building this takes 2 minutes a day. That's it.
> Tap when you're ready: [ I'll show up for myself ]

One button. The button text *is* the commitment. In similar apps this single screen has raised D7 retention by 8–12%.

#### Path-specific paywall framing (free upgrade)

Right now the paywall is generic. With paths in the system, change paywall headlines based on path. A *Gentle Mornings* user hitting the paywall sees: *"Make your mornings even gentler"* instead of the generic *"See yourself more clearly"*. Lift on relevance-targeted paywalls is well-documented (10–25% in this category). 5 paths × 1 line = 30 minutes of work.

**Verdict on Q2:** Sharpen the 5 paths to be actually different from each other, add Quiet Focus to open a real productivity-adjacent audience, and tighten the headline copy. You keep the brand voice and gain measurable signal.

---

### Q3: When to ask for a review?

**Short answer:** Your current logic is *competent but conservative*. Two specific changes will roughly 2–4x your review velocity.

#### Audit of current `ReviewRequestService`

What you do today:
- **First trigger:** 7th total habit completion OR first all-habits-done day.
- **Retry:** 25th completion if dismissed once.
- **Hard stop:** after 2 dismissals, never ask again.
- **Conflict avoidance:** won't ask in the same session as a paywall.
- **Mechanism:** opens `apps.apple.com/.../?action=write-review` directly. *(You commented out `in_app_review`.)*

What's good: "all done today" is a peak-emotion trigger; two-strike rule respects user; paywall conflict avoidance is correct; persisting in `SharedPreferences` is fine.

#### Issue 1: You're not using `in_app_review` in production. Fix this.

Your code comment says: *"The native in_app_review dialog is silently suppressed in TestFlight and throttled by Apple in production."* Partially correct, wrong conclusion:

- **TestFlight builds:** native modal is suppressed. You see nothing. (This is what you observed.)
- **Production App Store builds:** native modal **does work**, but Apple rate-limits to 3 prompts per user per 365 days *across all apps*. If a user has been prompted 3x by other apps, your call silently no-ops.
- **Native modal converts ~3–5x better** than the App Store deep-link in production, because it doesn't navigate the user out of your app.

**Fix:** try native first, fall back to URL only if it fails or rate-limited.

```dart
// In review_request_service.dart, replace _showPrompt's 'rate' branch:
final inAppReview = InAppReview.instance;
if (await inAppReview.isAvailable()) {
  try {
    await inAppReview.requestReview();
    // Native modal shown OR silently rate-limited; we accept either.
  } catch (_) {
    await _fallbackToAppStoreUrl();
  }
} else {
  await _fallbackToAppStoreUrl();
}
```

The `in_app_review` package is already in `pubspec.yaml`. Just stop bypassing it in production.

#### Issue 2: 7th completion is too late if user does 1/day. Add emotional-peak triggers.

Most churn happens before day 7. By the 7th completion at 1/day, the user has already decided whether they like the app. Ask at the moment current emotion is highest, not at an arbitrary count.

Add these triggers (use whichever fires first; keep existing rules as fallback; cap 1 ask per 30 days):

| Trigger | Why it works | Effort |
|---|---|---|
| **First milestone unlocked** (you have 12 milestones) | Peak emotional moment — confetti-feeling. | 30 min |
| **First weekly reflection completed** | User just engaged with your deepest feature. Highest "I get it" moment. | 30 min |
| **Curated pack 100% completed first time** | User just finished a routine *you* designed. Strong gratitude moment. | 30 min |
| **Existing 7th-completion / all-done-today** | Keep as fallback. | n/a |

#### Issue 3: Add a sentiment two-step (gold standard pattern)

Replace the single "Rate now / Not yet" dialog with:

**Step 1:** *"How's Intended treating you?"* → 😊 Loving it · 😐 It's okay · ☹️ Not for me

**Branch:**
- 😊 → trigger native review prompt
- 😐 → *"Thanks for the honesty — what would make it better?"* → free-text feedback to your support email or Firestore.
- ☹️ → *"Sorry to hear. What's going wrong?"* → feedback only.

This protects your star average (3-star reviewers don't get pushed to the App Store) while still capturing their feedback. Apple explicitly allows this pattern as long as you don't *block* low-rating users from leaving a review on their own (you're not — they can still rate manually from Profile).

#### Issue 4: Add a manual "Leave a review" path in Profile.

Free 5-stars from power users. Verify this exists; if not, add it.

**Verdict on Q3:** Two changes — `in_app_review` native modal first + emotional-peak triggers — should multiply your review velocity 2–4x once you have meaningful install volume.

---

## Part 5 — Competitive map (May 2026)

| App | Yearly | Wedge | What you can learn |
|---|---|---|---|
| **Finch** | $96 | Virtual pet for self-care | Soft paywall after personalization quiz. "43% off" anchored on yearly. |
| **Atoms (James Clear)** | ~$50 | Tiny habits, identity-led | Behavior-science framing: *"1% better every day."* |
| **Avocation** | ~$24 | Plant grows when you complete habits | Visible reward replaces streak. Closer to your aesthetic than you'd like. |
| **(Not Boring) Habits** | ~$30 | Premium aesthetic, fluid 3D | Pure aesthetic-driven. Pricing premium possible because of brand. |
| **Streaks** | $5 once | Streak-based, classic | The thing you're explicitly NOT. Use as foil. |
| **Habi** | Varies | Social/shared habits | Different wedge — accountability. |
| **Stoic** | ~$30 | Journaling-led | Shows journaling-as-habit pulls a paying audience. |

**Where Intended sits today:** crowded "gentle/aesthetic/anti-streak" pocket with no concrete differentiator vs. Avocation or (Not Boring) Habits other than your specific reflections + curated routines combo. That combo *is* defensible — but only if you commit to "companion" and ship Pattern Noticed cards. Then you're in your own slot: not a tracker, not a journaling app, not a self-care pet — a calm companion that adapts.

---

## Part 6 — The diagnosis

```
[App Store Search/Featured] → [Product Page] → [Install] → [Onboarding Complete] → [Paywall Seen] → [Trial Started] → [Trial Converted]
       ?                          <100/mo           ?              ?                    ~0                 0                 0
```

**Where you're broken:**
- **Top of funnel:** catastrophic. Awareness is the binding constraint.
- **Listing → install:** untested. With <100 PV no statistical signal yet, but the listing copy is poetic-not-utility-clear, suggesting low conversion when traffic arrives.
- **Onboarding → paywall:** structurally broken. Most users never see the paywall.
- **Paywall → trial:** untested. The paywall itself is well-designed.

**The single most important sentence:**
You don't have a conversion problem yet. You have a "nobody is in the funnel" problem. **Fix distribution first, listing second, paywall trigger third, price fourth.** In that order.

---

## Part 7 — The 30-day plan

Each item: **what**, **why**, **how**. Do them in this order. Do not skip ahead.

### Week 1 — Listing surgery + paywall trigger fix + review service fix

**1. Rewrite App Store name + subtitle.** *(2 hours; ASC submits, ~24h review)*
- **Name (30 char max):** `Intended: Calm Companion` (24 chars). Keeps brand. "Companion" is rare in this category and will index for searches like *"self care companion"*, *"wellness companion"*.
- **Subtitle (30 char max):** `Daily routines, made gentler` (28 chars). OR `Gentle routines that adapt` (26 chars). Pick the one that matches your gut.
- **Keywords field (100 chars):** `routine,habit tracker,companion,journal,reflection,mindful,wellness,goals,self care,calm,daily`
- *Why:* App Store algorithm in 2026 weights name > subtitle > keyword field. "Intended" alone matches no productivity search. "Calm Companion" is differentiated *and* searchable.

**2. Replace the first 3 screenshots.** *(4–6 hours)*
- First 2 screenshots account for >70% of conversion impact. Apple indexes screenshot caption text since June 2025. Treat captions as keyword content.
- Each must have a caption overlay with a keyword + benefit:
  - **Screenshot 1:** caption *"A calm companion for daily routines"*. Show home screen with 2–3 habits + a soft completion animation.
  - **Screenshot 2:** caption *"Notices what works. Adapts when life gets in the way."* Show a Pattern Noticed card or weekly reflection. (If Pattern Noticed isn't shipped yet, use the weekly reflection card.)
  - **Screenshot 3:** caption *"No streaks. No scores. No guilt."* Show the home screen completion state without any streak counter.
  - **Screenshots 4–6:** features (widget, moments, milestones, themes).

**3. Move the paywall to the right place.** *(1 day of dev work)*
- Keep ceiling-triggered paywalls.
- **Add a soft paywall at the end of onboarding**, immediately after the user picks habits. Copy: *"Start your 7-day free trial of Intended+ to unlock weekly reflections and unlimited routines. Skip if you'd rather start with Core — it's yours forever."* Two buttons: "Start free trial" (primary), "Continue with Core" (secondary, smaller).
- Track separately: `paywall_source = 'onboarding_soft'` so you can measure.
- *Why:* This is Finch's pattern. Right after onboarding is peak intent — the user just told you their goals.

**4. Drop the launch price by ~33%.** *(15 min in App Store Connect + RevenueCat)*
- Recommended: **€2.99/mo, €19.99/yr (Save 44%), €49.99 lifetime**.
- *Why:* Volume of trials matters more than ARPU right now. You need (a) review velocity, (b) payback signal to optimize, (c) word-of-mouth seed users. Raise prices later when you have 50+ reviews and 4.5+ stars. Pricing is a dial, not a tattoo.

**5. Fix `ReviewRequestService`.** *(half a day)*
- Use `in_app_review` native modal first; URL fallback only if it fails.
- Add three new triggers: first milestone unlocked, first weekly reflection completed, first curated pack 100% completed.
- Cap at 1 ask per 30 days (across all triggers).
- (Later) Add the sentiment two-step pattern (😊/😐/☹️). For Week 1 just fix the mechanism.

**6. Fix the paywall feature copy.** *(30 min in `app_en.arb`)*
- Current title *"See yourself more clearly"* → *"Get the full Intended experience"*. Sell features at paywall, not philosophy.
- Current feature 5 *"Unlimited habits, swaps, and focus areas — no ceiling on growth"* → *"Unlimited everything — no caps on habits or swaps."*

### Week 2 — Distribution: pick ONE channel. Go deep.

You said you've been doing organic on TikTok/IG/X/Reddit. Four channels with mediocre output on each. **Pick TikTok. The right one for this app and audience.**

**7. TikTok content engine — one format, 14 posts in 14 days.** *(45–90 min/post, faster over time)*

The format that works for indie habit/companion apps in 2026 is **silent screen recording + on-screen captions + low-stakes ambient music**. Pick one and stick with it for 14 days — the algorithm needs 2–4 weeks of consistent format to find your audience.

- **Format A — "POV: you're tired of streak guilt"** — 30s silent screen recording, opening the app, completing a habit, soft bloom animation, no streak counter. Caption: "no streaks. no guilt. just intention."
- **Format B — "I built this because"** — founder-on-camera, 60–90s, *"I built a habit app because Streaks made me anxious. Here's what I changed:"* + screen recording. Authenticity wins on TikTok in 2026.
- **Format C — "5 things that won't shame you"** — list format, 5 features, each ~10s with screen recording.
- **Format D — Quiet ASMR-y demo** — pure aesthetic, no voiceover, soft music, just the glassmorphism animations. Your visual craft is the differentiator — show it.

Post **once per day at the same time**. Don't switch formats. Don't read comments emotionally. Most indies quit at day 4. Don't.

**8. Seed the first 20 reviews.** *(2 hours)*
- DM 20 friends/family/Twitter followers personally with: *"Hey — launched my routine companion app. Would mean a lot if you tried it for a day and left a 5-star review with one honest sentence. Here's the link. No pressure."*
- Verify the in-app review prompt fires on the new triggers (Week 1 item 5).

### Week 3 — Russian/CIS market + product fixes

**9. Russian-language launch push.** *(4–6 hours of writing)*
- Submit Intended to **vc.ru, habr.ru, Pikabu** as a "indie hacker journey" story (with screenshots). vc.ru audience eats up solo-developer founder stories.
- Post in Russian-language Telegram channels: *"Боль продуктивности"*-style channels, self-development channels with 5k–50k subs, DM admins.
- **Russian App Store subtitle** specifically. Don't Google Translate. Hire 1 hour from a native speaker on Upwork (~$15) to translate "Calm companion for daily routines" into Russian that lands emotionally.
- Russian indie communities: Russian Indie Hackers, Pikabu's IT communities.

**10. Onboarding compression + commitment screen.** *(1–2 days)*
- Merge Intention path + Focus areas selection where possible. From 7 onboarding steps to 5.
- Move Theme selection to *after* habit completion #1 (skin in the game = more engagement with personalization).
- Add the **commitment screen** between path and focus areas (Part 4, Q2): *"One small promise. 2 minutes a day."* + button *"I'll show up for myself."*

**11. Restructure intention paths.** *(1 day, copy + minor enum changes)*
- Replace 5 current paths with: `gentleMornings`, `anchorsForHardDays`, `quietFocus`, `windingDown`, `yourOwnWay` (or drop `yourOwnWay` for 4 cleaner paths).
- Update `intention_path.dart`, `app_en.arb`, `app_ru.arb`, and the path-specific warmth/notification strings (~30 strings × 2 languages).
- Update headline subtext: *"This shapes the next 30 days. Pick the one that fits today — your future self will thank you."*
- Add path-specific paywall headlines (5 lines, free 10–25% conversion lift).

### Week 4 — Companion features + measure + scale

**12. Ship Pattern Noticed v1.** *(2–3 days)*
- Implement the 5 detection rules in Part 4, Q1.
- Add `WeeklyPatternCard` widget above `WeeklyReflectionCard` in Progress screen.
- Show on user's reflection day. Cap 1/week.
- *This is the feature that makes "companion" honest.* Most important product change of the month.

**13. Measure everything.** *(ongoing)*
- App Store Connect → Analytics: Impressions, Product Page Views, Conversion Rate by source. <2% PPV→install means listing problem; >5% means scale.
- RevenueCat: trial start rate and trial→paid by `paywall_source`. If `onboarding_soft` outperforms `focus_area_limit`, double down.
- Firebase Analytics: D1, D7, D30 retention. <15% D7 = product issue; >25% = marketing scale issue.

**14. Apple Search Ads — small targeted experiment.** *(€100 budget)*
- After listing is updated, run **€10/day for 10 days** on: `habit tracker`, `gentle habits`, `routine companion`, `daily routine`, `mindful habits`. ASA Discovery first.
- *Why:* cheapest way to get statistically significant traffic to your product page so you can measure true conversion.

**15. Apply for Apple Editor's Choice / "Best New Apps".** *(2 hours)*
- Use [Featuring Nominations](https://developer.apple.com/contact/app-store/promote/) form. Pitch: indie, hand-crafted, anti-streak, calm companion. Apple does feature small indie apps with strong design — your aesthetic is good enough to qualify. Don't expect a hit; the upside is enormous and the cost is paperwork.

---

## Part 8 — Success metrics

Realistic 30-day targets if you execute the plan:

| Metric | Today | 30-day target |
|---|---|---|
| Product Page Views / month | <100 | 1,500–3,000 |
| Install conversion (PPV → install) | unknown | 4–8% |
| Installs / month | <10 | 80–200 |
| Onboarding completion rate | unknown | >65% |
| Trial start rate (of installs) | ~0% | 8–15% |
| Trials / month | 0 | 8–25 |
| Paid conversions / month | 0 | 2–6 |
| Reviews | 0 | 15–30 |
| MRR | €0 | €30–€120 |

These are *signal* numbers, not lifestyle-business numbers. They tell you whether the funnel is working at small scale so you can scale it. Indie companion-style apps that hit these numbers at day 30 typically reach €1k–€3k MRR by month 6 if they keep iterating.

---

## Part 9 — What NOT to do

1. **Don't rebuild the app.** The product is fine. The marketing and packaging are the bottleneck.
2. **Don't pivot the wedge.** "Calm companion for daily routines, no streaks, no scores" is real and worth defending. Stay there. Sharpen the messaging.
3. **Don't go cross-platform yet.** Android adds ~30% engineering overhead and lower ARPU. Wait until iOS is consistently profitable.
4. **Don't add new features beyond Pattern Noticed in the next 30 days.** Every founder's instinct when sales are zero is "the app needs more features." It doesn't. It needs more eyeballs.
5. **Don't pay for influencers yet.** At your current funnel state, paid hits are wasted. Fix listing + paywall trigger first so the traffic that arrives actually converts.
6. **Don't keep calling it a habit tracker.** Internally too. Words shape strategy. *"Calm companion for daily routines."* Out loud, in your bio, in your pitches.

---

## Part 10 — The honest closing

You built a beautiful app. Zero trials at 1.5 months is not a verdict on your craft. It's the default outcome of every indie app that ships without a distribution plan, because shipping is the easy 5% and distribution is the brutal 95%. Almost nobody warns you about this part.

The "calm companion, no streaks, no scores" wedge is real and worth defending. The aesthetic is genuinely top-tier. The technical foundation is solid. The intention paths can be sharpened in a day. The Pattern Noticed feature can be shipped in three. The listing can be updated this week.

**The reasons this isn't paying yet are all addressable in 30 days.** Pick the Week 1 items, do them this week, and you will have more signal in 14 days than you've had in the last 45.

Ship the listing changes by Friday.

Good luck.
