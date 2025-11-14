FROM debian:12.9-slim

# Install only the runtime packages required for headless OBS
RUN apt-get update 
RUN apt-get install -y xvfb
RUN apt-get install -y obs-studio
RUN apt-get install -y gettext-base

# Ensure the default user's config directory exists and bundle the repo's
# obs-studio configuration into the image at ~/.config/obs-studio
RUN mkdir -p /root/.config
COPY obs-studio /root/.config/obs-studio

# Copy repository root into image so the container contains the whole project
COPY . /app

# Copy the entrypoint that starts Xvfb and runs obs
COPY docker-entrypoint.sh /usr/local/bin/obs-entrypoint.sh
RUN chmod +x /usr/local/bin/obs-entrypoint.sh

# Make /app/videos a mount point so the host can mount a directory there at runtime
VOLUME ["/app/videos"]

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/obs-entrypoint.sh"]
