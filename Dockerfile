# Use a lightweight and stable base image
FROM alpine:latest

# Enable the 'community' repository where the 3proxy package is located
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories

# Update package list again to include the community repository
RUN apk update

# Install 3proxy, python3, and strace
RUN apk add --no-cache 3proxy python3 strace

# Copy the gateway scripts
COPY . /gateway/
WORKDIR /gateway

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/gateway/entrypoint.sh"]
