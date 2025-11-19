#!/bin/bash
set -euo pipefail

PROXIES_FILE="/config/proxies.txt"
CONF_FILE="/usr/local/3proxy/conf/3proxy.cfg"

if [ ! -s "$PROXIES_FILE" ]; then
    echo "Error: $PROXIES_FILE is missing or empty." >&2
    exit 1
fi

echo "Generating 3proxy configuration..."
python3 /gateway/generate_config.py

if [ ! -s "$CONF_FILE" ]; then
    echo "Error: Failed to generate $CONF_FILE" >&2
    exit 1
fi

echo "Starting 3proxy..."
exec /usr/local/3proxy/bin/3proxy "$CONF_FILE"
