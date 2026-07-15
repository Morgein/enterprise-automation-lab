# Stage 5.3 - Terraform Remote State with Azure Storage

## 1. Purpose

This document describes Stage 5.3 of the Enterprise Automation Lab.

The goal of this stage is to introduce Terraform remote state using Azure Storage.

Before this stage, Terraform state was stored locally:

```text
terraform.tfstate
```

After this stage, the `dev` environment was connected to an AzureRM remote backend and stored its state as a blob inside Azure Storage:

```text
dev.terraform.tfstate
```

This stage demonstrates a more production-like Terraform workflow.

---

## 2. Why Remote State Exists

Terraform state tracks the relationship between Terraform configuration and real infrastructure.

Terraform state contains information such as:

```text
resource IDs
resource names
dependency relationships
provider metadata
outputs
sensitive infrastructure values
```

Local state is enough for small labs, but it has limitations:

```text
state exists only on one machine
state can be accidentally deleted
collaboration is difficult
state locking is not available in a simple local workflow
```

Remote state solves these problems by storing state in a shared backend.

For this project, the backend is:

```text
Azure Storage Account
Azure Blob Container
```

---

## 3. Stage Architecture

Remote state architecture:

```text
terraform/azure/bootstrap/remote-state/
    |
    | creates
    v
Azure Resource Group
Azure Storage Account
Azure Blob Container
    |
    | used by
    v
terraform/azure/environments/dev/
    |
    | stores Terraform state as
    v
dev.terraform.tfstate
```

---

## 4. Resources Created

The remote state bootstrap configuration creates:

```text
Resource Group
Storage Account
Blob Container
```

Terraform also creates one local Terraform-managed random resource:

```text
random_string.storage_suffix
```

This random suffix is used to make the Storage Account name globally unique.

Important distinction:

```text
Plan: 4 to add
```

means:

```text
3 Azure resources
1 Terraform random resource
```

Azure resources:

```text
azurerm_resource_group.tfstate
azurerm_storage_account.tfstate
azurerm_storage_container.tfstate
```

Terraform-only helper resource:

```text
random_string.storage_suffix
```

---

## 5. Directory Structure

Remote state bootstrap directory:

```text
terraform/azure/bootstrap/remote-state/
```

Expected files:

```text
terraform/azure/bootstrap/remote-state/
├── README.md
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

The `dev` environment was updated with backend files:

```text
terraform/azure/environments/dev/
├── backend.tf
└── backend.hcl.example
```

Local files that must not be committed:

```text
terraform/azure/bootstrap/remote-state/.terraform/
terraform/azure/bootstrap/remote-state/terraform.tfvars
terraform/azure/bootstrap/remote-state/terraform.tfstate
terraform/azure/bootstrap/remote-state/terraform.tfstate.backup

terraform/azure/environments/dev/backend.hcl
```

---

## 6. Bootstrap Configuration

Bootstrap path:

```text
terraform/azure/bootstrap/remote-state/
```

This is a separate Terraform root module.

Its job is to create the Azure infrastructure required for remote state.

This is needed because Terraform cannot use a backend before the backend infrastructure exists.

In simple terms:

```text
first create Storage Account and Blob Container
then configure environment to use them as backend
```

---

## 7. versions.tf

File:

```text
terraform/azure/bootstrap/remote-state/versions.tf
```

Purpose:

```text
Defines Terraform and provider version requirements.
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

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

Providers used:

```text
azurerm = creates Azure resources
random  = generates unique Storage Account suffix
```

---

## 8. providers.tf

File:

```text
terraform/azure/bootstrap/remote-state/providers.tf
```

Purpose:

```text
Configures the AzureRM provider.
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
features {} is required by AzureRM provider
subscription_id is passed through a sensitive variable
automatic resource provider registration is disabled
```

The real subscription ID is stored locally in:

```text
terraform.tfvars
```

This file is not committed.

---

## 9. variables.tf

File:

```text
terraform/azure/bootstrap/remote-state/variables.tf
```

Purpose:

```text
Defines input variables for the remote state bootstrap configuration.
```

Variables:

```text
subscription_id
project_name
location
resource_group_name
storage_account_prefix
container_name
```

Important validation:

```hcl
validation {
  condition     = can(regex("^[a-z0-9]{3,18}$", var.storage_account_prefix))
  error_message = "storage_account_prefix must contain only lowercase letters and numbers and must be between 3 and 18 characters."
}
```

Reason:

```text
Azure Storage Account names must use lowercase letters and numbers only.
Storage Account names must be globally unique.
Storage Account names have a maximum length of 24 characters.
The module adds a 6-character random suffix.
The prefix is limited to 18 characters.
```

