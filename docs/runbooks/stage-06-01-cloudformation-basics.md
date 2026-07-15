# Stage 6.1 - CloudFormation Basics with Local Static Validation

## 1. Purpose

This document describes Stage 6.1 of the Enterprise Automation Lab.

The goal of this stage is to introduce AWS CloudFormation basics without deploying paid AWS resources.

This stage focuses on:

```text
CloudFormation YAML syntax
template structure
Parameters
Mappings
Conditions
Resources
Outputs
Intrinsic functions
cfn-lint validation
GitHub Actions validation
```

No AWS resources are created in this stage.

---

## 2. Why This Stage Exists

The project already includes Terraform Infrastructure as Code practice for Azure.

CloudFormation is added to demonstrate AWS-native Infrastructure as Code concepts.

Terraform is cloud-agnostic and provider-based.

CloudFormation is AWS-native and uses AWS stack templates.

This stage introduces CloudFormation using static validation only.

The goal is to understand CloudFormation structure without using AWS credits or creating real AWS infrastructure.

---

## 3. Deployment Policy

This stage is validation-only.

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

CloudFormation basics directory:

```text
cloudformation/basics/
```

Files created:

```text
cloudformation/basics/
├── README.md
└── networking-basic.yml
```

GitHub Actions workflow:

```text
.github/workflows/cloudformation-validation.yml
```

Validation screenshots:

```text
docs/screenshots/stage-06-cloudformation-basics/
```

---

## 5. Template Created

Template path:

```text
cloudformation/basics/networking-basic.yml
```

The template defines a basic AWS networking structure:

```text
VPC
Public subnet
Optional private subnet
Security group
Outputs
```

The template is not deployed to AWS.

It is used only for local and CI-based static validation.

---

## 6. CloudFormation Sections Used

The template includes the following CloudFormation sections:

```text
AWSTemplateFormatVersion
Description
Parameters
Mappings
Conditions
Resources
Outputs
```

Each section has a specific purpose.

| Section | Purpose |
|---|---|
| `AWSTemplateFormatVersion` | Defines the CloudFormation template format version |
| `Description` | Describes what the template does |
| `Parameters` | Defines configurable input values |
| `Mappings` | Defines static lookup tables |
| `Conditions` | Defines conditional logic |
| `Resources` | Defines AWS resources |
| `Outputs` | Exposes useful values after deployment |

---

## 7. AWSTemplateFormatVersion

The template uses:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
```

This identifies the file as a CloudFormation template.

---

## 8. Description

The template uses a multiline description:

```yaml
Description: >
  Basic CloudFormation networking template for the Enterprise Automation Lab.
  This template is used for local/static validation only and is not deployed
  to AWS in this stage.
```

Purpose:

```text
documents what the template does
makes the validation-only purpose clear
helps readers understand that no AWS deployment is performed
```

---

## 9. Parameters

Parameters make the template configurable.

Current parameters:

```text
EnvironmentName
VpcCidr
PublicSubnetCidr
PrivateSubnetCidr
CreatePrivateSubnet
AllowedSshCidr
```

Parameter summary:

| Parameter | Default | Purpose |
|---|---|---|
| `EnvironmentName` | `dev` | Selects environment naming and tagging |
| `VpcCidr` | `10.60.0.0/16` | Defines the VPC CIDR block |
| `PublicSubnetCidr` | `10.60.1.0/24` | Defines the public subnet CIDR block |
| `PrivateSubnetCidr` | `10.60.2.0/24` | Defines the private subnet CIDR block |
| `CreatePrivateSubnet` | `true` | Controls whether the private subnet is created |
| `AllowedSshCidr` | `10.0.0.0/8` | Defines example SSH source CIDR |

---

## 10. EnvironmentName Parameter

Parameter:

```yaml
EnvironmentName:
  Type: String
  Default: dev
  AllowedValues:
    - dev
    - test
  Description: Environment name used for resource names and tags.
