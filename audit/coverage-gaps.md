# Coverage gaps — competitor libraries and community language

*Research companion to [`intention-library.md`](intention-library.md). Collected 2026-08-23.*
*Report only. No recommendations, and no intention text was written by me — every item below
is quoted from a source and linked.*

## Access limits — read this before trusting any count

**Three of the sources named in the brief could not be reached from this session.** I did not
substitute remembered content for them. Verbatim attempts and their exact failures:

| source | method attempted | result |
|---|---|---|
| reddit.com (r/ADHD, r/adhdwomen, r/CPTSD, r/depression_help, r/getdisciplined, r/selfcare) | WebSearch with `allowed_domains: ["reddit.com"]` | `API Error: 400 The following domains are not accessible to our user agent: ['reddit.com']` |
| reddit.com / old.reddit.com | WebFetch, incl. `.json` endpoint | `Claude Code is unable to fetch from www.reddit.com` / `...from old.reddit.com` |
| old.reddit.com | in-app browser `preview_start` | `https://old.reddit.com is blocked by policy` |
| tiktok.com | WebFetch on a public hashtag page | returned only the page shell (`TikTok - Make Your Day`); no captions or comments in the HTML |
| quora.com | WebFetch | `HTTP 403 Forbidden` |

Instagram was not attempted separately: its comment threads are login-gated and the same
client restrictions apply.

**What I used instead.** Sources that publish *crowdsourced first-person submissions* from the
same populations — principally The Mighty, whose depression and ADHD listicles are built from
reader submissions printed verbatim with attribution. This is a substitute, not an equivalent:
The Mighty submissions are lightly edited and self-selected for usefulness, so they skew toward
*what helps* rather than *what I can't do*. Reddit's raw register is absent from this data set.
**Every item below is labelled with which source it came from; none is labelled Reddit.**

**Target vs. delivered:** brief asked for 60–100 distinct items; **95 collected**, all quoted and linked.

---

## TASK 1 — Competitor libraries

Seven apps requested. Item-level text was verifiable for **one** (Finch). Default lists live
inside the apps, and App Store screenshots are images — unreadable by a text fetcher. Everything
unverified is marked so, and left empty rather than filled.

