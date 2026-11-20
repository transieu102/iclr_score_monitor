#!/bin/bash
set -euo pipefail

BASE="/home/stran5/iclr-2027-scores"

cd "$BASE"

# Prevent overlapping updates
exec 9>/tmp/iclr-2027-scores.lock
flock -n 9 || exit 0

# Load OpenReview credentials
if [ -f /root/.config/iclr-2027.env ]; then
    source /root/.config/iclr-2027.env
fi

export PYTHONUNBUFFERED=1

echo "=================================="
echo "Daily snapshot: $(date -u)"
echo "=================================="

"$BASE/update.sh"
