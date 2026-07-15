# Final Architecture Overview

## 1. Purpose

This document provides the final architecture overview for the Enterprise Automation Lab.

It summarizes the complete project architecture across:

```text
local Hyper-V infrastructure
Ansible automation
monitoring stack
PostgreSQL backup and restore validation
Terraform Azure Infrastructure as Code
Terraform security validation
CloudFormation static validation
GitHub Actions CI validation
documentation and runbooks
```

The goal is to describe how all parts of the project fit together as one complete infrastructure automation lab.

---

## 2. Architecture Summary

Enterprise Automation Lab is built as a layered infrastructure automation project.

The main layers are:

```text
1. Local virtualization layer
2. Linux server layer
3. Configuration management layer
4. Monitoring layer
5. Backup and restore validation layer
6. Azure Infrastructure as Code layer
7. Terraform security validation layer
8. AWS CloudFormation static validation layer
9. CI validation layer
10. Documentation layer
```

Each layer has a clear responsibility.

Together, they demonstrate a complete infrastructure automation workflow.

---

## 3. High-Level Architecture

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
│   └── EA-LAB-Internal NAT Network
│       ├── web-01
│       ├── web-02
│       ├── db-01
│       └── monitor-01
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

## 4. Design Principle

The project follows a clear separation of responsibilities.

```text
Hyper-V provides local infrastructure.
Ansible configures Linux systems and services.
Prometheus and Grafana provide observability.
PostgreSQL backup automation validates operational recovery.
Terraform models Azure infrastructure.
TFLint and Checkov validate Terraform quality and security.
CloudFormation demonstrates AWS-native IaC templates.
GitHub Actions validates infrastructure code.
Documentation explains architecture and operations.
```

This separation keeps the project understandable and closer to real infrastructure workflows.

---

## 5. Local Infrastructure Layer

The local infrastructure layer is based on Hyper-V.

The lab uses a dedicated internal NAT network.

| Component | Value |
|---|---|
| Virtualization platform | Hyper-V |
| Host operating system | Windows 11 |
| Control workstation | Kali Linux WSL |
| Hyper-V switch | `EA-LAB-Internal` |
| NAT name | `EA-LAB-NAT` |
| Network | `192.168.100.0/24` |
| Gateway | `192.168.100.1` |

The local lab allows Linux infrastructure automation practice without depending on cloud compute resources.

---

## 6. Managed Linux Nodes

The Hyper-V lab contains four Ubuntu Linux nodes.

| Hostname | IP Address | Main Role |
|---|---:|---|
| `web-01` | `192.168.100.11` | Web server |
| `web-02` | `192.168.100.12` | Web server |
| `db-01` | `192.168.100.21` | Database server |
| `monitor-01` | `192.168.100.31` | Monitoring server |

All nodes are managed from Kali Linux WSL over SSH.

SSH key-based authentication is used for automation access.

---

## 7. Network Architecture

The local lab network is isolated from the external network by the Hyper-V NAT design.

```text
Kali Linux WSL
    |
    | SSH / Ansible
    v
Hyper-V Internal NAT Network: 192.168.100.0/24
    |
    ├── web-01      192.168.100.11
    ├── web-02      192.168.100.12
    ├── db-01       192.168.100.21
    └── monitor-01  192.168.100.31
```

This structure provides a controlled environment for automation testing.

---

## 8. Configuration Management Layer

The configuration management layer is implemented with Ansible.

Ansible connects to managed nodes over SSH and applies roles and playbooks.

The main Ansible entrypoint is:

```text
ansible/playbooks/site.yml
```

The Ansible layer automates:

```text
Linux baseline configuration
Nginx deployment
PostgreSQL deployment
Node Exporter deployment
Prometheus deployment
Grafana deployment
Grafana dashboard provisioning
PostgreSQL backup automation
PostgreSQL restore validation
preflight checks
post-deployment validation
```

---

## 9. Ansible Project Structure

The Ansible structure is organized around inventories, playbooks and roles.

```text
ansible/
├── ansible.cfg
├── requirements.yml
├── examples/
├── inventories/
│   ├── dev/
│   └── prod/
├── playbooks/
└── roles/
```

This structure supports:

```text
environment separation
role reuse
static validation
safe secret examples
clear operational workflows
```

---

## 10. Ansible Inventory Model

The project uses a development inventory for the active Hyper-V lab.

```text
ansible/inventories/dev/hosts.ini
```

Inventory groups:

```text
web
database
monitoring
linux
```

Group purpose:

