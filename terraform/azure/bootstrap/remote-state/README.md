# Terraform Azure Remote State Bootstrap

## 1. Purpose

This directory creates Azure resources required for Terraform remote state.

It creates:

```text
Resource Group
Storage Account
Blob Container
```

The Blob Container is used to store Terraform state files.

---

## 2. Directory Path

```text
terraform/azure/bootstrap/remote-state/
```

---

## 3. Why Bootstrap Exists

Terraform backend infrastructure must exist before an environment can use it.

For example, before the `dev` environment can store state in Azure Storage, the Storage Account and Blob Container must already exist.

This bootstrap configuration creates those resources.

---

## 4. Resources Created

| Resource | Purpose |
|---|---|
| Resource Group | Holds remote state resources |
| Storage Account | Stores Terraform state blobs |
| Blob Container | Stores `.tfstate` files |

---

## 5. Cost Safety

This creates a real Azure Storage Account.

For the lab workflow:

```text
create backend resources
connect dev environment to remote state
validate remote state blob
take screenshots
destroy lab resources
destroy backend resources if not needed
```

---

## 6. Commands

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

Show outputs:

```bash
terraform output
```

Destroy when no longer needed:

```bash
terraform destroy
```

---

## 7. Git Safety

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

## 8. Backend Usage

After this bootstrap is applied, copy output values into a local environment backend file:

```text
terraform/azure/environments/dev/backend.hcl
```

The local backend file must not be committed.

A safe example file can be committed:

```text
terraform/azure/environments/dev/backend.hcl.example
```
