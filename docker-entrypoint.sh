#!/usr/bin/env bash
set -euo pipefail

# Collect files from /app/videos into an array, shuffle them, and
# loop through them in random order calling process_file on each.

videos_dir="/app/videos"

if [[ ! -d "${videos_dir}" ]]; then
	echo "Directory ${videos_dir} does not exist; nothing to do." >&2
	exit 0
fi

declare -a files=()
# Gather regular files only (no directories), handling whitespace in names.
while IFS= read -r -d '' f; do
	files+=("$f")
done < <(find "${videos_dir}" -maxdepth 1 -type f -print0)

if [[ ${#files[@]} -eq 0 ]]; then
	echo "No files found in ${videos_dir}; nothing to do."
	exit 0
fi

# Shuffle files into a new array. Use printf + xargs -0 to safely handle
# filenames containing whitespace. shuf randomizes the order.
mapfile -t shuffled < <(printf '%s\0' "${files[@]}" | xargs -0 -n1 printf '%s\n' | shuf)

process_file() {
	local file="$1"
	# <-- Put your command(s) here. For example:
	# /usr/bin/vlc --intf dummy "$file"
	# or
	# ffmpeg -i "$file" ...
exec ffmpeg -i "$file" \
  -c:v h264_nvenc -b:v 128k  \
  -c:a aac -b:a 64k  \
  -f flv "rtmps://dc1-1.rtmp.t.me/s/3298881468:lEWeplhaNqgGWuf9CHxoFw"
#    -vf "scale=-2:720" \

	# Placeholder action (safe default). Replace this with the real command.
	echo "Processing: $file"
}

# Iterate in the shuffled order and process each file.
for f in "${shuffled[@]}"; do
	process_file "$f"
done

exit 0