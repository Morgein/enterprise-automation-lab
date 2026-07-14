# Network Foundation Module

## 1. Purpose

This Terraform module creates a basic Azure network foundation for the Enterprise Automation Lab.

The module is responsible for creating the core Azure networking layer:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to Network Security Group association
```

This module does not create virtual machines, public IP addresses, managed disks, databases, load balancers, NAT gateways or any other expensive resources.

The goal of this module is to provide a reusable Azure networking foundation that can be called from different Terraform environments, such as:

```text
dev
test
prod
```

---

## 2. Why This Module Exists

In the Terraform basics stage, the Azure networking resources were created directly in one flat directory.

That approach is good for learning basics, but it is not ideal for larger infrastructure code.

This module improves the Terraform structure by separating reusable infrastructure logic from environment-specific configuration.

In simple terms:

```text
module = how to create the infrastructure
environment = with which values to create it
```

Example:

```text
network-foundation module
    -> creates Resource Group, VNet, Subnet, NSG

dev environment
    -> tells the module to use swedencentral, dev naming and dev CIDR ranges
```

This makes the Terraform code cleaner, more reusable and closer to real infrastructure projects.

---

## 3. Module Location

Module path:

```text
terraform/azure/modules/network-foundation/
```

Expected file structure:

```text
terraform/azure/modules/network-foundation/
├── README.md
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
└── versions.tf
```

---

## 4. Resources Created

This module creates the following Azure resources:

| Terraform Resource | Azure Resource | Purpose |
|---|---|---|
| `azurerm_resource_group.main` | Resource Group | Logical container for Azure resources |
| `azurerm_virtual_network.main` | Virtual Network | Main private network boundary |
| `azurerm_subnet.main` | Subnet | Network segment inside the VNet |
| `azurerm_network_security_group.main` | Network Security Group | Network filtering rules |
| `azurerm_subnet_network_security_group_association.main` | NSG association | Connects the NSG to the subnet |

---

## 5. Resource Group

Terraform resource:

```text
azurerm_resource_group.main
```

Purpose:

```text
Creates a dedicated Azure Resource Group for the environment.
```

Example name:

```text
rg-ea-lab-dev
```

Why it matters:

```text
keeps resources isolated
makes cleanup easier
groups related resources together
helps avoid mixing lab resources with unrelated Azure resources
```

---

## 6. Virtual Network

Terraform resource:

```text
azurerm_virtual_network.main
```

Purpose:

```text
Creates the main Azure Virtual Network.
```

Example name:

```text
vnet-ea-lab-dev
```

Example address space:

```text
10.40.0.0/16
```

Simple explanation:

```text
A Virtual Network is the main private network boundary in Azure.
```

It is similar to creating a private network for cloud resources.

---

## 7. Subnet

Terraform resource:

```text
azurerm_subnet.main
```

Purpose:

```text
Creates a subnet inside the Azure Virtual Network.
```

Example name:

```text
snet-ea-lab-dev-main
```

Example address prefix:

```text
10.40.1.0/24
```

Simple explanation:

```text
A subnet is a smaller network segment inside the VNet.
```

Future resources such as virtual machines can be connected to this subnet.

---

## 8. Network Security Group

Terraform resource:

```text
azurerm_network_security_group.main
```

Purpose:

```text
Creates a Network Security Group for basic traffic filtering.
```

Example name:

```text
nsg-ea-lab-dev-main
```

Simple explanation:

```text
A Network Security Group is similar to a firewall rule set for Azure network traffic.
```

The module currently creates one example inbound SSH rule:

```text
Allow-SSH-Example
```

Rule details:

```text
direction: Inbound
protocol: TCP
destination port: 22
source: configurable CIDR
access: Allow
priority: 100
```

No VM is created by this module, so this rule is currently a learning example and a foundation for future VM stages.

---

## 9. Subnet to NSG Association

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
Creating an NSG alone is not enough.
The NSG must be attached to a subnet or network interface.
```

This module attaches:

```text
nsg-ea-lab-dev-main
```

to:

```text
snet-ea-lab-dev-main
```

This means traffic rules from the NSG apply to resources placed inside the subnet.

---

## 10. Input Variables

This module accepts the following input variables.

| Variable | Type | Required | Purpose |
|---|---|---:|---|
| `project_name` | `string` | Yes | Project name used for naming and tags |
| `environment` | `string` | Yes | Environment name such as `dev`, `test` or `prod` |
| `location` | `string` | Yes | Azure region |
| `address_space` | `list(string)` | Yes | VNet address space |
| `subnet_address_prefixes` | `list(string)` | Yes | Subnet address prefixes |
| `allowed_ssh_source` | `string` | Yes | Source CIDR for example SSH rule |
| `tags` | `map(string)` | No | Additional tags applied to resources |

---

## 11. Variable: project_name

```hcl
variable "project_name" {
  description = "Project name used for Azure resource naming and tagging."
  type        = string
}
```

Purpose:

```text
Defines the project name used in Azure tags and naming logic.
```

Example value:

```hcl
project_name = "enterprise-automation-lab"
```

---

## 12. Variable: environment

```hcl
variable "environment" {
  description = "Environment name for the Azure network foundation."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}
```

Purpose:

```text
Defines which environment is being deployed.
```

Allowed values:

```text
dev
test
prod
```

The validation block prevents invalid environment names.

Example valid value:

```hcl
environment = "dev"
```

Example invalid value:

```hcl
environment = "banana"
```

Terraform will reject invalid values before creating resources.

---

## 13. Variable: location

```hcl
variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}
```

Purpose:

```text
Defines the Azure region used by the module.
```

