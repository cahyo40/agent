---
name: python-automation-specialist
description: "Expert Python automation including scripting, task automation, file processing, system administration, and DevOps scripting"
---

# Python Automation Specialist

## Overview

Automate tasks and workflows with Python including file processing, system administration, DevOps scripting, and desktop automation.

## When to Use This Skill

- Use when automating repetitive tasks
- Use when building automation scripts
- Use when processing files/data
- Use when system administration

## How It Works

### Step 1: File Automation

```python
import os
import shutil
from pathlib import Path
from datetime import datetime

def organize_downloads(downloads_dir: str):
    """Organize files by extension."""
    categories = {
        'Images': ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
        'Documents': ['.pdf', '.doc', '.docx', '.txt', '.xlsx'],
        'Videos': ['.mp4', '.avi', '.mkv', '.mov'],
        'Archives': ['.zip', '.rar', '.7z', '.tar.gz'],
    }
    
    for file in Path(downloads_dir).iterdir():
        if file.is_file():
            ext = file.suffix.lower()
            for category, extensions in categories.items():
                if ext in extensions:
                    dest_dir = Path(downloads_dir) / category
                    dest_dir.mkdir(exist_ok=True)
                    shutil.move(str(file), str(dest_dir / file.name))
                    print(f"Moved {file.name} to {category}")
                    break

def backup_files(source: str, dest: str):
    """Backup with timestamp."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = Path(dest) / f"backup_{timestamp}"
    shutil.copytree(source, backup_dir)
    print(f"Backup created: {backup_dir}")
```

### Step 2: Task Scheduling

```python
import schedule
import time
from datetime import datetime

def job():
    print(f"Running job at {datetime.now()}")

# Schedule tasks
schedule.every(10).minutes.do(job)
schedule.every().hour.do(job)
schedule.every().day.at("10:30").do(job)
schedule.every().monday.at("09:00").do(job)

while True:
    schedule.run_pending()
    time.sleep(1)
```

### Step 3: System Administration

```python
import subprocess
import psutil
import platform

def get_system_info():
    """Get system information."""
    return {
        'os': platform.system(),
        'cpu_percent': psutil.cpu_percent(interval=1),
        'memory': psutil.virtual_memory()._asdict(),
        'disk': psutil.disk_usage('/')._asdict(),
    }

def run_command(cmd: str) -> tuple[str, str, int]:
    """Run shell command safely."""
    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True,
        timeout=60
    )
    return result.stdout, result.stderr, result.returncode

def monitor_process(name: str):
    """Monitor process by name."""
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent']):
        if name.lower() in proc.info['name'].lower():
            print(f"PID: {proc.info['pid']}, CPU: {proc.info['cpu_percent']}%, Memory: {proc.info['memory_percent']:.2f}%")
```

### Step 4: Email Automation

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

def send_email(
    to: str,
    subject: str,
    body: str,
    attachments: list[str] = None
):
    msg = MIMEMultipart()
    msg['From'] = 'sender@example.com'
    msg['To'] = to
    msg['Subject'] = subject
    
    msg.attach(MIMEText(body, 'html'))
    
    for file_path in attachments or []:
        with open(file_path, 'rb') as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            encoders.encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename={os.path.basename(file_path)}')
            msg.attach(part)
    
    with smtplib.SMTP('smtp.gmail.com', 587) as server:
        server.starttls()
        server.login('user', 'password')
        server.send_message(msg)
```

## Best Practices

### ✅ Do This

- ✅ Use pathlib for paths
- ✅ Add error handling
- ✅ Log automation runs
- ✅ Use argparse for CLI
- ✅ Test before deploying

### ❌ Avoid This

- ❌ Don't hardcode credentials
- ❌ Don't ignore exceptions
- ❌ Don't skip logging
- ❌ Don't run as root unnecessarily

## Related Skills

- `@senior-python-developer` - Python fundamentals
- `@senior-linux-sysadmin` - System administration
