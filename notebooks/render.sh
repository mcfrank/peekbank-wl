#!/usr/bin/env bash
# Render one chapter per call (multi-file calls can silently skip files):
#   ./render.sh 01-data.qmd
# or the whole book:
#   ./render.sh
set -euo pipefail
cd "$(dirname "$0")"
quarto render "$@"
