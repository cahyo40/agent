---
name: mobile-security-tester
description: "Expert mobile application security testing including iOS and Android penetration testing, reverse engineering, and vulnerability assessment"
---

# Mobile Security Tester

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis mobile application security testing. Agent akan mampu melakukan penetration testing pada aplikasi iOS dan Android, reverse engineering APK/IPA, bypass security controls, dan mengidentifikasi vulnerability di mobile apps.

## When to Use This Skill

- Use when conducting security testing on mobile applications
- Use when reverse engineering Android APK or iOS IPA files
- Use when the user asks about mobile app vulnerabilities
- Use when bypassing SSL pinning or root/jailbreak detection
- Use when assessing mobile app data storage security

## How It Works

### Step 1: Mobile Security Testing Methodology

```text
┌─────────────────────────────────────────────────────────┐
│            OWASP MOBILE TOP 10 (2024)                   │
├─────────────────────────────────────────────────────────┤
│ M1  - Improper Credential Usage                         │
│ M2  - Inadequate Supply Chain Security                  │
│ M3  - Insecure Authentication/Authorization             │
│ M4  - Insufficient Input/Output Validation              │
│ M5  - Insecure Communication                            │
│ M6  - Inadequate Privacy Controls                       │
│ M7  - Insufficient Binary Protections                   │
│ M8  - Security Misconfiguration                         │
│ M9  - Insecure Data Storage                             │
│ M10 - Insufficient Cryptography                         │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Android Security Testing

#### Static Analysis

```bash
# Decompile APK
apktool d app.apk -o app_decompiled

# Extract Java source (jadx)
jadx app.apk -d app_source

# Check AndroidManifest.xml
cat app_decompiled/AndroidManifest.xml

# Look for sensitive info
grep -r "api_key\|password\|secret\|token" app_source/
grep -r "http://" app_source/  # Insecure HTTP
grep -r "MODE_WORLD_READABLE\|MODE_WORLD_WRITEABLE" app_source/

# Check for debugging enabled
grep "android:debuggable" app_decompiled/AndroidManifest.xml

# Check for backup allowed
grep "android:allowBackup" app_decompiled/AndroidManifest.xml
```

#### Dynamic Analysis with Frida

```javascript
// frida_scripts/bypass_root_detection.js
Java.perform(function() {
    // Bypass RootBeer library
    var RootBeer = Java.use("com.scottyab.rootbeer.RootBeer");
    RootBeer.isRooted.overload().implementation = function() {
        console.log("[*] RootBeer.isRooted() bypassed");
        return false;
    };
    
    // Bypass common root checks
    var Runtime = Java.use("java.lang.Runtime");
    Runtime.exec.overload('java.lang.String').implementation = function(cmd) {
        if (cmd.indexOf("su") !== -1 || cmd.indexOf("busybox") !== -1) {
            console.log("[*] Blocked root check command: " + cmd);
            throw new Error("Command not found");
        }
        return this.exec(cmd);
    };
});
```

```bash
# Run Frida script
frida -U -l bypass_root_detection.js -f com.target.app --no-pause

# SSL Pinning Bypass
frida -U -l ssl_pinning_bypass.js -f com.target.app --no-pause
```

#### SSL Pinning Bypass

```javascript
// frida_scripts/ssl_pinning_bypass.js
Java.perform(function() {
    // OkHttp CertificatePinner bypass
    var CertificatePinner = Java.use("okhttp3.CertificatePinner");
    CertificatePinner.check.overload('java.lang.String', 'java.util.List')
        .implementation = function(hostname, peerCertificates) {
        console.log("[*] OkHttp SSL Pinning bypassed for: " + hostname);
        return;
    };
    
    // TrustManagerImpl bypass
    var TrustManagerImpl = Java.use("com.android.org.conscrypt.TrustManagerImpl");
    TrustManagerImpl.verifyChain.implementation = function() {
        console.log("[*] TrustManagerImpl.verifyChain bypassed");
        return arguments[0];
    };
});
```

### Step 3: iOS Security Testing

#### Static Analysis

```bash
# Extract IPA
unzip app.ipa -d app_extracted

# Check Info.plist
plutil -p app_extracted/Payload/App.app/Info.plist

# Check for insecure configurations
grep -r "NSAllowsArbitraryLoads" app_extracted/
grep -r "NSExceptionDomains" app_extracted/

# Dump strings from binary
strings app_extracted/Payload/App.app/App | grep -E "(password|secret|api|key|token)"

