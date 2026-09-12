#!/bin/bash
# Adds an ingress rule for desktop.dubix.at to the existing cloudflared
# tunnel config, routes the DNS record to that tunnel, and reloads cloudflared.
# Run this ON THE CONTABO VPS, as a user who can read/write the cloudflared
# config and control the cloudflared service (root or sudo).
set -euo pipefail

HOSTNAME="desktop.dubix.at"
LOCAL_SERVICE="http://localhost:3010"

CANDIDATES=(
    "/etc/cloudflared/config.yml"
    "/etc/cloudflared/config.yaml"
    "$HOME/.cloudflared/config.yml"
    "$HOME/.cloudflared/config.yaml"
)

CONFIG=""
for c in "${CANDIDATES[@]}"; do
    if [ -f "$c" ]; then
        CONFIG="$c"
        break
    fi
done

if [ -z "$CONFIG" ]; then
    echo "ERROR: Could not find an existing cloudflared config.yml automatically."
    echo "Please add this ingress rule manually, above the final 'service: http_status:404' line:"
    echo
    echo "  - hostname: ${HOSTNAME}"
    echo "    service: ${LOCAL_SERVICE}"
    echo
    exit 1
fi

echo "Found cloudflared config at: $CONFIG"

if grep -q "$HOSTNAME" "$CONFIG"; then
    echo "Hostname $HOSTNAME already present in $CONFIG - skipping ingress edit."
else
    cp "$CONFIG" "${CONFIG}.bak.$(date +%s)"
    echo "Backed up existing config."

    python3 - "$CONFIG" "$HOSTNAME" "$LOCAL_SERVICE" <<'PYEOF'
import sys, yaml

path, hostname, service = sys.argv[1:4]
with open(path) as f:
    data = yaml.safe_load(f) or {}

ingress = data.get("ingress", [])
new_rule = {"hostname": hostname, "service": service}

# Insert before the first catch-all rule (a rule with no 'hostname' key),
# otherwise just append.
insert_at = len(ingress)
for i, rule in enumerate(ingress):
    if "hostname" not in rule:
        insert_at = i
        break

ingress.insert(insert_at, new_rule)
data["ingress"] = ingress

with open(path, "w") as f:
    yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False)

print(f"Inserted ingress rule for {hostname} -> {service}")
PYEOF

fi

# Extract tunnel name/ID from the config to route DNS.
TUNNEL_ID="$(python3 - "$CONFIG" <<'PYEOF'
import sys, yaml
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f) or {}
print(data.get("tunnel", ""))
PYEOF
)"

if [ -n "$TUNNEL_ID" ]; then
    echo "Routing DNS: $HOSTNAME -> tunnel $TUNNEL_ID"
    cloudflared tunnel route dns "$TUNNEL_ID" "$HOSTNAME" || \
        echo "WARNING: 'cloudflared tunnel route dns' failed - the CNAME may already exist or need manual creation in the Cloudflare dashboard."
else
    echo "WARNING: Could not determine tunnel ID from config; add the DNS CNAME for $HOSTNAME manually in the Cloudflare dashboard."
fi

echo "Reloading cloudflared..."
if systemctl is-active --quiet cloudflared 2>/dev/null; then
    systemctl restart cloudflared
    echo "cloudflared service restarted."
else
    echo "cloudflared is not a systemd service on this host - restart it manually (e.g. the container/process running it)."
fi

echo "Done. $HOSTNAME should now route to $LOCAL_SERVICE"