| Group | Hosts | Purpose |
|---|---|---|
| `web` | `web-01`, `web-02` | Web servers |
| `database` | `db-01` | PostgreSQL server |
| `monitoring` | `monitor-01` | Prometheus and Grafana server |
| `linux` | all Linux nodes | Shared Linux baseline and metrics |

---

## 11. Ansible Role Architecture

The project uses reusable Ansible roles.

| Role | Responsibility |
|---|---|
| `linux_baseline` | Common Linux baseline configuration |
| `nginx` | Nginx web server installation and configuration |
| `postgresql` | PostgreSQL installation and database setup |
| `node_exporter` | Node Exporter metrics agent deployment |
| `prometheus` | Prometheus server deployment and configuration |
| `grafana` | Grafana installation, datasource and dashboard provisioning |
| `postgresql_backup` | Backup and restore validation automation |

The role-based design makes the project easier to extend and maintain.

---

## 12. Service Deployment Architecture

The service deployment architecture is:

```text
web-01
├── Linux baseline
├── Nginx
└── Node Exporter

web-02
├── Linux baseline
├── Nginx
└── Node Exporter

db-01
├── Linux baseline
├── PostgreSQL
├── PostgreSQL backup automation
├── PostgreSQL restore validation
└── Node Exporter

monitor-01
├── Linux baseline
├── Node Exporter
├── Prometheus
└── Grafana
```

This gives the project a realistic multi-node infrastructure layout.

---

## 13. Monitoring Architecture

The monitoring layer is based on:

```text
Node Exporter
Prometheus
Grafana
```

Monitoring data flow:

```text
Linux nodes
    |
    | expose metrics on port 9100
    v
Node Exporter
    |
    | scraped by
    v
Prometheus on monitor-01
    |
    | queried by
    v
Grafana on monitor-01
    |
    | displays
    v
Enterprise Linux Overview Dashboard
```

Prometheus endpoint:

```text
http://192.168.100.31:9090
```

Grafana endpoint:

```text
http://192.168.100.31:3000
```

---

## 14. Monitoring Targets

Prometheus scrapes Node Exporter metrics from all Linux nodes.

| Target | Endpoint |
|---|---|
| `web-01` | `http://192.168.100.11:9100/metrics` |
| `web-02` | `http://192.168.100.12:9100/metrics` |
| `db-01` | `http://192.168.100.21:9100/metrics` |
| `monitor-01` | `http://192.168.100.31:9100/metrics` |

This validates that the entire Linux lab is observable.

---

## 15. Grafana Dashboard Architecture

Grafana is provisioned automatically.

The project provisions:

```text
Prometheus datasource
Enterprise Linux Overview dashboard
```

Dashboard folder:

```text
Enterprise Automation Lab
```

Dashboard name:

```text
Enterprise Linux Overview
```

Dashboard panels include:

```text
Node Exporter Targets UP
CPU Usage by Instance
Memory Available by Instance
Root Filesystem Free Space
System Load 1m
Network Receive Traffic
```

This demonstrates monitoring-as-code concepts through Ansible provisioning.

---

## 16. Backup and Restore Architecture

The project includes operational backup and restore validation for PostgreSQL.

The backup target is:

```text
db-01
```

Backup location:

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

Backup flow:

```text
PostgreSQL database
    |
    | pg_dump
    v
timestamped SQL backup file
    |
    | latest.sql symlink
    v
restore validation workflow
    |
    | psql restore
    v
validation database
    |
    | SQL query check
    v
restore confirmed
```

This proves that the backup workflow is not only creating files but also validating recovery.

---

## 17. Secret Management Architecture

The project uses Ansible Vault for local secret handling.

Vault-managed values include:

```text
PostgreSQL application password
Grafana admin password
```

Real Vault files are not committed to Git.

Vault password file is not committed to Git.

Safe example file:

```text
ansible/examples/vault.yml.example
```

This design keeps sensitive values out of the repository while still documenting expected secret structure.

---

## 18. Terraform Azure Architecture

The Terraform layer models Azure infrastructure.

It includes:

```text
Terraform Azure basics
Terraform modules
Terraform environment separation
Terraform remote state
Terraform security validation
```

Terraform directories:

```text
terraform/azure/basics/
terraform/azure/modules/network-foundation/
terraform/azure/environments/dev/
terraform/azure/environments/test/
terraform/azure/bootstrap/remote-state/
```

Terraform responsibilities:

```text
define Azure resources
separate reusable modules from environments
manage state
validate formatting and syntax
support security scanning
```

---

## 19. Terraform Azure Basics Architecture

The basics configuration creates a small Azure networking foundation.

