# Contained VLC
This OBS Studio for Linux packaged as a docker container and designed to stream a set of video files
mounted at `/app/videos` to an rtmps server specified at the environment variable `SERVER` given the 
stream key as an environment variable `STREAM_KEY`.

OBS Studio is pre-configured to stream videos from the collection in a continuous and random order at 1280x720 (720p).

## How to run
```
$ docker run --rm -it \
  -v "/actual_video_directory:/app/videos" \
  -e STREAM_KEY='YOUR_STREAM_KEY_HERE' \
  -e SERVER='YOUR_RTMPS_SERVER_HERE' \
  --cpus="3" \         # Strongly suggested to 3 vCPUs
  --memory="2g" \      # limit to 2 GB RAM
  contained_vlc
```