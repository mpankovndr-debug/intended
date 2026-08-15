# Intended — Growth Plan

**Written Aug 2026.** Goal: €1,500/month take-home, growing to €3,000/month gross with half reinvested into marketing. Constraints: 6–10 h/week, willing to appear on camera, English first with Russian second.

This is a companion to `INTENDED_V2_HANDOFF_2026-08.md`, which covers the product. That doc's §13 is right — distribution was always the binding constraint. This is the distribution plan.

---

## 0. The number, so nothing downstream is built on a guess

Per **annual** subscriber at €44.99, NL:

| Step | Amount |
|---|---|
| Price paid | €44.99 |
| − VAT 21% (Apple remits) | €37.18 |
| − Apple commission 15% (Small Business Program) | −€5.58 |
| **Your proceeds** | **€31.60/year = €2.63/month** |

Monthly at €5.99 → ~€4.21/month proceeds, but average lifetime is 3–4 months.
Lifetime at €49.99 → ~€35.12, once.

**To net €1500/month** after Dutch income tax (assume ~20–25% effective on a small ZZP profit — verify with your own situation, this is the softest number here) you need roughly **€1,900/month in Apple proceeds**, or ~€23,000/year.

At a realistic mix, that is **600–750 active paying subscribers at the same time.**

Using the handoff's own §3 benchmarks — 5–7% of installs start a trial, ~62% of trials convert → **~3.5% install→paid**:

- **~20,000 installs** to first reach the number
- **~10,000 installs/year afterwards**, forever, to replace annual churn
- ≈ **1,500–1,700 installs/month, sustained**

Handoff §13 estimated 700–1,000 installs. That was sized for 25–30 customers — a validation number, not a salary. **The real target is roughly 20× that.**

### The one thing to internalise

At €3 CPI, €100/month of ads buys ~33 installs → ~1 paying customer → **~€2.63/month back**. That is not "inefficient," it is off by a factor of fifty. Paid advertising is not, and will never be at this budget, your growth channel.

The only free channel with a ceiling above 1,500 installs/month is **short-form video**. Everything else in this plan is either the floor beneath it (ASO) or an amplifier on top of it.

### If you aim higher: €3,000/month with half reinvested

**First, an accounting correction that saves you ~€5,000/year.** Marketing spend is a deductible business expense in NL — it comes off your profit *before* income tax. So "€1,500 netto for marketing" over-taxes itself. You don't earn €1,500 net and then spend it; you spend it pre-tax and it reduces your taxable profit. (In a loss year the expense still counts and losses carry forward — worth an hour with an accountant before you scale spend.)

Modelled correctly:

| Scenario | Take-home | Marketing | Profit needed | **Proceeds needed** | **Subscribers** |
|---|---|---|---|---|---|
| Original | €1,500 | €0 | €1,920 | €1,920 | ~730 |
| Reinvesting | €1,500 | €1,000 | €1,920 | €2,920 | ~1,110 |
| **Reinvesting hard** | **€1,500** | **€1,500** | **€1,920** | **€3,420** | **~1,300** |

So the bigger ambition is **~1,300 simultaneous subscribers**, not 730. Nearly double.

### The finding that matters more than any of this

*(Every figure below is sourced in §9. An earlier draft of this document used my own estimates here and they were wrong in both directions — I had retention too optimistic and CPI too cheap. These are the published 2026 benchmarks.)*

**Lifetime value of a subscriber.** Annual plans in Health & Fitness renew year-1→year-2 at **25–44%**, clustering around 30%. At 30%:

> €31.60 ÷ (1 − 0.30) ≈ **€45 lifetime per subscriber**

**Sanity check that the model is right:** published install-LTV for subscription H&F apps is **$1.21 over 12 months** — the highest of any category. My model says 3.5% × €31.60 = €1.11 in year one. Those agree, which means the arithmetic here is describing something real.

**Value per install** at 3.5% install→paid: **€1.58.**

**Now the prices.** Average iOS CPI in Q1 2026 was **$5.84, up 19% year over year.** By channel:

| Channel | CPI | € equivalent |
|---|---|---|
| TikTok Ads | $2.45 | ~€2.27 — cheapest available |
| Apple Search Ads (global avg) | $2.96 | ~€2.74 |
| Apple Search Ads, competitive fitness keywords | $4–15 | €3.70–13.90 |
| iOS blended average | $5.84 | ~€5.41 |

**You would be paying at minimum €2.27 for something worth €1.58.** Not marginally underwater — structurally, on the cheapest channel that exists.

| Your install→paid | Value per install | Max CPI at 1.5× ROAS | What that unlocks |
|---|---|---|---|
| 3.5% | €1.58 | €1.05 | **Nothing.** Nothing on earth is this cheap. |
| 5% | €2.25 | €1.50 | Still nothing. |
| 7% | €3.15 | €2.10 | TikTok, marginally |
| **7.8%** | **€3.51** | **€2.34** | **TikTok yes; Apple Search Ads at ~1.28× — thin but positive** |
| 9% | €4.05 | €2.70 | TikTok + ASA both work |

