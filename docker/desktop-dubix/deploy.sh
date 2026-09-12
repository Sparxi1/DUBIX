#!/bin/bash
# Deploys the desktop.dubix.at Webtop (KDE Plasma) container.
# Run this script ON THE CONTABO VPS, from this directory.
set -euo pipefail

cd "$(dirname "$0")"

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Generating a strong random password for the desktop login..."
    PASSWORD="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 24)"
    echo "DESKTOP_DUBIX_PASSWORD=${PASSWORD}" > "$ENV_FILE"
    chmod 600 "$ENV_FILE"
else
    echo "Reusing existing password from $ENV_FILE"
    PASSWORD="$(grep DESKTOP_DUBIX_PASSWORD "$ENV_FILE" | cut -d= -f2)"
fi

echo "Building and starting the container..."
docker compose up -d --build

echo
echo "=================================================="
echo " Deployment complete."
echo " Login user:     dubix"
echo " Login password: ${PASSWORD}"
echo " (also saved in $(pwd)/.env)"
echo "=================================================="
echo
echo "Next step: run ./patch-cloudflare-tunnel.sh to expose it as desktop.dubix.at"
