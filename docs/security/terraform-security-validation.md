# Terraform Security and Policy Validation

## 1. Purpose

This document describes Terraform security and policy validation for the Enterprise Automation Lab.

The goal of this stage is to add static security and policy checks for Terraform code before any infrastructure is deployed to Azure.

This stage uses:

```text
TFLint
Checkov
GitHub Actions
```

The security validation workflow is static.

It does not run:

```text
terraform plan
terraform apply
terraform destroy
```

It does not create, modify or delete Azure resources.

---

## 2. Why Security Validation Exists

Terraform can create real cloud infrastructure.

A Terraform configuration can be syntactically valid but still contain security or quality problems.

Examples:

```text
overly permissive network rules
public access enabled by mistake
missing encryption settings
weak storage configuration
missing tags
deprecated Terraform syntax
unused declarations
provider-specific misconfigurations
unsafe cloud resource settings
```

Security validation helps detect these problems before deployment.

In this project, security validation is added after:

```text
Terraform basics
Terraform modules
Terraform environment separation
Terraform remote state
```

This makes it part of the Infrastructure as Code workflow.

---

## 3. Tools Used

### TFLint

TFLint is used for Terraform linting.

It checks:

```text
Terraform language issues
deprecated syntax
unused declarations
provider-specific rules
Azure-specific Terraform configuration
```

The project uses:

```text
Terraform ruleset
AzureRM ruleset
```

TFLint configuration file:

```text
.tflint.hcl
```

---

### Checkov

Checkov is used for Infrastructure-as-Code security and policy scanning.

It checks Terraform code for security and compliance misconfigurations.

The project runs Checkov in advisory mode:

```text
--soft-fail
```

This means:

```text
Checkov reports findings
Checkov does not fail the GitHub Actions job
```

This is useful for the first security baseline stage.

The goal is to collect findings first, then decide which issues should be fixed, accepted or documented.

---

## 4. Files Added

Stage 5.4 adds the following files:

```text
.tflint.hcl
.github/workflows/terraform-security-validation.yml
docs/security/terraform-security-validation.md
```

File purposes:

| File | Purpose |
|---|---|
| `.tflint.hcl` | TFLint configuration with Terraform and AzureRM rules |
| `.github/workflows/terraform-security-validation.yml` | GitHub Actions workflow for Terraform security validation |
| `docs/security/terraform-security-validation.md` | Documentation for the security validation stage |

---

## 5. TFLint Configuration

Configuration file:

```text
.tflint.hcl
```

Current configuration:

```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```

Explanation:

```text
plugin "terraform"
```

Enables general Terraform rules.

```text
preset = "recommended"
```

Uses the recommended Terraform ruleset.

```text
plugin "azurerm"
```

Enables AzureRM-specific Terraform rules.

```text
version = "0.32.0"
```

Pins the AzureRM TFLint ruleset version.

This makes validation more reproducible.

```text
source = "github.com/terraform-linters/tflint-ruleset-azurerm"
```

Defines where the AzureRM ruleset is downloaded from.

---

## 6. GitHub Actions Workflow

Workflow file:

```text
.github/workflows/terraform-security-validation.yml
```

The workflow runs when Terraform or security validation files change:

```text
terraform/**
.tflint.hcl
.github/workflows/terraform-security-validation.yml
```

The workflow also supports manual execution:

```text
workflow_dispatch
```

---

## 7. Security Workflow Steps

The GitHub Actions workflow performs the following steps:

```text
checkout repository
install TFLint
initialize TFLint plugins
run TFLint for Terraform basics
run TFLint for Terraform dev environment
run TFLint for Terraform test environment
run TFLint for remote state bootstrap
install Python
install Checkov
run Checkov scan
```

Workflow commands:

```text
tflint --init --config .tflint.hcl
tflint --config ../../../.tflint.hcl
tflint --config ../../../../.tflint.hcl
checkov -d terraform --framework terraform --quiet --soft-fail
```

---

## 8. Why TFLint Is Not Run Recursively Across the Whole Repository

The first workflow version used:

```bash
tflint --recursive --config .tflint.hcl
```

This caused a problem.

TFLint tried to scan directories that are not Terraform root modules, including:

```text
terraform/docs
ansible/collections
documentation folders
external Ansible collection files
```

This produced errors such as:

```text
failed to load TFLint config
failed to load file: open .tflint.hcl: no such file or directory
```

The fix was to run TFLint only against real Terraform root directories.

