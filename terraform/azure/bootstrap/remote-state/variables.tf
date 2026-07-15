variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name used for Azure resource tagging."
  type        = string
  default     = "enterprise-automation-lab"
}

variable "location" {
  description = "Azure region where remote state resources will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "Resource Group name for Terraform remote state resources."
  type        = string
  default     = "rg-ea-lab-tfstate"
}

variable "storage_account_prefix" {
  description = "Prefix for the Terraform state Storage Account name. Must be lowercase letters and numbers only."
  type        = string
  default     = "ealabtfstate"

  validation {
    condition     = can(regex("^[a-z0-9]{3,18}$", var.storage_account_prefix))
    error_message = "storage_account_prefix must contain only lowercase letters and numbers and must be between 3 and 18 characters."
  }
}

variable "container_name" {
  description = "Blob container name for Terraform state files."
  type        = string
  default     = "tfstate"
}
