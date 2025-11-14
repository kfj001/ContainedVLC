FROM debian:13.1-slim

# Install only the runtime packages required for headless OBS
RUN apt-get update && apt-get install --no-install-suggests -y ffmpeg  

# Copy the entrypoint that starts Xvfb and runs obs
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Make /app/videos a mount point so the host can mount a directory there at runtime
VOLUME ["/app/videos"]

WORKDIR /app

# Provide non-sensitive defaults for runtime discoverability; hosts can override
# these with `-e STREAMURL=... -e STREAM_KEY=...` when running the container.
# Do NOT embed real stream keys in the image.
ENV STREAMURL="rtmps://dc1-1.rtmp.t.me/s/"
ENV STREAM_KEY="<replace-me>"

# Run the streamer
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]