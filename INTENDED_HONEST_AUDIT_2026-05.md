# ⚠️ SUPERSEDED — see `INTENDED_STRATEGY_2026-05.md`

**This document has been merged into the unified strategy doc.**
The unified version updates the positioning (now "calm companion", not "habit tracker"), the App Store listing recommendations, and integrates the answers to the three product questions (smart functionality, intention paths, review timing).

**Read this instead:** [INTENDED_STRATEGY_2026-05.md](INTENDED_STRATEGY_2026-05.md)

The original content of this file is preserved below for reference, but it contradicts the unified doc in places. Trust the unified doc.

---

# Intended — Honest Audit & 30-Day Recovery Plan

**Date:** May 5, 2026
**Status:** Live on iOS for ~1.5 months. Zero paid trials. <100 product page views/month.
**Auditor's note:** No sugarcoating. The app is well-built. The reason it's not making money is not the product — it's three things, in order of severity: nobody can find it, the listing doesn't sell what makes it different, and you're priced for an established brand without one yet.

---

## Part 1: What you actually built

Stripped of poetry, here is your app described the way a reviewer would describe it:

> Intended is a Flutter-based iOS habit tracker positioned as the "anti-streak, gentle, intentional" alternative to gamified habit apps. It uses warm glassmorphism aesthetics (Sora + DM Sans, beige/brown palette), Firebase for sync, RevenueCat for IAP, and ships in English and Russian. Free tier ("Core") covers basic habit tracking with caps on focus areas, custom habits, and swaps. Premium tier ("Intended+", €5.99/mo · €44.99/yr · €69.99 lifetime, 7-day free trial) unlocks weekly + monthly reflections, a home screen widget, 10 themes, alternate app icons, curated routine packs, shareable moment cards, and removes all caps.

That description is your real product. Everything below is judged against it.

### Strengths (and they are real)
1. **Visual craft is top 10% of the category.** The glassmorphism, color system, and typography pairing (Sora display + DM Sans body) is genuinely polished. Most indie habit apps look like a 2018 Notion clone. Yours doesn't.
2. **The "no streaks, no scores" wedge is a real wedge.** Streak-pressure burnout is a documented complaint in r/getdisciplined and r/productivity, and apps like Finch have proven there's a 40M+ user audience for gentler tracking.
3. **Reflection system is a genuine differentiator.** Weekly and monthly reflections + shareable moment cards + curated milestones is more substantive than what most habit apps offer at this price point.
4. **Tech stack is sound.** Flutter + Firebase + RevenueCat is the right indie stack for 2026. Apple/Google sign-in is in. Analytics is wired. Crashlytics is in. You're not going to ship-debug yourself out of a sale.
5. **Russian localization is in.** This is a real lever you're not pulling (more in Part 4).
6. **Trial flow exists and is well-designed.** Yearly is correctly defaulted; lifetime "launch price" is good anchoring; 7-day trial copy is clean.

### Weaknesses (the honest list)

**1. Your one-line description does not communicate utility.**
- Tagline: *"Intention, not perfection."*
- Descriptor: *"No streaks. No scores. Just small steps that bring you closer to yourself."*

This is poetry. It tells a stranger nothing about what the app does. A user scrolling the App Store has 5–7 seconds and is asking *"will this help me build habits?"* — not *"what is this person's philosophy of life?"* Compare:
- **Finch:** "Self-care pet" → instantly clear what's different
- **Streaks:** "The To-Do List That Helps You Form New Habits" → instantly clear what it is
- **Avocation:** "Habit Tracker" → boring but searchable
- **Intended:** "Intention, not perfection." → reads like a candle scent

**2. Your name is an SEO disaster.**
"Intended" is a high-frequency English dictionary word ("the intended consequence", "as intended", etc). On the App Store search results for "habits" or "habit tracker" you will not rank, because the word "Intended" matches nothing relevant in those queries. People who type "intended" on the App Store are not looking for a habit tracker.

