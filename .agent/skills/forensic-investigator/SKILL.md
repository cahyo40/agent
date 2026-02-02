---
name: forensic-investigator
description: "Expert digital forensics including disk forensics, memory analysis, network forensics, incident response, and evidence collection"
---

# Forensic Investigator

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis digital forensics. Agent akan mampu melakukan disk forensics, memory analysis, network forensics, incident response, dan pengumpulan bukti digital yang dapat digunakan untuk investigasi keamanan atau legal proceedings.

## When to Use This Skill

- Use when investigating security incidents
- Use when analyzing disk images or memory dumps
- Use when collecting digital evidence
- Use when the user asks about forensic analysis
- Use when performing incident response

## How It Works

### Step 1: Forensic Process

```text
┌─────────────────────────────────────────────────────────┐
│              DIGITAL FORENSICS PROCESS                  │
├─────────────────────────────────────────────────────────┤
│ 1. IDENTIFICATION  - Identify potential evidence sources│
│ 2. PRESERVATION    - Create forensic copies, chain of   │
│                      custody                            │
│ 3. COLLECTION      - Acquire data without modification  │
│ 4. EXAMINATION     - Process and analyze evidence       │
│ 5. ANALYSIS        - Interpret findings                 │
│ 6. PRESENTATION    - Document and report findings       │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Disk Forensics

```bash
# Create forensic image
dd if=/dev/sda of=disk_image.dd bs=4M status=progress
dc3dd if=/dev/sda of=disk_image.dd hash=sha256 log=acquisition.log

# Verify hash
sha256sum disk_image.dd

# Mount read-only
mount -o ro,loop,noexec disk_image.dd /mnt/evidence

# Autopsy / Sleuth Kit
autopsy  # Web-based GUI
fls -r disk_image.dd  # List files
icat disk_image.dd 12345 > recovered_file.txt  # Extract by inode

# Timeline analysis
fls -m "/" -r disk_image.dd > bodyfile.txt
mactime -b bodyfile.txt > timeline.csv
```

#### Windows Artifacts

```text
Critical Locations:
├── Registry Hives
│   ├── NTUSER.DAT (user settings)
│   ├── SAM (user accounts)
│   ├── SYSTEM (system config)
│   └── SOFTWARE (installed software)
├── Event Logs
│   ├── Security.evtx
│   ├── System.evtx
│   └── Application.evtx
├── Prefetch (C:\Windows\Prefetch)
├── Recent Files (LNK files)
├── Browser History
├── $MFT (Master File Table)
└── $UsnJrnl (Change journal)
```

### Step 3: Memory Forensics

```bash
# Acquire memory (live)
winpmem_mini_x64.exe memdump.raw  # Windows
sudo avml memdump.lime             # Linux

# Volatility 3 analysis
vol -f memdump.raw windows.info
vol -f memdump.raw windows.pslist      # Running processes
vol -f memdump.raw windows.pstree      # Process tree
vol -f memdump.raw windows.cmdline     # Command lines
vol -f memdump.raw windows.netscan     # Network connections
vol -f memdump.raw windows.malfind     # Injected code
vol -f memdump.raw windows.dlllist     # Loaded DLLs
vol -f memdump.raw windows.handles     # Open handles
vol -f memdump.raw windows.filescan    # File objects
vol -f memdump.raw windows.hashdump    # Password hashes

# Dump suspicious process
vol -f memdump.raw windows.pslist --pid 1234 --dump
```

### Step 4: Network Forensics

```bash
# Analyze PCAP
tshark -r capture.pcap -z conv,tcp  # TCP conversations
tshark -r capture.pcap -z http,tree  # HTTP statistics

# Extract files
foremost -i capture.pcap -o extracted/
NetworkMiner capture.pcap  # GUI tool

# Zeek (Bro) analysis
zeek -r capture.pcap
cat conn.log | zeek-cut id.orig_h id.resp_h id.resp_p proto

# DNS analysis
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | sort | uniq -c | sort -rn

# Find data exfiltration
tshark -r capture.pcap -Y "tcp.len > 1000" -T fields -e ip.dst -e tcp.len | sort | uniq
```

### Step 5: Log Analysis

```bash
# Windows Event Logs (with PowerShell)
Get-WinEvent -Path Security.evtx | Where-Object {$_.Id -eq 4624}  # Logons
Get-WinEvent -Path Security.evtx | Where-Object {$_.Id -eq 4625}  # Failed logons
Get-WinEvent -Path Security.evtx | Where-Object {$_.Id -eq 4688}  # Process creation

# Linux logs
grep "Failed password" /var/log/auth.log
grep "Accepted password" /var/log/auth.log
journalctl --since "2026-02-01" --until "2026-02-02"

# Apache/Nginx logs
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head
grep -E "(SELECT|UNION|INSERT|UPDATE|DELETE)" access.log  # SQL injection attempts
```

### Step 6: Incident Response

```text
IR Playbook:
├── 1. Detection & Triage
│   ├── Identify scope of incident
│   ├── Assess criticality
│   └── Activate IR team
├── 2. Containment
│   ├── Isolate affected systems
│   ├── Block malicious IPs/domains
│   └── Disable compromised accounts
├── 3. Eradication
│   ├── Remove malware
│   ├── Patch vulnerabilities
│   └── Reset credentials
├── 4. Recovery
│   ├── Restore from clean backups
│   ├── Rebuild affected systems
│   └── Monitor for reinfection
└── 5. Lessons Learned
    ├── Document timeline
    ├── Root cause analysis
    └── Improve defenses
```

### Step 7: Evidence Collection Checklist

```yaml
Chain of Custody:
  - Date/time of acquisition
  - Who collected the evidence
  - Hash values (MD5, SHA256)
  - Storage location
  - Access log

Evidence Types:
  - [ ] Disk images (E01, dd, raw)
  - [ ] Memory dumps
  - [ ] Network captures (PCAP)
  - [ ] Log files
  - [ ] Screenshots
  - [ ] Notes and observations

Documentation:
  - Detailed timeline of events
  - All commands executed
  - Findings and artifacts
  - IOCs identified
```

## Best Practices

### ✅ Do This

- ✅ Always work on forensic copies, never original evidence
- ✅ Document every action with timestamps
- ✅ Maintain chain of custody
- ✅ Use write blockers when acquiring disk images
- ✅ Verify integrity with cryptographic hashes

### ❌ Avoid This

- ❌ Never modify original evidence
- ❌ Don't skip documentation—even small details matter
- ❌ Don't analyze malware on the evidence system
- ❌ Don't assume—verify with multiple artifacts
- ❌ Never break chain of custody

## Common Pitfalls

**Problem:** Evidence hash doesn't match after analysis
**Solution:** Always use write blockers and work on copies. Original should never change.

**Problem:** Volatility plugin not working
**Solution:** Ensure correct profile/OS version. Use `windows.info` to verify.

## Related Skills

- `@malware-analyst` - Analyze malware found in investigation
- `@network-security-specialist` - Network traffic analysis
- `@senior-cybersecurity-engineer` - Security context
- `@senior-linux-sysadmin` - Understanding system logs
