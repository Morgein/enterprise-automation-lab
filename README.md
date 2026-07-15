# Enterprise Automation Lab

[![Ansible Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/ansible-validation.yml)
[![Terraform Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/terraform-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/terraform-validation.yml)
[![Terraform Security Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/terraform-security-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/terraform-security-validation.yml)
[![CloudFormation Validation](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/cloudformation-validation.yml/badge.svg?branch=main&event=push)](https://github.com/Morgein/enterprise-automation-lab/actions/workflows/cloudformation-validation.yml)

## Project Overview

**Enterprise Automation Lab** is a practical infrastructure automation project focused on Linux system administration, Ansible configuration management, monitoring automation, PostgreSQL backup and restore validation, Terraform-based Azure Infrastructure as Code, AWS CloudFormation static validation, CI validation, and structured technical documentation.

The project demonstrates a complete infrastructure automation workflow:

```text
local virtualization
    -> Linux node preparation
    -> SSH-based automation access
    -> Ansible configuration management
    -> monitoring automation
    -> PostgreSQL backup and restore validation
    -> Terraform Azure Infrastructure as Code
    -> reusable Terraform module structure
    -> Terraform environment separation
    -> Terraform remote state with Azure Storage
    -> Terraform security and policy validation
    -> CloudFormation basics static validation
    -> CloudFormation advanced static validation
    -> final IaC comparison and architecture summary
    -> CI-based validation
```

The project combines several infrastructure automation areas:

```text
Linux administration
configuration management
monitoring
backup and restore operations
Infrastructure as Code
Azure networking
Terraform modules
Terraform remote state
Terraform security validation
AWS CloudFormation template validation
GitHub Actions CI
technical documentation
cost safety
```

---

## Current Project Status

Current stage:

```text
Stage 8 - Final IaC Comparison and Project Summary
```

Project phase status:

| Area | Status |
|---|---|
| Ansible automation | Completed |
| Monitoring automation | Completed |
| PostgreSQL backup and restore validation | Completed |
| Terraform Azure IaC | Completed advanced baseline |
| Terraform security validation | Completed |
| CloudFormation basics | Completed |
| CloudFormation advanced | Completed |
| Final documentation | Completed |

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
| Stage 4.2 | Terraform validation workflow in GitHub Actions | Completed |
| Stage 5.1 | Terraform Azure modules: network foundation module and dev environment | Completed |
| Stage 5.2 | Terraform environment separation with dev and test environments | Completed |
| Stage 5.3 | Terraform remote state with Azure Storage | Completed |
| Stage 5.4 | Terraform security and policy validation with TFLint and Checkov | Completed |
| Stage 6.1 | CloudFormation basics with local static validation | Completed |
| Stage 7.1 | CloudFormation advanced templates with static validation | Completed |
| Stage 8 | Final IaC comparison and project summary | Completed |

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
│       ├── yamllint
│       ├── ansible-lint
│       ├── TFLint
│       ├── Checkov
│       └── cfn-lint
│
├── Hyper-V Local Lab
│   └── Internal NAT Network: 192.168.100.0/24
│       ├── web-01      192.168.100.11
│       ├── web-02      192.168.100.12
│       ├── db-01       192.168.100.21
│       └── monitor-01  192.168.100.31
│
├── Azure Student Subscription
│   └── Terraform-managed Azure resources
│       ├── Resource Groups
│       ├── Virtual Networks
│       ├── Subnets
│       ├── Network Security Groups
│       ├── Storage Account
│       ├── Blob Container
│       └── Remote Terraform state
│
├── AWS CloudFormation Templates
│   └── Static validation only
│       ├── Basic networking template
│       └── Advanced security baseline template
│
└── GitHub Repository
    └── CI validation and documentation
        ├── Ansible validation
        ├── Terraform validation
        ├── Terraform security validation
        ├── CloudFormation validation
        ├── Runbooks
        ├── Architecture documentation
        └── Validation screenshots
```

---

## Local Hyper-V Lab

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

## Ansible Automation

The Ansible phase automates Linux configuration and service deployment across the local Hyper-V lab.

Ansible is used for:

```text
Linux baseline configuration
Nginx web server deployment
PostgreSQL database deployment
Node Exporter metrics agent deployment
Prometheus monitoring server deployment
Grafana deployment
Grafana datasource provisioning
Grafana dashboard provisioning
PostgreSQL backup automation
PostgreSQL restore validation
preflight checks
post-deployment validation
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

The prod inventory is included for syntax validation and future expansion. It is not used for active runtime deployment in this lab.

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

## PostgreSQL Backup and Restore Validation

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

---

## Ansible Vault

The project uses Ansible Vault for local secret management.

Vault-managed values:

```text
PostgreSQL application user password
Grafana admin password
```

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

Before running Vault-dependent playbooks locally:

```bash
cd ansible
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt
```

---

## Terraform Azure Infrastructure as Code

The Terraform phase introduces Azure Infrastructure as Code.

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
module structure
environment separation
remote state
security validation
cost-safe cloud validation
```

Terraform does not replace Ansible in this project.

```text
Terraform = creates infrastructure
Ansible = configures servers and services
```

---

## Terraform Azure Basics

Terraform basics directory:

```text
terraform/azure/basics/
```

Resources created during validation:

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

Azure region used after subscription policy validation:

```text
swedencentral
```

Stage 4.1 resource names:

| Resource | Name |
|---|---|
| Resource Group | `rg-ea-lab-dev` |
| Virtual Network | `vnet-ea-lab-dev` |
| Subnet | `snet-ea-lab-dev-main` |
| Network Security Group | `nsg-ea-lab-dev-main` |

---

## Terraform Modules

Terraform module directory:

```text
terraform/azure/modules/network-foundation/
```

The `network-foundation` module creates:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to Network Security Group association
```

The module separates reusable infrastructure logic from environment-specific values.

```text
module = how to create infrastructure
environment = with which values to create it
```

Module call flow:

```text
terraform/azure/environments/dev/
    |
    | calls
    v
terraform/azure/modules/network-foundation/
    |
    | creates
    v
Azure networking resources
```

---

## Terraform Environment Separation

The project contains two module-based Azure environments:

```text
terraform/azure/environments/dev/
terraform/azure/environments/test/
```

Both environments use the same reusable module:

```text
terraform/azure/modules/network-foundation/
```

Environment comparison:

| Setting | Dev | Test |
|---|---|---|
| Environment | `dev` | `test` |
| VNet CIDR | `10.40.0.0/16` | `10.50.0.0/16` |
| Subnet CIDR | `10.40.1.0/24` | `10.50.1.0/24` |
| Resource Group | `rg-ea-lab-dev` | `rg-ea-lab-test` |
| VNet | `vnet-ea-lab-dev` | `vnet-ea-lab-test` |
| Subnet | `snet-ea-lab-dev-main` | `snet-ea-lab-test-main` |
| NSG | `nsg-ea-lab-dev-main` | `nsg-ea-lab-test-main` |

The test environment was validated with `terraform plan` only.

Reason:

```text
The dev environment already validated real Azure deployment through the module.
The test environment demonstrates separation and module reuse without additional unnecessary deployment.
```

---

## Terraform Remote State

Terraform remote state is implemented with Azure Storage.

Remote state bootstrap directory:

```text
terraform/azure/bootstrap/remote-state/
```

The bootstrap configuration creates:

```text
Resource Group
Storage Account
Blob Container
```

Remote state flow:

```text
terraform/azure/bootstrap/remote-state/
    |
    | creates
    v
Azure Storage Account + Blob Container
    |
    | used by
    v
terraform/azure/environments/dev/
    |
    | stores state as
    v
dev.terraform.tfstate
```

The dev environment contains:

```text
backend.tf
backend.hcl.example
```

The real local backend configuration file is:

```text
backend.hcl
```

This file is not committed to Git.

Remote state resources are protected from accidental deletion with:

```hcl
lifecycle {
  prevent_destroy = true
}
```

Protected resources:

```text
azurerm_storage_account.tfstate
azurerm_storage_container.tfstate
```

---

## Terraform Security and Policy Validation

Terraform security validation uses:

```text
TFLint
Checkov
GitHub Actions
```

TFLint is used for:

```text
Terraform linting
AzureRM-specific checks
provider-specific validation
code quality validation
```

Checkov is used for:

```text
Infrastructure-as-Code security scanning
policy baseline
security finding visibility
```

Security workflow:

```text
.github/workflows/terraform-security-validation.yml
```

TFLint configuration:

```text
.tflint.hcl
```

Security documentation:

```text
docs/security/terraform-security-validation.md
```

The security workflow does not run:

```text
terraform plan
terraform apply
terraform destroy
```

Checkov currently runs in advisory mode:

```text
--soft-fail
```

---

## CloudFormation Static Validation

CloudFormation is included as AWS-native Infrastructure as Code practice.

The CloudFormation phase is static-validation only.

No AWS resources are deployed.

No AWS credentials are required.

No AWS costs are generated.

Validation tool:

```text
cfn-lint
```

Validation workflow:

```text
.github/workflows/cloudformation-validation.yml
```

The workflow validates all CloudFormation YAML templates inside:

```text
cloudformation/
```

---

## CloudFormation Basics

CloudFormation basics directory:

```text
cloudformation/basics/
```

Template:

```text
cloudformation/basics/networking-basic.yml
```

The template defines:

```text
VPC
Public subnet
Optional private subnet
Security group
Outputs
```

The template demonstrates:

```text
AWSTemplateFormatVersion
Description
Parameters
Mappings
Conditions
Resources
Outputs
Intrinsic functions
Tags
```

Validation command:

```bash
cfn-lint cloudformation/basics/networking-basic.yml
```

---

## CloudFormation Advanced

CloudFormation advanced directory:

```text
cloudformation/advanced/
```

Template:

```text
cloudformation/advanced/security-baseline.yml
```

The template defines:

```text
optional S3 audit bucket
S3 public access block
S3 server-side encryption
S3 bucket ownership controls
S3 bucket policy denying insecure transport
optional read-only IAM managed policy
environment-specific mapping
conditional resource creation
conditional property values
structured outputs
```

The template demonstrates:

```text
Metadata
Rules
advanced Parameters
Mappings
Conditions
DeletionPolicy
UpdateReplacePolicy
S3 BucketEncryption
S3 PublicAccessBlockConfiguration
S3 BucketPolicy
IAM ManagedPolicy
AWS pseudo parameters
advanced intrinsic functions
Outputs
```

Validation command:

```bash
cfn-lint cloudformation/advanced/security-baseline.yml
```

Repository-wide validation command:

```bash
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

No AWS deployment is performed.

---

## IaC Tool Comparison

The project uses three main automation and Infrastructure as Code approaches.

| Tool | Main Purpose | Used For in This Project |
|---|---|---|
| Ansible | Configuration management and operational automation | Linux configuration, services, monitoring, backups |
| Terraform | Cloud Infrastructure as Code | Azure networking, modules, environments, remote state |
| CloudFormation | AWS-native Infrastructure as Code | AWS template structure and static validation |

In simple terms:

```text
Ansible configures servers.
Terraform creates and manages cloud infrastructure.
CloudFormation defines AWS-native infrastructure templates.
```

More details are documented in:

```text
docs/iac-comparison.md
```

---

## What Was Actually Deployed

Actually deployed locally:

```text
Hyper-V Ubuntu nodes
Linux baseline configuration
Nginx
PostgreSQL
Node Exporter
Prometheus
Grafana
Grafana dashboards
PostgreSQL backup and restore validation
```

Actually deployed in Azure during validation:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
Azure Storage Account for Terraform remote state
Azure Blob Container for Terraform remote state
Terraform state blob
```

CloudFormation deployment:

```text
No CloudFormation stacks were deployed.
CloudFormation was used only for static validation.
```

---

## What Was Intentionally Not Deployed

Not deployed in Azure:

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

Not deployed in AWS:

```text
CloudFormation stacks
S3 buckets from CloudFormation templates
IAM policies from CloudFormation templates
EC2 resources from CloudFormation templates
VPC resources from CloudFormation templates
```

This is intentional.

The project is designed to demonstrate practical skills while avoiding unnecessary cloud costs.

---

## Azure Cost Safety

Cost safety guide:

```text
terraform/docs/azure-cost-safety.md
```

Mandatory Azure lab rule:

```text
Create -> Validate -> Screenshot -> Destroy
```

Azure cost safety rules:

```text
use a dedicated lab resource group
use small and cheap resources
review terraform plan before apply
do not leave resources running longer than needed
destroy resources after validation
check Azure Portal after destroy
never commit Terraform state
never commit real tfvars files
never commit real backend config files
never store Azure credentials in Git
```

CloudFormation cost safety rule:

```text
Write -> Validate -> Document
```

CloudFormation templates are not deployed to AWS.

---

## Validation Commands

Run YAML validation:

```bash
yamllint .
```

Run Ansible validation:

```bash
cd ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-lint .
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --syntax-check
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --syntax-check
```

Run Terraform formatting:

```bash
terraform fmt -check -recursive terraform
```

Run Terraform validation:

```bash
cd terraform/azure/basics
terraform init -backend=false -input=false
terraform validate
```

```bash
cd terraform/azure/environments/dev
terraform init -backend=false -input=false
terraform validate
```

```bash
cd terraform/azure/environments/test
terraform init -backend=false -input=false
terraform validate
```

```bash
cd terraform/azure/bootstrap/remote-state
terraform init -backend=false -input=false
terraform validate
```

Run CloudFormation validation:

```bash
cfn-lint cloudformation/basics/networking-basic.yml
cfn-lint cloudformation/advanced/security-baseline.yml
```

Repository-wide CloudFormation validation:

```bash
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

---

## Runtime Commands

Run full Ansible workflow:

```bash
cd ansible

export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass.txt

ansible-playbook playbooks/site.yml
```

Run Ansible preflight:

```bash
ansible-playbook playbooks/site.yml --tags preflight
```

Run Ansible post-deployment validation:

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

Run Terraform Azure module-based dev workflow:

```bash
cd terraform/azure/environments/dev

terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

Run Terraform Azure module-based test validation:

```bash
cd terraform/azure/environments/test

terraform init
terraform validate
terraform plan
```

Run Terraform remote state bootstrap workflow:

```bash
cd terraform/azure/bootstrap/remote-state

terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

CloudFormation workflow:

```bash
cfn-lint cloudformation/basics/networking-basic.yml
cfn-lint cloudformation/advanced/security-baseline.yml
```

No CloudFormation deployment is performed.

---

## GitHub Actions Validation

GitHub Actions validates Ansible, Terraform and CloudFormation code.

### Ansible Validation

Workflow file:

```text
.github/workflows/ansible-validation.yml
```

The Ansible workflow checks:

```text
YAML formatting
Ansible lint rules
required Ansible collections
Ansible playbook syntax
site.yml syntax with dev inventory
site.yml syntax with prod inventory
```

### Terraform Validation

Workflow file:

```text
.github/workflows/terraform-validation.yml
```

The Terraform workflow checks:

```text
terraform fmt -check -recursive terraform
terraform init -backend=false
terraform validate
```

The workflow does not run:

```text
terraform plan
terraform apply
terraform destroy
```

### Terraform Security Validation

Workflow file:

```text
.github/workflows/terraform-security-validation.yml
```

The Terraform security workflow checks:

```text
TFLint Terraform rules
TFLint AzureRM rules
Checkov Terraform security policies
```

The workflow does not deploy Azure resources.

### CloudFormation Validation

Workflow file:

```text
.github/workflows/cloudformation-validation.yml
```

The CloudFormation workflow checks:

```text
CloudFormation YAML templates
cfn-lint validation
```

Current templates checked:

```text
cloudformation/basics/networking-basic.yml
cloudformation/advanced/security-baseline.yml
```

The workflow does not deploy AWS resources.

---

## Documentation

Main documentation files:

| File | Purpose |
|---|---|
| `docs/project-summary.md` | Final project summary |
| `docs/iac-comparison.md` | Comparison of Ansible, Terraform and CloudFormation |
| `docs/final-architecture-overview.md` | Final architecture overview |
| `docs/architecture.md` | General lab architecture and design |
| `docs/ansible-architecture.md` | Architecture explanation of the Ansible project |
| `docs/runbooks/ansible-operations-guide.md` | Main operational guide for the Ansible workflow |
| `docs/security/terraform-security-validation.md` | Terraform security and policy validation documentation |
| `terraform/docs/azure-cost-safety.md` | Azure cost safety rules for Terraform |
| `cloudformation/basics/README.md` | CloudFormation basics documentation |
| `cloudformation/advanced/README.md` | CloudFormation advanced documentation |

Stage runbooks are stored in:

```text
docs/runbooks/
```

Important runbooks:

```text
docs/runbooks/stage-03-06-final-ansible-hardening.md
docs/runbooks/stage-04-01-terraform-azure-basics.md
docs/runbooks/stage-05-01-terraform-azure-modules.md
docs/runbooks/stage-05-02-terraform-environment-separation.md
docs/runbooks/stage-05-03-terraform-remote-state.md
docs/runbooks/stage-06-01-cloudformation-basics.md
docs/runbooks/stage-07-01-cloudformation-advanced.md
```

---

## Screenshots and Validation Evidence

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
docs/screenshots/stage-04-terraform-validation/
docs/screenshots/stage-05-terraform-azure-modules/
docs/screenshots/stage-05-terraform-environment-separation/
docs/screenshots/stage-05-terraform-remote-state/
docs/screenshots/stage-06-cloudformation-basics/
docs/screenshots/stage-07-cloudformation-advanced/
```

Stage 6.1 screenshot:

```text
docs/screenshots/stage-06-cloudformation-basics/
└── 01-cfn-lint-local-validation.png
```

Stage 7.1 screenshot:

```text
docs/screenshots/stage-07-cloudformation-advanced/
└── 01-cfn-lint-advanced-validation.png
```

Screenshots are used as validation evidence that the lab was configured and validated successfully.

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
| Terraform Modules | Reusable Infrastructure as Code structure |
| Terraform Environments | Environment-specific Infrastructure as Code structure |
| Terraform Remote State | Shared state storage model |
| TFLint | Terraform linting and Azure-specific static checks |
| Checkov | Infrastructure-as-Code security and policy scanning |
| AzureRM Provider | Terraform provider for Azure |
| Azure Student Subscription | Cloud practice environment |
| Azure Resource Group | Azure resource container |
| Azure Virtual Network | Azure networking |
| Azure Subnet | Azure network segmentation |
| Azure Network Security Group | Azure network filtering |
| Azure Storage Account | Remote state storage backend |
| Azure Blob Container | Terraform state blob storage |
| AWS CloudFormation | AWS-native Infrastructure as Code templates |
| cfn-lint | CloudFormation static validation |
| yamllint | YAML validation |
| ansible-lint | Ansible best-practice validation |
| GitHub Actions | Static CI validation |

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
│   └── roles/
│
├── terraform/
│   ├── azure/
│   │   ├── basics/
│   │   ├── bootstrap/
│   │   │   └── remote-state/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   └── test/
│   │   └── modules/
│   │       └── network-foundation/
│   └── docs/
│       └── azure-cost-safety.md
│
├── cloudformation/
│   ├── basics/
│   │   ├── README.md
│   │   └── networking-basic.yml
│   └── advanced/
│       ├── README.md
│       └── security-baseline.yml
│
├── scripts/
│   └── hyperv/
│       └── create-lab-network.ps1
│
├── docs/
│   ├── architecture.md
│   ├── ansible-architecture.md
│   ├── project-summary.md
│   ├── iac-comparison.md
│   ├── final-architecture-overview.md
│   ├── runbooks/
│   ├── screenshots/
│   ├── security/
│   └── troubleshooting/
│
└── .github/
    └── workflows/
        ├── ansible-validation.yml
        ├── terraform-validation.yml
        ├── terraform-security-validation.yml
        └── cloudformation-validation.yml
```

---

## Technical Outcomes

This project demonstrates practical work with:

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
Terraform module structure
Terraform root modules
Terraform child modules
Terraform module inputs
Terraform module outputs
Terraform environment separation
Terraform remote state with Azure Storage
Terraform AzureRM backend configuration
Terraform linting with TFLint
Terraform security scanning with Checkov
CloudFormation template structure
CloudFormation parameters
CloudFormation mappings
CloudFormation conditions
CloudFormation resources
CloudFormation outputs
CloudFormation intrinsic functions
CloudFormation Metadata
CloudFormation Rules
CloudFormation DeletionPolicy
CloudFormation UpdateReplacePolicy
CloudFormation S3 security configuration
CloudFormation IAM policy document structure
CloudFormation validation with cfn-lint
Azure Resource Group management
Azure Virtual Network basics
Azure Subnet basics
Azure Network Security Group basics
Azure Storage Account basics
Azure Blob Container basics
Azure cost safety workflow
AWS IaC static validation without deployment
infrastructure documentation and runbooks
```

---

## Final Status Summary

```text
The Ansible phase is complete.

The local Hyper-V Linux lab is automated with Ansible.
The project can deploy Linux baseline configuration, Nginx, PostgreSQL, Node Exporter, Prometheus and Grafana.
The monitoring stack is validated end-to-end.
Grafana dashboards are provisioned automatically.
Secrets are handled with Ansible Vault.
The project supports dev and prod-style inventories.
The project includes preflight and post-deployment validation.
The project includes PostgreSQL backup and restore validation.

The Terraform Azure phase is complete.

The project includes Azure networking basics, reusable Terraform modules, environment separation, remote state with Azure Storage, and Terraform security validation with TFLint and Checkov.

The CloudFormation phase is complete.

The project includes CloudFormation basics and advanced templates with cfn-lint validation.
No CloudFormation deployment is performed.
No AWS resources are created.

The final documentation phase is complete.

The repository includes a final project summary, IaC comparison, final architecture overview, runbooks, screenshots, cost safety documentation and security validation documentation.
```

---

## Safety Notice

This project uses real Azure resources during the Terraform phase.

All Azure resources must follow this rule:

```text
Create -> Validate -> Screenshot -> Destroy
```

CloudFormation is static-validation only.

CloudFormation templates are not deployed to AWS.

Never commit:

```text
terraform.tfvars
terraform.tfstate
terraform.tfstate.backup
.terraform/
backend.hcl
Azure credentials
AWS credentials
.aws/
Vault files
Vault password files
```

Always verify `git status` before committing.