---

## 10. main.tf

File:

```text
terraform/azure/bootstrap/remote-state/main.tf
```

Purpose:

```text
Creates remote state Azure resources.
```

Resources:

```text
random_string.storage_suffix
azurerm_resource_group.tfstate
azurerm_storage_account.tfstate
azurerm_storage_container.tfstate
```

The Storage Account uses:

```text
Standard tier
LRS replication
TLS 1.2 minimum
public nested items disabled
private container access
```

Important settings:

```hcl
account_tier             = "Standard"
account_replication_type = "LRS"
min_tls_version          = "TLS1_2"
```

Why this is used:

```text
Standard_LRS is enough for a cost-safe lab remote state backend.
TLS1_2 improves baseline security.
Private container access prevents public state exposure.
```

---

## 11. outputs.tf

File:

```text
terraform/azure/bootstrap/remote-state/outputs.tf
```

Purpose:

```text
Outputs backend values required by Terraform environments.
```

Outputs:

```text
resource_group_name
storage_account_name
container_name
backend_config_example
```

The most important output is:

```text
backend_config_example
```

It provides a template for:

```text
terraform/azure/environments/dev/backend.hcl
```

Example backend values:

```hcl
resource_group_name  = "rg-ea-lab-tfstate"
storage_account_name = "ealabtfstate80u3um"
container_name       = "tfstate"
key                  = "dev.terraform.tfstate"
subscription_id      = "<your-subscription-id>"
```

The actual Storage Account name contains a random suffix.

---

## 12. terraform.tfvars.example

File:

```text
terraform/azure/bootstrap/remote-state/terraform.tfvars.example
```

Purpose:

```text
Provides safe example values.
```

This file is safe to commit because it contains a placeholder subscription ID.

The real local file is:

```text
terraform.tfvars
```

This file is not committed.

---

## 13. Dev Backend Files

The `dev` environment was updated with:

```text
backend.tf
backend.hcl.example
```

### backend.tf

File:

```text
terraform/azure/environments/dev/backend.tf
```

Content:

```hcl
terraform {
  backend "azurerm" {}
}
```

Purpose:

```text
Enables AzureRM backend support for the dev environment.
```

The backend block is intentionally empty.

Reason:

```text
Terraform backend configuration cannot use normal input variables.
Real backend values are passed using backend.hcl.
```

---

### backend.hcl.example

File:

```text
terraform/azure/environments/dev/backend.hcl.example
```

Purpose:

```text
Provides a safe backend configuration template.
```

Example:

```hcl
resource_group_name  = "rg-ea-lab-tfstate"
storage_account_name = "ealabtfstatexxxxxx"
container_name       = "tfstate"
key                  = "dev.terraform.tfstate"
subscription_id      = "00000000-0000-0000-0000-000000000000"
```

This file is safe to commit.

---

### backend.hcl

Local file:

```text
terraform/azure/environments/dev/backend.hcl
```

Purpose:

```text
Stores real backend configuration values.
```

This file is not committed.

Reason:

```text
It can contain real subscription ID and real backend resource names.
```

---

## 14. Commands Used - Bootstrap

All bootstrap commands were executed from:

```text
terraform/azure/bootstrap/remote-state/
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

Apply:

```bash
terraform apply
```

Output:

```bash
terraform output
```

Expected plan result:

```text
Plan: 4 to add, 0 to change, 0 to destroy.
```

Expected apply result:

```text
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

---

## 15. Commands Used - Dev Remote Backend

All dev backend commands were executed from:

```text
terraform/azure/environments/dev/
```

Remote backend initialization:

```bash
terraform init -backend-config=backend.hcl -migrate-state
```

Validation:

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

State validation:

```bash
terraform state list
```

Output validation:

```bash
terraform output
```

Expected backend initialization result:

```text
Successfully configured the backend "azurerm"!
Terraform has been successfully initialized!
```

Expected dev plan:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Expected dev apply:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

---

## 16. Azure Portal Validation

Azure Portal was used to validate the remote state blob.

Validation path:

```text
Azure Portal
-> Resource groups
-> rg-ea-lab-tfstate
-> Storage Account
-> Containers
-> tfstate
```

Expected blob:

```text
dev.terraform.tfstate
```

This confirms that Terraform state for the `dev` environment was stored remotely in Azure Storage.

---

## 17. Cleanup Order

Cleanup must happen in the correct order.

Correct order:

```text
1. Destroy dev environment resources.
2. Destroy remote state bootstrap resources.
```

Dev destroy:

