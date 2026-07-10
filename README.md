# Enterprise Automation Lab

[![Ansible Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml/badge.svg?branch=main)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml)

## Project Overview

**Enterprise Automation Lab** is a local infrastructure automation project built with **Kali Linux WSL**, **Hyper-V**, **Ansible**, **GitHub Actions**, and future Infrastructure as Code tooling such as **Terraform** and **AWS CloudFormation**.

The project simulates a small enterprise-style Linux infrastructure environment and demonstrates how infrastructure can be configured, validated, documented, and gradually automated.

The main goal is to build automation skills step by step: from junior-level Ansible basics to more advanced infrastructure automation patterns.

---

## Current Project Status

Current stage:

```text
Stage 1.6 - README improvements and validation badge
```

Completed stages:

| Stage | Description | Status |
|---|---|---|
| Stage 0.1 | WSL control node preparation | Completed |
| Stage 0.2 | Hyper-V internal NAT network setup | Completed |
| Stage 0.3 | First Ubuntu managed node `web-01` | Completed |
| Stage 0.4 | SSH key authentication and Ansible ping | Completed |
| Stage 1.1 | First Ansible bootstrap playbook | Completed |
| Stage 1.2 | Ansible variables and inventory cleanup | Completed |
| Stage 1.3 | First reusable Ansible role | Completed |
| Stage 1.4 | Ansible linting and code quality | Completed |
| Stage 1.5 | GitHub Actions validation pipeline | Completed |
| Stage 1.6 | README and project presentation improvements | In Progress |

---

## Lab Architecture

```text
Windows 11 Host
│
├── Kali Linux WSL
│   └── Automation Control Workstation
│       ├── Git
│       ├── SSH Client
│       ├── Python
│       ├── Ansible
│       ├── ansible-lint
│       └── yamllint
│
└── Hyper-V
    └── Internal NAT Network: 192.168.100.0/24
        │
        ├── web-01      192.168.100.11
        ├── web-02      192.168.100.12   planned
        ├── db-01       192.168.100.21   planned
        └── monitor-01  192.168.100.31   planned
```

---

## Network Design

The lab uses a dedicated Hyper-V internal NAT network.

| Component | Value |
|---|---|
| Hyper-V Switch | `EA-LAB-Internal` |
| NAT Name | `EA-LAB-NAT` |
| Subnet | `192.168.100.0/24` |
| Gateway | `192.168.100.1` |
| First managed node | `web-01` |
| First managed node IP | `192.168.100.11` |

The WSL control node connects to Hyper-V managed nodes over SSH.

```text
Kali Linux WSL → SSH → web-01
```

---

## Technologies Used

| Technology | Purpose |
|---|---|
| Kali Linux WSL | Automation control workstation |
| Hyper-V | Local virtualization platform |
| Ubuntu Server | Managed Linux node operating system |
| Ansible | Configuration management and orchestration |
| Ansible Roles | Reusable automation structure |
| Ansible Inventory | Managed host definition |
| group_vars | Environment-specific variables |
| SSH Keys | Secure authentication from control node to managed nodes |
| yamllint | YAML syntax and formatting validation |
| ansible-lint | Ansible best-practice validation |
| GitHub Actions | Automated CI validation |
| Terraform | Planned Infrastructure as Code tool |
| AWS CloudFormation | Planned AWS-native IaC practice |

---

## Repository Structure

```text
enterprise-automation-lab/
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventories/
│   │   └── dev/
│   │       ├── hosts.ini
│   │       └── group_vars/
│   │           └── linux.yml
│   ├── playbooks/
│   │   ├── 01-bootstrap-linux.yml
│   │   └── 02-apply-linux-baseline.yml
│   └── roles/
│       └── linux_baseline/
│           ├── defaults/
│           │   └── main.yml
│           ├── handlers/
│           │   └── main.yml
│           ├── meta/
│           │   └── main.yml
│           └── tasks/
│               └── main.yml
│
├── cloudformation/
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
│
├── scripts/
│   └── hyperv/
│       └── create-lab-network.ps1
│
├── docs/
│   ├── architecture.md
│   ├── runbooks/
│   ├── screenshots/
│   └── troubleshooting/
│
└── .github/
    └── workflows/
        └── ansible-validation.yml
```

---

## Ansible Inventory

The development inventory is located at:

```text
ansible/inventories/dev/hosts.ini
```

