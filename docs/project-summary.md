# Enterprise Automation Lab - Project Summary

## 1. Project Overview

Enterprise Automation Lab is a practical infrastructure automation project focused on Linux system administration, configuration management, monitoring, backup validation, Infrastructure as Code, cloud infrastructure modeling, and CI-based validation.

The project combines several infrastructure automation areas:

```text
local virtualization
Linux server administration
Ansible configuration management
monitoring automation
PostgreSQL backup and restore validation
Terraform Azure Infrastructure as Code
Terraform modules
Terraform remote state
Terraform security validation
AWS CloudFormation static validation
GitHub Actions CI validation
technical documentation
```

The project is built as a realistic hands-on lab rather than a theoretical example.

It demonstrates how infrastructure can be prepared, configured, validated, documented, and checked through automation.

---

## 2. Main Goal

The main goal of the project is to demonstrate an end-to-end infrastructure automation workflow.

The project shows how different automation tools fit together:

```text
Ansible = configure Linux servers and services
Terraform = define and manage cloud infrastructure
CloudFormation = define AWS-native infrastructure templates
GitHub Actions = validate code automatically
Documentation = explain architecture, operations and decisions
```

The project does not focus on only one tool.

It shows how infrastructure automation is usually composed from multiple tools, each solving a different part of the problem.

---

## 3. Project Scope

The project includes four major technical areas:

```text
1. Local infrastructure automation with Ansible
2. Monitoring stack deployment and validation
3. Terraform-based Azure Infrastructure as Code
4. AWS CloudFormation template validation
```

The project also includes:

```text
GitHub Actions pipelines
security validation
cost safety rules
runbooks
architecture documentation
validation screenshots
```

---

## 4. Local Lab Foundation

The project uses a local Hyper-V lab.

The lab is controlled from Kali Linux running inside WSL.

The Hyper-V environment contains multiple Ubuntu Linux nodes connected through an internal NAT network.

Control node:

```text
Kali Linux WSL
```

Virtualization platform:

```text
Hyper-V
```

Managed nodes:

```text
web-01
web-02
db-01
monitor-01
```

Network:

```text
192.168.100.0/24
```

This setup allows the project to practice real Linux automation without depending on paid cloud resources.

---

## 5. Hyper-V Lab Nodes

| Hostname | IP Address | Purpose |
|---|---:|---|
| `web-01` | `192.168.100.11` | Web server |
| `web-02` | `192.168.100.12` | Web server |
| `db-01` | `192.168.100.21` | Database server |
| `monitor-01` | `192.168.100.31` | Monitoring server |

Each node is managed over SSH by Ansible.

The Ansible control node uses SSH key-based authentication.

---

## 6. Ansible Automation Summary

The Ansible phase automates Linux server configuration and service deployment.

Ansible is used to configure:

```text
Linux baseline settings
Nginx web servers
PostgreSQL database server
Prometheus Node Exporter
Prometheus monitoring server
Grafana visualization platform
Grafana dashboards
PostgreSQL backup automation
PostgreSQL restore validation
```

The Ansible part of the project is organized with:

```text
inventories
group_vars
roles
playbooks
templates
handlers
tags
Ansible Vault
preflight validation
post-deployment validation
```

This demonstrates a structured Ansible project rather than a single flat playbook.

---

## 7. Ansible Roles

The project contains reusable Ansible roles.

| Role | Purpose |
|---|---|
| `linux_baseline` | Applies common Linux baseline configuration |
| `nginx` | Installs and configures Nginx web servers |
| `postgresql` | Installs and configures PostgreSQL |
| `node_exporter` | Deploys Node Exporter for Linux metrics |
| `prometheus` | Deploys Prometheus server |
| `grafana` | Deploys Grafana and provisions dashboards |
| `postgresql_backup` | Automates PostgreSQL backup and restore validation |

These roles make the automation modular and reusable.

---

## 8. Monitoring Summary

The project includes a monitoring stack based on:

```text
Node Exporter
Prometheus
Grafana
```

Monitoring flow:

```text
Linux nodes
    -> Node Exporter metrics
    -> Prometheus scraping
    -> Grafana dashboards
```

The monitoring stack validates that infrastructure services are observable.

Grafana is provisioned automatically with a dashboard.

The dashboard includes panels for:

```text
target availability
CPU usage
memory availability
filesystem free space
system load
network traffic
```

---

## 9. PostgreSQL Backup and Restore Validation

The project includes PostgreSQL backup automation.

Backup workflow:

```text
create backup directory
run pg_dump
validate backup file
update latest.sql symlink
apply retention cleanup
```

Restore validation workflow:

```text
find latest backup
create restore validation database
restore backup into validation database
run SQL validation query
confirm restored database is usable
```

This is important because a backup is only useful if it can be restored.

The project therefore validates both:

```text
backup creation
restore correctness
```

---

