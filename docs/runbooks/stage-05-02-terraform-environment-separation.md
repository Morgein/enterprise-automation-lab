# Stage 5.2 - Terraform Environment Separation

## 1. Purpose

This document describes Stage 5.2 of the Enterprise Automation Lab.

The goal of this stage is to demonstrate Terraform environment separation by adding a second environment that reuses the same Terraform module.

Previous module-based structure:

```text
terraform/azure/modules/network-foundation/
terraform/azure/environments/dev/
```

New structure:

```text
terraform/azure/modules/network-foundation/
terraform/azure/environments/dev/
terraform/azure/environments/test/
```

The same reusable module is now used by multiple environments.

---

## 2. Why This Stage Exists

In Stage 5.1, the project introduced a reusable Terraform module:

```text
terraform/azure/modules/network-foundation/
```

That module was called by the dev environment:

```text
terraform/azure/environments/dev/
```

Stage 5.2 proves that the module is actually reusable by adding a separate test environment.

In simple terms:

```text
module = reusable infrastructure logic
environment = specific values for a deployment
```

For this project:

```text
network-foundation module
    -> defines how to create Azure networking resources

dev environment
    -> creates dev networking values

test environment
    -> creates test networking values
```

---

## 3. Final Structure

The Terraform Azure environment structure is now:

```text
terraform/azure/
├── environments/
│   ├── dev/
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars.example
│   │   ├── variables.tf
│   │   └── versions.tf
│   │
│   └── test/
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

---

## 4. Module Reuse

Both environments use the same module:

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

The environments do not duplicate this resource logic.

Instead, they only provide different values.

---

## 5. Dev Environment

Dev environment path:

```text
terraform/azure/environments/dev/
```

Dev values:

```text
environment = dev
location = swedencentral
address_space = 10.40.0.0/16
subnet_address_prefixes = 10.40.1.0/24
```

Expected dev resource names:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
snet-ea-lab-dev-main
nsg-ea-lab-dev-main
```

Dev stage tag:

```text
stage = terraform-azure-modules
```

---

## 6. Test Environment

Test environment path:

```text
terraform/azure/environments/test/
```

Test values:

```text
environment = test
location = swedencentral
address_space = 10.50.0.0/16
subnet_address_prefixes = 10.50.1.0/24
```

Expected test resource names:

```text
rg-ea-lab-test
vnet-ea-lab-test
snet-ea-lab-test-main
nsg-ea-lab-test-main
```

Test stage tag:

```text
stage = terraform-environment-separation
```

---

## 7. Environment Separation Logic

The environments use the same module, but different values.

Comparison:

| Setting | Dev | Test |
|---|---|---|
| Environment | `dev` | `test` |
| VNet CIDR | `10.40.0.0/16` | `10.50.0.0/16` |
| Subnet CIDR | `10.40.1.0/24` | `10.50.1.0/24` |
| Resource Group | `rg-ea-lab-dev` | `rg-ea-lab-test` |
| VNet | `vnet-ea-lab-dev` | `vnet-ea-lab-test` |
| Subnet | `snet-ea-lab-dev-main` | `snet-ea-lab-test-main` |
| NSG | `nsg-ea-lab-dev-main` | `nsg-ea-lab-test-main` |

This demonstrates that the same infrastructure pattern can be reused safely with separate environment values.

---

## 8. Test Environment Files

### versions.tf

File:

```text
terraform/azure/environments/test/versions.tf
```

Purpose:

```text
Defines Terraform and AzureRM provider version requirements for the test environment.
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

---

### providers.tf

File:

```text
terraform/azure/environments/test/providers.tf
```

Purpose:

```text
Configures the AzureRM provider in the test root module.
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
automatic Azure resource provider registration is disabled
```

---

### variables.tf

File:

```text
terraform/azure/environments/test/variables.tf
```

Purpose:

```text
Defines input variables for the test environment.
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

The environment variable is restricted to:

```text
test
```

Validation:

```hcl
validation {
  condition     = var.environment == "test"
  error_message = "This environment directory is only intended for test deployments."
}
```

This prevents accidental use of the test directory for another environment.

---

### main.tf

File:

```text
terraform/azure/environments/test/main.tf
```

Purpose:

```text
Calls the reusable network-foundation module with test-specific values.
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
    stage       = "terraform-environment-separation"
    environment = "test"
  }
}
```

---

### outputs.tf

File:

```text
terraform/azure/environments/test/outputs.tf
```

