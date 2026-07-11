# Stage 2.2 - Apply Linux Baseline Role to All Linux Nodes

## 1. Purpose

This document describes Stage 2.2 of the Enterprise Automation Lab.

The goal of this stage is to apply the reusable `linux_baseline` Ansible role to all Linux managed nodes in the lab.

Before this stage, the role-based playbook targeted only one host:

```yaml
hosts: web-01
```

After this stage, the playbook targets the full Linux inventory group:

```yaml
hosts: linux
```

This is the first stage where one reusable role is applied across multiple servers.

---

## 2. Current Managed Nodes

At this stage, the lab contains four managed Linux nodes.

| Hostname | IP Address | Group | Role |
|---|---:|---|---|
| web-01 | 192.168.100.11 | web | First web/application server |
| web-02 | 192.168.100.12 | web | Second web/application server |
| db-01 | 192.168.100.21 | database | Database server |
| monitor-01 | 192.168.100.31 | monitoring | Monitoring server |

All nodes are reachable from Kali Linux WSL through SSH key authentication.

---

## 3. Inventory Group Design

The development inventory is located at:

```text
ansible/inventories/dev/hosts.ini
```

Relevant inventory structure:

```ini
[web]
web-01 ansible_host=192.168.100.11
web-02 ansible_host=192.168.100.12

[database]
db-01 ansible_host=192.168.100.21

[monitoring]
monitor-01 ansible_host=192.168.100.31

[linux:children]
web
database
monitoring

[linux:vars]
ansible_user=automation
ansible_ssh_private_key_file=~/.ssh/enterprise_automation_lab
```

The group:

```ini
[linux:children]
```

means that the `linux` group contains child groups.

In this project:

```text
linux = web + database + monitoring
```

Therefore, targeting:

```yaml
hosts: linux
```

applies automation to:

```text
web-01
web-02
db-01
monitor-01
```

---

## 4. Connectivity Validation

Before applying configuration to all nodes, Ansible connectivity was validated with:

```bash
cd ~/enterprise-automation-lab/ansible
ansible linux -m ping
```

Expected result:

```text
web-01      pong
web-02      pong
db-01       pong
monitor-01 pong
```

This confirms:

- inventory is correct
- SSH key authentication works
- Python is available on every managed node
- all nodes are reachable from the WSL control node

---

## 5. Updated Playbook

File:

```text
ansible/playbooks/02-apply-linux-baseline.yml
```

Updated content:

```yaml
---
- name: Apply Linux baseline configuration
  hosts: linux
  become: true
  gather_facts: true

  roles:
    - linux_baseline
```

---

## 6. Playbook Explanation

### YAML document start

```yaml
---
```

Marks the beginning of the YAML document.

---

### Play name

```yaml
- name: Apply Linux baseline configuration
```

This is the human-readable play name shown in Ansible output.

---

### Target hosts

```yaml
hosts: linux
```

This tells Ansible to apply the play to all hosts in the `linux` inventory group.

This is the key change of this stage.

Previously:

```yaml
hosts: web-01
```

Only one server was targeted.

Now:

```yaml
hosts: linux
```

All Linux managed nodes are targeted.

---

### Privilege escalation

```yaml
become: true
```

This enables sudo.

The `linux_baseline` role needs elevated privileges for:

- package installation
- service management
- system configuration

---

### Fact gathering

```yaml
gather_facts: true
```

This allows Ansible to collect system information from each node.

The role uses facts such as:

```yaml
ansible_facts['hostname']
ansible_facts['distribution']
ansible_facts['kernel']
ansible_facts['architecture']
```

---

### Role application

```yaml
roles:
  - linux_baseline
```

This applies the reusable role:

```text
ansible/roles/linux_baseline/
```

to every host in the target group.

---

## 7. Role Applied

The role applied in this stage:

```text
linux_baseline
```

Role path:

```text
ansible/roles/linux_baseline/
```

The role performs:

- host information display
- APT package cache update
- baseline package installation
- SSH service enablement
- SSH service running-state validation
- hostname command validation

---

## 8. Syntax Check

Before running the playbook, validate syntax:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

Expected result:

```text
playbook: playbooks/02-apply-linux-baseline.yml
```

---

## 9. Apply Role to All Linux Nodes

Run:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Expected result:

```text
web-01      failed=0 unreachable=0
web-02      failed=0 unreachable=0
db-01       failed=0 unreachable=0
monitor-01 failed=0 unreachable=0
```

On newly created nodes, Ansible may report `changed > 0` during the first run because baseline packages are being installed.

---

## 10. Idempotency Check

Run the same playbook again:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Expected result:

```text
changed=0
failed=0
unreachable=0
```

This confirms that the role is idempotent.

Idempotency means that repeated automation runs should not keep changing the system if the desired state is already applied.

---

## 11. Post-Run Validation

Check if `htop` is installed on all Linux nodes:

```bash
ansible linux -m command -a "which htop"
```

Expected result:

```text
/usr/bin/htop
```

Check if SSH is enabled:

```bash
ansible linux -m command -a "systemctl is-enabled ssh"
```

Expected result:

```text
enabled
```

Check if SSH is active:

```bash
ansible linux -m command -a "systemctl is-active ssh"
```

Expected result:

```text
active
```

---

## 12. Why This Stage Is Important

This stage proves that the project can manage multiple servers with one reusable role.

Before this stage:

```text
one playbook -> one host
```

After this stage:

```text
one role-based playbook -> multiple hosts
```

This is a major step toward real infrastructure automation.

The same pattern will be used later for:

- web server configuration
- database configuration
- monitoring setup
- security hardening
- backup automation

---

## 13. Troubleshooting

### One host is unreachable

Check plain SSH first:

```bash
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.12
```

Replace the IP address with the failing host.

Check the VM:

```bash
ip addr
ip route
systemctl status ssh --no-pager
```

---

### Sudo fails

If Ansible reports a sudo-related error, verify passwordless sudo:

```bash
sudo visudo -cf /etc/sudoers.d/automation
```

Expected result:

```text
/etc/sudoers.d/automation: parsed OK
```

---

### Python interpreter issue

If Ansible cannot find Python, install Python on the managed node:

```bash
sudo apt update
sudo apt install -y python3
```

The inventory and Ansible configuration use:

```ini
interpreter_python = auto_silent
```

This allows Ansible to auto-detect Python.

---

## 14. Recommended Screenshots

Screenshots for this stage can be stored in:

```text
docs/screenshots/stage-02-multi-node-automation/
```

Recommended screenshots:

| Screenshot | Description |
|---|---|
| `01-ansible-linux-ping-all-nodes.png` | `ansible linux -m ping` returns pong for all nodes |
| `02-baseline-role-all-nodes-run.png` | Role applied to all Linux nodes |
| `03-baseline-role-idempotency.png` | Second run showing idempotent result |
| `04-post-run-validation.png` | `htop` and SSH service validation |

---

## 15. Stage Result

At the end of this stage:

```text
linux_baseline role applies to all Linux nodes
web-01 managed successfully
web-02 managed successfully
db-01 managed successfully
monitor-01 managed successfully
Ansible multi-node automation validated
Idempotency validated across all nodes
```

---

## 16. Current Status

Current project status:

```text
Stage 2.2 - Apply linux_baseline role to all Linux nodes completed
```

Next planned stage:

```text
Stage 2.3 - Create Nginx role for web servers
```

The next stage will introduce a dedicated `nginx` role and apply it only to the `web` group.
