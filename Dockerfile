# Use a lightweight and stable base image
FROM alpine:latest

# Install 3proxy from Alpine's official repository, along with python3 and strace
# This ensures we have a stable, pre-compiled binary.
RUN apk update && \
    apk add --no-cache 3proxy python3 py3-pip strace

# Copy the gateway scripts
COPY . /gateway/
WORKDIR /gateway

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/gateway/entrypoint.sh"]
