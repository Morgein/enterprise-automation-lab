# Stage 1.3 - First Reusable Ansible Role

## 1. Purpose

This document describes Stage 1.3 of the Enterprise Automation Lab.

The goal of this stage is to move from a playbook-only Ansible structure to a reusable role-based structure.

In previous stages, baseline Linux configuration tasks were stored directly inside a playbook.

In this stage, those tasks are moved into a reusable Ansible role:

```text
ansible/roles/linux_baseline/
```

This is an important step toward cleaner and more maintainable Ansible architecture.

---

## 2. Why Roles Are Important

A playbook is useful for defining what should be applied to which hosts.

A role is useful for organizing reusable automation logic.

A clean Ansible design separates responsibilities:

```text
Playbook = orchestration
Role     = reusable configuration logic
Variables = environment-specific data
```

Instead of writing all tasks directly inside a playbook, tasks are grouped into roles.

This makes automation easier to:

- reuse
- test
- maintain
- extend
- document
- apply to multiple environments

---

## 3. Role Created in This Stage

The role created in this stage is:

```text
linux_baseline
```

Role path:

```text
ansible/roles/linux_baseline/
```

Purpose:

```text
Apply baseline Linux configuration to managed nodes.
```

The role currently performs:

- basic host information output
- apt package cache update
- baseline package installation
- SSH service validation
- hostname command validation

---

## 4. Role Directory Structure

Created structure:

```text
ansible/roles/linux_baseline/
├── defaults/
│   └── main.yml
├── handlers/
│   └── main.yml
├── meta/
│   └── main.yml
└── tasks/
    └── main.yml
```

### tasks/

Contains the main automation tasks.

### defaults/

Contains default role variables.

These can be overridden by inventory variables such as `group_vars`.

### handlers/

Contains event-driven tasks.

Handlers are usually used for restarting services after configuration changes.

### meta/

Contains role metadata such as supported platforms and dependencies.

---

## 5. Role Tasks

File:

```text
ansible/roles/linux_baseline/tasks/main.yml
```

Content:

```yaml
---
- name: Show basic host information
  ansible.builtin.debug:
    msg:
      - "Inventory hostname: {{ inventory_hostname }}"
      - "System hostname: {{ ansible_hostname }}"
      - "Distribution: {{ ansible_distribution }} {{ ansible_distribution_version }}"
      - "Kernel: {{ ansible_kernel }}"
      - "Architecture: {{ ansible_architecture }}"

- name: Update apt package cache
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: "{{ apt_cache_valid_time }}"

- name: Install baseline packages
  ansible.builtin.apt:
    name: "{{ baseline_packages }}"
    state: present

- name: Ensure SSH service is enabled and running
  ansible.builtin.service:
    name: "{{ ssh_service_name }}"
    state: started
    enabled: true

- name: Validate hostname command
  ansible.builtin.command: hostname
  register: hostname_result
  changed_when: false

- name: Show hostname command result
  ansible.builtin.debug:
    var: hostname_result.stdout
```

---

## 6. Role Defaults

File:

```text
ansible/roles/linux_baseline/defaults/main.yml
```

Content:

```yaml
---
# Default variables for the linux_baseline role.
# These values can be overridden by inventory group_vars or host_vars.

baseline_packages:
  - curl
  - wget
  - vim
  - nano
  - htop
  - net-tools
  - unzip
  - git
  - python3
  - python3-pip
  - openssh-server

ssh_service_name: ssh

apt_cache_valid_time: 3600
```

Role defaults provide fallback values.

They are useful because the role can still work even if inventory variables are missing.

---

## 7. Variable Precedence

Ansible variables have precedence.

In this project, the important order is:

```text
role defaults < inventory group_vars < host_vars < extra vars
```

This means values from:

```text
ansible/inventories/dev/group_vars/linux.yml
```

override values from:

```text
ansible/roles/linux_baseline/defaults/main.yml
```

This is useful because the role has safe defaults, while each environment can still define its own values.

---

## 8. Role Handler

File:

```text
ansible/roles/linux_baseline/handlers/main.yml
```

Content:

```yaml
---
- name: Restart SSH service
  ansible.builtin.service:
    name: "{{ ssh_service_name }}"
    state: restarted
```

The handler is not actively used yet.

It is prepared for future stages where SSH configuration may be managed by Ansible.

Example future use:

```yaml
notify: Restart SSH service
```

---

## 9. Role Metadata

File:

```text
ansible/roles/linux_baseline/meta/main.yml
```

Content:

```yaml
---
galaxy_info:
  author: Morgein
  description: Baseline Linux configuration role for the Enterprise Automation Lab
  company: Personal Lab
  license: MIT
  min_ansible_version: "2.15"

  platforms:
    - name: Ubuntu
      versions:
        - noble
        - jammy

  galaxy_tags:
    - linux
    - baseline
    - automation
    - ansible
    - infrastructure

dependencies: []
```

This file documents role metadata.

It also makes the role structure closer to standard Ansible role conventions.

---

## 10. Role-Based Playbook

A new playbook was created:

```text
ansible/playbooks/02-apply-linux-baseline.yml
```

Content:

```yaml
---
- name: Apply Linux baseline configuration
  hosts: web-01
  become: true
  gather_facts: true

  roles:
    - linux_baseline
```

This playbook is intentionally short.

It delegates actual configuration logic to the role.

---

## 11. Why This Playbook Is Cleaner