### The one channel that may work sooner than the rest

Buried in those benchmarks is something that changes the recommendation: **Apple Search Ads converts Health & Fitness traffic to paid at 7.80%** — more than double the 3.5% blended rate.

Not because it's cheap. Because someone typing "habit tracker no streaks" has already told you they want what you built. Intent converts.

So the paid channel to test first is Apple Search Ads on long-tail terms — and the reason is **conversion quality, not price.** It is still thin (~1.28× ROAS) and the competitive fitness head terms at $4–15 CPI would destroy it. Long-tail only.

### What this does to the priority order

**The highest-leverage work available to you is raising install→paid from 3.5% toward 7–8%, not acquiring more traffic.** Published range for fitness apps is 3–8%, so the top of the band is achievable, not fantasy. One percentage point of conversion is worth more than any amount of ad optimisation — and it's the difference between a marketing budget that compounds and one that burns.

**This is the whole answer to your question.** €1,500/month of marketing budget is not a growth strategy until your install→paid conversion is above roughly 5%, and comfortable above 7%. Below that, every euro you spend destroys value faster the more of it you spend.

Which reframes the priority completely: **the highest-leverage work available to you is raising conversion from 3.5% toward 7%, not acquiring more traffic.** One percentage point of conversion is worth more than any amount of ad optimisation — and it makes the €1,500 budget go from destructive to accelerating.

The good news: the handoff already contains the levers, and two need no code.

1. **Measure it first.** You may already be above 3.5% — step 8 moved the paywall to after the first completed action, and §3 documents that restructure as 8.2% → 19.7% elsewhere. You are guessing at your own most important number. Find it in RevenueCat before doing anything else.
2. **14-day intro trial** — handoff "Yours, not code" item 2. Pure App Store Connect setting, no code.
3. **Better ASO raises conversion, not just volume.** Someone who installs after reading "habit tracker without streaks" is far likelier to pay than someone who installed from a funny video. §2 is a conversion project as much as a traffic project.
4. **The week-one gap** (§12) — day 5 is where people decide whether to keep the app. That's now built, and it should show up in this number.

### The cheaper lever, mentioned once

You need 700 subscribers at €44.99. You'd need 580 at €54.99. Price is the least effortful lever you own, and the handoff already established you shouldn't discount. Revisit annual pricing after you have 100 paying users and can actually read the elasticity — not before.

---

## 1. Week 1 — stop the leaks

Four hours of work here is worth more than a month of content. Do this before anything else.

### 1.1 The Lifetime price is still wrong — €69.99 in App Store Connect

Handoff §"Needs you" item 1: *"The only outstanding item with money attached."* Every lifetime purchase since that decision has been sold at the wrong price, or lost because of it. Fix it in App Store Connect today.

### 1.2 Ship v2

Everything in this plan assumes people arriving at a v2 app. Content driving traffic to the pre-v2 build wastes the traffic and the impression. If v2 isn't live, **shipping it is week one's only job** and content starts week two.

### 1.3 Your App Store name is spending its most valuable asset on a word nobody searches

This is the single biggest ASO finding, so it gets its own heading.

The **App Name** field (30 characters) is the highest-weighted keyword field on the App Store. Yours currently reads "Intended." Nobody types "intended" into App Store search. You are spending 100% of your strongest ranking field on a term with zero search volume.

**But don't call yourself a habit tracker.** An earlier draft of this document suggested `Intended: Habit Tracker`, and that was wrong — not on philosophical grounds but on commercial ones. Three real costs:

1. You compete head-on with Streaks, Habitica and Way of Life on their own word, where a small app ranks near the bottom
2. You set the wrong expectation, which hurts conversion *and* retention — people arrive wanting a checklist
3. It contradicts every one of your screenshots

You don't need *that word*. You need **a searched word**:

> ### `Intended: Habits, No Streaks`
> 28 of your 30 characters

- **"habits"** is the high-volume search term, so you still get found
- **"no streaks"** is your actual differentiator, sitting exactly where a human reads it
- You never claim to be a tracker
- The hidden keyword field carries "tracker" so your name doesn't have to

The App Name field does double duty — it ranks *and* it gets read. This spends both halves well.

---

## 2. ASO — the floor that compounds while you sleep

### What ASO actually is

**App Store Optimization** — making your App Store listing (a) rank higher when someone searches, and (b) convert more of the people who land on it. Two halves that get constantly conflated:

**Getting found (ranking).** Driven by three text fields — App Name, Subtitle, and a hidden 100-character keyword field — plus download velocity and ratings. Apple matches what people type against those fields.

