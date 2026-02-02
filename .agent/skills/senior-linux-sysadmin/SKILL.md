---
name: senior-linux-sysadmin
description: "Expert Linux system administration including kernel tuning, security hardening, eBPF monitoring, and production server management"
---

# Senior Linux Sysadmin

## Overview

This skill transforms you into a **Senior Linux Systems Engineer**. You will move beyond basic user management (`useradd`, `chmod`) to mastering Kernel Tuning (`sysctl`), advanced storage (LVM/ZFS), security hardening (SELinux/AppArmor), and modern eBPF-based observability.

## When to Use This Skill

- Use when debugging system performance (CPU, Memory, I/O)
- Use when hardening servers for production (CIS Benchmarks)
- Use when configuring high-throughput networking
- Use when managing storage volumes (Resize, Snapshot)
- Use when troubleshooting boot issues or kernel panics

---

## Part 1: Kernel Tuning (sysctl)

Defaults are often for desktop usage. Servers need tuning.

### 1.1 High-Performance Networking

**File: `/etc/sysctl.d/99-performance.conf`**

```ini
# Increase connection tracking table (prevent dropped packets)
net.netfilter.nf_conntrack_max = 524288

# TCP Window Scaling (For high throughput on high latency links)
net.ipv4.tcp_window_scaling = 1

# Max open files (file descriptors)
fs.file-max = 2097152

# Increase backlog for incoming connections (Handle request spikes)
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192

# Reuse TIME_WAIT sockets (Short-lived connections)
net.ipv4.tcp_tw_reuse = 1

# Keepalive settings (Detect dead peers faster)
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
```

**Apply changes:** `sysctl -p /etc/sysctl.d/99-performance.conf`

---

## Part 2: Security Hardening

### 2.1 SSH Hardening

**File: `/etc/ssh/sshd_config`**

```config
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
Protocol 2
AllowUsers deploy-user
```

### 2.2 UFW (Uncomplicated Firewall)

Always default deny.

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 2.3 Filesystem Permissions

Prevent users from seeing other users' processes.

```bash
mount -o remount,rw,hidepid=2 /proc
```

---

## Part 3: Advanced Storage (LVM)

Logical Volume Manager allows resizing disks without downtime.

```bash
# 1. Initialize physical disk
pvcreate /dev/sdb

# 2. Creating a Volume Group (VG)
vgcreate data_vg /dev/sdb

# 3. Create Logical Volume (LV)
lvcreate -L 50G -n db_data data_vg

# 4. Format and Mount
mkfs.ext4 /dev/data_vg/db_data
mount /dev/data_vg/db_data /mnt/db

# 5. RESIZE ON THE FLY (The Magic)
lvextend -L +10G /dev/data_vg/db_data
resize2fs /dev/data_vg/db_data
# Done! No reboot. No unmount.
```

---

## Part 4: Modern Observability

### 4.1 Traditional Tools (Legacy)

- **CPU**: `htop`, `mpstat -P ALL`
- **Memory**: `free -h`, `vmstat 1`
- **Disk I/O**: `iostat -xz 1`
- **Network**: `iftop`, `ss -tulpn`

### 4.2 Modern Tools (eBPF) - `bcc-tools`

eBPF allows safe, low-overhead kernel tracing.

```bash
# Installation
apt install bpfcc-tools linux-headers-$(uname -r)

# 1. execsnoop
# Trace new processes (Detect short-lived cron jobs or malware)
execsnoop-bpfcc

# 2. opensnoop
# Trace file opens (Who is touching that config file?)
opensnoop-bpfcc

# 3. biolatency
# Histogram of disk I/O latency (Is disk slow or app slow?)
biolatency-bpfcc -m

# 4. tcptop
# Top active TCP sessions by bandwidth
tcptop-bpfcc
```

---

## Part 5: Systemd Service Management

Don't run scripts in `screen` or `nohup`. Create proper services.

**File: `/etc/systemd/system/myapp.service`**

```ini
[Unit]
Description=My Critical App
After=network.target postgresql.service

[Service]
Type=simple
User=appuser
Group=appgroup
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=5

# Security Hardening (Sandboxing)
ProtectSystem=full
PrivateTmp=true
NoNewPrivileges=true

# Resource Limits
MemoryLimit=1G
CPUQuota=50%

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now myapp
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `sudo`**: Disable root account password. Use sudoers.
- ✅ **Automate Updates**: Enable `unattended-upgrades` (security patches only).
- ✅ **Centralize Logs**: Ship `/var/log` to ELK/Loki. Disk full of logs = Outage.
- ✅ **Monitor Inodes**: `df -i`. Full inodes causes "No space left on device" even if disk has GBs free.
- ✅ **Use NTP**: Ensure clocks are synced (`chronyd` or `systemd-timesyncd`). Critical for distributed systems (Auth/DBs).

### ❌ Avoid This

- ❌ **`chmod 777`**: Never. Fix ownership (`chown`) or group permissions (`chmod 770`).
- ❌ **Editing files directly**: Use configuration management (Ansible).
- ❌ **Disabling SELinux**: Learn to configure it (`audit2allow`). Disabling it removes your last line of defense.
- ❌ **Ignoring Zombie Processes**: Check `top` for `Z` state. It means parent process is buggy.

---

## Related Skills

- `@ansible-specialist` - Automating all of this
- `@docker-containerization-specialist` - Running apps in isolation
- `@senior-devops-engineer` - Pipeline integration
