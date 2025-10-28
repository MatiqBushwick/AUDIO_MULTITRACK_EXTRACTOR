#!/bin/bash

clear
echo 'Script is designed to EASILY EXTRACT and CONCATENATE (JOIN)'
echo 'separate AUDIO WAV channels from MULTITRACK CONTAINER(s32)'
echo ''
echo 'by MatiqBushwick'
echo ''
echo 'Press ENTER to proceed...'
read

cd "$(dirname "$0")"
echo '' > log.txt
clear

# Ask for folder
echo ''
echo "DRAG & DROP audio chunks containing folder:"
echo ''
echo "OR"
echo ''
echo "PRESS ENTER to use THIS FOLDER"

read folder_path
if [ ! -n "$folder_path" ]; then
    folder_path=.
fi

# Check if folder exists
if [ ! -d "$folder_path" ]; then
    echo "Error: Folder '$folder_path' does not exist!"
    exit 1
fi

# Change to the target directory
cd "$folder_path" || exit 1

clear

echo "Current directory: $(pwd)"
echo "Looking for audio files..."
echo ''

# Configuration - you can modify these
CHUNK_PATTERN="*.WAV"  # Adjust pattern to match your files
CHANNEL_COUNT=32
OUTPUT_PREFIX="CH"

# Get all chunk files and sort them
chunks=($(ls $CHUNK_PATTERN 2>/dev/null | sort -V))
num_chunks=${#chunks[@]}

if [ $num_chunks -eq 0 ]; then
    echo "No audio files found matching pattern: $CHUNK_PATTERN"
    #echo "Available files in directory:"
    #ls -la
    exit 1
fi

echo "Found $num_chunks audio chunks:"
echo ''
for chunk in "${chunks[@]}"; do
    echo "  - $chunk"
done

# Ask for channel count
echo ''
echo "Enter number of channels (default: $CHANNEL_COUNT):"
read user_channel_count
if [ -n "$user_channel_count" ] && [[ $user_channel_count =~ ^[0-9]+$ ]]; then
    CHANNEL_COUNT=$user_channel_count
fi
echo ''
echo "Using $CHANNEL_COUNT channels"

# Ask for output prefix
echo "Enter output file prefix (default: '$OUTPUT_PREFIX'):"
read user_prefix
if [ -n "$user_prefix" ]; then
    OUTPUT_PREFIX="$user_prefix"
fi

# Build input arguments dynamically
input_args=()
for chunk in "${chunks[@]}"; do
    input_args+=(-i "$chunk")
done

# Show processing summary
echo ""
echo "=== PROCESSING SUMMARY ==="
echo "Input folder: $folder_path"
echo "Files to process: $num_chunks"
echo "Channels per file: $CHANNEL_COUNT"
echo "Output files: ${OUTPUT_PREFIX}1.wav through ${OUTPUT_PREFIX}${CHANNEL_COUNT}.wav"
echo "Starting processing..."
echo ""

echo "Building filter graph for $num_chunks files with $CHANNEL_COUNT channels each..."

for ((ch=0; ch<CHANNEL_COUNT; ch++)); do

    # Build filter complex dynamically
    filter_complex=""
    concat_filters=""

    # Map each input into channels
    for ((i=0; i<num_chunks; i++)); do
        filter_complex+="[$i]channelmap=${ch}-0:mono[${ch}_${i}];"
    done


    # Build concatenation filters for each channel
    concat_inputs=""
    for ((i=0; i<num_chunks; i++)); do
        concat_inputs+="[${ch}_${i}]"
    done
    concat_filters+="${concat_inputs}concat=n=${num_chunks}:v=0:a=1[out${ch}];"

    # Combine all filters
    full_filter="${filter_complex}${concat_filters}"

    # Build output mapping
    map_args=()
    map_args+=(-map "[out${ch}]")

    #DEBUG
    echo "ffmpeg '${input_args[@]}' -filter_complex '$full_filter' '${map_args[@]}' \
        -c:a pcm_s16le " >> log.txt
    echo '' >> log.txt

    # Run FFmpeg
    ffmpeg "${input_args[@]}" -filter_complex "$full_filter" "${map_args[@]}" \
        -c:a pcm_s16le "${OUTPUT_PREFIX}${ch+1}.wav"

done

# Check if successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully processed all channels!"
    echo "Output files created in: $folder_path"
else
    echo ""
    echo "❌ Processing failed!"
    exit 1
fi
