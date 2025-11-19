FROM ubuntu:22.04

# Install 3proxy and Python
RUN apt-get update && \
    apt-get install -y wget build-essential python3 && \
    rm -rf /var/lib/apt/lists/*

# Download and install 3proxy
ARG THREE_PROXY_VERSION=0.9.5

RUN cd /tmp && \
    wget https://github.com/z3APA3A/3proxy/archive/refs/tags/${THREE_PROXY_VERSION}.tar.gz && \
    tar -xzf ${THREE_PROXY_VERSION}.tar.gz && \
    cd 3proxy-${THREE_PROXY_VERSION} && \
    make -f Makefile.Linux && \
    mkdir -p /usr/local/3proxy/bin /usr/local/3proxy/conf /usr/local/3proxy/logs && \
    cp bin/3proxy /usr/local/3proxy/bin/ && \
    chmod +x /usr/local/3proxy/bin/3proxy && \
    cd / && \
    rm -rf /tmp/3proxy-${THREE_PROXY_VERSION} /tmp/${THREE_PROXY_VERSION}.tar.gz

# Add 3proxy to PATH
ENV PATH="/usr/local/3proxy/bin:${PATH}"

# Copy the gateway scripts
COPY . /gateway/
WORKDIR /gateway

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/gateway/entrypoint.sh"]

