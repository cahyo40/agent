---
name: ansible-specialist
description: "Expert configuration management and automation with Ansible including playbooks, roles, inventories, and Ansible Vault"
---

# Ansible Specialist

## Overview

This skill transforms you into an **Ansible Automation Expert**. You will move beyond simple playbooks to building modular, reusable **Roles**, managing complex environments with **Dynamic Inventories**, securing secrets with **Ansible Vault**, and optimizing execution with modern strategies (Mitogen/Pipelining).

## When to Use This Skill

- Use when configuring servers (Application deployment, OS hardening)
- Use when automating infrastructure bootstrapping
- Use when managing configuration drift
- Use when orchestrating complex rolling updates
- Use when auditing system compliance (CIS Benchmarks)

---

## Part 1: Project Structure Best Practices

A production-ready Ansible repository is structured for reuse and clarity.

```text
ansible/
├── ansible.cfg              # Global configuration
├── inventories/             # Environment-specific inventories
│   ├── production/
│   │   ├── hosts.ini        # Or dynamic inventory script
│   │   ├── group_vars/      # Variables for groups (e.g., db_servers)
│   │   └── host_vars/       # Variables for specific hosts
│   └── staging/
├── playbooks/               # Top-level playbooks
│   ├── site.yml             # Main entry point
│   ├── webservers.yml
│   └── dbservers.yml
├── roles/                   # Reusable logic
│   ├── common/              # Base config (users, SSH, NTP)
│   ├── nginx/
│   └── postgresql/
└── requirements.yml         # Galaxy dependencies
```

### 1.1 `ansible.cfg` Optimization

```ini
[defaults]
inventory = ./inventories/production
roles_path = ./roles
host_key_checking = False
retry_files_enabled = False
forks = 20                   # Parallelism (default 5 is too low)
pipelining = True            # Critical for speed (reduces SSH connections)
callbacks_enabled = timer, profile_tasks # Metrics

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

---

## Part 2: Advanced Role Development

Roles are the building blocks of maintainable Ansible.

```yaml
# roles/nginx/tasks/main.yml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes
  register: nginx_install

- name: Configure Nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    validate: 'nginx -t -c %s' # Validate config BEFORE restarting
  notify: Restart Nginx

- name: Enable Nginx Service
  systemd:
    name: nginx
    enabled: yes
    state: started

# roles/nginx/handlers/main.yml
---
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

---

## Part 3: Variables & Vault Security

Never commit secrets to Git. Use Ansible Vault.

### 3.1 Variable Precedence (Simplified)

1. Extra vars (`-e`) - Highest
2. Host vars
3. Group vars
4. Role defaults - Lowest

### 3.2 Using Vault

```bash
# Encrypt a file
ansible-vault encrypt inventories/production/group_vars/all/secrets.yml

# Edit encrypted file
ansible-vault edit inventories/production/group_vars/all/secrets.yml
```

**Using Secrets in Playbooks:**

```yaml
# secrets.yml (Encrypted)
db_password: "supersecretpassword"

# tasks/main.yml
- name: Configure App
  template:
    src: app.conf.j2
    dest: /etc/app/config.json
  vars:
    database_password: "{{ db_password }}"
```

---

## Part 4: Advanced Patterns

### 4.1 Rolling Updates (Zero Downtime)

```yaml
- name: Deploy Web App
  hosts: webservers
  serial: "20%"        # Process 20% of hosts at a time
  max_fail_percentage: 10 # Stop if >10% fail
  
  tasks:
    - name: Disable from Load Balancer
      haproxy:
        state: disabled
        host: "{{ inventory_hostname }}"
        backend: web_back
      delegate_to: status_lb
      
    - name: Update Application
      git:
        repo: git@github.com:org/app.git
        dest: /var/www/app
        version: release-1.0
        
    - name: Restart Service
      service: name=app state=restarted
      
    - name: Enable in Load Balancer
      haproxy:
        state: enabled
        host: "{{ inventory_hostname }}"
        backend: web_back
      delegate_to: status_lb
```

### 4.2 Error Handling (Blocks)

```yaml
- block:
    - name: Dangerous Operation
      command: /opt/upgrade_db.sh
      
  rescue:
    - name: Rollback DB
      command: /opt/restore_db.sh
      
    - name: Alert Team
      slack:
        token: "{{ slack_token }}"
        msg: "DB Upgrade Failed on {{ inventory_hostname }}"
        
  always:
    - name: Cleanup Temp Files
      file:
        path: /tmp/upgrade
        state: absent
```

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Use Roles**: Don't put everything in one huge playbook.
- ✅ **Validate Configs**: Use `validate` parameter in `template` module to check syntax before saving.
- ✅ **Check Mode**: Run with `--check` (dry-run) often. Use `check_mode: no` for read-only tasks that *must* run even in check mode.
- ✅ **Idempotency**: Ensure tasks can run multiple times without changing the result if already correct.
- ✅ **Tagging**: Tag tasks (`tags: [deploy, config]`) to run subsets of logic.

### ❌ Avoid This

- ❌ **`command` / `shell` Abuse**: Only use them if no native module exists (e.g., use `apt`, `user`, `git` modules).
- ❌ **Complex Logic in Jinja2**: Keep templating logic simple. Move complex logic to Python plugins/filters.
- ❌ **Hardcoded Paths**: Use variables (`{{ nginx_conf_dir }}`) instead of literal strings.
- ❌ **Ignoring Errors**: Don't use `ignore_errors: yes` unless you explicitly handle the failure downstream.

---

## Related Skills

- `@senior-linux-sysadmin` - Target system knowledge
- `@terraform-specialist` - Infrastructure provisioning (Pre-Ansible)
- `@github-actions-specialist` - Running Ansible in CI/CD
