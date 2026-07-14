# Stage 4.1 - Terraform Azure Basics

## 1. Purpose

This document describes Stage 4.1 of the Enterprise Automation Lab.

The goal of this stage is to introduce Terraform with Azure by creating a small, safe and cost-controlled Azure networking foundation.

This stage creates:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to Network Security Group association
```

No virtual machine is created in this stage.

The main goal is to understand the Terraform workflow:

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

---

## 2. Why This Stage Exists

The Ansible phase of the project is already complete.

Ansible is used for:

```text
server configuration
package installation
service management
monitoring deployment
backup and restore validation
```

Terraform is introduced for Infrastructure as Code.

Terraform is used for:

```text
cloud resource modeling
resource creation
resource dependency management
state management
plan/apply/destroy workflow
infrastructure lifecycle control
```

In simple words:

```text
Ansible configures servers.
Terraform creates infrastructure.
```

This stage demonstrates the first safe Terraform Azure deployment.

---

## 3. Cost Safety Principle

This project uses Azure student credits.

Because of that, every Azure Terraform lab must follow this rule:

```text
Create resources -> validate resources -> take screenshots -> destroy resources
```

This means:

```text
1. Terraform creates Azure resources.
2. The resources are validated.
3. Screenshots are collected.
4. Terraform destroys the resources after validation.
```

Resources must not be left running longer than needed.

---

## 4. Why No VM in This Stage

Virtual machines can consume Azure credits if they are left running.

This stage intentionally avoids VMs.

The first Terraform Azure stage focuses on safe networking resources:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet association
```

These resources are enough to learn Terraform basics without introducing unnecessary cost risk.

VM deployment will be introduced later only after the Terraform workflow is clear.

---

## 5. Files Created or Updated

| File | Purpose |
|---|---|
| `terraform/azure/basics/versions.tf` | Defines Terraform and provider version requirements |
| `terraform/azure/basics/providers.tf` | Configures the AzureRM provider |
| `terraform/azure/basics/variables.tf` | Defines input variables |
| `terraform/azure/basics/locals.tf` | Defines computed names and common tags |
| `terraform/azure/basics/main.tf` | Defines Azure resources |
| `terraform/azure/basics/outputs.tf` | Defines useful output values |
| `terraform/azure/basics/terraform.tfvars.example` | Safe example variable file |
| `terraform/azure/basics/README.md` | Local README for Terraform Azure basics |
| `terraform/docs/azure-cost-safety.md` | Azure cost safety guide |
| `README.md` | Main project README updated with Terraform section |
| `docs/screenshots/stage-04-azure-terraform-basics/` | Runtime validation screenshots |

---

## 6. Directory Structure

Terraform Azure basics directory:

```text
terraform/azure/basics/
```

Expected structure:

```text
terraform/azure/basics/
├── .terraform.lock.hcl
├── README.md
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

Local files that must not be committed:

```text
terraform.tfvars
terraform.tfstate
terraform.tfstate.backup
.terraform/
```

---

## 7. Terraform Provider

File:

```text
terraform/azure/basics/versions.tf
```

Main content:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

Explanation:

```text
required_version
```

Defines the minimum Terraform CLI version required by the project.

```text
required_providers
```

Defines the external providers Terraform needs.

```text
azurerm
```

Is the Terraform provider for Azure Resource Manager.

```text
source = "hashicorp/azurerm"
```

Tells Terraform where to download the provider from.

```text
version = "~> 4.0"
```

Allows AzureRM provider version 4.x but avoids automatically jumping to a future major version.

---

## 8. Provider Configuration

File:

```text
terraform/azure/basics/providers.tf
```

Main content:

```hcl
provider "azurerm" {
  features {}

  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}
