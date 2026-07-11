# Stage 1 - Ansible Basics Runbook

## 1. Purpose

This runbook documents the first practical Ansible stage of the **Enterprise Automation Lab**.

The goal of this stage is to move from manual SSH access and simple Ansible ad-hoc commands to a repeatable Ansible playbook.

At this point, the lab already has:

- Kali Linux WSL configured as the automation control workstation
- Hyper-V internal NAT network configured
- First Ubuntu Server VM created as `web-01`
- SSH access from Kali WSL to `web-01`
- SSH key authentication configured
- Ansible inventory configured
- Ansible ping successfully tested

This stage introduces the first real Ansible playbook.

---

## 2. Current Lab State

### Control Node

The control node is:

```text
Kali Linux WSL
```

The control node is responsible for running:

- Git
- SSH client
- Python
- Ansible
- ansible-playbook
- ansible-lint
- yamllint

### Managed Node

The first managed node is:

| Hostname | IP Address | Role |
|---|---:|---|
| web-01 | 192.168.100.11 | First Linux managed node / web server candidate |

### Connection Model

```text
Kali Linux WSL
    |
    | SSH key authentication
    v
web-01
    |
    | Python-based Ansible module execution
    v
Linux configuration managed by Ansible
```

---

## 3. Ansible Control Directory

All Ansible commands for this project are executed from:

```bash
cd ~/enterprise-automation-lab/ansible
```

This is important because the project-specific Ansible configuration file is located here:

```text
ansible/ansible.cfg
```

When running Ansible from this directory, Ansible automatically detects and uses this configuration file.

Validation command:

```bash
ansible --version
```

Expected result should include:

```text
config file = /home/Morgein/enterprise-automation-lab/ansible/ansible.cfg
```

This confirms that Ansible is using the project configuration.

---

## 4. Ansible Configuration

The project uses the following Ansible configuration file:

```text
ansible/ansible.cfg
```

Current configuration:

```ini
[defaults]
inventory = inventories/dev/hosts.ini
host_key_checking = False
retry_files_enabled = False
stdout_callback = ansible.builtin.default
interpreter_python = auto_silent
roles_path = roles
timeout = 30

[callback_default]
result_format = yaml

[privilege_escalation]
become = True
become_method = sudo
become_ask_pass = False
```

### Explanation

```ini
inventory = inventories/dev/hosts.ini
```

This tells Ansible which inventory file to use by default.

The inventory file contains the list of managed servers.

---

```ini
host_key_checking = False
```

This disables strict SSH host key checking.

For a local lab, this makes testing easier.  
In production, host key checking should normally be enabled for better security.

---

```ini
retry_files_enabled = False
```

This prevents Ansible from creating old-style `.retry` files after failed runs.

---

```ini
stdout_callback = ansible.builtin.default
```

This uses the default built-in Ansible output callback.

---

```ini
[callback_default]
result_format = yaml
```

This makes Ansible output easier to read by formatting results in YAML style.

This setting is used because the old `stdout_callback = yaml` behavior is no longer valid in newer Ansible versions.

---

```ini
interpreter_python = auto_silent
```

This allows Ansible to automatically detect the Python interpreter on the managed node.

---

```ini
roles_path = roles
```

This tells Ansible where project roles will be stored later.

---

```ini
become = True
```

This enables privilege escalation by default.

Ansible will use `sudo` when executing tasks that require elevated privileges.

---

```ini
become_method = sudo
```

The privilege escalation method is `sudo`.

---

```ini
become_ask_pass = False
```

Ansible will not ask for a sudo password interactively.

This works because the `automation` user on `web-01` has passwordless sudo configured.

---

## 5. Inventory Configuration

The development inventory is located at:

```text
ansible/inventories/dev/hosts.ini
```

Current inventory structure:

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

### Important Notes

Only `web-01` currently exists.

The other hosts are already planned in the inventory, but they are not created yet:

```text
web-02
db-01
monitor-01
```

Because of this, early playbooks should target only:

```text
web-01
```

If a playbook targets the full `linux` group now, Ansible will try to connect to non-existing servers and the run will fail.

---

## 6. Pre-Playbook Validation

Before running any playbook, validate basic connectivity.

From the Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible
```

Run Ansible ping:

```bash
ansible web-01 -m ping
```

Expected result:

```text
web-01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Run a simple command:

```bash
ansible web-01 -m command -a "hostname"
```

Expected result:

```text
web-01 | CHANGED | rc=0 >>
web-01
```

This confirms:

- Ansible can read the inventory
- Ansible can connect to `web-01`
- SSH key authentication works
- Python is available on the managed node
- Ansible can execute remote commands

---

## 7. Ad-Hoc Commands vs Playbooks

### Ad-Hoc Commands

An ad-hoc command is a one-time Ansible command.

