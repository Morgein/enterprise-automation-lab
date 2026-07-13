# Stage 3.6 - Final Ansible Hardening and Cleanup

## 1. Purpose

This document describes Stage 3.6 of the Enterprise Automation Lab.

The goal of this stage is to finalize the Ansible part of the project by adding final operational documentation, architecture documentation, validation workflow and project cleanup.

This stage does not add a new infrastructure service.

Instead, it improves the project quality by adding:

```text
Ansible Operations Guide
Ansible Architecture document
final validation checklist
documentation cleanup
README cleanup
final Ansible status summary
```

After this stage, the Ansible part of the project can be considered complete.

---

## 2. Why This Stage Exists

A good infrastructure automation project should not only contain working code.

It should also explain:

```text
how the project is structured
how the automation works
how to run the deployment
how to validate the environment
how to run operational tasks
how secrets are handled
how backup and restore work
how to troubleshoot problems
```

Before this stage, the project already had many stage-specific runbooks.

This stage adds final high-level documentation so that the project is easier to understand and operate.

---

## 3. Final Ansible Scope

At this point, the Ansible part of the project includes:

```text
multi-node inventory
dev/prod inventory separation
Linux baseline automation
Nginx deployment
PostgreSQL deployment
Node Exporter deployment
Prometheus deployment
Grafana deployment
Grafana dashboard provisioning
Ansible Vault secret management
preflight checks
post-deployment validation
PostgreSQL backup automation
PostgreSQL restore validation
GitHub Actions static validation
stage runbooks
operations guide
architecture documentation
```

This represents a complete practical Ansible infrastructure automation lab.

---

## 4. Files Created or Updated

| File | Purpose |
|---|---|
| `docs/runbooks/ansible-operations-guide.md` | Main operational guide for using the Ansible project |
| `docs/ansible-architecture.md` | Architecture explanation of the Ansible part of the project |
| `docs/runbooks/stage-03-06-final-ansible-hardening.md` | This final Stage 3.6 runbook |
| `README.md` | Final Ansible status and documentation references |
| `.github/workflows/ansible-validation.yml` | Final CI syntax validation workflow |
| `docs/screenshots/stage-03-final-ansible-hardening/` | Final validation evidence screenshots |

---

## 5. Ansible Operations Guide

File:

```text
docs/runbooks/ansible-operations-guide.md
```

Purpose:

```text
Provide a single operational guide for running and validating the Ansible part of the project.
```

The operations guide explains how to:

```text
inspect inventories
check host variables
work with Ansible Vault
run static validation
run syntax validation
list operational tags
run full deployment
run preflight checks
run post-deployment validation
run PostgreSQL backup
run PostgreSQL restore validation
check services
check endpoints
verify Git safety before commit
troubleshoot common issues
```

This document is intended for project operators and reviewers.

Instead of reading every stage runbook, a reviewer can open this guide and quickly understand how to use the Ansible workflow.

---

## 6. Ansible Architecture Document

File:

```text
docs/ansible-architecture.md
```

Purpose:

```text
Explain how the Ansible part of the project is designed.
```

The architecture document explains:

```text
control node architecture
managed node architecture
inventory architecture
group_vars architecture
role architecture
playbook architecture
site.yml workflow
monitoring architecture
Vault architecture
backup and restore architecture
validation architecture
CI architecture
security-related design choices
idempotency design
documentation structure
```

This document is intended for technical review.

It answers the question:

```text
How is this Ansible infrastructure automation project built?
```

---

## 7. Difference Between Operations Guide and Architecture Document

The two documents have different purposes.

| Document | Main Question |
|---|---|
| `ansible-operations-guide.md` | How do I run and operate this project? |
| `ansible-architecture.md` | How is this project designed? |

The operations guide is command-focused.

The architecture document is design-focused.

Both are needed because real infrastructure projects require both operational instructions and architecture explanation.

---

## 8. Final Ansible Workflow

The central Ansible workflow is controlled by:

```text
ansible/playbooks/site.yml
```

Normal deployment command:

```bash
ansible-playbook playbooks/site.yml
```

Normal workflow:

```text
preflight
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
post-deployment validation
```

Backup and restore validation are available but not executed during normal deployment.

They are protected by the `never` tag.

Manual backup command:

```bash
ansible-playbook playbooks/site.yml --tags backup
```

Manual restore validation command:

