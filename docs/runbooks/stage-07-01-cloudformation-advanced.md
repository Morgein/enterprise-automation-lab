# Stage 7.1 - CloudFormation Advanced Templates with Static Validation

## 1. Purpose

This document describes Stage 7.1 of the Enterprise Automation Lab.

The goal of this stage is to add an advanced AWS CloudFormation template without deploying any paid AWS resources.

This stage focuses on:

```text
advanced CloudFormation template structure
Metadata
Rules
advanced Parameters
Mappings
Conditions
S3 security configuration
S3 bucket policy
IAM managed policy document
DeletionPolicy
UpdateReplacePolicy
AWS pseudo parameters
advanced intrinsic functions
cfn-lint validation
GitHub Actions validation
```

No AWS resources are created in this stage.

---

## 2. Why This Stage Exists

Stage 6.1 introduced CloudFormation basics using a simple networking template.

Stage 7.1 extends CloudFormation practice by adding a more security-focused and production-like template.

The goal is to demonstrate how CloudFormation can define:

```text
secure S3 configuration
conditional resources
parameter validation
IAM policy documents
data retention behavior
structured outputs
```

This gives the project a stronger AWS-native Infrastructure as Code section.

---

## 3. Deployment Policy

This stage is static-validation only.

Allowed actions:

```text
write CloudFormation templates
validate YAML syntax
run yamllint
run cfn-lint
run GitHub Actions validation
document the template
```

Not used in this stage:

```text
aws cloudformation deploy
aws cloudformation create-stack
aws cloudformation update-stack
AWS Console deployment
paid AWS resources
```

No AWS credentials are required.

No AWS costs are generated.

---

## 4. Directory Structure

Advanced CloudFormation directory:

```text
cloudformation/advanced/
```

Files created:

```text
cloudformation/advanced/
├── README.md
└── security-baseline.yml
```

Validation screenshots:

```text
docs/screenshots/stage-07-cloudformation-advanced/
```

Runbook:

```text
docs/runbooks/stage-07-01-cloudformation-advanced.md
```

---

## 5. Template Created

Template path:

```text
cloudformation/advanced/security-baseline.yml
```

The template defines an advanced security baseline structure.

It includes:

```text
optional S3 audit bucket
S3 public access block
S3 server-side encryption
S3 ownership controls
S3 bucket policy denying insecure transport
optional IAM read-only managed policy
environment-specific mappings
conditional resource creation
conditional property values
structured outputs
```

The template is not deployed to AWS.

It is used only for local and CI-based static validation.

---

## 6. CloudFormation Sections Used

The template includes:

```text
AWSTemplateFormatVersion
Description
Metadata
Parameters
Rules
Mappings
Conditions
Resources
Outputs
```

Section summary:

| Section | Purpose |
|---|---|
| `AWSTemplateFormatVersion` | Defines the CloudFormation template format version |
| `Description` | Describes the template purpose |
| `Metadata` | Stores descriptive template metadata |
| `Parameters` | Defines configurable input values |
| `Rules` | Validates parameter combinations before stack creation |
| `Mappings` | Defines static lookup tables |
| `Conditions` | Controls whether resources or values are included |
| `Resources` | Defines AWS resources |
| `Outputs` | Exposes useful stack values |

---

## 7. Metadata

The template uses the `Metadata` section.

Example:

```yaml
Metadata:
  TemplateName: security-baseline
  Project: enterprise-automation-lab
  Stage: cloudformation-advanced
  DeploymentPolicy: static-validation-only
```

Purpose:

```text
documents template identity
documents project name
documents project stage
documents deployment policy
stores notes about the template
```

Metadata does not create AWS resources.

It helps humans understand the template.

---

## 8. Parameters

The template defines several parameters.

| Parameter | Default | Purpose |
|---|---|---|
| `EnvironmentName` | `dev` | Controls environment-specific naming and mappings |
| `EnableAuditBucket` | `true` | Controls whether the audit bucket is included |
| `EnableReadOnlyPolicy` | `true` | Controls whether the IAM managed policy is included |
| `AuditBucketNamePrefix` | `ea-lab-audit` | Defines the audit bucket name prefix |
| `CostCenter` | `lab` | Defines the cost ownership tag value |

Parameters make the template reusable without changing the template body.

---

## 9. EnvironmentName Parameter

Parameter:

```yaml
EnvironmentName:
  Type: String
  Default: dev
  AllowedValues:
    - dev
    - test
    - prod
```