# Check entitlements
codesign -d --entitlements :- app_extracted/Payload/App.app

# Class dump (for Objective-C)
class-dump app_extracted/Payload/App.app/App > class_dump.txt
```

#### Dynamic Analysis with Frida

```javascript
// frida_scripts/ios_bypass.js
// Bypass jailbreak detection
var resolver = new ApiResolver('objc');
resolver.enumerateMatches('-[* isJailbroken*]', {
    onMatch: function(match) {
        Interceptor.attach(match.address, {
            onLeave: function(retval) {
                console.log("[*] Jailbreak detection bypassed");
                retval.replace(0);
            }
        });
    },
    onComplete: function() {}
});

// Bypass SSL Pinning (iOS)
var sslSetPeerDomainName = Module.findExportByName(null, "SSLSetPeerDomainName");
Interceptor.replace(sslSetPeerDomainName, new NativeCallback(function(context, peerName, peerNameLen) {
    console.log("[*] SSLSetPeerDomainName bypassed");
    return 0;
}, 'int', ['pointer', 'pointer', 'uint']));
```

### Step 4: Common Vulnerabilities

```text
Data Storage Issues:
├── SharedPreferences (Android) - Cleartext storage
├── SQLite databases - Unencrypted
├── Keychain (iOS) - Improper protection class
├── Backup files - Sensitive data in backups
└── Logs - Sensitive data in logs

Authentication Issues:
├── Weak password policies
├── Biometric bypass
├── Session management flaws
├── Insecure "Remember Me"
└── OAuth/SSO implementation bugs

Network Issues:
├── Missing SSL/TLS
├── Weak SSL pinning
├── Certificate validation bypass
├── Man-in-the-middle vulnerabilities
└── WebSocket security
```

### Step 5: Essential Tools

| Category | Android | iOS |
|----------|---------|-----|
| Decompiler | jadx, apktool | class-dump, Hopper |
| Dynamic | Frida, Objection | Frida, Objection |
| Proxy | Burp Suite, mitmproxy | Burp Suite, Charles |
| Emulator | Genymotion, Android Studio | Corellium, Simulator |
| Analysis | MobSF, drozer | MobSF, iMazing |

### Step 6: Testing Checklist

```yaml
Android Checklist:
  Static Analysis:
    - [ ] Decompile APK and review source
    - [ ] Check AndroidManifest.xml for misconfigurations
    - [ ] Search for hardcoded secrets
    - [ ] Analyze third-party libraries
  
  Dynamic Analysis:
    - [ ] Bypass root detection
    - [ ] Bypass SSL pinning
    - [ ] Intercept network traffic
    - [ ] Test authentication flows
    - [ ] Check data storage (SharedPrefs, SQLite)
    - [ ] Test deep links and intents

iOS Checklist:
  Static Analysis:
    - [ ] Extract and analyze IPA
    - [ ] Check Info.plist for ATS exceptions
    - [ ] Dump and analyze binary
    - [ ] Check entitlements
  
  Dynamic Analysis:
    - [ ] Bypass jailbreak detection
    - [ ] Bypass SSL pinning
    - [ ] Intercept network traffic
    - [ ] Check Keychain storage
    - [ ] Test biometric authentication bypass
```

## Best Practices

### ✅ Do This

- ✅ Test on both rooted/jailbroken and stock devices
- ✅ Use automated tools (MobSF) first, then manual testing
- ✅ Document all findings with clear reproduction steps
- ✅ Test all API endpoints discovered in the app
- ✅ Check both debug and release builds

### ❌ Avoid This

- ❌ Don't skip static analysis before dynamic
- ❌ Don't test only on emulators—use real devices
- ❌ Don't ignore third-party SDK vulnerabilities
- ❌ Don't forget to test offline functionality
- ❌ Never test on production accounts without permission

## Common Pitfalls

**Problem:** Frida crashes the app on injection
**Solution:** Try using `--pause` flag, check Frida version compatibility, or use spawn instead of attach.

**Problem:** SSL pinning bypass not working
**Solution:** App may use multiple pinning methods. Try universal bypass scripts or identify the specific library used.

## Related Skills

- `@senior-android-developer` - Understanding Android internals
- `@senior-ios-developer` - Understanding iOS internals
- `@senior-penetration-tester` - General pen testing methodology
- `@senior-api-security-specialist` - API vulnerability testing
- `@network-security-specialist` - Traffic analysis
