#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for required environment variables
if [ -z "$PROXY_HOST" ] || [ -z "$PROXY_PORT" ] || [ -z "$PROXY_TYPE" ]; then
  echo "Error: PROXY_HOST, PROXY_PORT, and PROXY_TYPE environment variables must be set." >&2
  exit 1
fi

# Validate PROXY_TYPE
if [ "$PROXY_TYPE" != "socks" ] && [ "$PROXY_TYPE" != "http" ]; then
    echo "Error: PROXY_TYPE must be either 'socks' or 'http'." >&2
    exit 1
fi

# Set default values for username/password if not provided
PROXY_USER="${PROXY_USER:-}"
PROXY_PASS="${PROXY_PASS:-}"

# Create the final sing-box config from the template
# Use sed to replace placeholders with actual values
# If username/password are provided, add auth fields to JSON
if [ -n "$PROXY_USER" ] && [ -n "$PROXY_PASS" ]; then
  AUTH_FIELDS=",\n      \"username\": \"$PROXY_USER\",\n      \"password\": \"$PROXY_PASS\""
else
  AUTH_FIELDS=""
fi

sed -e "s/__PROXY_TYPE__/$PROXY_TYPE/g" \
    -e "s/__PROXY_HOST__/$PROXY_HOST/g" \
    -e "s/__PROXY_PORT__/$PROXY_PORT/g" \
    -e "s|__AUTH_FIELDS__|$AUTH_FIELDS|g" \
    /gateway/sing-box.json > /gateway/config.json

# Start sing-box with the generated configuration
echo "Starting sing-box gateway..."
echo "Forwarding all traffic via $PROXY_TYPE proxy at $PROXY_HOST:$PROXY_PORT"
exec sing-box run -c /gateway/config.json