Purpose:

```text
controls resource naming
controls environment tags
controls mapping lookup
restricts valid environment values
```

Allowed values:

```text
dev
test
prod
```

---

## 10. EnableAuditBucket Parameter

Parameter:

```yaml
EnableAuditBucket:
  Type: String
  Default: "true"
  AllowedValues:
    - "true"
    - "false"
```

Purpose:

```text
controls whether the S3 audit bucket is created
```

Used by condition:

```text
ShouldCreateAuditBucket
```

If enabled, the template includes:

```text
AuditBucket
AuditBucketPolicy
AuditBucketName output
AuditBucketArn output
```

---

## 11. EnableReadOnlyPolicy Parameter

Parameter:

```yaml
EnableReadOnlyPolicy:
  Type: String
  Default: "true"
  AllowedValues:
    - "true"
    - "false"
```

Purpose:

```text
controls whether the read-only IAM managed policy is created
```

Used by condition:

```text
ShouldCreateReadOnlyPolicy
```

---

## 12. AuditBucketNamePrefix Parameter

Parameter:

```yaml
AuditBucketNamePrefix:
  Type: String
  Default: ea-lab-audit
  MinLength: 3
  MaxLength: 30
  AllowedPattern: "^[a-z0-9-]+$"
```

Purpose:

```text
defines the prefix for the audit bucket name
```

Validation rules:

```text
minimum length: 3
maximum length: 30
allowed characters: lowercase letters, numbers and hyphens
```

This demonstrates CloudFormation parameter validation.

---

## 13. CostCenter Parameter

Parameter:

```yaml
CostCenter:
  Type: String
  Default: lab
  AllowedPattern: "^[a-zA-Z0-9-]+$"
```

Purpose:

```text
adds cost ownership metadata through tags
```

This is included to demonstrate tagging and parameter validation.

---

## 14. Rules

The template uses the `Rules` section.

Rule:

```text
AuditBucketRequiresValidPrefix
```

Purpose:

```text
validates that AuditBucketNamePrefix is not empty when audit bucket creation is enabled
```

Rule logic:

```yaml
RuleCondition: !Equals [!Ref EnableAuditBucket, "true"]
```

Meaning:

```text
evaluate this rule only when EnableAuditBucket is true
```

Assertion:

```yaml
Assert: !Not
  - !Equals [!Ref AuditBucketNamePrefix, ""]
```

Meaning:

```text
AuditBucketNamePrefix must not be empty
```

Rules are evaluated before stack creation.

In this project, they are used for template structure practice and static validation.

---

## 15. Mappings

The template uses one mapping:

```text
EnvironmentMap
```

Mapping values:

| Environment | EnvironmentType | LogRetentionClass |
|---|---|---|
| `dev` | `Development` | `STANDARD` |
| `test` | `Testing` | `STANDARD` |
| `prod` | `Production` | `STANDARD_IA` |

Purpose:

```text
stores static environment-specific values
returns readable environment type
demonstrates environment-based configuration
```

The mapping is used in tags and outputs.

---

## 16. Conditions

The template defines three conditions.

| Condition | Purpose |
|---|---|
| `ShouldCreateAuditBucket` | Creates audit bucket resources only when enabled |
| `ShouldCreateReadOnlyPolicy` | Creates IAM managed policy only when enabled |
| `IsProduction` | Detects whether the environment is prod |

Condition examples:

```yaml
ShouldCreateAuditBucket: !Equals [!Ref EnableAuditBucket, "true"]
```

```yaml
ShouldCreateReadOnlyPolicy: !Equals [!Ref EnableReadOnlyPolicy, "true"]
```

```yaml
IsProduction: !Equals [!Ref EnvironmentName, prod]
```

Conditions are used for both resources and property values.

---

## 17. Resources

The template defines three logical resources.

| Logical ID | Type | Purpose |
|---|---|---|
| `AuditBucket` | `AWS::S3::Bucket` | Defines an encrypted audit bucket with public access blocked |
| `AuditBucketPolicy` | `AWS::S3::BucketPolicy` | Denies insecure transport to the bucket |
| `ReadOnlyManagedPolicy` | `AWS::IAM::ManagedPolicy` | Defines a read-only IAM managed policy |

These resources are defined for validation only.

No AWS resources are deployed in this stage.

---

## 18. AuditBucket Resource

Logical ID:

```text
AuditBucket
```

Resource type:

