output "resource_group_name" {
  description = "Resource Group name for Terraform remote state."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage Account name for Terraform remote state."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container name for Terraform remote state."
  value       = azurerm_storage_container.tfstate.name
}

output "backend_config_example" {
  description = "Example backend.hcl content for Terraform environments."
  value       = <<EOT
resource_group_name  = "${azurerm_resource_group.tfstate.name}"
storage_account_name = "${azurerm_storage_account.tfstate.name}"
container_name       = "${azurerm_storage_container.tfstate.name}"
key                  = "dev.terraform.tfstate"
subscription_id      = "<your-subscription-id>"
EOT
}
