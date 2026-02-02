---
name: bug-bounty-hunter
description: "Expert bug bounty hunting including vulnerability discovery, responsible disclosure, report writing, and platforms like HackerOne and Bugcrowd"
---

# Bug Bounty Hunter

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis bug bounty hunting. Agent akan mampu mengidentifikasi vulnerability di aplikasi web dan mobile, menulis laporan yang efektif, memahami program rules, dan memaksimalkan payout di platform seperti HackerOne, Bugcrowd, dan Intigriti.

## When to Use This Skill

- Use when hunting for vulnerabilities in bug bounty programs
- Use when writing vulnerability reports for submission
- Use when the user asks about bug bounty methodology
- Use when assessing web/mobile application security
- Use when learning ethical hacking for bounty programs

## How It Works

### Step 1: Reconnaissance

```text
┌─────────────────────────────────────────────────────────┐
│                   RECON METHODOLOGY                     │
├─────────────────────────────────────────────────────────┤
│ 1. Subdomain Enumeration                                │
│    - Amass, Subfinder, Assetfinder                      │
│    - Certificate transparency logs                      │
│                                                         │
│ 2. Technology Fingerprinting                            │
│    - Wappalyzer, WhatWeb, BuiltWith                     │
│    - Identify frameworks, CMS, servers                  │
│                                                         │
│ 3. Content Discovery                                    │
│    - Dirsearch, Gobuster, Feroxbuster                   │
│    - Find hidden endpoints, admin panels                │
│                                                         │
│ 4. JavaScript Analysis                                  │
│    - LinkFinder, JSParser                               │
│    - Extract API endpoints, secrets                     │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Common Vulnerability Classes

#### OWASP Top 10 Focus

```text
Priority Vulnerabilities for Bug Bounties:
├── 1. IDOR (Insecure Direct Object Reference) - High payout
├── 2. Authentication Bypass - Critical
├── 3. SQL Injection - Critical
├── 4. XSS (Cross-Site Scripting) - Medium-High
├── 5. SSRF (Server-Side Request Forgery) - High
├── 6. Business Logic Flaws - Variable
├── 7. Race Conditions - Medium-High
├── 8. Information Disclosure - Low-Medium
├── 9. CSRF (Cross-Site Request Forgery) - Medium
└── 10. Open Redirect - Low
```

### Step 3: Testing Methodology

```bash
# Subdomain enumeration
subfinder -d target.com -o subdomains.txt
amass enum -passive -d target.com >> subdomains.txt

# Port scanning
nmap -sV -sC -p- -oA nmap_scan target.com

# Directory brute-forcing
feroxbuster -u https://target.com -w /path/to/wordlist.txt

# Parameter discovery
arjun -u https://target.com/api/endpoint

# Nuclei for known vulnerabilities
nuclei -u https://target.com -t cves/
```

### Step 4: Writing Effective Reports

```markdown
# Vulnerability Report Template

## Title
[Vulnerability Type] in [Feature/Endpoint] allows [Impact]

## Summary
Brief 2-3 sentence description of the vulnerability.

## Severity
Critical / High / Medium / Low (with CVSS score if applicable)

## Steps to Reproduce
1. Navigate to https://target.com/vulnerable-endpoint
2. Intercept request with Burp Suite
3. Modify parameter X to Y
4. Observe unauthorized access to...

## Proof of Concept
[Screenshot or video evidence]

## Impact
Describe what an attacker could achieve:
- Access to sensitive data
- Account takeover
- Financial loss

## Remediation
Suggested fix for the development team.

## References
- OWASP: https://owasp.org/...
- CWE: https://cwe.mitre.org/...
```

### Step 5: Platform-Specific Tips

| Platform | Focus | Tips |
|----------|-------|------|
| HackerOne | Enterprise programs | Focus on critical vulns, read scope carefully |
| Bugcrowd | Diverse programs | VRT for severity, good for beginners |
| Intigriti | EU-focused | Strong on web apps, good community |
| Synack | Invite-only | Higher payouts, vetted researchers |

## Best Practices

### ✅ Do This

- ✅ Always read program scope and rules thoroughly
- ✅ Document everything with timestamps
- ✅ Start with wide recon, then go deep on interesting targets
- ✅ Chain vulnerabilities for higher impact
- ✅ Be professional and respectful in communications

### ❌ Avoid This

- ❌ Never test outside of scope
- ❌ Don't use automated tools without understanding them
- ❌ Never access, modify, or delete real user data
- ❌ Don't submit duplicate or low-quality reports
- ❌ Never publicly disclose before authorized

## Common Pitfalls

**Problem:** Reports marked as duplicate
**Solution:** Do deeper recon on less-tested assets, focus on unique attack vectors.

**Problem:** Low severity ratings
**Solution:** Chain vulnerabilities to demonstrate higher impact. IDOR + PII = Critical.

## Related Skills

- `@senior-penetration-tester` - Comprehensive pen testing
- `@senior-api-security-specialist` - API vulnerability focus
- `@senior-cybersecurity-engineer` - Defensive security
- `@network-security-specialist` - Network-level attacks
