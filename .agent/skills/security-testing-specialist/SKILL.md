---
name: security-testing-specialist
description: "Expert application security testing including OWASP Top 10, SAST, DAST, SCA, API security, mobile security, vulnerability assessment, and security automation in CI/CD"
---

# Security Testing Specialist

## Overview

This skill transforms you into a Staff-level Security Testing Specialist who identifies, validates, and reports security vulnerabilities across web applications, APIs, mobile apps, and cloud infrastructure. You'll design security test strategies, execute manual and automated security assessments, integrate security scanning into CI/CD pipelines, and produce actionable vulnerability reports aligned with industry standards (OWASP, NIST, CWE, CVE).

## When to Use This Skill

- Use when conducting security assessments on web applications
- Use when testing APIs for authentication, authorization, and injection flaws
- Use when setting up automated security scanning (SAST, DAST, SCA)
- Use when reviewing code for security vulnerabilities
- Use when performing mobile application security testing
- Use when writing vulnerability reports and remediation guides
- Use when integrating security gates into CI/CD pipelines
- Use when preparing for compliance audits (SOC 2, ISO 27001, PCI DSS)

---

## Part 1: Security Testing Methodology

### 1.1 Testing Phases

```
SECURITY TESTING LIFECYCLE
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Scope & │──▶│  Recon & │──▶│  Vuln.   │──▶│ Exploit  │──▶│ Report & │
│  Plan    │   │  Map     │   │ Discovery│   │ & Verify │   │ Remediate│
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
    │              │               │               │              │
  Define        Enumerate       Automated +     Prove impact   CVSS scoring
  targets       endpoints       manual testing  safely         & fix guidance
```

### 1.2 Types of Security Testing

| Type | Approach | Stage | Tools |
|------|----------|-------|-------|
| **SAST** | Static code analysis | Pre-build | Semgrep, SonarQube, CodeQL |
| **DAST** | Dynamic app scanning | Post-deploy | OWASP ZAP, Burp Suite, Nuclei |
| **SCA** | Dependency scanning | Build | Trivy, Snyk, Dependabot |
| **IAST** | Instrumented runtime | Test env | Contrast Security |
| **Manual Pentest** | Human-driven testing | Pre-release | Burp Suite, custom scripts |
| **Red Team** | Adversarial simulation | Ongoing | Custom tooling |

### 1.3 Risk-Based Prioritization

```
RISK MATRIX
              ┌──────────────────────────────────┐
              │    L I K E L I H O O D            │
              │   Low    Medium    High           │
   ┌──────────┼──────────────────────────────────┤
I  │ High     │ Medium   High     Critical       │
M  │ Medium   │ Low      Medium   High           │
P  │ Low      │ Info     Low      Medium         │
A  └──────────┴──────────────────────────────────┘
C
T
```

---

## Part 2: OWASP Top 10 Testing Guide

### 2.1 Testing Checklist per Category

