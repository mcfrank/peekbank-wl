# Handoff: novel word learning in Peekbank

Status as of the end of the first session. Branch: `claude/adoring-goldberg-l4mtko`.

## Goal

Estimate word-recognition accuracy (proportion target looking) as a function of (log) number of
**teaching exposures** to a novel word, with separate curves by child age (focus: 1–3 years),
using all novel-word data in Peekbank release **2026.1**, accessed with `peekbankr`.
Analysis best practices follow Frank et al. (2025, eLife, "Continuous developmental changes in word
recognition…"); its code is at https://github.com/peekbank/peekbank-development (`1_tidy_data.qmd`).

## Decisions made with Mike (do not re-litigate)

1. **Teaching exposure** = every labeling of the word with its referent disambiguated during
   teaching, *including teaching in the same child's earlier sessions* (longitudinal teaching
   counts). Test trials are not teaching.
2. **ME / referent-selection trials are test trials**, not teaching. They are counted separately
   (`me_*`). The main predictor is teaching. For pomper_salientme and pomper_yumme v4, whose
   learning phase is ME-only, N–N tests therefore have 0 teaching and some ME exposures.
3. **Primary outcome: N–N test trials** (novel target vs novel distractor). N–F (ME-type) trials
   are a separate, later analysis.
4. **No minimum number of trials per child.** Otherwise follow the paper: long window 200–4000 ms,
   drop trials with < 50% valid data, drop Peekbank-excluded trials.
5. **Model:** simple `lmer(acc ~ log(teaching + 1) * log(age/24) + (1|dataset) + (1|subject) + (1|word))`.
6. **Keep bilingual / multilingual data** for now.
7. **Release 2026.1** (Redivis version v1.4).
8. Data will be sparse and mostly 12–30 months; that is accepted.

## What exists

* `notebooks/`: Quarto book (knitr/R). Chapters:
  * `01-data`: pulls the data with `peekbankr`.
  * `02-exposure-coding`: trial roles and exposure counts.
  * `03-trials`: accuracy and exclusions; writes `data/derived/novel_trials.csv`.
  * `04-exposure-by-age`: plots and lmer.
* `metadata/exposure_design.csv`: role for every dataset × condition × target novelty, with
  confidence and notes. Roles:
  * `teaching`, `teaching_incidental`
  * `test_nn`, `test_nf`, `test_me`, `test_untaught`, `test_nn_incidental`
  * `familiar`, `familiar_me_control`, `exclude`
* `metadata/external_teaching.csv`: teaching outside the imported trials (learning videos,
  habituation, un-imported teaching trials). **Several counts are still `NA` (pending)**, and
  those datasets drop out of the analysis until they are filled.
* `metadata/novel_words.csv`: recodes fernald_marchman_2012's generic "novel" label to "deebo".

**Nothing has been rendered with real data yet.** The first session had no Redivis token.
Chapters 02–04 were run end to end on a synthetic fixture (real metadata, fake gaze samples) to
check the code paths only; those numbers mean nothing.

## Environment setup for a fresh container (about 10 minutes)

The cloud image has no R or Quarto.

```bash
# R + system libs
apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq r-base-core r-base-dev \
  libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
  libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev pandoc

# binary CRAN packages from Posit Package Manager
cat > ~/.Rprofile <<'EOF2'
options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/noble/latest"),
        HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])),
        Ncpus = 4)
EOF2
Rscript -e 'install.packages(c("tidyverse","remotes","here","knitr","rmarkdown","lme4","lmerTest","broom.mixed","viridis","jsonlite"))'

# peekbankr: remotes::install_github() FAILS in these sessions (GitHub API is scoped to this repo),
# but anonymous git clone works, so install from a local clone:
git clone --depth 1 https://github.com/peekbank/peekbankr.git /tmp/peekbankr
Rscript -e 'remotes::install_local("/tmp/peekbankr", upgrade="never", dependencies=TRUE)'

# Quarto
curl -sSL -o /tmp/quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.42/quarto-1.6.42-linux-amd64.deb
dpkg -i /tmp/quarto.deb
```

Check the token before anything else: `Rscript -e 'nchar(Sys.getenv("REDIVIS_API_TOKEN")) > 0'`.

Mike's skills are in the public repo `mcfrank/claude-skills`; clone it and read
`quarto-book/SKILL.md`, the book conventions this project follows, and `redivis/SKILL.md`.

## Gotchas learned

* **`trials` has no `administration_id`.** The trial-to-child link exists only in the timepoint
  tables, so chapter 02 recovers it via `distinct(administration_id, trial_id)` from AOI data.
* **Anonymous Redivis REST** (`https://redivis.com/api/v1/tables/datapages.peekbank:a3v0:v1_4.<table>/rows?maxResults=…`)
  serves the small tables without a token, but results over 100 MB, including any timepoint
  table, and all queries need auth.
* **fernald_totlot `new` (ME) trials:** distractor novelty is mis-coded as "novel" in Peekbank,
  because the import script sets distractor novelty from the target label. Handled in
  `exposure_design.csv`. Worth an issue on peekbank-data-import.
* **fernald_marchman_2012 "deebo":** incidental labeling. Familiar-Medial trials say either
  "There's a baby on the deebo" (+1 teaching) or "…over there" (none). The test is
  "Where's the deebo?", with the target labeled "novel" in Peekbank. Chapter 02 parses this from `full_phrase`.
* **byers-heinlein_2022:** training trials have a *familiar* target; the novel word appears only in
  the phrase ("the dog on the walem"). Chapter 02 parses this from `full_phrase`.
* **adams_marchman_2018:** has no phrases. Its `noveltest` (label "novel") cannot be counted, so it
  is coded `test_nn_incidental` and left out of the main analysis.
* **Freeze:** `freeze: auto` keys on chapter source. After editing `metadata/*.csv`, delete
  `notebooks/_freeze/<chapter>` before re-rendering.

## Next steps

1. Install the environment (above), confirm the token, then `cd notebooks && ./render.sh 01-data.qmd`.
   If `pb$subset$aoi_timepoints(dataset_name %in% !!novel_datasets)` fails to translate, loop over
   datasets with `==`.
2. Render 02. Sanity-check the outputs against the source designs:
   * the role table: no `uncoded` rows
   * the exposure summary, e.g. adams_marchman_2018 modi/panju should show 4 Exp trials then tests;
     fernald_marchman_2012 FerretExposure counts per child; byers-heinlein_2022 6 training trials per word
   * look at a few individual children's trial sequences
3. Fill the pending rows of `metadata/external_teaching.csv` from the source papers
   (see the hit list below; Mike is chasing the ones we could not access).
4. Render 03 and 04. Commit `data/derived/novel_trials.csv` and `notebooks/_freeze/`.
5. Report the figure, the coverage table (trials × exposures × age), and the model to Mike, with
   honest caveats on sparsity.
6. Later: the N–F / ME analysis (`test_me`, `test_nf`), and total-exposures vs teaching-only models.

## Source papers: hit list

See the section below, filled in from the paper search at the end of session 1.
