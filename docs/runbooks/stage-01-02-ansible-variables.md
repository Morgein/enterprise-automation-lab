# Stage 1.2 - Ansible Variables and Inventory Cleanup

## 1. Purpose

This document describes Stage 1.2 of the **Enterprise Automation Lab**.

The goal of this stage is to improve the first Ansible bootstrap playbook by moving hardcoded values into inventory-specific variables.

In Stage 1.1, the first real Ansible playbook was created:

```text
ansible/playbooks/01-bootstrap-linux.yml
```

That playbook worked correctly, but it still contained values directly inside the playbook, such as:

- package names
- SSH service name
- APT cache timing

In this stage, these values are moved into a dedicated `group_vars` file.

This makes the project cleaner, easier to maintain and closer to real infrastructure automation practices.

---

## 2. Current Lab State

At the beginning of this stage, the lab already has:

```text
Kali Linux WSL
    |
    | SSH key authentication
    v
web-01
    |
    | Ansible module execution
    v
Ubuntu Server managed by Ansible
```

Current managed node:

| Hostname | IP Address | Role |
|---|---:|---|
| web-01 | 192.168.100.11 | First Linux managed node |

The Ansible inventory already contains planned future hosts:

| Hostname | IP Address | Status |
|---|---:|---|
| web-01 | 192.168.100.11 | Created |
| web-02 | 192.168.100.12 | Planned |
| db-01 | 192.168.100.21 | Planned |
| monitor-01 | 192.168.100.31 | Planned |

Only `web-01` exists at this stage.

---

## 3. Problem With Hardcoded Values

The first bootstrap playbook contained package names directly inside the playbook.

Example:

```yaml
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
```

This works, but it is not ideal.

If package lists or environment-specific values are written directly inside playbooks, the playbook becomes harder to reuse.

For example, different environments may need different values:

```text
dev    -> smaller package list
stage  -> closer to production
prod   -> stricter and more controlled configuration
```

A better approach is:

```text
Playbook = automation logic
Variables = environment-specific data
```

---

## 4. What Was Changed

In this stage, a new inventory-specific variable file was created:

```text
ansible/inventories/dev/group_vars/linux.yml
```

The bootstrap playbook was updated to use variables instead of hardcoded values.

The following values were moved to variables:

| Variable | Purpose |
|---|---|
| `baseline_packages` | List of baseline packages for Linux nodes |
| `ssh_service_name` | Name of the SSH service |
| `apt_cache_valid_time` | APT cache validity time in seconds |

---

## 5. Why group_vars Is Used

Ansible supports variable files based on inventory groups.

The current inventory contains this group:

```ini
[linux:children]
web
database
monitoring
```

This means the `linux` group includes:

```text
web
database
monitoring
```

So variables stored in:

```text
ansible/inventories/dev/group_vars/linux.yml
```

apply to every host that belongs to the `linux` group.

Currently, this affects:

```text
web-01
```

Later, it will also affect:

```text
web-02
db-01
monitor-01
```

This is useful because all Linux servers should share a common baseline configuration.

---

## 6. Directory Structure

Before this stage, the inventory directory looked like this:

```text
ansible/inventories/dev/
└── hosts.ini
```

After this stage, it becomes:

```text
ansible/inventories/dev/
├── hosts.ini
└── group_vars/
    └── linux.yml
```

This structure is cleaner and closer to real Ansible project architecture.

---

## 7. Created Variable File

File:

```text
ansible/inventories/dev/group_vars/linux.yml
```

Content:

```yaml
---
# Variables for all Linux hosts in the development inventory.

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

---

## 8. Variable Explanation

### baseline_packages

```yaml
baseline_packages:
```

This variable contains the list of standard packages that should be installed on baseline Linux nodes.

Package list:

| Package | Purpose |
|---|---|
| `curl` | HTTP requests and endpoint testing |
| `wget` | File downloading |
| `vim` | Advanced terminal text editor |
| `nano` | Simple terminal text editor |
| `htop` | Interactive process viewer |
| `net-tools` | Legacy network tools such as `netstat` |
| `unzip` | ZIP archive extraction |
| `git` | Version control |
| `python3` | Required for many Ansible modules |
| `python3-pip` | Python package management |
| `openssh-server` | SSH access to the managed node |

This list defines a basic operational toolkit for Linux servers in the lab.

---

### ssh_service_name

```yaml
ssh_service_name: ssh
```

This variable defines the SSH service name.

On Ubuntu and Debian, the SSH service is usually called:

```text
ssh
```

On some other Linux distributions, it may be called:

```text
sshd
```

Using a variable makes the playbook easier to adapt later.

---

### apt_cache_valid_time

```yaml
apt_cache_valid_time: 3600
```

This variable defines how long the APT package cache should be considered valid.

`3600` seconds equals one hour.

This avoids unnecessary package cache updates during repeated Ansible runs.

---

## 9. Updated Bootstrap Playbook

File:

```text
ansible/playbooks/01-bootstrap-linux.yml
```

Updated playbook:

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

## 10. What Changed in the Playbook

### Before

The package list was hardcoded:

```yaml
- name: Install baseline packages
  ansible.builtin.apt:
    name:
      - curl
      - wget
      - vim
      - nano
    state: present
```

### After

The package list is loaded from a variable:

```yaml
- name: Install baseline packages
  ansible.builtin.apt:
    name: "{{ baseline_packages }}"
    state: present
```

This makes the playbook cleaner.

---

### Before

The SSH service name was hardcoded:

```yaml
name: ssh
```

### After

The SSH service name is loaded from a variable:

```yaml
name: "{{ ssh_service_name }}"
```

---

### Before

APT cache validity time was hardcoded:

```yaml
cache_valid_time: 3600
```

### After

APT cache validity time is loaded from a variable:

```yaml
cache_valid_time: "{{ apt_cache_valid_time }}"
```

---

## 11. Why This Design Is Better

This design improves the project because:

- package lists are easier to maintain
- environment-specific data is separated from task logic
- playbooks become more reusable
- the inventory becomes more meaningful
- future roles will be easier to create
- the project starts moving from beginner structure toward professional Ansible architecture

This is an important step toward clean automation design.

---

## 12. Important Concept: Logic vs Data

A clean Ansible project separates automation logic from configuration data.

### Logic

Logic describes what Ansible should do.

Examples:

```text
playbooks
tasks
roles
handlers
templates
```

### Data

Data describes values used by the automation.

Examples:

```text
group_vars
host_vars
inventory variables
environment-specific variables
```

In this stage:

```text
Logic:
ansible/playbooks/01-bootstrap-linux.yml

Data:
ansible/inventories/dev/group_vars/linux.yml
```

This separation makes automation easier to scale.

---

## 13. Inventory Validation

To verify that Ansible loads the variables correctly, run:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-inventory --host web-01
```

The output should include:

```text
baseline_packages
ssh_service_name
apt_cache_valid_time
```

This confirms that Ansible correctly loads variables from:

```text
ansible/inventories/dev/group_vars/linux.yml
```

---

## 14. Syntax Check

Before running the playbook, validate YAML and Ansible syntax:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
```

Expected result:

```text
playbook: playbooks/01-bootstrap-linux.yml
```

If the syntax check passes, the playbook is structurally valid.

---

## 15. Run the Playbook

Run:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

Expected result:

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

- Ansible reached the managed node
- SSH worked
- sudo worked
- tasks completed successfully

---

## 16. Idempotency Check

Run the same playbook again:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

The second run should produce fewer changes.

A good expected result is:

```text
changed=0
```

or at least fewer changes than the first run.

This confirms that the playbook mostly describes desired state instead of blindly executing commands.

---

## 17. Post-Run Validation

Validate that baseline packages and SSH service state are correct.

Check `htop`:

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

## 18. Troubleshooting

### Variables Are Not Loaded

If the playbook fails with an error such as:

```text
'baseline_packages' is undefined
```

Possible causes:

- `group_vars` directory is in the wrong location
- file name does not match the inventory group name
- the host is not part of the `linux` group
- command is executed from the wrong directory
- `ansible.cfg` is not loaded

Check inventory:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-inventory --host web-01
```