Purpose:

```text
Exposes selected outputs from the network foundation module.
```

Outputs:

```text
resource_group_name
location
virtual_network_name
subnet_name
network_security_group_name
subnet_id
```

The test environment uses the same output contract as the dev environment.

This is useful because future modules can consume outputs in the same way across environments.

---

### terraform.tfvars.example

File:

```text
terraform/azure/environments/test/terraform.tfvars.example
```

Purpose:

```text
Provides safe example values for the test environment.
```

This file is safe to commit.

It contains a placeholder subscription ID:

```text
00000000-0000-0000-0000-000000000000
```

---

### terraform.tfvars

Local file:

```text
terraform/azure/environments/test/terraform.tfvars
```

Purpose:

```text
Stores real local values, including the real Azure subscription ID.
```

This file must not be committed.

---

## 9. Commands Used

All test environment commands were executed from:

```text
terraform/azure/environments/test/
```

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

For this stage, `terraform apply` was not required for the test environment.

Reason:

```text
Stage 5.1 already validated real Azure deployment through the module.
Stage 5.2 only needs to prove environment separation and module reuse.
A test plan is enough to prove the module generates different test resources.
```

This keeps the stage cost-safe.

---

## 10. Expected Test Plan

Expected plan result:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Expected module-based resource addresses:

```text
module.network_foundation.azurerm_resource_group.main
module.network_foundation.azurerm_virtual_network.main
module.network_foundation.azurerm_subnet.main
module.network_foundation.azurerm_network_security_group.main
module.network_foundation.azurerm_subnet_network_security_group_association.main
```

Expected test resource names:

```text
rg-ea-lab-test
vnet-ea-lab-test
snet-ea-lab-test-main
nsg-ea-lab-test-main
```

Expected test CIDR values:

```text
10.50.0.0/16
10.50.1.0/24
```

---

## 11. Validation Evidence

Validation screenshots are stored in:

```text
docs/screenshots/stage-05-terraform-environment-separation/
```

Evidence file:

```text
01-terraform-test-environment-plan.png
```

This screenshot shows:

```text
Terraform test environment plan
module.network_foundation resource paths
Plan: 5 to add, 0 to change, 0 to destroy
test resource names
test CIDR values
```

---

## 12. Git Safety

The following files must not be committed:

```text
terraform/azure/environments/test/.terraform/
terraform/azure/environments/test/terraform.tfvars
terraform/azure/environments/test/terraform.tfstate
terraform/azure/environments/test/terraform.tfstate.backup
```

Safe files to commit:

```text
terraform/azure/environments/test/*.tf
terraform/azure/environments/test/terraform.tfvars.example
terraform/azure/environments/test/README.md
docs/runbooks/stage-05-02-terraform-environment-separation.md
docs/screenshots/stage-05-terraform-environment-separation/
```

Provider lock files can be committed if created:

```text
.terraform.lock.hcl
```

They help keep provider versions reproducible.

---

## 13. CI Validation Requirement

The Terraform GitHub Actions workflow should validate:

```text
terraform/azure/basics
terraform/azure/environments/dev
terraform/azure/environments/test
```

The workflow should run:

```text
terraform fmt -check -recursive terraform
terraform init -backend=false
terraform validate
```

The workflow should not run:

```text
terraform plan
terraform apply
terraform destroy
```

This keeps CI safe and prevents Azure resource creation from GitHub Actions.

---

## 14. Stage Result

At the end of this stage:

```text
test environment directory created
test environment uses the same network-foundation module
test environment has separate CIDR values
test environment has separate resource names
test environment has separate stage tag
test environment validates successfully
test environment plan shows 5 expected resources
module reuse is demonstrated
environment separation is demonstrated
no test apply was required
cost-safe validation was preserved
```

---

## 15. Current Project Status

Current completed stage:

```text
Stage 5.2 - Terraform Environment Separation
```

The project now demonstrates:

```text
Terraform flat basics configuration
Terraform reusable module structure
Terraform dev environment
Terraform test environment
environment-specific values
module reuse across environments
cost-safe environment validation
```

---

## 16. Next Stage

Next planned stage:

```text
Stage 5.3 - Terraform Remote State with Azure Storage
```

Planned goal:

```text
move from local Terraform state to Azure Storage remote backend
```

This will introduce:

```text
Azure Storage Account
Azure Storage Container
Terraform backend concept
state locking concept
state separation per environment
remote state safety
```
