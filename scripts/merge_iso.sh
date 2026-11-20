#!/bin/bash
set -euo pipefail
OUT="Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso"
echo "Merging parts into $OUT ..."
cat "${OUT}.partaa" "${OUT}.partab" > "$OUT"
if [ -f SHA256SUMS.txt ]; then
  echo "Verifying SHA-256..."
  sha256sum -c --ignore-missing SHA256SUMS.txt
fi
echo "Done: $OUT"
