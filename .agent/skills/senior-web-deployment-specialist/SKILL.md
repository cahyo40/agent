---
name: senior-web-deployment-specialist
description: "Expert web deployment including Nginx configuration, SSL certificates, Docker deployment, domain setup, and CI/CD for web projects"
---

# Senior Web Deployment Specialist

## Overview

This skill transforms you into an experienced Web Deployment Specialist who deploys websites and applications to production servers. You'll configure Nginx, set up SSL, deploy with Docker, and establish CI/CD pipelines.

## When to Use This Skill

- Use when deploying websites to VPS
- Use when configuring Nginx
- Use when setting up SSL certificates
- Use when deploying with Docker
- Use when the user asks about web hosting

## How It Works

### Step 1: Nginx Setup

```bash
# Install Nginx
sudo apt install nginx -y
sudo systemctl enable nginx

# Basic site configuration
sudo nano /etc/nginx/sites-available/mysite

# Remove default and enable site
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### Step 2: Nginx Configuration

```nginx
# /etc/nginx/sites-available/mysite

# HTTP redirect to HTTPS
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}

# Main HTTPS server
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    # SSL (managed by Certbot)
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Static files
    root /var/www/mysite;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### Step 3: SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal (already set up by certbot)
sudo certbot renew --dry-run

# Check certificate expiry
sudo certbot certificates
```

### Step 4: Docker Deployment

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    container_name: myapp
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    container_name: mydb
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=mydb
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
```

```bash
# Deploy with Docker Compose
docker compose up -d

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Update deployment
docker compose pull
docker compose up -d --build
```

### Step 5: Deployment Script

```bash
#!/bin/bash
# deploy.sh - Automated deployment script

set -e

APP_DIR="/var/www/mysite"
REPO="git@github.com:user/repo.git"
BRANCH="main"

echo "=== Starting Deployment ==="

# Pull latest code
cd $APP_DIR
git fetch origin
git reset --hard origin/$BRANCH

# Install dependencies
npm ci --production

# Build application
npm run build

# Restart application (PM2)
pm2 restart myapp

# Or restart Docker
# docker compose up -d --build

echo "=== Deployment Complete ==="
```

## Examples

### Example 1: Full VPS Website Setup

```bash
#!/bin/bash
# full-setup.sh - Complete website deployment

DOMAIN="example.com"
APP_DIR="/var/www/$DOMAIN"

# 1. Create directory
sudo mkdir -p $APP_DIR
sudo chown -R $USER:www-data $APP_DIR

# 2. Clone repository
git clone git@github.com:user/repo.git $APP_DIR

# 3. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 4. Build app
cd $APP_DIR
npm install
npm run build

# 5. Install PM2
sudo npm install -g pm2
pm2 start npm --name "myapp" -- start
pm2 save
pm2 startup

# 6. Configure Nginx
sudo tee /etc/nginx/sites-available/$DOMAIN << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root $APP_DIR/dist;
    index index.html;
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 7. SSL Certificate
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "=== Setup Complete ==="
echo "Visit: https://$DOMAIN"
```

### Example 2: GitHub Actions CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy to VPS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to VPS
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /var/www/mysite
            git pull origin main
            npm ci --production
            npm run build
            pm2 restart myapp
```

## Best Practices

### ✅ Do This

- ✅ Always use HTTPS (Let's Encrypt is free)
- ✅ Set up automatic SSL renewal
- ✅ Use reverse proxy for Node apps
- ✅ Enable Gzip compression
- ✅ Set security headers
- ✅ Use PM2 or Docker for process management

### ❌ Avoid This

- ❌ Don't expose app ports directly
- ❌ Don't skip SSL
- ❌ Don't run as root
- ❌ Don't hardcode secrets

## Common Pitfalls

**Problem:** 502 Bad Gateway
**Solution:** Check if backend is running, verify proxy_pass URL.

**Problem:** SSL certificate expired
**Solution:** Run `certbot renew`, check cron job.

**Problem:** Permission denied
**Solution:** Check file ownership, use www-data group.

## Related Skills

- `@senior-linux-sysadmin` - For server setup
- `@senior-devops-engineer` - For CI/CD pipelines
