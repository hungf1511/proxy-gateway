# Use a specific, stable version of Alpine Linux to ensure a consistent build environment
FROM alpine:3.16

# Define the 3proxy version to use
ARG THREE_PROXY_VERSION=0.9.5

# In a single RUN command for atomicity and smaller layers:
# 1. Install build dependencies (build-base, wget) and runtime dependencies (python3, strace).
# 2. Download and compile 3proxy from the official source.
# 3. Move the compiled binary to a standard location.
# 4. Clean up the source code and build dependencies to keep the final image small.
RUN apk update && \
    apk add --no-cache --virtual .build-deps build-base wget && \
    apk add --no-cache python3 strace && \
    cd /tmp && \
    wget https://github.com/z3APA3A/3proxy/archive/refs/tags/${THREE_PROXY_VERSION}.tar.gz && \
    tar -xzf ${THREE_PROXY_VERSION}.tar.gz && \
    cd 3proxy-${THREE_PROXY_VERSION} && \
    make -f Makefile.Linux && \
    cp bin/3proxy /usr/local/bin/3proxy && \
    cd / && \
    rm -rf /tmp/* && \
    apk del .build-deps

# Copy our custom gateway scripts
COPY . /gateway/
WORKDIR /gateway

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/gateway/entrypoint.sh"]
