# Ansible Operations Guide

## 1. Purpose

This document is the main operational guide for the Ansible part of the Enterprise Automation Lab.

It explains how to:

```text
validate the Ansible project
inspect inventories
run the full infrastructure deployment
run preflight checks
run post-deployment validation
run PostgreSQL backup
run PostgreSQL restore validation
work with Ansible Vault
validate dev and prod inventories
troubleshoot common operational issues
```

This guide is intended for someone who wants to operate or review the project without reading every individual stage runbook first.

---

## 2. Project Location

Repository root:

```bash
~/enterprise-automation-lab
```

Ansible directory:

```bash
~/enterprise-automation-lab/ansible
```

Main Ansible configuration file:

```text
ansible/ansible.cfg
```

Main site playbook:

```text
ansible/playbooks/site.yml
```

---

## 3. Control Node

The control node is the machine where Ansible is executed.

In this lab, the control node is:

```text
Kali Linux WSL
```

The control node manages the Hyper-V Linux VMs through SSH.

---

## 4. Managed Nodes

Development environment nodes:

| Host | IP Address | Role |
|---|---:|---|
| `web-01` | `192.168.100.11` | Nginx web server |
| `web-02` | `192.168.100.12` | Nginx web server |
| `db-01` | `192.168.100.21` | PostgreSQL database server |
| `monitor-01` | `192.168.100.31` | Prometheus and Grafana monitoring server |

Parent group:

```text
linux
```

The `linux` group contains all managed Linux nodes.

---

## 5. Inventory Files

Development inventory:

```text
ansible/inventories/dev/hosts.ini
```

Production-like inventory template:

```text
ansible/inventories/prod/hosts.ini
```

The prod inventory is a template and should be used for syntax validation only until real production hosts exist.

---

## 6. Inventory Graph

From the Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible
```

Show dev inventory graph:

```bash
ansible-inventory -i inventories/dev/hosts.ini --graph
```

Show prod inventory graph:

```bash
ansible-inventory -i inventories/prod/hosts.ini --graph
```

Expected group structure:

```text
web
database
monitoring
linux
```

---

## 7. Inspect Host Variables

Inspect a dev host:

```bash
ansible-inventory -i inventories/dev/hosts.ini --host monitor-01
```

Inspect a prod-like host:

```bash
ansible-inventory -i inventories/prod/hosts.ini --host prod-monitor-01
```

This helps verify that group variables and environment variables are loaded correctly.

---

## 8. Ansible Vault

Vault is used for sensitive variables.

Local Vault password file:

```text
ansible/.vault_pass.txt
```

Development Vault file:

```text
ansible/inventories/dev/group_vars/all/vault.yml
```

Production-like Vault file:

```text
ansible/inventories/prod/group_vars/all/vault.yml
```

These files must not be committed to Git.

Before running Vault-dependent playbooks, export:

```bash
cd ~/enterprise-automation-lab/ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt
```

Edit dev Vault:

```bash
ansible-vault edit inventories/dev/group_vars/all/vault.yml
```

Edit prod Vault:

```bash
ansible-vault edit inventories/prod/group_vars/all/vault.yml
```

---

## 9. Static Validation

Run YAML validation from repository root:

```bash
cd ~/enterprise-automation-lab

yamllint .
```

Run Ansible lint from Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-lint .
```

Both commands should complete without errors.

---

## 10. Syntax Validation

From the Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt
```

Validate main site playbook:

```bash
ansible-playbook playbooks/site.yml --syntax-check
```

Validate preflight playbook:

```bash
ansible-playbook playbooks/00-preflight.yml --syntax-check
```

Validate post-deployment validation playbook:

```bash
ansible-playbook playbooks/08-post-deployment-validation.yml --syntax-check
```

Validate PostgreSQL backup playbook:

```bash
ansible-playbook playbooks/09-backup-postgresql.yml --syntax-check
```

Validate PostgreSQL restore validation playbook:

```bash
ansible-playbook playbooks/10-restore-postgresql-validation.yml --syntax-check
```

Validate site playbook with explicit dev inventory:

```bash
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check
```

Validate site playbook with prod-like inventory:

```bash
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --syntax-check
```

The prod command is syntax-only.

Do not run prod deployment until real prod hosts exist.

---

## 11. List Operational Tags

Show available tags:

```bash
cd ~/enterprise-automation-lab/ansible

