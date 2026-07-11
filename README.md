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
Stage 2.4 - README and CI update after Nginx role
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
| Stage 1.6 | README and project presentation improvements | Completed |
| Stage 2.1 | Additional Hyper-V managed nodes | Completed |
| Stage 2.2 | Linux baseline role applied to all Linux nodes | Completed |
| Stage 2.3 | Nginx role for web servers | Completed |
| Stage 2.4 | README and CI update after Nginx role | In Progress |

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
        ├── web-02      192.168.100.12
        ├── db-01       192.168.100.21
        └── monitor-01  192.168.100.31
```

---

## Service Architecture

Current service layout:

```text
Kali Linux WSL
    |
    | Ansible / SSH
    v
Hyper-V Linux Nodes
    |
    ├── web-01
    │   └── Nginx
    │       └── Custom Ansible-managed index.html
    │
    ├── web-02
    │   └── Nginx
    │       └── Custom Ansible-managed index.html
    │
    ├── db-01
    │   └── Database role planned
    │
    └── monitor-01
        └── Monitoring role planned
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
| DNS | `1.1.1.1`, `8.8.8.8` |

Node IP plan:

| Hostname | IP Address | Role |
|---|---:|---|
| `web-01` | `192.168.100.11` | First web server |
| `web-02` | `192.168.100.12` | Second web server |
| `db-01` | `192.168.100.21` | Database server |
| `monitor-01` | `192.168.100.31` | Monitoring server |

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
| Jinja2 Templates | Dynamic file generation |
| SSH Keys | Secure authentication from control node to managed nodes |
| Nginx | Web server role deployed to web nodes |
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
│   │   ├── 02-apply-linux-baseline.yml
│   │   └── 03-deploy-nginx.yml
│   └── roles/
│       ├── linux_baseline/
│       │   ├── defaults/
│       │   ├── handlers/
│       │   ├── meta/
│       │   └── tasks/
│       └── nginx/
│           ├── defaults/
│           ├── handlers/
│           ├── meta/
│           ├── tasks/
│           └── templates/
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

The `linux` group contains all managed Linux nodes.

The `web` group is used for Nginx deployment.

---

## Ansible Roles

### linux_baseline

Path:

```text
ansible/roles/linux_baseline/
```

Purpose:

```text
Apply common baseline configuration to all Linux nodes.
```

The role performs:

- host information display
- APT package cache update
- baseline package installation
- SSH service validation
- hostname validation

Target group:

```text
linux
```

---

### nginx

Path:

```text
ansible/roles/nginx/
```

Purpose:

```text
Deploy and manage Nginx on web servers.
```

The role performs:

- Nginx package installation
- web root directory management
- custom `index.html` deployment through Jinja2 template
- Nginx service enablement
- local HTTP response validation

Target group:

```text
web
```

---

## Playbooks

| Playbook | Purpose |
|---|---|
| `ansible/playbooks/01-bootstrap-linux.yml` | Initial bootstrap playbook |
| `ansible/playbooks/02-apply-linux-baseline.yml` | Apply Linux baseline role |
| `ansible/playbooks/03-deploy-nginx.yml` | Deploy Nginx to web servers |

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
ansible-playbook playbooks/03-deploy-nginx.yml --syntax-check
```

### Runtime Validation

Validate all Linux nodes:

```bash
cd ansible
ansible linux -m ping
```

Apply Linux baseline:

```bash
ansible-playbook playbooks/02-apply-linux-baseline.yml
```

Deploy Nginx:

```bash
ansible-playbook playbooks/03-deploy-nginx.yml
```

Validate HTTP response from Kali WSL:

```bash
curl -s http://192.168.100.11 | grep "Enterprise Automation Lab"
curl -s http://192.168.100.12 | grep "Enterprise Automation Lab"
```

---

## GitHub Actions Validation

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
- syntax of all current Ansible playbooks

Current playbooks checked by CI:

```text
01-bootstrap-linux.yml
02-apply-linux-baseline.yml
03-deploy-nginx.yml
```

---

## Current Working Validation Results

The current local lab validates successfully:

```text
Ansible ping to all nodes:        successful
SSH key login:                    successful
Linux baseline role:              successful
Linux baseline idempotency:       changed=0
Nginx role:                       successful
Nginx idempotency:                changed=0
Nginx HTTP response:              successful
yamllint:                         successful
ansible-lint:                     successful
GitHub Actions:                   successful
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
| `docs/runbooks/stage-02-01-create-additional-managed-nodes.md` | Additional VM creation |
| `docs/runbooks/stage-02-02-apply-baseline-to-all-linux-nodes.md` | Baseline role applied to all nodes |
| `docs/runbooks/stage-02-03-nginx-role.md` | Nginx role for web servers |
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
docs/screenshots/stage-02-multi-node-automation/
docs/screenshots/stage-02-nginx-role/
```

Screenshots are used as evidence that the local lab was configured and validated successfully.

---

## Project Roadmap

Planned next stages:

| Stage | Goal |
|---|---|
| Stage 2.5 | PostgreSQL role for `db-01` |
| Stage 2.6 | Monitoring role for `monitor-01` |
| Stage 2.7 | Nginx reverse proxy or simple load balancing |
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
- Jinja2 templates
- idempotent automation
- multi-node automation
- service-specific role design
- YAML linting
- Ansible linting
- GitHub Actions CI validation
- infrastructure documentation and runbooks

---

## Current Status Summary

```text
The project has completed the first multi-node automation phase.

The lab can manage all Linux nodes through Ansible using SSH key authentication.
The Linux baseline role is applied to all nodes.
The Nginx role is applied to web servers.
The project passes local linting and GitHub Actions validation.
```