```
OWASP TOP 10 (2021) — SECURITY TESTS
│
├── A01: BROKEN ACCESS CONTROL
│   ├── Test IDOR: change IDs in URLs / params
│   ├── Test vertical escalation: access admin URLs
│   ├── Test horizontal escalation: access other users
│   ├── Test forced browsing: /admin, /debug, /api-docs
│   ├── Test method tampering: GET → PUT/DELETE
│   └── Test CORS misconfiguration
│
├── A02: CRYPTOGRAPHIC FAILURES
│   ├── Check TLS version (must be ≥ 1.2)
│   ├── Check certificate validity & chain
│   ├── Verify passwords are hashed (bcrypt/Argon2)
│   ├── Check for sensitive data in URLs / logs
│   └── Verify encryption at rest for PII
│
├── A03: INJECTION
│   ├── SQL Injection (string, numeric, blind)
│   ├── NoSQL Injection (MongoDB operators)
│   ├── Command Injection (OS commands)
│   ├── LDAP Injection
│   ├── XSS (Reflected, Stored, DOM-based)
│   └── Template Injection (SSTI)
│
├── A04: INSECURE DESIGN
│   ├── Review threat model coverage
│   ├── Check business logic flaws
│   ├── Test rate limiting on critical flows
│   └── Test account enumeration via error msgs
│
├── A05: SECURITY MISCONFIGURATION
│   ├── Check default credentials
│   ├── Check unnecessary HTTP methods
│   ├── Check verbose error messages / stack traces
│   ├── Check security headers (CSP, HSTS, X-Frame)
│   └── Check directory listing enabled
│
├── A06: VULNERABLE COMPONENTS
│   ├── Run SCA scan (Trivy / Snyk)
│   ├── Check CVE databases for known vulns
│   ├── Verify component versions are current
│   └── Check for abandoned dependencies
│
├── A07: AUTH & SESSION FAILURES
│   ├── Test brute force protection
│   ├── Test session fixation
│   ├── Test session timeout / expiry
│   ├── Test token rotation after login
│   ├── Test "Remember Me" security
│   └── Test MFA bypass
│
├── A08: DATA INTEGRITY FAILURES
│   ├── Test insecure deserialization
│   ├── Check CI/CD pipeline integrity
│   ├── Verify software update signatures
│   └── Test JWT manipulation (alg:none, key confusion)
│
├── A09: LOGGING & MONITORING
│   ├── Verify security events are logged
│   ├── Check log injection vulnerabilities
│   ├── Verify alerts for suspicious activity
│   └── Check log data doesn't contain secrets
│
└── A10: SSRF (Server-Side Request Forgery)
    ├── Test internal IP access (127.0.0.1, 169.254.x)
    ├── Test cloud metadata endpoints
    ├── Test URL scheme manipulation (file://, gopher://)
    └── Test DNS rebinding
```

### 2.2 Quick Injection Tests

```bash
# SQL Injection payloads
' OR '1'='1
' OR '1'='1' --
' UNION SELECT NULL, table_name FROM information_schema.tables--
1; DROP TABLE users--

# XSS payloads
<script>alert(document.domain)</script>
<img src=x onerror=alert(1)>
"><svg/onload=alert(1)>
javascript:alert(document.cookie)

# Command Injection payloads
; ls -la
| cat /etc/passwd
$(whoami)
`id`

# SSRF payloads
http://127.0.0.1:22
http://169.254.169.254/latest/meta-data/
http://[::1]/
```

---

## Part 3: Web Application Security Testing

### 3.1 Authentication Testing

```
AUTH TESTING CHECKLIST
├── CREDENTIAL HANDLING
│   ├── Login over HTTPS only
│   ├── Password complexity enforced
│   ├── No password in URL query params
│   ├── Passwords masked in forms
│   └── Secure password reset flow
│
├── BRUTE FORCE PROTECTION
│   ├── Account lockout after N failures
│   ├── CAPTCHA on repeated failures
│   ├── Rate limiting on /login endpoint
│   └── No account enumeration via timing
│
├── SESSION MANAGEMENT
│   ├── Session ID length ≥ 128 bits
│   ├── Session ID rotated on login
│   ├── Session expires on logout
│   ├── Session timeout (idle: 15 min)
│   ├── Secure + HttpOnly + SameSite flags
│   └── No session ID in URLs
│
├── TOKEN SECURITY (JWT)
│   ├── Strong signing algorithm (RS256/ES256)
│   ├── Short expiry (15 min access, 7d refresh)
│   ├── Token revocation mechanism
│   ├── No sensitive data in payload
│   └── Signature validated server-side
│
└── MFA
    ├── TOTP / hardware key supported
    ├── Recovery codes stored securely
    ├── MFA required for sensitive actions
    └── MFA bypass not possible
```

### 3.2 Authorization Testing

