#!/usr/bin/env bash
set -uo pipefail

# Collect files from /app/videos into an array, shuffle them, and
# loop through them in random order calling process_file on each.

videos_dir="/app/videos"

if [[ ! -d "${videos_dir}" ]]; then
	echo "Directory ${videos_dir} does not exist; nothing to do." >&2
	exit 0
fi

# Build the stream target from two environment variables so the host can
# supply the base URL and the stream key separately.
STREAMURL="${STREAMURL:-}"
STREAM_KEY="${STREAM_KEY:-}"
STREAM_TARGET="${STREAMURL}${STREAM_KEY}"
echo "Using streaming target: ${STREAM_TARGET}"

# Loop forever: re-gather files each pass, reshuffle, and process them in
# randomized order. If no files are present, sleep briefly and retry so the
# container can pick up files added later.
while true; do
	declare -a files=()
	# Gather regular files only (no directories), handling whitespace in names.
	while IFS= read -r -d '' f; do
		files+=("$f")
	done < <(find "${videos_dir}" -maxdepth 1 -type f -print0)

	if [[ ${#files[@]} -eq 0 ]]; then
		echo "No files found in ${videos_dir}; retrying..."
		continue
	fi

	# Shuffle files into a new array. Use printf + xargs -0 to safely handle
	# filenames containing whitespace. shuf randomizes the order.
	mapfile -t shuffled < <(printf '%s\0' "${files[@]}" | xargs -0 -n1 printf '%s\n' | shuf)

# Serialize the shuffled list to a playlist file that ffmpeg's concat demuxer
# can read. The file is overwritten each cycle at /tmp/playlist.txt as requested.
playlist="/tmp/playlist.txt"
: > "$playlist"

# Escape single-quotes in filenames for the concat file's single-quoted entries.
for f in "${shuffled[@]}"; do
	esc=${f//\'/\'\\\'\'}
	printf "file '%s'\n" "$esc" >> "$playlist"
done

echo "Starting ffmpeg with playlist ${playlist} -> ${STREAM_TARGET}"
# Use -re so ffmpeg plays back in real time; -safe 0 allows arbitrary paths.
if ! ffmpeg -re -f concat -safe 0 -i "$playlist" -c copy -f flv "${STREAM_TARGET}"; then
	echo "ffmpeg failed with exit code $?" >&2
fi
done
echo "This shouldn't ever happen"
exit 0
