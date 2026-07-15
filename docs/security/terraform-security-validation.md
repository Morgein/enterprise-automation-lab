# Terraform Security and Policy Validation

## 1. Purpose

This document describes Terraform security and policy validation for the Enterprise Automation Lab.

The goal is to add static security checks before Terraform code is applied to Azure.

This stage uses:

```text
TFLint
Checkov
GitHub Actions
```

---

## 2. Why Security Validation Exists

Terraform can create real cloud infrastructure.

A valid Terraform configuration can still contain security problems.

Examples:

```text
public access enabled
weak network rules
missing encryption settings
unsafe storage configuration
overly permissive security rules
missing required tags
deprecated provider arguments
incorrect resource configuration
```

Security validation helps detect problems before deployment.

---

## 3. Tools Used

### TFLint

TFLint is used for Terraform linting.

It checks:

```text
Terraform language issues
deprecated syntax
unused declarations
Azure-specific configuration rules
provider-specific best practices
```

The project uses:

```text
terraform ruleset
azurerm ruleset
```

TFLint configuration file:

```text
.tflint.hcl
```

---

### Checkov

Checkov is used for Infrastructure-as-Code policy scanning.

It checks Terraform code for security and compliance misconfigurations.

The project uses Checkov in advisory mode:

```text
--soft-fail
```

This means Checkov reports findings but does not fail the CI pipeline during the baseline stage.

---

## 4. GitHub Actions Workflow

Workflow file:

```text
.github/workflows/terraform-security-validation.yml
```

The workflow runs:

```text
tflint --init
tflint --recursive --config .tflint.hcl
checkov -d terraform --framework terraform --quiet --soft-fail
```

The workflow does not run:

```text
terraform plan
terraform apply
terraform destroy
```

This keeps the workflow safe.

No Azure resources are created by the security workflow.

---

## 5. TFLint Configuration

TFLint configuration:

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

The Terraform plugin enables general Terraform rules.

The AzureRM plugin enables Azure-specific rules.

---

## 6. Local Commands

Initialize TFLint plugins:

```bash
tflint --init
```

Run TFLint:

```bash
tflint --recursive --config .tflint.hcl
```

Run Checkov:

```bash
checkov -d terraform --framework terraform --quiet --soft-fail
```

---

## 7. CI Safety

The security workflow is static.

It does not authenticate to Azure.

It does not create Azure resources.

It does not modify Azure resources.

It only scans Terraform code.

---

## 8. Current Mode

Current Checkov mode:

```text
advisory
```

Reason:

```text
The first security validation stage should collect a baseline.
Findings can be reviewed and fixed in later iterations.
```

Future strict mode:

```text
remove --soft-fail after important findings are handled
```

---

## 9. Stage Result

This stage adds:

```text
TFLint configuration
Azure-specific Terraform linting
Checkov IaC security scanning
Terraform security validation workflow
Security documentation
CI-based Terraform policy baseline
```
