#!/bin/bash
set -euo pipefail

cd /home/stran5/iclr-2027-scores

echo "=================================="
echo "Update started: $(date -u)"
echo "=================================="

echo "[1/2] Downloading..."
.venv/bin/python download.py

# Chỉ build nếu snapshot mới nhất đã hoàn tất
.venv/bin/python - <<'PY'
from pathlib import Path
import json
import sys

base = Path("snapshots")
folders = sorted(p for p in base.iterdir() if p.is_dir()) if base.exists() else []

if not folders:
    sys.exit("ERROR: No snapshot found")

manifest = folders[-1] / "manifest.json"

if not manifest.exists() or not json.loads(manifest.read_text()).get("complete", False):
    sys.exit("ERROR: Latest snapshot incomplete. Skipping build.")

print("Snapshot complete:", folders[-1])
PY

echo "[2/2] Building website..."
.venv/bin/python build_site.py

echo "Update completed: $(date -u)"
