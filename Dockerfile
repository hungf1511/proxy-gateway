# Use a specific, stable version of Alpine Linux
FROM alpine:3.16

# Define the sing-box version to use
ARG SING_BOX_VERSION=1.8.0
# Define the target architecture, allows for multi-arch builds (e.g., amd64, arm64)
ARG TARGETARCH=amd64

# Install dependencies, download and install sing-box
RUN apk update && \
    apk add --no-cache wget ca-certificates curl && \
    wget "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-${TARGETARCH}.tar.gz" -O /tmp/sing-box.tar.gz && \
    tar -xzf /tmp/sing-box.tar.gz -C /tmp && \
    mv "/tmp/sing-box-${SING_BOX_VERSION}-linux-${TARGETARCH}/sing-box" /usr/local/bin/ && \
    rm -rf /tmp/*

# Copy our custom gateway scripts and config template
COPY . /gateway/
WORKDIR /gateway

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/gateway/entrypoint.sh"]