```

Purpose:

```text
controls resource naming
controls environment tags
restricts valid environment names
```

Allowed values:

```text
dev
test
```

---

## 11. CIDR Parameters

CIDR parameters:

```text
VpcCidr
PublicSubnetCidr
PrivateSubnetCidr
```

Default values:

```text
VpcCidr            = 10.60.0.0/16
PublicSubnetCidr   = 10.60.1.0/24
PrivateSubnetCidr  = 10.60.2.0/24
```

Purpose:

```text
define the VPC network range
define the public subnet network range
define the private subnet network range
```

---

## 12. CreatePrivateSubnet Parameter

Parameter:

```yaml
CreatePrivateSubnet:
  Type: String
  Default: "true"
  AllowedValues:
    - "true"
    - "false"
  Description: Controls whether the private subnet is created.
```

Purpose:

```text
allows the template to optionally create or skip the private subnet
```

This parameter is used by the condition:

```text
ShouldCreatePrivateSubnet
```

---

## 13. Mappings

The template uses a mapping:

```text
EnvironmentTagMap
```

Mapping logic:

```text
dev  -> Development
test -> Testing
```

CloudFormation section:

```yaml
Mappings:
  EnvironmentTagMap:
    dev:
      EnvironmentType: Development
    test:
      EnvironmentType: Testing
```

Purpose:

```text
stores static values inside the template
returns a human-readable environment type
adds EnvironmentType metadata to resources and outputs
```

---

## 14. Conditions

The template uses one condition:

```text
ShouldCreatePrivateSubnet
```

Condition logic:

```yaml
ShouldCreatePrivateSubnet: !Equals [!Ref CreatePrivateSubnet, "true"]
```

Meaning:

```text
create the private subnet only when CreatePrivateSubnet is true
```

The condition is used by:

```text
PrivateSubnet resource
PrivateSubnetId output
```

---

## 15. Resources

The template defines four logical resources.

| Logical ID | Type | Purpose |
|---|---|---|
| `LabVpc` | `AWS::EC2::VPC` | Defines the main VPC |
| `PublicSubnet` | `AWS::EC2::Subnet` | Defines the public subnet |
| `PrivateSubnet` | `AWS::EC2::Subnet` | Defines the optional private subnet |
| `LabSecurityGroup` | `AWS::EC2::SecurityGroup` | Defines a basic security group |

These are template definitions only.

No actual AWS resources are created in this stage.

---

## 16. LabVpc Resource

Logical ID:

```text
LabVpc
```

Resource type:

```text
AWS::EC2::VPC
```

Important properties:

```text
CidrBlock
EnableDnsHostnames
EnableDnsSupport
Tags
```

The VPC CIDR comes from the parameter:

```yaml
CidrBlock: !Ref VpcCidr
```

Tags include:

```text
Name
Project
Environment
EnvironmentType
ManagedBy
Stage
```

---

## 17. PublicSubnet Resource

Logical ID:

```text
PublicSubnet
```

Resource type:

```text
AWS::EC2::Subnet
```

Important properties:

```text
VpcId
CidrBlock
MapPublicIpOnLaunch
Tags
```

The subnet is connected to the VPC with:

```yaml
VpcId: !Ref LabVpc
```

The subnet CIDR comes from:

```yaml
CidrBlock: !Ref PublicSubnetCidr
```

---

## 18. PrivateSubnet Resource

Logical ID:

```text
PrivateSubnet
```

Resource type:

```text
AWS::EC2::Subnet
```

This resource uses:

```yaml
Condition: ShouldCreatePrivateSubnet
```

Meaning:

```text
the private subnet is included only when the condition is true
```

---

## 19. LabSecurityGroup Resource

Logical ID:

```text
LabSecurityGroup
```

Resource type:

```text
AWS::EC2::SecurityGroup
```

The security group includes:

```text
one example inbound SSH rule
one outbound allow rule
```

Inbound rule:

```text
TCP 22 from AllowedSshCidr
```

This is included for CloudFormation syntax practice only.

No security group is deployed in AWS during this stage.

---

## 20. Outputs

The template defines the following outputs:

| Output | Purpose |
|---|---|
| `VpcId` | Returns the VPC ID |
| `PublicSubnetId` | Returns the public subnet ID |
| `PrivateSubnetId` | Returns the private subnet ID if created |
| `SecurityGroupId` | Returns the security group ID |
| `EnvironmentType` | Returns the environment type from the mapping |

Outputs demonstrate how CloudFormation can expose useful values after stack creation.

---

## 21. Intrinsic Functions Used

The template uses CloudFormation intrinsic functions.

| Function | Purpose |
|---|---|
| `!Ref` | References parameters or resources |
| `!Sub` | Substitutes variables into strings |
| `!Equals` | Compares two values |
| `!FindInMap` | Looks up a value from a mapping |

Examples:

```yaml
VpcId: !Ref LabVpc
```

```yaml
Value: !Sub ea-lab-${EnvironmentName}-vpc
```

```yaml
ShouldCreatePrivateSubnet: !Equals [!Ref CreatePrivateSubnet, "true"]
```

```yaml
Value: !FindInMap
  - EnvironmentTagMap
  - !Ref EnvironmentName
  - EnvironmentType
