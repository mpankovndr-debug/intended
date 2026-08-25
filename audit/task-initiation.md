# Task initiation — what people say about starting, and what of it recurs

*Research companion to [`coverage-gaps.md`](coverage-gaps.md) and [`intention-library.md`](intention-library.md). Collected 2026-08-24.*
*Report only. **No intention copy was written by me**, and nothing here is a recommendation. Every
item is quoted from a source and linked. Where a source could not be reached, the failure is
recorded verbatim instead of being filled in from memory.*

---

## 0. Access log — read this before trusting any count

The brief named Reddit first and asked for every method to be tried and every failure named.
**Reddit was unreachable by all ten methods attempted.** No remembered Reddit content has been
substituted; no item in this file is labelled Reddit.

| # | source | method | exact result |
|---|---|---|---|
| 1 | reddit.com | `WebSearch` with `allowed_domains: ["reddit.com"]` | `API Error: 400 The following domains are not accessible to our user agent: ['reddit.com']` |
| 2 | www.reddit.com | `WebFetch` on the `.json` search endpoint | `Claude Code is unable to fetch from www.reddit.com` |
| 3 | old.reddit.com | in-app browser `preview_start` | `Browser pane opened at about:blank; https://old.reddit.com is blocked by policy.` |
| 4 | reddit.com | in-app browser `navigate` to a thread URL | `https://reddit.com is blocked by policy and cannot be opened in the Browser pane.` |
| 5 | safereddit.com (Redlib mirror) | `WebFetch` | page returned was "an access denial error message from Anubis security software"; no post content |
| 6 | redlib.catsarch.com (Redlib mirror) | in-app browser `navigate` | loaded a bot-check page — tab title `Even checken of je een bot bent!` |
| 7 | libreddit.privacydev.net (Redlib mirror) | in-app browser `navigate` | tab title `502 Bad Gateway` |
| 8 | redlib.perennialte.ch (Redlib mirror) | `WebFetch` | `The server returned HTTP 403 Forbidden.` |
| 9 | web.archive.org | `WebFetch` of an archived Reddit URL | `Claude Code is unable to fetch from web.archive.org` |
| 10 | archive.ph | `WebFetch` of `archive.ph/newest/https://www.reddit.com/r/ADHD/` | `Claude Code is unable to fetch from archive.ph` |

Two further sources in the brief also failed:

| source | method | exact result |
|---|---|---|
| YouTube **comments** | `WebFetch` on `youtube.com/watch?v=WQuYHPg3Tjo` | only footer navigation returned; "the actual video description, title details, and any viewer comments are not present" |
| YouTube **comments** | in-app browser `navigate` to `youtube.com/watch?v=345yaPuNDgc&hl=en` | browser landed on `https://youtube.com` with the path stripped; `get_page_text` returned an empty body |
| HealthUnlocked (CHADD's Adult ADHD Support forum) | `WebFetch` on two post URLs | `The server returned HTTP 403 Forbidden.` (both) |
| HealthUnlocked | in-app browser `navigate` + JS location set | landed on the root, page text `Looks like that page can't be found!` — logged-out gate |
| Substack paid threads (`ihopethishelps`) | `WebFetch` | `This thread is only visible to paid subscribers` |
| ot4adhd.com, chadd.org article URLs, effectiveu.umn.edu | `WebFetch` | `403 Forbidden` / `404 Not Found` (see per-row notes below) |

**YouTube transcripts *were* reachable** through a third-party transcription mirror
([pickscribe.com](https://pickscribe.com/v/SuENZbvkgmA), redirected from ytscribe.com) and through
podcast transcript pages. YouTube *comments* were not.

**What replaced Reddit.** Substack **comment threads** are the closest reachable substitute: they
are unedited, first-person, signed, and public. Six of them are used below. They skew older and
more writerly than Reddit, and self-select for people who subscribe to ADHD newsletters. Two other
reachable crowdsourced pools were used: ADDitude's **reader-survey verbatims** (edited only for
length) and The Mighty's community pieces.

**Target vs. delivered:** brief asked for 40–60 verbatim items in TASK 1; **89 collected**.

---

## TASK 1 — What people say about starting

Sources keyed here, cited by key in the table.

| key | source | kind |
|---|---|---|
| ADD-GS | ["Why Getting Started Is So Difficult for Adults with ADHD"](https://www.additudemag.com/getting-started-adhd-challenges/) — ADDitude | reader survey, verbatim |
| ADD-FIX | ["Get Unstuck Now: Adults with ADHD Share Their Procrastination Fixes"](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) — ADDitude | reader submissions, signed |
| ADD-5W | ["How to Get Started: 5 Ways I Overcame Chronic Procrastination"](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) — ADDitude | first-person essay |
| MTY-10 | ["10 Things Neurotypical People Need to Know About Living With ADHD"](https://themighty.com/topic/adhd/facts-about-adhd-what-its-like/) — The Mighty, Damien Southam | first-person author |
| MTY-LB | ["How Many People With Executive Dysfunction Does It Take to Screw In a Light Bulb?"](https://themighty.com/topic/adhd/executive-dysfunction-household-tasks-example/) — The Mighty | first-person author |
| MTY-AP | ["What Is ADHD Paralysis?"](https://themighty.com/topic/adhd/managing-adhd-paralysis/) — The Mighty | editorial (marked) |
| AI-C | [comments on "First article on autistic inertia"](https://autisticinertia.com/2020/12/first-autistic-inertia-article/) — Autistic Inertia | public comments, signed |
| LSA | ["Autistic Inertia: How To Get Unstuck When 'Try Harder' Backfires"](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) — Life Skills Advocate | editorial quoting research participants |
| SUB-PC | [comments on "ADHD: sometimes it's really, really hard"](https://purposefulconnection.substack.com/p/adhd-sometimes-its-really-really/comments) — Hanna Keiner | public comments, signed |
| SUB-CR | [comments on "Struggling with feeling stuck"](https://charlierewilding.substack.com/p/struggling-with-feeling-stuck/comments) — Charlie Rewilding | public comments, signed |
| SUB-JZ | [comments on "The surprising truth about ADHD motivation"](https://jezz.substack.com/p/the-surprising-truth-about-adhd-motivation/comments) — Jezz Lundkvist | public comments, signed |
| SUB-RT | ["Going aluminum: why is starting the hardest part?"](https://robbieqtelfer.substack.com/p/going-aluminum-why-is-starting-the) — Robbie Q Telfer | first-person essay |
| SUB-AI | ["Start Before You're Ready — With AI's Help"](https://adhdwithai.substack.com/p/start-before-youre-ready-with-ais) | first-person / editorial |
| SUB-JF | ["ADHD and Task Initiation: How to get unstuck"](https://adhdwithjennafree.substack.com/p/adhd-and-task-initiation-how-to-get) — Jenna Free | ADHD coach, first-person plural |
| SUB-RI | ["10 ridiculous ADHD hacks"](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) — Rach Idowu | first-person |
| WSL | ["ADHD Task Switching: Quick Rituals to Keep You Moving"](https://www.adhdweasel.com/p/adhd-task-switching-ritual) | first-person |
| IHA | ["Episode #319: 'Why Can't I Just START?!'"](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) — Kristen Carder | podcast, first-person |
| OSA | [Outsmart ADHD Ep. 5 transcript](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) — Jamie | podcast transcript |
| YTS | [YouTube transcript, "Task Initiation + ADHD — Why we struggle to get started"](https://pickscribe.com/v/SuENZbvkgmA) — Caren Magill | video transcript |
| HAD | ["Task Initiation Made Easy: 8 Ways to Start Tasks with ADHD"](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) — Honestly ADHD | coaching blog |
| MAC | ["ADHD Task Initiation"](https://www.theminiadhdcoach.com/living-with-adhd/adhd-task-initiation) — Alice Gendron | first-person |
| JH | ["Body-Doubling To Help You Get Started And Focus On Tasks"](https://jaynehardy.co.uk/body-doubling-for-when-youre-struggling-to-focus-or-get-started-on-tasks/) — Jayne Hardy | first-person |
| HUF | ["'Home Shoes' Can Help With Task Paralysis From ADHD"](https://www.huffpost.com/entry/home-shoes-adhd-task-paralysis_l_6a83753fe4b05886dff6476f) — HuffPost | reported, expert quotes |
| INF | ["How to use the 2 minute rule to get things done with ADHD"](https://www.getinflow.io/post/get-things-done-with-adhd) — Inflow | first-person |

### Items

`class` column: **R** recurring · **1** one-shot · **S** setup · **—** no action in the item (description only).
`meta` = the action only exists relative to some other task the user already has.

| id | verbatim | who | src | class | meta |
|---|---|---|---|---|---|
| TI01 | "My OCD says: 'Before we start, let's tidy up our workspace, organize our diary, and get today's admin out the way.' My ADHD says: 'Yes! Let's tidy up our workspace, but let us also rearrange the bookshelf, de-clutter our cupboards, donate old clothes, do some laundry, feed the dogs, cook lunch, wash the cars, tend to the garden, worry, think, worry.'" | Anneke | ADD-GS | — | |
| TI02 | "I'm a serial procrastinator. Even before I start a task, I'm convinced that I won't be able to do something right or that it will take too much time. For example, doing the dishes; I always feel like it will take an hour when, in reality, it usually only takes 10 minutes." | Kami | ADD-GS | — | |
| TI03 | "I have a hard time starting a task because I get so overwhelmed when I see what has to be done. Then once I do get started, my perfectionism kicks in and it takes forever to finish." | Anonymous | ADD-GS | — | |
| TI04 | "I have trouble getting motivated, especially if it's for a task that I really don't want to do but have to do. Most of the time it's a self-esteem problem; I never think I'm good enough, so even if I want to try I never do because I'm afraid I'll fail." | Hannah | ADD-GS | — | |
| TI05 | "I'm a bit of a control freak so I've always tried to file my taxes on my own, but after another year of procrastinating until the last possible day, I finally hired an accountant to take care of it." | Keelie | ADD-GS | 1 | |
| TI06 | "Finding the motivation to start something is excruciating. Hyperfocus helps, but I spend days beating myself up for being behind on tasks. I'm trying to cut myself some slack and accept that it is just how my brain works, but 54 years of conditioning is hard to reverse!" | Anonymous | ADD-GS | — | |
| TI07 | "Starting tasks feels infinitely more difficult than finishing them. In physics, static friction is always a greater force than kinetic friction; a still object takes more force to move than an object already in motion." | Anonymous | ADD-GS | — | |
| TI08 | "Any task related to money causes me immense stress. There is a huge mental block between knowing I need to do the task and actually being able to do it." | Anonymous | ADD-GS | — | |
| TI09 | "I am very linear: I can't start a task until everything else is finished. I also find it hard to break big tasks down into manageable steps. Organizing and completing paperwork is the hardest for me to start." | Donna | ADD-GS | — | |
| TI10 | "I get frazzled by where to start and how to start. I overthink the whole process before I even begin. I feel ashamed that such small things can be utterly paralyzing." | Anonymous | ADD-GS | — | |
| TI11 | "I have real difficulty starting mundane tasks, like dishes, laundry and math homework. Exciting tasks, like writing an interesting paper or painting a portrait, are daunting too. I need to be up against a deadline and I always procrastinate until the very last minute." | Beth | ADD-GS | — | |
| TI12 | "I avoided opening all my snail mail for a few months by putting the letters in a drawer, until I got a letter stating I would have to go to court if I didn't pay a bill. Following this I contacted all my billers and made the request for emailed bills!" | Anonymous | ADD-GS | S | |
| TI13 | "I get bright ideas and have the energy to get started on them, but then the energy dwindles and it is a fight to continue. I have to use a reward system to keep myself going." | Anonymous | ADD-GS | R | ✔ |
| TI14 | "Stay off of Facebook and personal e-mail during the workday. Make a to-do list, and cross off items as they are completed." | Walter Kloepfer, Homer, Alaska | ADD-FIX | R | |
| TI15 | "I try to remember that today is yesterday's tomorrow." | David, Montreal | ADD-FIX | R | |
| TI16 | "Feet first, feelings follow. I don't wait until I feel like doing something, or until I am in the right mood, because that might never happen. So I jump in and start the project. Nine times out of 10, I find that, once I get started, I feel like continuing." | Leslie Pressnell, Lakewood, Ohio | ADD-FIX | R | ✔ |
| TI17 | "Make short lists of 'musts.' Take care of the most important things first, then take on other items. I give myself permission to do at least one 'tolerable,' 'fun,' or 'worthwhile' item each day, even if it's not on the 'must' list." | Susan Hsu, Gainesville, Florida | ADD-FIX | R | |
| TI18 | "I need uninterrupted time to work, so I schedule at least one day a week with no appointments (especially if I am working at home). I allow myself one trip to let the dogs out, get the mail, or eat." | Nancy, Salt Lake City, Utah | ADD-FIX | S | |
| TI19 | "Make it exciting, no matter what it is. Boring and dull are killers. Play music and dance around! Do a portion of one project, then break off and do a little of another until they're both done." | Anonymous ADDitude reader | ADD-FIX | R | ✔ |
| TI20 | "Plan a get-together or an event with a deadline. Hold a garage sale and set a date. Then there's no turning back, because you have to get organized for the sale." | Christine Kelly, Naples, Florida | ADD-FIX | 1 | |
| TI21 | "I get dressed, right down to my shoes, first thing in the morning, then I do the first thing on my list to build momentum. And before all of this, I pray to God for help." | Tammy Miller, Emerald Isle, North Carolina | ADD-FIX | R | |
| TI22 | "If I'm really struggling, I visit unstuck.com (or use the iOS app), and I go through questions to help me figure out why I can't get started." | Emma Bennett, Wirral, United Kingdom | ADD-FIX | R | ✔ |
| TI23 | "I work with someone else rather than working alone. Having an assistant or a friend in the room keeps me on track." | Anonymous ADDitude reader | ADD-FIX | R | |
| TI24 | "I use a wrist tape to keep me focused and to remind me to resist starting a project in another room." | Anonymous ADDitude reader | ADD-FIX | R | |
| TI25 | "I remind myself of a quotation from Janet Dailey: 'Someday is not a day of the week.'" | Vickey A., Middletown, Connecticut | ADD-FIX | R | |
| TI26 | "I keep lists everywhere — poster-size, small, and digital. They all help." | Melanie, Utah | ADD-FIX | S | |
| TI27 | "I would love to go exercise right now, but that desire just doesn't seem to make it into my body." | Damien Southam | MTY-10 | — | |
| TI28 | "I would love to do my self-care, but somehow it just doesn't seem to occur to me — I sort of…. forget I need to eat, or drink water, or get up and stretch." | Damien Southam | MTY-10 | — | |
| TI29 | "I want to behave, but my brain sometimes tells me not to." | Damien Southam | MTY-10 | — | |
| TI30 | "I cannot simply control myself. This lack of control makes me feel like a failure most days." | Damien Southam | MTY-10 | — | |
| TI31 | "most of the stock standard advice doesn't help us — we know and agree with everything you say, but it's just another in an entire web of things we are trying to remember, concentrate on or feel motivated about." | Damien Southam | MTY-10 | — | |
| TI32 | "I *know* that it would (or 'should') just be easier to change the light bulbs, but I just can't bring myself to do it." | author | MTY-LB | — | |
| TI33 | "a battle between wanting to act and an overpowering sensation of immobility. It's like being in a car with a full gas tank but perpetually engaged brakes" | editorial | MTY-AP | — | |
| TI34 | "Imagine standing at a crossroads with multiple paths ahead, each representing a task or decision. Yet, there's an invisible barrier preventing any forward movement" | editorial | MTY-AP | — | |
| TI35 | "Difficulties in initiation rather than in ability to plan are my major struggles." | Jack | AI-C | — | |
| TI36 | "I get stuck a lot and it's one of the biggest problems in my life" | Ezra | AI-C | — | |
| TI37 | "I find curiosity can bypass the stuck-ness" | Jack | AI-C | R | |
| TI38 | "up-beat but expected music can help a little" | Jack | AI-C | R | |
| TI39 | "I want to, and I still cannot get my body and brain to shift states." | autistic research participant, quoted | LSA | — | |
| TI40 | "lying on the couch hungry, needing a shower, and still not moving" — the next step "feels weirdly far away, like it requires a running start." | community description, quoted | LSA | — | |
| TI41 | "stopping will cost more energy than continuing" | community description, quoted | LSA | — | |
| TI42 | "I would kill for a start button. I hardcore relate to the pain in the ass of starting tasks that I know I want to do, that I choose to do, and that I can't JUST DO! I do not embrace that part of my skull spaghetti." | Russ Jones | SUB-PC | — | |
| TI43 | "Thank you for this! I had a hard ADHD day and reading your words helped me feel much less alone and much less ashamed." | Ray Katharine Cohen | SUB-PC | — | |
| TI44 | "Thanks for writing this, Hanna. I needed to read it, to feel a little bit less alone as I berate myself for not just being able to just be 'ok'." | Ross Wood | SUB-PC | — | |
| TI45 | "I'm in burnout/freeze mode and the thought of thinking that hard and writing about it is unappealing now. 🫠 Executive dysfunction sucks." | Dawn-Renée Rice | SUB-PC | — | |
| TI46 | "I love this Hanna. And yes, my kingdom for a start button!" | Lewis Holmes | SUB-PC | — | |
| TI47 | "It genuinely feels as though I am in a prison and all I can do is wait to be let out." | Charlie (author) | SUB-CR | — | |
| TI48 | "Stuck there right now. In the molasses (as I think Sylvia Path described), but knowing my capabilities are just sitting in abeyance until my capacity and energy returns." | Michelle | SUB-CR | — | |
| TI49 | "For myself, I called them my 'anxious days,' where all I could do was sit or lay in bed, but the anxiety of not getting up to do the things I needed to would sit really heavy on my chest." | Amber | SUB-CR | — | |
| TI50 | "This was me last week I felt stuck and trapped. It was frustrating and exhausting in and of itself and I spent hours in bed doing nothing but it was all I felt I could do." | Casper Moore | SUB-CR | — | |
| TI51 | "I've been in this for weeks. All I can do is the one thing that brings me comfort which is gaming. Other than doing that I'm stuck. I physically and mentally cannot do anything else." | Sarah Holley | SUB-CR | — | |
| TI52 | "I've spent most of my adult life believing I was lazy and depressed...I'm struggling to execute everyday tasks and it's impossible to set goals." | Joanne | SUB-CR | — | |
| TI53 | "I once heard such days described as 'wading through treacle' and that has stayed with me." | Miranda R Waterton | SUB-CR | — | |
| TI54 | "ADHD runs in our family, my son is diagnosed and he has a lot of trouble starting new things like drawing. There's an energy involved, I think, in trying to start something new that you need to overcome..." | J.M. Guilfoyle | SUB-JZ | — | |
| TI55 | "Our most typical and challenging trait is that we struggle to do things, even if we'd really like to" | Maggie Jon | SUB-JZ | — | |
| TI56 | "A person without ADHD procrastinate stuff they dont want to do. A person with ADHD procrastinate stuff they want to do." | quoted by Jezz Lundkvist | SUB-JZ | — | |
| TI57 | "Ever sat on the couch knowing you 'should' do something… but just couldn't?" | Kristen Carder | IHA | — | |
| TI58 | "I don't know why I'm not just starting. I don't know why I don't know why I can't just make myself do this." | Kristen Carder | IHA | — | |
| TI59 | "I truly avoid and procrastinate the most on the things that I care about most." | Kristen Carder | IHA | — | |
| TI60 | "It's starting to do the fucking task, which is hard for us with ADHD because of our underdeveloped frontal lobe." | Jamie | OSA | — | |
| TI61 | "The more you stop and you think about it, the more that you're berating yourself, the more you're feeling like, why am I not doing this? And then that feeling makes it even harder to get started." | Jamie | OSA | — | |
| TI62 | "when something's easy to get started it's probably because there's a lot of dopamine in that thing" | Caren Magill | YTS | — | |
| TI63 | "urgency tends to be a real motivator for us but energetically speaking that's not exactly a sustainable way to live" | Caren Magill | YTS | — | |
| TI64 | "if your limiting beliefs exceed your desire to write a book the book will not get written" | Caren Magill | YTS | — | |
| TI65 | "start with the lowest hanging fruit first...all you need to do is start and the rest will naturally seem to evolve from there" | Caren Magill | YTS | R | ✔ |
| TI66 | "dumb old shame is the main culprit here. Shame and then the treating of shame with my little stupid dopamine outlets." | Robbie Q Telfer | SUB-RT | — | |
| TI67 | "drawing a picture first helps...doing something meditative and emotionally neutral as a way to ease into" | Telfer's seven-year-old, quoted | SUB-RT | R | |
| TI68 | "From the inside, it feels like standing at the edge of a canyon. You know what you want to do. You can even picture it getting done. But you can't step forward." | author | SUB-AI | — | |
| TI69 | "There's no ramp. No foothold. Just fog." | author | SUB-AI | — | |
| TI70 | "Why can't I just do the thing!??" | Jenna Free | SUB-JF | — | |
| TI71 | "The barrier to entry to even the simplest task seems too big. It can feel like our brains are betraying us when we desperately want to DO THE THING." | Jenna Free | SUB-JF | — | |
| TI72 | "I lose so much time in that float. The moment I need to change gears, my brain idles and the guilt starts creeping in." | author | WSL | — | |
| TI73 | "You click send and the screen goes quiet...Your brain hums but your body does not move." | author | WSL | — | |
| TI74 | "when I finish writing an email, I stand up, stretch, and say done as I close the email tab. Then I take a sip of water and look at my next task." | author | WSL | R | ✔ |
| TI75 | "To those with ADHD, it can feel like there's a brick wall between us and the task at hand." | author | HAD | — | |
| TI76 | "It seems impossible to climb that wall, and we'll do almost anything to avoid trying." | author | HAD | — | |
| TI77 | "it took me two months just to start the illustration for this article and another three months to muster the motivation to write about it." | Alice Gendron | MAC | — | |
| TI78 | "it took me 9 months to write the book proposal for The Self-Care Project because I procrastinated on it for so long" | Jayne Hardy | JH | — | |
| TI79 | "I've always been more productive and less prone to distraction when I'm working on something alongside someone else, even if that's remotely." | Jayne Hardy | JH | R | |
| TI80 | "Having a body-double helps minimise distractions and procrastination because you're aware there's someone else there who can see what you're up to. At least, that's how it feels for me." | Jayne Hardy | JH | R | |
| TI81 | "Ooo! An invite! All I have to do is check my calendar and then click 'going' or 'not going'. Easy peasy." … "Aaaand... now 40 minutes have passed and I still haven't done that 'quick' task." | author | INF | — | |
| TI82 | "Putting shoes on when I'm sitting at my home desk. It puts me into 'focus' mode" | Rach Idowu | SUB-RI | R | |
| TI83 | "Listening to music to do chores, admin, to get me pumped up to do anything" | Rach Idowu | SUB-RI | R | |
| TI84 | "chewing gum helps me stay focused when I'm either drafting or reading a long document" | Rach Idowu | SUB-RI | R | |
| TI85 | "I set myself a fake deadline" | Rach Idowu | SUB-RI | R | ✔ |
| TI86 | "I set multiple alarms around 2 hours before I'm meant to leave, at several times" | Rach Idowu | SUB-RI | S | |
| TI87 | "when we're able to have something that puts our brain into the concept of 'OK, I associate this with work,' that association takes some of the hurdle out of starting the task." | Robinson (expert, not first-person) | HUF | — | |
| TI88 | "Don't intermingle. It wont work. As soon as you're done with that task, take off those shoes." | Robinson (expert) | HUF | R | |
| TI89 | "You *want* to vanquish it, but you can't – and you're not sure why." | author | ADD-5W | — | |

**Register note.** 60 of the 89 items (67%) contain **no action at all** — they are descriptions of
the state. That is not a collection failure; it is what the corpus is made of. The single most
repeated figure of speech across independent sources is a **physical barrier**: "brick wall"
(TI75), "wall of awful" (see TASK 2), "canyon" (TI68), "invisible barrier" (TI34), "prison"
(TI47), "engaged brakes" (TI33), "static friction" (TI07), "molasses" (TI48), "treacle" (TI53),
"a running start" (TI40). Two people, in unrelated threads, independently asked for the same
object: **"a start button"** (TI42, TI46).

---

## TASK 2 — Named techniques

`every day?` — **DAILY** the act itself repeats · **SETUP** arranged once, used after · **ONE-OFF**
done once and finished. `meta` = requires a host task to already exist.

| # | technique | verbatim | source | every day? | meta |
|---|---|---|---|---|---|
| N01 | Body doubling | "when you work in the presence of someone else, either in person or online, to make it easier to start tasks, stay focused, and follow through" | [FLOWN Help Centre](https://help.flown.com/en/articles/8333363-what-is-body-doubling) | DAILY (SETUP to join a service) | |
| N02 | Body doubling (personal use) | "get someone else to work alongside you or be present, this can help anchor you in the task at hand" | [SUB-JF](https://adhdwithjennafree.substack.com/p/adhd-and-task-initiation-how-to-get) | DAILY | ✔ |
| N03 | Micro-start | "Choose the smallest possible action related to your task. Example: Instead of 'clean the kitchen,' try 'put one mug in the sink.'" | [Tiimo](https://www.tiimoapp.com/resource-hub/task-initiation-adhd) | DAILY | ✔ |
| N04 | Five-minute rule | "Commit to working on something for just five minutes… Many people find they continue past the five-minute mark once they get going." | [Tiimo](https://www.tiimoapp.com/resource-hub/task-initiation-adhd) | DAILY | ✔ |
| N05 | Ten-minute intention | "Intend for 10 minutes." | [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) | DAILY | ✔ |
| N06 | Two-minute rule | "if a task or action takes less than two minutes to complete, you should do it immediately rather than postponing it" | [Inflow](https://www.getinflow.io/post/get-things-done-with-adhd) | DAILY | ✔ |
| N07 | Pomodoro | "It involves using a timer to work in short bursts (usually 25 minutes) with little breaks in between." | [MAC](https://www.theminiadhdcoach.com/living-with-adhd/adhd-task-initiation) | DAILY | ✔ |
| N08 | Timer racing | "Set a timer and race against yourself." | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) | DAILY | ✔ |
| N09 | Count down from five | "Count Down From Five" | [HAD](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) | DAILY | ✔ |
| N10 | Create a ritual | "Create a Ritual" | [HAD](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) | DAILY (SETUP to define it) | |
| N11 | Transition ritual | "certain behaviors, that they go through between different tasks" that "signal to the brain it is time to start a new task" | [ADDA](https://add.org/rituals-transitions-get-one-task-another/) | DAILY | |
| N12 | Transition ritual examples | "Get a healthy snack" · "Get something to drink" · "Set up your playlist" · "Text a friend" · "Take a quick walk or run up and down the dorm or library stairs" · "Move to a different location to start a new task" · "Listen to a certain energizing song" | [ADDA](https://add.org/rituals-transitions-get-one-task-another/) | DAILY | |
| N13 | Close-clean / begin-cue ritual | "one act to end clean, one cue to begin, and one tiny first action" | [WSL](https://www.adhdweasel.com/p/adhd-task-switching-ritual) | DAILY | ✔ |
| N14 | Starter step | "Pick one tiny action and pause intentionally (e.g., 'Put toothpaste on the toothbrush')" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N15 | Scene setup | "Arrange tools in your path so the next action is obvious" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | SETUP | |
| N16 | Borrow momentum | "Pair starting with something already happening (kettle on, playlist starting)" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N17 | Save point | "Write a one-line note: 'I stopped here. Next is ____'" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N18 | Breadcrumbs | "I will ask the AI feature in notion to do a quick summary of everything I've written so far" | [YTS](https://pickscribe.com/v/SuENZbvkgmA) | DAILY | ✔ |
| N19 | Countdown ritual (to stop) | "Three minutes to wrap up, then close tabs, stand up, water" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N20 | Transition buffer | "Build 2–10 minutes between tasks (especially social-to-solo)" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N21 | Bridge task | "Choose a small action linking old and new tasks (file, then open next tab)" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N22 | Batch similar work | "Switch less often by grouping comparable tasks" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | SETUP | ✔ |
| N23 | Schedule restart | "Plan a brief return to make stopping feel safer" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | DAILY | ✔ |
| N24 | Check-in prompts from trusted people | "Check-in prompts from trusted people" | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) | SETUP | |
| N25 | Task pairing | "Task Pairing" / "pair a boring task with something you like such as a podcast or audiobook" | [HAD](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) · [SUB-JF](https://adhdwithjennafree.substack.com/p/adhd-and-task-initiation-how-to-get) | DAILY | ✔ |
| N26 | Start in the middle | "Start in the Middle" | [HAD](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) | DAILY | ✔ |
| N27 | Grab the easy parts | "Grab the easy parts of the chore." | [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) | DAILY | ✔ |
| N28 | Break it down | "Break each project into small tasks and define the first step that needs to get done. Then stick with it until the first task is completed." | [ADD-6W](https://www.additudemag.com/six-ways-to-get-started/) | DAILY | ✔ |
| N29 | House shoes | "house shoes" as "a way to combat task paralysis and get necessary chores done" | [HUF](https://www.huffpost.com/entry/home-shoes-adhd-task-paralysis_l_6a83753fe4b05886dff6476f) | DAILY | |
| N30 | Shoes-off discipline | "Don't intermingle. It wont work. As soon as you're done with that task, take off those shoes." | [HUF](https://www.huffpost.com/entry/home-shoes-adhd-task-paralysis_l_6a83753fe4b05886dff6476f) | DAILY | |
| N31 | Dressed down to shoes | "I get dressed, right down to my shoes, first thing in the morning, then I do the first thing on my list to build momentum." | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | DAILY | |
| N32 | Wall of Awful — climb it | "sitting with the emotion that built up our wall and understanding what's stopping us" | [Hacking Your ADHD w/ Brendan Mahan](https://www.hackingyouradhd.com/podcast/the-wall-of-awful-with-brendan-mahan) | DAILY | ✔ |
| N33 | Wall of Awful — put a door in it | "changing your emotional state so that you can get past the wall" — "taking walks, listening to energizing music, or watching something funny" | [Hacking Your ADHD](https://www.hackingyouradhd.com/podcast/the-wall-of-awful-with-brendan-mahan) | DAILY | |
| N34 | Emotional regulation first | "if you are feeling dread, if you are feeling fear, if you are feeling that full body resistance, I invite you to take some time to emotionally regulate." | [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | DAILY | |
| N35 | Sensory de-escalation | "Get away from any stimulus you can, any sights, sounds, smells, anything that is going to ramp up your nervous system." | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) | DAILY | |
| N36 | External initiation | someone else starts it for you — "turn on the shower so that I have to get up" | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) | DAILY | |
| N37 | B-minus work | "can we just do a b minus job on this? Can we at least get started with B minus work?" | [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | DAILY | ✔ |
| N38 | Phone jail | "Put your phone in a phone jail." | [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | DAILY | |
| N39 | Shrink the block | "Hey, let's just get started with one hour and see how you're feeling." | [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | DAILY | ✔ |
| N40 | Connect to values | "think about your values. What is driving you? What is your core? Why?" | [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | DAILY | ✔ |
| N41 | Visual cues / Time Timer | "creating some visual cues or some timers. I love the Time Timer." | [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | SETUP | |
| N42 | Accountability with stakes | "If I don't post this by...I owe you $100." | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) | DAILY | ✔ |
| N43 | Fake deadline | "I set myself a fake deadline" and publicly announce it | [SUB-RI](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) | DAILY | ✔ |
| N44 | Real event as deadline | "Plan a get-together or an event with a deadline. Hold a garage sale and set a date." | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | ONE-OFF | |
| N45 | Reward system | "Rewards" / "plan a reward for yourself, especially if there's delayed dopamine on the project" | [HAD](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) · [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) | DAILY | ✔ |
| N46 | Note the streak | "Note the streak" | [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) | DAILY | ✔ |
| N47 | Bait yourself | "Bait yourself with something enjoyable." | [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) | DAILY | ✔ |
| N48 | Enlist an accountability partner | "Enlist someone to hold you accountable." | [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) | SETUP → DAILY | ✔ |
| N49 | Be prepared the night before | "Collect all needed materials the night before and place them in your inbox or folder." | [ADD-6W](https://www.additudemag.com/six-ways-to-get-started/) | DAILY | ✔ |
| N50 | Get relaxed first | "brews a soothing cup of his favorite cranberry apple tea and puts on a CD of Hawaiian music before he files briefs or writes letters" | [ADD-6W](https://www.additudemag.com/six-ways-to-get-started/) | DAILY | |
| N51 | Make it fun | "Put on a headset and dance while you vacuum. Sing while you wash windows, or skip when taking out the garbage." | [ADD-6W](https://www.additudemag.com/six-ways-to-get-started/) | DAILY | ✔ |
| N52 | Change location | "go directly to the library after class, instead of going to their busy dorm room" | [ADD-6W](https://www.additudemag.com/six-ways-to-get-started/) | DAILY | |
| N53 | One thing on the desk | "My rule is to have on my desk only what I'm currently working on." | [ADD-6W](https://www.additudemag.com/six-ways-to-get-started/) | DAILY | |
| N54 | AI scaffolding prompt | "I want to start [insert task] but I feel frozen. Can you give me a tiny, no-pressure first step I could take right now?" | [SUB-AI](https://adhdwithai.substack.com/p/start-before-youre-ready-with-ais) | DAILY | ✔ |
| N55 | Video-game-tutorial prompt | "Can you walk me through this task one step at a time, like a video game tutorial — and only give me the next step once I finish the last one?" | [SUB-AI](https://adhdwithai.substack.com/p/start-before-youre-ready-with-ais) | DAILY | ✔ |
| N56 | Nervous-system check-in | "Can you help me figure out what state I'm in before I try to start anything?" | [SUB-AI](https://adhdwithai.substack.com/p/start-before-youre-ready-with-ais) | DAILY | |
| N57 | Magic ToDo (Goblin Tools) | "Break down todo items" — "A collection of small, simple tools, for when things feel too big or complicated" | [goblin.tools](https://goblin.tools/) | DAILY | ✔ |
| N58 | Chapter template | "a template for every chapter" with "prompts to help me think about the points that I want to make" | [YTS](https://pickscribe.com/v/SuENZbvkgmA) | SETUP | ✔ |
| N59 | Reorder the list | make a list of "have-to" tasks and rewrite it "easy to hard or hard to easy, to get started sooner" | [CHADD](https://chadd.org/adhd-in-the-news/getting-started-on-inexplicably-tough-tasks/) | DAILY | ✔ |
| N60 | Lists everywhere | "I keep lists everywhere — poster-size, small, and digital." | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | SETUP | |
| N61 | Launch pad | a designated physical zone "where everything needed for the next morning lives" | [Life Skills Advocate](https://lifeskillsadvocate.com/blog/neurodivergent-toolbox-how-to-use-a-launch-pad/) | SETUP | |
| N62 | Appointment-free day | "I schedule at least one day a week with no appointments" | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | SETUP (weekly) | |
| N63 | Wrist tape | "I use a wrist tape to keep me focused and to remind me to resist starting a project in another room." | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | DAILY | |
| N64 | Chewing gum | "chewing gum helps me stay focused when I'm either drafting or reading a long document" | [SUB-RI](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) | DAILY | |
| N65 | Music to start | "Listening to music to do chores, admin, to get me pumped up to do anything" · "up-beat but expected music can help a little" | [SUB-RI](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) · [AI-C](https://autisticinertia.com/2020/12/first-autistic-inertia-article/) | DAILY | |
| N66 | Neutral warm-up (draw first) | "drawing a picture first helps...doing something meditative and emotionally neutral as a way to ease into" | [SUB-RT](https://robbieqtelfer.substack.com/p/going-aluminum-why-is-starting-the) | DAILY | |
| N67 | A sentence you say to yourself | "Feet first, feelings follow." · "today is yesterday's tomorrow" · "Someday is not a day of the week." | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | DAILY | |
| N68 | Multiple alarms before leaving | "I set multiple alarms around 2 hours before I'm meant to leave, at several times" | [SUB-RI](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) | SETUP | |
| N69 | Delegate it away | "I finally hired an accountant to take care of it" | [ADD-GS](https://www.additudemag.com/getting-started-adhd-challenges/) | ONE-OFF | |
| N70 | Remove the task at source | "I contacted all my billers and made the request for emailed bills!" | [ADD-GS](https://www.additudemag.com/getting-started-adhd-challenges/) | ONE-OFF | |
| N71 | Guided questions app | "I visit unstuck.com (or use the iOS app), and I go through questions to help me figure out why I can't get started" | [ADD-FIX](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) | DAILY | ✔ |
| N72 | Aluminum standard | "just doing your best with the resources you got" rather than "gold standard of excellence" | [SUB-RT](https://robbieqtelfer.substack.com/p/going-aluminum-why-is-starting-the) | DAILY | ✔ |

**"Just put on your shoes" resolves to two different things.** The brief's phrasing matches
N29/N30/N31: shoes as a *state cue you wear*, not as a first step of a walk. Three independent
sources describe it — HuffPost reporting a viral hack, an ADDitude reader in 2010s-era print, and a
2024 Substack. It is the only technique in this corpus that (a) recurs daily, (b) needs no host
task, and (c) is a single physical action with no measurement attached.

---

## TASK 3 — Competitor coverage

All ten apps in the brief were checked. Every quote below is the product's own copy, fetched from
the URL given. Two fetch failures are recorded rather than papered over: `flown.com` returned
`Parse Error: Header overflow` twice (root and `/how-it-works`), so FLOWN's definition below comes
from its Help Centre, which did fetch; `llamalife.co` served only a title tag, so Llama Life's copy
comes from its App Store listing.

| app | what it actually offers, in its own words | source | is the *user's* side of it a daily action? |
|---|---|---|---|
| **Tiimo** | "Watch time pass with a countdown that keeps you anchored" · widgets "See what is next without opening the app" · AI planner "turns your tasks into a clear, realistic schedule" — "type or speak what's on your mind and it will break things down" · "brain dump into clear steps and simple priorities" | [tiimoapp.com](https://www.tiimoapp.com/) | Planning and looking. The **starting** tactics Tiimo publishes (micro-start, five-minute rule, body doubling) live in its [blog](https://www.tiimoapp.com/resource-hub/task-initiation-adhd), not in the product. |
| **Llama Life** | "focus on ONE task at a time - so you're not just making lists, you're actually getting THROUGH them!" · timeboxing: "set a countdown timer for *every* task" · "total List Time, and the estimated finishing time" · "you get confetti (woo hoo!) when you finish a task" · saveable preset routines | [App Store](https://apps.apple.com/us/app/llama-life-adhd-routine-task/id6454469750) | Setting a timer per task — daily, but **meta** (needs the task list first). Preset routines are SETUP. |
| **Focus Bear** | "Set your morning and evening routines once. Focus Bear guides you through them step by step, every day." · "Block distracting sites and apps across Mac, Windows, iOS, and Android, all at once." · "Micro-breaks that reset hyperfocus before burnout" · "Tell Focus Bear what you're working on. It gently nudges you back when you wander off." | [focusbear.io](https://www.focusbear.io/) | Closest of the ten to *starting*: the routine is defined once (SETUP) and **walked through daily** (DAILY, non-meta). Blocking is coercive rather than an action the user takes. |
| **Routinery** | "Set the time, go with the flow." · "Stack your habits, follow the order." · "Anywhere, start right away." · "Move forward smoothly without willpower." · "Change the environment, and behavior follows. Routinery creates that environment for you." · "You don't have to be perfect. We design consistency." | [routinery.app](https://routinery.app/) | Same shape as Focus Bear: SETUP the routine once, run it daily. The runnable step is the daily action; the app supplies the ordering. |
| **Sunsama** | "Plan your day with intention by aligning your goals, prioritizing tasks, and a setting a realistic workload" · "Stay focused and on track all day" · "End each day feeling successful" · "Automatically track your daily wins" · "End work on time, without guilt" | [sunsama.com](https://www.sunsama.com/) | Two genuinely daily, non-meta rituals: a **planning ritual** at the start and a **shutdown ritual** at the end. Both are about the day, not about a task. |
| **Structured** | "Structured combines all your tasks and to-dos into a single visual timeline." · "Split your day into tasks and visualize them in a timeline" · "Create tasks in seconds or import your existing calendar" | [structured.app](https://structured.app/) | Pure visualisation of a plan. Nothing addresses the moment of starting. |
| **Goblin Tools** | "Magic ToDo: Break down todo items" · "Compiler: Turn a braindump into actions" · "Estimator: Guess an activity's timeframe" · "A collection of small, simple tools, for when things feel too big or complicated" | [goblin.tools](https://goblin.tools/) | Daily but wholly **meta** — every tool takes an existing task as input. |
| **Dubbii** | "tackle difficult, mundane tasks with fun, friendly support at any time" · "Break down everyday tasks into micro-steps to reduce overwhelm" · nudges: "Schedule one-off and recurring prompts to remember to tackle those daily tasks at the right moment" · "PDA Mode: Demand avoidant? Whatever you do, don't tap that button!" · live drop-in sessions · badge tracking · €9.99/month | [App Store (IE)](https://apps.apple.com/ie/app/dubbii-the-body-doubling-app/id6450302677) | Body-doubling **to a video**, on demand — a daily, non-meta act. Note the paywall: task library, live sessions, unlimited nudges and badges are subscription-gated. |
| **FLOWN** | body doubling is "when you work in the presence of someone else, either in person or online, to make it easier to start tasks, stay focused, and follow through" | [help.flown.com](https://help.flown.com/en/articles/8333363-what-is-body-doubling) | Booking and attending a session — daily, non-meta, but requires a scheduled slot (SETUP + DAILY). |
| **Focusmate** | "Virtual coworking for getting anything done." · "25, 50, and 75-minute sessions" · "We'll match you with a member of our wonderful community whenever you want to focus." · "Greet your partner, share your session goals and get to work!" · "At the end of the session, check in with your partner and celebrate your progress!" | [focusmate.com](https://www.focusmate.com/) | The session itself is the daily act. The one element uniquely about *starting* is scripted: **saying your goal out loud to a stranger** at the top of the call. |

**What the ten have in common.** Eight of the ten address *what to do next* — planning, ordering,
timing, breaking down. Only three put anything in the user's hands at the moment of starting:
Focus Bear and Routinery (**walk a pre-defined routine, step by step**), and
Dubbii/FLOWN/Focusmate (**be in someone's presence while you start**). None of the ten ships a
standalone daily act that is not attached to a task list.

---

## TASK 4 — Classification, with counts

**This is the answer to "how much of what people say about starting can even be expressed as a
recurring daily intention."** Counts were computed from the two tables above by parsing the file,
not estimated.

The brief's three buckets did not cover the corpus, so two additions were necessary and are
declared here:

- **NO ACTION** — the item contains no action at all. It is a description of the state. Without
  this bucket, 60 items would have had to be forced into a bucket they do not fit.
- **META** (a flag, not a bucket) — the action is recurring, but it only exists relative to a task
  the user already has: "break *it* down", "set a timer for *it*", "do the easy part of *it*".
  These recur, but they are not self-contained; they cannot stand alone as a short imperative that
  is true tomorrow, because tomorrow's version needs tomorrow's task.

### Counts

| bucket | TASK 1 (89 said) | TASK 2 (72 named) | total (161) | share |
|---|---|---|---|---|
| **RECURRING** (true again tomorrow) | 23 | 60 | **83** | 52% |
| **SETUP** (arrange once, benefit daily) | 4 | 9 | **13** | 8% |
| **ONE-SHOT** (done once) | 2 | 3 | **5** | 3% |
| **NO ACTION** (description only) | 60 | 0 | **60** | 37% |

### The recurring 83, split by whether they can stand alone

| | TASK 1 | TASK 2 | total | share of the 83 |
|---|---|---|---|---|
| **META** — needs a host task | 7 | 39 | **46** | 55% |
| **self-contained** — an action in its own right | 16 | 21 | **37** | 45% |

### The 37 self-contained recurring actions collapse to 18 distinct ones

Duplicates across the two tables were merged (shoes appears 5 times, body doubling 4, music 3,
a-sentence-you-say 3, transition ritual 5). The distinct set:

| # | the action | items |
|---|---|---|
| 1 | wearing shoes while working; taking them off when done | TI21, TI82, TI88, N29, N30, N31 |
| 2 | working in another person's presence | TI23, TI79, TI80, N01 |
| 3 | putting music on to begin | TI38, TI83, N65 |
| 4 | chewing gum while working | TI84, N64 |
| 5 | saying a fixed sentence to yourself | TI15, TI25, N67 |
| 6 | writing a short list by hand | TI14, TI17 |
| 7 | wearing a wrist tape as a reminder | TI24, N63 |
| 8 | a fixed transition ritual between tasks (drink, snack, playlist, walk, moving rooms, tea) | N10, N11, N12, N50, N52 |
| 9 | getting dressed first thing in the morning | TI21 |
| 10 | a neutral warm-up (drawing) before the hard thing | TI67, N66 |
| 11 | staying off social and email during the work block | TI14 |
| 12 | putting the phone out of reach | N38 |
| 13 | clearing the desk to only the current thing | N53 |
| 14 | getting away from noise, light and smell before starting | N35 |
| 15 | taking time to settle before starting | N34 |
| 16 | checking what state you are in before starting | N56 |
| 17 | deliberately changing your state — a walk, a funny thing | N33 |
| 18 | having someone else make the first move for you | N36 |

Two items each supply two distinct actions and so appear twice: TI21 (dressing, and shoes) and
TI14 (writing a list, and staying off email). One further recurring item, TI37 ("I find curiosity can bypass the stuck-ness"), was excluded
here: it names a lever, not a discrete act.

### What the numbers say

- **37% of what people say about starting has no action in it at all.** The corpus is
  overwhelmingly *description of a state* — walls, canyons, brakes, treacle, "a start button". Two
  people in unrelated threads asked for the same nonexistent object (TI42, TI46).
- **Of the actions that do recur, the majority (55%) are meta** — they operate on a task the
  person already has. This is the structural finding: task initiation is by definition *about
  something else*, so most of its vocabulary cannot be a self-contained daily imperative.
- **18 distinct self-contained recurring actions** came out of 161 collected items — an 11% yield.
  Eleven of those 18 (#1, 3, 4, 5, 6, 7, 9, 11, 12, 13, 17) are already ordinary physical acts of
  the kind the existing library holds; the seven that are genuinely *about starting* (#2, 8, 10,
  14, 15, 16, 18) are all either state-changes before a task or another person's presence.
- **The competitor scan agrees with the corpus.** Of ten apps, seven address the plan; three
  address the moment. The three that address the moment do it with exactly the two mechanics that
  survive classification here: a pre-defined routine walked daily, and another person present.

---

## TASK 5 — Conflicts, flagged not deleted

| # | item | conflict | source |
|---|---|---|---|
| X1 | **"Note the streak"** — one of five named ways to start | **Streak-based.** Direct collision with "No streaks, no scores, no denominators." It is offered as a *starting* device, not a tracking one. | [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) |
| X2 | "If I don't post this by...I owe you $100." | **Punitive.** Manufactured penalty for not starting. | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) |
| X3 | "Set a timer and race against yourself." — "Those of us with ADHD are oftentimes very competitive." | **Score-shaped.** Introduces a beatable number. | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) |
| X4 | "If something is hard to do, set it up to where the opposite thing is even harder." (Tony Robbins, quoted) | **Punitive by design** — makes not-doing costly. | [OSA](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) |
| X5 | Reward systems — "I have to use a reward system to keep myself going" · "plan a reward for yourself" · "Bait yourself with something enjoyable." | **Contingent reward.** Makes the act conditional on a payout; failure to earn it is a failure state. | [ADD-GS](https://www.additudemag.com/getting-started-adhd-challenges/) · [IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) · [ADD-5W](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) |
| X6 | **Two-minute rule** — "if a task takes less than two minutes… do it immediately" | **Quota-based**, and *the ADHD press itself says it backfires*: "Your weak working memory makes it hard to remember to go back to your original goal when the 2 minute task is complete." A first-person account of the cascade ends: "now 40 minutes have passed and I still haven't done that 'quick' task." | [Inflow](https://www.getinflow.io/post/get-things-done-with-adhd) · [ADDitude](https://www.additudemag.com/how-to-stop-procrastinating-video/) |
| X7 | Fake deadlines / real deadlines as ignition | **Pressure-based.** One source flags the cost itself: "urgency tends to be a real motivator for us but energetically speaking that's not exactly a sustainable way to live" | [SUB-RI](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) · [YTS](https://pickscribe.com/v/SuENZbvkgmA) |
| X8 | "Set micro-goals" | **Goal/target framing** — a denominator in miniature. | [MTY-AP](https://themighty.com/topic/adhd/managing-adhd-paralysis/) |
| X9 | Batch similar work · reorder the list easy-to-hard | **Productivity-optimising** — workflow engineering, not an act of living. | [LSA](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) · [CHADD](https://chadd.org/adhd-in-the-news/getting-started-on-inexplicably-tough-tasks/) |
| X10 | Llama Life: "you get confetti (woo hoo!) when you finish a task" · timeboxing every task | **Gamified completion + timed quota per task.** | [App Store](https://apps.apple.com/us/app/llama-life-adhd-routine-task/id6454469750) |
| X11 | Sunsama: "Automatically track your daily wins" · "End each day feeling successful" | **Scored day.** A day that can be successful can be unsuccessful. | [sunsama.com](https://www.sunsama.com/) |
| X12 | Routinery: "progress tracking through calendar widgets" · "We design consistency." | **Consistency as the product** — the calendar grid is a streak surface. | [routinery.app](https://routinery.app/) |
| X13 | Dubbii: badge tracking; task library, live sessions and unlimited nudges behind €9.99/mo | **Badges** = score. Separately: the body-doubling *rescue* is the paywalled part. | [App Store (IE)](https://apps.apple.com/ie/app/dubbii-the-body-doubling-app/id6450302677) |
| X14 | Focus Bear: "Block distracting sites and apps… all at once" | **Coercive** — removes the choice rather than supporting it. | [focusbear.io](https://www.focusbear.io/) |
| X15 | Focusmate: "check in with your partner and celebrate your progress!" | **Congratulatory register** — the exact tone "and you did them anyway" was cut for. | [focusmate.com](https://www.focusmate.com/) |
| X16 | *Meta-conflict, worth reading twice:* "most of the stock standard advice doesn't help us — we know and agree with everything you say, but it's just another in an entire web of things we are trying to remember, concentrate on or feel motivated about." | An ADHD writer arguing that **adding another thing to remember is itself the harm**. It applies to any of the 18 actions above. | [MTY-10](https://themighty.com/topic/adhd/facts-about-adhd-what-its-like/) |

**Two items point the other way** and are noted because they are unusually aligned rather than in
conflict: "can we just do a b minus job on this? Can we at least get started with B minus work?"
([IHA](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/)) and the
"aluminum standard" — "just doing your best with the resources you got" rather than a "gold
standard of excellence" ([SUB-RT](https://robbieqtelfer.substack.com/p/going-aluminum-why-is-starting-the)).
Both are explicitly anti-perfectionist and carry no measurement.

---

## Sources

Every URL cited above, once:

ADDitude: [getting started](https://www.additudemag.com/getting-started-adhd-challenges/) ·
[procrastination fixes](https://www.additudemag.com/beat-procrastination-unstuck-with-adhd/) ·
[5 ways](https://www.additudemag.com/how-to-get-started-chronic-procrastination-adhd/) ·
[six ways](https://www.additudemag.com/six-ways-to-get-started/) ·
[2-minute rule critique](https://www.additudemag.com/how-to-stop-procrastinating-video/) ·
[motivation](https://www.additudemag.com/adhd-motivation-problems-getting-started-on-tough-projects/).
The Mighty: [10 things](https://themighty.com/topic/adhd/facts-about-adhd-what-its-like/) ·
[light bulb](https://themighty.com/topic/adhd/executive-dysfunction-household-tasks-example/) ·
[ADHD paralysis](https://themighty.com/topic/adhd/managing-adhd-paralysis/).
CHADD: [inexplicably tough tasks](https://chadd.org/adhd-in-the-news/getting-started-on-inexplicably-tough-tasks/).
ADDA: [rituals to transitions](https://add.org/rituals-transitions-get-one-task-another/).
Autistic inertia: [autisticinertia.com](https://autisticinertia.com/2020/12/first-autistic-inertia-article/) ·
[Life Skills Advocate](https://lifeskillsadvocate.com/blog/autistic-inertia-start-stop-switch/) ·
[launch pad](https://lifeskillsadvocate.com/blog/neurodivergent-toolbox-how-to-use-a-launch-pad/).
Substack: [Hanna Keiner comments](https://purposefulconnection.substack.com/p/adhd-sometimes-its-really-really/comments) ·
[Charlie Rewilding comments](https://charlierewilding.substack.com/p/struggling-with-feeling-stuck/comments) ·
[Jezz Lundkvist comments](https://jezz.substack.com/p/the-surprising-truth-about-adhd-motivation/comments) ·
[Robbie Q Telfer](https://robbieqtelfer.substack.com/p/going-aluminum-why-is-starting-the) ·
[ADHD with AI](https://adhdwithai.substack.com/p/start-before-youre-ready-with-ais) ·
[Jenna Free](https://adhdwithjennafree.substack.com/p/adhd-and-task-initiation-how-to-get) ·
[Rach Idowu](https://adultingadhd.substack.com/p/10-ridiculous-adhd-hacks) ·
[ADHD Weasel](https://www.adhdweasel.com/p/adhd-task-switching-ritual).
Podcasts / video: [I Have ADHD #319](https://ihaveadhd.com/episode-319-why-cant-i-just-start-adhd-task-initiation/) ·
[Outsmart ADHD Ep.5 transcript](https://outsmartadhd.transistor.fm/episodes/task-initiation-and-adhd-understanding-the-struggle-and-finding-solutions/transcript) ·
[Caren Magill video transcript](https://pickscribe.com/v/SuENZbvkgmA) ·
[Hacking Your ADHD — Wall of Awful](https://www.hackingyouradhd.com/podcast/the-wall-of-awful-with-brendan-mahan).
Coaching blogs: [Honestly ADHD](https://honestlyadhd.com/adhd-struggle-starting-stuff-e-task-initiation/) ·
[The Mini ADHD Coach](https://www.theminiadhdcoach.com/living-with-adhd/adhd-task-initiation) ·
[Jayne Hardy](https://jaynehardy.co.uk/body-doubling-for-when-youre-struggling-to-focus-or-get-started-on-tasks/) ·
[Inflow](https://www.getinflow.io/post/get-things-done-with-adhd).
Press: [HuffPost home shoes](https://www.huffpost.com/entry/home-shoes-adhd-task-paralysis_l_6a83753fe4b05886dff6476f).
Apps: [Tiimo](https://www.tiimoapp.com/) · [Tiimo tactics](https://www.tiimoapp.com/resource-hub/task-initiation-adhd) ·
[Llama Life](https://apps.apple.com/us/app/llama-life-adhd-routine-task/id6454469750) ·
[Focus Bear](https://www.focusbear.io/) · [Routinery](https://routinery.app/) ·
[Sunsama](https://www.sunsama.com/) · [Structured](https://structured.app/) ·
[Goblin Tools](https://goblin.tools/) · [Dubbii](https://apps.apple.com/ie/app/dubbii-the-body-doubling-app/id6450302677) ·
[FLOWN](https://help.flown.com/en/articles/8333363-what-is-body-doubling) ·
[Focusmate](https://www.focusmate.com/).
