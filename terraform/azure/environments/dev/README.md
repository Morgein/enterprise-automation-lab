# Terraform Azure Dev Environment

## 1. Purpose

This directory defines the development environment for Terraform Azure infrastructure.

It calls the reusable `network-foundation` module and passes dev-specific values into it.

In simple terms:

```text
network-foundation module = how to create Azure networking
dev environment = create it with dev values
```

---

## 2. Directory Path

```text
terraform/azure/environments/dev/
```

---

## 3. Module Used

This environment calls:

```text
terraform/azure/modules/network-foundation/
```

Module source path:

```hcl
source = "../../modules/network-foundation"
```

---

## 4. Resources Created

The module creates:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to Network Security Group association
```

No virtual machine is created in this stage.

---

## 5. Dev Values

Current dev values:

```text
environment = dev
location = swedencentral
VNet address space = 10.40.0.0/16
Subnet address prefix = 10.40.1.0/24
```

Resource names created by the module:

```text
rg-ea-lab-dev
vnet-ea-lab-dev
snet-ea-lab-dev-main
nsg-ea-lab-dev-main
```

---

## 6. Files

| File | Purpose |
|---|---|
| `versions.tf` | Terraform and provider version requirements |
| `providers.tf` | AzureRM provider configuration |
| `variables.tf` | Input variables for this environment |
| `main.tf` | Calls the network foundation module |
| `outputs.tf` | Exposes module outputs |
| `terraform.tfvars.example` | Safe example variable file |
| `terraform.tfvars` | Real local variable file, not committed |

---

## 7. Cost Safety

This environment follows the project safety rule:

```text
Create resources -> validate resources -> take screenshots -> destroy resources
```

No resources should be left running longer than needed.

---

## 8. Commands

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

## 9. Git Safety

Do not commit:

```text
terraform.tfvars
terraform.tfstate
terraform.tfstate.backup
.terraform/
```

Commit:

```text
*.tf
terraform.tfvars.example
.terraform.lock.hcl
README.md
```

---

## 10. Summary

This environment demonstrates the first advanced Terraform pattern in the project:

```text
root environment -> reusable module -> Azure resources
```

This separates reusable infrastructure logic from environment-specific configuration.
