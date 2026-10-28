# Handoff: novel word learning in Peekbank

Status as of the end of the second session (2026-10-28). Branch: `claude/adoring-goldberg-l4mtko`.

**Session 2:** chapters 01–04 rendered with real data (release 2026.1). `data/derived/novel_trials.csv`
and `notebooks/_freeze/` are committed. Changes this session:

* `here::i_am()` in every chapter (current `here` treats `notebooks/_quarto.yml` as the root).
* Missing-trial reconstruction in chapter 02 (see Gotchas). `teaching_observed` keeps the
  un-reconstructed count.
* `needs_prior_session` column in `exposure_design.csv`: fernald_totlot `ylearn` and
  fernald_marchman_2012 `FerretRetention` get NA teaching when the teaching session is not in Peekbank
  (4 ylearn trials).
* Sensitivity models (observed-only teaching; dataset as fixed effect) and timing controls
  (`session_trials`, `trials_since_teaching` from chapter 02) in chapter 04.
* `render.sh` sets a UTF-8 locale if none is set.

Mike has written to Heidi Baumgartner and Virginia Marchman about hit-list items 1–4.

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
* **Trials missing from Peekbank.** Many Fernald-lab administrations (and a few byers-heinlein ones)
  have gaps in `trial_order`. Those trials are not in `trials` at all (every trial there *is* linked
  to an administration), presumably dropped at import for lack of gaze data. A missing teaching trial
  undercounted teaching (e.g. FerretTest at 1–3 instead of 4 for ~100 trials). Chapter 02 now fills
  a gap from donor administrations with an identical trial list (exact match on every shared position,
  ≥80% overlap, all donors agree). It never fills trailing gaps, or positions absent from every
  administration (pomper_salientme breaks; pomper_yumme v5 un-imported teaching). After this,
  6 FerretTest and 4 byers-heinlein N–N trials remain below the design count.
* **Same-age administrations** (fernald_marchman_2012, 200 pairs) are ordered by `administration_id`.
  This matches the content in all 200 pairs (Medial → Medial+Test; Exposure → Retention).
* **`here`:** recent versions stop at `notebooks/` because of `_quarto.yml`; each chapter calls `here::i_am()`.
* **Locale:** cloud containers default to POSIX, so en dashes print as `<U+2013>`; `render.sh` exports `LANG=C.UTF-8`.
* **Freeze:** `freeze: auto` keys on chapter source. After editing `metadata/*.csv`, delete
  `notebooks/_freeze/<chapter>` before re-rendering.

## Next steps

1. ~~Render 01–04 with real data; sanity-check the coding~~ (done in session 2).
2. When Baumgartner / Marchman reply: fill `metadata/external_teaching.csv` (baumgartner_2014 is
   still NA and drops out: 269 kept N–N trials, 12–13 mo, the only sub-18-month data outside the
   reflook/yurovsky tablets) and confirm the Fernald-lab protocols. Then delete `notebooks/_freeze/02-*`
   through `04-*` and re-render 02–04.
3. ~~Timing controls~~ (done: chapter 04 "Timing controls", with position, test number, and
   trials since teaching). With any one of them, the 24-month teaching slope goes from −0.03 to about 0.
   Position and test number are collinear (r ≈ .95), and in reflook_socword teaching is collinear
   with both, so the 12–18-month curve (mostly socword) cannot be separated from fatigue. Possible
   next step: a joint model of teaching + recency on the in-session-teaching datasets with
   by-dataset slopes, or dropping socword as a sensitivity check.
4. Later: the N–F / ME analysis (`test_me`, `test_nf`), and total-exposures vs teaching-only models.

## Source-paper coding status

**Coded from accessible sources (in `metadata/external_teaching.csv` or counted in-data):**

| Dataset | Teaching | Source |
|---|---|---|
| yurovsky_2017 | modi: 4 learning trials × 3 labelings, all before test; dax never taught (ME word) | Yurovsky & Frank (2017) Dev Sci, PMC4870162 |
| reflook_v4 | 3 naming events × 3 labelings per word, all before test | Yurovsky et al. ms Expt 1 (callab.uchicago.edu/papers/ywkghf-ur.pdf); github.com/dyurovsky/refword |
| reflook_socword | learning trials (3 labelings each) **interleaved** with tests in one fixed order. Teaching before a test = 1–4 by `trial_order`; verified against Peekbank's trial_order × condition | Yurovsky, Wade & Frank (2013) CogSci; refword `stimuli/soc_word_stimuli.docx` |
| byers-heinlein_2022 | 6 training trials per word, 1 token each (in data, parsed from phrases) | Byers-Heinlein et al. (2022), PMC8992731 |
| pomper_salientme | 0 teaching; 3 ME referent-selection trials per word, 1 token each, all before test, no feedback | Pomper & Saffran (2019) Child Dev, PMC6128788 |

**Hit list: still needed (Mike is chasing these):**

1. Baumgartner, H. A. (2014). *Understanding the Role of Non-Contrastive Variability in Word
   Learning and Visual Attention in Infancy* [Doctoral dissertation, UC Davis]. ProQuest 3685177.
   Need: labelings per habituation trial, and the habituation criterion and min/max number of
   habituation trials (ideally per-infant counts). Until then this dataset has NA teaching.
2. Fernald, A., & Marchman, V. A. (2012). *Child Development, 83*(1), 203–222. The 24/30-month
   "Ferret" task (manju/tempo; Exposure, ImmTest, Test, Retention) and the "deebo" medial task are
   not described in the paper. Need: the protocol, whether all exposure trials are in the data, and
   the session structure. The deebo paradigm is attributed to Fernald, Zangl, Portillo & Marchman
   (2008), "Looking while listening", in *Developmental Psycholinguistics* (pp. 97–135); not accessed.
3. Adams, K. A., Marchman, V. A., et al. (2018). *Child Development, 89*(5), 1674–1690. Need: the
   modi/panju protocol (Exp1–4, ImTest, Test2–5), and how the word in `noveltest` was introduced.
   The closest published design is Bion, Borovsky & Fernald (2013), *Cognition, 126*, 39–53
   (4 ostensive labelings per word), which is unconfirmed as the same procedure.
4. Fernald, A., Perfors, A., & Marchman, V. A. (2006). *Developmental Psychology, 42*(1), 98–116.
   The novel-word trials (zteach / learn / ylearn with kreeb and nonce; `new` with toma) are probably
   among the paper's unexplained "filler" trials. Need: teaching structure, and whether the
   21-month ylearn tests rely on 18-month teaching or new teaching.
5. Pomper, R., & Saffran, J. R. (2018). *More than distractors: Familiar objects influence
   toddlers' semantic representations in novel word learning.* ICIS poster, Philadelphia.
   Need: the v5 isolated-teaching phase (tokens per trial) and the v4 design. Coded provisionally
   as 1 teaching event per word for v5.
6. Pomper & Saffran, unpublished "Dimy" study. Low priority: there is no teaching, so it is
   excluded from the main analysis.

Items 2–4 are Fernald/Marchman lab tasks; Virginia Marchman is the likely source.
