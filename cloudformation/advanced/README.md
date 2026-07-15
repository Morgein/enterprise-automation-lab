# CloudFormation Advanced

## 1. Purpose

This directory contains advanced AWS CloudFormation templates for the Enterprise Automation Lab.

The goal is to demonstrate more advanced CloudFormation concepts without deploying paid AWS resources.

Current template:

```text
security-baseline.yml
```

This stage is focused on:

```text
Metadata
Parameters
Rules
Mappings
Conditions
S3 security configuration
IAM policy documents
Bucket policies
DeletionPolicy
UpdateReplacePolicy
Outputs
cfn-lint validation
GitHub Actions validation
```

No AWS resources are created in this stage.

---

## 2. Deployment Policy

This stage is static-validation only.

The templates are not deployed to AWS.

Allowed actions:

```text
write CloudFormation templates
validate YAML syntax
run yamllint
run cfn-lint
run GitHub Actions validation
document the template structure
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

## 3. Directory Structure

Current directory:

```text
cloudformation/advanced/
```

Expected files:

```text
cloudformation/advanced/
├── README.md
└── security-baseline.yml
```

---

## 4. Template: security-baseline.yml

Template path:

```text
cloudformation/advanced/security-baseline.yml
```

This template defines an advanced security baseline structure.

The template includes:

```text
optional S3 audit bucket
S3 public access block
S3 server-side encryption
S3 bucket ownership controls
S3 bucket policy denying insecure transport
optional read-only IAM managed policy
environment-specific mapping
conditional resource creation
structured outputs
```

The template is used only for static validation.

It is not deployed to AWS in this stage.

---

## 5. CloudFormation Sections Used

The template contains:

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

Section purpose:

| Section | Purpose |
|---|---|
| `AWSTemplateFormatVersion` | Defines the CloudFormation template format version |
| `Description` | Describes what the template does |
| `Metadata` | Stores template metadata and documentation values |
| `Parameters` | Defines configurable input values |
| `Rules` | Validates parameter combinations before stack creation |
| `Mappings` | Defines static lookup tables |
| `Conditions` | Controls whether resources or outputs are created |
| `Resources` | Defines AWS resources |
| `Outputs` | Exposes useful values after stack creation |

---

## 6. Metadata

The template uses a `Metadata` section.

Example values:

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
documents stage name
documents that the template is validation-only
```

Metadata does not create AWS resources.

It provides descriptive information inside the template.

---

## 7. Parameters

Parameters make the template configurable.

Current parameters:

| Parameter | Default | Purpose |
|---|---|---|
| `EnvironmentName` | `dev` | Selects environment-specific naming and mappings |
| `EnableAuditBucket` | `true` | Controls whether the audit bucket is created |
| `EnableReadOnlyPolicy` | `true` | Controls whether the IAM managed policy is created |
| `AuditBucketNamePrefix` | `ea-lab-audit` | Prefix for the audit bucket name |
| `CostCenter` | `lab` | Tag value for cost ownership |

---

## 8. EnvironmentName Parameter

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
controls resource names
controls environment tags
controls mapping lookups
allows dev, test or prod values only
```

Allowed values:

```text
dev
test
prod
```

---

## 9. EnableAuditBucket Parameter

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
controls whether the S3 audit bucket is included in the stack
```

Used by condition:

```text
ShouldCreateAuditBucket
```

If the value is:

```text
true
```

CloudFormation includes the audit bucket and bucket policy.

If the value is:

```text
false
```

CloudFormation skips those resources.

---

## 10. EnableReadOnlyPolicy Parameter

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
controls whether the read-only IAM managed policy is included
```

Used by condition:

```text
ShouldCreateReadOnlyPolicy
```

---

## 11. AuditBucketNamePrefix Parameter

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

This follows S3 bucket naming style requirements.

---

## 12. Rules

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
only evaluate this rule when EnableAuditBucket is true
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

---

## 13. Mappings

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
returns human-readable environment type
returns storage class style value for different environments
```

---

## 14. Conditions

The template defines three conditions.

| Condition | Purpose |
|---|---|
| `ShouldCreateAuditBucket` | Creates audit bucket resources only when enabled |
| `ShouldCreateReadOnlyPolicy` | Creates IAM managed policy only when enabled |
| `IsProduction` | Detects whether environment is prod |

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

