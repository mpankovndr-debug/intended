# Intended — Growth Plan

**Written Aug 2026.** Goal: €1500/month netto. Constraints: 6–10 h/week for marketing, €100/month budget, willing to appear on camera, English first with Russian second.

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

Change it to carry the category:

- `Intended: Habits, Gently` — 24 chars
- `Intended — Gentle Habit Log` — 27 chars
- `Intended: Habit Tracker` — 23 chars

The third ranks best; the first is most on-brand. Pick one and don't agonise — you can change it with any release.

---

## 2. ASO — the floor that compounds while you sleep

Handoff §12 flags the App Store page as *"the only channel that compounds while you're not working on it"* and notes it's probably still launch-day defaults. This is a one-weekend job and then a quarterly review.

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

**4. Screenshots** — 90% of viewers see only the first two or three, and most never swipe. Handoff §5.4 found the **"What you're starting with"** card was the strongest thing on the day-one page, and §12 recommends it as the lead. Do that. Suggested order:

1. "What you're starting with" — their intention, actions, focus areas. Explains the app to a stranger in one glance.
2. The grid, with the caption **"one square = one thing you did"** rendered large in the screenshot caption, not just in-app.
3. The line that is your actual differentiator: **"It doesn't count streaks. It counts how many times you came back."**
4. The letter.
5. The widget in situ.

Put a **text caption above each screenshot** in the image itself. Screenshots without captions convert measurably worse — people don't decode UI, they read.

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

The gentle-habit-tracker audience, from Finch's demographics and the category generally: **overwhelmingly women, 18–34**, and heavily overrepresented for ADHD, anxiety, depression, and burnout recovery. The recurring self-description is *"I have downloaded and abandoned eleven habit trackers."*

They are not looking for productivity. They are looking for permission.

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
| **Tue–Sat** | 20 min/day | Post one to TikTok + Reels + Shorts. Then **stay in the comments for 20 minutes** — early engagement is what the algorithm reads. This is not optional and it is the step people skip. |
| **Saturday** | 60 min | Look at what performed. Write next week's eight hooks from the winners. |
| **Sunday** | — | Off. Seriously. |

≈ 5.5 hours. Your remaining 1–4 hours go to ASO, Reddit, and creator outreach.

**Post the same video to all three platforms.** Zero extra cost. TikTok and Reels behave differently enough that a flop on one can hit on the other.

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

## 4. Where the €100/month goes

**Months 1–2: nowhere. Save it.** You have nothing to amplify yet, no data on what converts, and no creative that has proven itself organically. Spending now buys you noise.

**Months 3–6: split it.**

- **€50 — Apple Search Ads**, on long-tail intent keywords only: "habit tracker no streaks", "gentle habit tracker", "habit tracker adhd", "habit app without pressure". These are cheap because they're low-volume, and the person searching them has already articulated your exact value proposition. This is the only place ads make sense at your budget. Skip Meta entirely.
- **€50 — one creator collaboration per month.** Not a €50 sponsored post from a 100k account (they'll say no, and it wouldn't convert anyway). Instead: DM twenty accounts in the 3k–20k range who post about ADHD, burnout, gentle productivity, or mental health. Offer a free lifetime code and no obligation. Most will ignore you; two or three will post. The €50 goes to the one whose free post actually drove installs — pay them to do it again.

**Never boost a video that hasn't already performed organically.** Amplification multiplies what's working; it can't create it. If a video hit 100k views on its own, then and only then consider putting money behind it.

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
| **Week 6** (~30 videos) | Median views ≥ 300, and at least one video over 3,000 | The **format** is wrong, not the volume. Change hook style before posting another 30. |
| **Week 12** (~60 videos) | At least one video over 50,000 views, and Web Referrer downloads over 200/month | Short-form isn't landing for you. Reassess: different format, or shift weight to ASO + creators. |
| **Month 6** | €150/month revenue | Under €50 with decent install numbers means the problem is the **funnel**, not the traffic — fix conversion before buying more traffic. |
| **Month 12** | €400–600/month | On the curve. Under €150 → the honest conversation about whether this instrument can reach €1500. |

The week-6 gate matters most. The most common failure is posting 200 mediocre videos in the same wrong format, concluding "content doesn't work," and quitting. Volume only compounds once the format is right.

---

## 7. The honest timeline

| Period | Installs/month | Revenue/month | What's happening |
|---|---|---|---|
| Month 1–2 | 50–300 | €0–20 | ASO live. First 40 videos. Mostly learning. |
| Month 3–6 | 300–1,500 | €50–200 | A format starts working. First video over 50k. |
| Month 7–12 | 1,000–3,000 | €200–700 | Back catalogue compounding. ASO lifting on real download velocity. |
| Month 13–24 | 1,500–4,000 | €700–1,900 | Target reachable — if the format held. |

**This is a 12–24 month path.** Do not schedule your vaste lasten against it. There is a real, non-trivial chance it plateaus at €300–500/month, which would be a good outcome by app-business standards and still not your goal.

If €1500/month is needed *this year*, the app is the wrong instrument for it and freelance work is the right one. That's your call and not mine to make — but the plan shouldn't pretend otherwise.

---

## 8. This week

- [ ] Set Lifetime to €49.99 in App Store Connect
- [ ] Ship v2, if it isn't live
- [ ] Change the App Name to include a searched term
- [ ] Rewrite subtitle + keyword field
- [ ] Rebuild screenshots, leading with "What you're starting with", captions burned in
- [ ] Add the Russian App Store listing localisation
- [ ] Create TikTok, Instagram, YouTube accounts. Same handle everywhere. Bio: *"It doesn't count streaks. It counts how many times you came back."* + App Store link with `?ct=`
- [ ] Film eight videos on Monday from the hooks in §3.4. Start with #6 as your pin.

The rest is doing it every week for a year.
