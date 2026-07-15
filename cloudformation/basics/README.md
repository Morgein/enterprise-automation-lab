# CloudFormation Basics

## 1. Purpose

This directory contains basic AWS CloudFormation templates for the Enterprise Automation Lab.

The goal of this stage is to learn CloudFormation syntax and validate templates locally without deploying paid AWS resources.

Current template:

```text
networking-basic.yml
```

This stage is focused on:

```text
CloudFormation template structure
YAML syntax
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

## 2. Deployment Policy

This stage is static-validation only.

The CloudFormation templates are not deployed to AWS.

The project uses CloudFormation here for learning and validation only.

Allowed actions in this stage:

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

---

## 3. Directory Structure

Current directory:

```text
cloudformation/basics/
```

Expected files:

```text
cloudformation/basics/
├── README.md
└── networking-basic.yml
```

---

## 4. Template: networking-basic.yml

Template path:

```text
cloudformation/basics/networking-basic.yml
```

This template defines a basic AWS networking structure.

The template includes:

```text
VPC
Public subnet
Optional private subnet
Security group
Outputs
```

The template is used only for static validation.

It is not deployed to AWS in this stage.

---

## 5. CloudFormation Sections Used

The template contains the main CloudFormation sections:

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

## 6. AWSTemplateFormatVersion

The template uses:

```yaml
AWSTemplateFormatVersion: "2010-09-09"
```

This is the current standard CloudFormation template format version.

It identifies the template as a CloudFormation template.

---

## 7. Description

The template uses a description block:

```yaml
Description: >
  Basic CloudFormation networking template for the Enterprise Automation Lab.
  This template is used for local/static validation only and is not deployed
  to AWS in this stage.
```

Purpose:

```text
explains what the template is for
documents that it is validation-only
makes the template easier to understand
```

---

## 8. Parameters

Parameters make the template configurable.

Instead of hardcoding every value, the template accepts input values.

Current parameters:

| Parameter | Type | Default | Purpose |
|---|---|---|---|
| `EnvironmentName` | `String` | `dev` | Selects environment naming and tagging |
| `VpcCidr` | `String` | `10.60.0.0/16` | Defines the VPC CIDR block |
| `PublicSubnetCidr` | `String` | `10.60.1.0/24` | Defines the public subnet CIDR block |
| `PrivateSubnetCidr` | `String` | `10.60.2.0/24` | Defines the private subnet CIDR block |
| `CreatePrivateSubnet` | `String` | `true` | Controls whether the private subnet is created |
| `AllowedSshCidr` | `String` | `10.0.0.0/8` | Defines example SSH source CIDR |

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
  Description: Environment name used for resource names and tags.
```

Purpose:

```text
controls environment-specific naming
controls environment-specific tags
limits valid values to dev or test
```

Allowed values:

```text
dev
test
```

This prevents invalid environment names.

---

## 10. CIDR Parameters

The template defines three CIDR parameters:

```text
VpcCidr
PublicSubnetCidr
PrivateSubnetCidr
```

Default values:

```text
VPC:            10.60.0.0/16
Public subnet:  10.60.1.0/24
Private subnet: 10.60.2.0/24
```

Purpose:

```text
defines the VPC network range
defines the public subnet range
defines the private subnet range
```

These values are used by the VPC and subnet resources.

---

## 11. CreatePrivateSubnet Parameter

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

## 12. AllowedSshCidr Parameter

Parameter:

```yaml
AllowedSshCidr:
  Type: String
  Default: 10.0.0.0/8
  Description: Example CIDR allowed for SSH traffic in the security group.
```

Purpose:

```text
defines the source CIDR for the example SSH security group rule
```

Important note:

```text
This is used only for static validation in this stage.
No security group is deployed to AWS.
```

---

## 13. Mappings

Mappings are static lookup tables inside a CloudFormation template.

Current mapping:

```text
EnvironmentTagMap
```

It maps environment names to human-readable environment types:

```text
dev  -> Development
test -> Testing
```

Template section:

```yaml
Mappings:
  EnvironmentTagMap:
    dev:
      EnvironmentType: Development
    test:
      EnvironmentType: Testing
```

The template uses this mapping to create:

```text
EnvironmentType tag
EnvironmentType output
```

---

## 14. Conditions

Conditions allow CloudFormation to create resources or outputs only when a condition is true.

Current condition:

```text
ShouldCreatePrivateSubnet
```

Condition logic:

```yaml
ShouldCreatePrivateSubnet: !Equals [!Ref CreatePrivateSubnet, "true"]
```

Meaning:

