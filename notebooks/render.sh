#!/usr/bin/env bash
# Render one chapter per call (multi-file calls can silently skip files):
#   ./render.sh 01-data.qmd
# or the whole book:
#   ./render.sh
set -euo pipefail
cd "$(dirname "$0")"
# R needs a UTF-8 locale to print en dashes etc. in figures (cloud containers default to POSIX)
export LANG="${LANG:-C.UTF-8}"
quarto render "$@"
