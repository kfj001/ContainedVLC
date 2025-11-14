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

process_file() {
    local file="$1"
    echo "Processing: $file"

    # Read input in real-time (-re) so ffmpeg streams at native (1x) speed
    # and do not use `exec` so the script keeps running through the loop.
    if ! ffmpeg -re -i "$file" -c copy \
      -f flv "${STREAM_TARGET}"; then
		echo "ffmpeg failed for $file with exit code $?" >&2
    fi
}

	# Iterate in the shuffled order and process each file.
	for f in "${shuffled[@]}"; do
		process_file "$f"
	done
done
echo "This shouldn't ever happen"
exit 0