Example:

```bash
ansible web-01 -m ping
```

Another example:

```bash
ansible web-01 -m command -a "hostname"
```

Ad-hoc commands are useful for:

- quick testing
- diagnostics
- simple checks
- one-time operations

### Playbooks

A playbook is a YAML file that describes a repeatable automation workflow.

A playbook can contain:

- target hosts
- variables
- tasks
- handlers
- conditions
- loops
- templates
- service management
- package installation

In this stage, the project introduces the first real playbook:

```text
ansible/playbooks/01-bootstrap-linux.yml
```

---

## 8. First Ansible Playbook

The first playbook is located at:

```text
ansible/playbooks/01-bootstrap-linux.yml
```

Full playbook:

```yaml
---
- name: Bootstrap Linux managed node
  hosts: web-01
  become: true
  gather_facts: true

  tasks:
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
        cache_valid_time: 3600

    - name: Install baseline packages
      ansible.builtin.apt:
        name:
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
        state: present

    - name: Ensure SSH service is enabled and running
      ansible.builtin.service:
        name: ssh
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

## 9. Playbook Explanation

### Play Name

```yaml
- name: Bootstrap Linux managed node
```

This is the name of the play.

It describes the purpose of this automation step.

---

### Target Host

```yaml
hosts: web-01
```

The playbook targets only `web-01`.

This is intentional because `web-01` is currently the only existing managed node.

---

### Privilege Escalation

```yaml
become: true
```

This tells Ansible to use `sudo`.

It is required for tasks such as:

- installing packages
- managing services
- editing system files
- configuring the operating system

---

### Fact Gathering

```yaml
gather_facts: true
```

This allows Ansible to collect system information from the managed node.

Examples of facts:

```text
ansible_hostname
ansible_distribution
ansible_distribution_version
ansible_kernel
ansible_architecture
```

Facts are useful because they allow playbooks to make decisions based on the target system.

---

### Debug Task

```yaml
ansible.builtin.debug:
```

The debug module prints useful information during a playbook run.

In this playbook, it prints:

- inventory hostname
- system hostname
- Linux distribution
- kernel version
- CPU architecture

This is useful for learning and validation.

---

### APT Cache Update

```yaml
ansible.builtin.apt:
  update_cache: true
  cache_valid_time: 3600
```

This updates the APT package cache.

`cache_valid_time: 3600` means that Ansible will not update the cache again if it was updated within the last 3600 seconds.

This avoids unnecessary package index updates.

---

### Baseline Package Installation

```yaml
state: present
```

This means that the listed packages should be installed.

If a package is already installed, Ansible will not reinstall it unnecessarily.

This is an example of idempotent behavior.

Baseline packages installed in this stage:

| Package | Purpose |
|---|---|
| curl | HTTP requests and API testing |
| wget | File downloading |
| vim | Terminal text editor |
| nano | Beginner-friendly terminal text editor |
| htop | Interactive process monitoring |
| net-tools | Legacy networking tools like `netstat` |
| unzip | Archive extraction |
| git | Version control |
| python3 | Required by Ansible modules |
| python3-pip | Python package management |
| openssh-server | SSH server |

---

### SSH Service Management

```yaml
ansible.builtin.service:
  name: ssh
  state: started
  enabled: true
```

This ensures that SSH is:

```text
started now
enabled after reboot
```

This is important because Ansible depends on SSH connectivity.

---

### Command Validation

```yaml
ansible.builtin.command: hostname
```

This runs the `hostname` command on the managed node.

The result is stored using:

```yaml
register: hostname_result
```

Then the output is displayed using:

```yaml
ansible.builtin.debug:
  var: hostname_result.stdout
```

---

### changed_when: false

```yaml
changed_when: false
```

The `hostname` command only reads information.  
It does not change the system.

By default, Ansible may mark some command tasks as changed because it cannot always know whether a command modified the system.

`changed_when: false` tells Ansible:

```text
This task is informational only. Do not mark it as changed.
```

This makes playbook output cleaner and more accurate.

---

## 10. Syntax Check

Before running the playbook, check the syntax:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
```

Expected result:

```text
playbook: playbooks/01-bootstrap-linux.yml
```

If there is a YAML error, Ansible will show the approximate line where the issue occurred.

---

## 11. Run the Playbook

Run:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

Expected final result should include:

```text
PLAY RECAP
web-01 : ok=... changed=... unreachable=0 failed=0
```

The most important values are:

```text
unreachable=0
failed=0
```

This means:

- the host was reachable
- the playbook did not fail

---

## 12. Idempotency Check

Run the same playbook a second time:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

The second run should produce fewer changes.

Why?

Because most desired state has already been applied:

- packages are already installed
- SSH service is already running
- SSH service is already enabled
- hostname validation does not change the system

This is a core automation principle.

