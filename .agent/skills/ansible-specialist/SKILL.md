---
name: ansible-specialist
description: "Expert configuration management and automation with Ansible including playbooks, roles, inventories, and Ansible Vault"
---

# Ansible Specialist

## Overview

Master configuration management and IT automation with Ansible. Leverage YAML-based playbooks, modular roles, inventories, and secure secret management with Ansible Vault.

## When to Use This Skill

- Use when automating server configuration (provisioning software)
- Use when managing large numbers of servers
- Use when deploying applications consistently
- Use when orchestrating complex IT workflows

## How It Works

### Step 1: Inventory & Ad-hoc Commands

```ini
# inventory.ini
[web]
web1.example.com
web2.example.com

[db]
db1.example.com

[prod:children]
web
db
```

```bash
# Ping all hosts
ansible all -m ping -i inventory.ini

# Run command on web group
ansible web -a "/usr/bin/uptime" -i inventory.ini

# Check disk space
ansible all -m shell -a "df -h" -i inventory.ini
```

### Step 2: Playbook Development (YAML)

```yaml
# site.yml
---
- name: Configure Web Servers
  hosts: web
  become: yes
  vars:
    http_port: 80
    max_clients: 200

  tasks:
    - name: Ensure Apache is installed
      apt:
        name: apache2
        state: present
      when: ansible_os_family == "Debian"

    - name: Copy index.html
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
        mode: '0644'
      notify: Restart Apache

  handlers:
    - name: Restart Apache
      service:
        name: apache2
        state: restarted
```

### Step 3: Roles & Modularity

```text
# Directory structure
roles/
  common/
    tasks/main.yml
    handlers/main.yml
    templates/
    vars/main.yml
```

```yaml
# tasks/main.yml
- name: Install common packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - vim
    - htop
    - git

# Using the role in a playbook
- hosts: all
  roles:
    - common
    - webserver
```

### Step 4: Security with Ansible Vault

```bash
# Create an encrypted variables file
ansible-vault create secret_vars.yml

# Edit existing vault file
ansible-vault edit secret_vars.yml

# Run playbook with vault password
ansible-playbook site.yml --ask-vault-pass

# Or use a password file
ansible-playbook site.yml --vault-password-file .vault_pass
```

## Best Practices

### ✅ Do This

- ✅ Use Roles to organize complex tasks
- ✅ Keep playbooks idempotent (running them multiple times is safe)
- ✅ Use meaningful names for every task
- ✅ Use Ansible Vault for any sensitive data
- ✅ Organize inventory by environment (staging, prod)

### ❌ Avoid This

- ❌ Don't use `command` or `shell` modules if a specific module (e.g., `apt`, `yum`, `file`) exists
- ❌ Don't put plaintext passwords in playbooks
- ❌ Don't use root where `become: yes` suffice
- ❌ Don't skip `when` blocks for OS-specific tasks

## Related Skills

- `@senior-devops-engineer` - Automation pipelines
- `@terraform-specialist` - Infrastructure as Code
- `@senior-linux-sysadmin` - System administration
