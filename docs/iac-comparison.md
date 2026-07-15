# Infrastructure as Code Comparison

## 1. Purpose

This document compares the Infrastructure as Code and automation tools used in the Enterprise Automation Lab.

The project uses three main infrastructure automation approaches:

```text
Ansible
Terraform
CloudFormation
```

Each tool has a different purpose.

The goal of this document is to explain:

```text
what each tool does
where each tool fits in the project
what was deployed
what was validated
what was intentionally not deployed
how the tools complement each other
```

---

## 2. High-Level Summary

| Tool | Main Purpose | Used For in This Project |
|---|---|---|
| Ansible | Configuration management and server automation | Linux configuration, services, monitoring, backups |
| Terraform | Cloud Infrastructure as Code | Azure networking, modules, environments, remote state |
| CloudFormation | AWS-native Infrastructure as Code | AWS template structure and static validation |

In simple terms:

```text
Ansible configures servers.
Terraform creates and manages cloud infrastructure.
CloudFormation defines AWS-native infrastructure templates.
```

---

## 3. Tool Responsibility Model

The project separates tool responsibilities clearly.

```text
Terraform
    -> defines cloud infrastructure

Ansible
    -> configures operating systems and services

CloudFormation
    -> demonstrates AWS-native IaC templates

GitHub Actions
    -> validates all infrastructure code
```

This separation is important because real infrastructure projects usually do not rely on only one tool.

A practical infrastructure workflow often combines:

```text
provisioning
configuration management
monitoring
validation
security checks
documentation
```

---

## 4. Ansible Overview

Ansible is a configuration management and automation tool.

It connects to existing machines, usually over SSH, and applies configuration.

In this project, Ansible is used to configure Linux servers in the local Hyper-V lab.

Ansible manages:

```text
Linux baseline configuration
Nginx
PostgreSQL
Node Exporter
Prometheus
Grafana
Grafana dashboards
PostgreSQL backup automation
PostgreSQL restore validation
```

Ansible works well when infrastructure already exists and needs to be configured.

---

## 5. Terraform Overview

Terraform is an Infrastructure as Code tool for defining and managing infrastructure resources.

Terraform uses providers to communicate with cloud platforms.

In this project, Terraform is used with Azure.

Terraform manages:

```text
Azure Resource Groups
Azure Virtual Networks
Azure Subnets
Azure Network Security Groups
Azure Storage Account for remote state
Azure Blob Container for remote state
```

Terraform works well when infrastructure resources need to be created, modified, tracked, and destroyed.

---

## 6. CloudFormation Overview

CloudFormation is AWS-native Infrastructure as Code.

It defines AWS resources using YAML or JSON templates.

In this project, CloudFormation is used for static validation only.

CloudFormation templates demonstrate:

```text
AWS VPC structure
subnets
security groups
S3 bucket security configuration
IAM managed policy structure
conditions
mappings
rules
outputs
metadata
```

No CloudFormation stacks are deployed in this project.

The purpose is to demonstrate AWS-native IaC syntax and validation without creating AWS resources or generating AWS costs.

---

## 7. Configuration Management vs Infrastructure Provisioning

The key distinction:

```text
configuration management = configure existing systems
infrastructure provisioning = create infrastructure resources
```

Ansible belongs mainly to configuration management.

Terraform and CloudFormation belong mainly to infrastructure provisioning.

Project examples:

| Task | Best Tool | Reason |
|---|---|---|
| Install Nginx on Ubuntu | Ansible | Configures an existing server |
| Create Azure VNet | Terraform | Creates cloud infrastructure |
| Define AWS S3 bucket template | CloudFormation | Defines AWS-native infrastructure |
| Configure Grafana datasource | Ansible | Configures application/service state |
| Create Azure Storage Account for state | Terraform | Manages Azure cloud resource |
| Validate AWS template syntax | CloudFormation + cfn-lint | Checks AWS-native IaC template |

---

## 8. Declarative vs Procedural Style

All three tools support declarative infrastructure concepts, but they feel different in practice.

### Ansible

Ansible playbooks describe desired configuration tasks.

