#!/bin/bash

# Path to the proxies file that will be mounted from the host
PROXIES_FILE="/config/proxies.txt"

# Check if proxies.txt is mounted
if [ ! -f "$PROXIES_FILE" ]; then
    echo "Error: proxies.txt not found in /config/. Please mount it as a volume." >&2
    exit 1
fi

# Generate the 3proxy.cfg from the proxies
echo "Generating 3proxy configuration..."
python3 /gateway/generate_config.py

# Check if config generation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate 3proxy.cfg." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p /usr/local/3proxy/logs

echo "Configuration generated. Starting 3proxy..."

# Start 3proxy with the generated config (-n = no daemon)
exec /usr/local/3proxy/bin/3proxy /usr/local/3proxy/conf/3proxy.cfg -n

