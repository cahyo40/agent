---
name: forensic-investigator
description: "Expert digital forensics including disk forensics, memory analysis, network forensics, incident response, and evidence collection"
---

# Forensic Investigator

## Overview

This skill transforms you into a **Digital Forensics Expert**. You will master **Disk Analysis**, **Memory Forensics**, **Network Forensics**, and **Incident Response** for conducting thorough digital investigations.

## When to Use This Skill

- Use when investigating security incidents
- Use when analyzing malware artifacts
- Use when recovering deleted data
- Use when collecting digital evidence
- Use when building incident timelines

---

## Part 1: Forensics Fundamentals

### 1.1 Investigation Process

```
Identification → Preservation → Collection → Analysis → Reporting
```

### 1.2 Chain of Custody

| Element | Requirement |
|---------|-------------|
| **Documentation** | Who, what, when, where |
| **Hashing** | MD5/SHA256 of evidence |
| **Write Blockers** | Prevent modification |
| **Secure Storage** | Encrypted, access-controlled |

### 1.3 Evidence Types

| Type | Examples |
|------|----------|
| **Disk** | Hard drives, SSDs, USB |
| **Memory** | RAM dumps |
| **Network** | Packet captures, logs |
| **Cloud** | API logs, container images |
| **Mobile** | Phone dumps |

---

## Part 2: Disk Forensics

### 2.1 Image Acquisition

```bash
# Create forensic image (dd)
dd if=/dev/sda of=disk.img bs=4M status=progress

# With hashing
dc3dd if=/dev/sda of=disk.img hash=sha256 log=hash.log

# FTK Imager (Windows)
# Autopsy (cross-platform)
```

### 2.2 File System Analysis

```bash
# Mount image (read-only)
mount -o ro,loop,offset=$((512*2048)) disk.img /mnt/evidence

# List files with timestamps
ls -la --time-style=full-iso

# Autopsy (GUI tool)
autopsy
```

### 2.3 File Recovery

```bash
# Photorec - file carving
photorec disk.img

# TestDisk - partition recovery
testdisk disk.img

# Foremost - specific file types
foremost -t jpg,pdf -i disk.img -o recovered/
```

### 2.4 Timeline Analysis

```bash
# Plaso/Log2Timeline
log2timeline.py timeline.plaso disk.img
psort.py -o l2tcsv timeline.plaso "date > '2024-01-01'" > timeline.csv
```

---

## Part 3: Memory Forensics

### 3.1 Memory Acquisition

```bash
# Linux
dd if=/dev/mem of=memory.raw

# Windows
winpmem.exe memory.raw

# VMware
vmss2core <vm>.vmss <vm>.vmem
```

### 3.2 Volatility 3

```bash
# Identify profile
vol -f memory.raw windows.info

# Process list
vol -f memory.raw windows.pslist

# Hidden processes
vol -f memory.raw windows.psscan

# Network connections
vol -f memory.raw windows.netscan

# Command line arguments
vol -f memory.raw windows.cmdline

# Dump process
vol -f memory.raw windows.pslist --pid 1234 --dump
```

### 3.3 Key Artifacts

| Artifact | What It Shows |
|----------|---------------|
| **pslist** | Running processes |
| **psscan** | Hidden processes |
| **netscan** | Network connections |
| **malfind** | Injected code |
| **hashdump** | Password hashes |
| **filescan** | Open file handles |

---

## Part 4: Network Forensics

### 4.1 Packet Analysis

```bash
# Wireshark filters
ip.addr == 10.0.0.5
tcp.port == 80
http.request.method == "POST"
dns.qry.name contains "malware"

# tshark (command line)
tshark -r capture.pcap -Y "http" -T fields -e http.host -e http.request.uri

# Extract files
tshark -r capture.pcap --export-objects http,./extracted
```

### 4.2 Network Artifacts

| Source | Information |
|--------|-------------|
| **Firewall Logs** | Allowed/blocked connections |
| **DNS Logs** | Domain lookups |
| **Proxy Logs** | URL access |
| **NetFlow** | Traffic patterns |
| **PCAP** | Full packet content |

### 4.3 Zeek/Bro

```bash
# Process PCAP
zeek -r capture.pcap

# Review logs
cat conn.log | zeek-cut id.orig_h id.resp_h id.resp_p service
cat http.log | zeek-cut host uri
cat dns.log | zeek-cut query
```

---

## Part 5: Incident Response

### 5.1 IR Process

```
Preparation → Identification → Containment → Eradication → Recovery → Lessons Learned
```

### 5.2 Containment Actions

| Level | Action |
|-------|--------|
| **Network** | Block IP, isolate segment |
| **Host** | Disconnect, disable account |
| **Application** | Kill process, revoke tokens |

### 5.3 Evidence Collection Script

```bash
#!/bin/bash
# ir_collect.sh

CASE_DIR="evidence_$(date +%Y%m%d_%H%M%S)"
mkdir -p $CASE_DIR

# System info
uname -a > $CASE_DIR/system_info.txt
cat /etc/passwd > $CASE_DIR/users.txt

# Network
netstat -tulpn > $CASE_DIR/network.txt
iptables -L > $CASE_DIR/firewall.txt

# Processes
ps auxf > $CASE_DIR/processes.txt
lsof -i > $CASE_DIR/open_connections.txt

# Recent files
find / -mtime -1 -type f 2>/dev/null > $CASE_DIR/recent_files.txt

# Hash everything
find $CASE_DIR -type f -exec sha256sum {} \; > $CASE_DIR/hashes.txt
```

---

## Part 6: Reporting

### 6.1 Report Structure

| Section | Content |
|---------|---------|
| **Executive Summary** | Key findings for non-technical |
| **Scope** | What was investigated |
| **Methodology** | Tools and techniques |
| **Timeline** | Event sequence |
| **Findings** | Evidence with screenshots |
| **Conclusions** | What happened |
| **Recommendations** | How to prevent recurrence |

### 6.2 Documentation Tips

- Screenshot everything.
- Include commands used.
- Hash all evidence.
- Note timestamps in UTC.

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Use Write Blockers**: Preserve evidence integrity.
- ✅ **Hash Before and After**: Verify no modification.
- ✅ **Document Chain of Custody**: Legal admissibility.

### ❌ Avoid This

- ❌ **Modifying Evidence**: Always work on copies.
- ❌ **Skipping Documentation**: Every step matters.
- ❌ **Rushing Analysis**: Thoroughness over speed.

---

## Related Skills

- `@malware-analyst` - Malware analysis
- `@senior-penetration-tester` - Offensive perspective
- `@ctf-competitor` - CTF forensics challenges