---

## 15. Resources

The template defines three logical resources.

| Logical ID | Type | Purpose |
|---|---|---|
| `AuditBucket` | `AWS::S3::Bucket` | Defines an encrypted audit bucket with public access blocked |
| `AuditBucketPolicy` | `AWS::S3::BucketPolicy` | Denies insecure HTTP access to the bucket |
| `ReadOnlyManagedPolicy` | `AWS::IAM::ManagedPolicy` | Defines a read-only IAM policy |

These resources are defined for static validation only.

They are not deployed in this stage.

---

## 16. AuditBucket Resource

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
defines a secure S3 bucket for audit-style storage
```

Important configuration:

```text
DeletionPolicy: Retain
UpdateReplacePolicy: Retain
OwnershipControls
PublicAccessBlockConfiguration
BucketEncryption
VersioningConfiguration
Tags
```

---

## 17. DeletionPolicy and UpdateReplacePolicy

The bucket uses:

```yaml
DeletionPolicy: Retain
UpdateReplacePolicy: Retain
```

Purpose:

```text
protects important bucket data from accidental deletion during stack deletion or replacement
```

This is similar in concept to Terraform:

```hcl
lifecycle {
  prevent_destroy = true
}
```

It is appropriate for data-bearing resources.

---

## 18. S3 Public Access Block

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

This is a security baseline for S3 buckets.

---

## 19. S3 Encryption

The bucket uses:

```yaml
BucketEncryption:
  ServerSideEncryptionConfiguration:
    - ServerSideEncryptionByDefault:
        SSEAlgorithm: AES256
```

Purpose:

```text
enables server-side encryption using Amazon S3 managed encryption keys
```

This demonstrates basic encryption configuration in CloudFormation.

---

## 20. S3 Versioning

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

## 21. AuditBucketPolicy Resource

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

This means access over non-TLS transport is denied.

Policy statement:

```text
DenyInsecureTransport
```

This is a common S3 security control.

---

## 22. ReadOnlyManagedPolicy Resource

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

The policy allows read/list/describe style actions for:

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

## 23. Outputs

The template defines the following outputs:

| Output | Condition | Purpose |
|---|---|---|
| `TemplateStage` | None | Returns the stage name |
| `EnvironmentType` | None | Returns mapped environment type |
| `AuditBucketName` | `ShouldCreateAuditBucket` | Returns bucket name |
| `AuditBucketArn` | `ShouldCreateAuditBucket` | Returns bucket ARN |
| `ReadOnlyManagedPolicyName` | `ShouldCreateReadOnlyPolicy` | Returns managed policy name |

Outputs demonstrate how CloudFormation can expose resource values after stack creation.

---

## 24. Intrinsic Functions Used

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

```yaml
Value: !FindInMap
  - EnvironmentMap
  - !Ref EnvironmentName
  - EnvironmentType
```

---

## 25. AWS Pseudo Parameters

The template uses AWS pseudo parameters:

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
makes bucket name more unique
adds account and region context
avoids hardcoding account-specific values
```

---

## 26. Tags

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

## 27. Static Validation

This stage uses static validation only.

Validation tools:

```text
yamllint
cfn-lint
GitHub Actions
```

No AWS deployment is performed.

---

## 28. Local YAML Validation

Run from repository root:

```bash
yamllint cloudformation/advanced/security-baseline.yml
```

Purpose:

```text
checks YAML syntax and formatting
```

---

## 29. Local CloudFormation Validation

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

## 30. GitHub Actions Validation

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

## 31. Validation Evidence

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

## 32. Cost Safety

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

## 33. Git Safety

Safe files to commit:

```text
cloudformation/advanced/security-baseline.yml
cloudformation/advanced/README.md
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

## 34. Stage Result

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
cfn-lint validation
CI validation through existing CloudFormation workflow
static validation without AWS deployment
```

---

## 35. Summary

This stage demonstrates advanced AWS CloudFormation template structure without paid AWS deployment.

It extends the previous CloudFormation basics stage by adding:

```text
Metadata
Rules
conditional resources
conditional property values
S3 security configuration
IAM policy document structure
data-retention protection
advanced outputs
```

This prepares the project for final Infrastructure as Code comparison between:

```text
Terraform
CloudFormation
Ansible
```
