# Enterprise Automation Lab - Architecture

## 1. Purpose

This document describes the architecture of the Enterprise Automation Lab.

The lab is designed as a local enterprise-style infrastructure automation environment.

It uses:

```text
Windows 11 Host
Hyper-V
Kali Linux WSL
Ubuntu Server VMs
Ansible
Prometheus
Grafana
GitHub Actions
```

The main goal is to practice infrastructure automation, monitoring, validation, and documentation in a realistic multi-node environment.

---

## 2. High-Level Architecture

```text
Windows 11 Host
│
├── Kali Linux WSL
│   └── Automation Control Node
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

The Windows host provides virtualization through Hyper-V.

Kali Linux WSL acts as the automation control workstation.

Ubuntu Server virtual machines act as managed infrastructure nodes.

---

## 3. Host System

The physical host is a Windows 11 machine running Hyper-V.

The host is responsible for:

```text
running the Hyper-V virtual machines
providing the internal virtual switch
providing NAT connectivity for lab VMs
hosting Kali Linux WSL
```

The host is not directly configured by Ansible in this phase.

Ansible runs from Kali Linux WSL and connects to the Linux VMs through SSH.

---

## 4. Control Node

The control node is:

```text
Kali Linux WSL
```

Its purpose is to manage the lab infrastructure.

Installed tools:

```text
git
ssh
python
ansible
ansible-lint
yamllint
ansible-galaxy
```

The control node stores:

```text
Ansible inventory
Ansible playbooks
Ansible roles
Ansible collections requirements
project documentation
validation commands
Git repository
```

The control node connects to all managed Linux nodes using SSH key authentication.

---

## 5. Hyper-V Network Design

The lab uses a dedicated Hyper-V internal NAT network.

| Component | Value |
|---|---|
| Hyper-V Switch | `EA-LAB-Internal` |
| NAT Name | `EA-LAB-NAT` |
| Subnet | `192.168.100.0/24` |
| Gateway | `192.168.100.1` |
| DNS Servers | `1.1.1.1`, `8.8.8.8` |

Network purpose:

```text
isolate the lab from the physical network
allow VMs to communicate with each other
allow VMs to reach the internet through NAT
allow WSL to access VMs by static IP
```

---

## 6. IP Address Plan

| Hostname | IP Address | Role |
|---|---:|---|
| `web-01` | `192.168.100.11` | First web server |
| `web-02` | `192.168.100.12` | Second web server |
| `db-01` | `192.168.100.21` | Database server |
| `monitor-01` | `192.168.100.31` | Monitoring server |

All nodes are placed in the same lab subnet:

```text
192.168.100.0/24
```

This keeps the first phase simple and easy to troubleshoot.

---

## 7. Managed Nodes

### web-01

```text
Hostname: web-01
IP:       192.168.100.11
Group:    web
```

Services:

```text
Linux baseline
Nginx
Node Exporter
```

Purpose:

```text
acts as the first managed web server
serves Ansible-managed Nginx content
exports Linux metrics to Prometheus
```

---

### web-02

```text
Hostname: web-02
IP:       192.168.100.12
Group:    web
```

Services:

```text
Linux baseline
Nginx
Node Exporter
```

Purpose:

```text
acts as the second managed web server
demonstrates multi-node web automation
exports Linux metrics to Prometheus
```

---

### db-01

```text
Hostname: db-01
IP:       192.168.100.21
Group:    database
```

Services:

```text
Linux baseline
PostgreSQL
Node Exporter
```

Purpose:

```text
acts as the database server
hosts the automation_lab PostgreSQL database
exports Linux metrics to Prometheus
```

---

### monitor-01

```text
Hostname: monitor-01
IP:       192.168.100.31
Group:    monitoring
```

Services:

```text
Linux baseline
Node Exporter
Prometheus
Grafana
```

Purpose:

```text
acts as the monitoring server
collects metrics from all Linux nodes
provides Prometheus UI
provides Grafana UI
hosts provisioned monitoring dashboards
```

---

## 8. Ansible Inventory Architecture

Inventory file:

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

Inventory group meaning:

| Group | Purpose |
|---|---|
| `web` | Web servers managed by the Nginx role |
| `database` | Database servers managed by the PostgreSQL role |
| `monitoring` | Monitoring servers managed by Prometheus and Grafana roles |
| `linux` | Parent group containing all Linux managed nodes |

The `linux` group allows common roles to be applied to all Linux nodes.

Examples:

```text
linux_baseline
node_exporter
```

---

## 9. SSH Access Model

Ansible connects to managed nodes through SSH.

SSH user:

```text
automation
```

SSH key:

```text
~/.ssh/enterprise_automation_lab
```

The automation user has passwordless sudo on managed nodes.

This allows Ansible to perform privileged operations such as:

```text
installing packages
managing systemd services
creating system users
writing files under /etc
writing files under /usr/local/bin
writing files under /var/lib
```

---

## 10. Ansible Role Architecture

The project uses role-based automation.

Current roles:

```text
linux_baseline
nginx
postgresql
node_exporter
prometheus
grafana
```

Role layout pattern:

```text
role_name/
├── defaults/
│   └── main.yml
├── handlers/
│   └── main.yml
├── meta/
│   └── main.yml
├── tasks/
│   └── main.yml
└── templates/
```

Not every role needs templates.

Roles that generate files dynamically use Jinja2 templates.

---

## 11. Service Deployment Architecture

```text
Kali Linux WSL
    |
    | SSH / Ansible
    v