Check that this file exists:

```bash
ls -la inventories/dev/group_vars/linux.yml
```

---

### Wrong group_vars Location

Correct location:

```text
ansible/inventories/dev/group_vars/linux.yml
```

Incorrect example:

```text
ansible/group_vars/linux.yml
```

This may also work in some project structures, but for this lab the variables are intentionally stored inside the `dev` inventory to keep environment-specific data separated.

---

### YAML Formatting Error

YAML is indentation-sensitive.

Correct:

```yaml
baseline_packages:
  - curl
  - wget
```

Incorrect:

```yaml
baseline_packages:
- curl
- wget
```

Run syntax check:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
```

---

### Playbook Targets Non-Existing Hosts

The inventory already includes future hosts:

```text
web-02
db-01
monitor-01
```

They are not created yet.

Because of this, the playbook currently targets only:

```yaml
hosts: web-01
```

If the playbook targets:

```yaml
hosts: linux
```

Ansible will try to connect to all planned hosts and fail for the VMs that do not exist yet.

---

## 19. Commands Used in This Stage

Create group variables directory:

```bash
mkdir -p ansible/inventories/dev/group_vars
```

Create variable file:

```bash
nano ansible/inventories/dev/group_vars/linux.yml
```

Validate inventory variables:

```bash
cd ~/enterprise-automation-lab/ansible
ansible-inventory --host web-01
```

Run syntax check:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
```

Run playbook:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

Run idempotency check:

```bash
ansible-playbook playbooks/01-bootstrap-linux.yml
```

Post-run validation:

```bash
ansible web-01 -m command -a "which htop"
ansible web-01 -m command -a "systemctl is-enabled ssh"
ansible web-01 -m command -a "systemctl is-active ssh"
```

---

## 20. Recommended Screenshots

Screenshots for this stage can be stored in:

```text
docs/screenshots/stage-01-ansible-basics/
```

Recommended screenshots:

| Screenshot | Description |
|---|---|
| `05-inventory-variables-web-01.png` | `ansible-inventory --host web-01` showing loaded variables |
| `06-bootstrap-playbook-syntax-check.png` | Successful syntax check |
| `07-bootstrap-playbook-with-variables.png` | Successful playbook run using variables |
| `08-idempotency-check.png` | Second playbook run showing no or fewer changes |

Example markdown links:

```markdown
![Inventory variables for web-01](../screenshots/stage-01-ansible-basics/05-inventory-variables-web-01.png)

![Bootstrap playbook syntax check](../screenshots/stage-01-ansible-basics/06-bootstrap-playbook-syntax-check.png)

![Bootstrap playbook using variables](../screenshots/stage-01-ansible-basics/07-bootstrap-playbook-with-variables.png)

![Idempotency check](../screenshots/stage-01-ansible-basics/08-idempotency-check.png)
```

Screenshots are optional, but they provide useful evidence for GitHub.

---

## 21. Stage Result

At the end of this stage, the project has:

```text
Inventory-specific group_vars created
Baseline package list moved to variables
SSH service name moved to variables
APT cache timing moved to variables
Bootstrap playbook cleaned up
Ansible variable loading validated
Playbook syntax validated
Playbook execution validated
Idempotency checked
```

---

## 22. Current Status

Current project status:

```text
Stage 1.2 - Ansible Variables and Inventory Cleanup completed
```

Next planned stage:

```text
Stage 1.3 - First Reusable Ansible Role
```

In the next stage, the baseline Linux configuration will be moved from a single playbook into a reusable Ansible role.

This will move the project closer to a maintainable Ansible architecture.