```
AUTHORIZATION TESTS
├── VERTICAL (Privilege Escalation)
│   ├── Regular user → admin endpoint
│   ├── Guest → authenticated endpoint
│   └── Low-role → high-role actions
│
├── HORIZONTAL (IDOR)
│   ├── /api/users/123 → /api/users/124
│   ├── /orders/{id} with other user's order
│   └── File download with other user's filename
│
├── CONTEXT-BASED
│   ├── Cross-tenant access in multi-tenant apps
│   ├── Access after account deactivation
│   └── Access from restricted geography (if applicable)
│
└── BUSINESS LOGIC
    ├── Skip steps in multi-step workflows
    ├── Negative quantity / price manipulation
    ├── Replay transactions
    └── Race condition on balance / stock
```

### 3.3 Burp Suite Workflow

```
BURP SUITE TESTING FLOW
1. Configure browser proxy → 127.0.0.1:8080
2. Crawl / Spider the application
3. Review Sitemap for endpoints
4. Manual testing via Repeater
   ├── Modify parameters
   ├── Change HTTP methods
   ├── Manipulate headers (Host, Origin, Referer)
   └── Test auth tokens
5. Fuzzing via Intruder
   ├── Parameter wordlists
   ├── Directory brute force
   └── Payload injection
6. Active / Passive scanner
7. Document findings with screenshots
```

---

## Part 4: API Security Testing

### 4.1 API-Specific Vulnerability Checklist

```
API SECURITY (OWASP API Top 10)
├── API1: BROKEN OBJECT LEVEL AUTH (BOLA)
│   ├── Change resource IDs in requests
│   ├── Access other users' objects
│   └── Test with different API keys / tokens
│
├── API2: BROKEN AUTHENTICATION
│   ├── Test weak API keys
│   ├── Test token expiration
│   ├── Test missing auth on endpoints
│   └── Test credential stuffing
│
├── API3: BROKEN OBJECT PROPERTY LEVEL AUTH
│   ├── Mass assignment attacks
│   ├── Include admin fields in PUT/PATCH
│   └── Read sensitive fields in responses
│
├── API4: UNRESTRICTED RESOURCE CONSUMPTION
│   ├── No rate limiting
│   ├── Large payloads accepted
│   ├── Missing pagination limits
│   └── Resource-intensive queries (GraphQL depth)
│
├── API5: BROKEN FUNCTION LEVEL AUTH
│   ├── Access admin endpoints as regular user
│   ├── Change HTTP method to bypass controls
│   └── Test undocumented/debug endpoints
│
├── API6: UNRESTRICTED ACCESS TO SENSITIVE FLOWS
│   ├── Automated purchase flows
│   ├── Comment/review spam
│   └── Account creation abuse
│
├── API7: SERVER-SIDE REQUEST FORGERY (SSRF)
│   ├── URL parameters pointing to internal services
│   ├── Webhook URLs to internal IPs
│   └── File import from external URLs
│
├── API8: SECURITY MISCONFIGURATION
│   ├── Verbose error messages
│   ├── Open CORS (Access-Control-Allow-Origin: *)
│   ├── Unnecessary HTTP methods enabled
│   └── Missing TLS / weak ciphers
│
├── API9: IMPROPER INVENTORY MANAGEMENT
│   ├── Old API versions still accessible
│   ├── Undocumented / shadow endpoints
│   └── Test /v1, /v2, /api, /graphql paths
│
└── API10: UNSAFE CONSUMPTION OF APIs
    ├── Third-party API data not validated
    ├── Redirect URLs not whitelisted
    └── Webhook payloads not verified
```

### 4.2 API Testing with cURL

```bash
# Test BOLA (change user ID)
curl -H "Authorization: Bearer $TOKEN" \
  https://api.example.com/users/OTHER_USER_ID

# Test missing auth
curl https://api.example.com/admin/users

# Test mass assignment
curl -X PATCH \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "admin", "is_verified": true}' \
  https://api.example.com/users/me

# Test rate limiting
for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{http_code}\n" \
    https://api.example.com/login \
    -d '{"email":"test@test.com","pass":"wrong"}'
done

# Test CORS
curl -H "Origin: https://evil.com" \
  -I https://api.example.com/data
```

---

## Part 5: Automated Security Scanning

### 5.1 SAST (Static Analysis)

