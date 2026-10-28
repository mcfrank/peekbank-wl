# peekbank-wl: novel word learning in Peekbank

How does recognition of a novel word depend on the number of times a child has been taught it,
and how does that relationship change with age? The data are novel-word trials from
[Peekbank](https://peekbank.github.io/peekbank-website/) (release 2026.1).

## Layout

```
notebooks/               Quarto book (R / knitr)
  _quarto.yml            chapter list, freeze: auto
  index.qmd              overview and definitions
  01-data.qmd            pull metadata + AOI timepoints for datasets with novel words (needs Redivis token)
  02-exposure-coding.qmd trial roles and prior-exposure counts
  03-trials.qmd          trial-level accuracy and exclusions -> data/derived/novel_trials.csv
  04-exposure-by-age.qmd accuracy by exposures across age, lmer
metadata/                hand-coded inputs (edit these, not the notebooks)
  exposure_design.csv    role of each dataset x condition (teaching, test_nn, test_me, ...)
  external_teaching.csv  teaching that happened outside the imported trials (from source papers)
  novel_words.csv        recodes generic novel labels (e.g. "novel" -> "deebo")
cache/                   gitignored local pull from Peekbank
data/derived/            small derived trial-level file (committed)
```

## Rendering

Requirements:

* R with tidyverse, here, lme4, lmerTest, broom.mixed
* `peekbankr` (`remotes::install_github("peekbank/peekbankr")`)
* Quarto
* `REDIVIS_API_TOKEN` with the `data.metadata` scope, needed for chapter 1 only

```bash
cd notebooks
./render.sh 01-data.qmd             # one chapter per call
./render.sh 02-exposure-coding.qmd
./render.sh 03-trials.qmd
./render.sh 04-exposure-by-age.qmd
```

`freeze: auto` caches chapter outputs by *source*. When hand-coded metadata changes, delete
`notebooks/_freeze/<chapter>` before re-rendering, or the cached output will be stale.

The book is AI-generated and preliminary; see the banner on each chapter.