**3. Your wedge is real, but you are not the only one occupying it.**
The "anti-streak, gentle, beautiful, intentional" pocket is currently held by **Finch (40M+ downloads), Avocation, Atoms (James Clear), (Not Boring) Habits, Loop, and Habi**. Every one of them is positioned almost identically to you. You don't have a single concrete reason a stranger picks Intended over Avocation. "It's prettier" doesn't show up in a search result.

**4. Your price is too high for a brand-new app with no reviews.**
- Intended yearly: **€44.99 (~$48)**
- Finch yearly: **$96** (but: 40M users, mature brand, Apple Editor's Choice, virtual pet hook)
- Stoic: **~$30/yr**
- Atoms: **~$50/yr** (but: James Clear's brand)
- Avocation yearly: **~$24/yr**
- Streaks: **$5 one-time**
- Stride: **free**

A new app with zero reviews and no brand authority cannot price at the same level as Finch or Atoms. The Apple Search Ads CPI for the "habit tracker" cluster in 2026 is roughly $3–6 per install and a typical install→trial conversion for a strong indie listing in this category is 8–15%, with trial→paid around 15–25%. At €44.99/yr that math can work — but only after you've tuned the listing and built social proof. Right now you are pricing like an established brand and selling like an unknown one.

**5. Your paywall is reactive, not strategic.**
Reading the codebase, the paywall fires from these places:
- `'focus_area_limit'` (ceiling hit)
- `'custom_habit_limit'` (ceiling hit)
- `'browse_habits'`
- `'monthly_reflection'`, `'reflection_card'` (reading reflections)
- `'upgrade_nudge'` (banner)
- `'profile'` (manual)
- `'boost'`

There is **no hard paywall in onboarding, and no soft paywall on day 2–3 after first habit completion.** This means users complete onboarding, use the app casually, never hit a ceiling, never reflect (because reflections require enough days of data), and **never see the paywall.** You are showing the paywall to the wrong people at the wrong time. Hitting a ceiling is the most punishing place to first see "pay €44.99" because the user has just been told *"no, you can't do this thing."*

**6. The onboarding is too long.**
Welcome → Name → Intention path → Focus areas → Habit reveal → Daily reminder → Theme = **7 steps before first habit.** Best-in-class onboarding in this category in 2026 is 4–5 steps with a personalization quiz that doubles as the soft paywall (Finch's pattern). Each extra step shaves ~5–8% off completion.

**7. Zero distribution.**
This is the biggest one. <100 product page views per month means the App Store algorithm has nothing to optimize on. Even at 10% install conversion (high) you'd see <10 installs/mo and proportionally near-zero trials. Organic TikTok/IG without a defined content format is, in 2026, almost noise — the algorithm rewards consistency and one identifiable visual style maintained for 2–4 weeks, not occasional posts about an app.

**8. No reviews, no social proof, no chicken-egg breaker.**
You have no reviews because you have no installs because you have no reviews. The only way out of this is to (a) ask every install for a review at the right moment, and (b) get the first 20 reviews from your personal network deliberately. There is no shame in this — it's how everyone does it.

**9. Russian-market strategy is being ignored.**
You shipped Russian localization but, based on what you described, you're posting on TikTok/IG/X/Reddit (English-speaking platforms). The Russian-language App Store has dramatically less competition in the gentle-habits niche, lower paid-acquisition costs, and a strong cultural fit for the warm/intentional aesthetic. VK, Telegram channels for self-development, and Russian-language Reddit equivalents (Pikabu, dev.by) are wide open.

---

## Part 2: Competitive map (May 2026)

| App | Yearly | Wedge | What you can learn from them |
|---|---|---|---|
| **Finch** | $96 | Virtual pet for self-care; gentle | Soft paywall after personalization quiz. "43% off" anchored on yearly. |
| **Atoms (James Clear)** | ~$50 | Tiny-habits, identity-led | Behavior science framing: "1% better every day". |
| **Avocation** | ~$24 | Plant grows when you complete habits | Visible reward replaces streak. Closer to your aesthetic than you'd like. |
| **(Not Boring) Habits** | ~$30 | Premium aesthetic, fluid 3D | Pure aesthetic-driven. Pricing premium possible because of brand. |
| **Streaks** | $5 once | Streak-based, classic | The thing you're explicitly NOT. Use as foil. |
| **Habi** | Varies | Social/shared habits | Different wedge — accountability with friends. |
| **Stoic** | ~$30 | Journaling-led | Shows journaling-as-habit pulls a paying audience. |

**Where Intended sits:** crowded "gentle/aesthetic/anti-streak" pocket, with no concrete differentiator vs. Avocation or (Not Boring) Habits other than your specific reflections + curated routines combo. That combo *is* defensible — but it's not communicated in your listing or marketing.

---

## Part 3: The real diagnosis

If you do nothing else, internalize this funnel:

```
[App Store Search/Featured] → [Product Page] → [Install] → [Onboarding Complete] → [Paywall Seen] → [Trial Started] → [Trial Converted]
       ?                          <100/mo           ?              ?                    ~0                 0                 0
```

**Where you're broken:**
- **Top of funnel: catastrophic.** Awareness is the binding constraint. No marketing motion is consistent enough to feed the funnel.
- **Listing→install: untested.** With <100 PV you have no statistical signal yet, but the listing copy is poetic-not-utility-clear, which suggests a low conversion rate when traffic does arrive.
- **Onboarding→paywall: structurally broken.** You don't show the paywall during the moment of highest intent (right after the user has just told the app what they want to change about their life). Most users never see the paywall.
- **Paywall→trial: untested.** The paywall itself is well-designed, but with so few people seeing it you have no data.

**The single most important sentence in this audit:**
You don't have a conversion problem yet. You have a "nobody is in the funnel" problem. Fix distribution first, listing second, paywall trigger third, price fourth. In that order.

---

## Part 4: 30-day executable plan

Each item lists **what**, **why**, **how**, and **time estimate**. Do them in this order. Do not skip ahead.

### Week 1 — Listing surgery + paywall trigger fix

**1. Rewrite your App Store name + subtitle.** *(2 hours, ASC update + 24h review)*
- Current name in store: probably "Intended" alone. **Change to:** `Intended: Gentle Habit Tracker` (30 chars) — keeps brand, captures the search term *"habit tracker"*.
- Subtitle (30 chars): replace "Intention, not perfection" with **`Build habits without streaks`** or **`Routines, reflections & calm`** — depending on which you want to rank for.
- Keywords field (100 chars): pack it. Suggested: `habits,habit tracker,routine,journal,reflection,mindful,wellness,goals,self care,calm,daily`
- *Reasoning:* App Store algorithm in 2026 weights name > subtitle > keyword field. "Intended" alone matches no productivity search. Adding "Gentle Habit Tracker" makes you indexable for the right queries.

**2. Replace your first 3 screenshots.** *(4–6 hours)*
- The first 2 screenshots account for >70% of conversion impact (Apple now indexes screenshot caption text since June 2025).
- Each screenshot must have a **caption overlay** with a keyword and a benefit. Suggested copy:
  - Screenshot 1: caption *"Build habits — without the streak pressure"*. Show your home screen with 2–3 habits checked.
  - Screenshot 2: caption *"Reflect weekly. See your real patterns."* Show a weekly reflection card.
  - Screenshot 3: caption *"Beautiful. Calm. Yours."* Show theme picker / app icons.
  - Screenshots 4–6: features (widget, moments, milestones).
- *Reasoning:* Indie devs reported 90%+ download lifts from first-2-screenshot redesigns in 2026.

**3. Move the paywall to the right place in the flow.** *(1 day of dev work)*
- Keep ceiling-triggered paywalls.
- **Add a soft paywall at the end of onboarding**, immediately after the user picks habits. Copy: *"Start your 7-day free trial of Intended+ to unlock weekly reflections and unlimited habits. No card now if you skip — Core is yours forever."* Two buttons: "Start free trial" (primary), "Continue with Core" (secondary, smaller, gray).
- *Reasoning:* This is Finch's pattern and the reason their trial-start rate is so high. The user just spent 2 minutes telling you their goals — this is the moment of peak intent.
- Track conversion separately with `paywall_source = 'onboarding_soft'` so you can measure.

**4. Drop the launch price by 33%.** *(15 minutes in App Store Connect + RevenueCat)*
- Recommended new prices: **€2.99/mo, €19.99/yr (Save 44%), €49.99 lifetime**.
- *Reasoning:* You are an unproven brand with zero reviews. Volume of trials matters more than ARPU right now because you need (a) review velocity, (b) payback signal to optimize, (c) word-of-mouth seed users. You can raise prices later when you have 50+ reviews and 4.5+ stars. Pricing is a dial, not a tattoo.

### Week 2 — Distribution: pick ONE channel and go deep

You said you've been doing organic on TikTok/IG/X/Reddit. That's four channels with mediocre output on each. **Pick one. The right one is TikTok for this app and audience.**

**5. TikTok content engine — one format, 14 posts in 14 days.** *(45–90 minutes per post, but production gets faster)*

The format that works for indie habit apps in 2026 is **"silent screen recording + on-screen captions + low-stakes ambient music"**. Examples of formats that have worked for Finch, Avocation, and Habi:

- **Format A — "POV: you're tired of streak guilt"**: 30s silent screen recording showing you opening the app, completing a habit, getting a gentle bloom animation, no streak counter. Caption: "no streaks. no guilt. just intention."
- **Format B — "I built this because"**: founder-on-camera, 60–90s, *"I built a habit app because Streaks made me anxious. Here's what I changed:"* + screen recording. Authenticity wins on TikTok in 2026.
- **Format C — "5 things that won't shame you"**: list format, 5 features, each ~10s with a screen recording.
- **Format D — Quiet ASMR-y demo**: pure aesthetic, no voiceover, soft music, just the glassmorphism animations. Your visual craft is the differentiator — show it.

Post **once per day at the same time** for 14 days. Don't switch formats. Don't read the comments emotionally. The algorithm needs 2–4 weeks of consistent format to figure out who to show your stuff to. Most indies quit at day 4.

**6. Seed the first 20 reviews.** *(2 hours)*
- DM 20 friends/family/Twitter followers personally with: *"Hey — launched my habit app. Would mean a lot if you tried it for a day and left a 5-star review with one honest sentence. Here's the link. No pressure if not."*
- Bake your in-app review prompt to fire **after the user completes their 5th habit** (not the 1st — too early; not the 30th — they'll have churned). Use `in_app_review` package which you already have.

### Week 3 — Russian/CIS market + product fixes

**7. Russian-language launch push.** *(4–6 hours of writing)*
- Submit Intended to **Pikabu, vc.ru, habr.ru** as a "indie hacker journey" story (with screenshots). vc.ru audience eats up startup founder stories from solo developers.
- Post in Russian-language Telegram channels: *"Боль продуктивности"*, *"Психология здорового человека"*, *"IT-каналы / запуски"*. Search Telegram for `@productivity_ru` style channels with 5k–50k subs and DM the admins.
- **Russian App Store subtitle** specifically. Don't use Google Translate. Hire a 1-hour native speaker from Upwork (~$15) to translate "Gentle habit tracker. No streaks." into something that hits emotionally in Russian.
- Russian press: try out Russian Indie Hackers, Russian r/iOSApps equivalents.

**8. Onboarding compression.** *(1 day)*
- Merge "Intention path" + "Focus areas" into a single screen with a 2-step picker. You go from 7 steps to 5.
- Move "Theme selection" to *after* habit completion #1 — when the user has skin in the game, they're more likely to engage with personalization, and one less onboarding step.

**9. Fix the paywall feature copy.** *(30 minutes in `app_en.arb`)*
- Current paywall feature 5: *"Unlimited habits, swaps, and focus areas — no ceiling on growth"*. The phrase "no ceiling on growth" is meta-poetic. Simpler: *"Unlimited everything — no caps on habits or swaps."*
- Current title: *"See yourself more clearly"*. Change to: *"Get the full Intended experience"*. You're selling features at the moment of paywall, not philosophy. Save philosophy for the onboarding screens, where it belongs.

### Week 4 — Measure, iterate, prepare next phase

**10. Measure everything.** *(ongoing)*
- App Store Connect → Analytics: track Impressions, Product Page Views, Conversion Rate, by source (Search vs Browse vs External). Look at the conversion rate column. <2% means listing problem. >5% means listing is working — go scale.
- RevenueCat dashboard: trial start rate, trial→paid rate, by `paywall_source`. If `onboarding_soft` performs better than `focus_area_limit`, double down on it. If worse, you may have priced too high.
- Firebase Analytics: D1, D7, D30 retention. Habit apps that retain at D7 < 15% have a product issue, not a marketing issue.

**11. Apple Search Ads — small, targeted experiment.** *(€100 budget)*
- Once your listing is updated, run **€10/day for 10 days** on the keywords: `habit tracker`, `gentle habits`, `habit app`, `daily routine`, `mindful habits`. Use ASA Discovery campaigns first.
- *Reasoning:* This is the cheapest way to get statistically significant traffic to your product page so you can measure the listing's true conversion rate.

**12. Apply to Apple Editor's Choice / "Best New Apps".** *(2 hours)*
- Use the [App Store Connect "Featuring Nominations"](https://developer.apple.com/contact/app-store/promote/) form. Pitch: indie, hand-crafted, anti-streak, mindfulness/wellness category. Apple does feature small indie apps with strong design — your aesthetic is genuinely good enough to qualify. Don't expect a hit, but the upside of getting featured for a week is enormous and the cost is just paperwork.

---

## Part 5: What success looks like

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

These numbers are not "lifestyle business" yet. They are *signal* numbers. They tell you whether the funnel is working at small scale so you can confidently scale it. Indie habit apps that hit these numbers at day 30 typically reach €1k–€3k MRR by month 6 if they keep iterating.

---

## Part 6: What NOT to do

1. **Don't rebuild the app.** The product is fine. The marketing and packaging are the bottleneck.
2. **Don't pivot the wedge.** "Gentle, anti-streak, intentional" is a real niche with paying users. Stay there. Sharpen the messaging instead.
3. **Don't go cross-platform yet.** Android adds ~30% engineering overhead and the productivity-app ARPU is lower on Play Store. Wait until iOS is consistently profitable.
4. **Don't add new features.** Every founder's instinct when sales are zero is "the app needs more features." It doesn't. It needs more eyeballs.
5. **Don't pay for influencers yet.** At your current funnel state, paid influencer hits are wasted. First fix listing + paywall trigger so the traffic that arrives actually converts.

---

## Closing — the part that's not in the bullet points

You built a beautiful app. The fact that you have zero trials at 1.5 months is not a verdict on your craft. It's the default outcome of every indie app that ships without a distribution plan, because shipping is the easy 5% and distribution is the brutal 95%. Almost nobody warns you about this part.

The "no streaks, no scores" wedge is real and worth defending. The aesthetic is genuinely top-tier. The technical foundation is solid. **The reasons this isn't paying yet are all addressable in 30 days.** Pick the items in Week 1, do them this week, and you will have more signal in 14 days than you've had in the last 45.

Good luck. Ship the listing changes by Friday.
