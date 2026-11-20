#!/bin/bash
set -euo pipefail

BASE="/home/stran5/iclr-2027-scores"

# 18 Nov 2026, 23:59:59 AoE
# Cutoff = 19 Nov 2026, 12:00:00 UTC
CUTOFF=$(date -u -d '2026-11-19 12:00:00 UTC' +%s)
NOW=$(date -u +%s)

if (( NOW >= CUTOFF )); then
    echo "AoE deadline reached. Removing cronjob."

    crontab -l 2>/dev/null |
      grep -vF "$BASE/run_until_aoe.sh" |
      crontab - || true

    exit 0
fi

# Prevent overlapping updates
exec 9>/tmp/iclr-2027-scores.lock
flock -n 9 || exit 0

cd "$BASE"

# Load OpenReview credentials
if [ -f /root/.config/iclr-2027.env ]; then
    source /root/.config/iclr-2027.env
fi

# Stop the update at the AoE deadline
REMAINING=$((CUTOFF - NOW))

timeout -s TERM -k 15s "${REMAINING}s" \
    "$BASE/update.sh"
