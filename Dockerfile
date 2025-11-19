# Stage 1: Get the stable, pre-compiled 3proxy binary from the official image
FROM 3proxy/3proxy:latest as builder

# Stage 2: Create our final, lightweight image with Python
FROM alpine:3.16

# Install runtime dependencies
RUN apk update && apk add --no-cache python3 strace

# Copy the 3proxy binary from the builder stage into our final image
# The correct path in the official image is /usr/local/bin/3proxy
COPY --from=builder /usr/local/bin/3proxy /usr/local/bin/3proxy

# Copy our custom gateway scripts
COPY . /gateway/
WORKDIR /gateway

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/gateway/entrypoint.sh"]
