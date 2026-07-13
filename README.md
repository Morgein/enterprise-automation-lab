# Enterprise Automation Lab

[![Ansible Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml)

## Project Overview

**Enterprise Automation Lab** is a local infrastructure automation project built with **Kali Linux WSL**, **Hyper-V**, **Ansible**, **GitHub Actions**, and future Infrastructure as Code tooling such as **Terraform** and **AWS CloudFormation**.

The project simulates a small enterprise-style Linux infrastructure environment and demonstrates how infrastructure can be configured, validated, documented, monitored, visualized, and gradually automated.

The main goal is to build automation skills step by step: from junior-level Ansible basics to more advanced infrastructure automation patterns.

---

## Current Project Status

Current stage:

```text
Stage 3.3 - Environment separation for dev and prod inventories
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
| Stage 2.7 | Prometheus server role for metrics collection | Completed |
| Stage 2.8 | Grafana role for metrics visualization | Completed |
| Stage 2.9 | Grafana dashboard provisioning | Completed |
| Stage 2.10 | Monitoring stack final validation | Completed |
| Stage 3.1 | Site playbook and operational tags | Completed |
| Stage 3.2 | Ansible Vault secret management | Completed |
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
        ├── Node Exporter
        │   └── http://192.168.100.31:9100/metrics
        ├── Prometheus
        │   ├── Web UI: http://192.168.100.31:9090
        │   ├── Readiness: http://192.168.100.31:9090/-/ready
        │   └── Targets API: http://192.168.100.31:9090/api/v1/targets
        └── Grafana
            ├── Web UI: http://192.168.100.31:3000
            ├── Health API: http://192.168.100.31:3000/api/health
            ├── Prometheus data source provisioned automatically
            └── Enterprise Linux Overview dashboard provisioned automatically
```

---

## Monitoring Architecture

The monitoring stack currently contains:

```text
Node Exporter
Prometheus
Grafana
Provisioned Grafana Dashboard
```

Node Exporter runs on every Linux node and exposes Linux system metrics on port `9100`.

Prometheus runs on `monitor-01` and collects metrics from all Node Exporter endpoints.

Grafana runs on `monitor-01` and visualizes metrics from Prometheus.

The Grafana dashboard is provisioned automatically through Ansible.

```text
web-01:9100
web-02:9100
db-01:9100
monitor-01:9100
        |
        v
monitor-01:9090
Prometheus Server
        |
        v
monitor-01:3000
Grafana
        |
        v
Enterprise Linux Overview Dashboard
```

Current Node Exporter targets:

| Hostname | IP Address | Metrics Endpoint |
|---|---:|---|
| `web-01` | `192.168.100.11` | `http://192.168.100.11:9100/metrics` |
| `web-02` | `192.168.100.12` | `http://192.168.100.12:9100/metrics` |
| `db-01` | `192.168.100.21` | `http://192.168.100.21:9100/metrics` |
| `monitor-01` | `192.168.100.31` | `http://192.168.100.31:9100/metrics` |

Prometheus endpoint:

| Service | Hostname | IP Address | Endpoint |
|---|---|---:|---|
| Prometheus | `monitor-01` | `192.168.100.31` | `http://192.168.100.31:9090` |

Grafana endpoint:

| Service | Hostname | IP Address | Endpoint |
|---|---|---:|---|
| Grafana | `monitor-01` | `192.168.100.31` | `http://192.168.100.31:3000` |

Provisioned Grafana dashboard:

| Folder | Dashboard | Purpose |
|---|---|---|
| `Enterprise Automation Lab` | `Enterprise Linux Overview` | Linux infrastructure metrics overview |

Prometheus scrape jobs currently configured:

```text
prometheus
node_exporter
```

The `prometheus` job scrapes Prometheus itself.

The `node_exporter` job scrapes Linux metrics from all managed Linux nodes.

Grafana uses Prometheus as a provisioned data source.

Grafana dashboard provisioning currently deploys:

```text
/etc/grafana/provisioning/dashboards/linux-overview.yml
/var/lib/grafana/dashboards/linux-overview.json
```

Current provisioned dashboard panels:

```text
Node Exporter Targets UP
CPU Usage by Instance
Memory Available by Instance
Root Filesystem Free Space
System Load 1m
Network Receive Traffic
```
```markdown
Final monitoring validation confirms the complete end-to-end chain:

```text
Linux Nodes
  -> Node Exporter
  -> Prometheus
  -> Grafana
  -> Enterprise Linux Overview Dashboard
```

Validated monitoring components:

```text
Node Exporter services active and enabled
Node Exporter metrics endpoints reachable
Prometheus service active and enabled
Prometheus readiness endpoint healthy
Prometheus targets API healthy
Prometheus UI shows targets UP
Prometheus query engine returns metrics
Grafana service active and enabled
Grafana health endpoint healthy
Grafana Prometheus datasource provisioned
Grafana dashboard provisioned and displaying metrics
```
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
| Ansible Vault | Local secret management for PostgreSQL and Grafana credentials |
| ansible-lint | Ansible best-practice validation |
| group_vars | Environment-specific variables |
| Jinja2 Templates | Dynamic file generation |
| SSH Keys | Secure authentication from control node to managed nodes |
| Nginx | Web server role deployed to web nodes |
| PostgreSQL | Database server deployed to `db-01` |
| community.postgresql | Ansible collection for PostgreSQL automation |
| Prometheus Node Exporter | Linux system metrics exporter |
| Prometheus | Metrics collection and time-series monitoring server |
| promtool | Prometheus configuration validation |
| Grafana | Metrics visualization and dashboards |
| Grafana provisioning | Automated data source and dashboard configuration |
| PromQL | Metrics query language used by Prometheus and Grafana panels |
| systemd | Service management on Linux nodes |
| yamllint | YAML syntax and formatting validation |
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
│   ├── examples/
│   │   └── vault.yml.example
│   ├── inventories/
│   │   ├── dev/
│   │   │   ├── hosts.ini
│   │   │   └── group_vars/
│   │   │       ├── all/
│   │   │       │   └── main.yml
│   │   │       ├── database.yml
│   │   │       ├── linux.yml
│   │   │       └── monitoring.yml
│   │   └── prod/
│   │       ├── hosts.ini
│   │       └── group_vars/
│   │           ├── all/
│   │           │   └── main.yml
│   │           ├── database.yml
│   │           ├── linux.yml
│   │           └── monitoring.yml
│   ├── playbooks/
│   │   ├── site.yml
│   │   ├── 01-bootstrap-linux.yml
│   │   ├── 02-apply-linux-baseline.yml
│   │   ├── 03-deploy-nginx.yml
│   │   ├── 04-deploy-postgresql.yml
│   │   ├── 05-deploy-node-exporter.yml
│   │   ├── 06-deploy-prometheus.yml
│   │   └── 07-deploy-grafana.yml
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
│       ├── node_exporter/
│       │   ├── defaults/
│       │   ├── handlers/
│       │   ├── meta/
│       │   ├── tasks/
│       │   └── templates/
│       ├── prometheus/
│       │   ├── defaults/
│       │   ├── handlers/
│       │   ├── meta/
│       │   ├── tasks/
│       │   └── templates/
│       └── grafana/
│           ├── defaults/
│           ├── handlers/
│           ├── meta/
│           ├── tasks/
│           └── templates/
│               ├── dashboard-provider.yml.j2
│               ├── linux-overview-dashboard.json.j2
│               └── prometheus-datasource.yml.j2
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

The `monitoring` group is used for Prometheus, Grafana, and future monitoring services.

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

### prometheus

Path:

```text
ansible/roles/prometheus/
```

Purpose:

```text
Deploy Prometheus server on the monitoring node.
```

The role performs:

- Prometheus system group creation
- Prometheus system user creation
- configuration directory creation
- data directory creation
- Prometheus release archive download
- archive extraction
- `prometheus` binary installation
- `promtool` binary installation
- Prometheus configuration deployment from a Jinja2 template
- configuration validation with `promtool`
- systemd service deployment from a Jinja2 template
- service enablement and startup
- readiness endpoint validation
- targets API validation
- service state validation with `service_facts` and `assert`

Target group:

```text
monitoring
```

Prometheus listens on:

```text
0.0.0.0:9090
```

Current Prometheus scrape targets:

```text
192.168.100.11:9100
192.168.100.12:9100
192.168.100.21:9100
192.168.100.31:9100
```

---

### grafana

Path:

```text
ansible/roles/grafana/
```

Purpose:

```text
Deploy Grafana on the monitoring node, provision Prometheus as a data source and provision Linux monitoring dashboards.
```

The role performs:

- prerequisite package installation
- Grafana APT repository key installation
- Grafana APT repository configuration
- Grafana package installation
- Prometheus data source provisioning
- Grafana dashboard provider provisioning
- Linux overview dashboard provisioning
- Grafana service enablement and startup
- Grafana TCP port readiness wait
- Grafana health endpoint validation
- service state validation with `service_facts` and `assert`

Target group:

```text
monitoring
```

Grafana listens on:

```text
0.0.0.0:3000
```

Prometheus data source is provisioned through:

```text
/etc/grafana/provisioning/datasources/prometheus.yml
```

Dashboard provider is provisioned through:

```text
/etc/grafana/provisioning/dashboards/linux-overview.yml
```

Dashboard JSON is provisioned through:

```text
/var/lib/grafana/dashboards/linux-overview.json
```

Current provisioned dashboard:

```text
Enterprise Automation Lab / Enterprise Linux Overview
```

Current Prometheus data source URL:

```text
http://127.0.0.1:9090
```

---

## Playbooks

| Playbook | Purpose |
|---|---|
| `ansible/playbooks/site.yml` | Main operational playbook that imports the current infrastructure stack |
| `ansible/playbooks/01-bootstrap-linux.yml` | Initial bootstrap playbook |
| `ansible/playbooks/02-apply-linux-baseline.yml` | Apply Linux baseline role |
| `ansible/playbooks/03-deploy-nginx.yml` | Deploy Nginx to web servers |
| `ansible/playbooks/04-deploy-postgresql.yml` | Deploy PostgreSQL to database server |
| `ansible/playbooks/05-deploy-node-exporter.yml` | Deploy Prometheus Node Exporter to all Linux nodes |
| `ansible/playbooks/06-deploy-prometheus.yml` | Deploy Prometheus server to the monitoring node |
| `ansible/playbooks/07-deploy-grafana.yml` | Deploy Grafana and provision dashboards on the monitoring node |

---

## Site Playbook and Operational Tags

The project now includes a main Ansible site playbook:

```text
ansible/playbooks/site.yml
```

The site playbook imports the main infrastructure playbooks and provides one central operational entrypoint.

Full current stack deployment:

```bash
ansible-playbook playbooks/site.yml
```

Selective deployment with tags:

```bash
ansible-playbook playbooks/site.yml --tags monitoring
ansible-playbook playbooks/site.yml --tags grafana
ansible-playbook playbooks/site.yml --tags web
ansible-playbook playbooks/site.yml --tags database
```

Available operational tags include:

```text
baseline
common
dashboards
database
grafana
linux
metrics
monitoring
nginx
node_exporter
postgresql
stage_02
web
```

The site playbook allows the lab to support both execution models:

```text
individual playbook execution
central site.yml execution with tags
```

This improves operational control and makes the Ansible structure closer to production-style automation.
---

## Ansible Vault Secret Management

The project now includes a local Ansible Vault workflow for secret management.

Real secrets are stored locally in an encrypted Vault file:

```text
ansible/inventories/dev/group_vars/all/vault.yml
```

The Vault password file is stored locally:

```text
ansible/.vault_pass.txt
```

Both files are excluded from Git.

The repository includes only a safe example file:

```text
ansible/examples/vault.yml.example
```

Current Vault-managed values:

```text
PostgreSQL application user password
Grafana admin password
```

The PostgreSQL role can create users from Vault-provided variables.

The Grafana role can validate and reset the admin password from Vault-provided variables.

Sensitive Ansible tasks use:

```yaml
no_log: true
```

to avoid leaking passwords into terminal output.

Before running Vault-dependent playbooks locally, export:

```bash
cd ansible
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt
```

The real Vault file and Vault password file must never be committed to GitHub.
---
## Environment Separation

The project now supports separate Ansible inventories for development and production-like environments.

Current environments:

```text
ansible/inventories/dev/
ansible/inventories/prod/
```

The `dev` inventory represents the real local Hyper-V lab:

```text
192.168.100.0/24
```

The `prod` inventory is a production-like template:

```text
10.20.10.0/24
```

The same roles and playbooks can be validated against both inventories.

Development syntax check:

```bash
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check
```

Production-like syntax check:

```bash
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --syntax-check
```

The production-like inventory is not currently used for runtime deployment.

It is used for:

```text
inventory structure validation
environment variable separation
production-style documentation
future expansion
```

This stage demonstrates the Ansible pattern:

```text
same automation code
different inventories
different variables
different secrets
different environments
```
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
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/01-bootstrap-linux.yml --syntax-check
ansible-playbook playbooks/02-apply-linux-baseline.yml --syntax-check
ansible-playbook playbooks/03-deploy-nginx.yml --syntax-check
ansible-playbook playbooks/04-deploy-postgresql.yml --syntax-check
ansible-playbook playbooks/05-deploy-node-exporter.yml --syntax-check
ansible-playbook playbooks/06-deploy-prometheus.yml --syntax-check
ansible-playbook playbooks/07-deploy-grafana.yml --syntax-check
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

Deploy Prometheus:

```bash
ansible-playbook playbooks/06-deploy-prometheus.yml
```

Deploy Grafana and dashboards:

```bash
ansible-playbook playbooks/07-deploy-grafana.yml
```

Deploy the full current stack through the site playbook:

```bash
ansible-playbook playbooks/site.yml
```

Deploy only the monitoring stack:

```bash
ansible-playbook playbooks/site.yml --tags monitoring
```

Deploy only Grafana:

```bash
ansible-playbook playbooks/site.yml --tags grafana
```

Deploy only the web layer:

```bash
ansible-playbook playbooks/site.yml --tags web
```

List available operational tags:

```bash
ansible-playbook playbooks/site.yml --list-tags
```
Validate inventory graphs:

```bash
cd ansible
ansible-inventory -i inventories/dev/hosts.ini --graph
ansible-inventory -i inventories/prod/hosts.ini --graph
```

GitHub Vault Validation:
```bash
cd ansible
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/04-deploy-postgresql.yml --syntax-check
ansible-playbook playbooks/07-deploy-grafana.yml --syntax-check
```

Validate site playbook against both inventories:
```bash
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --syntax-check
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

### Prometheus Validation

Validate Prometheus service:

```bash
ansible monitoring -m command -a "systemctl is-active prometheus"
ansible monitoring -m command -a "systemctl is-enabled prometheus"
```

Validate Prometheus readiness endpoint:

```bash
curl -s http://192.168.100.31:9090/-/ready
```

Expected output:

```text
Prometheus Server is Ready.
```

Validate Prometheus targets API:

```bash
curl -s http://192.168.100.31:9090/api/v1/targets | head
```

Open Prometheus UI:

```text
http://192.168.100.31:9090
```

Useful Prometheus queries:

```promql
up
```

```promql
node_uname_info
```

```promql
node_memory_MemAvailable_bytes
```

---

### Grafana Validation

Validate Grafana service:

```bash
ansible monitoring -m command -a "systemctl is-active grafana-server"
ansible monitoring -m command -a "systemctl is-enabled grafana-server"
```

Validate Grafana health endpoint:

```bash
curl -s http://192.168.100.31:3000/api/health
```

Expected output includes:

```text
"database":"ok"
```

Open Grafana UI:

```text
http://192.168.100.31:3000
```

Default first login:

```text
username: admin
password: admin
```

Validate Prometheus data source:

```text
Connections -> Data sources -> Prometheus
```

Validate provisioned dashboard:

```text
Dashboards -> Enterprise Automation Lab -> Enterprise Linux Overview
```

Validate dashboard files on `monitor-01`:

```bash
ansible monitoring -m command -a "ls -la /etc/grafana/provisioning/dashboards"
ansible monitoring -m command -a "ls -la /var/lib/grafana/dashboards"
```

Expected files:

```text
linux-overview.yml
linux-overview.json
```

Validate Prometheus query in Grafana:

```text
Explore -> Prometheus -> up
```

Expected result:

```text
1
```

for healthy scrape targets.

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
- required Ansible collection installation from `requirements.yml`
- syntax of all current Ansible playbooks

Current playbooks checked by CI:

```text
site.yml
site.yml with default/dev inventory
site.yml with explicit dev inventory
site.yml with prod inventory
01-bootstrap-linux.yml
02-apply-linux-baseline.yml
03-deploy-nginx.yml
04-deploy-postgresql.yml
05-deploy-node-exporter.yml
06-deploy-prometheus.yml
07-deploy-grafana.yml
```

---

## Current Working Validation Results

The current local lab validates successfully:

```text
Ansible Vault file encryption:            successful
Vault password file usage:                successful
PostgreSQL Vault user creation:           successful
Grafana Vault admin password management:  successful
Vault secrets excluded from Git:          successful
Vault lint and syntax validation:         successful
Ansible ping to all nodes:              successful
SSH key login:                          successful
Linux baseline role:                    successful
Linux baseline idempotency:             changed=0
Nginx role:                             successful
Nginx idempotency:                      changed=0
Nginx HTTP response:                    successful
PostgreSQL role:                        successful
PostgreSQL idempotency:                 changed=0
PostgreSQL service state:               active and enabled
PostgreSQL database validation:         automation_lab exists
Node Exporter role:                     successful
Node Exporter idempotency:              changed=0
Node Exporter service state:            active and enabled
Node Exporter metrics endpoints:        reachable on port 9100
Prometheus role:                        successful
Prometheus idempotency:                 changed=0
Prometheus service state:               active and enabled
Prometheus readiness endpoint:          successful
Prometheus targets API:                 successful
Grafana role:                           successful
Grafana idempotency:                    changed=0
Grafana service state:                  active and enabled
Grafana health endpoint:                successful
Grafana Prometheus data source:         provisioned
Grafana dashboard provider:             provisioned
Enterprise Linux Overview dashboard:    provisioned
yamllint:                               successful
ansible-lint:                           successful
GitHub Actions:                         successful after workflow validation
Monitoring services final validation:       successful
Node Exporter endpoints final validation:   successful
Prometheus targets final validation:        successful
Prometheus query validation:                successful
Grafana dashboard final validation:         successful
End-to-end monitoring chain validation:     successful
Site playbook syntax check:              successful
Site playbook tag listing:               successful
Monitoring tag execution:                successful
Grafana tag execution:                   successful
Full site playbook execution:            successful
Operational tags validation:             successful
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
| `docs/runbooks/stage-02-07-prometheus-role.md` | Prometheus server role for metrics collection |
| `docs/runbooks/stage-02-08-grafana-role.md` | Grafana role for metrics visualization |
| `docs/runbooks/stage-02-09-grafana-dashboard-provisioning.md` | Grafana dashboard provisioning |
| `docs/runbooks/stage-02-10-monitoring-final-validation.md` | Monitoring stack final validation |
| `docs/runbooks/stage-03-01-site-playbook-and-tags.md` | Site playbook and operational tags |
| `docs/runbooks/stage-03-02-ansible-vault-secret-management.md` | Ansible Vault secret management |
| `docs/runbooks/stage-03-03-environment-separation.md` | Environment separation for dev and prod inventories |
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
docs/screenshots/stage-02-prometheus-role/
docs/screenshots/stage-02-grafana-role/
docs/screenshots/stage-02-grafana-dashboard-provisioning/
docs/screenshots/stage-02-monitoring-final-validation/
docs/screenshots/stage-03-site-playbook-and-tags/
docs/screenshots/stage-03-ansible-vault-secret-management/
docs/screenshots/stage-03-environment-separation/
```

Screenshots are used as evidence that the local lab was configured and validated successfully.

---

## Project Roadmap

Planned next stages:

| Stage | Goal |
|---|---|
| Stage 3.4 | Advanced handlers, pre_tasks and post_tasks |
| Stage 4 | Terraform foundations |
| Stage 5 | CloudFormation foundations |
| Stage 6 | CI/CD and final automation platform documentation |

---

## Key Learning Outcomes

This project demonstrates practical experience with:

- Ansible Vault secret management
- Ansible environment separation
- dev and prod inventory design
- inventory-specific group_vars
- production-like inventory templates
- environment-specific monitoring targets
- encrypted local secrets
- safe Vault example files
- no_log usage for sensitive tasks
- Git secret exclusion workflow
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
- Prometheus metrics collection
- Prometheus configuration validation with promtool
- Grafana installation automation
- Grafana data source provisioning
- Grafana dashboard provisioning
- PromQL dashboard panels
- monitoring foundation design
- YAML linting
- Ansible linting
- GitHub Actions CI validation
- infrastructure documentation and runbooks
- Ansible site playbook design
- operational tags
- selective playbook execution
- centralized Ansible entrypoint

---

## Current Status Summary

```text
The project has completed the first multi-node automation and monitoring visualization phase.

The lab can manage all Linux nodes through Ansible using SSH key authentication.
The Linux baseline role is applied to all nodes.
The Nginx role is applied to web servers.
The PostgreSQL role is applied to the database server.
The Node Exporter role is applied to all Linux nodes.
All Linux nodes expose Prometheus-compatible metrics on port 9100.
The Prometheus role is applied to the monitoring server.
Prometheus collects metrics from all Node Exporter targets.
The Grafana role is applied to the monitoring server.
Grafana is connected to Prometheus through provisioning.
Grafana automatically loads the Enterprise Linux Overview dashboard.
The full monitoring chain has been validated end-to-end.
The completed monitoring flow is Node Exporter -> Prometheus -> Grafana -> Dashboard.
The project passes local linting and GitHub Actions validation.
The project now includes a central site.yml playbook.
The full infrastructure stack can be deployed through one main Ansible entrypoint.
Operational tags allow selective execution of baseline, web, database, monitoring, Grafana and dashboard automation.
The project now supports separate dev and prod Ansible inventories.
The dev inventory represents the real local Hyper-V lab.
The prod inventory is a production-like template for future expansion.
The same site.yml playbook can be syntax-checked against both inventories.
Environment-specific variables are separated through inventory group_vars.
Prometheus targets are now environment-specific.

```