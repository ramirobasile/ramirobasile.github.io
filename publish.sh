#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

VERBOSE=0

while getopts "hv" OPT; do
	case "$OPT" in
		v) VERBOSE=1;;
		h) 	echo 'Usage:'
			echo '	publish.sh [-h] [-v] <file | directory> <file | directory>...'
			exit 0
			;;
	esac
done

shift $(( OPTIND-1 ))

# TODO arreglar for
# TODO comentarios
for FILE in $(find $@ -maxdepth 1 -type f -name "*.md" -exec realpath {} \;); do
	ROOT=$(realpath --relative-to=$(dirname "$FILE") .)
	OUT=$(dirname "$FILE")/$(basename "$FILE" '.md').html
	
	cd $(dirname "$FILE")
	
	ARGS=()
	if [ -f "./resources/head.html" ]; then
		ARGS+=( "-H" "./resources/head.html" )
	elif [ -f "$ROOT/resources/head.html" ]; then
		ARGS+=( "-H" "$ROOT/resources/head.html" )
	fi
	if [ -f "./resources/header.html" ]; then
		ARGS+=( "--include-before-body" "./resources/header.html" )
	elif [ -f "$ROOT/resources/header.html" ]; then
		ARGS+=( "--include-before-body" "$ROOT/resources/header.html" )
	fi
	if [ -f "./resources/footer.html" ]; then
		ARGS+=( "--include-after-body" "./resources/footer.html" )
	elif [ -f "$ROOT/resources/footer.html" ]; then
		ARGS+=( "--include-after-body" "$ROOT/resources/footer.html" )
	fi
	
	pandoc $FILE \
		--to html4 \
		--email-obfuscation=references \
		"${ARGS[@]}" \
		-o $OUT
	if [ $VERBOSE == 1 ]; then
		echo Published $(basename "$FILE") to $(basename "$OUT")
	fi
done

exit 0
