# Terraform Azure Basics

## Purpose

This directory contains the first Azure Terraform basics stage for the Enterprise Automation Lab.

The goal is to create a small and safe Azure networking foundation with Terraform.

## Resources Created

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Subnet to NSG association
```

No virtual machine is created in this stage.

## Why No VM Yet

Virtual machines can consume Azure credits if left running.

This stage focuses only on the Terraform basics workflow:

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

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Terraform and provider version requirements |
| `providers.tf` | AzureRM provider configuration |
| `variables.tf` | Input variables and validation |
| `locals.tf` | Computed names and common tags |
| `main.tf` | Azure resources |
| `outputs.tf` | Useful output values |
| `terraform.tfvars.example` | Safe example variable file |
| `terraform.tfvars` | Real local variable file, not committed |

## Cost Safety Rule

```text
Create resources -> validate resources -> take screenshots -> destroy resources
```

## Commands

Initialize providers:

```bash
terraform init
```

Format code:

```bash
terraform fmt
```

Validate configuration:

```bash
terraform validate
```

Preview resources:

```bash
terraform plan
```

Apply resources:

```bash
terraform apply
```

Show outputs:

```bash
terraform output
```

Show Terraform state resources:

```bash
terraform state list
```

Destroy resources:

```bash
terraform destroy
```

## Important

Always run `terraform destroy` after validation.

Do not commit:

```text
terraform.tfvars
terraform.tfstate
.terraform/
*.tfplan
```
