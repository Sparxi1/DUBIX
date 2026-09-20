# Printful + Syncee Integration for WooCommerce (sxm.at)

This folder contains a runbook and helper script for connecting
[Printful](https://www.printful.com/) and [Syncee](https://syncee.com/) to
the WooCommerce store running on the sxm.at server.

## Prerequisites

- WordPress + WooCommerce already installed and running on the server
- SSH access to the server
- [wp-cli](https://wp-cli.org/) installed on the server
- A Printful account (or ability to create one)
- A Syncee account (or ability to create one)
- WordPress admin login for sxm.at

## Steps

### 1. Install the plugins

SSH into the sxm.at server, go to the WordPress root directory, and run:

```bash
./scripts/setup-printful-syncee.sh
```

Or, if wp-cli needs an explicit path to the WordPress install:

```bash
./scripts/setup-printful-syncee.sh --path=/var/www/sxm.at/htdocs
```

This installs and activates:

- **Printful Integration for WooCommerce** — official Printful plugin for
  print-on-demand product sync and order fulfillment
- **Syncee** — dropshipping/product-sync plugin for importing supplier
  catalogs into WooCommerce

### 2. Connect Printful (manual, in WP Admin)

1. WP Admin → **Printful** → **Settings**
2. Click **Connect with Printful**, log in and authorize
3. Select which Printful store to link
4. **Printful → Products** → import the products to sell
5. Confirm shipping rates / regions match what sxm.at needs (Printful
   handles fulfillment and shipping cost calculation per product)

### 3. Connect Syncee (manual, in WP Admin)

1. WP Admin → **Syncee**
2. Log in / register and link the Syncee account to this WooCommerce store
3. Browse the marketplace or your existing supplier catalogs
4. Use Syncee's import tool to bring products into WooCommerce
   (supports scheduled auto-sync for stock/price updates)
5. Configure markup/pricing rules per supplier if needed

### 4. Verify

- **WooCommerce → Products**: confirm items from both Printful and Syncee
  appear correctly (images, variants, price)
- Place a test order and confirm:
  - Printful receives the order and starts fulfillment
  - Syncee-sourced orders route to the correct supplier per that supplier's
    fulfillment settings
- Check **WooCommerce → Settings → Shipping** to make sure shipping zones
  don't conflict between the store's existing settings and the imported
  products

## Notes / limitations

- API key entry and OAuth-style account linking for both Printful and
  Syncee cannot be scripted — both require an interactive login in their
  respective dashboards, so step 2 and 3 must be done manually in a
  browser by someone with admin access to sxm.at and to the Printful/Syncee
  accounts.
- If sxm.at uses a staging/production split, run this on staging first and
  verify before repeating on production.