Example concept:

```text
install package
copy config file
restart service if changed
verify endpoint
```

Ansible is task-oriented.

It often reads like:

```text
do this
then do this
then validate this
```

### Terraform

Terraform describes desired infrastructure state.

Example concept:

```text
there should be a resource group
there should be a virtual network
there should be a subnet
there should be a network security group
```

Terraform calculates the difference between current state and desired state using its state file.

### CloudFormation

CloudFormation describes desired AWS stack resources.

Example concept:

```text
this stack should contain a VPC
this stack should contain a subnet
this stack should contain a security group
```

CloudFormation state is managed by AWS as part of the stack.

---

## 9. State Management

State management is one of the biggest differences between the tools.

| Tool | State Handling |
|---|---|
| Ansible | Usually stateless; checks target systems during execution |
| Terraform | Uses a Terraform state file |
| CloudFormation | AWS manages stack state |

### Ansible State

Ansible does not usually maintain a separate state file.

It connects to machines and checks current system state.

Example:

```text
Is Nginx installed?
Is the service running?
Does the config file exist?
```

Then it applies changes if needed.

### Terraform State

Terraform stores infrastructure state in:

```text
terraform.tfstate
```

or remote backend storage.

In this project, Terraform remote state is stored in Azure Blob Storage:

```text
dev.terraform.tfstate
```

This allows Terraform to know which resources it manages.

### CloudFormation State

CloudFormation state is managed by AWS.

When a stack is deployed, AWS tracks the resources in that stack.

In this project, no CloudFormation stack is deployed, so only static template validation is used.

---

## 10. Idempotency

Idempotency means that running the same automation multiple times should not create unnecessary changes.

All three tools support idempotent workflows, but in different ways.

| Tool | Idempotency Model |
|---|---|
| Ansible | Modules check and apply changes only when needed |
| Terraform | Compares desired configuration with state |
| CloudFormation | Compares template changes with stack state |

Project examples:

```text
Ansible should not reinstall Nginx unnecessarily.
Terraform should not recreate a VNet if nothing changed.
CloudFormation should not update stack resources if the template is unchanged.
```

In this project, idempotency is demonstrated most directly through Ansible and Terraform.

CloudFormation is validated statically and not deployed.

---

## 11. Language and File Format

| Tool | Language / Format |
|---|---|
| Ansible | YAML |
| Terraform | HCL |
| CloudFormation | YAML |

### Ansible YAML

Ansible uses YAML playbooks and roles.

Example structure:

```text
tasks
handlers
templates
defaults
vars
inventory
```

### Terraform HCL

Terraform uses HashiCorp Configuration Language.

Example structure:

```text
resource
variable
output
locals
module
provider
terraform block
```

### CloudFormation YAML

CloudFormation uses YAML templates.

Example structure:

```text
Parameters
Mappings
Conditions
Resources
Outputs
Metadata
Rules
```

---

## 12. Project Usage Comparison

| Area | Ansible | Terraform | CloudFormation |
|---|---|---|---|
| Local Linux automation | Yes | No | No |
| Service deployment | Yes | No | No |
| Monitoring stack | Yes | No | No |
| PostgreSQL backup automation | Yes | No | No |
| Azure infrastructure | No | Yes | No |
| Terraform modules | No | Yes | No |
| Remote state | No | Yes | No |
| AWS template syntax | No | No | Yes |
| AWS deployment | No | No | No |
| Static validation | Yes | Yes | Yes |
| CI validation | Yes | Yes | Yes |

---

## 13. What Ansible Does in This Project

Ansible is responsible for the local Hyper-V Linux infrastructure.

It configures:

```text
web-01
web-02
db-01
monitor-01
```

Ansible applies:

```text
Linux baseline role
Nginx role
PostgreSQL role
Node Exporter role
Prometheus role
Grafana role
PostgreSQL backup role
```

Ansible also handles:

```text
preflight checks
post-deployment validation
environment separation
Vault-based secrets
operational tags
manual backup and restore validation
```

Ansible is the operational automation layer of the project.

---

## 14. What Terraform Does in This Project

