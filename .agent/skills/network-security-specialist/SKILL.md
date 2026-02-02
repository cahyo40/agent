---
name: network-security-specialist
description: "Expert network security including penetration testing, traffic analysis, firewall configuration, IDS/IPS, and network defense"
---

# Network Security Specialist

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis network security. Agent akan mampu melakukan network penetration testing, traffic analysis dengan Wireshark, konfigurasi firewall dan IDS/IPS, serta mengamankan infrastruktur jaringan dari berbagai ancaman.

## When to Use This Skill

- Use when conducting network penetration testing
- Use when analyzing network traffic for threats
- Use when configuring firewalls or IDS/IPS
- Use when the user asks about network security
- Use when designing secure network architecture

## How It Works

### Step 1: Network Reconnaissance

```bash
# Host discovery
nmap -sn 192.168.1.0/24

# Port scanning
nmap -sS -sV -p- -T4 target.com
nmap -sU --top-ports 100 target.com  # UDP

# Service enumeration
nmap -sV --version-intensity 5 target.com
nmap -sC target.com  # Default scripts

# OS detection
nmap -O target.com

# Comprehensive scan
nmap -A -T4 target.com
```

### Step 2: Traffic Analysis

```bash
# Capture traffic
tcpdump -i eth0 -w capture.pcap
tcpdump -i eth0 host 192.168.1.100 -w host_capture.pcap

# Wireshark filters
ip.addr == 192.168.1.100
tcp.port == 443
http.request.method == "POST"
dns.qry.name contains "suspicious"
tcp.flags.syn == 1 and tcp.flags.ack == 0  # SYN scan detection

# Extract files from PCAP
tshark -r capture.pcap --export-objects http,./extracted/

# Protocol analysis
tshark -r capture.pcap -Y "http" -T fields -e http.host -e http.request.uri
```

### Step 3: Network Attacks

#### Man-in-the-Middle

```bash
# ARP Spoofing
arpspoof -i eth0 -t victim_ip gateway_ip
arpspoof -i eth0 -t gateway_ip victim_ip

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Bettercap (modern MITM)
bettercap -iface eth0
> net.probe on
> set arp.spoof.targets 192.168.1.100
> arp.spoof on
> net.sniff on
```

#### DNS Attacks

```bash
# DNS enumeration
dnsenum target.com
dnsrecon -d target.com

# DNS spoofing (with Bettercap)
> set dns.spoof.domains target.com
> set dns.spoof.address attacker_ip
> dns.spoof on

# Zone transfer (misconfigured DNS)
dig axfr @ns1.target.com target.com
```

### Step 4: Firewall Configuration

#### iptables (Linux)

```bash
# Default deny policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH from specific IP
iptables -A INPUT -p tcp -s 10.0.0.0/8 --dport 22 -j ACCEPT

# Rate limiting (DDoS protection)
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "DROPPED: "
iptables -A INPUT -j DROP

# Save rules
iptables-save > /etc/iptables/rules.v4
```

#### UFW (Simplified)

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow from 10.0.0.0/8 to any port 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### Step 5: IDS/IPS Configuration

#### Snort Rules

```text
# Detect SQL injection attempt
alert tcp any any -> $HOME_NET 80 (
  msg:"SQL Injection Attempt";
  content:"UNION"; nocase;
  content:"SELECT"; nocase;
  sid:1000001; rev:1;
)

# Detect port scan
alert tcp any any -> $HOME_NET any (
  msg:"Possible Port Scan";
  flags:S;
  threshold:type both, track by_src, count 20, seconds 60;
  sid:1000002; rev:1;
)

# Detect C2 beacon
alert tcp $HOME_NET any -> any any (
  msg:"Possible C2 Beacon";
  dsize:0;
  detection_filter:track by_src, count 10, seconds 60;
  sid:1000003; rev:1;
)
```

### Step 6: Network Security Tools

| Category | Tools |
|----------|-------|
| Scanning | Nmap, Masscan, Zmap |
| Sniffing | Wireshark, tcpdump, Tshark |
| MITM | Bettercap, Ettercap, mitmproxy |
| Vuln Scan | Nessus, OpenVAS, Nexpose |
| IDS/IPS | Snort, Suricata, Zeek |
| Wireless | Aircrack-ng, Kismet, Wifite |

## Best Practices

### ✅ Do This

- ✅ Segment networks with VLANs and firewalls
- ✅ Use encrypted protocols (TLS, SSH, VPN)
- ✅ Implement network monitoring and logging
- ✅ Regularly audit firewall rules
- ✅ Keep network devices patched and updated

### ❌ Avoid This

- ❌ Don't use default credentials on network devices
- ❌ Don't expose management interfaces to internet
- ❌ Don't disable logging to save space
- ❌ Don't allow unrestricted outbound traffic
- ❌ Don't ignore IDS/IPS alerts

## Common Pitfalls

**Problem:** Nmap scan takes too long
**Solution:** Use `-T4` for faster timing, limit port range, use `--top-ports`.

**Problem:** Traffic not being captured
**Solution:** Ensure promiscuous mode, check interface, use hub or port mirroring for switched networks.

## Related Skills

- `@senior-penetration-tester` - Comprehensive pen testing
- `@red-team-operator` - Offensive operations
- `@senior-devops-engineer` - Infrastructure security
- `@senior-linux-sysadmin` - Server hardening
