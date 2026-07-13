# Ansible Architecture

## 1. Purpose

This document explains the Ansible architecture of the Enterprise Automation Lab.

It describes how the Ansible part of the project is structured, how the components are connected, and how the automation workflow works.

This document focuses on architecture and design.

For operational commands, use:

```text
docs/runbooks/ansible-operations-guide.md
```

---

## 2. High-Level Architecture

The Ansible architecture is based on a control node and multiple managed Linux nodes.

```text
Kali Linux WSL Control Node
        |
        | SSH
        |
        +-------------------- web-01
        +-------------------- web-02
        +-------------------- db-01
        +-------------------- monitor-01
```

The control node executes Ansible playbooks.

The managed nodes receive configuration through SSH.

---

## 3. Control Node

The control node is:

```text
Kali Linux WSL
```

The control node contains:

```text
Ansible
project repository
inventories
playbooks
roles
Vault configuration
lint configuration
GitHub repository working copy
```

Main project path:

```text
~/enterprise-automation-lab
```

Ansible path:

```text
~/enterprise-automation-lab/ansible
```

---

## 4. Managed Nodes

The development environment uses four managed Linux nodes.

| Host | IP Address | Main Function |
|---|---:|---|
| `web-01` | `192.168.100.11` | Nginx web server |
| `web-02` | `192.168.100.12` | Nginx web server |
| `db-01` | `192.168.100.21` | PostgreSQL database server |
| `monitor-01` | `192.168.100.31` | Prometheus and Grafana monitoring server |

All nodes are grouped under:

```text
linux
```

The `linux` group is used for common configuration and Node Exporter deployment.

---

## 5. Inventory Architecture

The project uses environment-separated inventories.

```text
ansible/inventories/
├── dev/
│   ├── hosts.ini
│   └── group_vars/
└── prod/
    ├── hosts.ini
    └── group_vars/
```

The `dev` inventory represents the real local Hyper-V lab.

The `prod` inventory is a production-like template used for syntax validation and future expansion.

---

## 6. Development Inventory

Development inventory path:

```text
ansible/inventories/dev/hosts.ini
```

Main groups:

```text
web
database
monitoring
linux
```

Logical structure:

```text
linux
├── web
│   ├── web-01
│   └── web-02
├── database
│   └── db-01
└── monitoring
    └── monitor-01
```

The `linux` group is a parent group.

This allows common roles to target all Linux nodes.

---

## 7. Production-Like Inventory

Production-like inventory path:

```text
ansible/inventories/prod/hosts.ini
```

The prod inventory uses placeholder IP addresses:

```text
10.20.10.0/24
```

It is not used for real deployment yet.

It is used for:

```text
environment separation demonstration
syntax validation
future production-style structure
```

Runtime deployment must not be executed against prod until real hosts exist.

---

## 8. Group Variables Architecture

The project uses `group_vars` to separate configuration from role logic.

Example:

```text
ansible/inventories/dev/group_vars/
├── all/
│   ├── main.yml
│   └── vault.yml
├── database.yml
├── linux.yml
└── monitoring.yml
```

Purpose:

| File | Purpose |
|---|---|
| `all/main.yml` | Environment metadata |
| `all/vault.yml` | Encrypted secrets |
| `database.yml` | PostgreSQL and backup variables |
| `linux.yml` | Common Linux variables |
| `monitoring.yml` | Prometheus and Grafana variables |

This keeps roles reusable because environment-specific values are stored in inventory variables.

---

## 9. Environment Metadata

Each inventory has environment metadata.

Development example:

```yaml
environment_name: dev
environment_description: Local Hyper-V development lab
environment_network_cidr: 192.168.100.0/24
environment_type: local_lab
```

Production-like example:

```yaml
environment_name: prod
environment_description: Production-like inventory template
environment_network_cidr: 10.20.10.0/24
environment_type: production_template
```

These variables are validated by the preflight playbook.

---

## 10. Role Architecture

