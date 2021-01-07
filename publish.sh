#!/bin/bash
# Usage: sh publish.sh <file | directory> <file | directory>...

set -euo pipefail
IFS=$'\n\t'

for FILE in $(find $@ -maxdepth 1 -type f -name "*.md" -exec realpath {} \;); do
	DIR=$(dirname "$FILE")
	OUT=$(dirname "$FILE")/$(basename "$FILE" '.md').html
	
	pandoc $FILE \
		--to html4 \
		--email-obfuscation=references \
		-H resources/head.html \
		--include-before-body "$DIR"/resources/header.html \
		--include-after-body resources/footer.html \
		-o $OUT
		
	echo Published $(basename "$FILE") to $(basename "$OUT")
done

exit 0
