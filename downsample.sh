#!/bin/bash

cleanup()
# example cleanup function
{
	echo ""
}

control_c()
# run if user hits control-c
{
	echo "** ABORTING **"
	cleanup
	exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT

# Setup our variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FILES=`find "$DIR" -maxdepth 1 -type f -name "*.wav" -exec echo {} \;`
OUTPUT_DIR="downsampled"
OUTPUT_BITDEPTH=8
OUTPUT_KHZ="8k"
FILE_COUNT=`echo "$FILES" | wc -l | tr -d ' '`

OUTPUT_DIR="$DIR/$OUTPUT_DIR"

# Check if output dir exists, if not create it
if [[ ! -e "$OUTPUT_DIR" ]]; then
    echo "Output dir downsample didn't exist"
    mkdir "$OUTPUT_DIR"
fi

# Count total length of files
FILES_DURATION=`sox --i -D "$OUTPUT_DIR"/*.wav`
TOTAL_DURATION=0
for duration in $FILES_DURATION
do
	TOTAL_DURATION=$(echo $TOTAL_DURATION + $duration | bc)
done
TOTAL_DURATION=`printf "%.1f" "$TOTAL_DURATION"`

# Start downsampling
echo "Downsampling $FILE_COUNT wav files of $TOTAL_DURATION seconds in current directory"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for f in $FILES
do
	filename=$(basename "$f")
	extension="${filename##*.}"
	filename="${filename%.*}"

	echo " -> Downsampling $filename.$extension ..."
	sox "$f" -b $OUTPUT_BITDEPTH -r "$OUTPUT_BITDEPTH" "$OUTPUT_DIR/$filename.$extension"
done
IFS=$SAVEIFS

echo "All files downsampled with total length $TOTAL_DURATION seconds"
open "$OUTPUT_DIR"
