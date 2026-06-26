#!/usr/bin/env bash
# =============================================================================
# STEP 3 — Configure Nginx (run as root on the VPS)
# =============================================================================
set -euo pipefail

APP_DIR="/opt/uganda-diaspora"

echo "==> Installing Nginx site config..."
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
cp "$APP_DIR/deploy/nginx.conf" /etc/nginx/sites-available/uganda-diaspora
ln -sf /etc/nginx/sites-available/uganda-diaspora /etc/nginx/sites-enabled/uganda-diaspora

# Make sure Nginx main config includes sites-enabled
if ! grep -q "sites-enabled" /etc/nginx/nginx.conf; then
  echo "==> Patching /etc/nginx/nginx.conf to include sites-enabled..."
  # Insert include directive inside the http block before the closing brace
  sed -i '/^http {/a\    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
fi

echo "==> Testing Nginx config..."
nginx -t

echo "==> Reloading Nginx..."
systemctl reload nginx

echo ""
echo "============================================================"
echo "  Done! Your app should now be accessible at:"
echo "  http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_VPS_IP')"
echo ""
echo "  Admin dashboard : http://YOUR_VPS_IP/"
echo "  API             : http://YOUR_VPS_IP/api/healthz"
echo "  Data deletion   : http://YOUR_VPS_IP/data-deletion"
echo "============================================================"