## 10. Ansible Vault and Secret Handling

The project uses Ansible Vault for local secret management.

Secrets are stored outside normal plaintext files.

Vault is used for values such as:

```text
PostgreSQL application password
Grafana admin password
```

The real Vault files and Vault password file are excluded from Git.

A safe example file is provided for documentation purposes.

This demonstrates basic secret management hygiene.

---

## 11. Terraform Azure Summary

The Terraform phase introduces Azure Infrastructure as Code.

Terraform is used to model cloud infrastructure in Azure.

The Terraform section includes:

```text
Azure provider configuration
input variables
locals
outputs
state management
safe plan/apply/destroy workflow
modules
environment separation
remote state
security validation
```

The Azure part is intentionally cost-safe.

The project creates only low-cost networking and storage resources.

No expensive services are used.

---

## 12. Terraform Azure Basics

The first Terraform Azure stage creates basic Azure networking resources:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
```

This demonstrates the standard Terraform workflow:

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

The purpose of this stage is to practice Terraform with real Azure resources while keeping cost risk low.

---

## 13. Terraform Modules

The project includes a reusable Terraform module:

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

The module separates reusable infrastructure logic from environment-specific values.

In simple terms:

```text
module = reusable infrastructure definition
environment = concrete configuration values
```

This structure is closer to real infrastructure projects than a single flat Terraform file.

---

## 14. Terraform Environment Separation

The project includes separate Terraform environments:

```text
dev
test
```

Directories:

```text
terraform/azure/environments/dev/
terraform/azure/environments/test/
```

Both environments call the same reusable module but use different values.

Example difference:

| Environment | VNet CIDR | Subnet CIDR |
|---|---|---|
| `dev` | `10.40.0.0/16` | `10.40.1.0/24` |
| `test` | `10.50.0.0/16` | `10.50.1.0/24` |

This demonstrates how the same module can be reused safely across environments.

---

## 15. Terraform Remote State

The project includes Terraform remote state using Azure Storage.

Remote state bootstrap directory:

```text
terraform/azure/bootstrap/remote-state/
```

The bootstrap creates:

```text
Resource Group
Storage Account
Blob Container
```

The dev environment can store its state in Azure Blob Storage as:

```text
dev.terraform.tfstate
```

This demonstrates how Terraform state can be stored remotely instead of only on the local machine.

Remote state is important because it supports:

```text
state persistence
team collaboration
centralized state storage
safer infrastructure workflow
```

---

## 16. Terraform Security and Policy Validation

The project includes Terraform static security validation.

Tools used:

```text
TFLint
Checkov
GitHub Actions
```

TFLint validates:

```text
Terraform quality
Terraform rules
AzureRM-specific checks
provider-specific issues
```

Checkov validates:

```text
Infrastructure-as-Code security posture
policy findings
security baseline issues
```

The Terraform security workflow does not deploy anything.

It only checks Terraform code.

Remote state storage resources are protected from accidental deletion with:

```hcl
lifecycle {
  prevent_destroy = true
}
```

---

## 17. CloudFormation Summary

The project includes AWS CloudFormation templates for AWS-native Infrastructure as Code practice.

The CloudFormation phase is static-validation only.

No AWS resources are created.

No AWS credentials are required.

No AWS costs are generated.

CloudFormation is used to demonstrate:

```text
AWS-native IaC syntax
template structure
parameters
mappings
conditions
resources
outputs
metadata
rules
IAM policy documents
S3 security configuration
```

Validation is performed with:

```text
cfn-lint
```

---

## 18. CloudFormation Basics

The CloudFormation basics template is:

```text
cloudformation/basics/networking-basic.yml
```

It defines:

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

This template introduces the basic CloudFormation structure.

---

## 19. CloudFormation Advanced

The CloudFormation advanced template is:

```text
cloudformation/advanced/security-baseline.yml
```

It defines:

```text
optional S3 audit bucket
S3 public access block
S3 server-side encryption
S3 ownership controls
S3 bucket policy denying insecure transport
optional IAM read-only managed policy
environment-specific mappings
conditional resource creation
conditional property values
structured outputs
```

It demonstrates advanced CloudFormation concepts:

```text
Metadata
Rules
DeletionPolicy
UpdateReplacePolicy
AWS pseudo parameters
advanced intrinsic functions
S3 security baseline
IAM policy document structure
```

This gives the project an AWS-native IaC section without creating paid AWS resources.

---

## 20. GitHub Actions CI Summary

The project includes GitHub Actions validation workflows.

Workflows:

```text
Ansible Validation
Terraform Validation
Terraform Security Validation
CloudFormation Validation
```

The CI pipelines validate:

```text
YAML syntax
Ansible linting
Ansible playbook syntax
Terraform formatting
Terraform validation
Terraform linting
Terraform security scanning
CloudFormation cfn-lint validation
```

The CI workflows do not run destructive infrastructure operations.

They do not automatically deploy cloud infrastructure.

---

## 21. Documentation Summary

The project includes structured documentation.

Documentation types:

```text
architecture documentation
stage runbooks
tool-specific README files
security documentation
cost safety documentation
validation evidence
screenshots
```

Important documentation files:

```text
README.md
docs/architecture.md
docs/ansible-architecture.md
docs/project-summary.md
docs/iac-comparison.md
docs/final-architecture-overview.md
docs/security/terraform-security-validation.md
terraform/docs/azure-cost-safety.md
```

Runbooks are stored in:

```text
docs/runbooks/
```

Screenshots are stored in:

```text
docs/screenshots/
```

---

## 22. What Was Actually Deployed

The project includes real local and Azure deployment validation.

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

The Azure resources are created for validation and then managed according to cost-safety rules.

---

## 23. What Was Intentionally Not Deployed

The project intentionally avoids high-cost or unnecessary cloud resources.

Not deployed in Azure:

```text
AKS
Azure Firewall
Application Gateway
NAT Gateway
Azure Bastion
large virtual machines
managed databases
premium disks
VPN Gateway
ExpressRoute
```

Not deployed in AWS:

```text
CloudFormation stacks
S3 buckets from CloudFormation templates
IAM policies from CloudFormation templates
EC2 resources from CloudFormation templates
```

CloudFormation is used only for static validation in this project.

---

## 24. Cost Safety

The project follows strict cost safety rules.

Azure rule:

```text
Create -> Validate -> Screenshot -> Destroy
```

CloudFormation rule:

```text
Write -> Validate -> Document
```

The CloudFormation section does not deploy AWS resources.

This protects the project from unexpected cloud costs.

---

## 25. Security Considerations

The project includes several security-related practices:

```text
SSH key-based access
passwordless sudo validation for automation user
Ansible Vault for local secrets
Git ignore rules for sensitive files
Terraform state exclusion from Git
Terraform remote state protection
TFLint validation
Checkov security scanning
S3 public access blocking in CloudFormation template
S3 encryption in CloudFormation template
S3 insecure transport denial policy
no cloud credentials committed to Git
```

The project is not a full production security platform, but it demonstrates important security-aware infrastructure practices.

---

## 26. Key Technical Outcomes

The project demonstrates practical ability to:

```text
build a local Linux infrastructure lab
configure multiple Linux nodes through Ansible
structure Ansible roles and playbooks
separate inventories and variables
handle secrets with Ansible Vault
deploy and validate monitoring services
automate PostgreSQL backup and restore validation
write Terraform code for Azure networking
create reusable Terraform modules
separate Terraform environments
configure Terraform remote state
add Terraform linting and security validation
write CloudFormation templates
validate CloudFormation templates with cfn-lint
use GitHub Actions for infrastructure code validation
document infrastructure decisions and operations
```

---

## 27. Tool Responsibilities

The project clearly separates tool responsibilities.

```text
Ansible
```

Used for server configuration and application/service deployment.

```text
Terraform
```

Used for Azure infrastructure definition and cloud resource lifecycle.

```text
CloudFormation
```

Used for AWS-native Infrastructure as Code template practice and static validation.

```text
GitHub Actions
```

Used for continuous validation of infrastructure code.

```text
Documentation
```

Used to make the project understandable, reproducible, and reviewable.

---

## 28. Why This Project Is Valuable

This project is valuable because it connects multiple real infrastructure skills into one coherent lab.

It is not only a collection of isolated examples.

It demonstrates:

```text
multi-node Linux automation
monitoring deployment
backup and restore operations
cloud Infrastructure as Code
modular Terraform structure
remote state concepts
IaC security validation
CloudFormation syntax and validation
CI pipelines
documentation discipline
```

The project shows practical infrastructure thinking:

```text
build
configure
validate
secure
document
automate
```

---

## 29. Final Project State

At the end of the project, the repository contains:

```text
complete Ansible automation phase
complete Terraform Azure advanced baseline
complete Terraform security validation phase
complete CloudFormation basics phase
complete CloudFormation advanced phase
CI validation workflows
technical documentation
runbooks
screenshots
cost safety documentation
security validation documentation
```

Current final project stage:

```text
Stage 8 - Final IaC Comparison and Project Summary
```

---

## 30. Summary

Enterprise Automation Lab demonstrates a practical infrastructure automation workflow across local Linux systems, Azure Infrastructure as Code, and AWS-native CloudFormation templates.

The project combines:

```text
Ansible for configuration management
Terraform for cloud infrastructure
CloudFormation for AWS-native IaC syntax
GitHub Actions for validation
Prometheus and Grafana for monitoring
PostgreSQL backup and restore validation for operations
structured documentation for maintainability
```

The project is designed to be technically clear, cost-safe, and reviewable.

It provides evidence of practical infrastructure automation skills across several important areas of modern IT infrastructure.
