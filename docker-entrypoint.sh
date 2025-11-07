#!/bin/bash
set -e

# Minimal entrypoint: start Xvfb (assume not running) then run OBS.
# Improves reliability by using -ac and waiting for the X socket to appear.
export DISPLAY=${DISPLAY:-:99}
export LANG=${LANG:-C.UTF-8}

# compute display number (e.g. :99 -> 99)
disp_num="${DISPLAY#*:}"

# Start Xvfb in background with -ac (disable access control) and no TCP
Xvfb "$DISPLAY" -screen 0 1280x720x24 -ac -nolisten tcp >/dev/null 2>&1 &

# Wait up to 10s for the X socket to appear
timeout=10
while [ $timeout -gt 0 ]; do
	if [ -e "/tmp/.X11-unix/X${disp_num}" ]; then
		break
	fi
	sleep 0.5
	timeout=$((timeout - 1))
done

if [ $timeout -le 0 ]; then
	echo "Warning: X socket /tmp/.X11-unix/X${disp_num} did not appear; obs may fail to connect to display" >&2
fi

# Render service.json from template if present
TEMPLATE="/root/.config/obs-studio/basic/profiles/only/service.json.template"
TARGET="/root/.config/obs-studio/basic/profiles/only/service.json"
if [ -f "$TEMPLATE" ]; then
  # export default env var names you expect, e.g. STREAM_KEY, SERVER
  : "${STREAM_KEY:=}"
  : "${SERVER:=}"
  envsubst < "$TEMPLATE" > "$TARGET"
  chmod 600 "$TARGET"
fi

# Exec OBS with the requested fixed args
exec obs --startstreaming