Previous playbook style:

```text
playbook contains all tasks directly
```

New playbook style:

```text
playbook selects hosts and applies roles
```

This is cleaner because the playbook becomes orchestration-focused.

The role contains reusable implementation details.

---

## 12. Validation Commands

Run from the Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible
```

Check role-based playbook syntax:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

Expected result:

```text
playbook: playbooks/02-apply-linux-baseline.yml
```

Run role-based playbook:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Expected result:

```text
unreachable=0
failed=0
```

Run it again for idempotency validation:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Expected result:

```text
changed=0
```

or fewer changes than the first run.

---

## 13. Post-Run Validation

Check package installation:

```bash
ansible web-01 -m command -a "which htop"
```

Expected result:

```text
/usr/bin/htop
```

Check SSH service enabled state:

```bash
ansible web-01 -m command -a "systemctl is-enabled ssh"
```

Expected result:

```text
enabled
```

Check SSH service active state:

```bash
ansible web-01 -m command -a "systemctl is-active ssh"
```

Expected result:

```text
active
```

---

## 14. Important Concept: Reusability

The role can later be applied to more hosts.

Currently:

```yaml
hosts: web-01
```

Later, after all Linux VMs exist, the same role can be applied to:

```yaml
hosts: linux
```

That will apply the baseline configuration to:

```text
web-01
web-02
db-01
monitor-01
```

This is the main value of roles: one implementation, many targets.

---

## 15. Important Concept: Maintainability

Without roles, a project can become messy:

```text
large playbooks
duplicated tasks
hardcoded values
difficult troubleshooting
```

With roles, the structure becomes clearer:

```text
roles/linux_baseline/tasks/main.yml
roles/linux_baseline/defaults/main.yml
roles/linux_baseline/handlers/main.yml
```

Each part has a clear responsibility.

This is a major step from beginner Ansible toward production-style Ansible.

---

## 16. Troubleshooting

### Role Not Found

Error example:

```text
ERROR! the role 'linux_baseline' was not found
```

Possible causes:

- role directory name is wrong
- command was not executed from the Ansible project directory
- `roles_path` is wrong in `ansible.cfg`

Check:

```bash
cd ~/enterprise-automation-lab/ansible
ansible --version
```

Expected config:

```text
config file = /home/Morgein/enterprise-automation-lab/ansible/ansible.cfg
```

Check role path:

```bash
tree roles/linux_baseline
```

Check `ansible.cfg`:

```ini
roles_path = roles
```

---

### Variable Is Undefined

Error example:

```text
'baseline_packages' is undefined
```

Possible causes:

- defaults file missing
- group_vars file missing
- YAML syntax error
- wrong variable name

Check:

```bash
cat roles/linux_baseline/defaults/main.yml
cat inventories/dev/group_vars/linux.yml
ansible-inventory --host web-01
```

---

### Playbook Targets Non-Existing Hosts

Currently only `web-01` exists.

Because of this, the role-based playbook targets:

```yaml
hosts: web-01
```

Do not change it to:

```yaml
hosts: linux
```

until all planned VMs are created.

---

## 17. Commands Used in This Stage

Create role directories:

```bash
mkdir -p ansible/roles/linux_baseline/tasks
mkdir -p ansible/roles/linux_baseline/defaults
mkdir -p ansible/roles/linux_baseline/handlers
mkdir -p ansible/roles/linux_baseline/meta
```

Create role files:

```bash
nano ansible/roles/linux_baseline/tasks/main.yml
nano ansible/roles/linux_baseline/defaults/main.yml
nano ansible/roles/linux_baseline/handlers/main.yml
nano ansible/roles/linux_baseline/meta/main.yml
```

Create role-based playbook:

```bash
nano ansible/playbooks/02-apply-linux-baseline.yml
```

Validate syntax:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

Run playbook:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Run idempotency check:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

---

## 18. Recommended Screenshots

Screenshots for this stage can be stored in:

```text
docs/screenshots/stage-01-ansible-basics/
```

Recommended screenshots:

| Screenshot | Description |
|---|---|
| `09-linux-baseline-role-tree.png` | Role directory structure |
| `10-role-playbook-syntax-check.png` | Successful syntax check |
| `11-role-playbook-run.png` | Role-based playbook execution |
| `12-role-idempotency-check.png` | Second run showing idempotency |

Example markdown links:

```markdown
![Linux baseline role structure](../screenshots/stage-01-ansible-basics/09-linux-baseline-role-tree.png)

![Role playbook syntax check](../screenshots/stage-01-ansible-basics/10-role-playbook-syntax-check.png)

![Role playbook run](../screenshots/stage-01-ansible-basics/11-role-playbook-run.png)

![Role idempotency check](../screenshots/stage-01-ansible-basics/12-role-idempotency-check.png)
```

Screenshots are optional but useful as GitHub evidence.

---

## 19. Stage Result

At the end of this stage, the project has:

```text
First reusable Ansible role created
Linux baseline tasks moved into a role
Role defaults added
Role handler structure prepared
Role metadata added
Role-based playbook created
Syntax check passed
Role playbook executed successfully
Idempotency validated
```

---

## 20. Current Status

Current project status:

```text
Stage 1.3 - First Reusable Ansible Role completed
```

Next planned stage:

```text
Stage 1.4 - Ansible linting and code quality
```

The next stage will introduce basic Ansible code quality checks using `ansible-lint` and `yamllint`.
