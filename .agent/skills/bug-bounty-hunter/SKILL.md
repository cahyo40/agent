---
name: bug-bounty-hunter
description: "Expert bug bounty hunting including vulnerability discovery, responsible disclosure, report writing, and platforms like HackerOne and Bugcrowd"
---

# Bug Bounty Hunter

## Overview

This skill transforms you into a **Bug Bounty Professional**. You will master **Vulnerability Discovery**, **Recon Automation**, **Report Writing**, and **Platform Navigation** for earning bounties through responsible disclosure.

## When to Use This Skill

- Use when hunting for bugs on authorized programs
- Use when writing vulnerability reports
- Use when automating reconnaissance
- Use when prioritizing targets
- Use when understanding program scopes

---

## Part 1: Bug Bounty Fundamentals

### 1.1 Top Platforms

| Platform | Focus |
|----------|-------|
| **HackerOne** | Enterprise programs, managed |
| **Bugcrowd** | Diverse programs |
| **Intigriti** | European focus |
| **YesWeHack** | European programs |
| **Synack** | Invite-only, vetted |

### 1.2 Program Types

| Type | Description |
|------|-------------|
| **Public** | Anyone can participate |
| **Private** | Invitation only |
| **VDP** | Vulnerability Disclosure, often no bounty |

### 1.3 Scope Understanding

Always check:

- In-scope domains/apps
- Out-of-scope items
- Vulnerability types accepted
- Testing restrictions

---

## Part 2: Reconnaissance Workflow

### 2.1 Subdomain Enumeration

```bash
# Passive
subfinder -d target.com -o subs.txt
amass enum -passive -d target.com

# Active
ffuf -u https://FUZZ.target.com -w wordlist.txt -mc 200,301,302

# Combine and dedupe
cat subs.txt | sort -u | httpx -o live.txt
```

### 2.2 Content Discovery

```bash
# Directory brute force
ffuf -u https://target.com/FUZZ -w /opt/SecLists/Discovery/Web-Content/big.txt

# Parameter discovery
arjun -u https://target.com/api/endpoint

# JavaScript analysis
cat js_files.txt | xargs -I@ bash -c 'curl -s @ | grep -oP "https?://[^\"]+|/api/[^\"]+|apiKey[^\"]*"'
```

### 2.3 Automation Pipeline

```bash
#!/bin/bash
# recon.sh

TARGET=$1

echo "[*] Subdomain enumeration..."
subfinder -d $TARGET -silent | httpx -silent > live_subs.txt

echo "[*] Port scanning..."
naabu -l live_subs.txt -p 80,443,8080,8443 -silent > ports.txt

echo "[*] Tech stack..."
httpx -l live_subs.txt -tech-detect -silent

echo "[*] Nuclei scan..."
nuclei -l live_subs.txt -t nuclei-templates/ -severity critical,high -o vulns.txt
```

---

## Part 3: High-Value Vulnerability Types

### 3.1 Top Bugs by Payout

| Vulnerability | Typical Bounty |
|---------------|----------------|
| **RCE** | $10,000 - $100,000+ |
| **SSRF to Cloud Metadata** | $5,000 - $20,000 |
| **SQL Injection** | $3,000 - $15,000 |
| **Authentication Bypass** | $2,000 - $10,000 |
| **IDOR (PII access)** | $1,000 - $5,000 |
| **XSS (Stored)** | $500 - $3,000 |

### 3.2 Focus Areas

| Area | What to Look For |
|------|------------------|
| **Auth Flows** | OAuth misconfig, session issues |
| **API Endpoints** | IDOR, broken auth, rate limiting |
| **File Uploads** | Path traversal, RCE via upload |
| **Admin Panels** | Default creds, bypass |
| **Mobile API** | API keys, broken auth |

---

## Part 4: Report Writing

### 4.1 Good Report Structure

```markdown
## Title: IDOR Allows Access to Other Users' Payment Details

**Program:** TargetCorp Payments
**Severity:** High (CVSS 7.5)
**Endpoint:** `GET /api/v1/payments/{payment_id}`

### Summary
Authenticated users can access payment details of any user by changing the `payment_id` parameter.

### Steps to Reproduce
1. Log in to https://app.target.com
2. Navigate to Settings → Payments
3. Intercept the request to `/api/v1/payments/12345`
4. Change `12345` to `12346` (another user's payment ID)
5. Response contains other user's payment details

### Proof of Concept
[Screenshot showing access to another user's data]

### Impact
Attacker can access PII including:
- Full name
- Billing address
- Last 4 digits of card

### Remediation
- Verify user owns the requested payment before returning data
- Use UUID instead of sequential IDs
```

### 4.2 Report Tips

| Do | Don't |
|----|-------|
| Clear repro steps | Vague descriptions |
| Screenshots/videos | Missing evidence |
| Explain impact | Just "I found XSS" |
| One bug per report | Bundle unrelated bugs |

---

## Part 5: Common Mistakes

### 5.1 What Gets Reports Closed

| Mistake | Why Closed |
|---------|------------|
| **Out of Scope** | Didn't read program policy |
| **Already Known** | Duplicate |
| **No Impact** | Theoretical only |
| **Self-XSS** | Requires victim to paste code |
| **Missing Verification** | Doesn't actually exploit |

### 5.2 How to Stand Out

- **Unique Attack Chains**: Combine low-severity bugs.
- **Automation**: Find what others miss.
- **Root Cause Analysis**: Show fix, not just bug.
- **Responsive**: Answer triager questions quickly.

---

## Part 6: Tools Arsenal

### 6.1 Essential Tools

| Category | Tools |
|----------|-------|
| **Recon** | subfinder, amass, httpx, naabu |
| **Scanning** | Nuclei, ffuf, Burp Suite |
| **Exploitation** | sqlmap, XSStrike, SSRFmap |
| **Wordlists** | SecLists, commonspeak2 |
| **Reporting** | Markdown, screenshots |

### 6.2 Nuclei Custom Templates

```yaml
id: custom-api-exposure

info:
  name: Custom API Key Exposure
  severity: medium

requests:
  - method: GET
    path:
      - "{{BaseURL}}/config.js"
      - "{{BaseURL}}/env.js"
    matchers:
      - type: word
        words:
          - "API_KEY"
          - "apiSecret"
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Read Scope Carefully**: Avoid wasting time.
- ✅ **Automate Recon**: Check for changes regularly.
- ✅ **Quality > Quantity**: Well-written reports get paid.

### ❌ Avoid This

- ❌ **Testing Without Authorization**: Even on public programs, follow rules.
- ❌ **Rage Quitting**: Triage takes time; be patient.
- ❌ **Sharing Before Disclosure**: Wait for fix + permission.

---

## Related Skills

- `@senior-penetration-tester` - Full pentest methodology
- `@red-team-operator` - Advanced techniques
- `@senior-cybersecurity-engineer` - Security architecture
