---
name: ctf-competitor
description: "Expert Capture The Flag competition including web exploitation, reverse engineering, cryptography, forensics, and pwn challenges"
---

# CTF Competitor

## Overview

Skill ini menjadikan AI Agent Anda sebagai spesialis CTF (Capture The Flag) competition. Agent akan mampu menyelesaikan berbagai kategori challenge: Web, Pwn (Binary Exploitation), Reverse Engineering, Cryptography, Forensics, dan OSINT dengan strategi dan tools yang tepat.

## When to Use This Skill

- Use when solving CTF challenges in competitions
- Use when practicing security skills through CTF platforms
- Use when the user asks about CTF methodology
- Use when learning reverse engineering or exploitation
- Use when analyzing binary files or cryptographic puzzles

## How It Works

### Step 1: CTF Categories

```text
┌─────────────────────────────────────────────────────────┐
│                   CTF CATEGORIES                        │
├─────────────────────────────────────────────────────────┤
│ 🌐 WEB       - SQL injection, XSS, SSTI, deserialization│
│ 🔓 CRYPTO    - RSA, AES, hashing, custom ciphers        │
│ 🔍 FORENSICS - Disk, memory, network, steganography     │
│ ⚙️ REVERSING - Binary analysis, decompilation           │
│ 💥 PWN       - Buffer overflow, ROP, heap exploitation  │
│ 🌍 OSINT     - Open source intelligence gathering       │
│ 🧩 MISC      - Programming, trivia, unconventional      │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Essential Tools

#### Web Challenges

```bash
# Burp Suite for request manipulation
# SQLMap for SQL injection
sqlmap -u "http://target.com/page?id=1" --dbs

# SSTI detection
{{7*7}}  # If returns 49, SSTI confirmed
${7*7}   # Alternative syntax
```

#### Crypto Challenges

```python
# RSA with small e (common CTF scenario)
from Crypto.Util.number import long_to_bytes
import gmpy2

# If e=3 and c < n, try cube root
m = gmpy2.iroot(c, 3)[0]
print(long_to_bytes(m))

# Frequency analysis for substitution cipher
from collections import Counter
freq = Counter(ciphertext)
```

#### Forensics Challenges

```bash
# File identification
file mystery_file
binwalk mystery_file

# Extract hidden files
binwalk -e mystery_file
foremost -i mystery_file

# Steganography
steghide extract -sf image.jpg
zsteg image.png
strings image.jpg | grep -i flag

# Memory forensics
volatility -f memory.dmp imageinfo
volatility -f memory.dmp --profile=Win7SP1x64 pslist
```

#### Reverse Engineering

```bash
# Static analysis
strings binary
objdump -d binary
ghidra binary  # GUI decompiler

# Dynamic analysis
ltrace ./binary
strace ./binary
gdb ./binary
```

#### Binary Exploitation (Pwn)

```python
from pwn import *

# Connect to challenge
p = remote('challenge.ctf.com', 1337)

# Buffer overflow payload
payload = b'A' * offset
payload += p64(win_function_addr)

p.sendline(payload)
p.interactive()
```

### Step 3: Common Patterns

| Category | Common Pattern | Solution Approach |
|----------|----------------|-------------------|
| Web | robots.txt, .git exposed | Check for hidden files |
| Crypto | RSA small e | Cube root attack |
| Forensics | PNG with extra data | binwalk extraction |
| Reversing | strcmp with flag | Strings or debug |
| Pwn | gets() function | Buffer overflow |

### Step 4: CTF Platforms for Practice

```text
Beginner:
├── PicoCTF (https://picoctf.org)
├── OverTheWire (https://overthewire.org)
└── TryHackMe (https://tryhackme.com)

Intermediate:
├── HackTheBox (https://hackthebox.com)
├── Root-Me (https://root-me.org)
└── CryptoHack (https://cryptohack.org)

Advanced:
├── pwnable.kr / pwnable.tw
├── Exploit Education (https://exploit.education)
└── CTFtime (https://ctftime.org) - Live competitions
```

## Best Practices

### ✅ Do This

- ✅ Read the challenge description carefully—hints are often there
- ✅ Check file metadata and strings first
- ✅ Keep notes and writeups of solved challenges
- ✅ Collaborate with teammates on different categories
- ✅ Automate repetitive tasks with scripts

### ❌ Avoid This

- ❌ Don't overthink—start with simple approaches
- ❌ Don't spend too long on one challenge—move on and return
- ❌ Don't ignore the obvious (check source code, robots.txt)
- ❌ Don't forget to URL decode / base64 decode flags

## Common Pitfalls

**Problem:** Stuck on a challenge
**Solution:** Take a break, check CTF Discord/IRC for hints, or try a different category.

**Problem:** Binary won't run locally
**Solution:** Check architecture (32/64-bit), use Docker or VM with same environment.

## Related Skills

- `@senior-penetration-tester` - Real-world pen testing
- `@malware-analyst` - Reverse engineering malware
- `@forensic-investigator` - Digital forensics deep dive
- `@red-team-operator` - Offensive security operations