**Getting downloaded (conversion).** Driven by screenshots, preview video, ratings, and the first three lines of your description. They searched, saw ten results, tapped yours — this decides whether they install.

**Why it's first in this plan:** search is **65% of all iOS app discovery**, ahead of browse (18%), referrer (12%) and ads (5%). It's free, and it's the only channel that keeps working while you're asleep.

Handoff §12 calls the App Store page *"the only channel that compounds while you're not working on it."* This is a one-weekend job and then a quarterly review.

### The fields, in order of ranking weight

**1. App Name** (30 chars) — see §1.3 above.

**2. Subtitle** (30 chars) — second-highest weight, and it is *also* the line a human reads. Both jobs at once:

- `Habit tracker without streaks` (29)
- `Gentle habits, no streaks` (25)
- `Habits you can miss a day of` (28)

**3. Keyword field** (100 chars, hidden from users). Rules people get wrong:

- Comma-separated, **no spaces after commas** — spaces waste characters
- Do **not** repeat any word already in your name or subtitle — Apple already indexes those, repeating is pure waste
- Do **not** include your category name, "app", or plurals (Apple handles stemming)
- Apple **auto-combines** words across all fields, so "habit" + "tracker" as separate entries covers "habit tracker"
- Competitor brand names are against guidelines. Don't.

A starting set:

```
routine,daily,mood,journal,selfcare,mindful,ritual,adhd,anxiety,calm,streak,reminder,checklist,wellbeing,intention,gentle,burnout,consistency
```

**4. Screenshots — you already have good ones.** An earlier draft of this assumed launch-day defaults. Wrong: the six that exist are considered, coherent, and better than most of the category.

**What's working, and shouldn't be touched:**

- One colour per screen, consistent system. Distinctive rather than templated.
- Headlines large enough to read at thumbnail size — most indie apps fail exactly this.
- Every headline is a **claim**, not a feature name. *"Going quiet is allowed"* is the best line in the set and nothing else in the category says it.
- The serif display face separates you from the Inter/SF default everyone else uses.
- Caption above, device below. Correct pattern.

**What to change, in priority order:**

**a) The order is costing you.** 90% of viewers see the first two or three. Right now #1 asks a stranger to decode a mosaic before they know what the app *is*.

Reorder to **3 → 4 → 1 → 2 → 5 → 6**:

| Slot | Screenshot | Job |
|---|---|---|
| 1 | "Four small actions. No streaks." | What it is + why it's different |
| 2 | "Going quiet is allowed." | The emotional hook, your strongest line |
| 3 | "Your month, not your score." | Your visual signature — now with context |
| 4–6 | Letter, plan, share card | For the people who swipe |

**b) Screenshot 1's device frame is broken.** No top bezel, content runs to the image edge, tab bar floating over text. Beside five clean full devices with status bars, it reads as a mistake.

**c) Screenshots 2 and 5 open mid-sentence.** #2 starts on a cut-off "YOUR FIRST WEEK", #5 on a half-visible "2 days passed, and then you came back." At full size that reads as *scrolled*. At App Store thumbnail size it reads as *broken rendering*.

**d) "What you're starting with" is missing.** Handoff §5.4 found it *"tested as the strongest thing on the page"* and §12 names it as the lead. It's the only surface that explains the app to a stranger in one glance, and it isn't in the set.

**e) Steal your own line.** *"Nine days away — and it asks for one small thing, not an apology"* is better than anything in your subtitle. Move it to promotional text.

**f) Localise them.** Screenshots are per-language. If you add the RU listing, RU screenshots are a large and cheap conversion lever.

**5. App Preview video** (up to 3, 15–30s each) — autoplays muted in search results. This is the highest-leverage conversion asset on the page and most solo devs skip it. First 3 seconds must land without sound. Show the tile animating into the grid (handoff §5.2: *"the animation is not optional"*) — it's the most visually explicable idea in the product.

**6. Russian localisation of the store listing.** The app already speaks Russian. Adding an RU App Store localisation gets you indexed in Russian-language keyword searches across every storefront where Russian speakers shop. This is free installs sitting on the table. (Note: no IAP inside the Russian storefront itself since 2022 — the money comes from the diaspora storefronts: DE, IL, KZ, GE, the Baltics, US.)

### Two ASC features worth knowing

**Custom Product Pages** — up to 35 alternate pages, each with its own screenshots and its own URL. When a video's hook is "it doesn't count streaks," send that video's link to a product page whose lead screenshot says exactly that. Message-match roughly doubles conversion.

**Product Page Optimization** — Apple's built-in A/B test, up to 3 treatments. Genuinely useful, but it needs traffic to reach significance. At near-zero traffic it will never conclude. Park this until you're over ~1,000 product page views/month.

---

## 3. The content engine — this is the actual plan

Everything above is table stakes. This section is where €1500/month comes from or doesn't.

### 3.1 Why the last attempt failed

