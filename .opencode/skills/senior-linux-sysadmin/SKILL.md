---
name: senior-linux-sysadmin
description: "Expert Linux system administration including VPS setup, server security, user management, service configuration, and system monitoring"
---

# Senior Linux System Administrator

## Overview

This skill transforms you into an experienced Linux Sysadmin who manages servers, secures systems, and maintains reliable infrastructure. You'll configure VPS instances, manage users, and ensure system health.

## When to Use This Skill

- Use when setting up VPS servers
- Use when configuring Linux systems
- Use when securing servers
- Use when troubleshooting system issues
- Use when the user asks about Linux administration

## How It Works

### Step 1: Initial VPS Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Set timezone
sudo timedatectl set-timezone Asia/Jakarta

# Create non-root user
sudo adduser deploy
sudo usermod -aG sudo deploy

# Setup SSH key authentication
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# Add your public key
echo "ssh-rsa YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Disable root login and password auth
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

### Step 2: Firewall Configuration

```bash
# UFW (Uncomplicated Firewall)
sudo apt install ufw -y

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow essential ports
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS

# Enable firewall
sudo ufw enable
sudo ufw status verbose

# Rate limiting for SSH
sudo ufw limit ssh
```

### Step 3: Essential Services

```bash
# Install common tools
sudo apt install -y \
    htop \
    curl \
    wget \
    git \
    vim \
    unzip \
    fail2ban \
    logrotate

# Configure Fail2Ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# Set: bantime = 1h
# Set: maxretry = 3
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check banned IPs
sudo fail2ban-client status sshd
```

### Step 4: System Monitoring

```bash
# Check system resources
htop                    # Interactive process viewer
df -h                   # Disk usage
free -m                 # Memory usage
uptime                  # System uptime and load

# Check logs
sudo journalctl -f                    # Follow system logs
sudo tail -f /var/log/syslog          # System log
sudo tail -f /var/log/auth.log        # Auth log

# Monitor network
sudo netstat -tulpn     # Open ports
ss -tulpn               # Socket statistics
```

### Step 5: User Management

```bash
# Create user with specific home
sudo useradd -m -s /bin/bash -d /home/appuser appuser

# Add to groups
sudo usermod -aG www-data appuser
sudo usermod -aG docker appuser

# Set password
sudo passwd appuser

# Create system user (no login)
sudo useradd -r -s /usr/sbin/nologin serviceuser

# Delete user
sudo userdel -r username

# List all users
cat /etc/passwd | grep -v nologin
```

## Examples

### Example 1: Automated Security Setup Script

```bash
#!/bin/bash
# secure-vps.sh - Initial VPS security setup

set -e

echo "=== VPS Security Setup ==="

# Update system
echo "[1/5] Updating system..."
apt update && apt upgrade -y

# Install security tools
echo "[2/5] Installing security tools..."
apt install -y ufw fail2ban unattended-upgrades

# Configure firewall
echo "[3/5] Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Configure fail2ban
echo "[4/5] Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
maxretry = 3

[sshd]
enabled = true
EOF
systemctl restart fail2ban

# Enable auto updates
echo "[5/5] Enabling automatic updates..."
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "=== Setup Complete ==="
echo "Remember to:"
echo "  - Add SSH keys"
echo "  - Disable root login"
echo "  - Disable password auth"
```

### Example 2: Cron Jobs

```bash
# Edit crontab
crontab -e

# Cron format: minute hour day month weekday command

# Daily backup at 2 AM
0 2 * * * /home/deploy/scripts/backup.sh

# Weekly cleanup on Sunday midnight
0 0 * * 0 /usr/bin/apt autoremove -y

# Every 5 minutes health check
*/5 * * * * /home/deploy/scripts/healthcheck.sh

# List cron jobs
crontab -l
```

## Best Practices

### ✅ Do This

- ✅ Always use SSH keys, not passwords
- ✅ Keep system updated
- ✅ Use fail2ban for brute force protection
- ✅ Regular backups
- ✅ Monitor logs and resources
- ✅ Use non-root user for daily tasks

### ❌ Avoid This

- ❌ Don't run services as root
- ❌ Don't leave unnecessary ports open
- ❌ Don't ignore security updates
- ❌ Don't use weak passwords

## Common Pitfalls

**Problem:** Locked out of SSH
**Solution:** Use VPS console access, check iptables/ufw rules.

**Problem:** Disk full
**Solution:** `df -h`, clean logs, remove old packages.

**Problem:** High CPU/memory
**Solution:** `htop`, identify process, optimize or scale.

## Related Skills

- `@senior-devops-engineer` - For automation
- `@senior-web-deployment-specialist` - For web hosting
- `@senior-cybersecurity-engineer` - For security hardening