```bash
cd terraform/azure/environments/dev
terraform destroy
```

Bootstrap destroy:

```bash
cd terraform/azure/bootstrap/remote-state
terraform destroy
```

Why order matters:

```text
If the Storage Account is destroyed first, the dev environment loses access to its remote state.
The environment using the backend should be destroyed before the backend itself.
```

---

## 18. Validation Evidence

Validation screenshots are stored in:

```text
docs/screenshots/stage-05-terraform-remote-state/
```

Evidence files:

```text
01-remote-state-bootstrap-plan.png
02-remote-state-bootstrap-apply-output.png
03-dev-remote-backend-init-validate.png
04-dev-remote-backend-plan.png
05-dev-remote-state-apply-state-output.png
06-azure-portal-remote-state-blob.png
```

### 01-remote-state-bootstrap-plan.png

Shows:

```text
remote state bootstrap plan
Plan: 4 to add, 0 to change, 0 to destroy
random_string.storage_suffix
azurerm_resource_group.tfstate
azurerm_storage_account.tfstate
azurerm_storage_container.tfstate
```

### 02-remote-state-bootstrap-apply-output.png

Shows:

```text
bootstrap apply completed
backend_config_example output
resource_group_name
storage_account_name
container_name
```

### 03-dev-remote-backend-init-validate.png

Shows:

```text
AzureRM backend successfully configured
Terraform initialized successfully
dev environment validation successful
```

### 04-dev-remote-backend-plan.png

Shows:

```text
dev environment plan using remote backend
Plan: 5 to add, 0 to change, 0 to destroy
```

### 05-dev-remote-state-apply-state-output.png

Shows:

```text
dev environment apply completed
module-based resources created
terraform output values
remote backend workflow validated
```

### 06-azure-portal-remote-state-blob.png

Shows:

```text
Azure Storage Container
tfstate container
dev.terraform.tfstate blob
```

---

## 19. Git Safety

The following files must not be committed:

```text
terraform/azure/bootstrap/remote-state/.terraform/
terraform/azure/bootstrap/remote-state/terraform.tfvars
terraform/azure/bootstrap/remote-state/terraform.tfstate
terraform/azure/bootstrap/remote-state/terraform.tfstate.backup

terraform/azure/environments/dev/backend.hcl
terraform/azure/environments/dev/.terraform/
terraform/azure/environments/dev/terraform.tfvars
terraform/azure/environments/dev/terraform.tfstate
terraform/azure/environments/dev/terraform.tfstate.backup
```

Safe files to commit:

```text
terraform/azure/bootstrap/remote-state/*.tf
terraform/azure/bootstrap/remote-state/terraform.tfvars.example
terraform/azure/bootstrap/remote-state/README.md
terraform/azure/bootstrap/remote-state/.terraform.lock.hcl
terraform/azure/environments/dev/backend.tf
terraform/azure/environments/dev/backend.hcl.example
docs/runbooks/stage-05-03-terraform-remote-state.md
docs/screenshots/stage-05-terraform-remote-state/
```

Provider lock files can be committed:

```text
.terraform.lock.hcl
```

They help keep provider versions reproducible.

---

## 20. CI Validation Requirement

The Terraform GitHub Actions workflow should validate:

```text
terraform/azure/basics
terraform/azure/environments/dev
terraform/azure/environments/test
terraform/azure/bootstrap/remote-state
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

## 21. Stage Result

At the end of this stage:

```text
remote state bootstrap directory created
Azure Storage Account backend created
tfstate Blob Container created
dev backend.tf added
dev backend.hcl.example added
real backend.hcl kept local
dev environment initialized with AzureRM backend
dev environment validated with remote backend
dev environment applied with remote backend
dev.terraform.tfstate blob validated in Azure Portal
runtime screenshots collected
remote backend concept documented
Git safety rules updated for backend.hcl
```

---

## 22. Current Project Status

Current completed stage:

```text
Stage 5.3 - Terraform Remote State with Azure Storage
```

The project now demonstrates:

```text
Terraform flat basics configuration
Terraform reusable module structure
Terraform dev environment
Terraform test environment
Terraform environment separation
Terraform Azure remote state
Azure Storage backend bootstrap
remote backend initialization
remote state blob validation
cost-safe remote state workflow
```

---

## 23. Next Stage

Next planned stage:

```text
Stage 5.4 - Terraform Security and Policy Validation
```

Planned goal:

```text
add security and policy checks for Terraform code before deployment
```

Possible tools:

```text
tfsec
Checkov
TFLint
Terraform validate
Terraform fmt
GitHub Actions security validation
```
