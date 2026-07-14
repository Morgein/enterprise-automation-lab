output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the Azure Resource Group."
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region used by the network foundation."
  value       = azurerm_resource_group.main.location
}

output "virtual_network_name" {
  description = "Name of the Azure Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "ID of the Azure Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "subnet_name" {
  description = "Name of the Azure subnet."
  value       = azurerm_subnet.main.name
}

output "subnet_id" {
  description = "ID of the Azure subnet."
  value       = azurerm_subnet.main.id
}

output "network_security_group_name" {
  description = "Name of the Azure Network Security Group."
  value       = azurerm_network_security_group.main.name
}

output "network_security_group_id" {
  description = "ID of the Azure Network Security Group."
  value       = azurerm_network_security_group.main.id
}
