# VPS Deployment Guide — Uganda Diaspora Platform

**Server:** Arch Linux VPS (Hostinger)  
**Stack:** Node.js 24 · PostgreSQL · Nginx · PM2

---

## Overview

```
Internet → Nginx :80
                 ├── /       → static files (admin dashboard)
                 └── /api/*  → Node.js API on :8080 (via reverse proxy)
```

---

## Step-by-step

### 1. SSH into your VPS

```bash
ssh root@YOUR_VPS_IP
```

### 2. Upload the repo to the VPS

**Option A — Git (recommended)**  
Push this project to GitHub/GitLab first, then edit the `git clone` URL in `deploy/2-deploy.sh`.

**Option B — Direct copy with rsync (no Git needed)**
```bash
# Run this on YOUR LOCAL machine (not the VPS):
rsync -avz --exclude node_modules --exclude .git --exclude dist \
  /path/to/this/project/ root@YOUR_VPS_IP:/opt/uganda-diaspora/
```

### 3. Run Step 1 — Install server software

```bash
# On the VPS:
bash /opt/uganda-diaspora/deploy/1-server-setup.sh
```

⚠️ **Save the DATABASE_URL that is printed at the end.**

### 4. Run Step 2 — Build and start the app

Edit the `DATABASE_URL` variable at the top of `deploy/2-deploy.sh` first:

```bash
nano /opt/uganda-diaspora/deploy/2-deploy.sh
# Replace YOUR_PASSWORD with the password from step 1
```

Then run it:

```bash
bash /opt/uganda-diaspora/deploy/2-deploy.sh
```

⚠️ **Save the SESSION_SECRET that is printed at the end.**

### 5. Run Step 3 — Configure Nginx

```bash
bash /opt/uganda-diaspora/deploy/3-nginx-setup.sh
```

### 6. Verify it's working

```bash
# Check API health:
curl http://localhost/api/healthz

# Check PM2 process:
pm2 status

# Check Nginx:
systemctl status nginx

# View API logs:
pm2 logs uganda-api
```

---

## Restoring the database (news data)

To copy the existing Replit database to your VPS:

**On Replit** (run in the Replit shell):
```bash
pg_dump "$DATABASE_URL" --no-owner --no-acl -f /tmp/diaspora_backup.sql
```

Then copy it to the VPS:
```bash
# On your local machine:
# First download from Replit, then upload to VPS:
scp root@YOUR_VPS_IP:/tmp/diaspora_backup.sql .   # if Replit shell has SSH
# OR use the Replit file download → upload to VPS via scp
```

**On the VPS**, restore it:
```bash
DATABASE_URL="postgresql://diaspora:YOUR_PASSWORD@localhost:5432/uganda_diaspora"
psql "$DATABASE_URL" < /tmp/diaspora_backup.sql
```

---

## Adding a domain later

1. Point your domain's A record to the VPS IP
2. Edit `/etc/nginx/sites-available/uganda-diaspora` — replace `server_name _;` with `server_name yourdomain.com;`
3. Install Certbot for free HTTPS:
   ```bash
   pacman -S certbot certbot-nginx
   certbot --nginx -d yourdomain.com
   ```
4. Reload Nginx: `systemctl reload nginx`

---

## Updating the app (after code changes)

```bash
cd /opt/uganda-diaspora
git pull                          # if using Git
pnpm install --frozen-lockfile
pnpm run typecheck:libs
cd artifacts/api-server && pnpm run build && cd ../..
cd artifacts/admin-dashboard && PORT=3000 BASE_PATH=/ NODE_ENV=production pnpm run build && cd ../..
pm2 restart uganda-api
```

---

## Useful commands

| Task | Command |
|------|---------|
| View API logs | `pm2 logs uganda-api` |
| Restart API | `pm2 restart uganda-api` |
| Check all services | `pm2 status` |
| Nginx logs | `journalctl -u nginx -f` |
| PostgreSQL shell | `su - postgres -c psql` |
| DB connection test | `psql "$DATABASE_URL" -c "\dt"` |