```bash
ansible-playbook playbooks/site.yml --tags restore_validation
```

---

## 9. Final Role List

The project contains these Ansible roles:

| Role | Purpose |
|---|---|
| `linux_baseline` | Common Linux baseline configuration |
| `nginx` | Nginx web server deployment |
| `postgresql` | PostgreSQL installation, database and user management |
| `node_exporter` | Node Exporter metrics agent deployment |
| `prometheus` | Prometheus monitoring server deployment |
| `grafana` | Grafana installation, datasource and dashboard provisioning |
| `postgresql_backup` | PostgreSQL backup and restore validation automation |

Each role has a clear responsibility.

This keeps the project modular and maintainable.

---

## 10. Final Playbook List

The project contains these important playbooks:

| Playbook | Purpose |
|---|---|
| `00-preflight.yml` | Validate inventory, environment, SSH and sudo before deployment |
| `02-apply-linux-baseline.yml` | Apply Linux baseline to all Linux nodes |
| `03-deploy-nginx.yml` | Deploy Nginx web servers |
| `04-deploy-postgresql.yml` | Deploy PostgreSQL database server |
| `05-deploy-node-exporter.yml` | Deploy Node Exporter on all Linux nodes |
| `06-deploy-prometheus.yml` | Deploy Prometheus monitoring server |
| `07-deploy-grafana.yml` | Deploy Grafana and dashboards |
| `08-post-deployment-validation.yml` | Validate services and endpoints after deployment |
| `09-backup-postgresql.yml` | Create PostgreSQL backup |
| `10-restore-postgresql-validation.yml` | Validate restore from latest PostgreSQL backup |
| `site.yml` | Central workflow importing the operational playbooks |

---

## 11. Final Validation Model

The project uses several validation layers.

### Static Validation

Static validation checks project quality before runtime.

Tools:

```text
yamllint
ansible-lint
ansible-playbook --syntax-check
```

Purpose:

```text
catch YAML errors
catch Ansible best-practice issues
catch syntax errors before runtime
```

---

### Preflight Validation

Preflight checks environment readiness before deployment.

Validated items:

```text
environment variables
required inventory groups
SSH connectivity
ansible_user variable
passwordless sudo
```

Purpose:

```text
avoid deployment failures caused by broken environment readiness
```

---

### Post-deployment Validation

Post-deployment validation checks that services actually work after deployment.

Validated services:

```text
Node Exporter
Nginx
PostgreSQL
Prometheus
Grafana
```

Purpose:

```text
prove that deployment success means operational success
```

---

### Backup and Restore Validation

Backup and restore validation checks database recoverability.

Validated operations:

```text
PostgreSQL dump creation
backup file existence
backup file size
latest.sql symlink
backup retention
restore into validation database
SQL query after restore
```

Purpose:

```text
prove that backups are usable, not only created
```

---

## 12. Final Security and Git Hygiene

Sensitive files must not be committed.

Ignored local files:

```text
ansible/.vault_pass.txt
ansible/inventories/dev/group_vars/all/vault.yml
ansible/inventories/prod/group_vars/all/vault.yml
ansible/collections/
```

Before every commit, check:

```bash
git status
```

The following files must not appear in staged changes:

```text
.vault_pass.txt
vault.yml
collections/
```

Secrets are represented in the repository only through the safe example file:

```text
ansible/examples/vault.yml.example
```

---

## 13. Final Static Validation Commands

Run from repository root:

```bash
cd ~/enterprise-automation-lab

yamllint .
```

Run from Ansible directory:

```bash
cd ~/enterprise-automation-lab/ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-lint .
```

Syntax checks:

```bash
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/00-preflight.yml --syntax-check
ansible-playbook playbooks/08-post-deployment-validation.yml --syntax-check
ansible-playbook playbooks/09-backup-postgresql.yml --syntax-check
ansible-playbook playbooks/10-restore-postgresql-validation.yml --syntax-check
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --syntax-check
```

Expected result:

```text
yamllint passes
ansible-lint passes
all syntax checks pass
```

---

## 14. Final Runtime Validation Commands

Run preflight:

```bash
ansible-playbook playbooks/site.yml --tags preflight
```

Run post-deployment validation:

```bash
ansible-playbook playbooks/site.yml --tags post_validation
```

Run PostgreSQL backup:

```bash
ansible-playbook playbooks/site.yml --tags backup
```

