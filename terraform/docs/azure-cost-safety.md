# Azure Cost Safety Guide

## 1. Purpose

This document defines cost safety rules for the Azure Terraform part of the Enterprise Automation Lab.

The project uses Azure student credits, so every Azure deployment must be small, temporary, controlled and destroyed after validation.

The main goal is to practice Terraform on Azure without wasting credits or accidentally leaving paid resources running.

---

## 2. Main Safety Rule

```text
Create resources -> validate resources -> take screenshots -> destroy resources
```

This means:

```text
1. Terraform creates Azure resources.
2. The resources are tested and validated.
3. Screenshots are collected as proof.
4. Terraform destroys the resources after the lab session.
```

No Azure resources should be left running longer than necessary.

---

## 3. Why Cost Safety Matters

Cloud resources are billed while they exist or while they are running.

Some resources are cheap, but others can consume credits quickly.

Examples of possible cost risks:

```text
virtual machines left running overnight
premium disks left after VM deletion
public IP addresses left unused
managed databases running continuously
NAT Gateway or Azure Firewall deployed accidentally
large VM sizes selected by mistake
snapshots and disks forgotten after testing
```

Because this project uses limited student credits, every Azure step must be controlled.

---

## 4. Mandatory Rules

The following rules must be followed for every Azure Terraform deployment.

```text
1. Use a dedicated lab resource group.
2. Use small and cheap resources.
3. Use short lab sessions.
4. Do not leave virtual machines running overnight.
5. Always review `terraform plan` before `terraform apply`.
6. Always run `terraform destroy` after validation.
7. Always check Azure Portal after destroy.
8. Always check remaining credits after a lab session.
9. Never commit Terraform state files.
10. Never commit real Terraform variable files.
11. Never store Azure credentials in Git.
12. Never create expensive services unless they are explicitly required.
```

---

## 5. Dedicated Resource Group Rule

All Terraform Azure resources must be created inside a dedicated lab resource group.

Example resource group name:

```text
rg-enterprise-automation-lab-dev
```

Why this matters:

```text
a dedicated resource group keeps lab resources isolated
it is easier to review what Terraform created
it is easier to delete everything if needed
it reduces the risk of mixing lab resources with other Azure resources
```

If something goes wrong, the entire lab resource group can be removed.

---

## 6. Recommended Azure Region

Use one region consistently for the lab.

Example:

```text
westeurope
```

Why this matters:

```text
resources in the same region are easier to manage
networking is simpler
cost estimation is easier
Terraform code is cleaner
```

Do not spread beginner resources across many Azure regions.

---

## 7. Safe Services for Terraform Basics

The following services are acceptable for the Terraform basics stage:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
Network Security Group rules
Storage Account
Public IP only when needed
Network Interface only when needed
Small Linux VM only when needed
```

These are common Azure infrastructure building blocks.

For the first Terraform Azure stage, start with:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
```

Do not start with VM immediately.

---

## 8. Services to Avoid for Now

Avoid these services during the basic and early advanced stages:

```text
AKS
Azure Firewall
Application Gateway
NAT Gateway
Azure Bastion
Azure Load Balancer unless required
Azure Application Gateway
Managed PostgreSQL
Managed MySQL
Azure SQL Database
large VM sizes
premium disks
snapshots
VPN Gateway
ExpressRoute
Log Analytics with large ingestion
```

Why avoid them:

```text
they can be more expensive
they can create hidden dependent resources
they can be harder to destroy cleanly
they are not needed for Terraform basics
```

---

## 9. Virtual Machine Safety Rules

Virtual machines can consume credits quickly if left running.

Use VMs only when needed.

VM rules:

```text
use the smallest practical VM size
do not use premium disks unless required
do not leave the VM running overnight
destroy the VM after validation
check that the OS disk was removed
check that the public IP was removed
check that the network interface was removed
```

For initial Terraform basics, do not create a VM yet.

VMs should be introduced only after the basic workflow is clear:

