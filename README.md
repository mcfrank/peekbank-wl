# peekbank-wl (branch: vanilla-only vs mixed designs)

Does familiar-word recognition look worse when the session also contains non-vanilla trials
(mispronunciations, novel words, mutual exclusivity, …)? A reanalysis of the vanilla trials from
Frank et al. (2025, eLife), split by session design. Peekbank release 2026.1.

The novel-word-learning analysis that this repo was created for is on branch
`claude/adoring-goldberg-l4mtko`.

## Layout

```
HANDOFF.md          goal, decisions, results, next steps
metadata/           nonvanilla_types.csv: hand-coded type of non-vanilla trial per dataset
data/derived/       vanilla_trials_design.csv, session_design.csv (committed)
cache/              Peekbank metadata pull, clone of peekbank-development (gitignored)
notebooks/          Quarto book: 01-design, 02-split, 03-within; _freeze/ is committed
```

## Rendering

Requires R (tidyverse, here, lme4, lmerTest, broom.mixed, ggrepel, cowplot, peekbankr) and Quarto.
See HANDOFF.md for the cloud-container setup. Chapter 01 needs a `REDIVIS_API_TOKEN`
(scope `data.metadata`) and clones `peekbank/peekbank-development` into `cache/`. Chapters 02–03
run from the committed CSVs, except the timecourse figure in 02, which reads the cached clone.

```bash
cd notebooks
./render.sh 01-design.qmd
./render.sh 02-split.qmd
./render.sh 03-within.qmd
```
