# Enterprise Automation Lab

[![Ansible Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml)
[![Terraform Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/terraform-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/terraform-validation.yml)
## Project Overview

**Enterprise Automation Lab** is a practical infrastructure automation project built around a local Hyper-V Linux lab, Ansible configuration management, monitoring automation, PostgreSQL backup and restore validation, and Terraform-based Azure Infrastructure as Code practice.

The project is designed to demonstrate a realistic infrastructure automation learning path:

```text
local lab foundation
    -> Ansible automation
    -> monitoring and validation
    -> backup and restore operations
    -> Terraform Azure Infrastructure as Code
    -> future CloudFormation static validation
```


---

## Current Project Status

Current stage:

```text
Stage 4.1 - Terraform Azure Basics
```

Ansible phase:

```text
Completed
```

Terraform phase:

```text
In progress
```

CloudFormation phase:

```text
Planned
```

---

## Completed Stages

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
| Stage 3.3 | Environment separation for dev and prod inventories | Completed |
| Stage 3.4 | Preflight and post-deployment validation | Completed |
| Stage 3.5 | PostgreSQL backup and restore automation | Completed |
| Stage 3.6 | Final Ansible hardening and cleanup | Completed |
| Stage 4.0 | Azure and Terraform safety bootstrap | Completed |
| Stage 4.1 | Terraform Azure basics: Resource Group, VNet, Subnet and NSG | Completed |

---

## High-Level Architecture

```text
Windows 11 Host
│
├── Kali Linux WSL
│   └── Automation Control Workstation
│       ├── Git
│       ├── SSH Client
│       ├── Python
│       ├── Ansible
│       ├── Terraform
│       ├── Azure CLI
│       ├── ansible-lint
│       └── yamllint
│
├── Hyper-V
│   └── Internal NAT Network: 192.168.100.0/24
│       ├── web-01      192.168.100.11
│       ├── web-02      192.168.100.12
│       ├── db-01       192.168.100.21
│       └── monitor-01  192.168.100.31
│
└── Azure Student Subscription
    └── Terraform Azure Basics
        ├── Resource Group
        ├── Virtual Network
        ├── Subnet
        ├── Network Security Group
        └── Subnet to NSG association
```

---

## Local Hyper-V Lab Architecture

The local lab uses a dedicated Hyper-V internal NAT network.

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
| `web-01` | `192.168.100.11` | Web server |
| `web-02` | `192.168.100.12` | Web server |
| `db-01` | `192.168.100.21` | Database server |
| `monitor-01` | `192.168.100.31` | Monitoring server |

---

## Service Architecture

```text
Kali Linux WSL
    |
    | Ansible over SSH
    v
Hyper-V Linux Nodes
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
    │   ├── PostgreSQL backup automation
    │   ├── PostgreSQL restore validation
    │   └── Node Exporter
    │
    └── monitor-01
        ├── Linux baseline
        ├── Node Exporter
        ├── Prometheus
        └── Grafana
```

---

## Monitoring Architecture

The monitoring stack contains:

```text
Node Exporter
Prometheus
Grafana
Provisioned Grafana dashboard
```

Monitoring flow:

```text
web-01 Node Exporter
web-02 Node Exporter
db-01 Node Exporter
monitor-01 Node Exporter
        |
        v
Prometheus on monitor-01
        |
        v
Grafana on monitor-01
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

```text
http://192.168.100.31:9090
```

Grafana endpoint:

```text
http://192.168.100.31:3000
```

Provisioned Grafana dashboard:

| Folder | Dashboard | Purpose |
|---|---|---|
| `Enterprise Automation Lab` | `Enterprise Linux Overview` | Linux infrastructure metrics overview |

Current dashboard panels:

```text
Node Exporter Targets UP
CPU Usage by Instance
Memory Available by Instance
Root Filesystem Free Space
System Load 1m
Network Receive Traffic
```

---

## Ansible Phase Summary

The Ansible phase is complete.

It includes:

```text
multi-node inventory
dev/prod inventory separation
Linux baseline automation
Nginx automation
PostgreSQL automation
Node Exporter automation
Prometheus automation
Grafana automation
Grafana dashboard provisioning
Ansible Vault secret management
preflight checks
post-deployment validation
PostgreSQL backup automation
PostgreSQL restore validation
GitHub Actions static validation
operations guide
architecture documentation
runtime validation screenshots
```

Main Ansible entrypoint:

```text
ansible/playbooks/site.yml
```

Normal deployment workflow:

```text
preflight
    -> Linux baseline
    -> Nginx
    -> PostgreSQL
    -> Node Exporter
    -> Prometheus
    -> Grafana
    -> post-deployment validation
```

Manual operational tasks:

```text
PostgreSQL backup
PostgreSQL restore validation
```

These are protected by the `never` tag and run only when explicitly requested.

---

## Ansible Inventory

Development inventory:

```text
ansible/inventories/dev/hosts.ini
```

Current dev inventory:

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

Production-like inventory:

```text
ansible/inventories/prod/hosts.ini
```

The prod inventory is a template for syntax validation and future expansion. It is not currently used for runtime deployment.

---

## Ansible Roles

| Role | Purpose |
|---|---|
| `linux_baseline` | Common Linux baseline configuration |
| `nginx` | Nginx installation and web page deployment |
| `postgresql` | PostgreSQL installation, database and user management |
| `node_exporter` | Node Exporter metrics agent deployment |
| `prometheus` | Prometheus monitoring server deployment |
| `grafana` | Grafana installation, datasource and dashboard provisioning |
| `postgresql_backup` | PostgreSQL backup and restore validation automation |

---

## Ansible Playbooks

| Playbook | Purpose |
|---|---|
| `ansible/playbooks/site.yml` | Main operational playbook |
| `ansible/playbooks/00-preflight.yml` | Validates inventory, environment variables, SSH and sudo before deployment |
| `ansible/playbooks/01-bootstrap-linux.yml` | Initial bootstrap playbook |
| `ansible/playbooks/02-apply-linux-baseline.yml` | Applies Linux baseline role |
| `ansible/playbooks/03-deploy-nginx.yml` | Deploys Nginx to web servers |
| `ansible/playbooks/04-deploy-postgresql.yml` | Deploys PostgreSQL to database server |
| `ansible/playbooks/05-deploy-node-exporter.yml` | Deploys Node Exporter to all Linux nodes |
| `ansible/playbooks/06-deploy-prometheus.yml` | Deploys Prometheus to the monitoring node |
| `ansible/playbooks/07-deploy-grafana.yml` | Deploys Grafana and dashboards |
| `ansible/playbooks/08-post-deployment-validation.yml` | Validates services and endpoints after deployment |
| `ansible/playbooks/09-backup-postgresql.yml` | Creates timestamped PostgreSQL backups |
| `ansible/playbooks/10-restore-postgresql-validation.yml` | Restores latest backup into a validation database and verifies SQL access |

---

## Ansible Vault

The project uses Ansible Vault for local secret management.

Encrypted local Vault files:

```text
ansible/inventories/dev/group_vars/all/vault.yml
ansible/inventories/prod/group_vars/all/vault.yml
```

Local Vault password file:

```text
ansible/.vault_pass.txt
```

These files are excluded from Git.

Safe example file:

```text
ansible/examples/vault.yml.example
```

Vault-managed values:

```text
PostgreSQL application user password
Grafana admin password
```

Before running Vault-dependent playbooks locally:

```bash
cd ansible
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt
```

---

## Preflight and Post-deployment Validation

The Ansible workflow includes:

```text
preflight -> deployment -> post-deployment validation
```

Preflight validates:

```text
environment variables
required inventory groups
SSH connectivity
Ansible user variable
passwordless sudo access
```

Post-deployment validation checks:

```text
Node Exporter service and metrics endpoint
Nginx HTTP response and page content
PostgreSQL service unit and SQL query
Prometheus service and readiness endpoint
Grafana service and health endpoint
```

Useful commands:

```bash
cd ansible

ansible-playbook playbooks/site.yml --tags preflight
ansible-playbook playbooks/site.yml --tags post_validation
ansible-playbook playbooks/site.yml --tags validation
```

---

## PostgreSQL Backup and Restore Automation

The project includes PostgreSQL backup and restore validation automation.

Backup workflow:

```text
create backup directory
run pg_dump
validate backup file exists
validate backup file is not empty
update latest.sql symlink
clean old backups according to retention policy
```

Restore validation workflow:

```text
validate latest.sql exists
drop restore validation database if it exists
create restore validation database
restore latest backup into validation database
run SQL query against restored database
verify restored database is queryable
```

Manual backup:

```bash
cd ansible
ansible-playbook playbooks/site.yml --tags backup
```

Manual restore validation:

```bash
cd ansible
ansible-playbook playbooks/site.yml --tags restore_validation
```

Backup location on `db-01`:

```text
/var/backups/postgresql/automation_lab
```

Latest backup symlink:

```text
/var/backups/postgresql/automation_lab/latest.sql
```

Restore validation database:

```text
automation_lab_restore_validation
```

---

## Terraform Azure Phase

The Terraform phase introduces Azure Infrastructure as Code practice.

The project uses Azure student credits, so every Azure deployment follows strict cost safety rules.

Main rule:

```text
Create resources -> validate resources -> take screenshots -> destroy resources
```

Terraform is used to practice:

```text
providers
variables
locals
resources
outputs
state
plan/apply/destroy workflow
Azure resource modeling
cost-safe cloud validation
```

Terraform does not replace Ansible in this project.

```text
Terraform = creates infrastructure
Ansible = configures servers and services
```

---

## Terraform Azure Basics

Current Terraform basics stage:

```text
Stage 4.1 - Terraform Azure Basics
```

Terraform basics directory:

```text
terraform/azure/basics/
```

Resources created in Stage 4.1:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
```

No virtual machine is created in this stage.

Reason:

```text
VMs can consume credits if left running.
The first Terraform Azure stage focuses on networking and safe Terraform workflow.
```

Terraform workflow demonstrated:

```text
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

Azure region used after subscription policy validation:

```text
swedencentral
```

Stage 4.1 Resource names:

| Resource | Name |
|---|---|
| Resource Group | `rg-ea-lab-dev` |
| Virtual Network | `vnet-ea-lab-dev` |
| Subnet | `snet-ea-lab-dev-main` |
| Network Security Group | `nsg-ea-lab-dev-main` |

---

## Azure Cost Safety

Cost safety guide:

```text
terraform/docs/azure-cost-safety.md
```

Mandatory Azure lab rules:

```text
use a dedicated lab resource group
use small and cheap resources
review terraform plan before apply
do not leave resources running longer than needed
destroy resources after validation
check Azure Portal after destroy
never commit Terraform state
never commit real tfvars files
never store Azure credentials in Git
```

Services avoided in early stages:

```text
AKS
Azure Firewall
Application Gateway
NAT Gateway
Azure Bastion
Managed PostgreSQL
Managed MySQL
large VM sizes
premium disks
snapshots
VPN Gateway
ExpressRoute
```

---

## Terraform Files

Terraform basics files:

| File | Purpose |
|---|---|
| `terraform/azure/basics/versions.tf` | Terraform and provider version requirements |
| `terraform/azure/basics/providers.tf` | AzureRM provider configuration |
| `terraform/azure/basics/variables.tf` | Input variables and validation |
| `terraform/azure/basics/locals.tf` | Computed names and common tags |
| `terraform/azure/basics/main.tf` | Azure resources |
| `terraform/azure/basics/outputs.tf` | Useful output values |
| `terraform/azure/basics/terraform.tfvars.example` | Safe example variables |
| `terraform/azure/basics/README.md` | Terraform basics documentation |

Local files not committed:

```text
terraform/azure/basics/terraform.tfvars
terraform/azure/basics/terraform.tfstate
terraform/azure/basics/terraform.tfstate.backup
terraform/azure/basics/.terraform/
```

Provider lock file committed:

```text
terraform/azure/basics/.terraform.lock.hcl
```

The lock file is committed to keep provider versions reproducible.

---

## Terraform Validation

From the Terraform basics directory:

```bash
cd terraform/azure/basics
```

Initialize Terraform:

```bash
terraform init
```

Format code:

```bash
terraform fmt
```

Validate configuration:

```bash
terraform validate
```

Preview resources:

```bash
terraform plan
```

Apply resources:

```bash
terraform apply
```

Show outputs:

```bash
terraform output
```

Show state resources:

```bash
terraform state list
```

Destroy resources:

```bash
terraform destroy
```

Expected Stage 4.1 plan:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Expected Stage 4.1 apply:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

Expected Stage 4.1 destroy:

```text
Destroy complete! Resources: 5 destroyed.
```

---

## CloudFormation Phase

CloudFormation is planned as a future AWS-native Infrastructure as Code learning block.

Because the current available cloud credits are Azure credits, the CloudFormation phase will use static validation and documentation only unless AWS deployment is explicitly added later.

Planned CloudFormation approach:

```text
local templates
YAML syntax
Parameters
Mappings
Conditions
Resources
Outputs
cfn-lint
static validation
nested stack design
change set concept
drift detection concept
documentation
```

No AWS paid deployment is planned at the current stage.

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
| Ansible Vault | Local secret management |
| community.postgresql | PostgreSQL automation collection |
| Nginx | Web server |
| PostgreSQL | Database server |
| Prometheus Node Exporter | Linux metrics exporter |
| Prometheus | Metrics collection |
| Grafana | Metrics visualization |
| PromQL | Metrics query language |
| Terraform | Infrastructure as Code |
| AzureRM Provider | Terraform provider for Azure |
| Azure Student Subscription | Cloud practice environment |
| Azure Virtual Network | Azure networking |
| Azure Network Security Group | Azure network filtering |
| yamllint | YAML validation |
| ansible-lint | Ansible best-practice validation |
| GitHub Actions | Static CI validation |
| AWS CloudFormation | Planned AWS-native IaC static validation |

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
│   │   └── prod/
│   ├── playbooks/
│   │   ├── site.yml
│   │   ├── 00-preflight.yml
│   │   ├── 01-bootstrap-linux.yml
│   │   ├── 02-apply-linux-baseline.yml
│   │   ├── 03-deploy-nginx.yml
│   │   ├── 04-deploy-postgresql.yml
│   │   ├── 05-deploy-node-exporter.yml
│   │   ├── 06-deploy-prometheus.yml
│   │   ├── 07-deploy-grafana.yml
│   │   ├── 08-post-deployment-validation.yml
│   │   ├── 09-backup-postgresql.yml
│   │   └── 10-restore-postgresql-validation.yml
│   └── roles/
│       ├── linux_baseline/
│       ├── nginx/
│       ├── postgresql/
│       ├── postgresql_backup/
│       ├── node_exporter/
│       ├── prometheus/
│       └── grafana/
│
├── terraform/
│   ├── azure/
│   │   ├── basics/
│   │   └── advanced/
│   └── docs/
│       └── azure-cost-safety.md
│
├── cloudformation/
│
├── scripts/
│   └── hyperv/
│       └── create-lab-network.ps1
│
├── docs/
│   ├── ansible-architecture.md
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

## Local Static Validation

Run from repository root:

```bash
yamllint .
```

Run from Ansible directory:

```bash
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
```

Run Terraform validation:

```bash
cd terraform/azure/basics

terraform fmt
terraform validate
terraform plan
```

---

## Runtime Validation

Ansible full workflow:

```bash
cd ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-playbook playbooks/site.yml
```

Ansible preflight:

```bash
ansible-playbook playbooks/site.yml --tags preflight
```

Ansible post-deployment validation:

```bash
ansible-playbook playbooks/site.yml --tags post_validation
```

PostgreSQL backup:

```bash
ansible-playbook playbooks/site.yml --tags backup
```

PostgreSQL restore validation:

```bash
ansible-playbook playbooks/site.yml --tags restore_validation
```

Terraform Azure basics workflow:

```bash
cd terraform/azure/basics

terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

---

## GitHub Actions Validation

GitHub Actions currently validates the Ansible phase.

Workflow file:

```text
.github/workflows/ansible-validation.yml
```

The workflow checks:

```text
YAML formatting
Ansible lint rules
required Ansible collections
Ansible playbook syntax
site.yml syntax with dev inventory
site.yml syntax with prod inventory
```

Current Ansible playbooks checked by CI:

```text
site.yml
00-preflight.yml
01-bootstrap-linux.yml
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

Terraform CI validation is planned for the next Terraform stage.

---

## Documentation

Main documentation files:

| File | Purpose |
|---|---|
| `docs/architecture.md` | General lab architecture and design |
| `docs/ansible-architecture.md` | Architecture explanation of the Ansible project |
| `docs/runbooks/ansible-operations-guide.md` | Main operational guide for the Ansible workflow |
| `docs/runbooks/stage-03-06-final-ansible-hardening.md` | Final Ansible hardening and cleanup |
| `terraform/docs/azure-cost-safety.md` | Azure cost safety rules for Terraform |
| `terraform/azure/basics/README.md` | Terraform Azure basics documentation |

Stage runbooks are stored in:

```text
docs/runbooks/
```

Troubleshooting documents are stored in:

```text
docs/troubleshooting/
```

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
docs/screenshots/stage-03-postgresql-backup-restore/
docs/screenshots/stage-03-final-ansible-hardening/
docs/screenshots/stage-04-azure-terraform-basics/
```

Screenshots are used as runtime evidence that the lab was configured and validated successfully.

---

## Project Roadmap

| Stage | Goal |
|---|---|
| Stage 4.2 | Terraform Azure basics documentation, runbook and CI validation |
| Stage 5.1 | Terraform Azure modules |
| Stage 5.2 | Terraform Azure environment separation |
| Stage 5.3 | Terraform remote state with Azure Storage |
| Stage 5.4 | Terraform security and policy validation |
| Stage 6.1 | CloudFormation basics with local static validation |
| Stage 7.1 | CloudFormation advanced templates with static validation |
| Stage 8 | Final IaC comparison and project summary |

---

## Key Learning Outcomes

This project demonstrates practical experience with:

```text
Linux automation control environment setup
Hyper-V private lab networking
WSL to Hyper-V connectivity troubleshooting
SSH key-based automation access
Ansible inventory design
Ansible playbooks
Ansible roles
Ansible collections
group_vars and variable separation
Jinja2 templates
systemd service management
idempotent automation
multi-node automation
Ansible Vault secret management
Ansible environment separation
preflight infrastructure checks
post-deployment validation
PostgreSQL automation
PostgreSQL backup automation
PostgreSQL restore validation
Node Exporter metrics exposure
Prometheus metrics collection
Grafana provisioning
Grafana dashboard provisioning
PromQL dashboard panels
YAML linting
Ansible linting
GitHub Actions validation
Terraform Azure provider usage
Terraform variables
Terraform locals
Terraform outputs
Terraform state basics
Terraform plan/apply/destroy workflow
Azure Resource Group management
Azure Virtual Network basics
Azure Subnet basics
Azure Network Security Group basics
Azure cost safety workflow
infrastructure documentation and runbooks
```

---

## Current Status Summary

```text
The Ansible phase is complete.

The local Hyper-V Linux lab is fully automated with Ansible.
The project can deploy Linux baseline configuration, Nginx, PostgreSQL, Node Exporter, Prometheus and Grafana.
The monitoring stack is validated end-to-end.
Grafana dashboards are provisioned automatically.
Secrets are handled with Ansible Vault.
The project supports dev and prod-style inventories.
The project includes preflight and post-deployment validation.
The project includes PostgreSQL backup and restore validation.
The project includes final Ansible operations and architecture documentation.

The Terraform phase has started.

Terraform is installed and used with AzureRM provider.
Azure student subscription is used with strict cost safety rules.
Stage 4.1 creates a safe Azure networking foundation with Resource Group, VNet, Subnet, NSG and NSG association.
The Terraform workflow demonstrates init, validate, plan, apply, output, state list and destroy.
Azure resources are destroyed after validation to protect student credits.

CloudFormation is planned as a future local/static-validation learning phase.
```

---

