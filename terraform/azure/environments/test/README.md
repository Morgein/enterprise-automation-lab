# Terraform Azure Test Environment

## 1. Purpose

This directory defines the test environment for Terraform Azure infrastructure.

It calls the reusable `network-foundation` module and passes test-specific values into it.

In simple terms:

```text
network-foundation module = how to create Azure networking
test environment = create it with test values
```

---

## 2. Directory Path

```text
terraform/azure/environments/test/
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

## 5. Test Values

Current test values:

```text
environment = test
location = swedencentral
VNet address space = 10.50.0.0/16
Subnet address prefix = 10.50.1.0/24
```

Resource names created by the module:

```text
rg-ea-lab-test
vnet-ea-lab-test
snet-ea-lab-test-main
nsg-ea-lab-test-main
```

---

## 6. Difference from Dev

The dev environment uses:

```text
environment = dev
address_space = 10.40.0.0/16
subnet_address_prefixes = 10.40.1.0/24
```

The test environment uses:

```text
environment = test
address_space = 10.50.0.0/16
subnet_address_prefixes = 10.50.1.0/24
```

Both environments use the same module:

```text
terraform/azure/modules/network-foundation/
```

This demonstrates Terraform environment separation.

---

## 7. Files

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

## 8. Cost Safety

This environment follows the project safety rule:

```text
Create resources -> validate resources -> destroy resources
```

No resources should be left running longer than needed.

---

## 9. Commands

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

## 10. Git Safety

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

## 11. Summary

This environment demonstrates Terraform environment separation.

The same reusable network foundation module is used by both:

```text
dev environment
test environment
```

Each environment passes different values into the same module.