Terraform is responsible for Azure Infrastructure as Code.

Terraform defines:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
Storage Account
Blob Container
remote state backend
```

Terraform demonstrates:

```text
providers
variables
locals
outputs
modules
environments
remote state
state migration
security validation
```

Terraform is the cloud infrastructure provisioning layer of the project.

---

## 15. What CloudFormation Does in This Project

CloudFormation is responsible for AWS-native IaC template practice.

CloudFormation templates demonstrate:

```text
basic networking template
advanced security baseline template
parameters
mappings
conditions
rules
metadata
resources
outputs
intrinsic functions
IAM policy documents
S3 security configuration
```

CloudFormation is not used for deployment in this project.

It is used for:

```text
AWS IaC syntax practice
static validation
documentation
tool comparison
```

CloudFormation is the AWS-native IaC learning and validation layer of the project.

---

## 16. What Was Actually Deployed

### Deployed by Ansible

The following was deployed and configured in the local Hyper-V lab:

```text
Linux baseline configuration
Nginx
PostgreSQL
Node Exporter
Prometheus
Grafana
Grafana dashboards
PostgreSQL backup automation
PostgreSQL restore validation
```

### Deployed by Terraform

The following was deployed in Azure during validation stages:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
Storage Account for Terraform remote state
Blob Container for Terraform remote state
Terraform state blob
```

### Deployed by CloudFormation

Nothing was deployed by CloudFormation.

CloudFormation was static-validation only.

---

## 17. What Was Intentionally Not Deployed

The project avoids unnecessary cost and risk.

### Not Deployed in Azure

```text
AKS
Azure Firewall
Application Gateway
NAT Gateway
Azure Bastion
large virtual machines
managed databases
premium disks
snapshots
VPN Gateway
ExpressRoute
```

### Not Deployed in AWS

```text
CloudFormation stacks
S3 buckets from CloudFormation templates
IAM policies from CloudFormation templates
EC2 resources from CloudFormation templates
VPC resources from CloudFormation templates
```

This is intentional.

CloudFormation templates are included to show AWS IaC knowledge without generating AWS costs.

---

## 18. Validation Tools

Each tool has its own validation method.

| Area | Validation Tool |
|---|---|
| YAML | yamllint |
| Ansible | ansible-lint |
| Ansible playbooks | ansible-playbook --syntax-check |
| Terraform formatting | terraform fmt |
| Terraform syntax | terraform validate |
| Terraform linting | TFLint |
| Terraform security | Checkov |
| CloudFormation syntax | cfn-lint |
| CI validation | GitHub Actions |

This gives the project a strong validation workflow.

---

## 19. GitHub Actions Workflows

The project includes CI workflows for infrastructure code validation.

| Workflow | Purpose |
|---|---|
| `ansible-validation.yml` | Validates Ansible code |
| `terraform-validation.yml` | Validates Terraform format and syntax |
| `terraform-security-validation.yml` | Runs TFLint and Checkov |
| `cloudformation-validation.yml` | Runs cfn-lint for CloudFormation templates |

The workflows do not automatically deploy or destroy cloud resources.

They are validation-only.

---

## 20. Security Comparison

| Security Area | Ansible | Terraform | CloudFormation |
|---|---|---|---|
| Secret handling | Ansible Vault | Sensitive files excluded from Git | No secrets used |
| Static validation | ansible-lint | TFLint, Checkov | cfn-lint |
| Access control examples | SSH user and sudo validation | NSG and remote state protection | IAM policy and S3 bucket policy |
| Data protection | Backup/restore validation | Remote state protection | S3 retention and encryption template |
| Git safety | Vault files ignored | tfvars/state/backend ignored | AWS credentials ignored |

Security is handled differently by each tool.

Ansible focuses on system access and secret handling.

Terraform focuses on cloud resource configuration and state protection.

CloudFormation demonstrates AWS security baseline patterns in template form.

---

## 21. Cost Safety Comparison