Resources:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
```

Resource names:

| Resource | Name |
|---|---|
| Resource Group | `rg-ea-lab-dev` |
| Virtual Network | `vnet-ea-lab-dev` |
| Subnet | `snet-ea-lab-dev-main` |
| Network Security Group | `nsg-ea-lab-dev-main` |

This stage validates the basic Terraform lifecycle:

```text
init
fmt
validate
plan
apply
state list
output
destroy
```

---

## 20. Terraform Module Architecture

The reusable module is:

```text
terraform/azure/modules/network-foundation/
```

The module creates:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
```

The module is called by environment directories.

Module architecture:

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

This demonstrates reusable Infrastructure as Code structure.

---

## 21. Terraform Environment Architecture

The project separates Terraform environments.

Environments:

```text
dev
test
```

Directories:

```text
terraform/azure/environments/dev/
terraform/azure/environments/test/
```

Environment comparison:

| Environment | VNet CIDR | Subnet CIDR |
|---|---|---|
| `dev` | `10.40.0.0/16` | `10.40.1.0/24` |
| `test` | `10.50.0.0/16` | `10.50.1.0/24` |

Both environments use the same module.

This demonstrates how one module can support multiple isolated environments.

---

## 22. Terraform Remote State Architecture

Remote state is implemented with Azure Storage.

Bootstrap directory:

```text
terraform/azure/bootstrap/remote-state/
```

Bootstrap resources:

```text
Resource Group
Storage Account
Blob Container
```

Remote state flow:

```text
terraform/azure/bootstrap/remote-state/
    |
    | creates backend infrastructure
    v
Azure Storage Account + Blob Container
    |
    | stores
    v
dev.terraform.tfstate
    |
    | used by
    v
terraform/azure/environments/dev/
```

The dev environment uses:

```text
backend.tf
backend.hcl
```

The real `backend.hcl` file is not committed to Git.

Remote state storage resources are protected with:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This protects data-bearing Terraform backend resources from accidental deletion.

---

## 23. Terraform Security Validation Architecture

Terraform security validation uses:

```text
TFLint
Checkov
GitHub Actions
```

Configuration file:

```text
.tflint.hcl
```

Workflow file:

```text
.github/workflows/terraform-security-validation.yml
```

Documentation:

```text
docs/security/terraform-security-validation.md
```

TFLint checks:

```text
Terraform recommended rules
AzureRM-specific rules
Terraform root module quality
```

Checkov checks:

```text
Terraform security posture
Infrastructure-as-Code policy findings
```

Checkov runs in advisory mode:

```text
--soft-fail
```

This gives visibility into security findings without blocking the initial baseline.

---

## 24. CloudFormation Architecture

The CloudFormation layer demonstrates AWS-native Infrastructure as Code.

CloudFormation is static-validation only in this project.

No AWS resources are created.

CloudFormation directories:

```text
cloudformation/basics/
cloudformation/advanced/
```

Validation tool:

```text
cfn-lint
```

Workflow:

```text
.github/workflows/cloudformation-validation.yml
```

CloudFormation templates are validated locally and through GitHub Actions.

---

## 25. CloudFormation Basics Architecture

Template:

```text
cloudformation/basics/networking-basic.yml
```

The template defines:

```text
VPC
public subnet
optional private subnet
security group
outputs
```

It demonstrates:

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

This template introduces the basic structure of an AWS CloudFormation stack.

---

## 26. CloudFormation Advanced Architecture

Template:

```text
cloudformation/advanced/security-baseline.yml
```

The template defines:

```text
optional S3 audit bucket
S3 public access block
S3 server-side encryption
S3 ownership controls
S3 bucket policy denying insecure transport
optional read-only IAM managed policy
conditional resources
conditional property values
structured outputs
```

It demonstrates:

```text
Metadata
Rules
advanced Parameters
Mappings
Conditions
DeletionPolicy
UpdateReplacePolicy
AWS pseudo parameters
advanced intrinsic functions
IAM policy document structure
S3 security baseline
```

This gives the project an AWS-native security baseline template without AWS deployment.

---

## 27. CI Validation Architecture

GitHub Actions validates the repository automatically.

Workflows:

```text
.github/workflows/ansible-validation.yml
.github/workflows/terraform-validation.yml
.github/workflows/terraform-security-validation.yml
.github/workflows/cloudformation-validation.yml
```

CI validation coverage:

| Workflow | Validates |
|---|---|
| Ansible Validation | YAML, ansible-lint, playbook syntax |
| Terraform Validation | terraform fmt, init, validate |
| Terraform Security Validation | TFLint, Checkov |
| CloudFormation Validation | cfn-lint |