Run PostgreSQL restore validation:

```bash
ansible-playbook playbooks/site.yml --tags restore_validation
```

Run full site workflow:

```bash
ansible-playbook playbooks/site.yml
```

Expected result:

```text
failed=0
unreachable=0
```

---

## 15. Final Tag Validation

List tags:

```bash
ansible-playbook playbooks/site.yml --list-tags
```

Important expected tags:

```text
preflight
validation
post_validation
baseline
linux
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
stage_02
stage_03
```

These tags make the project operationally flexible.

They allow running the full workflow or only a specific infrastructure layer.

---

## 16. Final Documentation Structure

Documentation is organized like this:

```text
docs/
├── ansible-architecture.md
├── runbooks/
│   ├── ansible-operations-guide.md
│   ├── stage-02-*.md
│   ├── stage-03-*.md
│   └── stage-03-06-final-ansible-hardening.md
└── screenshots/
    ├── stage-02-*/
    └── stage-03-*/
```

The documentation layers are:

| Documentation Type | Purpose |
|---|---|
| README | High-level project overview |
| Stage runbooks | Detailed implementation history |
| Operations guide | How to operate the Ansible workflow |
| Architecture document | How the Ansible design works |
| Screenshots | Runtime and validation evidence |

---

## 17. Final Validation Evidence

Validation screenshots for this stage are stored in:

```text
docs/screenshots/stage-03-final-ansible-hardening/
```

Expected screenshot files:

```text
docs/screenshots/stage-03-final-ansible-hardening/
├── 01-final-lint-syntax-validation.png
├── 02-final-site-tags.png
├── 03-final-preflight-validation.png
├── 04-final-post-validation.png
├── 05-final-backup-validation.png
├── 06-final-restore-validation.png
└── 07-final-full-site-run.png
```

Only runtime and validation screenshots are stored.

Code screenshots are not required because the code is available in the GitHub repository.

---

## 18. GitHub Actions Validation

GitHub Actions validates the project statically.

Workflow file:

```text
.github/workflows/ansible-validation.yml
```

The workflow checks:

```text
YAML syntax
Ansible lint
Ansible playbook syntax
site.yml syntax
dev inventory syntax
prod inventory syntax
backup playbook syntax
restore validation playbook syntax
```

GitHub Actions does not run real deployments because the Hyper-V lab VMs are local.

Runtime validation is documented locally through screenshots and runbooks.

---

## 19. Troubleshooting Checklist

If the final validation fails, troubleshoot in this order:

```text
check git status
check inventory graph
check host variables
check SSH connectivity
check sudo access
check Vault password file
check lint output
check syntax-check output
run preflight
run specific role tag
check service status
check endpoint response
check logs
```

Useful commands:

```bash
ansible-inventory -i inventories/dev/hosts.ini --graph
ansible-inventory -i inventories/dev/hosts.ini --host monitor-01
ansible linux -m ping
ansible linux -m command -a "sudo -n true"
ansible-playbook playbooks/site.yml --tags preflight
```

---

## 20. Final Ansible Skills Demonstrated

This Ansible project demonstrates:

```text
inventory management
group variables
environment separation
role-based automation
Ansible Vault
Linux package management
systemd service management
template-based configuration
Prometheus monitoring deployment
Grafana dashboard provisioning
PostgreSQL database automation
backup automation
restore validation
preflight validation
post-deployment validation
operational tags
GitHub Actions static validation
documentation and runbook writing
```

These are practical infrastructure automation skills relevant for:

```text
Linux Administrator
System Administrator
Infrastructure Engineer
Junior DevOps Engineer
Cloud Engineer trainee
SRE trainee
```

---

## 21. Stage Result

At the end of this stage:

```text
Ansible Operations Guide created
Ansible Architecture document created
final Ansible hardening runbook created
final validation checklist defined
final screenshot evidence list defined
README ready for final Ansible update
Ansible workflow ready for final project presentation
```

---

## 22. Current Project Status

Current completed stage:

```text
Stage 3.6 - Final Ansible Hardening and Cleanup
```

After this stage, the Ansible part of the project is considered complete.

The completed Ansible workflow includes:

```text
preflight -> deployment -> post-deployment validation
manual backup -> manual restore validation
static CI validation
operator documentation
architecture documentation
runtime evidence
```

This completes the Ansible phase of the Enterprise Automation Lab.