| app | item text verified? | what is verified | source |
|---|---|---|---|
| Finch | **YES** — ~120 items | full suggested-goal lists by category | [Finch wiki, Goals](https://finch.fandom.com/wiki/Goals) |
| Routinery | PARTIAL | category names, 2 preset names, their steps | [MakeUseOf review](https://www.makeuseof.com/review-routinery-app-wellness-habits/) |
| Fabulous | PARTIAL | first journey name, first habit, ritual slots | [Zapier](https://zapier.com/blog/best-habit-tracker-app/), [Bustle](https://www.bustle.com/wellness/fabulous-app-good-habits-review-features-price) |
| Streaks | PARTIAL | that presets exist + 4 preset *types* | [MacStories](https://www.macstories.net/reviews/streaks-6-brings-habit-tracking-to-your-home-screen-with-extensively-customizable-widgets/), [The Sweet Setup](https://thesweetsetup.com/how-to-track-your-habits-using-streaks/) |
| Habitify | **UNVERIFIED** | mechanism only (AI suggestions, pre-made templates; default areas Morning/Afternoon/Evening) — **no item text found** | [Habitify Help Center](https://intercom.help/habitify-app/en/articles/11957562-get-started-with-habitify) |
| Productive | **UNVERIFIED** | **no item text found** — App Store description names no habits | [App Store](https://apps.apple.com/us/app/productive-habit-tracker/id983826477) |
| Done | **UNVERIFIED** | **no item text found**; app is built on "streaks/chains" | [EducationalAppStore review](https://www.educationalappstore.com/app/done-a-simple-habit-tracker) |

### 1.1 Finch — suggested goals, verbatim

**Source caveat, stated once and applying to every Finch item below:** this is a fan-maintained
CC-BY-SA wiki, not Finch's own documentation. The page carries a banner reading *"This page needs
a review and update. This feature has been affected by a Finch update."* The wiki also says the
Suggested list is *"a random serving of the ideas they've got"* and *"by no means complete."*
Treat as a large verified sample, not a complete or current library.
Source for all of 1.1: [finch.fandom.com/wiki/Goals](https://finch.fandom.com/wiki/Goals)

**"Easy Wins" — formerly titled "Just survive the day" (14 items).** The wiki describes this as
*"a specific category containing minimal suggestions for getting through a bad day."*

- Change clothes
- Literally survive the day
- Brush teeth
- Drink hot water
- Look in the mirror and say "I can do it"
- Drink water
- Stand up for 10 seconds
- Step outside once
- Take 3 deep breaths
- Get out of bed
- Take a shower
- Wash face
- Name one person who cares for me
- Just be

**Sleep (17).**

- Setup computer screen to use warm colors at night
- Avoid caffeine after 3PM
- Complete breathing exercise before bed
- Leave bed after 20 mins if I can't fall asleep
- Hot shower one hour before sleep
- Write goals for tomorrow before sleeping
- Dim lights before bed
- Turn on airplane mode on phone 30 mins before bed
- Don't take a nap
- Avoid snacking after 7PM
- Research how CBTI can help insomnia
- Read something relaxing before bed
- Make a gratitude list before sleeping
- Avoid YouTube after 9PM
- Listen to a free SleepCove podcast episode to sleep
- Stop using phone 1 hour before bed
- Use blackout curtains to reduce light during sleep

**Exercise / "Movement" (13, incl. one duplicate in the source).**

- 3 push-ups
- Go on a 10 minute stroll outside with a podcast
- 10 second plank
- Walk around the neighborhood
- 5 sit-ups
- 10 crunches
- 5 squats
- 5 burpees
- 10 jumping jacks
- 10 crunches
- Morning Yoga
- 5 lunges
- Yoga

**Loved Ones (17).**

- Express gratitude to mom
- Express gratitude to dad
- Offer a helping hand to someone
- Tell mom I love her
- Tell dad I love him
- Wrote one positive thing about today
- Spend time with the family
- Share a fond memory with family
- Cook a meal for family
- Surprise a friend with a small gesture
- Tell an old friend that I miss them
- Share a fond memory with a friend
- Cook a meal for a friend
- Reconnect with a friend I haven't talked to in a while
- Thank someone who helped make life easier
- Reach out to a friend
- Plan a game night with friends

**Presence (5).**

- Avoid using social media during work
- Uninstall apps from my phone that don't spark joy
- Enjoy lunch without multi-tasking
- Avoid mindlessly using Twitter
- Avoid mindlessly using YouTube

**Tidy Up (9, incl. one duplicate in the source).**

- Wash bed sheets
- Laundry
- Organize my closet
- Make my bed
- Pick clothes off the floor
- Take out the trash
- Clean kitchen countertops
- Put away one item that is not in its place
- Take out the trash

**"Suggested" — uncategorised rotating list (50).**

- Wash dishes
- Start a personal journal or blog
- Donate unused clothes
- 5 burpees
- Bake cookies for someone
- Use blue light blocking glasses before sleeping
- Write goals for tomorrow before sleeping
- Yoga
- Laundry
- Start a piggy bank for a cause
- Share a fond memory with a friend
- Vacuum my room
- Reconnect with someone I haven't talked to in a while
- Plant a tree or start a small garden
- Wash bathroom towels
- Volunteer at an animal shelter
- Cook a meal for family
- Go offline for a full day for digital detox
- Enjoy lunch fully without multi-tasking
- 5 sit-ups
- Get emails in inbox to zero
- Leave bed after 20mins if I can't fall asleep
- 5 squats
- Leave quarters at the laundromat
- Let someone behind me in line go in front
- Clean kitchen countertops
- Wash face
- Organize a family or friends get-together
- Dim lights before bed
- Shower and wash hair
- Write a positive comment on the internet
- Offer seat to someone else on public transport
- Vacuum living room
- Reduce screen time by one hour
- Turn on airplane mode on phone 30 mins before bed
- Avoid mindlessly using YouTube
- Buy a warm meal for someone in need
- Take 3 deep breaths
- Walk around the neighborhood
- Design a personalized workout plan for yourself
- Stretch
- Respond to 3 personal messages
- Complete a DIY project for your home
- Take a professional profile photo for networking
- Dedicate a day to declutter your living space
- Read a book that inspires growth and positivity
- Give my umbrella to a stranger
- Volunteer for a day at a local organization
- Create your own vision board for the year
- Open a new savings account for a specific goal
- Clear out unused browser tabs

### 1.2 Routinery — verified fragments

Preset categories: **Morning, Evening, The Famous, Productivity, Health, Relationships.**
Named presets: **"Miracle Morning routine"**, **"Get Some Fresh Air routine"**.
Steps named inside them: *making the bed, meditation, affirmation exercises, visualization
exercises, a walk, and reading* (Miracle Morning); *"a quick walk, stretching, and meditation"*
(Get Some Fresh Air). Each step carries a time allocation and a countdown timer.
Source: [MakeUseOf](https://www.makeuseof.com/review-routinery-app-wellness-habits/).
Full per-preset step lists: **UNVERIFIED.**

### 1.3 Fabulous — verified fragments

Every user starts on a first journey titled **"An Unexpected Journey"**, whose first habit is to
**drink a glass of water first thing in the morning**. Rituals are slotted **morning, afternoon,
evening**. Source: [Zapier](https://zapier.com/blog/best-habit-tracker-app/),
[Bustle](https://www.bustle.com/wellness/fabulous-app-good-habits-review-features-price).
The remaining journey and ritual item text: **UNVERIFIED** — the reviews I could reach describe
structure, not item names ([Liven review](https://theliven.com/blog/wellbeing/dopamine-management/fabulous-app-review) confirmed to name none).

### 1.4 Streaks — verified fragments

Presets exist and are grouped into categories; the only preset *types* named in reachable text
are **"hand washing, ECG, and energy deficit tasks"** and **"dietary health tasks"**
([MacStories](https://www.macstories.net/reviews/streaks-6-brings-habit-tracking-to-your-home-screen-with-extensively-customizable-widgets/)).
The Sweet Setup's walkthrough names no presets — only the reviewer's own tasks ("Meditation",
"Mindfulness Minutes", "Read Bible"), which are **not** app defaults
([The Sweet Setup](https://thesweetsetup.com/how-to-track-your-habits-using-streaks/)).
Preset item text: **UNVERIFIED.**

### 1.5 Habitify, Productive, Done — UNVERIFIED

| app | what the source actually says | source |
|---|---|---|
| Habitify | users "select from the **suggestions by AI** based on your existing habit(s) **pre-made templates** and adjust them, or **create a custom habit** from scratch"; default areas are Morning, Afternoon, Evening. **No template is named.** | [Help Center](https://intercom.help/habitify-app/en/articles/11957562-get-started-with-habitify) |
| Productive | App Store description names no habits. The only habit-shaped string on the page is inside a customer review: "I have a plant I water every two weeks, always on Saturday's" — a user's own habit, **not a default**. | [App Store](https://apps.apple.com/us/app/productive-habit-tracker/id983826477) |
| Done | No default list found. Verified only that it "helps you set goals, tracking your progress, and then motivating you with streaks/chains". | [EducationalAppStore](https://www.educationalappstore.com/app/done-a-simple-habit-tracker) |

---
## TASK 2 — Community language

**95 distinct items, all verbatim.** Column *action core* is a neutral description I added
so the item can be classified in Task 3 — it is deliberately not written as intention copy.
`†` marks items I judge **smaller than other apps include** (below the granularity of any
competitor list in Task 1).

### Sources

| key | source | type |
|---|---|---|
| M47 | ["47 Little Things You Can Do If Depression Is Keeping You Home Today" (community submissions)](https://themighty.com/topic/depression/what-to-do-at-home-depression/) — The Mighty | community submissions |
| MDH | ["16 Dental Hygiene 'Hacks' for When You're Too Depressed to Brush Your Teeth" (community submissions)](https://themighty.com/topic/depression/dental-hygiene-depression/) — The Mighty | community submissions |
| MGO | ["The Daily and Weekly Goals of Someone With Depression and Anxiety" (author's own goal list)](https://themighty.com/topic/depression/anxiety-depression-small-goals/) — The Mighty | first-person author |
| IDM | ["The ultimate guide for when depression makes hygiene hard" (editorial micro-steps)](https://idontmind.com/journal/the-ultimate-guide-for-when-depression-makes-hygiene-hard) — IDONTMIND | editorial |
| MAD | ["When ADHD Makes Everything Seem Like Work" (first-person essay)](https://themighty.com/topic/adhd/when-adhd-makes-everything-seem-like-work/) — The Mighty | first-person author |
| M22 | ["22 Things From My Everyday Routine That 'Go Out the Window' When I'm Depressed" (community submissions)](https://themighty.com/2017/06/depression-no-motivation-tasks-chores) — The Mighty | community submissions |
| ADD | ["Why Getting Started Is So Difficult for Adults with ADHD" (reader survey responses, verbatim)](https://www.additudemag.com/getting-started-adhd-challenges/) — ADDitude | survey verbatim |

### Items

| id | verbatim | who | src | action core | † |
|---|---|---|---|---|---|
| C01 | "Brush my teeth and change my clothes. Even if I'm not doing anything else that day, doing those two things makes me feel as if I did do something" | Cassandra R. | M47 | brushing teeth; changing clothes |  |
| C02 | "I make sure I take my dog out, and give him his treats and play at least one round of ball or rope with him" | Kimberly D. | M47 | caring for a pet |  |
| C03 | "I try to do at least one thing in the house a day" | Alissa E. | M47 | one household task |  |
| C04 | "Paint my nails. Small act of self care." | Christina H. | M47 | painting nails |  |
| C05 | "I would open all of our windows early in the morning, sit down in the porch and drink a hot cup of coffee" | Isay B. | M47 | opening windows; sitting with a drink |  |
| C06 | "I will actively tell myself "I am alive," even if I don't feel alive" | Ceilidh M. | M47 | saying a sentence to yourself | † |
| C07 | "Work on my jigsaw puzzle." | Roxanne B. | M47 | working on a puzzle |  |
| C08 | "Put on some perfume that you like and hop out if bed and move somewhere else it could be the couch" | Chloe R. | M47 | putting on scent; moving off the bed | † |
| C09 | "Make yourself something to eat that you enjoy. It gets you doing something, even if it's just a bowl of cereal." | Justine P. | M47 | eating something |  |
| C10 | "sitting on the living room couch and talking to my pet" | Alejandra F. | M47 | talking to a pet | † |
| C11 | "I make a list of three things on my bad days and when I complete them I count it as a win against the depression" | Patricia L. | M47 | writing a three-item list |  |
| C12 | "I open the curtains. Just letting some natural light in" | Ashley M. | M47 | opening curtains | † |
| C13 | "Turn on the lights to make the room brighter even if I'm going to sleep all day." | Jennifer B. | M47 | turning on a light | † |
| C14 | "I try and read a book, something to transport me away" | Becky U. | M47 | reading |  |
| C15 | "Text at least one person." | Tanya H. | M47 | texting one person |  |
| C16 | "Breathe. It's something our bodies do naturally and something I can control" | Talia B. | M47 | breathing |  |
| C17 | "I play guitar." | Claudiu S. | M47 | playing an instrument |  |
| C18 | "I talk to my partner. I talk about the stuff I can't explain — that I'm having a bad day and I don't know why" | Nat N. | M47 | telling someone you are struggling |  |
| C19 | "I try and spend at least 10 minutes a day talking to someone else" | Lydia A. | M47 | ten minutes of conversation |  |
| C20 | "Sometimes I get up and stand on one leg. It's a simple, almost silly thing but it can feel like the only thing I have control over" | Emily J. | M47 | standing on one leg | † |
| C21 | "Make dinner for my family." | Ashley R. | M47 | cooking for others |  |
| C22 | "Write. Even if it's uncomfortable, I write." | Kaine S. | M47 | writing |  |
| C23 | "A hot bath does wonders for me." | Vivian G. | M47 | taking a bath |  |
| C24 | "Bake. Reminds me of my grandma and good times." | Jaimie M. | M47 | baking |  |
| C25 | "I try to always sit outside for at least 15 minutes!" | Darci O. | M47 | sitting outside |  |
| C26 | "I will do my makeup. It gives me a sense of doing something" | Louise J. | M47 | doing makeup |  |
| C27 | "I write in my positive journal whether I feel like it or not." | Tammy O. | M47 | writing in a journal |  |
| C28 | "I'm trying to draw what I feel to show other people like my doctor or therapist" | Týnka Š. | M47 | drawing a feeling |  |
| C29 | "I take my pup out to the front yard to pee." | Nat C. | M47 | letting a pet out |  |
| C30 | "Yoga. Keeps me calm and grounded" | Brooke B. | M47 | yoga |  |
| C31 | "I spend my day behind a sewing machine, it helps me to see material results of my work" | Markéta V. | M47 | sewing |  |
| C32 | "I always call my grandma and grandpa to see how they are doing." | Kylie J. | M47 | calling a relative |  |
| C33 | "Wash my bedsheets then put them back on my bed. The smell of clean laundry really helps." | Debbie S. | M47 | changing bedsheets |  |
| C34 | "Write a thank you note that's long overdue ... put a stamp on it and walk it out to the mailbox." | Carol M. | M47 | sending a written note |  |
| C35 | "Drink a full glass of water. I know that sounds simple, but for me it's a big deal." | Cassey M. | M47 | drinking water |  |
| C36 | "Text my loved ones and tell them I love them and appreciate them." | Leah V. | M47 | telling someone you love them |  |
| C37 | "Play video games." | Ea H. | M47 | playing a game |  |
| C38 | "I watch a lot of movies. No serious drama that might trigger more sadness" | Karen F. | M47 | watching something chosen carefully |  |
| C39 | "I get up with kids talk to them. Tell them nice things about their clothes or behavior" | Jen T. | M47 | greeting your children |  |
| C40 | "Honestly on my really rough days, I wipe my teeth with a baby wipe." | Hope K. | MDH | wiping teeth without brushing | † |
| C41 | "Keeping the toothbrush and toothpaste in the shower kind of helps me to remember to brush my teeth." | Kim J. | MDH | relocating a hygiene object | † |
| C42 | "Brushing your teeth in the shower so it's more like doing one thing instead of two." | Tess S. | MDH | combining two hygiene tasks | † |
| C43 | "Brush teeth in the shower. Sitting on [the] floor with back against [the] wall if you have to." | Renée W. | MDH | brushing teeth seated | † |
| C44 | "I recently bought a dry erase board for my room...I write my daily tasks, like take meds, shower, brush teeth, eat." | Mary R. | MDH | taking medication; writing tasks where you see them |  |
| C45 | "I keep floss picks and mouth[wash] in my car because it takes less energy to floss in the car" | Emily D. | MDH | flossing somewhere other than the bathroom | † |
| C46 | "Brush teeth" | author list | MGO | brushing teeth |  |
| C47 | "Comb hair" | author list | MGO | combing hair | † |
| C48 | "Get dressed" | author list | MGO | getting dressed |  |
| C49 | "Eat breakfast" | author list | MGO | eating a meal |  |
| C50 | "Eat lunch" | author list | MGO | eating a meal |  |
| C51 | "Eat dinner" | author list | MGO | eating a meal |  |
| C52 | "Clean up kitchen" | author list | MGO | cleaning the kitchen |  |
| C53 | "Talk to someone" | author list | MGO | speaking to another person |  |
| C54 | "Do breathing exercises" | author list | MGO | breathing exercise |  |
| C55 | "Drink water" | author list | MGO | drinking water |  |
| C56 | "Check mail" | author list | MGO | checking the post | † |
| C57 | "Go to bed on time" | author list | MGO | going to bed |  |
| C58 | "Shower three times" | author list | MGO | showering |  |
| C59 | "Wash hair twice" | author list | MGO | washing hair |  |
| C60 | "Go outside three times" | author list | MGO | going outside |  |
| C61 | "Get groceries" | author list | MGO | buying food |  |
| C62 | "Do laundry" | author list | MGO | doing laundry |  |
| C63 | "Clean bathroom" | author list | MGO | cleaning the bathroom |  |
| C64 | "Vacuum and dust the house" | author list | MGO | vacuuming |  |
| C65 | "If you can only manage to brush for 30 seconds, go for it." | editorial | IDM | brushing teeth briefly | † |
| C66 | "Keep your toothbrush in a cup by your bed or couch and dry-brush when you can" | editorial | IDM | brushing without water or paste | † |
| C67 | "Even just thoroughly rubbing your teeth with a paper towel or washcloth will help" | editorial | IDM | cleaning teeth without a brush | † |
| C68 | "A quick swish of mouthwash will still be better than nothing." | editorial | IDM | rinsing the mouth | † |
| C69 | "Pick out the clothes you're going to wear (preferably something comfy) and lay them out" | editorial | IDM | laying out tomorrow's clothes | † |
| C70 | "If you only have the energy to wash your body, skip the hair." | editorial | IDM | partial washing | † |
| C71 | "There's nothing wrong with just rinsing and no sudsing." | editorial | IDM | rinsing only | † |
| C72 | "Sit down in the shower if you need to, and let the water run over you." | editorial | IDM | showering seated | † |
| C73 | "Try just washing your face with soap and water." | editorial | IDM | washing your face |  |
| C74 | "Use wet wipes for your body, focusing on the areas that need the most attention." | editorial | IDM | washing without a shower | † |
| C75 | "Even just wetting your hair and then brushing through it will give it new life." | editorial | IDM | refreshing hair without washing | † |
| C76 | "Dry shampoo can be a lifesaver for greasy hair." | editorial | IDM | dry shampoo | † |
| C77 | "When in doubt, a claw clip, ponytail, or braid will do the trick." | editorial | IDM | tying hair up | † |
| C78 | "Skip the 12-step skincare routine, and go for a basic cleanser and moisturizer." | editorial | IDM | minimal skincare | † |
| C79 | "Just try to make sure you're changing your underwear every day." | editorial | IDM | changing underwear | † |
| C80 | "Try doing a "necessity load" of laundry with just enough clothes to get through days" | editorial | IDM | a partial laundry load | † |
| C81 | "Call up a friend or family member who you trust, and ask them to stay on the phone" | editorial | IDM | asking someone to stay on the line while you do a task | † |
| C82 | "Put on some music or a YouTube video to give yourself a distraction." | editorial | IDM | using sound to start a task | † |
| C83 | "a dishwasher that needs to be loaded" | author | MAD | loading the dishwasher |  |
| C84 | "a suitcase that needs to be unpacked" | author | MAD | unpacking |  |
| C85 | "a bunch of emails that have been waiting to be responded to since July" | author | MAD | replying to a backlog |  |
| C86 | "a stack of unopened mail" | author | MAD | opening post |  |
| C87 | "a form from my insurance company that needed to be filled out" | author | MAD | filling in a form |  |
| C88 | "go warm up a plate of food" | author | MAD | reheating food | † |
| C89 | "piles of laundry around my apartment" | author | MAD | laundry backlog |  |
| C90 | "Eating right. When I'm really depressed, I get so tearful and anxious that I hardly eat" | Noelle M. | M22 | eating at all |  |
| C91 | "Talking to my friends. When I have a depressive episode, I don't call or text anyone" | Emily H. | M22 | contacting a friend |  |
| C92 | "Running errands. I don't have any motivation at all for getting stuff done like doctor appointments, therapy, shopping" | Alejandra C. | M22 | errands and appointments |  |
| C93 | "Any task related to money causes me immense stress." | survey respondent | ADD | money admin (domain statement, not a discrete action) |  |
| C94 | "I also find it hard to break big tasks down into manageable steps." | survey respondent | ADD | breaking a task down (domain statement) |  |
| C95 | "Starting tasks feels infinitely more difficult than finishing them." | survey respondent | ADD | task initiation (domain statement) |  |

**31 of 95 items are marked †.** These are the sub-granular ones: cleaning teeth with
a paper towel, brushing for 30 seconds, sitting down in the shower, standing on one leg, opening
the curtains, turning on a light, putting on perfume, reheating a plate of food, saying one
sentence to yourself. No competitor list in Task 1 contains an item at this scale — Finch's
"Easy Wins" is the closest and still stops at whole actions ("Take a shower", "Brush teeth").

---

## TASK 3 — Classification of the collection

Same axes and same rules as section G of the audit. **One rule had to be extended:** the audit's
G3 has no bucket for animals, because the library contains no pet item. Pet care is filed under
*environment* here and flagged in Task 4.

**G1 — time of day implied**

| bucket | count | % |
|---|---|---|
| morning | 5 | 5% |
| daytime | 5 | 5% |
| evening | 2 | 2% |
| night | 1 | 1% |
| none | 82 | 86% |
| **Total** | **95** | |

**G2 — effort floor**

| bucket | count | % |
|---|---|---|
| under a minute | 39 | 41% |
| a few minutes | 37 | 39% |
| 15 min or more | 14 | 15% |
| unclear | 5 | 5% |
| **Total** | **95** | |

**G3 — body / mind / environment / people**

| bucket | count | % |
|---|---|---|
| body | 42 | 44% |
| mind | 4 | 4% |
| environment | 38 | 40% |
| people | 11 | 12% |
| **Total** | **95** | |

**G4 — action verb** (the head verb of the action described, since verbatim quotes do not all

**55 distinct verbs across 94 items.**

| verb | count |
|---|---|
| Do | 7 |
| Brush | 6 |
| Eat | 4 |
| Wash | 4 |
| Write | 4 |
| Make | 3 |
| Open | 3 |
| Talk | 3 |
| Use | 3 |
| Call | 2 |
| Clean | 2 |
| Drink | 2 |
| Go | 2 |
| Keep | 2 |
| Play | 2 |
| Put on | 2 |
| Sit | 2 |
| Take out | 2 |
| Tell | 2 |
| Text | 2 |

**Used once:** Ask, Bake, Break, Breathe, Change, Check, Comb, Draw, Fill out, Get, Get dressed, Lay out, Load, Paint, Read, Respond, Rinse, Rub, Run, Sew, Shower, Spend, Stand, Start, Swish, Take, Tie, Turn on, Unpack, Vacuum, Warm, Watch, Wet, Wipe, Work

**G5 / G6 / G7**

| axis | yes | no |
|---|---|---|
| G5 requires another person | 11 | 84 |
| G6 requires leaving the home | 8 | 87 |
| G7 requires an object | 81 | 14 |
| G7a of which possession/purchase-gated | 24 | — |

---
## TASK 4 — Gap report

Library figures are taken from sections F and G of [`intention-library.md`](intention-library.md)
(98 items). Collection figures are Task 3 above (95 items). Percentages, not raw counts, are the
comparable quantity.

### 4.1 Axis-by-axis

| axis | bucket | library 98 | collection 95 | delta |
|---|---|---|---|---|
| G1 time | morning | 1 (1%) | 5 (5%) | +4 pp |
|  | daytime | 6 (6%) | 5 (5%) | -1 pp |
|  | evening | 3 (3%) | 2 (2%) | -1 pp |
|  | night | 0 (0%) | 1 (1%) | +1 pp |
|  | none | 88 (90%) | 82 (86%) | -3 pp |
| G2 effort | under a minute | 73 (74%) | 39 (41%) | -33 pp |
|  | a few minutes | 11 (11%) | 37 (39%) | +28 pp |
|  | 15 min or more | 3 (3%) | 14 (15%) | +12 pp |
|  | unclear | 11 (11%) | 5 (5%) | -6 pp |
| G3 axis | body | 23 (23%) | 42 (44%) | +21 pp |
|  | mind | 21 (21%) | 4 (4%) | -17 pp |
|  | environment | 43 (44%) | 38 (40%) | -4 pp |
|  | people | 11 (11%) | 11 (12%) | +0 pp |
| G5 | needs another person | 11 (11%) | 11 (12%) | +0 pp |
| G6 | needs leaving home | 1 (1%) | 8 (8%) | +7 pp |
| G7 | needs an object | 51 (52%) | 81 (85%) | +33 pp |
| G7a | possession/purchase-gated | 13 (13%) | 24 (25%) | +12 pp |

**Three deltas are larger than 20 points.**

| finding | library | collection |
|---|---|---|
| Effort floor "under a minute" | 74% | 41% |
| G3 *mind* | 21% | 4% |
| G7 requires an object | 52% | 85% |

The library is built at a smaller effort floor than the language people use, is five times more
*mind*-weighted, and is far less object-bound. Stated as counts; whether that is a gap or the
design is not this report's call.

### 4.2 Verb overlap

| | library | collection |
|---|---|---|
| distinct opening/action verbs | 69 | 55 |
| items carrying one | 92 | 94 |
| most frequent | Do 5, Notice 5, Take 4, Give 3, Review 3 | Brush 8, Wash 6, Eat 5, Do 5, Take 3 |

**`Notice` appears in 0 of the 95 collected quotes** — checked by string match across every
verbatim item, not by classification. It is the library's joint-most-frequent verb (`MO-02`,
`MO-06`, `MO-09`, `CR-04`, `SC-06`). The collection's three most frequent verbs — *Brush*, *Wash*,
*Eat* — appear **0 times** in the library's 69 verbs.

### 4.3 Thematic coverage — where the library is absent

| theme | collection | library | note | collection ids |
|---|---|---|---|---|
| Personal hygiene (teeth, shower, hair, face, skin) | 23 | **0** | — | C01, C40–C43, C46, C47, C58, C59, C65–C68, C70–C79 |
| Admin: post, forms, appointments, errands | 7 | **0** | — | C34, C56, C61, C85, C86, C87, C92 |
| Eating a meal, plainly | 6 | **0** | `HE-12` and `MO-13` exist but both gate the meal on a condition ("mindfully", "without your phone") | C09, C49, C50, C51, C88, C90 |
| Daylight indoors: curtains, lamps | 3 | **0** | `HO-04` opens a window for *air*, not light | C05, C12, C13 |
| Pets | 3 | **0** | — | C02, C10, C29 |
| Asking someone for support | 2 | **0** | all 11 `RE-*` people items are outbound giving | C18, C81 |
| Medication | 1 | **0** | — | C44 |
| Getting out of bed | 1 | **0** | — | C08 |
| Getting dressed / clean clothes | 3 | **1** | `SC-10` Put on something comfortable | C08, C48, C69 |
| Sleep and bedtime | 3 | **2** | `HE-13`, `SC-13` — both *before* sleep | C33, C57, C69 |

**48 of the 95 collected items fall in a theme the library covers with 0 or 1 item.**

### 4.4 The inverted case — Finances

| | library | collection |
|---|---|---|
| money items | 12 (12% of library) | 1 |
| of which possession/purchase-gated | 6 of 12 | 1 of 1 |

The single collected money item is not an action but a statement of avoidance: *"Any task related
to money causes me immense stress."* — ADDitude reader survey respondent
([source](https://www.additudemag.com/getting-started-adhd-challenges/)). Finch's money items are
similarly sparse: 2 of ~120 ("Start a piggy bank for a cause", "Open a new savings account for a
specific goal") ([source](https://finch.fandom.com/wiki/Goals)).

Cross-referencing F3: Finances is also one of the three focus areas **no path defaults to**, so
its 12 items need the user to add the area by hand.

### 4.5 F3 cross-check — the unreachable areas against demand

| focusArea | library items | reachable by a path? (F3) | collection items in this theme |
|---|---|---|---|
| Home & organization | 12 | **no** | 10 |
| Creativity | 12 | **no** | 8 |
| Finances | 12 | **no** | 1 |
| Health | 13 | yes (GM, WD, SN, ML) | 30 |
| Mood | 13 | yes (AH, WD, LU, CP, HS) | 4 |
| Productivity | 11 | yes (GM, QF, LU) | 7 |
| Relationships | 12 | yes (CP) | 11 |
| Self-care | 13 | yes (AH, QF, SN, ML, HS) | 24 |

Home & organization draws 10 collected items and is reachable by no path. Finances draws 1 and
holds 12 library items.

---

## Philosophy conflicts — flagged, not removed

Against the stated rules: no streaks, no scores, no denominators, no failure states, not
productivity-optimising, not appearance- or weight-focused.

### In the collected community items

| id | verbatim | conflict |
|---|---|---|
| C04 | "Paint my nails. Small act of self care." | appearance-adjacent (contributor frames it as self-care) |
| C11 | "I make a list of three things on my bad days and when I complete them I count it as a win ..." | adversarial framing ("a win against the depression") |
| C26 | "I will do my makeup. It gives me a sense of doing something" | appearance-adjacent (contributor frames it as doing something) |
| C57 | "Go to bed on time" | "on time" implies a standard to miss |
| C58 | "Shower three times" | weekly quota — a denominator |
| C59 | "Wash hair twice" | weekly quota — a denominator |
| C60 | "Go outside three times" | weekly quota — a denominator |
| C78 | "Skip the 12-step skincare routine, and go for a basic cleanser and moisturizer." | appearance-adjacent |
| C79 | "Just try to make sure you're changing your underwear every day." | daily quota — a denominator |
| C85 | "a bunch of emails that have been waiting to be responded to since July" | backlog framing is implicitly punitive |

**10 of 95 collected items carry a flag.** The densest cluster is the
weekly-quota goal list (`C58`–`C60`), which is a scored checklist by construction: "Shower three
times", "Wash hair twice", "Go outside three times".

### In the competitor libraries (Task 1)

| app | conflicting element | source |
|---|---|---|
| Done | built on "streaks/chains" as the motivating mechanic | [EducationalAppStore](https://www.educationalappstore.com/app/done-a-simple-habit-tracker) |
| Streaks | the streak is the product; app tracks "up to 24 tasks you want to complete each day" | [The Sweet Setup](https://thesweetsetup.com/how-to-track-your-habits-using-streaks/) |
| Finch | scoring and reward economy around goals: Energy, Rainbow Stones, "Goal of the Day" pays more, micropet egg hatches after completing a goal **seven times** | [Finch wiki](https://finch.fandom.com/wiki/Goals) |
| Finch | prohibition-framed items rather than actions: "Don't take a nap", "Avoid caffeine after 3PM", "Avoid snacking after 7PM", "Avoid YouTube after 9PM", "Avoid mindlessly using Twitter" | [Finch wiki](https://finch.fandom.com/wiki/Goals) |
| Finch | productivity/career optimisation: "Get emails in inbox to zero", "Take a professional profile photo for networking", "Design a personalized workout plan for yourself", "Create your own vision board for the year" | [Finch wiki](https://finch.fandom.com/wiki/Goals) |
| Routinery | every step carries a time allocation and runs on a countdown timer with a progress bar | [MakeUseOf](https://www.makeuseof.com/review-routinery-app-wellness-habits/) |

Finch's "Easy Wins" category — formerly titled **"Just survive the day"** — is the one competitor
surface that carries no quota, no timer and no target: "Literally survive the day", "Just be",
"Get out of bed", "Stand up for 10 seconds"
([source](https://finch.fandom.com/wiki/Goals)).

---

*Research only — no recommendations, and no intention text authored. 95 community items and
~140 competitor items collected; every one carries a source link. Reddit, TikTok, Instagram and
Quora were unreachable from this session and are represented by nothing in this file.*