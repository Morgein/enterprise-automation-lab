# Stage 5.1 - Terraform Azure Modules

## 1. Purpose

This document describes Stage 5.1 of the Enterprise Automation Lab.

The goal of this stage is to move from a flat Terraform configuration to a reusable Terraform module structure.

Previous Terraform stage:

```text
terraform/azure/basics/
```

New module-based structure:

```text
terraform/azure/modules/network-foundation/
terraform/azure/environments/dev/
```

This stage introduces the following Terraform concepts:

```text
Terraform modules
root modules
child modules
module inputs
module outputs
environment-specific configuration
module-based Azure resource creation
```

---

## 2. Why This Stage Exists

In Stage 4.1, Azure resources were created directly from one Terraform directory.

That structure is good for learning Terraform basics.

However, real infrastructure projects usually separate reusable infrastructure logic from environment-specific values.

In simple terms:

```text
module = reusable infrastructure logic
environment = concrete values for a specific deployment
```

For this stage:

```text
network-foundation module
    -> defines how to create Azure networking resources

dev environment
    -> calls the module with dev values
```

This makes the Terraform code cleaner, more reusable and easier to extend.

---

## 3. Final Structure

The Stage 5.1 Terraform structure is:

```text
terraform/azure/
├── environments/
│   └── dev/
│       ├── README.md
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars.example
│       ├── variables.tf
│       └── versions.tf
│
└── modules/
    └── network-foundation/
        ├── README.md
        ├── locals.tf
        ├── main.tf
        ├── outputs.tf
        ├── variables.tf
        └── versions.tf
```

Local files that must not be committed:

```text
terraform/azure/environments/dev/.terraform/
terraform/azure/environments/dev/terraform.tfvars
terraform/azure/environments/dev/terraform.tfstate
terraform/azure/environments/dev/terraform.tfstate.backup
```

---

## 4. Module Created

Module path:

```text
terraform/azure/modules/network-foundation/
```

The module creates:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to Network Security Group association
```

The module does not create:

```text
Virtual Machines
Managed Disks
Public IP addresses
NAT Gateway
Azure Firewall
Azure Bastion
Load Balancer
Managed Databases
AKS
Application Gateway
```

This keeps the stage cost-safe.

---

## 5. Dev Environment Created

Environment path:

```text
terraform/azure/environments/dev/
```

The dev environment is the root Terraform configuration.

It calls the network foundation module.

The dev environment provides:

```text
Azure provider configuration
subscription ID variable
environment name
Azure region
VNet CIDR range
Subnet CIDR range
additional tags
module output exposure
```

---

## 6. Root Module and Child Module

Terraform has two important module concepts.

### Root module

The root module is the directory where Terraform is executed.

For this stage, the root module is:

```text
terraform/azure/environments/dev/
```

Commands are executed from this directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

### Child module

A child module is called by the root module.

For this stage, the child module is:

```text
terraform/azure/modules/network-foundation/
```

The root module calls it using:

```hcl
module "network_foundation" {
  source = "../../modules/network-foundation"
}
```

---

## 7. Important Provider Lesson

During this stage, Terraform initially failed with:

```text
Invalid provider configuration
The argument "features" is required, but no definition was found.
```

Cause:

```text
Terraform was executed from the dev environment.
The dev environment is the root module.
The AzureRM provider must be configured in the root module.
```

Fix:

```hcl
provider "azurerm" {
  features {}

  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}
```

This provider block was added to:

```text
terraform/azure/environments/dev/providers.tf
```

Important lesson:

```text
Provider configuration belongs in the root module.
Child modules declare provider requirements, but the root module configures the provider.
```

---

## 8. Network Foundation Module Files

### versions.tf

File:

```text
terraform/azure/modules/network-foundation/versions.tf
```

Purpose:

```text
Defines Terraform and AzureRM provider version requirements for the module.
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

This makes the module self-documenting.

---

### variables.tf

File:

```text
terraform/azure/modules/network-foundation/variables.tf
```

Purpose:

```text
Defines input values required by the module.
```

Variables:

```text
project_name
environment
location
address_space
subnet_address_prefixes
allowed_ssh_source
tags
```

The module does not hardcode environment-specific values.

Instead, it receives them from the calling environment.

---

### locals.tf

File:

```text
terraform/azure/modules/network-foundation/locals.tf
```

Purpose:

```text
Computes resource names and common tags.
```

Important local values:

```text
name_prefix
default_tags
common_tags
resource_group_name
vnet_name
subnet_name
nsg_name
```

Example:

```hcl
name_prefix = "ea-lab-${var.environment}"
```

If:

```text
environment = dev
```

then:

```text
name_prefix = ea-lab-dev
```