---

## 13. Important Concept: Idempotency

Idempotency means that running the same automation multiple times should lead to the same final state.

Example:

```yaml
- name: Install baseline packages
  ansible.builtin.apt:
    name:
      - curl
      - wget
    state: present
```

If `curl` and `wget` are not installed, Ansible installs them.

If they are already installed, Ansible does nothing.

This is different from a simple shell script that blindly runs the same commands every time.

Reliable infrastructure automation should be idempotent.

---

## 14. Post-Run Validation

After running the playbook, validate the result.

From the Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible
```

Check if `htop` is installed:

```bash
ansible web-01 -m command -a "which htop"
```

Expected result:

```text
/usr/bin/htop
```

Check if SSH is enabled:

```bash
ansible web-01 -m command -a "systemctl is-enabled ssh"
```

Expected result:

```text
enabled
```

Check if SSH is active:

```bash
ansible web-01 -m command -a "systemctl is-active ssh"
```

Expected result:

```text
active
```

---

## 15. Troubleshooting

### Problem: Ansible YAML Callback Error

Example error:

```text
[ERROR]: The 'community.general.yaml' callback plugin has been removed.
The plugin has been superseded by the option result_format=yaml in callback plugin ansible.builtin.default.
```

### Cause

The old configuration:

```ini
stdout_callback = yaml
```

is not valid for newer Ansible versions.

### Fix

Use:

```ini
stdout_callback = ansible.builtin.default
```

and add:

```ini
[callback_default]
result_format = yaml
```

Final working configuration:

```ini
[defaults]
inventory = inventories/dev/hosts.ini
host_key_checking = False
retry_files_enabled = False
stdout_callback = ansible.builtin.default
interpreter_python = auto_silent
roles_path = roles
timeout = 30

[callback_default]
result_format = yaml

[privilege_escalation]
become = True
become_method = sudo
become_ask_pass = False
```

---

### Problem: Host Is Unreachable

Example:

```text
UNREACHABLE
```

Possible causes:

- VM is powered off
- wrong IP address in inventory
- SSH service is not running
- Windows forwarding between WSL and Hyper-V is disabled
- firewall blocks traffic
- SSH key path is wrong

Check:

```bash
ping 192.168.100.11
ssh -i ~/.ssh/enterprise_automation_lab automation@192.168.100.11
```

---

### Problem: Permission Denied

Example:

```text
Permission denied (publickey)
```

Possible causes:

- public key was not copied to `web-01`
- wrong private key path in inventory
- incorrect permissions on SSH key files
- `PubkeyAuthentication yes` is not enabled on the server

Check on Kali WSL:

```bash
ls -la ~/.ssh
```

Recommended permissions:

```text
~/.ssh                              700
~/.ssh/enterprise_automation_lab    600
~/.ssh/enterprise_automation_lab.pub 644
```

Check on `web-01`:

```bash
ls -la ~/.ssh
cat ~/.ssh/authorized_keys
sudo grep PubkeyAuthentication /etc/ssh/sshd_config
```

Restart SSH if needed:

```bash
sudo systemctl restart ssh
```

---

### Problem: Missing Sudo Password

Example:

```text
Missing sudo password
```

Cause:

Ansible is trying to use `sudo`, but the `automation` user does not have passwordless sudo.

Fix on `web-01`:

```bash
echo "automation ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/automation
sudo chmod 440 /etc/sudoers.d/automation
sudo visudo -cf /etc/sudoers.d/automation
```

Expected result:

```text
/etc/sudoers.d/automation: parsed OK
```

---

## 16. Commands Used in This Stage

### Connectivity Validation

```bash
cd ~/enterprise-automation-lab/ansible
ansible web-01 -m ping
ansible web-01 -m command -a "hostname"
```

### Syntax Check

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
```

### Playbook Execution

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

### Idempotency Check

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

### Post-Run Checks

```bash
ansible web-01 -m command -a "which htop"
ansible web-01 -m command -a "systemctl is-enabled ssh"
ansible web-01 -m command -a "systemctl is-active ssh"
```

---


## 18. Stage Result

At the end of this stage, the project has:

```text
Ansible control configuration working
Inventory file working
SSH key authentication working
Ansible ping validated
First real playbook created
Linux baseline packages automated
SSH service managed by Ansible
Basic idempotency tested
```

---

## 19. Current Status

Current project status:

```text
Stage 1.1 - First Ansible Playbook completed or in progress
```

Next planned stage:

```text
Stage 1.2 - Ansible variables and inventory cleanup
```

In the next stage, the playbook will be improved by moving hardcoded values into variables.

Planned improvements:

- create `group_vars`
- define baseline package list as a variable
- clean up inventory structure
- prepare for reusable roles
- start moving from beginner-style playbooks toward cleaner project architecture
