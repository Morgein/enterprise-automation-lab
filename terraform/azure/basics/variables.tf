variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name used for Azure resource naming."
  type        = string
  default     = "enterprise-automation-lab"
}

variable "environment" {
  description = "Environment name for this Terraform deployment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "westeurope"
}

variable "address_space" {
  description = "Address space for the Azure virtual network."
  type        = list(string)
  default     = ["10.40.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the main Azure subnet."
  type        = list(string)
  default     = ["10.40.1.0/24"]
}

variable "allowed_ssh_source" {
  description = "Source CIDR allowed for SSH in the Network Security Group. This is only a rule example in basics stage."
  type        = string
  default     = "10.0.0.0/8"
}
