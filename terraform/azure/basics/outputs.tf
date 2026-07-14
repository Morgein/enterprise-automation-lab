output "resource_group_name" {
  description = "Name of the Azure Resource Group created by Terraform."
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region used for the basics deployment."
  value       = azurerm_resource_group.main.location
}

output "virtual_network_name" {
  description = "Name of the Azure Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "subnet_name" {
  description = "Name of the Azure subnet."
  value       = azurerm_subnet.main.name
}

output "network_security_group_name" {
  description = "Name of the Azure Network Security Group."
  value       = azurerm_network_security_group.main.name
}

output "resource_group_id" {
  description = "Azure Resource Group ID."
  value       = azurerm_resource_group.main.id
}
