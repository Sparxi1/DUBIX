#!/usr/bin/env bash
set -uo pipefail
cd /opt/dubix/staging/sxm-woocommerce

echo "=== Syncee plugin hostnames ==="
docker compose exec -T --user 33:33 wp bash -c \
  "grep -rEho 'https?://[a-zA-Z0-9._-]*syncee[a-zA-Z0-9._-]*' /var/www/html/wp-content/plugins/syncee-global-dropshipping/ 2>/dev/null | sed -E 's#https?://##' | sort -u"

echo
echo "=== apache-alias.conf ==="
cat config/apache-alias.conf

echo
echo "=== Caddyfile (sxm/staging related) ==="
docker exec caddy cat /etc/caddy/Caddyfile 2>/dev/null | grep -B2 -A5 -i "sxm\|18443\|staging"
