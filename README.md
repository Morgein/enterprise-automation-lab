# Enterprise Automation Lab

[![Ansible Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml)

## Project Overview

**Enterprise Automation Lab** is a local infrastructure automation project built with **Kali Linux WSL**, **Hyper-V**, **Ansible**, **GitHub Actions**, and future Infrastructure as Code tooling such as **Terraform** and **AWS CloudFormation**.

The project simulates a small enterprise-style Linux infrastructure environment and demonstrates how infrastructure can be configured, validated, documented, monitored, and gradually automated.

The main goal is to build automation skills step by step: from junior-level Ansible basics to more advanced infrastructure automation patterns.

---

## Current Project Status

Current stage:

```text
Stage 2.6 - Prometheus Node Exporter role
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
| Stage 2.4 | README and CI update after Nginx role | Completed |
| Stage 2.5 | PostgreSQL role for database server | Completed |
| Stage 2.6 | Prometheus Node Exporter role for Linux metrics | Completed |

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
    │   ├── Linux baseline
    │   ├── Nginx
    │   │   └── Custom Ansible-managed index.html
    │   └── Node Exporter
    │       └── http://192.168.100.11:9100/metrics
    │
    ├── web-02
    │   ├── Linux baseline
    │   ├── Nginx
    │   │   └── Custom Ansible-managed index.html
    │   └── Node Exporter
    │       └── http://192.168.100.12:9100/metrics
    │
    ├── db-01
    │   ├── Linux baseline
    │   ├── PostgreSQL
    │   │   └── automation_lab database
    │   └── Node Exporter
    │       └── http://192.168.100.21:9100/metrics
    │
    └── monitor-01
        ├── Linux baseline
        └── Node Exporter
            └── http://192.168.100.31:9100/metrics
```

---

## Monitoring Foundation

The monitoring foundation currently uses **Prometheus Node Exporter**.

Node Exporter is deployed to all Linux nodes and exposes system metrics on port `9100`.

Current Node Exporter endpoints:

| Hostname | IP Address | Metrics Endpoint |
|---|---:|---|
| `web-01` | `192.168.100.11` | `http://192.168.100.11:9100/metrics` |
| `web-02` | `192.168.100.12` | `http://192.168.100.12:9100/metrics` |
| `db-01` | `192.168.100.21` | `http://192.168.100.21:9100/metrics` |
| `monitor-01` | `192.168.100.31` | `http://192.168.100.31:9100/metrics` |

Node Exporter exposes metrics such as:

```text
CPU metrics
memory metrics
disk metrics
filesystem metrics
network metrics
system load metrics
boot time metrics
```

Future monitoring stages will add:

```text
Prometheus server on monitor-01
Grafana on monitor-01
Prometheus scrape configuration
Grafana dashboards
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
| PostgreSQL | Database server deployed to `db-01` |
| community.postgresql | Ansible collection for PostgreSQL automation |
| Prometheus Node Exporter | Linux system metrics exporter |
| systemd | Service management on Linux nodes |
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
│   ├── requirements.yml
│   ├── inventories/
│   │   └── dev/
│   │       ├── hosts.ini
│   │       └── group_vars/
│   │           ├── database.yml
│   │           └── linux.yml
│   ├── playbooks/
│   │   ├── 01-bootstrap-linux.yml
│   │   ├── 02-apply-linux-baseline.yml
│   │   ├── 03-deploy-nginx.yml
│   │   ├── 04-deploy-postgresql.yml
│   │   └── 05-deploy-node-exporter.yml
│   └── roles/
│       ├── linux_baseline/
│       │   ├── defaults/
│       │   ├── handlers/
│       │   ├── meta/
│       │   └── tasks/
│       ├── nginx/
│       │   ├── defaults/
│       │   ├── handlers/
│       │   ├── meta/
│       │   ├── tasks/
│       │   └── templates/
│       ├── postgresql/
│       │   ├── defaults/
│       │   ├── handlers/
│       │   ├── meta/
│       │   └── tasks/
│       └── node_exporter/
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

The `database` group is used for PostgreSQL deployment.

The `monitoring` group is reserved for monitoring services such as Prometheus and Grafana.

---

## Ansible Collections

The project uses an Ansible collection for PostgreSQL automation.

Collection requirements are stored in:

```text
ansible/requirements.yml
```

Current content:

```yaml
---
collections:
  - name: community.postgresql
```

The collection is installed locally with:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml -p ./collections --force
```

Downloaded collections are not committed to the repository.

The project commits the dependency definition file:

```text
ansible/requirements.yml
```

but ignores:

```text
ansible/collections/
```

This keeps the repository clean and reproducible.

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

### postgresql

Path:

```text
ansible/roles/postgresql/
```

Purpose:

```text
Deploy and validate PostgreSQL on the database server.
```

The role performs:

- PostgreSQL package installation
- PostgreSQL service enablement
- PostgreSQL service running-state validation
- `automation_lab` database creation
- PostgreSQL version validation
- PostgreSQL database query validation

Target group:

```text
database
```

Current database created by the role:

```text
automation_lab
```

---

### node_exporter

Path:

```text
ansible/roles/node_exporter/
```

Purpose:

```text
Deploy Prometheus Node Exporter on all Linux nodes.
```

The role performs:

- Node Exporter system group creation
- Node Exporter system user creation
- Node Exporter release archive download
- archive extraction
- binary installation to `/usr/local/bin/node_exporter`
- systemd service deployment from a Jinja2 template
- service enablement and startup
- local `/metrics` endpoint validation
- service state validation with `service_facts` and `assert`

Target group:

```text
linux
```

Node Exporter exposes metrics on:

```text
0.0.0.0:9100
```

---

## Playbooks

| Playbook | Purpose |
|---|---|
| `ansible/playbooks/01-bootstrap-linux.yml` | Initial bootstrap playbook |
| `ansible/playbooks/02-apply-linux-baseline.yml` | Apply Linux baseline role |
| `ansible/playbooks/03-deploy-nginx.yml` | Deploy Nginx to web servers |
| `ansible/playbooks/04-deploy-postgresql.yml` | Deploy PostgreSQL to database server |
| `ansible/playbooks/05-deploy-node-exporter.yml` | Deploy Prometheus Node Exporter to all Linux nodes |

---

## Validation

The project includes local and automated validation.

### Local Static Validation

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
ansible-playbook playbooks/04-deploy-postgresql.yml --syntax-check
ansible-playbook playbooks/05-deploy-node-exporter.yml --syntax-check
```

---

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

Deploy PostgreSQL:

```bash
ansible-playbook playbooks/04-deploy-postgresql.yml
```

Deploy Node Exporter:

```bash
ansible-playbook playbooks/05-deploy-node-exporter.yml
```

---

### Nginx Validation

Validate Nginx HTTP response from Kali WSL:

```bash
curl -s http://192.168.100.11 | grep "Enterprise Automation Lab"
curl -s http://192.168.100.12 | grep "Enterprise Automation Lab"
```

---

### PostgreSQL Validation

Validate PostgreSQL service:

```bash
ansible database -m command -a "systemctl is-active postgresql"
ansible database -m command -a "systemctl is-enabled postgresql"
```

Validate PostgreSQL database:

```bash
ansible database -m command -a "sudo -u postgres psql -tAc \"SELECT datname FROM pg_database WHERE datname='automation_lab';\""
```

---

### Node Exporter Validation

Validate Node Exporter services:

```bash
ansible linux -m command -a "systemctl is-active node_exporter"
ansible linux -m command -a "systemctl is-enabled node_exporter"
```

Validate Node Exporter HTTP endpoints from Kali WSL:

```bash
curl -s http://192.168.100.11:9100/metrics | head
curl -s http://192.168.100.12:9100/metrics | head
curl -s http://192.168.100.21:9100/metrics | head
curl -s http://192.168.100.31:9100/metrics | head
```

Expected output contains Prometheus-style metrics:

```text
# HELP
# TYPE
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
- required Ansible collection installation from `requirements.yml`

Current playbooks checked by CI:

```text
01-bootstrap-linux.yml
02-apply-linux-baseline.yml
03-deploy-nginx.yml
04-deploy-postgresql.yml
05-deploy-node-exporter.yml
```

---

## Current Working Validation Results

The current local lab validates successfully:

```text
Ansible ping to all nodes:          successful
SSH key login:                      successful
Linux baseline role:                successful
Linux baseline idempotency:         changed=0
Nginx role:                         successful
Nginx idempotency:                  changed=0
Nginx HTTP response:                successful
PostgreSQL role:                    successful
PostgreSQL idempotency:             changed=0
PostgreSQL service state:           active and enabled
PostgreSQL database validation:     automation_lab exists
Node Exporter role:                 successful
Node Exporter idempotency:          changed=0
Node Exporter service state:        active and enabled
Node Exporter metrics endpoints:    reachable on port 9100
yamllint:                           successful
ansible-lint:                       successful
GitHub Actions:                     successful after workflow validation
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
| `docs/runbooks/stage-02-05-postgresql-role.md` | PostgreSQL role for database server |
| `docs/runbooks/stage-02-06-node-exporter-role.md` | Prometheus Node Exporter role for Linux metrics |
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
docs/screenshots/stage-02-postgresql-role/
docs/screenshots/stage-02-node-exporter-role/
```

Screenshots are used as evidence that the local lab was configured and validated successfully.

---

## Project Roadmap

Planned next stages:

| Stage | Goal |
|---|---|
| Stage 2.7 | Prometheus server role for `monitor-01` |
| Stage 2.8 | Grafana role for `monitor-01` |
| Stage 2.9 | Prometheus scrape configuration for all Node Exporter targets |
| Stage 2.10 | Monitoring validation and dashboard screenshots |
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
- Ansible collections
- group_vars and variable separation
- Jinja2 templates
- systemd service management
- idempotent automation
- multi-node automation
- service-specific role design
- PostgreSQL automation
- Linux metrics exposure with Node Exporter
- monitoring foundation design
- YAML linting
- Ansible linting
- GitHub Actions CI validation
- infrastructure documentation and runbooks

---

## Current Status Summary

```text
The project has completed the first multi-node automation and monitoring foundation phase.

The lab can manage all Linux nodes through Ansible using SSH key authentication.
The Linux baseline role is applied to all nodes.
The Nginx role is applied to web servers.
The PostgreSQL role is applied to the database server.
The Node Exporter role is applied to all Linux nodes.
All Linux nodes expose Prometheus-compatible metrics on port 9100.
The project passes local linting and GitHub Actions validation.
```