Current TFLint scan targets:

```text
terraform/azure/basics
terraform/azure/environments/dev
terraform/azure/environments/test
terraform/azure/bootstrap/remote-state
```

This avoids scanning unrelated directories.

---

## 9. Terraform Root Directories Checked by TFLint

### Terraform Basics

Directory:

```text
terraform/azure/basics
```

GitHub Actions command:

```yaml
- name: Run TFLint basics
  working-directory: terraform/azure/basics
  run: tflint --config ../../../.tflint.hcl
```

Purpose:

```text
Checks the original flat Terraform Azure basics configuration.
```

---

### Terraform Dev Environment

Directory:

```text
terraform/azure/environments/dev
```

GitHub Actions command:

```yaml
- name: Run TFLint dev environment
  working-directory: terraform/azure/environments/dev
  run: tflint --config ../../../../.tflint.hcl
```

Purpose:

```text
Checks the module-based dev environment.
```

---

### Terraform Test Environment

Directory:

```text
terraform/azure/environments/test
```

GitHub Actions command:

```yaml
- name: Run TFLint test environment
  working-directory: terraform/azure/environments/test
  run: tflint --config ../../../../.tflint.hcl
```

Purpose:

```text
Checks the module-based test environment.
```

---

### Terraform Remote State Bootstrap

Directory:

```text
terraform/azure/bootstrap/remote-state
```

GitHub Actions command:

```yaml
- name: Run TFLint remote state bootstrap
  working-directory: terraform/azure/bootstrap/remote-state
  run: tflint --config ../../../../.tflint.hcl
```

Purpose:

```text
Checks the Terraform configuration that creates Azure Storage remote state resources.
```

---

## 10. TFLint prevent_destroy Finding

TFLint reported that the remote state Storage Account and Blob Container should be protected from accidental deletion.

Affected resources:

```text
azurerm_storage_account.tfstate
azurerm_storage_container.tfstate
```

TFLint rule:

```text
azurerm_resources_missing_prevent_destroy
```

The fix was to add:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This is appropriate for remote state resources because they store Terraform state data.

Remote state backend resources should not be deleted accidentally.

Important operational note:

```text
terraform destroy will be blocked for resources protected with prevent_destroy
```

If the backend must be intentionally removed later, the protection should be removed consciously in code first.

---

## 11. Checkov Configuration

Checkov is installed inside GitHub Actions with:

```bash
pip install checkov
```

Checkov command:

```bash
checkov -d terraform --framework terraform --quiet --soft-fail
```

Explanation:

```text
-d terraform
```

Scans the `terraform/` directory.

```text
--framework terraform
```

Limits the scan to Terraform files.

```text
--quiet
```

Reduces unnecessary output.

```text
--soft-fail
```

Reports findings but does not fail the CI job.

---

## 12. Why Checkov Uses Soft Fail

The project currently uses Checkov in advisory mode:

```text
--soft-fail
```

Reason:

```text
Stage 5.4 introduces the first security baseline.
The first goal is visibility, not immediate pipeline blocking.
Findings should be reviewed before enforcing strict failure.
```

This allows the workflow to show security findings without breaking the project pipeline immediately.

Future strict mode can be enabled by removing:

```text
--soft-fail
```

after the important findings are handled.

---

## 13. Local Validation Commands

Local installation of TFLint and Checkov is optional.

The project relies on GitHub Actions to install and run both tools.

### TFLint local commands

Initialize plugins from repository root:

```bash
tflint --init --config .tflint.hcl
```

Run TFLint for Terraform basics:

```bash
cd terraform/azure/basics
tflint --config ../../../.tflint.hcl
```

Run TFLint for dev environment:

```bash
cd terraform/azure/environments/dev
tflint --config ../../../../.tflint.hcl
```

Run TFLint for test environment:

```bash
cd terraform/azure/environments/test
tflint --config ../../../../.tflint.hcl
```

Run TFLint for remote state bootstrap:

```bash
cd terraform/azure/bootstrap/remote-state
tflint --config ../../../../.tflint.hcl
```

---

### Checkov local command

Run from repository root:

```bash
checkov -d terraform --framework terraform --quiet --soft-fail
```

If Checkov is not installed locally, GitHub Actions will install it automatically.

---

## 14. CI Safety

The Terraform security validation workflow is static.

It does not authenticate to Azure.

It does not require Azure credentials.

It does not run Terraform apply.

It does not create Azure resources.