Current inventory:

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

Only `web-01` currently exists. Other nodes are already planned in the inventory and will be created in later stages.

---

## Ansible Role: linux_baseline

The first reusable Ansible role is:

```text
ansible/roles/linux_baseline/
```

This role currently performs baseline Linux configuration:

- shows basic host information
- updates APT package cache
- installs baseline packages
- ensures SSH service is enabled and running
- validates hostname command execution

Role-based playbook:

```text
ansible/playbooks/02-apply-linux-baseline.yml
```

Example:

```yaml
---
- name: Apply Linux baseline configuration
  hosts: web-01
  become: true
  gather_facts: true

  roles:
    - linux_baseline
```

---

## Validation

The project includes local and automated validation.

### Local Validation

Run from the repository root:

```bash
yamllint .
```

Run from the Ansible directory:

```bash
cd ansible
ansible-lint .
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
```

### GitHub Actions Validation

GitHub Actions automatically runs validation on:

- push to `main`
- pull request to `main`
- manual workflow dispatch

Workflow file:

```text
.github/workflows/ansible-validation.yml
```

The workflow validates:

- YAML formatting with `yamllint`
- Ansible best practices with `ansible-lint`
- playbook syntax with `ansible-playbook --syntax-check`

---

## Current Working Validation Results

The current local lab validates successfully:

```text
Ansible ping:        successful
SSH key login:       successful
Role playbook run:   successful
Idempotency check:   changed=0
yamllint:            successful
ansible-lint:        successful
GitHub Actions:      successful
```

---

## Documentation

Main documentation files:

| File | Purpose |
|---|---|
| `docs/architecture.md` | Lab architecture and design |
| `docs/runbooks/wsl-control-node-setup.md` | WSL control node setup |
| `docs/runbooks/hyperv-network-setup.md` | Hyper-V NAT network setup |
| `docs/runbooks/create-web-01-vm.md` | First VM creation runbook |
| `docs/runbooks/stage-01-ansible-basics.md` | First Ansible playbook documentation |
| `docs/runbooks/stage-01-02-ansible-variables.md` | Variables and group_vars documentation |
| `docs/runbooks/stage-01-03-first-ansible-role.md` | First reusable Ansible role documentation |
| `docs/runbooks/stage-01-04-ansible-linting.md` | Linting and code quality documentation |
| `docs/runbooks/stage-01-05-github-actions-validation.md` | GitHub Actions validation pipeline |
| `docs/troubleshooting/wsl-to-hyperv-connectivity.md` | WSL to Hyper-V connectivity troubleshooting |

---

## Screenshots

Validation screenshots are stored under:

```text
docs/screenshots/
```

Current screenshot categories:

```text
docs/screenshots/stage-00-foundation/
docs/screenshots/stage-01-ansible-basics/
```

Screenshots are used as evidence that the local lab was configured and validated successfully.

---

## Project Roadmap

Planned next stages:

| Stage | Goal |
|---|---|
| Stage 1.7 | Add README screenshots and final Stage 1 polish |
| Stage 2.1 | Create additional Hyper-V nodes: `web-02`, `db-01`, `monitor-01` |
| Stage 2.2 | Apply Linux baseline role to all Linux nodes |
| Stage 2.3 | Add Nginx role for web servers |
| Stage 2.4 | Add PostgreSQL role for database server |
| Stage 2.5 | Add monitoring basics |
| Stage 3 | Advanced Ansible: templates, handlers, Vault, tags |
| Stage 4 | Terraform foundations |
| Stage 5 | CloudFormation foundations |
| Stage 6 | CI/CD and final automation platform documentation |

---

## Key Learning Outcomes

This project demonstrates practical experience with:

- Linux automation control environment setup
- Hyper-V private lab networking
- WSL to Hyper-V connectivity troubleshooting
- SSH key-based automation access
- Ansible inventory design
- Ansible ad-hoc commands
- Ansible playbooks
- Ansible roles
- group_vars and variable separation
- idempotent automation
- YAML linting
- Ansible linting
- GitHub Actions CI validation
- infrastructure documentation and runbooks

---

## Current Status Summary

```text
The project has completed the first automation foundation phase.

The lab can currently manage web-01 through Ansible using SSH key authentication.
The first reusable Ansible role is implemented.
The project passes local linting and GitHub Actions validation.
```
