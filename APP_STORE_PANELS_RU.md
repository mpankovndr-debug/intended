# App Store panels — Russian

Caption text for the six screenshot panels. The device screenshots themselves render in Russian automatically once you capture them with the app set to RU — only the overlay copy below needs setting by hand.

Where a panel mirrors real UI (the action pills, the focus-area chips), the Russian is **the app's own string**, not a fresh translation, so the panel and the screen agree. Those are marked ✓.

Register is **ты**, matching the app.

---

## Panel 1 — mosaic (purple)

| | |
|---|---|
| Eyebrow | `INTENDED · ТВОЙ МЕСЯЦ В ЦВЕТЕ` |
| Chips ✓ | `Здоровье` · `Забота о себе` · `Настроение` |
| Headline | `Твой месяц, а не оценка.` |
| Body | `Каждое маленькое дело становится квадратом. Мозаика только растёт.` |

*On the headline:* "score" went to **оценка** (a mark, a grade) rather than счёт (a tally). Оценка carries the judgement, which is the whole point of the line.

---

## Panel 2 — letter (tan)

| | |
|---|---|
| Headline | `Оно пишет тебе письмо.` |
| Pill 1 | `Четыре честные строки о твоём месяце` |
| Pill 2 | `И вопрос, с которым стоит побыть` |

*On "it":* приложение is neuter, so **оно** works and keeps the English's deliberate understatement. "Приложение пишет тебе письмо" is correct but heavier.

---

## Panel 3 — today (brown)

| | |
|---|---|
| Headline | `Четыре маленьких дела. Никаких серий.` |
| Body | `Ничего не рвётся. Ничего не обнуляется. Только сегодня.` |
| Pill 1 ✓ | `Сделай 3 медленных вдоха` |
| Pill 2 ✓ | `Выпей 3 стакана воды` |
| Pill 3 ✓ | `Разреши себе отдохнуть` |

*On "streaks":* **серии** is the established Russian term in habit apps. "Без серий" is ambiguous on its own (series of what?), so **никаких серий** — flatter and unmistakable.

*On "breaks":* **рвётся** (tears) rather than прерывается (is interrupted). A streak tearing is the physical image the English has.

---

## Panel 4 — rescue (green)

| | |
|---|---|
| Headline | `Затихать — можно.` |
| Body | `Девять дней тишины — и оно просит одно маленькое дело, а не извинения.` |

*On the headline:* the app already uses затих / тихих дней throughout (`seasonEveningLine`, `letterCameBack`), so **затихать** keeps the panel inside the app's own vocabulary. It also comes out shorter than the English, which helps the layout.

---

## Panel 5 — plan (pink)

| | |
|---|---|
| Headline | `Следующий месяц — из того, что было.` |
| Pill 1 | `Одно решение — о твоих делах` |
| Pill 2 | `Одно — о твоём ритме` |
| Pill 3 | `и честная проверка, сработало ли` |

*On "measured":* translated as **честная проверка** (an honest check) rather than anything with измеримый, which is technical in a way the English isn't. It matches the letter's own "с честным ответом, сработал ли он".

---

## Panel 6 — share (purple)

| | |
|---|---|
| Headline | `Стоит сохранить. Стоит поделиться.` |
| Body | `Твой сезон и твоя мозаика — готовые для сторис.` |

*On "a story":* **сторис** is the standard loanword and what the audience actually says.

---

## Two lines that grow, for the layout

Russian runs 10–20% longer than English on average. Most of these came out even or shorter. Two didn't:

| Line | EN | RU | Growth |
|---|---|---|---|
| Panel 3 headline | 31 | 37 | **+19%** |
| Panel 3 body | 42 | 54 | **+29%** |

Panel 3 is your lead screenshot under the recommended order, so it's worth checking first at thumbnail size. Everything else should drop into the existing layout unchanged, and panel 4's headline actually gets *shorter* (23 → 17).

---

## Before you ship these

My Russian is the same grade the handoff flags in "Needs you" item 8 — serviceable, correct in its mechanics, not native. The lines a native ear should check first, in order:

1. **Panel 4 body** — `просит одно маленькое дело, а не извинения`. Просить takes the genitive with abstract objects (просить извинений), but дело wants the accusative, so the two halves pull against each other. A native would either accept it as colloquial or restructure the sentence. This is the one I'm least sure of.
2. **Panel 3 headline** — whether никаких серий reads naturally to someone who has actually used Russian habit apps, or whether стриков is now the more common word.
3. **Panel 1 headline** — оценка vs счёт. Both defensible; the choice changes the feeling.

Everything else I'd ship as-is.