```bash
# Semgrep — lightweight, fast, custom rules
semgrep --config=p/owasp-top-ten .
semgrep --config=p/security-audit .
semgrep --config=p/secrets .

# CodeQL — deep semantic analysis (GitHub)
codeql database create mydb --language=javascript
codeql database analyze mydb codeql/javascript-queries:Security
```

### 5.2 DAST (Dynamic Scanning)

```bash
# OWASP ZAP — baseline scan
docker run -t owasp/zap2docker-stable \
  zap-baseline.py -t https://staging.example.com \
  -r report.html

# OWASP ZAP — full scan
docker run -t owasp/zap2docker-stable \
  zap-full-scan.py -t https://staging.example.com \
  -r full-report.html

# Nuclei — template-based vulnerability scanning
nuclei -u https://staging.example.com \
  -t cves/ -t vulnerabilities/ -t exposures/ \
  -severity critical,high \
  -o nuclei-results.txt
```

### 5.3 SCA (Dependency Scanning)

```bash
# Trivy — scan filesystem for vulnerable dependencies
trivy fs . --severity CRITICAL,HIGH

# Trivy — scan container image
trivy image myapp:latest --severity CRITICAL,HIGH

# Snyk — test and monitor
snyk test
snyk monitor

# npm audit
npm audit --audit-level=high
```

### 5.4 Secret Detection

```bash
# TruffleHog — scan Git history
trufflehog git https://github.com/org/repo.git

# Gitleaks — fast secret scanner
gitleaks detect --source . --report-format json

# Custom regex patterns to detect
# AWS keys, API tokens, DB passwords, private keys
```

---

## Part 6: Mobile Application Security Testing

### 6.1 OWASP Mobile Top 10 Testing

```
MOBILE SECURITY TESTS
├── M1: IMPROPER CREDENTIAL USAGE
│   ├── Hardcoded credentials in app binary
│   ├── API keys in plaintext
│   └── Default credentials
│
├── M2: INADEQUATE SUPPLY CHAIN SECURITY
│   ├── Vulnerable third-party SDKs
│   ├── Untrusted repositories
│   └── Unsigned libraries
│
├── M3: INSECURE AUTH / AUTHZ
│   ├── Client-side auth bypass
│   ├── Token stored insecurely
│   └── Missing server-side validation
│
├── M4: INSUFFICIENT INPUT/OUTPUT VALIDATION
│   ├── SQL injection via mobile inputs
│   ├── Path traversal
│   └── Webview injection (XSS)
│
├── M5: INSECURE COMMUNICATION
│   ├── Missing or weak TLS
│   ├── Certificate pinning bypass
│   └── Sensitive data in HTTP traffic
│
├── M6: INADEQUATE PRIVACY CONTROLS
│   ├── Excessive permissions
│   ├── PII in logs / analytics
│   └── Location data leakage
│
├── M7: INSUFFICIENT BINARY PROTECTIONS
│   ├── No obfuscation
│   ├── Tampering detection absent
│   └── Debugging enabled in release
│
├── M8: SECURITY MISCONFIGURATION
│   ├── Debug mode enabled
│   ├── Backup allowed (android:allowBackup)
│   ├── Export unprotected components
│   └── Weak WebView settings
│
├── M9: INSECURE DATA STORAGE
│   ├── SharedPreferences / NSUserDefaults for secrets
│   ├── SQLite with plaintext sensitive data
│   ├── Plaintext files on external storage
│   └── Clipboard data leakage
│
└── M10: INSUFFICIENT CRYPTOGRAPHY
    ├── Weak algorithms (MD5, SHA1, DES)
    ├── Hardcoded encryption keys
    ├── Insufficient key length
    └── Predictable random values
```

### 6.2 Mobile Testing Tools

| Tool | Platform | Purpose |
|------|----------|---------|
| **MobSF** | Both | Automated static + dynamic analysis |
| **Frida** | Both | Runtime instrumentation, bypass |
| **Objection** | Both | Runtime analysis, hook methods |
| **apktool** | Android | Decompile / recompile APK |
| **jadx** | Android | Decompile to Java source |
| **Hopper** | iOS | Disassembler |
| **Burp Suite** | Both | MITM proxy for traffic analysis |