```

---

## 22. Tags

The template applies consistent tags to resources.

Common tags:

```text
Project
Environment
ManagedBy
Stage
```

Example values:

```text
Project = enterprise-automation-lab
Environment = dev
ManagedBy = cloudformation
Stage = cloudformation-basics
```

Purpose:

```text
identify ownership
identify environment
identify IaC tool
identify project stage
```

---

## 23. Local YAML Validation

YAML validation command:

```bash
yamllint cloudformation/basics/networking-basic.yml
```

Purpose:

```text
checks YAML syntax and style
```

---

## 24. Local CloudFormation Validation

CloudFormation validation command:

```bash
cfn-lint cloudformation/basics/networking-basic.yml
```

This command passed successfully in this stage.

Purpose:

```text
validates CloudFormation template syntax
validates resource types
validates resource properties
validates references
validates conditions
validates outputs
```

Repository-wide validation command:

```bash
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

---

## 25. GitHub Actions Validation

CloudFormation validation workflow:

```text
.github/workflows/cloudformation-validation.yml
```

The workflow installs `cfn-lint` and validates all CloudFormation YAML templates.

Workflow steps:

```text
checkout repository
setup Python
install cfn-lint
validate CloudFormation templates
```

The workflow command:

```bash
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

The workflow does not deploy anything to AWS.

---

## 26. Validation Evidence

Validation screenshots are stored in:

```text
docs/screenshots/stage-06-cloudformation-basics/
```

Evidence file:

```text
01-cfn-lint-local-validation.png
```

This screenshot shows:

```text
cfn-lint cloudformation/basics/networking-basic.yml
successful command completion
no CloudFormation validation errors
```

---

## 27. Cost Safety

This stage does not create AWS resources.

Commands not used:

```text
aws cloudformation deploy
aws cloudformation create-stack
aws cloudformation update-stack
aws ec2 create-vpc
```

No AWS credentials are required.

No AWS costs are generated.

---

## 28. Git Safety

Safe files to commit:

```text
cloudformation/basics/networking-basic.yml
cloudformation/basics/README.md
.github/workflows/cloudformation-validation.yml
docs/runbooks/stage-06-01-cloudformation-basics.md
docs/screenshots/stage-06-cloudformation-basics/
```

Never commit:

```text
.aws/
AWS credentials
access keys
secret keys
deployment parameter files with sensitive values
```

---

## 29. CI Safety

The CloudFormation workflow is static.

It does not authenticate to AWS.

It does not require AWS credentials.

It does not deploy stacks.

It only validates template files.

This keeps the workflow safe and cost-free.

---

## 30. Stage Result

At the end of this stage, the project includes:

```text
CloudFormation basics directory
basic networking CloudFormation template
CloudFormation README
CloudFormation validation workflow
CloudFormation local cfn-lint validation
CloudFormation validation screenshot
CloudFormation runbook
static validation without AWS deployment
```

The project now demonstrates:

```text
Terraform Infrastructure as Code for Azure
CloudFormation Infrastructure as Code syntax for AWS
Ansible configuration management
CI validation for Ansible, Terraform and CloudFormation
```

---

## 31. Current Project Status

Current completed stage:

```text
Stage 6.1 - CloudFormation Basics with Local Static Validation
```

---

## 32. Next Stage

Next planned stage:

```text
Stage 7.1 - CloudFormation Advanced Templates with Static Validation
```

Planned goal:

```text
add advanced CloudFormation templates without AWS deployment
```

Possible advanced concepts:

```text
nested stacks concept
more complex Conditions
Rules section
Metadata section
CloudFormation exports/imports concept
IAM policy template validation
cfn-lint validation
GitHub Actions validation
```