The workflows are validation-only.

They do not automatically deploy cloud resources.

---

## 28. Repository Architecture

Final repository structure:

```text
enterprise-automation-lab/
│
├── ansible/
│   ├── ansible.cfg
│   ├── requirements.yml
│   ├── examples/
│   ├── inventories/
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
│   └── advanced/
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
├── scripts/
│   └── hyperv/
│
└── .github/
    └── workflows/
```

---

## 29. Documentation Architecture

The documentation layer contains several categories.

```text
root README
architecture documents
stage runbooks
security documentation
cost safety documentation
tool-specific README files
validation screenshots
troubleshooting notes
```

Important final documents:

```text
docs/project-summary.md
docs/iac-comparison.md
docs/final-architecture-overview.md
```

These documents explain:

```text
what the project does
how the tools compare
how the final architecture is structured
what was deployed
what was validated
what was intentionally not deployed
```

---

## 30. Validation Evidence Architecture

Validation evidence is stored in:

```text
docs/screenshots/
```

Screenshot categories follow project stages.

Examples:

```text
stage-03-final-ansible-hardening
stage-05-terraform-remote-state
stage-06-cloudformation-basics
stage-07-cloudformation-advanced
```

Screenshots provide evidence for:

```text
successful commands
working services
cloud resource validation
CI validation
local static validation
```

This makes the project easier to review.

---

## 31. Cost Safety Architecture

Cost safety is part of the architecture.

Azure cost safety approach:

```text
create only small resources
validate quickly
take screenshots
destroy when no longer needed
avoid expensive services
exclude credentials and state from Git
```

CloudFormation cost safety approach:

```text
write templates
validate templates
document templates
do not deploy AWS stacks
```

This allows the project to demonstrate cloud skills without unnecessary spending.

---

## 32. Security Architecture

Security-related practices in the project:

```text
SSH key-based automation access
passwordless sudo validation
Ansible Vault for secrets
Git ignore rules for sensitive files
Terraform state excluded from Git
Terraform backend config excluded from Git
Terraform remote state protection
TFLint validation
Checkov scanning
CloudFormation S3 security baseline
CloudFormation IAM policy document validation
AWS credentials excluded from Git
Azure credentials excluded from Git
```

The project is not presented as a production security platform.

It is a practical infrastructure automation lab with security-aware design decisions.

---

## 33. Data Flow Summary

Main data and control flows:

```text
Developer writes code in repository.
    |
    v
GitHub Actions validates code.
    |
    v
Ansible configures local Linux nodes.
    |
    v
Linux nodes expose metrics.
    |
    v
Prometheus collects metrics.
    |
    v
Grafana displays dashboards.
```

Terraform flow:

```text
Developer writes Terraform code.
    |
    v
GitHub Actions validates Terraform syntax and security.
    |
    v
Terraform creates Azure resources when run manually.
    |
    v
Remote state is stored in Azure Storage.
```

CloudFormation flow:

```text
Developer writes CloudFormation templates.
    |
    v
cfn-lint validates templates locally and in CI.
    |
    v
No AWS deployment is performed.
```

---

## 34. What Makes the Architecture Complete

The architecture is complete because it includes:

```text
infrastructure foundation
server configuration
service deployment
monitoring
backup validation
cloud IaC
remote state
security validation
CI validation
documentation
cost safety
```

It does not only show code.

It shows the full infrastructure lifecycle:

```text
build
configure
validate
monitor
backup
secure
document
```

---

## 35. Final Architecture Result

At the final stage, the project demonstrates:

```text
a local Hyper-V Linux infrastructure lab
multi-node Ansible automation
monitoring stack with Prometheus and Grafana
PostgreSQL backup and restore validation
Terraform Azure Infrastructure as Code
Terraform modules and environment separation
Terraform remote state with Azure Storage
Terraform linting and security validation
CloudFormation basic and advanced templates
CloudFormation static validation with cfn-lint
GitHub Actions validation pipelines
structured technical documentation
validation screenshots
```

---

## 36. Final Summary

Enterprise Automation Lab is a complete infrastructure automation project.

It combines local Linux automation, cloud Infrastructure as Code, monitoring, backup validation, security checks, CI validation and documentation.

The final architecture shows how multiple tools can work together:

```text
Ansible configures systems.
Terraform provisions cloud infrastructure.
CloudFormation demonstrates AWS-native IaC templates.
Prometheus and Grafana provide observability.
GitHub Actions validates infrastructure code.
Documentation makes the project understandable and reproducible.
```

This architecture represents a practical and reviewable infrastructure automation lab.