It does not delete Azure resources.

It only scans Terraform code.

Commands not used in this workflow:

```text
terraform plan
terraform apply
terraform destroy
az login
az group create
az storage account create
```

---

## 15. Relationship with Terraform Validation Workflow

The project has two Terraform-related GitHub Actions workflows.

### Terraform Validation

Workflow:

```text
.github/workflows/terraform-validation.yml
```

Purpose:

```text
format check
terraform init
terraform validate
```

This workflow validates Terraform syntax and provider initialization.

---

### Terraform Security Validation

Workflow:

```text
.github/workflows/terraform-security-validation.yml
```

Purpose:

```text
TFLint linting
AzureRM-specific linting
Checkov security scanning
```

This workflow validates code quality, security posture and policy baseline.

---

## 16. Current Workflow Design

Current security workflow design:

```text
TFLint = strict
Checkov = advisory
```

Meaning:

```text
TFLint findings can fail the workflow.
Checkov findings are reported but do not fail the workflow.
```

Reason:

```text
TFLint focuses on code quality and provider-specific correctness.
Checkov may produce many baseline security findings during the first scan.
```

---

## 17. Common Troubleshooting

### Problem: TFLint fails because .tflint.hcl is missing

Example error:

```text
failed to load TFLint config
failed to load file: open .tflint.hcl: no such file or directory
```

Cause:

```text
TFLint was run recursively across directories where .tflint.hcl was not available.
```

Fix:

```text
Run TFLint only against known Terraform root directories.
Pass the config file with the correct relative path.
```

Correct examples:

```bash
tflint --config ../../../.tflint.hcl
tflint --config ../../../../.tflint.hcl
```

---

### Problem: TFLint reports missing prevent_destroy

Example warning:

```text
Resource is missing lifecycle { prevent_destroy = true }.
This resource contains data that should be protected from accidental deletion.
```

Affected remote state resources:

```text
azurerm_storage_account.tfstate
azurerm_storage_container.tfstate
```

Fix:

```hcl
lifecycle {
  prevent_destroy = true
}
```

Reason:

```text
Remote state backend resources store Terraform state data.
They should be protected from accidental deletion.
```

---

### Problem: Checkov reports findings

Cause:

```text
Checkov is scanning Terraform code for security and compliance issues.
```

Current behavior:

```text
Checkov reports findings but does not fail CI because --soft-fail is enabled.
```

Next action:

```text
Review findings.
Fix important issues.
Document accepted findings if needed.
```

---

### Problem: TFLint plugin initialization fails

Possible causes:

```text
network issue
plugin source unavailable
incorrect plugin version
incorrect .tflint.hcl syntax
```

Actions:

```text
check .tflint.hcl syntax
rerun GitHub Actions
verify plugin version
check setup-tflint step logs
```

---

## 18. Git Safety

This stage does not add secrets.

Safe files to commit:

```text
.tflint.hcl
.github/workflows/terraform-security-validation.yml
docs/security/terraform-security-validation.md
README.md
```

Files that must still not be committed:

```text
terraform.tfvars
terraform.tfstate
terraform.tfstate.backup
.terraform/
backend.hcl
Azure credentials
Vault files
Vault password files
```

---

## 19. Stage Result

At the end of this stage, the project includes:

```text
TFLint configuration
Terraform recommended linting rules
AzureRM-specific linting rules
Checkov Terraform scanning
Terraform security validation GitHub Actions workflow
static security validation documentation
advisory security baseline
remote state resources protected with prevent_destroy
```

The project now validates Terraform code with:

```text
terraform fmt
terraform validate
TFLint
Checkov
```

---

## 20. Current Project Status

Current completed stage:

```text
Stage 5.4 - Terraform Security and Policy Validation
```

The project now demonstrates:

```text
Terraform syntax validation
Terraform module validation
Terraform environment validation
Terraform remote state validation
Terraform linting
Azure-specific Terraform linting
Infrastructure-as-Code security scanning
CI-based security baseline
remote state deletion protection
```

---

## 21. Next Stage

Next planned stage:

```text
Stage 6.1 - CloudFormation Basics with Local Static Validation
```

Planned goal:

```text
introduce AWS CloudFormation syntax and static validation without deploying paid AWS resources
```

Planned approach:

```text
CloudFormation YAML templates
Parameters
Mappings
Conditions
Resources
Outputs
cfn-lint
GitHub Actions validation
local/static validation only
```