The project uses Ansible roles for reusable infrastructure components.

```text
ansible/roles/
├── linux_baseline/
├── nginx/
├── postgresql/
├── node_exporter/
├── prometheus/
├── grafana/
└── postgresql_backup/
```

Each role owns one infrastructure responsibility.

| Role | Responsibility |
|---|---|
| `linux_baseline` | Common Linux packages, users, SSH and baseline configuration |
| `nginx` | Web server installation and web page deployment |
| `postgresql` | PostgreSQL installation, database and user management |
| `node_exporter` | Linux metrics exporter deployment |
| `prometheus` | Prometheus monitoring server deployment |
| `grafana` | Grafana installation, datasource and dashboard provisioning |
| `postgresql_backup` | PostgreSQL backup and restore validation automation |

This design follows separation of concerns.

---

## 11. Playbook Architecture

Playbooks are stored under:

```text
ansible/playbooks/
```

Main playbooks:

```text
00-preflight.yml
02-apply-linux-baseline.yml
03-deploy-nginx.yml
04-deploy-postgresql.yml
05-deploy-node-exporter.yml
06-deploy-prometheus.yml
07-deploy-grafana.yml
08-post-deployment-validation.yml
09-backup-postgresql.yml
10-restore-postgresql-validation.yml
site.yml
```

Each playbook is responsible for one part of the workflow.

The `site.yml` playbook imports the full operational workflow.

---

## 12. Site Playbook Architecture

Main workflow file:

```text
ansible/playbooks/site.yml
```

The site playbook imports other playbooks in order:

```text
00-preflight.yml
02-apply-linux-baseline.yml
03-deploy-nginx.yml
04-deploy-postgresql.yml
05-deploy-node-exporter.yml
06-deploy-prometheus.yml
07-deploy-grafana.yml
08-post-deployment-validation.yml
09-backup-postgresql.yml
10-restore-postgresql-validation.yml
```

Normal execution:

```bash
ansible-playbook playbooks/site.yml
```

Normal execution includes:

```text
preflight
deployment
post-deployment validation
```

Normal execution does not include:

```text
backup
restore validation
```

Backup and restore validation are protected with the `never` tag.

---

## 13. Normal Deployment Flow

Normal deployment workflow:

```text
Preflight
    ↓
Linux baseline
    ↓
Nginx
    ↓
PostgreSQL
    ↓
Node Exporter
    ↓
Prometheus
    ↓
Grafana
    ↓
Post-deployment validation
```

This means the project validates the environment before deployment and validates services after deployment.

---

## 14. Preflight Architecture

Preflight playbook:

```text
ansible/playbooks/00-preflight.yml
```

Target group:

```text
linux
```

Preflight validates:

```text
environment variables
required inventory groups
SSH connectivity
ansible_user variable
passwordless sudo access
```

Preflight exists to catch infrastructure readiness issues before running deployment tasks.

This prevents wasting time on deployment errors caused by missing inventory data, broken SSH, or sudo problems.

---

## 15. Linux Baseline Architecture

Linux baseline playbook:

```text
ansible/playbooks/02-apply-linux-baseline.yml
```

Role:

```text
linux_baseline
```

Target group:

```text
linux
```

Purpose:

```text
prepare all Linux nodes with common baseline configuration
```

This role is applied to all managed nodes because every server needs common packages and baseline settings.

---

## 16. Web Layer Architecture

Web playbook:

```text
ansible/playbooks/03-deploy-nginx.yml
```

Role:

```text
nginx
```

Target group:

```text
web
```

Hosts:

```text
web-01
web-02
```

Purpose:

```text
install Nginx
deploy managed web page
validate HTTP service
```

The web layer demonstrates multi-node service deployment.

---

## 17. Database Layer Architecture

Database playbook:

```text
ansible/playbooks/04-deploy-postgresql.yml
```

Role:

```text
postgresql
```

Target group:

```text
database
```

Host:

```text
db-01
```

Purpose:

