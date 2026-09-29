#!/usr/bin/env bash
LOG_FILE="${1:-build/system_fonts.log}"
echo "--- System Font Audit ---" > "$LOG_FILE"
MISSING=0
while IFS= read -r font || [[ -n "$font" ]]; do
    [ -z "$font" ] && continue
    echo "Verifying: $font"
    OUTPUT=$(luaotfload-tool --find="$font" 2>&1)
    
    if echo "$OUTPUT" | grep -qi "resolved file name"; then
        echo "[OK] $font -> $OUTPUT" >> "$LOG_FILE"
    else
        echo "[FATAL] Missing Font: $font" | tee -a "$LOG_FILE"
        MISSING=1
    fi
done < "$(dirname "$0")/fonts.in"

if [ "$MISSING" -eq 1 ]; then
    echo "Error: Required fonts are missing. Check $LOG_FILE"
    exit 1
fi
exit 0
