#!/usr/bin/env bash
#
# Setup script: Install and configure Printful + Syncee for WooCommerce on sxm.at
#
# Requirements:
#   - wp-cli installed on the server (https://wp-cli.org/)
#   - Run as the user that owns the WordPress installation (usually www-data or similar)
#   - WooCommerce already installed and activated
#   - Run from the WordPress root directory, or pass --path=/path/to/wordpress
#
# Usage:
#   ./setup-printful-syncee.sh [--path=/var/www/sxm.at/htdocs]
#
# This script only installs and activates the plugins. API keys and store
# connections (Printful <-> WooCommerce, Syncee <-> WooCommerce) must be
# entered manually in the WordPress admin, because both services use an
# OAuth/API-key flow that requires logging into the respective dashboards.

set -euo pipefail

WP_PATH_ARG="${1:-}"

if ! command -v wp >/dev/null 2>&1; then
  echo "ERROR: wp-cli is not installed or not in PATH. See https://wp-cli.org/" >&2
  exit 1
fi

WP="wp"
if [[ -n "$WP_PATH_ARG" ]]; then
  WP="wp $WP_PATH_ARG"
fi

echo "==> Verifying WordPress installation"
$WP core is-installed

echo "==> Verifying WooCommerce is active"
if ! $WP plugin is-active woocommerce; then
  echo "ERROR: WooCommerce is not active. Install/activate it before continuing." >&2
  exit 1
fi

echo "==> Installing Printful plugin (printful-integration)"
$WP plugin install printful-integration --activate

echo "==> Installing Syncee plugin (syncee-marketplace)"
$WP plugin install syncee-marketplace --activate

echo "==> Flushing rewrite rules"
$WP rewrite flush

cat <<'EOF'

==> Plugins installed and activated.

Manual steps required (cannot be automated via wp-cli):

1. Printful:
   - Go to WP Admin -> Printful -> Settings
   - Click "Connect with Printful" and log in / authorize with the Printful account
   - Select the Printful store to link to this WooCommerce store
   - Under Printful -> Products, import the products you want to sell

2. Syncee:
   - Go to WP Admin -> Syncee
   - Log in / create a Syncee account and connect it to this WooCommerce store
   - Browse the Syncee marketplace / your supplier catalogs and import the
     products you want to sell via Syncee's product import tool

3. Verify:
   - Check WooCommerce -> Products for imported items from both sources
   - Place a test order to confirm order sync to Printful (Syncee dropshipping
     order routing depends on the supplier's fulfillment settings)

EOF