```

Explanation:

```text
provider "azurerm"
```

Configures the Azure provider.

```text
features {}
```

Required block for the AzureRM provider.

```text
subscription_id = var.subscription_id
```

Makes Terraform use the selected Azure subscription.

```text
resource_provider_registrations = "none"
```

Prevents Terraform from automatically registering many Azure resource providers.

This is useful for the lab because only required providers should be registered manually.

For this stage, the required Azure resource provider is:

```text
Microsoft.Network
```

---

## 9. Azure Resource Provider Registration

During this stage, Terraform initially failed because the subscription was not registered for:

```text
Microsoft.Network
```

The fix was to register `Microsoft.Network` manually in Azure Portal.

Portal path:

```text
Azure Portal
-> Subscriptions
-> Azure for Students
-> Settings
-> Resource providers
-> Microsoft.Network
-> Register
```

After the provider was registered, Terraform could create:

```text
Virtual Network
Subnet
Network Security Group
```

This is an important real-world Azure lesson.

Azure subscriptions may require resource provider registration before specific resource types can be deployed.

---

## 10. Variables

File:

```text
terraform/azure/basics/variables.tf
```

Main variables:

```text
subscription_id
project_name
environment
location
address_space
subnet_address_prefixes
allowed_ssh_source
```

### subscription_id

```hcl
variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}
```

Purpose:

```text
Defines which Azure subscription Terraform should use.
```

It is marked as sensitive to avoid unnecessary exposure in Terraform output.

The real value is stored locally in:

```text
terraform.tfvars
```

This file is not committed to Git.

---

### project_name

```hcl
variable "project_name" {
  description = "Project name used for Azure resource naming."
  type        = string
  default     = "enterprise-automation-lab"
}
```

Purpose:

```text
Defines the project name used in naming and tagging.
```

---

### environment

```hcl
variable "environment" {
  description = "Environment name for this Terraform deployment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}
```

Purpose:

```text
Defines the environment name.
```

Allowed values:

```text
dev
test
prod
```

This prevents invalid environment names.

---

### location

```hcl
variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "westeurope"
}
```

Purpose:

```text
Defines the Azure region.
```

Important stage note:

```text
westeurope was blocked by Azure Policy in the student subscription.
swedencentral was used successfully.
```

Final working value:

```text
swedencentral
```

---

### address_space

```hcl
variable "address_space" {
  description = "Address space for the Azure virtual network."
  type        = list(string)
  default     = ["10.40.0.0/16"]
}
```

Purpose:

```text
Defines the IP range for the Azure Virtual Network.
```

---

### subnet_address_prefixes

```hcl
variable "subnet_address_prefixes" {
  description = "Address prefixes for the main Azure subnet."
  type        = list(string)
  default     = ["10.40.1.0/24"]
}
```

Purpose:

```text
Defines the IP range for the subnet inside the VNet.
```

---

### allowed_ssh_source

```hcl
variable "allowed_ssh_source" {
  description = "Source CIDR allowed for SSH in the Network Security Group. This is only a rule example in basics stage."
  type        = string
  default     = "10.0.0.0/8"
}
```

Purpose:

```text
Defines an example source CIDR for SSH traffic.
```

No VM is created in this stage, so this is only a basic NSG rule example.

---

## 11. Locals

File:

```text
terraform/azure/basics/locals.tf
```

Main content:

```hcl
locals {
  name_prefix = "ea-lab-${var.environment}"

  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    lab         = "enterprise-automation-lab"
  }

  resource_group_name = "rg-${local.name_prefix}"
  vnet_name           = "vnet-${local.name_prefix}"
  subnet_name         = "snet-${local.name_prefix}-main"
  nsg_name            = "nsg-${local.name_prefix}-main"
}
```

Explanation:

```text
locals
```

Are computed values inside Terraform.

They avoid repeating naming logic in multiple resources.

### name_prefix

```text
ea-lab-dev
```

Used as the common prefix for resource names.

### common_tags

Tags applied to Azure resources.

Tags help identify:

```text
project
environment
tool that manages the resource
lab ownership
```

### resource names

Computed resource names:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
snet-ea-lab-dev-main
nsg-ea-lab-dev-main
```

---

## 12. Azure Resources

File:

```text
terraform/azure/basics/main.tf
```

Resources created:

```text
azurerm_resource_group.main
azurerm_virtual_network.main
azurerm_subnet.main
azurerm_network_security_group.main
azurerm_subnet_network_security_group_association.main
```

---

## 13. Resource Group

Terraform resource:

```text
azurerm_resource_group.main
```

Purpose:

```text
Creates a dedicated Azure Resource Group for this lab stage.
```

Final name:

```text
rg-ea-lab-dev
```

Why it matters:

```text
Resource Group keeps lab resources isolated.
Resource Group makes cleanup easier.
Resource Group helps avoid mixing lab resources with other Azure resources.
```

---

## 14. Virtual Network

Terraform resource:

```text
azurerm_virtual_network.main
```

Purpose:

```text
Creates an Azure Virtual Network.
```

Final name:

```text
vnet-ea-lab-dev
```

Address space:

```text
10.40.0.0/16
```

Simple explanation:

```text
A Virtual Network is the main private network boundary in Azure.
```

It is similar in concept to having a private network segment for cloud resources.

---

## 15. Subnet

Terraform resource:

```text
azurerm_subnet.main
```

Purpose:

```text
Creates a subnet inside the Azure Virtual Network.
```

Final name:

```text
snet-ea-lab-dev-main
```

Address prefix:

```text
10.40.1.0/24
```

Simple explanation:

```text
A subnet is a smaller network range inside the VNet.
```

---

## 16. Network Security Group

Terraform resource:

```text
azurerm_network_security_group.main
```

Purpose:

```text
Creates a Network Security Group.
```

Final name:

```text
nsg-ea-lab-dev-main
```

Simple explanation:

