#!/usr/bin/env bash
# =============================================================================
# STEP 1 — Server setup (run as root on the VPS)
# Installs: Node.js 24, pnpm, PostgreSQL, Nginx, PM2
# =============================================================================
set -euo pipefail

echo "==> Updating system packages..."
pacman -Syu --noconfirm

echo "==> Installing core dependencies..."
pacman -S --noconfirm \
  nodejs npm \
  postgresql \
  nginx \
  git \
  base-devel

echo "==> Installing pnpm..."
npm install -g pnpm pm2

echo "==> Initialising PostgreSQL..."
# Initialise the data directory (Arch requires manual initdb)
if [ ! -f /var/lib/postgres/data/PG_VERSION ]; then
  su - postgres -c "initdb --locale=en_US.UTF-8 -D /var/lib/postgres/data"
fi

echo "==> Enabling and starting PostgreSQL..."
systemctl enable --now postgresql

echo "==> Creating database and user..."
DB_PASSWORD=$(openssl rand -base64 24)

su - postgres -c "psql -c \"CREATE USER diaspora WITH PASSWORD '${DB_PASSWORD}';\"" || true
su - postgres -c "psql -c \"CREATE DATABASE uganda_diaspora OWNER diaspora;\"" || true
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE uganda_diaspora TO diaspora;\"" || true

echo ""
echo "============================================================"
echo "  PostgreSQL credentials — SAVE THESE NOW"
echo "  DB User    : diaspora"
echo "  DB Password: ${DB_PASSWORD}"
echo "  DB Name    : uganda_diaspora"
echo "  DATABASE_URL=postgresql://diaspora:${DB_PASSWORD}@localhost:5432/uganda_diaspora"
echo "============================================================"
echo ""

echo "==> Enabling and starting Nginx..."
systemctl enable --now nginx

echo ""
echo "==> STEP 1 COMPLETE. Note the DATABASE_URL above, you will need it in Step 2."
