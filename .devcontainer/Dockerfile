# Note: You can use any Debian/Ubuntu based image you want. 
FROM mcr.microsoft.com/devcontainers/base:bullseye

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    apt-transport-https ca-certificates git curl gnupg lsb-release

RUN mkdir -p /etc/apt/keyrings
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update
RUN apt-get install azure-cli
# Download, extract, and install azcopy v10
RUN curl -L -o /tmp/azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux 
RUN tar -xzf /tmp/azcopy.tar.gz -C /tmp && \
    mv /tmp/azcopy_linux_amd64_*/azcopy /usr/bin/ && \
    chmod +x /usr/bin/azcopy && \
    rm -rf /tmp/azcopy.tar.gz /tmp/azcopy_linux_amd64_*/