Computed resource names:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
snet-ea-lab-dev-main
nsg-ea-lab-dev-main
```

---

### main.tf

File:

```text
terraform/azure/modules/network-foundation/main.tf
```

Purpose:

```text
Defines the Azure resources created by the module.
```

Resources:

```text
azurerm_resource_group.main
azurerm_virtual_network.main
azurerm_subnet.main
azurerm_network_security_group.main
azurerm_subnet_network_security_group_association.main
```

---

### outputs.tf

File:

```text
terraform/azure/modules/network-foundation/outputs.tf
```

Purpose:

```text
Returns useful values from the module.
```

Important outputs:

```text
resource_group_name
resource_group_id
location
virtual_network_name
virtual_network_id
subnet_name
subnet_id
network_security_group_name
network_security_group_id
```

These outputs allow the root environment or future modules to reuse created resource IDs.

Example future use:

```hcl
subnet_id = module.network_foundation.subnet_id
```

---

## 9. Dev Environment Files

### versions.tf

File:

```text
terraform/azure/environments/dev/versions.tf
```

Purpose:

```text
Defines Terraform and AzureRM provider version requirements for the dev environment.
```

---

### providers.tf

File:

```text
terraform/azure/environments/dev/providers.tf
```

Purpose:

```text
Configures AzureRM provider for the root module.
```

Main content:

```hcl
provider "azurerm" {
  features {}

  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}
```

Important details:

```text
features {} is required by the AzureRM provider
subscription_id is passed through a sensitive variable
automatic provider registration is disabled
```

---

### variables.tf

File:

```text
terraform/azure/environments/dev/variables.tf
```

Purpose:

```text
Defines input variables for the dev environment.
```

Variables:

```text
subscription_id
project_name
environment
location
address_space
subnet_address_prefixes
allowed_ssh_source
```

The `environment` variable is restricted to:

```text
dev
```

This prevents accidental use of the dev directory for another environment.

---

### main.tf

File:

```text
terraform/azure/environments/dev/main.tf
```

Purpose:

```text
Calls the reusable network-foundation module.
```

Main content:

```hcl
module "network_foundation" {
  source = "../../modules/network-foundation"

  project_name            = var.project_name
  environment             = var.environment
  location                = var.location
  address_space           = var.address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  allowed_ssh_source      = var.allowed_ssh_source

  tags = {
    stage       = "terraform-azure-modules"
    environment = "dev"
  }
}
```

This block connects the dev environment to the reusable module.

---

### outputs.tf

File:

```text
terraform/azure/environments/dev/outputs.tf
```

Purpose:

```text
Exposes selected module outputs at the environment level.
```

Example:

```hcl
output "subnet_id" {
  description = "ID of the Azure subnet. This can be used by future compute modules."
  value       = module.network_foundation.subnet_id
}
```

This is useful because future modules can consume the subnet ID.

---

### terraform.tfvars.example

File:

```text
terraform/azure/environments/dev/terraform.tfvars.example
```

Purpose:

```text
Provides a safe example of required variable values.
```

This file is safe to commit.

It uses a placeholder subscription ID:

```text
00000000-0000-0000-0000-000000000000
```

---

### terraform.tfvars

Local file:

```text
terraform/azure/environments/dev/terraform.tfvars
```

Purpose:

```text
Stores real local values, including the real Azure subscription ID.
```

This file must not be committed.

---

## 10. Module Call Flow

The resource creation flow is:

```text
terraform/azure/environments/dev/
    |
    | calls
    v
terraform/azure/modules/network-foundation/
    |
    | creates
    v
Azure Resource Group
Azure Virtual Network
Azure Subnet
Azure Network Security Group
NSG association
```

Terraform state shows module-based addresses:

```text
module.network_foundation.azurerm_resource_group.main
module.network_foundation.azurerm_virtual_network.main
module.network_foundation.azurerm_subnet.main
module.network_foundation.azurerm_network_security_group.main
module.network_foundation.azurerm_subnet_network_security_group_association.main
```

This confirms that resources are created through the module.

---

## 11. Dev Values Used

Current dev values:

```text
project_name = enterprise-automation-lab
environment = dev
location = swedencentral
address_space = 10.40.0.0/16
subnet_address_prefixes = 10.40.1.0/24
allowed_ssh_source = 10.0.0.0/8
```

Created resource names:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
snet-ea-lab-dev-main
nsg-ea-lab-dev-main
```

---

## 12. Tags

The module applies default tags:

```text
project
environment
managed_by
module
```

The dev environment adds:

```text
stage
environment
```

Expected tags:

```text
project      = enterprise-automation-lab
environment  = dev
managed_by   = terraform
module       = network-foundation
stage        = terraform-azure-modules
```

These tags prove that resources were created using module logic and environment-specific metadata.

---

## 13. Commands Used

All Terraform commands were executed from:

```text
terraform/azure/environments/dev/
```

Initialize:

```bash
terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Show outputs:

```bash
terraform output
```

Show state:

```bash
terraform state list
```

Destroy:

```bash
terraform destroy
```

---

## 14. Plan Result

Terraform plan showed:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Planned resources:

```text
module.network_foundation.azurerm_resource_group.main
module.network_foundation.azurerm_virtual_network.main
module.network_foundation.azurerm_subnet.main
module.network_foundation.azurerm_network_security_group.main
module.network_foundation.azurerm_subnet_network_security_group_association.main
```

This confirmed that Terraform would create only the expected safe Azure networking resources.

---

## 15. Apply Result

Terraform apply created:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to Network Security Group association
```