```text
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

---

## 10. Terraform State Safety

Terraform state files must not be committed to Git.

Ignored files:

```text
*.tfstate
*.tfstate.*
```

Why state is sensitive:

```text
it contains Azure resource IDs
it can contain infrastructure metadata
it can contain outputs
it may contain sensitive values depending on the configuration
```

State is required for Terraform to manage resources, but it should stay local or be stored in a secure backend later.

For the basics stage:

```text
local state is acceptable
state must not be committed
```

For the advanced stage:

```text
remote state with Azure Storage can be introduced
state locking concept can be documented
```

---

## 11. Terraform Variables Safety

Real Terraform variable files must not be committed.

Ignored file:

```text
terraform.tfvars
```

Allowed file:

```text
terraform.tfvars.example
```

Purpose:

```text
terraform.tfvars = real local values
terraform.tfvars.example = safe template for GitHub
```

Example of safe values:

```text
location
environment
project_name
resource_prefix
```

Examples of values that should be handled carefully:

```text
subscription_id
tenant_id
admin usernames
allowed IP addresses
SSH public key paths
```

---

## 12. Azure Credentials Safety

Do not store Azure credentials in the repository.

Do not commit:

```text
client secrets
service principal passwords
Azure access tokens
tenant secrets
subscription credentials
```

For this project, Terraform should authenticate through Azure CLI login during local lab work.

Typical login command:

```bash
az login --use-device-code
```

Then verify the active subscription:

```bash
az account show --output table
```

Terraform can use the Azure CLI authentication context locally.

---

## 13. Before Terraform Apply Checklist

Before running:

```bash
terraform apply
```

check the following:

```text
correct Azure subscription is selected
correct Azure region is selected
resource group name is correct
resources are small and cheap
no expensive services are included
terraform plan was reviewed
no secrets are hardcoded
no real tfvars file is staged in Git
```

Useful commands:

```bash
az account show --output table
terraform fmt
terraform validate
terraform plan
git status
```

---

## 14. Terraform Plan Review

Always review:

```bash
terraform plan
```

before applying.

Look for:

```text
how many resources will be created
resource types
resource names
resource locations
VM sizes if any
disk types if any
public IP resources
unexpected resources
```

Do not apply if the plan contains unknown or expensive resources.

---

## 15. After Terraform Apply Checklist

After running:

```bash
terraform apply
```

do the following:

```text
check Terraform outputs
verify resources in Azure Portal
take required screenshots
test the created resources
check Azure Cost Management if needed
run terraform destroy after validation
```

Useful commands:

```bash
terraform output
terraform state list
az resource list --resource-group RESOURCE_GROUP_NAME --output table
```

---

## 16. Terraform Destroy Rule

After each Azure lab session, run:

```bash
terraform destroy
```

Then type:

```text
yes
```

After destroy, verify that the resource group is empty or removed.

Useful Azure CLI check:

```bash
az resource list --resource-group RESOURCE_GROUP_NAME --output table
```

If the resource group should also be deleted, verify that it no longer exists:

```bash
az group show --name RESOURCE_GROUP_NAME --output table
```

If it returns an error saying the group was not found, that is expected after deletion.

---

## 17. Azure Portal Verification

After `terraform destroy`, open Azure Portal and check:

```text
Resource groups
Cost Management
Credits remaining
Virtual machines
Disks
Public IP addresses
Network interfaces
Storage accounts
```

The goal is to confirm:

```text
no unexpected resources are left
no VM is still running
no unused disk is left
no unused public IP is left
credits were not consumed unexpectedly
```

---

## 18. Budget and Credit Monitoring

Azure student credits are limited.

Check credits before and after lab work.

Recommended checks:

```text
Azure Portal -> Cost Management + Billing
Azure Portal -> Subscription -> Credits
Azure Portal -> Resource groups
```

Important note:

```text
Budgets and alerts help monitor spending.
They do not replace manual cleanup.
```

The real safety mechanism in this project is:

```text
small resources + short runtime + terraform destroy
```

---

## 19. Screenshot Rules

Screenshots should prove real work, not expose sensitive data.

Good screenshots:

```text
terraform validate
terraform plan
terraform apply success
terraform output
Azure resource group with resources
terraform destroy success
Azure Portal showing resources removed
Cost/credits check with personal details hidden
```

Hide or crop:

```text
email address
subscription ID
tenant ID
full account details
personal information
```

Do not screenshot secrets.

---

## 20. Git Safety Checklist

Before every commit, run:

```bash
git status
```

Do not commit:

```text
terraform.tfstate
terraform.tfstate.backup
terraform.tfvars
.terraform/
*.tfplan
Azure credentials
personal account screenshots with visible sensitive data
```

Safe files to commit:

```text
*.tf
terraform.tfvars.example
README.md
runbooks
architecture documents
sanitized screenshots
```

---

## 21. Emergency Cleanup

If something goes wrong and Terraform cannot destroy resources, use Azure CLI or Azure Portal.

List resources in the lab resource group:

```bash
az resource list --resource-group RESOURCE_GROUP_NAME --output table
```

Delete the entire resource group:

```bash
az group delete --name RESOURCE_GROUP_NAME --yes
```

Important:

```text
deleting the resource group deletes all resources inside it
use this only for the dedicated lab resource group
never use it on a shared or important resource group
```

---

## 22. Safe Terraform Basics Scope

The first Terraform Azure basics stage should create only:

```text
Resource Group
Virtual Network
Subnet
Network Security Group
```

The first stage should validate:

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

This keeps the first Azure deployment safe and cheap.

---

## 23. Advanced Terraform Scope

Advanced Terraform can later include:

```text
modules
environment folders
dev/prod variable separation
Azure Storage remote backend
state locking concept
input validation
naming conventions
tags
security validation
small VM deployment
destroy workflow
```

But advanced stages must still follow:

```text
Create -> Validate -> Screenshot -> Destroy
```

---

## 24. Final Safety Summary

The Azure Terraform part of this project must follow these principles:

```text
use student credits carefully
start with cheap resources
review every plan
destroy after validation
check Azure Portal
check credits
never commit secrets
never commit state
document every step
```

This keeps the project safe, reproducible and professional.