```text
install PostgreSQL
create automation_lab database
create managed PostgreSQL users from Vault
validate database availability
```

Sensitive database user values are loaded from Ansible Vault.

---

## 18. Monitoring Agent Architecture

Node Exporter playbook:

```text
ansible/playbooks/05-deploy-node-exporter.yml
```

Role:

```text
node_exporter
```

Target group:

```text
linux
```

Purpose:

```text
install Node Exporter on every Linux node
expose host metrics on port 9100
allow Prometheus to scrape all nodes
```

Node Exporter endpoints:

```text
web-01:9100
web-02:9100
db-01:9100
monitor-01:9100
```

---

## 19. Prometheus Architecture

Prometheus playbook:

```text
ansible/playbooks/06-deploy-prometheus.yml
```

Role:

```text
prometheus
```

Target group:

```text
monitoring
```

Host:

```text
monitor-01
```

Purpose:

```text
install Prometheus
configure scrape targets
validate Prometheus configuration
validate readiness endpoint
```

Prometheus scrapes Node Exporter metrics from all Linux nodes.

Logical flow:

```text
Node Exporter on Linux nodes
        ↓
Prometheus on monitor-01
```

---

## 20. Grafana Architecture

Grafana playbook:

```text
ansible/playbooks/07-deploy-grafana.yml
```

Role:

```text
grafana
```

Target group:

```text
monitoring
```

Host:

```text
monitor-01
```

Purpose:

```text
install Grafana
configure Prometheus datasource
provision dashboards
manage admin credentials with Vault
validate Grafana health
```

Grafana reads metrics from Prometheus.

Logical flow:

```text
Node Exporter
    ↓
Prometheus
    ↓
Grafana
```

---

## 21. Monitoring Stack Architecture

Full monitoring flow:

```text
web-01 Node Exporter
web-02 Node Exporter
db-01 Node Exporter
monitor-01 Node Exporter
        ↓
Prometheus on monitor-01
        ↓
Grafana on monitor-01
```

Prometheus endpoint:

```text
http://192.168.100.31:9090
```

Grafana endpoint:

```text
http://192.168.100.31:3000
```

Node Exporter endpoints:

```text
http://192.168.100.11:9100/metrics
http://192.168.100.12:9100/metrics
http://192.168.100.21:9100/metrics
http://192.168.100.31:9100/metrics
```

---

## 22. Post-deployment Validation Architecture

Post-deployment validation playbook:

```text
ansible/playbooks/08-post-deployment-validation.yml
```

Purpose:

```text
verify that deployed services are actually operational
```

Validated layers:

```text
Linux monitoring agents
web layer
database layer
monitoring server
```

Validation checks include:

```text
service state
service enabled status
HTTP endpoints
Prometheus readiness
Grafana health
PostgreSQL SQL query
```

This makes the deployment workflow stronger because success is not only based on package installation.

---

## 23. Backup Architecture

Backup playbook:

```text
ansible/playbooks/09-backup-postgresql.yml
```

Role:

```text
postgresql_backup
```

Target group:

```text
database
```

Backup target:

```text
automation_lab
```

Backup directory:

```text
/var/backups/postgresql/automation_lab
```

Backup flow:

```text
create backup directory
run pg_dump
validate backup file exists
validate backup file is not empty
update latest.sql symlink
remove old backups according to retention
```

Backup files are timestamped:

```text
automation_lab-YYYYMMDDTHHMMSS.sql
```

Latest backup symlink:

```text
latest.sql
```

---

## 24. Restore Validation Architecture

Restore validation playbook:

```text
ansible/playbooks/10-restore-postgresql-validation.yml
```

Role:

```text
postgresql_backup
```

Target group:

```text
database
```

Restore source:

```text
/var/backups/postgresql/automation_lab/latest.sql
```

Restore target:

```text
automation_lab_restore_validation
```

Restore validation flow:

```text
validate latest.sql exists
drop validation database if it exists
create validation database
restore latest backup into validation database
run SQL query against restored database
assert restored database is queryable
```

