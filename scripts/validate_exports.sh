#!/usr/bin/env bash
set -e

echo "Validating plain text export schemas..."
EXPORT_DIR="${1:-${CG_EXPORT_DIR:-build/export}}"
FILES=("$EXPORT_DIR/list_alpha.txt" "$EXPORT_DIR/list_grade.txt")

for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "[FAIL] Missing export file: $file. Ensure TeX compilation generated the exports."
        exit 1
    fi

    # Read line by line and count pipe separators
    while IFS= read -r line; do
        if [ -z "$line" ]; then continue; fi
        
        # Count occurrences of the pipe character
        pipes=$(echo "$line" | tr -cd '|' | wc -c)
        
        # Schema [ID] | [Name] | [Grade] | [Length] | [Gear] | [Setter] | [Sector] | [Zone] requires exactly 7 pipes
        if [ "$pipes" -ne 7 ]; then
            echo "[FAIL] Schema violation in $file"
            echo "Line: $line"
            echo "Expected 7 separators, found $pipes."
            exit 1
        fi
    done < "$file"
    
    echo "[OK] Fixed-separator schema strictly validated for $file"
done