Managed Linux Nodes
    |
    ├── web-01
    │   ├── Linux baseline
    │   ├── Nginx
    │   └── Node Exporter
    │
    ├── web-02
    │   ├── Linux baseline
    │   ├── Nginx
    │   └── Node Exporter
    │
    ├── db-01
    │   ├── Linux baseline
    │   ├── PostgreSQL
    │   └── Node Exporter
    │
    └── monitor-01
        ├── Linux baseline
        ├── Node Exporter
        ├── Prometheus
        └── Grafana
```

Ansible is responsible for installing, configuring, validating, and documenting these services.

---

## 12. Web Layer Architecture

The web layer contains:

```text
web-01
web-02
```

Each web server runs:

```text
Nginx
```

Nginx serves a custom Ansible-managed `index.html`.

The Nginx role manages:

```text
Nginx package installation
web root directory
index.html template
Nginx service state
HTTP validation
```

Web endpoints:

```text
http://192.168.100.11
http://192.168.100.12
```

---

## 13. Database Layer Architecture

The database layer contains:

```text
db-01
```

The database server runs:

```text
PostgreSQL
```

The PostgreSQL role manages:

```text
PostgreSQL package installation
PostgreSQL service state
PostgreSQL database creation
PostgreSQL version validation
PostgreSQL query validation
```

Current database:

```text
automation_lab
```

The database is currently used as an infrastructure service demonstration.

Application integration may be added in later project stages.

---

## 14. Monitoring Layer Architecture

The monitoring layer contains:

```text
Node Exporter
Prometheus
Grafana
Provisioned Grafana Dashboard
```

High-level monitoring flow:

```text
Linux nodes
  -> Node Exporter
  -> Prometheus
  -> Grafana
  -> Enterprise Linux Overview Dashboard
```

Detailed monitoring architecture:

```text
web-01:9100
web-02:9100
db-01:9100
monitor-01:9100
        |
        v
monitor-01:9090
Prometheus
        |
        v
monitor-01:3000
Grafana
        |
        v
Enterprise Linux Overview Dashboard
```

---

## 15. Node Exporter Architecture

Node Exporter runs on every Linux node.

Hosts:

```text
web-01
web-02
db-01
monitor-01
```

Node Exporter listens on:

```text
0.0.0.0:9100
```

Metrics endpoints:

```text
http://192.168.100.11:9100/metrics
http://192.168.100.12:9100/metrics
http://192.168.100.21:9100/metrics
http://192.168.100.31:9100/metrics
```

Node Exporter exposes Linux system metrics such as:

```text
CPU metrics
memory metrics
filesystem metrics
network metrics
load average
kernel and system information
```

Prometheus scrapes these endpoints.

---

## 16. Prometheus Architecture

Prometheus runs on:

```text
monitor-01
```

Prometheus listens on:

```text
0.0.0.0:9090
```

Prometheus endpoints:

```text
http://192.168.100.31:9090
http://192.168.100.31:9090/-/ready
http://192.168.100.31:9090/targets
http://192.168.100.31:9090/api/v1/targets
```

Prometheus scrape jobs:

```text
prometheus
node_exporter
```

The `prometheus` job scrapes Prometheus itself.

The `node_exporter` job scrapes all Linux Node Exporter targets.

Current Node Exporter targets:

```text
192.168.100.11:9100
192.168.100.12:9100
192.168.100.21:9100
192.168.100.31:9100
```

Prometheus configuration is generated from an Ansible Jinja2 template.

Prometheus configuration file:

```text
/etc/prometheus/prometheus.yml
```

Prometheus validates its configuration with:

```text
promtool check config
```

before deployment.

---

## 17. Grafana Architecture

Grafana runs on:

```text
monitor-01
```

Grafana listens on:

```text
0.0.0.0:3000
```

Grafana endpoints:

```text
http://192.168.100.31:3000
http://192.168.100.31:3000/api/health
```

Grafana is configured by Ansible.

The Grafana role manages:

```text
Grafana package installation
Grafana APT repository
Grafana service state
Prometheus data source provisioning
dashboard provider provisioning
Linux overview dashboard provisioning
Grafana health validation
```

---

## 18. Grafana Provisioning Architecture

Grafana provisioning is used for reproducible configuration.

The project currently provisions:

```text
Prometheus data source
Enterprise Linux Overview dashboard
```

Prometheus data source file:

```text
/etc/grafana/provisioning/datasources/prometheus.yml
```

Dashboard provider file:

```text
/etc/grafana/provisioning/dashboards/linux-overview.yml
```

Dashboard JSON file:

```text
/var/lib/grafana/dashboards/linux-overview.json
```

Provisioned Grafana folder:

```text
Enterprise Automation Lab
```

Provisioned dashboard:

```text
Enterprise Linux Overview
```

Dashboard panels:

```text
Node Exporter Targets UP
CPU Usage by Instance
Memory Available by Instance
Root Filesystem Free Space
System Load 1m
Network Receive Traffic
```

---

## 19. Monitoring Data Flow

The monitoring data flow is:

```text
Linux operating system
    |
    | exposes kernel/system metrics
    v