| Tool | Cost Risk | Project Strategy |
|---|---|---|
| Ansible | Low, local Hyper-V lab | Uses local VMs |
| Terraform | Medium, real Azure resources | Low-cost resources and destroy after validation |
| CloudFormation | Potentially high if deployed | Static validation only, no AWS deployment |

CloudFormation is intentionally not deployed.

Terraform is deployed only with strict Azure cost safety rules.

Ansible runs locally and does not generate cloud costs.

---

## 22. Operational Comparison

| Operation | Ansible | Terraform | CloudFormation |
|---|---|---|---|
| Install packages | Strong | Not intended | Not intended |
| Configure services | Strong | Not intended | Not intended |
| Create cloud resources | Possible but not ideal | Strong | Strong for AWS |
| Manage state | Minimal local state | Strong state model | AWS stack state |
| Validate before deployment | Good | Strong | Good |
| Multi-cloud support | Yes, but not primary use | Strong | AWS only |
| AWS-native integration | Limited | Provider-based | Native |
| Azure support | Modules/collections possible | Strong | No |

---

## 23. Strengths of Ansible

Ansible strengths demonstrated in this project:

```text
simple SSH-based automation
good for Linux configuration
good for service deployment
good for operational tasks
good for validation tasks
role-based structure
idempotent modules
Vault secret management
easy to read YAML syntax
```

Ansible is especially useful when machines already exist and need to be configured.

Project example:

```text
Deploy Prometheus and Grafana on monitor-01.
```

---

## 24. Strengths of Terraform

Terraform strengths demonstrated in this project:

```text
strong infrastructure lifecycle management
clear plan/apply/destroy workflow
provider ecosystem
state tracking
module structure
environment separation
remote backend support
good cloud resource modeling
security scanning support
```

Terraform is especially useful for cloud infrastructure provisioning.

Project example:

```text
Create Azure Resource Group, VNet, Subnet and NSG using reusable modules.
```

---

## 25. Strengths of CloudFormation

CloudFormation strengths demonstrated in this project:

```text
AWS-native infrastructure definition
direct support for AWS resources
stack-based model
parameters
mappings
conditions
rules
metadata
outputs
AWS pseudo parameters
AWS-native policy documents
```

CloudFormation is especially useful for AWS-specific environments where native AWS stack management is preferred.

Project example:

```text
Define an S3 security baseline template with encryption, public access block and bucket policy.
```

---

## 26. Limitations of Ansible

Ansible limitations:

```text
not ideal as the primary tool for cloud infrastructure lifecycle
does not naturally maintain infrastructure state like Terraform
large playbooks can become hard to manage without roles
order of tasks matters
requires reachable target machines
```

In this project, Ansible is therefore used mainly for configuration management and operational automation.

---

## 27. Limitations of Terraform

Terraform limitations:

```text
not intended for detailed operating system configuration
state must be protected carefully
remote backend setup requires bootstrap process
mistakes can affect real cloud resources
provider behavior must be understood
```

In this project, Terraform is therefore used carefully with cost-safe Azure resources and validation workflows.

---

## 28. Limitations of CloudFormation

CloudFormation limitations:

```text
AWS-only
YAML templates can become verbose
less portable across cloud providers
complex templates can be difficult to maintain
stack deployment can create real costs if not controlled
```

In this project, CloudFormation is therefore used only for static validation and AWS-native IaC practice.

---

## 29. How the Tools Work Together

A realistic infrastructure workflow could look like this:

```text
Terraform creates cloud infrastructure.
Ansible configures servers after they exist.
CloudFormation defines AWS-native templates when working specifically with AWS.
GitHub Actions validates code before changes are merged.
Documentation explains how everything works.
```

In this project:

```text
Ansible = local operational automation
Terraform = Azure cloud IaC
CloudFormation = AWS IaC template validation
GitHub Actions = validation layer
Docs = knowledge and reproducibility layer
```

---

## 30. Practical Example Workflow

A practical infrastructure workflow can be described as:

```text
1. Create infrastructure with Terraform.
2. Configure servers with Ansible.
3. Monitor systems with Prometheus and Grafana.
4. Validate backup and restore processes.
5. Validate IaC with CI.
6. Document architecture and operations.
```

