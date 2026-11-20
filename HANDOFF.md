# Handoff: vanilla-only vs mixed designs

Branch `claude/peekbank-vanilla-split-qx8syl` (from `main`; independent of the novel-word-learning
work on `claude/adoring-goldberg-l4mtko`). First session: 2026-11-20.

## Goal

Elika Bergelson asked Mike whether children do less well on standard LWL trials when the
experiment also has "something is off" trials (mispronunciation, novel words, absent referents,
ME), beyond an effect of trial number. Mike's plan: take the vanilla word-recognition analysis of
Frank et al. (2025, eLife; code in `peekbank/peekbank-development`) and split it by whether the
study has only vanilla trials.

## Decisions

1. Use the eLife analysis file (`cached_intermediates/1_d_trial.Rds`, release 2026.1) unchanged:
   same trials, filters, windows and models. (Mike)
2. Split variable from Peekbank's `vanilla_trial` flag over **all** trials in a session. Both a
   dataset-level and a session-level coding are reported. (Agent's choice; session-level added
   because four longitudinal datasets change design between visits.)
3. Type of non-vanilla trial is hand-coded per dataset in `metadata/nonvanilla_types.csv` from
   condition names and phrases. Not checked against the papers. (Agent's choice)

## Results (2026-11-20)

* 26 datasets, 58,099 vanilla trials, 4,124 sessions. 9 datasets are vanilla only; 17 have
  non-vanilla trials. By session: 1,406 vanilla only (mean 18 mo), 2,718 mixed (mean 29 mo).
* Dataset-level design, adjusting for log age: −0.012 [−0.042, 0.017] (mixed minus vanilla only).
* Session-level design: +0.051 [0.040, 0.063]; RT −0.073 log units. Driven by
  adams_marchman_2018, fernald_marchman_2012, fernald_totlot, where vanilla-only sessions are the
  first visit. Confounded with visit and items.
* Log trial position: +0.006 per SD; adding it changes no design coefficient.
* By type vs vanilla only: mispronunciation −0.001 [−0.056, 0.054]; novel/ME −0.016
  [−0.051, 0.019]; sentence/other +0.015 [−0.013, 0.043]; novel+sentence +0.059.
* Within mixed sessions, preceding trial non-vanilla: +0.005 [−0.003, 0.013]. By type:
  mispronunciation −0.032 [−0.066, 0.002] (2 datasets, 912 trials); novel/ME −0.012
  [−0.030, 0.006]; novel+sentence +0.014; sentence/other +0.002.

## Gotchas

* The Fernald/Marchman longitudinal datasets run vanilla-only sessions at the youngest visit.
  Dataset-level and session-level codings disagree for them, and within them design = visit.
* `vanilla_trial` is liberal: bacon_gendercues, mahr_coartic, borovsky_2019, potter_canine,
  weaver_* have manipulations that count as vanilla.
* pomper_salientme has `high/low_salience_test` conditions on both sides of the vanilla flag.
* `trial_order` starts at 0 in some datasets; the notebooks use position among imported trials.
* The eLife file does not filter on `trials.excluded`; neither do we.
* `0_d_aoi.Rds` (14.8M rows) is needed only for the timecourse figure; its summary is cached in
  `cache/02_timecourse.rds`.

## Environment setup

As in the `peekbank-report` skill (`mcfrank/claude-skills`, branch `claude/peekbank-report-skill`),
plus `ggrepel` and `cowplot`. brms is not needed.

## Next steps

1. Mike to decide whether this is worth sending to Elika as is.
2. Check `metadata/nonvanilla_types.csv` against the papers, and code non-vanilla type per
   condition instead of per dataset (e.g. fernald_totlot `gated` is a sound manipulation).
3. Mispronunciation is the one lead. More MP data would help: non-English MP datasets in Peekbank
   were dropped by the eLife English filter and could be added for this question.
4. A brms version with dataset-specific slopes for the local effect.
5. The book has not been published to Quarto Pub.