Expected apply result:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

---

## 16. Output and State Validation

After apply, outputs were checked with:

```bash
terraform output
```

State was checked with:

```bash
terraform state list
```

Expected state resources:

```text
module.network_foundation.azurerm_network_security_group.main
module.network_foundation.azurerm_resource_group.main
module.network_foundation.azurerm_subnet.main
module.network_foundation.azurerm_subnet_network_security_group_association.main
module.network_foundation.azurerm_virtual_network.main
```

This confirms that Terraform tracks the resources through the module path.

---

## 17. Azure Portal Validation

Azure Portal was used to validate real Azure resources.

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

VNet validation path:

```text
rg-ea-lab-dev
-> vnet-ea-lab-dev
-> Subnets
-> snet-ea-lab-dev-main
```

Expected subnet details:

```text
Address prefix: 10.40.1.0/24
Network Security Group: nsg-ea-lab-dev-main
```

Tag validation path:

```text
rg-ea-lab-dev
-> Tags
```

or:

```text
vnet-ea-lab-dev
-> Tags
```

Expected tags:

```text
project = enterprise-automation-lab
environment = dev
managed_by = terraform
module = network-foundation
stage = terraform-azure-modules
```

---

## 18. Destroy and Cost Safety

After validation, resources were destroyed with:

```bash
terraform destroy
```

Expected destroy result:

```text
Destroy complete! Resources: 5 destroyed.
```

A destroy screenshot was not stored for this stage.

The operational requirement is still important:

```text
Azure resources must be destroyed after validation to protect student credits.
```

---

## 19. Validation Evidence

Validation screenshots are stored in:

```text
docs/screenshots/stage-05-terraform-azure-modules/
```

Evidence files:

```text
01-terraform-module-plan.png
02-terraform-module-apply-output-state.png
03-azure-portal-module-resource-group.png
04-azure-portal-module-tags.png
05-azure-portal-module-vnet-subnet-nsg.png
```

### 01-terraform-module-plan.png

Shows:

```text
module.network_foundation resource paths
Plan: 5 to add, 0 to change, 0 to destroy
```

### 02-terraform-module-apply-output-state.png

Shows:

```text
successful apply
terraform output
terraform state list
module-based state addresses
```

### 03-azure-portal-module-resource-group.png

Shows:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
nsg-ea-lab-dev-main
```

### 04-azure-portal-module-tags.png

Shows:

```text
project tag
environment tag
managed_by tag
module tag
stage tag
```

### 05-azure-portal-module-vnet-subnet-nsg.png

Shows:

```text
vnet-ea-lab-dev
snet-ea-lab-dev-main
10.40.1.0/24
nsg-ea-lab-dev-main association
```

---

## 20. Git Safety

The following files must not be committed:

```text
terraform/azure/environments/dev/.terraform/
terraform/azure/environments/dev/terraform.tfvars
terraform/azure/environments/dev/terraform.tfstate
terraform/azure/environments/dev/terraform.tfstate.backup
```

Safe files to commit:

```text
terraform/azure/modules/network-foundation/*.tf
terraform/azure/modules/network-foundation/README.md
terraform/azure/environments/dev/*.tf
terraform/azure/environments/dev/terraform.tfvars.example
terraform/azure/environments/dev/README.md
docs/runbooks/stage-05-01-terraform-azure-modules.md
docs/screenshots/stage-05-terraform-azure-modules/
```

Provider lock files can be committed if created:

```text
.terraform.lock.hcl
```

They help keep provider versions reproducible.

---

## 21. Stage Result

At the end of this stage:

```text
network-foundation module created
dev environment created
dev environment calls the network-foundation module
AzureRM provider configured in the root module
Terraform module variables added
Terraform module locals added
Terraform module outputs added
environment outputs added
safe terraform.tfvars.example created
real terraform.tfvars kept local
module-based terraform plan validated
module-based terraform apply completed
module outputs validated
module state addresses validated
Azure Portal validation completed
Azure tags validated
VNet, subnet and NSG association validated
resources destroyed after validation
runtime screenshots collected
```

---

## 22. Current Project Status

Current completed stage:

```text
Stage 5.1 - Terraform Azure Modules
```

The project now demonstrates:

```text
Ansible automation for local Hyper-V infrastructure
Terraform Azure basics in flat configuration
Terraform Azure validation through GitHub Actions
Terraform reusable module structure
Terraform dev environment structure
module-based Azure networking deployment
cost-safe Azure validation workflow
```

---

## 23. Next Stage

Next planned stage:

```text
Stage 5.2 - Terraform Environment Separation
```

Planned goal:

```text
expand the module-based structure from dev-only into multiple environments
```

Possible future structure:

```text
terraform/azure/environments/dev/
terraform/azure/environments/test/
```

The goal will be to demonstrate how the same module can be reused with different environment values.