Handoff §1: *"prior content (API key leaks, RevenueCat, App Store approval, founder story) reached builders, who don't download habit trackers."*

That is the whole lesson. Indie-hacker content reaches indie hackers. Your buyer is not an indie hacker.

**Never make content about:** Flutter, RevenueCat, Firebase, App Store review, MRR screenshots, "building in public" as a genre, your tech stack, or how you made the app. Not once. It feels productive because it gets engagement from people who will never install.

### 3.2 Who actually downloads this

**Finch's audience is 75% women, primarily 25–35**, with neurodivergent users (ADHD, anxiety, PTSD) reporting they stuck with it when nothing else took. The recurring self-description in this category is *"I have downloaded and abandoned eleven habit trackers."*

They are not looking for productivity. They are looking for permission.

Worth knowing as a ceiling: **Finch reached $30M ARR with no VC money.** This category can carry a solo-built app to a real business.

### 3.2b Is it a men's app?

The 75% figure is Finch's, not yours, and it describes *the incumbent* — not the market.

**The case that men are an opening:** the gentle/self-care wing is saturated with female-coded design — Finch has a pet bird and pastels. Yours doesn't. It's restrained, typographic, no mascot. *"Steadier on hard days"* is not a gendered sentence. Men are dramatically underserved in permission-giving self-care, and an underserved audience is a wedge, not a consolation prize.

**The case against:** the constraint is distribution, not product. The ADHD and mental-health creator ecosystem does skew female, so reaching men there means thinner communities and fewer obvious creators.

**Don't resolve this by argument.** Firebase gives you inferred age and gender for your actual installs. Go look. If you're already near 50/50, the paragraph above this one is wrong about *your* app, and your content should follow your real users rather than the incumbent's.

### 3.3 The positioning line

Your enemy is **the streak**. Not other apps — the streak. It's a shared, specific, emotionally loaded experience that millions of people have had and nobody has named for them.

The single strongest line in your entire product is already written, in handoff §4.3:

> **It doesn't count streaks. It counts how many times you came back.**

That is your hook, your subtitle, your bio, your pinned video, and your screenshot 3. Say it until you are sick of it, and then say it a hundred more times, because each new viewer is hearing it for the first time.

Your credibility anchor is **Lally et al. 2010** — missing a single opportunity did not materially affect habit formation. You have research on your side and every competitor is built as though the opposite were true. That's a content format on its own.

### 3.4 Fifteen hooks to start with

The first line is everything. Nobody watches past a weak first three seconds. These are ordered by how likely they are to reach beyond your followers.

**Problem-first — widest reach, lowest intent**

1. "I had a 187-day streak. I missed one day. I never opened that app again." — near-universal experience
2. "Your habit tracker is the reason you keep quitting."
3. "The research says missing a day doesn't matter. Every habit app is built like it's the end of the world."
4. "Habit trackers give you an empty square for every day you failed. That's not data. That's a scoreboard against yourself."
5. "Three signs your habit tracker is making you worse."

**The product, as an idea — your best converters**

6. "It doesn't count streaks. It counts how many times you came back." *(pin this one)*
7. "I built a habit app that is physically incapable of showing you a bad day." — then show the grid, which only grows
8. "This is what my app says when you disappear for nine days." — read the rescue screen aloud: *"Eight days. That's allowed. Just this one today?"*
9. "My app noticed I was about to quit before I did." — the drift warning
10. "I asked my app to write me a letter about my month. I wasn't ready for it." — read the real letter from the handoff verbatim. That copy is genuinely good and it does the selling for you.

**Visual / satisfying — high shares, low intent, good for reach**

11. Silent screen recording of tiles landing in the grid, one by one. Caption: "one square = one thing you did for yourself." No talking.
12. "Every habit app is a checklist. Mine is a collection."

**Founder, emotionally — builds the trust that converts, without being builder content**

13. "I'm building the app I needed during the year I couldn't get out of bed." — only if true. Do not manufacture this.
14. "Someone emailed me about the app today." — read it. Only if real.
15. "Nobody downloaded my app yesterday. Here's what I'm doing about it." — honest-numbers content performs, *as long as* the emotional frame is the app's purpose, not the business.

**The distinction that keeps #13–15 from becoming builder content:** talk about the *feeling the app addresses*, never the *mechanics of building a business*. "I couldn't get out of bed" is for your buyer. "MRR hit $47" is for indie hackers.

### 3.5 The weekly routine — 6 hours

The failure mode is not producing bad videos. It's producing five videos in week one, three in week two, and none in week five. **Batch, or this dies in month two.**

| When | Time | What |
|---|---|---|
| **Monday** | 90 min | Film 6–8 videos in one sitting. One outfit, one setup, one energy. Don't edit yet. |
| **Monday** | 60 min | Edit all of them. Captions burned in — most people watch muted. |
| **Tue–Sat** | 20 min/day | Post one to TikTok + Reels + Shorts, then spend 20 minutes **commenting on other people's videos** (see below). |
| **Saturday** | 60 min | Look at what performed. Write next week's eight hooks from the winners. |
| **Sunday** | — | Off. Seriously. |