```text
AWS::S3::Bucket
```

Purpose:

```text
defines a security-focused S3 audit bucket
```

Important configuration:

```text
DeletionPolicy
UpdateReplacePolicy
OwnershipControls
PublicAccessBlockConfiguration
BucketEncryption
VersioningConfiguration
Tags
```

---

## 19. DeletionPolicy and UpdateReplacePolicy

The bucket uses:

```yaml
DeletionPolicy: Retain
UpdateReplacePolicy: Retain
```

Purpose:

```text
protects bucket data from accidental deletion during stack deletion or replacement
```

This is similar in concept to Terraform:

```hcl
lifecycle {
  prevent_destroy = true
}
```

Both patterns protect data-bearing resources from accidental destruction.

---

## 20. S3 Ownership Controls

The bucket uses:

```yaml
OwnershipControls:
  Rules:
    - ObjectOwnership: BucketOwnerEnforced
```

Purpose:

```text
enforces bucket owner ownership for objects
disables ACL-based ownership management
supports stronger S3 ownership control
```

This is a common modern S3 baseline setting.

---

## 21. S3 Public Access Block

The bucket uses:

```yaml
PublicAccessBlockConfiguration:
  BlockPublicAcls: true
  BlockPublicPolicy: true
  IgnorePublicAcls: true
  RestrictPublicBuckets: true
```

Purpose:

```text
blocks public ACLs
blocks public bucket policies
ignores public ACLs
restricts public bucket access
```

This demonstrates S3 public exposure prevention.

---

## 22. S3 Encryption

The bucket uses:

```yaml
BucketEncryption:
  ServerSideEncryptionConfiguration:
    - ServerSideEncryptionByDefault:
        SSEAlgorithm: AES256
```

Purpose:

```text
enables server-side encryption using Amazon S3 managed keys
```

This demonstrates encryption configuration in CloudFormation.

---

## 23. S3 Versioning

The bucket versioning setting uses a condition:

```yaml
VersioningConfiguration:
  Status: !If
    - IsProduction
    - Enabled
    - Suspended
```

Meaning:

```text
if EnvironmentName is prod, enable versioning
otherwise suspend versioning
```

This demonstrates conditional property values using `!If`.

---

## 24. AuditBucketPolicy Resource

Logical ID:

```text
AuditBucketPolicy
```

Resource type:

```text
AWS::S3::BucketPolicy
```

Purpose:

```text
adds a bucket policy that denies insecure transport
```

The policy denies requests when:

```text
aws:SecureTransport = false
```

Policy statement:

```text
DenyInsecureTransport
```

This is a common S3 security control.

---

## 25. ReadOnlyManagedPolicy Resource

Logical ID:

```text
ReadOnlyManagedPolicy
```

Resource type:

```text
AWS::IAM::ManagedPolicy
```

Purpose:

```text
defines a read-only IAM managed policy
```

The policy allows read/list/describe actions for:

```text
EC2
S3
CloudWatch
```

Actions included:

```text
ec2:Describe*
s3:Get*
s3:List*
cloudwatch:Describe*
cloudwatch:Get*
cloudwatch:List*
```

Resource:

```text
*
```

This is included for IAM policy document structure practice.

No IAM policy is deployed in this stage.

---

## 26. Outputs

The template defines the following outputs.

| Output | Condition | Purpose |
|---|---|---|
| `TemplateStage` | None | Returns the stage name |
| `EnvironmentType` | None | Returns mapped environment type |
| `AuditBucketName` | `ShouldCreateAuditBucket` | Returns bucket name |
| `AuditBucketArn` | `ShouldCreateAuditBucket` | Returns bucket ARN |
| `ReadOnlyManagedPolicyName` | `ShouldCreateReadOnlyPolicy` | Returns managed policy name |

Outputs demonstrate how CloudFormation exposes useful values after stack creation.

---

## 27. Intrinsic Functions Used

The template uses several CloudFormation intrinsic functions.

| Function | Purpose |
|---|---|
| `!Ref` | References parameters or resources |
| `!Sub` | Substitutes variables into strings |
| `!Equals` | Compares values |
| `!Not` | Negates a condition |
| `!FindInMap` | Looks up values from mappings |
| `!If` | Selects value based on a condition |
| `!GetAtt` | Gets an attribute from a resource |

Examples:

```yaml
BucketName: !Sub ${AuditBucketNamePrefix}-${EnvironmentName}-${AWS::AccountId}-${AWS::Region}
```