The original database is not overwritten.

This makes restore validation safe.

---

## 25. Backup and Restore Tag Protection

Backup and restore validation are imported into `site.yml` with:

```text
never
```

This prevents accidental execution during normal deployment.

Manual backup:

```bash
ansible-playbook playbooks/site.yml --tags backup
```

Manual restore validation:

```bash
ansible-playbook playbooks/site.yml --tags restore_validation
```

This design is safer because backup and restore are operational tasks, not normal deployment tasks.

---

## 26. Vault Architecture

Ansible Vault is used for secrets.

Vault stores:

```text
PostgreSQL managed user credentials
Grafana admin credentials
```

Vault files:

```text
ansible/inventories/dev/group_vars/all/vault.yml
ansible/inventories/prod/group_vars/all/vault.yml
```

Vault password file:

```text
ansible/.vault_pass.txt
```

These files are ignored by Git.

Example safe file:

```text
ansible/examples/vault.yml.example
```

Vault allows the project to show secret management without exposing real passwords.

---

## 27. CI Architecture

GitHub Actions workflow:

```text
.github/workflows/ansible-validation.yml
```

The CI pipeline validates:

```text
YAML syntax
Ansible lint rules
Ansible playbook syntax
dev inventory syntax
prod inventory syntax
```

CI does not run real deployments because the Hyper-V lab VMs are local and not accessible from GitHub Actions.

CI provides static validation only.

Runtime validation is documented with screenshots and runbooks.

---

## 28. Validation Architecture

The project uses three validation levels.

### Static Validation

Static validation checks project quality before runtime:

```text
yamllint
ansible-lint
ansible-playbook --syntax-check
```

### Preflight Validation

Preflight validation checks readiness before deployment:

```text
inventory
environment variables
SSH
sudo
```

### Runtime/Post-deployment Validation

Runtime validation checks actual services:

```text
Nginx HTTP response
PostgreSQL SQL query
Node Exporter metrics endpoint
Prometheus readiness
Grafana health
backup creation
restore validation
```

This layered validation model makes the project more reliable.

---

## 29. Security Architecture

Security-related design choices:

```text
passwordless SSH key authentication
passwordless sudo for automation user
Ansible Vault for secrets
Vault files excluded from Git
Vault password file excluded from Git
backup files owned by postgres
backup directory restricted with 0750 permissions
backup files restricted with 0640 permissions
prod inventory kept as template
backup/restore protected with never tag
```

This is not a complete production security model, but it demonstrates important infrastructure automation security practices.

---

## 30. Idempotency Architecture

Most deployment roles are designed to be idempotent.

This means repeated runs should not unnecessarily change the system.

Examples:

```text
APT packages use state: present
services use enabled: true and state: started
templates update only when content changes
systemd handlers restart services only when needed
validation tasks use changed_when: false
```

Backup and restore tasks are intentionally not fully idempotent.

Reason:

```text
a backup operation is expected to create a new timestamped backup file
restore validation intentionally recreates a validation database
```

Because of this, backup and restore are protected with the `never` tag and run only manually.

---

## 31. Documentation Architecture

The project documentation is split into layers.

README:

```text
high-level project overview
quick start
main features
current status
```

Stage runbooks:

```text
detailed implementation history per stage
```

Operations guide:

```text
how to operate the Ansible project
```

Architecture document:

```text
how the Ansible project is designed
```

Screenshots:

```text
runtime and validation evidence
```

This keeps the project easier to review.

---

## 32. Final Ansible Architecture Summary

The Ansible part of the project now provides:

```text
multi-node infrastructure automation
environment-separated inventories
role-based configuration management
central site playbook
operational tags
secret management with Ansible Vault
monitoring stack deployment
Grafana dashboard provisioning
preflight checks
post-deployment validation
PostgreSQL backup automation
PostgreSQL restore validation
static CI validation
operator documentation
architecture documentation
```