≈ 5.5 hours. Your remaining 1–4 hours go to ASO, Reddit, and creator outreach.

**Post the same video to all three platforms.** Zero extra cost. TikTok and Reels behave differently enough that a flop on one can hit on the other.

**About those 20 minutes — nobody will comment on your first twenty videos.** That's expected, and the step isn't really about your own comments.

Spend the 20 minutes leaving genuinely useful, non-promotional comments on *other people's* videos in your niche — ADHD, burnout, gentle productivity — ones posted in the last few hours with 10k–500k views. Early on, **a good comment on someone else's big video will out-reach your own video.** People click the profile.

When comments do start arriving: reply to every one within the first hour, and when a question is good, answer it *as a video*. That's free content with demand already proven.

### 3.5b Text posts — the hook laboratory

An earlier draft of this said video only. That was too narrow.

**A line that dies as a text post will die as a video too** — and text costs two minutes instead of twenty. So: post ten hooks as text, film the two that land. Text is where you find out what works, cheaply.

**Threads is your best-fit text platform.** It currently rewards personal, first-person, vulnerable writing with unusually high organic reach — which is precisely your app's voice. The letter copy would work on Threads nearly verbatim.

**The honest limit:** text drives far fewer installs per unit of reach, because nobody sees the product. So divide the labour: **text builds audience and tests hooks; video drives installs.** Do both, and don't let text become the comfortable one you hide in.

### 3.6 Craft notes for someone who has never done this

- **First frame, no dead air.** Start mid-sentence. No "hey guys." No logo intro. The hook is spoken within 0.5 seconds.
- **Burn in captions.** Assume muted.
- **Vertical, filmed in decent daylight, phone at eye level.** That's the entire production requirement.
- **One idea per video.** If you have two, that's two videos.
- **Show the app for at least 3 seconds** in most videos — people need to see what they'd be downloading.
- **Link in bio, always.** Say "link in bio" out loud once, near the end.
- **Don't delete flops.** They cost nothing to leave up and TikTok resurfaces old videos months later.

### 3.7 The asset you're actually building

An audience of 20,000 people who trust you on this topic is worth more than any single app, and it survives Intended entirely. Every video builds two things: installs today, and a distribution channel you own forever. If Intended plateaus, the audience is what you'd launch the next thing into. Weight your patience accordingly.

---

## 4. Money — what it can and can't buy

### The rule that governs this whole section

**Money amplifies creative that already works. It cannot find creative that works.**

Every euro of paid spend is a multiplier on a message. If the message converts at 0.5×, spending more makes you lose money faster. This is why the answer to "should I spend €100 or €1,500?" is the same in month one — **neither** — and different in month twelve.

So the budget doesn't change the plan's sequence. It changes how fast you can move through it once §3 has produced a winner.

### Phase A — months 1–6: spend €0

You have no proven message, no measured conversion rate, and an unoptimised store page. Spending here buys expensive noise. Bank the money.

The only exception worth €50–100/month: **Apple Search Ads on long-tail intent keywords** — "habit tracker no streaks", "gentle habit tracker", "habit tracker adhd", "habit app without pressure". These are cheap because volume is low, and the searcher has already articulated your value proposition in their own words. Treat it as a conversion-rate experiment, not an acquisition channel. **Skip Meta entirely at this stage.**

**Creator seeding, which costs nothing.** DM twenty accounts in the 3k–20k range posting about ADHD, burnout, gentle productivity, or mental health. Offer a free lifetime code, no obligation, no script. Most ignore you; two or three post. This is how you find out which creator *style* converts before you pay for any of it.

### Phase B — months 7–12: reinvest 100% of revenue

Revenue at this stage is €200–700/month. All of it goes back into marketing. You take home nothing. This is the investment phase and it is the part most solo founders skip, because taking the €400 feels like progress and reinvesting it feels like standing still.

**What €400 actually buys — the correction.** An earlier draft claimed €150–400 gets you a 20k–150k creator. It doesn't, and you were right to laugh. The published 2026 rates:

| Tier | TikTok video / IG Reel | Note |
|---|---|---|
| 10k–100k followers | **$150–$1,500** | and **health & wellness adds 40–80% on top** |
| 10k–100k, Instagram Reel | $250–$2,500 | Reels price above feed posts |

So at €150–400, with the health premium applied, you are realistically reaching **5k–25k follower accounts** — nano and micro. Not what I wrote.

**The genuinely good news:** nano creators often convert better per follower. Higher trust, less ad fatigue, audiences that actually read the comments. It's a different game, not a worse one.