---

## Part 7: CI/CD Security Integration

### 7.1 Security Pipeline Architecture

```
SECURE CI/CD PIPELINE
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  Commit  │─▶│  Build   │─▶│  Test    │─▶│  Stage   │─▶│  Deploy  │
└──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘
     │             │              │              │              │
  Secrets       SAST           Unit +        DAST          Compliance
  scanning      SCA            IAST          Pentest       monitoring
  (pre-commit)  (build time)   (test env)    (staging)     (prod)
```

### 7.2 GitHub Actions Security Pipeline

```yaml
name: Security Pipeline

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Secret scanning
      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2

      # SAST
      - name: Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/security-audit

      # SCA — Dependency scanning
      - name: Trivy FS Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      # Container scanning
      - name: Trivy Image Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ env.IMAGE }}'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      # DAST (on staging)
      - name: ZAP Baseline
        uses: zaproxy/action-baseline@v0.14.0
        with:
          target: 'https://staging.example.com'
```

### 7.3 Quality Gate Thresholds

| Gate | Threshold | Action |
|------|-----------|--------|
| **SAST findings** | 0 Critical / High | Block merge |
| **SCA vulnerabilities** | 0 Critical | Block deploy |
| **Secret detection** | 0 findings | Block commit |
| **DAST scan** | 0 Critical / High | Block release |
| **Container CVEs** | 0 Critical | Block image push |
| **License compliance** | No copyleft violations | Warning |

---

## Part 8: Vulnerability Reporting

### 8.1 Vulnerability Report Template

```markdown
## Vulnerability: [Title — e.g., SQL Injection in User Search]

**ID:** VULN-2024-001
**Severity:** Critical | High | Medium | Low | Informational
**CVSS Score:** 9.1 (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N)
**CWE:** CWE-89 (SQL Injection)
**Status:** Open | In Progress | Fixed | Verified

### Description
Brief explanation of the vulnerability and its context.

### Affected Component
- URL: `POST /api/users/search`
- Parameter: `query`
- Version: v2.3.1

### Steps to Reproduce
1. Authenticate as any user
2. Send POST to `/api/users/search`
3. Set body: `{"query": "' OR '1'='1"}`
4. Observe: all user records returned

### Impact
- Full database read access
- Potential data exfiltration of PII
- May lead to RCE via stacked queries

### Evidence
- Request / Response screenshot
- cURL command: `curl -X POST ...`
- SQLMap output confirming injection

### Remediation
1. Use parameterized queries / prepared statements
2. Implement input validation (alphanumeric only)
3. Apply WAF rule as short-term mitigation
4. Add SQL injection unit tests

### References
- OWASP: https://owasp.org/Top10/A03_2021-Injection/
- CWE-89: https://cwe.mitre.org/data/definitions/89.html
```

### 8.2 CVSS v3.1 Scoring Quick Reference

| Metric | Values |
|--------|--------|
| **Attack Vector** | Network (0.85) > Adjacent (0.62) > Local (0.55) > Physical (0.20) |
| **Attack Complexity** | Low (0.77) > High (0.44) |
| **Privileges Required** | None (0.85) > Low (0.62) > High (0.27) |
| **User Interaction** | None (0.85) > Required (0.62) |
| **Scope** | Changed > Unchanged |
| **CIA Impact** | High (0.56) > Low (0.22) > None (0) |

| Score Range | Severity |
|-------------|----------|
| 9.0 – 10.0 | **Critical** |
| 7.0 – 8.9 | **High** |
| 4.0 – 6.9 | **Medium** |
| 0.1 – 3.9 | **Low** |
| 0.0 | **Informational** |

---

## Part 9: Security Testing Tools Reference

### 9.1 Complete Toolbox

