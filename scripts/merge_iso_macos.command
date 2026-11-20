#!/usr/bin/env bash
# macOS double-clickable script (.command) to merge split ISO parts and verify SHA-256
set -euo pipefail
cd "$(dirname "$0")"

PART1="Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partaa"
PART2="Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partab"
OUT="Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso"
EXPECTED_SHA256="07aa728e5b810b9ddb7cc5006083957323709a29a34061befac200a51fd6f835"

for f in "$PART1" "$PART2"; do
  if [ ! -f "$f" ]; then
    echo "[ERROR] Missing $f"
    echo "Please place this script in the same folder as the downloaded .partaa and .partab files."
    read -r -p "Press Enter to exit..."
    exit 1
  fi
done

echo "[1/2] Merging $PART1 + $PART2 -> $OUT ..."
cat "$PART1" "$PART2" > "$OUT"

echo "[2/2] Verifying SHA-256 checksum..."
ACTUAL_SHA256="$(shasum -a 256 "$OUT" | awk '{print $1}')"
echo "Expected: $EXPECTED_SHA256"
echo "Actual  : $ACTUAL_SHA256"

if [ "$ACTUAL_SHA256" = "$EXPECTED_SHA256" ]; then
  echo "[OK] SHA-256 verified! $OUT is ready to use."
else
  echo "[FAIL] SHA-256 mismatch! Please re-download the split files."
  read -r -p "Press Enter to exit..."
  exit 1
fi

read -r -p "Press Enter to close..."