**Which means the mechanics for a bootstrapped app are not flat-fee sponsorships:**

1. **Gifting** — free lifetime, no obligation, no script. Costs €0. This is how you discover who converts before paying anyone.
2. **Affiliate / bounty** — pay per install or per subscriber rather than per post. Many small creators accept this. Apple has no native IAP affiliate programme, so track via unique `?ct=` links and pay manually. Clunky; fine at your scale.
3. **Spark Ads / Partnership Ads** — when a creator's post performs organically, you pay to run *that exact post from their handle* as an ad. It doesn't read as an ad. This is the most efficient paid mechanism available to an app your size, and it only exists once organic has told you which post to boost.
4. **Telegram** — see §5b. Your €100 buys more real reach there than anywhere else available to you.

### Phase C — months 13+: €1,000–1,500/month, funded by the app

**Only enter this phase if install→paid is above 5%.** That gate is not negotiable — see §0. Below it you are converting revenue into losses at scale.

What €1,500/month realistically buys with proven creative at a ~€3.00 blended CPI (TikTok's €2.27 is the floor; creator fees blend it upward): **roughly 500 installs/month.**

Set against organic short-form at a working format (500–2,000 installs/month), paid roughly **doubles** you. That's the honest expectation. It is not a step change and it does not replace the content engine — it compresses the timeline from ~24 months to ~14.

Allocation at €1,500:

| Line | Budget | Why |
|---|---|---|
| Spark Ads on winning creator posts | €800 | Best CPI available to you. Scales with proven creative. |
| Paid creator posts (4–6/month) | €500 | The pipeline that feeds the line above. Assume half flop. |
| Apple Search Ads | €200 | **Hard ceiling.** Long-tail volume runs out around here; past it you're bidding on competitive fitness terms at $4–15 CPI, where the maths dies. |

Note that ceiling on Apple Search Ads. It's the reason you *cannot* simply deploy €1,500 into ads even if you have it — there is not enough high-intent search volume in your niche to absorb it. The money has to go through creators, which means creator relationships are the real bottleneck, not budget.

### Three rules that don't bend

1. **Never boost a video that hasn't already performed organically.** If it needed money to get views, money won't fix it.
2. **Never spend beyond your measured payback.** At €50 LTV and 14-month payback, aggressive spend is a cash-flow problem even when it's profitable on paper.
3. **Cut a creator after one flop, not three.** The variance is enormous — effective CPI ranges from €0.30 to €15 on the same budget. Winners announce themselves in week one.

### Where does the money come from before the app earns it?

If the €1,000–1,500/month is **reinvested revenue**, the phases above are the plan.

If it's **savings you're willing to deploy now**, you can compress Phase A from six months to three or four — paying creators to test messages for you rather than testing them all yourself. But you'd be buying learning, not installs, and you'd be buying it at a premium. The gate in §0 still applies: don't scale past €300/month of spend until conversion is measured and above 5%.

---

## 5. Reddit and communities — free, slow, real

Low ceiling, but the cost is zero and the users are unusually high-intent.

The subreddits: `r/ADHD`, `r/adhdwomen`, `r/getdisciplined`, `r/selfimprovement`, `r/decidingtobebetter`, `r/CPTSD`, `r/productivity`, `r/habits`.

**Almost all of them ban self-promotion, and they are very good at spotting it.** The play is:

1. Spend four weeks genuinely participating. No links. Answer questions about habit formation using what you learned building this — you actually know the Lally research, which is more than most posters.
2. Put the app in your Reddit profile bio. People check profiles.
3. When someone asks "is there a habit tracker that doesn't guilt-trip me" — and they do, constantly — answer honestly, disclose that you made it.
4. One "I made this" post in the subs that permit it, at most.

Expect a few hundred installs a year from this, not thousands. It's worth the hour a week mostly because it's where you'll learn how your buyer actually talks — which feeds better hooks.

---

## 5b. The Russian-speaking audience — Telegram, and it's your best-value channel

The app already speaks Russian. This is the cheapest reach available to you, by a wide margin.

### Why Telegram and not Instagram

**Telegram delivers 10–20× the organic reach of Instagram and Facebook, at a CPM 3–4× lower.** For a Russian-speaking audience it isn't one option among several — it's where the audience actually lives.

### How to buy it

**Direct channel sponsorships, not the official ad platform.** Telegram's own self-serve Ads platform has minimum budgets around $2,000 (and direct platform access is gated behind a €2M commitment). Ignore it entirely.

Instead, DM channel admins directly, or use a marketplace like Telega.in. **Direct channel advertising is testable on a budget under $200** — that is genuinely within your €100/month, which is true of no Western channel.

Two mechanics worth knowing:
- **Native collaborations** (the admin writes it in their own voice) cost 2–3× a standard sponsored post but convert **4–6× better**. Take the native one.
- **Pinning for 24 hours** adds a 50–100% premium. Skip it at your budget.

### Run your own channel

Costs nothing, and Telegram builds more durable audiences than any Western platform — subscribers see essentially every post, with no algorithm deciding otherwise. Write the philosophy, in Russian, in your own voice. This is the single best fit between your app's writing and a platform's format.

### The constraint you must design around

**Apple removed in-app purchases from the Russian storefront in 2022. Someone in Russia physically cannot subscribe.**

So the target is the diaspora — the largest Russian-speaking populations on storefronts that still take payments: **Germany, Israel, Kazakhstan, Georgia, Armenia, the Baltics, the US, Turkey, Serbia, and the Netherlands.** Choose channels whose audience is emigrant-skewed, and tag every link `?ct=telegram_<channelname>` so you can tell what actually landed rather than guessing.

Also worth doing, since it's free: **VK** (older skew), Russian-language **YouTube Shorts**, and Russian-language **TikTok**, which works fine for the diaspora.

---

## 6. How you'll know if it's working

### The numbers to watch, and where

**App Store Connect → App Analytics** gives you everything free:

- **Impressions** → your ASO reach
- **Product Page Views** → people who clicked through
- **Conversion Rate** (views → downloads) → whether your screenshots work. Category average is roughly 25–35%.
- **Source Type** → the important one. *App Store Search* rising means ASO is working. *Web Referrer* rising means content is working.

**Free attribution, which almost nobody sets up:** append `?ct=` to your App Store link and the campaign shows up in App Analytics.

```
https://apps.apple.com/app/idYOURAPPID?ct=tiktok
```

Use `?ct=tiktok`, `?ct=reels`, `?ct=reddit`, `?ct=creator_name`. Now you know which channel actually delivers instead of guessing.

### The gates — decide in advance, so you're not deciding emotionally later

| When | Check | If it fails |
|---|---|---|
| **Week 2** | You know your actual install→paid rate, from RevenueCat | You are flying blind on the number that decides whether paid marketing is ever available to you. Stop and measure. |
| **Week 6** (~30 videos) | Median views ≥ 300, and at least one video over 3,000 | The **format** is wrong, not the volume. Change hook style before posting another 30. |
| **Week 12** (~60 videos) | At least one video over 50,000 views, and Web Referrer downloads over 200/month | Short-form isn't landing for you. Reassess: different format, or shift weight to ASO + creators. |
| **Month 6** | €150/month revenue | Under €50 with decent install numbers means the problem is the **funnel**, not the traffic — fix conversion before buying more traffic. |
| **Month 12** | €400–600/month | On the curve. Under €150 → the honest conversation about whether this instrument can reach €1500. |

The week-6 gate matters most. The most common failure is posting 200 mediocre videos in the same wrong format, concluding "content doesn't work," and quitting. Volume only compounds once the format is right.

---

## 7. The honest timeline

Two paths. The difference between them is entirely whether you reinvest in months 7–12 instead of taking the money.

| Period | Installs/mo | Revenue/mo | You take home | Marketing spend | What's happening |
|---|---|---|---|---|---|
| **M1–2** | 50–300 | €0–20 | €0 | €0 | ASO live. Conversion measured. First 40 videos. |
| **M3–6** | 300–1,500 | €50–200 | €0 | €0–100 | A format starts working. First video over 50k. Free creator seeding. |
| **M7–12** | 1,000–3,000 | €200–700 | **€0** | **all of it** | Spark Ads on proven creator posts. The investment phase. |
| **M13–18** | 2,000–5,000 | €800–1,600 | €400–800 | €400–800 | Paid roughly doubles organic. Compounding starts. |
| **M19–30** | 3,000–7,000 | €1,900–3,400 | €1,500 | €1,000–1,500 | Target: ~1,300 subscribers, half of revenue reinvested. |

**The reinvested path reaches a bigger number, and reaches €1,500 take-home at roughly the same time as the organic-only path** — because Phase B costs you the months 7–12 income but buys a faster slope afterwards. If you take the money in month 8, you cap out lower and later.

### What has to be true for the bottom row to happen

1. Install→paid at 5%+ (§0). **This is the gate. Nothing below it works.**
2. A content format that produces at least one 50k+ video per month, sustained.
3. Two or three creator relationships whose posts reliably convert.
4. You still posting five videos a week in month 24. This is the one that fails most often.

### The part that stays true regardless of budget

**This is an 18–30 month path to €3,000/month, not a 12-month one**, and there's a real chance it plateaus around €500–800/month — a genuinely good outcome by solo-app standards and still short of your goal.

Do not schedule your vaste lasten against it. If €1,500/month is needed *this year*, the app is the wrong instrument and freelance work is the right one, with this running alongside. That's your call, not mine — but the plan shouldn't pretend otherwise.

---

## 8. This week

- [ ] **Find your actual install→paid conversion rate in RevenueCat.** This decides whether a marketing budget is ever usable. Do it first.
- [ ] Set Lifetime to €49.99 in App Store Connect
- [ ] Turn on a 14-day intro trial in App Store Connect — **now genuinely zero code.** The trial length is read from the live intro offer (`RevenueCatService.trialDays`) and every string that quotes it takes it as a placeholder, in both languages. Flip it in ASC and the app follows.
- [ ] Ship v2, if it isn't live
- [ ] Change the App Name to `Intended: Habits, No Streaks`
- [ ] Rewrite subtitle + keyword field
- [ ] **Reorder the existing screenshots to 3 → 4 → 1 → 2 → 5 → 6.** Ten minutes, and it's the highest-value ten minutes in this list. Then fix #1's broken device frame and the mid-sentence crops on #2 and #5.
- [ ] Check Firebase for your actual age/gender split before writing any content
- [ ] Add the Russian App Store listing localisation
- [ ] Create TikTok, Instagram, YouTube accounts. Same handle everywhere. Bio: *"It doesn't count streaks. It counts how many times you came back."* + App Store link with `?ct=`
- [ ] Film eight videos on Monday from the hooks in §3.4. Start with #6 as your pin.

The rest is doing it every week for a year.

---

## 9. Where the numbers come from

Read this section before trusting any figure above. The claims in this document come from three different places and they do not deserve equal confidence.

### Tier 1 — your own handoff, §3

Not researched here; taken as given because you researched it. Trial start 5–7% of installs · trial→paid ~62% · 90% of trial starts and 44.5% of purchases on Day 0 · paywalls after a value moment 2.1× · Lally et al. 2010 · high-priced apps 3× LTV · H&F annual = 60.6% of category revenue.

### Tier 2 — arithmetic, checkable in ten seconds

The VAT and commission maths (`44.99 ÷ 1.21 = 37.18`, `× 0.85 = 31.60`), the subscriber counts, the LTV and CPI tables. Everything downstream of Tier 1 and Tier 3 is division. Check it.

### Tier 3 — published 2026 benchmarks, verified August 2026

| Claim used above | Source |
|---|---|
| Annual renewal Y1→Y2 in H&F: 25–44%, clustering ~30% | [RevenueCat](https://www.revenuecat.com/blog/growth/average-subscription-renewal-rates-by-app-category/) · [Adapty](https://adapty.io/blog/health-fitness-app-subscription-benchmarks/) |
| Install LTV $1.21 over 12 months, highest of any category | [Airbridge](https://www.airbridge.io/en/blog/subscription-app-pricing-by-category-2026-benchmark) |
| Install→paid for fitness apps: 3–8% | [Adwave](https://adwave.com/resources/fitness-app-advertising) |
| **Apple Search Ads H&F install→paid: 7.80%** | [Adapty](https://adapty.io/blog/apple-ads-install-to-paid-rate-benchmarks/) |
| iOS CPI $5.84 Q1 2026, +19% YoY; TikTok $2.45; ASA $2.96; fitness keywords $4–15 | [Admiral Media](https://admiral.media/mobile-app-marketing-benchmarks-2026/) · [The Social Outline](https://thesocialoutline.com/blog/mobile-app-cpi-benchmarks-2026) |
| Search = 65% of iOS discovery (browse 18%, referrer 12%, ads 5%) | [Digital Applied](https://www.digitalapplied.com/blog/app-store-optimization-aso-statistics-2026-data) · [Searchlab](https://searchlab.nl/en/statistics/app-marketing-aso-statistics-2026) |
| Finch: 75% women, primarily 25–35; $30M ARR without VC | [Sparrow Apps](https://blog.sparrowapps.io/p/finch-how-a-self-care-app-hit-30m-arr-without-vc-money) |
| Micro creator rates $150–$1,500; health niche +40–80% | [Influencer Marketing Hub](https://influencermarketinghub.com/influencer-rates/micro-influencer-rates/) · [ContentGrip](https://www.contentgrip.com/influencer-marketing-rate-card/) |
| Telegram: 10–20× organic reach vs Meta, CPM 3–4× lower; direct channel testing under $200 | [Marketing Agent](https://marketingagent.blog/2026/01/08/the-complete-telegram-marketing-strategy-for-2026-direct-encrypted-and-highly-profitable/) · [CRMChat](https://crmchat.ai/blog/telegram-ads-vs-telegram-outreach-2026-guide) |

### Tier 4 — still estimates, flagged as such

The €3.00 blended CPI in Phase C, the ~€200/month Apple Search Ads volume ceiling in your niche, the Spark Ads discount versus brand creative, and every row of the §7 timeline. These are judgement, not data.

### The number that replaces all of this

**Your own.** RevenueCat knows your real retention and LTV; App Store Connect knows your real conversion. Every benchmark above is a stand-in for a number you will have in week two. When yours disagrees with a table in this document, yours is right.