```text
if CreatePrivateSubnet equals true
then create the private subnet
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
| `LabVpc` | `AWS::EC2::VPC` | Creates a VPC |
| `PublicSubnet` | `AWS::EC2::Subnet` | Creates a public subnet |
| `PrivateSubnet` | `AWS::EC2::Subnet` | Creates an optional private subnet |
| `LabSecurityGroup` | `AWS::EC2::SecurityGroup` | Creates a basic security group |

These resources are defined for learning and validation only.

They are not deployed in this stage.

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

Purpose:

```text
defines the main AWS VPC
```

Important properties:

```text
CidrBlock
EnableDnsHostnames
EnableDnsSupport
Tags
```

The VPC uses:

```yaml
CidrBlock: !Ref VpcCidr
```

This means the VPC CIDR is taken from the `VpcCidr` parameter.

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

Purpose:

```text
defines a subnet inside the VPC
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

The subnet CIDR is taken from:

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

Purpose:

```text
defines an optional private subnet inside the VPC
```

This resource uses a condition:

```yaml
Condition: ShouldCreatePrivateSubnet
```

Meaning:

```text
the private subnet is created only if CreatePrivateSubnet is true
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

Purpose:

```text
defines a basic security group inside the VPC
```

The template includes:

```text
one example inbound SSH rule
one outbound allow rule
```

Inbound rule:

```text
TCP 22 from AllowedSshCidr
```

Important note:

```text
This rule is included for CloudFormation syntax practice.
No AWS deployment is performed in this stage.
```

---

## 20. Outputs

Outputs expose useful values after a CloudFormation stack is deployed.

Current outputs:

| Output | Purpose |
|---|---|
| `VpcId` | Returns the VPC ID |
| `PublicSubnetId` | Returns the public subnet ID |
| `PrivateSubnetId` | Returns the private subnet ID if created |
| `SecurityGroupId` | Returns the security group ID |
| `EnvironmentType` | Returns environment type from mapping |

Even though this stage does not deploy the stack, outputs are included to demonstrate correct CloudFormation structure.

---

## 21. Intrinsic Functions Used

The template uses CloudFormation intrinsic functions.

| Function | Purpose |
|---|---|
| `!Ref` | References parameters or resources |
| `!Sub` | Substitutes variables into strings |
| `!Equals` | Compares two values |
| `!FindInMap` | Looks up values from a mapping |

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

The template applies tags to resources.

Common tags:

```text
Project
Environment
ManagedBy
Stage
```

Example:

```text
Project = enterprise-automation-lab
Environment = dev or test
ManagedBy = cloudformation
Stage = cloudformation-basics
```

Purpose:

```text
identify resources
show ownership
show environment
show that resources are managed by CloudFormation
```

---

## 23. Validation

This stage uses static validation only.

Validation tools:

```text
yamllint
cfn-lint
GitHub Actions
```

No AWS deployment is required.

---

## 24. Local YAML Validation

Run from repository root:

```bash
yamllint cloudformation/basics/networking-basic.yml
```

Purpose:

```text
checks YAML formatting and syntax style
```

---

## 25. Local CloudFormation Validation

If `cfn-lint` is installed locally, run:

```bash
cfn-lint cloudformation/basics/networking-basic.yml
```

Purpose:

```text
checks CloudFormation resource structure
checks CloudFormation syntax
checks resource properties
checks references
checks conditions
checks outputs
```

Repository-wide validation:

```bash
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

---

## 26. GitHub Actions Validation

CloudFormation validation is performed by:

```text
.github/workflows/cloudformation-validation.yml
```

The workflow installs `cfn-lint` and validates all CloudFormation YAML templates.

The workflow runs:

```text
pip install cfn-lint
find cloudformation -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 cfn-lint
```

The workflow does not deploy anything to AWS.

It only performs static validation.

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
```

No secrets are used in this stage.

No local AWS credential files should be committed.

Never commit:

```text
.aws/
AWS credentials
access keys
secret keys
deployment parameter files with sensitive values
```

---

## 29. Stage Result

At the end of this stage, the project includes:

```text
basic CloudFormation networking template
CloudFormation parameters
CloudFormation mappings
CloudFormation conditions
CloudFormation resources
CloudFormation outputs
CloudFormation intrinsic functions
local YAML validation
cfn-lint validation workflow
static validation without AWS deployment
```

---

## 30. Summary

This stage introduces AWS CloudFormation basics without paid AWS deployment.

It demonstrates:

```text
CloudFormation YAML structure
template parameters
mappings
conditions
resources
outputs
intrinsic functions
resource tagging
cfn-lint validation
CI-based static validation
```

This prepares the project for later CloudFormation advanced templates and final Infrastructure as Code comparison.
