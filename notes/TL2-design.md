# TL2 design (fernald_marchman_2012, adams_marchman_2018)

Source: the TL2 design spreadsheet ("TL2design acrossage.xls") and Slack DMs from Virginia Marchman
to Mike Frank, 2026-11-04. The spreadsheet itself is not committed (internal lab document); this
summarizes the parts used for exposure coding. Marchman confirmed that both Fernald & Marchman (2012)
and Adams et al. (2018) used this design.

Each age has two sessions, visit A and visit B.

## Deebo task (24 months)

* **Medial trials** (familiar target, e.g. baby vs. doggy) end with the novel word as the thing the
  familiar object is on: "There's a baby on the deebo." The alternative phrase is "That's a baby over
  there." The deebo itself is not a pictured target.
  * Visit A: 6 medial trials, 3 "on the deebo" and 3 "over there".
  * Visit B: 10 medial trials, 5 "on the deebo" and 5 "over there".
* **Test** (visit B only): 4 trials of "Where's the deebo? Can you see the deebo?" with two novel
  pictures.

In Peekbank, fernald_marchman_2012 has the phrases, so labelings are counted directly. Its lists put
2 "on the deebo" trials among the first 4 medial trials of visit B.

adams_marchman_2018's stored phrases for these trials are generic per-word questions ("Where's the
baby? Can you see it?"; 4 distinct phrases across ~2,000 medial trials), not the medial sentences,
so labelings can't be counted. Its visit-B lists always put test 1 after 4 medial trials and
tests 2–4 after all 10, and most children did the A/B task twice (about 20–23 and 24–27 months).
Each medial trial is counted as 0.5 deebo labelings, the design rate. This gives 5 labelings before
test 1 and 8 before tests 2–4 in round one, and 13 and 16 in round two. These are expected counts,
not observed ones.

## Ferret task (30 months)

* Exposure (visit A only): 4 trials per word, "You can EAT the MANJU. EAT the MANJU." / "You can DRIVE
  the TEMPO. DRIVE the TEMPO."
* Test (visit A): 5 per word. One comes immediately after the first exposure, the rest after all
  exposure trials.
* Retention (visit B): 3 per word, with no further exposure.

adams_marchman_2018's modi/panju trials have the same structure (Exp1–4, ImTest1, Test2–5).

Note: Bion, Borovsky & Fernald (2013) used a different, mutual-exclusivity design and is not a model
for these tasks.

## fernald_totlot (Fernald, Perfors & Marchman, 2006): unresolved

The paper's design table (15/18/21/25 months) lists only familiar-word, partial-word, "New Word"
(banana/toma, 4 trials at 21 months, ME), verb, adjective, difficult-word and superordinate trials.
It does not list the kreeb/nonce trials (`zteach`, `alearn`, `learn`, `ylearn`).
Marchman (from the i-charts): `new` is ME with toma always the target. In `ylearn`, kreeb and nonce are
always paired with kreeb as the target, so "nonce" may be a novel picture rather than a word. She did
not recognize an exposure → test design. The Peekbank data do contain 18-month `zteach` trials
(kreeb or nonce as both target and distractor) before `alearn`/`learn` tests, which the current coding
treats as teaching. Confidence is set to low until this is resolved.