```text
A Network Security Group is similar to a firewall rule set for Azure network traffic.
```

The NSG contains one example rule:

```text
Allow-SSH-Example
```

Rule details:

```text
direction: Inbound
protocol: TCP
destination port: 22
source: 10.0.0.0/8
access: Allow
priority: 100
```

No VM is deployed in this stage, so this rule is only a learning example.

---

## 17. Subnet to NSG Association

Terraform resource:

```text
azurerm_subnet_network_security_group_association.main
```

Purpose:

```text
Associates the Network Security Group with the subnet.
```

Why it matters:

```text
Creating an NSG alone does not protect a subnet.
The NSG must be associated with a subnet or network interface.
```

This stage associates:

```text
snet-ea-lab-dev-main
```

with:

```text
nsg-ea-lab-dev-main
```

---

## 18. Outputs

File:

```text
terraform/azure/basics/outputs.tf
```

Outputs defined:

```text
resource_group_name
location
virtual_network_name
subnet_name
network_security_group_name
resource_group_id
```

Purpose:

```text
Outputs show important values after terraform apply.
```

Example output values:

```text
location = "swedencentral"
resource_group_name = "rg-ea-lab-dev"
virtual_network_name = "vnet-ea-lab-dev"
subnet_name = "snet-ea-lab-dev-main"
network_security_group_name = "nsg-ea-lab-dev-main"
```

Sensitive account metadata in screenshots should be hidden.

---

## 19. Terraform State

Terraform state tracks the relationship between Terraform code and real Azure resources.

Command used:

```bash
terraform state list
```

Expected resources:

```text
azurerm_network_security_group.main
azurerm_resource_group.main
azurerm_subnet.main
azurerm_subnet_network_security_group_association.main
azurerm_virtual_network.main
```

State files must not be committed:

```text
terraform.tfstate
terraform.tfstate.backup
```

---

## 20. Terraform Lock File

Terraform created:

```text
.terraform.lock.hcl
```

This file records selected provider versions.

It should be committed.

Reason:

```text
It makes provider versions reproducible.
It helps future runs use the same provider version selection.
```

The local provider plugin directory is not committed:

```text
.terraform/
```

---

## 21. Terraform Workflow

### Initialize

```bash
terraform init
```

Purpose:

```text
Downloads required providers.
Initializes the working directory.
Creates or updates .terraform.lock.hcl.
```

---

### Format

```bash
terraform fmt
```

Purpose:

```text
Formats Terraform files consistently.
```

---

### Validate

```bash
terraform validate
```

Purpose:

```text
Checks whether Terraform configuration is syntactically valid.
```

Expected result:

```text
Success! The configuration is valid.
```

---

### Plan

```bash
terraform plan
```

Purpose:

```text
Shows what Terraform will create, change or destroy.
```

Expected result:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

---

### Apply

```bash
terraform apply
```

Purpose:

```text
Creates the planned Azure resources.
```

Expected result:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

---

### Output

```bash
terraform output
```

Purpose:

```text
Shows useful output values from Terraform.
```

---

### State List

```bash
terraform state list
```

Purpose:

```text
Shows resources tracked by Terraform state.
```

---

### Destroy

```bash
terraform destroy
```

Purpose:

```text
Deletes resources managed by this Terraform configuration.
```

Expected result:

```text
Destroy complete! Resources: 5 destroyed.
```

---

## 22. Problems Encountered and Fixes

### Problem 1 - AzureRM Provider Registration Conflict

Initial error:

```text
409 Conflict
ConflictingConcurrentWriteNotAllowed
```

Cause:

```text
AzureRM provider attempted to automatically register multiple Azure resource providers.
Azure returned a conflict because multiple registration operations were happening.
```

Fix:

```hcl
resource_provider_registrations = "none"
```

This disabled automatic provider registration.

---

### Problem 2 - Region Blocked by Azure Policy

Initial region:

```text
westeurope
```

Error:

```text
RequestDisallowedByAzure
```

Cause:

```text
Azure student subscription policy did not allow deployment in westeurope.
```

Fix:

```text
Changed location to swedencentral.
```

---

### Problem 3 - Microsoft.Network Not Registered

Error:

```text
MissingSubscriptionRegistration
The subscription is not registered to use namespace Microsoft.Network.
```

Cause:

```text
The subscription was not registered for Microsoft.Network.
```

Fix:

```text
Registered Microsoft.Network manually in Azure Portal.
```

---

### Problem 4 - Azure CLI Resource Commands Failed on Kali

Some Azure CLI commands failed on Kali Linux with a Python module error.

Decision:

```text
Terraform and Azure Portal were used for validation instead of Azure CLI resource commands.
```

Reason:

```text
Terraform successfully authenticated and deployed resources.
Azure Portal provided reliable visual validation.
Azure CLI repair was not required to complete this Terraform stage.
```