ansible-playbook playbooks/site.yml --list-tags
```

Important tags:

```text
preflight
validation
post_validation
baseline
web
nginx
database
postgresql
monitoring
metrics
node_exporter
prometheus
grafana
dashboards
backup
restore
restore_validation
never
```

---

## 12. Full Deployment Workflow

The main playbook is:

```text
ansible/playbooks/site.yml
```

Run full deployment:

```bash
cd ~/enterprise-automation-lab/ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-playbook playbooks/site.yml
```

The full workflow is:

```text
preflight
Linux baseline
Nginx
PostgreSQL
Node Exporter
Prometheus
Grafana
post-deployment validation
```

Backup and restore validation are not executed during normal deployment because they use the `never` tag.

---

## 13. Preflight Checks

Run only preflight checks:

```bash
ansible-playbook playbooks/site.yml --tags preflight
```

Preflight validates:

```text
environment variables
required inventory groups
SSH connectivity
ansible_user variable
passwordless sudo
```

This should be run before troubleshooting deployment problems.

---

## 14. Post-deployment Validation

Run only post-deployment validation:

```bash
ansible-playbook playbooks/site.yml --tags post_validation
```

Post-deployment validation checks:

```text
Node Exporter service and metrics endpoint
Nginx HTTP endpoint and page content
PostgreSQL service unit and SQL query
Prometheus service and readiness endpoint
Grafana service and health endpoint
```

This confirms that deployed services are operational.

---

## 15. Run Individual Layers

Run Linux baseline only:

```bash
ansible-playbook playbooks/site.yml --tags baseline
```

Run web layer only:

```bash
ansible-playbook playbooks/site.yml --tags web
```

Run database layer only:

```bash
ansible-playbook playbooks/site.yml --tags database
```

Run monitoring layer only:

```bash
ansible-playbook playbooks/site.yml --tags monitoring
```

Run Grafana only:

```bash
ansible-playbook playbooks/site.yml --tags grafana
```

---

## 16. PostgreSQL Backup

Run PostgreSQL backup manually:

```bash
ansible-playbook playbooks/site.yml --tags backup
```

This creates a timestamped SQL dump under:

```text
/var/backups/postgresql/automation_lab
```

Check backup files:

```bash
ansible database -m command -a "ls -lah /var/backups/postgresql/automation_lab"
```

Expected files:

```text
automation_lab-YYYYMMDDTHHMMSS.sql
latest.sql -> /var/backups/postgresql/automation_lab/automation_lab-YYYYMMDDTHHMMSS.sql
```

---

## 17. PostgreSQL Restore Validation

Run restore validation manually:

```bash
ansible-playbook playbooks/site.yml --tags restore_validation
```

This restores the latest backup into:

```text
automation_lab_restore_validation
```

Check validation database:

```bash
ansible database -m command -a "sudo -u postgres psql -tAc \"SELECT datname FROM pg_database WHERE datname='automation_lab_restore_validation';\""
```

Expected result:

```text
automation_lab_restore_validation
```

The original database is not overwritten.

---

## 18. Service Checks

Check Nginx:

```bash
ansible web -m command -a "systemctl status nginx --no-pager"
```

Check PostgreSQL:

```bash
ansible database -m command -a "systemctl status postgresql --no-pager"
```

Check Node Exporter:

```bash
ansible linux -m command -a "systemctl status node_exporter --no-pager"
```

Check Prometheus:

```bash
ansible monitoring -m command -a "systemctl status prometheus --no-pager"
```

Check Grafana:

```bash
ansible monitoring -m command -a "systemctl status grafana-server --no-pager"
```

---

## 19. Endpoint Checks

Check web servers:

```bash
curl -s http://192.168.100.11
curl -s http://192.168.100.12
```

Check Node Exporter:

```bash
curl -s http://192.168.100.11:9100/metrics | head
curl -s http://192.168.100.12:9100/metrics | head
curl -s http://192.168.100.21:9100/metrics | head
curl -s http://192.168.100.31:9100/metrics | head
```

Check Prometheus:

```bash
curl -s http://192.168.100.31:9090/-/ready
```

Check Grafana:

```bash
curl -s http://192.168.100.31:3000/api/health
```

---

## 20. Useful URLs

Nginx web servers:

```text
http://192.168.100.11
http://192.168.100.12
```

Prometheus:

```text
http://192.168.100.31:9090
```

Grafana:

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

## 21. Git Safety Check

Before committing, verify:

```bash
cd ~/enterprise-automation-lab

git status
```

Sensitive files must not appear:

```text
ansible/.vault_pass.txt
ansible/inventories/dev/group_vars/all/vault.yml
ansible/inventories/prod/group_vars/all/vault.yml
ansible/collections/
```

If they appear, check `.gitignore` before committing.

---

## 22. Full Local Validation Checklist

Run:

```bash
cd ~/enterprise-automation-lab

yamllint .

cd ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-lint .
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/00-preflight.yml --syntax-check
ansible-playbook playbooks/08-post-deployment-validation.yml --syntax-check
ansible-playbook playbooks/09-backup-postgresql.yml --syntax-check
ansible-playbook playbooks/10-restore-postgresql-validation.yml --syntax-check
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --tags preflight
ansible-playbook playbooks/site.yml --tags post_validation
ansible-playbook playbooks/site.yml --tags backup
ansible-playbook playbooks/site.yml --tags restore_validation
```

Expected result:

```text
lint passes
syntax checks pass
preflight passes
post-validation passes
backup passes
restore validation passes
failed=0
unreachable=0
```

---

## 23. Troubleshooting Order

If something fails, troubleshoot in this order:

```text
inventory graph
host variables
SSH connectivity
sudo access
Vault availability
syntax validation
role-specific task
service status
endpoint response
logs
```

Recommended first commands:

```bash
ansible-inventory -i inventories/dev/hosts.ini --graph
ansible linux -m ping
ansible linux -m command -a "sudo -n true"
ansible-playbook playbooks/site.yml --tags preflight
```

---

## 24. Project Status

The Ansible part of the project currently includes:

```text
multi-node inventory
dev/prod environment separation
Linux baseline role
Nginx role
PostgreSQL role
Node Exporter role
Prometheus role
Grafana role
Grafana dashboard provisioning
Ansible Vault secret management
preflight checks
post-deployment validation
PostgreSQL backup automation
PostgreSQL restore validation
GitHub Actions syntax validation
operator documentation
```


