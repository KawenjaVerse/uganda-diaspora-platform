#!/usr/bin/env bash
# =============================================================================
# STEP 2 — Clone, build, and start the app (run as root or your deploy user)
# Run AFTER step 1. Edit the variables below before running.
# =============================================================================
set -euo pipefail

# ── EDIT THESE ────────────────────────────────────────────────────────────────
DATABASE_URL="postgresql://diaspora:YOUR_PASSWORD@localhost:5432/uganda_diaspora"
SESSION_SECRET=$(openssl rand -base64 48)  # auto-generated — save this value
APP_DIR="/opt/uganda-diaspora"
# ─────────────────────────────────────────────────────────────────────────────

echo "==> Cloning / updating repository..."
if [ -d "$APP_DIR/.git" ]; then
  cd "$APP_DIR" && git pull
else
  git clone https://github.com/KawenjaVerse/uganda-diaspora-platform.git "$APP_DIR"
  cd "$APP_DIR"
fi

echo "==> Installing dependencies..."
pnpm install --frozen-lockfile

echo "==> Building shared libraries..."
pnpm run typecheck:libs

echo "==> Building API server..."
cd "$APP_DIR/artifacts/api-server"
pnpm run build

echo "==> Building admin dashboard..."
cd "$APP_DIR/artifacts/admin-dashboard"
PORT=3000 BASE_PATH=/ NODE_ENV=production pnpm run build

echo "==> Writing .env file..."
cat > "$APP_DIR/.env" <<EOF
DATABASE_URL=${DATABASE_URL}
SESSION_SECRET=${SESSION_SECRET}
NODE_ENV=production
PORT=8080
EOF
chmod 600 "$APP_DIR/.env"

echo "==> Running database migrations..."
cd "$APP_DIR"
DATABASE_URL="${DATABASE_URL}" pnpm --filter @workspace/db run push-force

echo "==> Starting services with PM2..."
pm2 delete uganda-api 2>/dev/null || true
pm2 start "$APP_DIR/artifacts/api-server/dist/index.mjs" \
  --name uganda-api \
  --env production \
  --node-args="--enable-source-maps" \
  -- 
pm2 env uganda-api 2>/dev/null || true

# Pass env vars to PM2
pm2 delete uganda-api 2>/dev/null || true
DATABASE_URL="${DATABASE_URL}" SESSION_SECRET="${SESSION_SECRET}" NODE_ENV=production PORT=8080 \
  pm2 start "$APP_DIR/artifacts/api-server/dist/index.mjs" \
    --name uganda-api \
    --node-args="--enable-source-maps"

pm2 save
pm2 startup systemd -u root --hp /root | tail -1 | bash || true

echo ""
echo "============================================================"
echo "  SESSION_SECRET (save this): ${SESSION_SECRET}"
echo "  API running on port 8080"
echo "  Dashboard built to: $APP_DIR/artifacts/admin-dashboard/dist/public"
echo "============================================================"
echo ""
echo "==> STEP 2 COMPLETE. Now run step 3 to configure Nginx."
