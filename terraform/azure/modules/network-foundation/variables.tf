variable "project_name" {
  description = "Project name used for Azure resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Environment name for the Azure network foundation."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "address_space" {
  description = "Address space for the Azure virtual network."
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the main Azure subnet."
  type        = list(string)
}

variable "allowed_ssh_source" {
  description = "Source CIDR allowed for SSH in the Network Security Group."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to Azure resources."
  type        = map(string)
  default     = {}
}