---

## 23. Azure Portal Validation

Azure Portal was used to validate created resources.

Validation path:

```text
Azure Portal
-> Resource groups
-> rg-ea-lab-dev
```

Expected resources:

```text
vnet-ea-lab-dev
nsg-ea-lab-dev-main
```

Subnet validation:

```text
vnet-ea-lab-dev
-> Subnets
-> snet-ea-lab-dev-main
```

NSG association validation:

```text
Subnet
-> Network security group
-> nsg-ea-lab-dev-main
```

This confirms:

```text
Resource Group exists
VNet exists
Subnet exists
NSG exists
Subnet is associated with NSG
```

---

## 24. Cleanup Validation

After screenshots were collected, resources were destroyed with:

```bash
terraform destroy
```

Expected result:

```text
Destroy complete! Resources: 5 destroyed.
```

Azure Portal was used to confirm that:

```text
rg-ea-lab-dev no longer exists
```

This confirms cost safety.

---

## 25. Git Safety

Before committing, Git status was checked.

Command:

```bash
git status --ignored
```

Ignored local Terraform files:

```text
terraform/azure/basics/.terraform/
terraform/azure/basics/terraform.tfstate
terraform/azure/basics/terraform.tfstate.backup
terraform/azure/basics/terraform.tfvars
```

Safe files to commit:

```text
terraform/azure/basics/*.tf
terraform/azure/basics/.terraform.lock.hcl
terraform/azure/basics/terraform.tfvars.example
terraform/azure/basics/README.md
terraform/docs/azure-cost-safety.md
docs/screenshots/stage-04-azure-terraform-basics/
README.md
.gitignore
```

---

## 26. Validation Evidence

Validation screenshots for this stage are stored in:

```text
docs/screenshots/stage-04-azure-terraform-basics/
```

Expected screenshot files:

```text
docs/screenshots/stage-04-azure-terraform-basics/
├── 01-terraform-init-validate-plan.png
├── 02-terraform-apply-output-state.png
├── 03-azure-portal-resource-group.png
├── 04-azure-portal-vnet-subnet-nsg.png
├── 05-terraform-destroy.png
├── 06-azure-portal-cleanup-validation.png
└── 07-git-safety-status.png
```

Only runtime and validation screenshots are stored.

Code screenshots are not required because Terraform code is available in the GitHub repository.

---

## 27. Screenshot Descriptions

### Terraform Init, Validate and Plan

Shows Terraform initialization, validation and safe plan.

Expected evidence:

```text
Terraform initialized
Configuration valid
Plan: 5 to add, 0 to change, 0 to destroy
```

### Terraform Apply, Output and State

Shows successful resource creation and Terraform state.

Expected evidence:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
terraform output
terraform state list
```

### Azure Portal Resource Group

Shows created Azure Resource Group and Azure resources.

Expected evidence:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
nsg-ea-lab-dev-main
```

### Azure Portal VNet, Subnet and NSG

Shows Azure networking structure.

Expected evidence:

```text
vnet-ea-lab-dev
snet-ea-lab-dev-main
nsg-ea-lab-dev-main
```

### Terraform Destroy

Shows successful cleanup.

Expected evidence:

```text
Destroy complete! Resources: 5 destroyed.
```

### Azure Portal Cleanup Validation

Shows that the lab resource group was removed.

Expected evidence:

```text
rg-ea-lab-dev no longer exists
```

### Git Safety Status

Shows that local Terraform state and variable files are ignored and not committed.

Expected evidence:

```text
terraform.tfvars ignored
terraform.tfstate ignored
.terraform/ ignored
safe Terraform code untracked or staged
```

---

## 28. Stage Result

At the end of this stage:

```text
Terraform Azure basics directory created
AzureRM provider configured
subscription_id handled through local tfvars
automatic provider registration disabled
Microsoft.Network registered manually
Azure region adjusted to swedencentral
Resource Group created
Virtual Network created
Subnet created
Network Security Group created
NSG associated with subnet
Terraform outputs validated
Terraform state validated
Azure Portal validation completed
Terraform destroy completed
Azure cleanup validated
Terraform state and tfvars excluded from Git
runtime screenshots collected
```

---

## 29. Current Project Status

Current completed stage:

```text
Stage 4.1 - Terraform Azure Basics
```

The project now demonstrates:

```text
Ansible for local Hyper-V configuration management
Terraform for Azure Infrastructure as Code basics
Azure cost safety workflow
manual Azure Portal validation
safe create -> validate -> destroy practice
```

Next planned Terraform stage:

```text
Stage 4.2 - Terraform Azure Basics Documentation and CI Validation
```

This next stage will add:

```text
Terraform validation commands
GitHub Actions Terraform validation
Terraform README polishing
final Terraform basics documentation
```