```yaml
ShouldCreateAuditBucket: !Equals [!Ref EnableAuditBucket, "true"]
```

```yaml
Value: !GetAtt AuditBucket.Arn
```

---

## 28. AWS Pseudo Parameters

The template uses AWS pseudo parameters.

Pseudo parameters used:

```text
AWS::AccountId
AWS::Region
```

Example:

```yaml
BucketName: !Sub ${AuditBucketNamePrefix}-${EnvironmentName}-${AWS::AccountId}-${AWS::Region}
```

Purpose:

```text
adds account context
adds region context
avoids hardcoding account-specific values
helps make resource names unique
```

---

## 29. Tags

The template applies tags to the S3 bucket.

Tags used:

```text
Name
Project
Environment
EnvironmentType
ManagedBy
Stage
CostCenter
```

Purpose:

```text
identify project
identify environment
identify IaC tool
identify stage
identify cost ownership
```

---

## 30. Static Validation

This stage uses static validation only.

Validation tools:

```text
yamllint
cfn-lint
GitHub Actions
```

No AWS deployment is performed.

---

## 31. Local YAML Validation

Run from repository root:

```bash
yamllint cloudformation/advanced/security-baseline.yml
```

Purpose:

```text
checks YAML syntax and formatting
```

---

## 32. Local CloudFormation Validation

Run from repository root:

```bash
cfn-lint cloudformation/advanced/security-baseline.yml
```

Purpose:

```text
checks CloudFormation syntax
checks resource types
checks resource properties
checks references
checks conditions
checks IAM policy structure
checks outputs
```

Repository-wide validation:

```bash
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

---

## 33. GitHub Actions Validation

CloudFormation validation workflow:

```text
.github/workflows/cloudformation-validation.yml
```

The workflow validates all CloudFormation templates inside:

```text
cloudformation/
```

Current templates checked by CI:

```text
cloudformation/basics/networking-basic.yml
cloudformation/advanced/security-baseline.yml
```

The workflow installs:

```text
cfn-lint
```

The workflow does not deploy AWS resources.

---

## 34. Validation Evidence

Validation screenshots are stored in:

```text
docs/screenshots/stage-07-cloudformation-advanced/
```

Evidence file:

```text
01-cfn-lint-advanced-validation.png
```

This screenshot shows:

```text
cfn-lint cloudformation/advanced/security-baseline.yml
successful command completion
no CloudFormation validation errors
```

---

## 35. Cost Safety

This stage does not create AWS resources.

Commands not used:

```text
aws cloudformation deploy
aws cloudformation create-stack
aws cloudformation update-stack
aws iam create-policy
aws s3api create-bucket
```

No AWS credentials are required.

No AWS costs are generated.

---

## 36. Git Safety

Safe files to commit:

```text
cloudformation/advanced/security-baseline.yml
cloudformation/advanced/README.md
docs/runbooks/stage-07-01-cloudformation-advanced.md
docs/screenshots/stage-07-cloudformation-advanced/
```

No secrets are used in this stage.

Never commit:

```text
.aws/
AWS credentials
access keys
secret keys
deployment parameter files with sensitive values
```

---

## 37. CI Safety

The CloudFormation workflow is static.

It does not authenticate to AWS.

It does not require AWS credentials.

It does not deploy stacks.

It only validates template files.

This keeps the workflow safe and cost-free.

---

## 38. Stage Result

At the end of this stage, the project includes:

```text
advanced CloudFormation template
Metadata section
Rules section
advanced Parameters
Mappings
Conditions
S3 bucket security baseline
S3 bucket policy
IAM managed policy document
DeletionPolicy and UpdateReplacePolicy
AWS pseudo parameters
advanced intrinsic functions
advanced CloudFormation README
advanced CloudFormation runbook
cfn-lint validation
CI validation through existing CloudFormation workflow
static validation without AWS deployment
```

---

## 39. Current Project Status

Current completed stage:

```text
Stage 7.1 - CloudFormation Advanced Templates with Static Validation
```

---

## 40. Next Stage

Next planned stage:

```text
Stage 8 - Final IaC Comparison and Project Summary
```

Planned goal:

```text
summarize the complete project and compare Ansible, Terraform and CloudFormation
```

The final stage will include:

```text
final project summary
IaC tool comparison
architecture overview
technical outcomes
what was validated
what was intentionally not deployed
final README polishing
```