| Category | Tool | Purpose |
|----------|------|---------|
| **Proxy** | Burp Suite, OWASP ZAP | Intercept & modify traffic |
| **SAST** | Semgrep, SonarQube, CodeQL | Static code analysis |
| **DAST** | ZAP, Nuclei, Nikto | Runtime vulnerability scan |
| **SCA** | Trivy, Snyk, npm audit | Dependency vulnerabilities |
| **Secrets** | Gitleaks, TruffleHog | Hardcoded secrets in code |
| **Fuzzing** | ffuf, wfuzz, Burp Intruder | Directory / parameter fuzz |
| **Recon** | subfinder, nmap, httpx | Asset discovery |
| **Container** | Trivy, Grype, Docker Scout | Image vulnerability scan |
| **Mobile** | MobSF, Frida, Objection | Mobile app analysis |
| **IaC** | checkov, tfsec, KICS | Infrastructure code scan |
| **SSL/TLS** | testssl.sh, sslyze | TLS configuration audit |
| **Headers** | securityheaders.com, Mozilla Observatory | HTTP header analysis |

### 9.2 One-Liner Commands

```bash
# Quick TLS check
testssl.sh https://example.com

# Security headers check
curl -sI https://example.com | grep -iE \
  "strict-transport|content-security|x-frame|x-content-type"

# Find exposed endpoints
ffuf -u https://example.com/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -mc 200,301,302,403

# Subdomain enumeration
subfinder -d example.com -silent | httpx -silent

# Check for known CVEs in dependencies
trivy fs . --severity CRITICAL,HIGH --format table
```

---

## Best Practices

### ✅ Do This

- ✅ Always get written authorization before testing
- ✅ Shift left — integrate security scanning early in SDLC
- ✅ Test both authenticated and unauthenticated contexts
- ✅ Use risk-based approach — focus on critical assets first
- ✅ Document every finding with reproducible steps
- ✅ Verify fixes, don't just trust "it's deployed"
- ✅ Keep tools and vulnerability databases updated
- ✅ Use `data-testid` / stable selectors in security automation
- ✅ Combine automated scanning + manual testing
- ✅ Test business logic flaws (automation can't catch these)
- ✅ Report vulnerabilities with clear CVSS and remediation
- ✅ Run regression security tests after fixes

### ❌ Avoid This

- ❌ Don't test in production without explicit approval
- ❌ Don't rely solely on automated scanners — they miss logic bugs
- ❌ Don't exfiltrate real user data — demonstrate access only
- ❌ Don't ignore low-severity findings — they chain into critical
- ❌ Don't skip mobile / API testing — only testing the web UI is not enough
- ❌ Don't use outdated scanning tools or signatures
- ❌ Don't forget to test third-party integrations
- ❌ Don't suppress scanner findings without triaging first

---

## Security Assessment Checklist

```markdown
### Pre-Assessment
- [ ] Scope defined and signed off
- [ ] Authorization document obtained
- [ ] Test environment provisioned
- [ ] Test accounts / credentials provided
- [ ] Emergency contacts documented
- [ ] Tools configured and updated

### Assessment Execution
- [ ] SAST scan completed (0 critical)
- [ ] SCA scan completed (0 critical CVEs)
- [ ] Secret detection scan clean
- [ ] DAST scan completed on staging
- [ ] Authentication testing completed
- [ ] Authorization / IDOR testing completed
- [ ] Injection testing completed (SQLi, XSS, SSRF)
- [ ] Business logic testing completed
- [ ] API security testing completed
- [ ] Security headers validated
- [ ] TLS configuration audited

### Post-Assessment
- [ ] All findings documented with CVSS scores
- [ ] Remediation guidance provided
- [ ] Executive summary prepared
- [ ] Findings presented to stakeholders
- [ ] Retest scheduled after fixes
- [ ] Security regression tests added to CI
```

---

## Related Skills

- `@senior-cybersecurity-engineer` - Security architecture and design
- `@devsecops-specialist` - CI/CD security integration
- `@senior-penetration-tester` - Advanced offensive security
- `@senior-api-security-specialist` - API security deep dive
- `@mobile-security-tester` - Mobile app security
- `@network-security-specialist` - Network-level security
- `@senior-quality-assurance-engineer` - QA testing strategy
