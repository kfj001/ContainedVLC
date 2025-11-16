# Contained VLC

A lightweight Docker container that continuously streams video files using FFmpeg. Videos mounted at `/app/videos` are played in random order and streamed to an RTMPS server.

## Overview

This container uses FFmpeg to stream video files in a continuous loop. Videos are shuffled and played in random order, with the playlist regenerating each cycle to pick up any new files added to the mounted directory.

## Features

- Streams videos using FFmpeg with real-time playback (`-re`)
- Randomizes playback order each cycle
- Automatically detects and streams new files added to the video directory
- Lightweight: based on `debian:13.1-slim` with only FFmpeg installed
- Graceful error handling with automatic retry on stream failure

## Environment Variables

- `STREAMURL` - Base RTMPS server URL (default: `rtmps://dc1-1.rtmp.t.me/s/`)
- `STREAM_KEY` - Your stream key (default: `<replace-me>`)

## How to Build

```sh
docker build -t contained_vlc '.'
```

## How to Run

```sh
docker run --rm -it \
  -v "/path/to/your/videos:/app/videos" \
  -e STREAMURL='rtmps://your-server-url/' \
  -e STREAM_KEY='YOUR_STREAM_KEY_HERE'
```

### Example with Default Telegram RTMPS Server

```sh
docker run --rm -it \
  -v "/path/to/your/videos:/app/videos" \
  -e STREAM_KEY='YOUR_STREAM_KEY_HERE' \
  contained_vlc
```

## Notes

- Videos are copied with `-c copy` (no re-encoding) for efficiency
- The container will continue running even if no videos are present, checking periodically for new files
- Stream failures trigger a 5-second backoff before retry
- The playlist is regenerated at `/tmp/playlist.txt` each cycle