Node Exporter
    |
    | HTTP /metrics endpoint
    v
Prometheus
    |
    | PromQL queries
    v
Grafana
    |
    | dashboard panels
    v
User
```

Simple explanation:

```text
Node Exporter exposes metrics.
Prometheus collects metrics.
Grafana visualizes metrics.
```

---

## 20. Automation Flow

The automation flow is:

```text
User runs Ansible command in Kali WSL
    |
    v
Ansible reads inventory
    |
    v
Ansible connects to target hosts over SSH
    |
    v
Ansible applies roles
    |
    v
Services are installed and configured
    |
    v
Validation tasks confirm service health
```

Example:

```text
ansible-playbook playbooks/07-deploy-grafana.yml
```

Flow:

```text
Ansible
  -> connects to monitor-01
  -> installs Grafana
  -> configures Prometheus datasource
  -> deploys dashboard provider
  -> deploys dashboard JSON
  -> restarts Grafana if needed
  -> validates Grafana health endpoint
```

---

## 21. CI Validation Architecture

The project uses GitHub Actions for static validation.

Workflow file:

```text
.github/workflows/ansible-validation.yml
```

The CI pipeline validates:

```text
YAML formatting
Ansible best practices
Ansible playbook syntax
Ansible collection installation
```

Current validation tools:

```text
yamllint
ansible-lint
ansible-playbook --syntax-check
ansible-galaxy collection install
```

Current playbooks checked by CI:

```text
01-bootstrap-linux.yml
02-apply-linux-baseline.yml
03-deploy-nginx.yml
04-deploy-postgresql.yml
05-deploy-node-exporter.yml
06-deploy-prometheus.yml
07-deploy-grafana.yml
```

CI validates code quality before changes are considered stable.

---

## 22. Repository Structure

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
│   │           ├── linux.yml
│   │           └── monitoring.yml
│   ├── playbooks/
│   │   ├── 01-bootstrap-linux.yml
│   │   ├── 02-apply-linux-baseline.yml
│   │   ├── 03-deploy-nginx.yml
│   │   ├── 04-deploy-postgresql.yml
│   │   ├── 05-deploy-node-exporter.yml
│   │   ├── 06-deploy-prometheus.yml
│   │   └── 07-deploy-grafana.yml
│   └── roles/
│       ├── linux_baseline/
│       ├── nginx/
│       ├── postgresql/
│       ├── node_exporter/
│       ├── prometheus/
│       └── grafana/
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

## 23. Current Service Ports

| Service | Host | Port | URL |
|---|---|---:|---|
| Nginx | `web-01` | `80` | `http://192.168.100.11` |
| Nginx | `web-02` | `80` | `http://192.168.100.12` |
| Node Exporter | `web-01` | `9100` | `http://192.168.100.11:9100/metrics` |
| Node Exporter | `web-02` | `9100` | `http://192.168.100.12:9100/metrics` |
| Node Exporter | `db-01` | `9100` | `http://192.168.100.21:9100/metrics` |
| Node Exporter | `monitor-01` | `9100` | `http://192.168.100.31:9100/metrics` |
| Prometheus | `monitor-01` | `9090` | `http://192.168.100.31:9090` |
| Grafana | `monitor-01` | `3000` | `http://192.168.100.31:3000` |

---

## 24. Security Model

Current lab security model:

```text
SSH key authentication is used for Ansible access.
Passwordless sudo is configured for the automation user.
Services run under dedicated system users where appropriate.
Prometheus runs as the prometheus user.
Node Exporter runs as the node_exporter user.
Grafana runs as the grafana service user.
```

Current limitations:

```text
Grafana still uses default first-login credentials until changed manually.
No TLS is configured for internal service UIs.
No firewall hardening is implemented yet.
No Ansible Vault secrets are used yet.
```

Planned improvements:

```text
Ansible Vault for secrets
Grafana admin password management
firewall rules
environment separation
backup and restore automation
```

---

## 25. Current Completed Architecture State

The current architecture supports:

```text
multi-node Ansible automation
Linux baseline configuration
web server deployment
database server deployment
Linux metrics collection
Prometheus monitoring
Grafana visualization
Grafana dashboard provisioning
GitHub Actions static validation
documentation and runbooks
```

Current completed monitoring chain:

```text
web-01 / web-02 / db-01 / monitor-01
    -> Node Exporter
    -> Prometheus
    -> Grafana
    -> Enterprise Linux Overview Dashboard
```

This represents the completed monitoring layer for the current lab phase.

---

## 26. Future Architecture Direction

Planned future architecture extensions:

```text
Advanced Ansible features
Ansible Vault
environment separation
Terraform infrastructure modules
AWS CloudFormation templates
CI/CD improvements
backup automation
security hardening
cloud deployment scenarios
```

The current local lab acts as the foundation for those future stages.