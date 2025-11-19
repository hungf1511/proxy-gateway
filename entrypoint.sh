#!/bin/bash
set -euo pipefail

PROXIES_FILE="/config/proxies.txt"
CONF_FILE="/usr/local/3proxy/conf/3proxy.cfg"

if [ ! -s "$PROXIES_FILE" ]; then
  echo "Error: $PROXIES_FILE is missing hoặc rỗng" >&2
  exit 1
fi

echo "Generating 3proxy configuration..."
python3 /gateway/generate_config.py

echo "Configuration generated → Starting 3proxy"
exec /usr/local/3proxy/bin/3proxy "$CONF_FILE"
