# Stage 1.4 - Ansible Linting and Code Quality

## 1. Purpose

This document describes Stage 1.4 of the Enterprise Automation Lab.

The goal of this stage is to introduce basic code quality validation for Ansible and YAML files.

At this stage, the project already has:

- a working Ansible inventory
- SSH key-based access to `web-01`
- a reusable `linux_baseline` role
- a role-based playbook
- working Ansible execution with idempotent results

This stage adds quality checks using:

- `yamllint`
- `ansible-lint`

---

## 2. Why Linting Is Important

Infrastructure automation code should be treated like software code.

It should be:

- readable
- consistent
- maintainable
- predictable
- safe to run repeatedly
- easy to review in GitHub

Linting helps detect issues before code is executed on servers.

---

## 3. Tools Used

### yamllint

`yamllint` checks YAML files for syntax and formatting issues.

It helps detect:

- indentation problems
- invalid YAML syntax
- overly long lines
- inconsistent formatting
- missing document start markers

### ansible-lint

`ansible-lint` checks Ansible-specific best practices.

It helps detect:

- bad task names
- missing fully qualified collection names
- unsafe command usage
- weak role structure
- variable naming problems
- non-idempotent patterns
- formatting issues in Ansible files

---

## 4. YAML Lint Configuration

A `.yamllint` configuration file was created in the repository root.

File:

```text
.yamllint
```

Content:

```yaml
---
extends: default

rules:
  line-length:
    max: 160
    level: warning

  comments:
    min-spaces-from-content: 1

  comments-indentation: disable

  truthy:
    allowed-values:
      - "true"
      - "false"
      - "yes"
      - "no"
    check-keys: false

ignore: |
  .git/
  .venv/
  venv/
  ansible/.venv/
  terraform/.terraform/
```

---

## 5. Ansible Lint Configuration

An `.ansible-lint` configuration file was created in the repository root.

File:

```text
.ansible-lint
```

Content:

```yaml
---
profile: basic

exclude_paths:
  - .git/
  - .venv/
  - venv/
  - ansible/.venv/
  - terraform/.terraform/

warn_list:
  - experimental

skip_list: []
```

The project currently uses the `basic` profile.

This provides useful validation without making the early lab too strict.

Later, the project can move toward stricter profiles.

---

## 6. Variable Naming Cleanup

During this stage, role variables were renamed to use the role prefix.

### Before

```yaml
baseline_packages:
ssh_service_name:
apt_cache_valid_time:
```

### After

```yaml
linux_baseline_packages:
linux_baseline_ssh_service_name:
linux_baseline_apt_cache_valid_time:
```

This is better because role-prefixed variables reduce the risk of variable name conflicts.

---

## 7. Updated group_vars

File:

```text
ansible/inventories/dev/group_vars/linux.yml
```

Updated variables:

```yaml
---
# Variables for all Linux hosts in the development inventory.

linux_baseline_packages:
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

linux_baseline_ssh_service_name: ssh

linux_baseline_apt_cache_valid_time: 3600
```

---

## 8. Updated Role Defaults

File:

```text
ansible/roles/linux_baseline/defaults/main.yml
```

The role defaults were updated to use the same role-prefixed variable names.

This means the role has safe default values, but those values can still be overridden by inventory variables.

---

## 9. Updated Role Tasks

File:

```text
ansible/roles/linux_baseline/tasks/main.yml
```

The role now uses role-prefixed variables:

```yaml
- name: Update apt package cache
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: "{{ linux_baseline_apt_cache_valid_time }}"

- name: Install baseline packages
  ansible.builtin.apt:
    name: "{{ linux_baseline_packages }}"
    state: present

- name: Ensure SSH service is enabled and running
  ansible.builtin.service:
    name: "{{ linux_baseline_ssh_service_name }}"
    state: started
    enabled: true
```

The hostname command result variable was also renamed:

```yaml
register: linux_baseline_hostname_result
```

This makes registered variables clearer and less likely to conflict with other roles.

---

## 10. Updated Facts Usage

The role uses the modern `ansible_facts` dictionary style.

Example:

```yaml
"System hostname: {{ ansible_facts['hostname'] }}"
"Distribution: {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}"
"Kernel: {{ ansible_facts['kernel'] }}"
"Architecture: {{ ansible_facts['architecture'] }}"
```

This avoids deprecation warnings related to injected fact variables.

---

## 11. Validation Commands

All commands are run from the repository root unless stated otherwise.

### Check Ansible Inventory Variables

```bash
cd ~/enterprise-automation-lab/ansible
ansible-inventory --host web-01
```

Expected variables:

```text
linux_baseline_packages
linux_baseline_ssh_service_name
linux_baseline_apt_cache_valid_time
```

### Check Playbook Syntax

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

Expected result:

```text
playbook: playbooks/02-apply-linux-baseline.yml
```

### Run Role-Based Playbook

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Expected result:

```text
unreachable=0
failed=0
```

### Run yamllint

```bash
cd ~/enterprise-automation-lab
yamllint .
```

Expected result:

```text
No YAML errors.
```

### Run ansible-lint

```bash
cd ~/enterprise-automation-lab
ansible-lint ansible/
```

Expected result:

```text
No Ansible linting failures.
```

---

## 12. Troubleshooting

### yamllint reports line length warnings

If `yamllint` reports line length warnings, review the affected line.

Long documentation lines may be acceptable as warnings, but Ansible tasks should stay readable.

### ansible-lint reports role variable naming issues

Use role prefixes.

Example:

```yaml
linux_baseline_packages:
```

instead of:

```yaml
packages:
```

### ansible-lint reports missing FQCN

Use fully qualified collection names.

Example:

```yaml
ansible.builtin.apt:
```

instead of:

```yaml
apt:
```

### ansible-lint reports command usage issues

If a task uses `ansible.builtin.command`, make sure it is intentional.

For read-only validation commands, use:

```yaml
changed_when: false
```

Example:

```yaml
- name: Validate hostname command
  ansible.builtin.command: hostname
  register: linux_baseline_hostname_result
  changed_when: false
```

---

## 13. Recommended Screenshots

Screenshots for this stage can be stored in:

```text
docs/screenshots/stage-01-ansible-basics/
```

Recommended screenshots:

| Screenshot | Description |
|---|---|
| `13-yamllint-result.png` | Successful `yamllint .` execution |
| `14-ansible-lint-result.png` | Successful `ansible-lint ansible/` execution |
| `15-clean-role-playbook-run.png` | Role-based playbook run without warnings |
| `16-updated-inventory-vars.png` | Inventory output showing role-prefixed variables |

Example markdown links:

```markdown
![yamllint result](../screenshots/stage-01-ansible-basics/13-yamllint-result.png)

![ansible-lint result](../screenshots/stage-01-ansible-basics/14-ansible-lint-result.png)

![Clean role playbook run](../screenshots/stage-01-ansible-basics/15-clean-role-playbook-run.png)

![Updated inventory variables](../screenshots/stage-01-ansible-basics/16-updated-inventory-vars.png)
```

---

## 14. Stage Result

At the end of this stage, the project has:

```text
YAML linting configuration added
Ansible linting configuration added
Role variables renamed with role prefix
Deprecated facts usage cleaned up
Role-based playbook validated
yamllint introduced
ansible-lint introduced
Project code quality improved
```

---

## 15. Current Status

Current project status:

```text
Stage 1.4 - Ansible Linting and Code Quality completed
```

Next planned stage:

```text
Stage 1.5 - GitHub Actions validation pipeline
```

The next stage will automate these checks in GitHub Actions.