The project demonstrates this workflow through local and cloud-safe stages.

---

## 31. Terraform vs CloudFormation

Terraform and CloudFormation are both Infrastructure as Code tools, but they differ.

| Area | Terraform | CloudFormation |
|---|---|---|
| Cloud support | Multi-cloud | AWS only |
| Language | HCL | YAML or JSON |
| State | Terraform state file | AWS stack state |
| Modules | Terraform modules | Nested stacks/modules concept |
| Provider model | Provider plugins | Native AWS resource types |
| Azure support | Yes | No |
| AWS support | Yes | Native |
| Used in this project for | Azure IaC | AWS template validation |

Terraform is better for multi-cloud or provider-based workflows.

CloudFormation is AWS-native and tightly integrated with AWS.

---

## 32. Ansible vs Terraform

Ansible and Terraform solve different problems.

| Area | Ansible | Terraform |
|---|---|---|
| Main role | Configuration management | Infrastructure provisioning |
| State model | Usually stateless | Stateful |
| Target | Existing systems | Infrastructure resources |
| Language | YAML | HCL |
| Best for | Services, OS config, tasks | Cloud resources |
| Example in project | Configure Grafana | Create Azure VNet |

They can work together well.

Terraform can create infrastructure.

Ansible can configure that infrastructure.

---

## 33. Ansible vs CloudFormation

Ansible and CloudFormation also solve different problems.

| Area | Ansible | CloudFormation |
|---|---|---|
| Main role | Configure systems | Define AWS stacks |
| Target | Servers and services | AWS resources |
| State | Usually stateless | AWS stack state |
| Cloud scope | Multi-purpose | AWS-native |
| Example in project | Install PostgreSQL | Define S3 bucket template |

Ansible is better for OS and application configuration.

CloudFormation is better for AWS resource templates.

---

## 34. Why All Three Are Included

All three tools are included because they demonstrate different parts of infrastructure automation.

```text
Ansible shows practical Linux automation.
Terraform shows cloud Infrastructure as Code and state management.
CloudFormation shows AWS-native template knowledge.
```

Together they show a broader infrastructure skill set than any single tool alone.

---

## 35. Project Design Decision

The project intentionally avoids using one tool for everything.

For example:

```text
Ansible is not used to create Azure networking.
Terraform is not used to configure Grafana dashboards.
CloudFormation is not used to deploy AWS resources.
```

This makes the architecture cleaner.

Each tool is used where it makes the most sense.

---

## 36. Final Comparison Table

| Feature | Ansible | Terraform | CloudFormation |
|---|---|---|---|
| Main category | Configuration management | Infrastructure as Code | AWS-native Infrastructure as Code |
| Primary target | Servers | Cloud resources | AWS resources |
| Used with | Hyper-V Ubuntu nodes | Azure | AWS templates |
| Deployment performed | Yes, local lab | Yes, Azure validation | No |
| Static validation | Yes | Yes | Yes |
| CI workflow | Yes | Yes | Yes |
| State file | No normal state file | Yes | AWS-managed stack state |
| Secrets handling | Ansible Vault | Git ignored tfvars/backend/state | No secrets used |
| Best project example | Grafana deployment | Azure network module | S3 security baseline template |
| Cost risk | Low | Controlled | Avoided |
| Final role | Operations automation | Cloud provisioning | AWS IaC template practice |

---

## 37. Final Conclusion

The Enterprise Automation Lab uses Ansible, Terraform and CloudFormation in a structured way.

Ansible demonstrates practical Linux configuration management and operational automation.

Terraform demonstrates cloud infrastructure provisioning, reusable modules, environment separation, remote state and security validation.

CloudFormation demonstrates AWS-native Infrastructure as Code syntax, basic templates, advanced template features and static validation.

Together, these tools show a complete infrastructure automation mindset:

```text
build infrastructure
configure systems
validate services
protect state and secrets
check code automatically
document architecture
avoid unnecessary cloud costs
```

This comparison shows that the project is not only a collection of commands.

It is a structured infrastructure automation lab with clear tool boundaries and practical validation evidence.
