#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

VERBOSE=0
TEMPLATE=0
FEED=0

while getopts "vht:o:" OPT; do
	case "$OPT" in
		v) VERBOSE=1;;
		t) TEMPLATE=$OPTARG;;
		o) FEED=$OPTARG;;
		h) 	echo 'Usage:'
			echo '	generate-feed.sh [-v] [-h] [-t <template>] -o <output> <file | directory> <file | directory>...'
			exit 0
			;;
	esac
done

shift $(( OPTIND-1 ))

if [ -d $FEED ]; then
	echo "$0"\: "$FEED": Is a directory
	exit 1
fi

# Clear output file if it existed beforehand
> $FEED

# Add template to output if there is any. Error out on invalid template
if [ -f $TEMPLATE ]; then
	cat $TEMPLATE >> $FEED
else
	echo "$0"\: "$TEMPLATE": Is not a file
	exit 1
fi

for FILE in $(find $@ -maxdepth 1 -type f -name "*.html" -exec realpath {} \;); do
	TITLE=$(xmllint --html --xpath '//title/text()' "$FILE")
	DATE=$(xmllint --html --xpath '//*[@class="date"]/text()' "$FILE")
	LINK='https://ramirobasile.github.io/'$(realpath --relative-to=. "$FILE")
	CONTENT=$(xmllint --html --xpath 'html/body' "$FILE")
	
	ENTRY='
	<entry>
		<title>'$TITLE'</title>
		<link href="'$LINK'" />
		<updated>'$DATE'</updated>
		<content type="html">'$CONTENT'</content>
	</entry>'

	echo "$ENTRY" >> $FEED
	
	if [ $VERBOSE -eq 1 ]; then
		echo Title: "$TITLE"
		echo Date: "$DATE"
		echo Link: "$LINK"
		echo Content: "${FILE%.*}".html
		echo
	fi
	
	echo Added $(basename "$FILE") to $(basename "$FEED")
done

echo '</feed>' >> $FEED
	
exit 0

