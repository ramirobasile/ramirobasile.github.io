#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

VERBOSE=0

while getopts "vrh" OPT; do
	case "$OPT" in
		v) VERBOSE=1;;
		#r) DOCS=$(find -type f -name "*.md");;
		h) 	echo 'Usage:'
			echo '	publish.sh [-v] [-h] [-r] <file | directory> <file | directory>...'
			exit 0
			;;
	esac
done

shift $(( OPTIND - 1 ))

for FILE in $(find $@ -maxdepth 1 -type f -name "*.md" -exec realpath {} \;); do
	OUT=$(dirname "$FILE")/$(basename "$FILE" '.md').html
	RESOURCES=$(dirname "$FILE")/
	CSS=./resources/style.css
	HEAD=./resources/head.html
	HEADER=./resources/header.html
	FOOTER=./resources/footer.html
	
	if [ $VERBOSE == 1 ]; then
		echo FILE: "$FILE" 
		echo OUT: "$OUT"
		echo CSS: "$CSS"
		echo Resources folder: "$RESOURCES"
		echo Head: "$HEAD"
		echo Header: "$HEADER"
		echo Footer: "$FOOTER"
		echo
	fi
	
	pandoc $FILE \
		--to html4 \
		--email-obfuscation=references \
		--css $CSS \
		--resource-path $RESOURCES \
		-H $HEAD \
		--include-before-body $HEADER \
		--include-after-body $FOOTER \
		-o $OUT
	
	echo Published $(basename "$FILE") to $(basename "$OUT")
done

exit 0