Current working region for this lab:

```hcl
location = "swedencentral"
```

This region was used because the student subscription policy blocked deployment in `westeurope`.

---

## 14. Variable: address_space

```hcl
variable "address_space" {
  description = "Address space for the Azure virtual network."
  type        = list(string)
}
```

Purpose:

```text
Defines the IP range for the Azure Virtual Network.
```

Example:

```hcl
address_space = ["10.40.0.0/16"]
```

---

## 15. Variable: subnet_address_prefixes

```hcl
variable "subnet_address_prefixes" {
  description = "Address prefixes for the main Azure subnet."
  type        = list(string)
}
```

Purpose:

```text
Defines the IP range for the subnet inside the VNet.
```

Example:

```hcl
subnet_address_prefixes = ["10.40.1.0/24"]
```

---

## 16. Variable: allowed_ssh_source

```hcl
variable "allowed_ssh_source" {
  description = "Source CIDR allowed for SSH in the Network Security Group."
  type        = string
}
```

Purpose:

```text
Defines the source CIDR allowed by the example SSH rule.
```

Example:

```hcl
allowed_ssh_source = "10.0.0.0/8"
```

Important:

```text
This module does not create a VM.
The SSH rule is included as a basic NSG rule example for later stages.
```

---

## 17. Variable: tags

```hcl
variable "tags" {
  description = "Additional tags applied to Azure resources."
  type        = map(string)
  default     = {}
}
```

Purpose:

```text
Allows the environment to pass additional Azure tags into the module.
```

Example:

```hcl
tags = {
  owner = "local-lab"
  stage = "terraform-modules"
}
```

These tags are merged with the module default tags.

---

## 18. Locals

File:

```text
locals.tf
```

The module uses local values to compute names and tags.

Main local values:

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

```hcl
environment = "dev"
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

## 19. Tags

The module applies default tags:

```hcl
default_tags = {
  project     = var.project_name
  environment = var.environment
  managed_by  = "terraform"
  module      = "network-foundation"
}
```

Meaning:

```text
project     = project name
environment = dev, test or prod
managed_by  = Terraform manages this resource
module      = module that created the resource
```

Additional tags are merged with default tags:

```hcl
common_tags = merge(local.default_tags, var.tags)
```

This allows the environment to add extra tags without rewriting the module.

---

## 20. Outputs

This module returns the following outputs.

| Output | Purpose |
|---|---|
| `resource_group_name` | Name of the created Resource Group |
| `resource_group_id` | ID of the created Resource Group |
| `location` | Azure region used by the module |
| `virtual_network_name` | Name of the created VNet |
| `virtual_network_id` | ID of the created VNet |
| `subnet_name` | Name of the created subnet |
| `subnet_id` | ID of the created subnet |
| `network_security_group_name` | Name of the created NSG |
| `network_security_group_id` | ID of the created NSG |

Outputs are important because other modules can use them later.

Example future use:

```hcl
subnet_id = module.network_foundation.subnet_id
```

A future VM module can use this subnet ID to place a VM inside the created subnet.

---

## 21. Example Module Usage

Example usage from an environment root module:

```hcl
module "network_foundation" {
  source = "../../modules/network-foundation"

  project_name             = var.project_name
  environment              = var.environment
  location                 = var.location
  address_space            = var.address_space
  subnet_address_prefixes  = var.subnet_address_prefixes
  allowed_ssh_source       = var.allowed_ssh_source

  tags = {
    stage = "terraform-azure-modules"
  }
}
```

Explanation:

```text
source
```

points to the local module path.

```text
project_name
environment
location
address_space
subnet_address_prefixes
allowed_ssh_source
```

are values passed from the environment into the module.

```text
tags
```

adds extra environment-specific tags.

---

## 22. Cost Safety

This module is cost-safe for the current lab stage because it does not create:

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

The module creates only basic Azure networking resources.

The project still follows the rule:

```text
Create resources -> validate resources -> take screenshots -> destroy resources
```

---

## 23. Resource Provider Requirement

This module requires the Azure resource provider:

```text
Microsoft.Network
```

This provider must be registered in the Azure subscription before applying this module.

In Azure Portal:

```text
Subscriptions
-> Azure for Students
-> Resource providers
-> Microsoft.Network
-> Register
```

---

## 24. State Safety

Terraform state must not be committed to Git.

Do not commit:

```text
terraform.tfstate
terraform.tfstate.backup
.terraform/
terraform.tfvars
```

The provider lock file should be committed:

```text
.terraform.lock.hcl
```

Reason:

```text
It keeps provider versions reproducible.
```

---

## 25. Validation Commands

From the environment directory that calls this module:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

After applying:

```bash
terraform output
terraform state list
```

After validation:

```bash
terraform destroy
```

---

## 26. Expected Result

When this module is called from the dev environment, it should create:

```text
Resource Group: rg-ea-lab-dev
Virtual Network: vnet-ea-lab-dev
Subnet: snet-ea-lab-dev-main
Network Security Group: nsg-ea-lab-dev-main
NSG association: subnet attached to NSG
```

Expected Terraform apply result:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

Expected Terraform destroy result:

```text
Destroy complete! Resources: 5 destroyed.
```

---

## 27. Summary

This module provides a reusable Azure network foundation.

It demonstrates:

```text
Terraform module structure
input variables
local values
resource naming
common tags
Azure Resource Group creation
Azure Virtual Network creation
Azure Subnet creation
Network Security Group creation
Subnet to NSG association
module outputs
cost-safe Terraform design
```

This module is the first advanced Terraform step after the basic flat Terraform configuration.
