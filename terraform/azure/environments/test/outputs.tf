output "resource_group_name" {
  description = "Name of the Azure Resource Group created by the network foundation module."
  value       = module.network_foundation.resource_group_name
}

output "location" {
  description = "Azure region used by the test environment."
  value       = module.network_foundation.location
}

output "virtual_network_name" {
  description = "Name of the Azure Virtual Network."
  value       = module.network_foundation.virtual_network_name
}

output "subnet_name" {
  description = "Name of the Azure subnet."
  value       = module.network_foundation.subnet_name
}

output "network_security_group_name" {
  description = "Name of the Azure Network Security Group."
  value       = module.network_foundation.network_security_group_name
}

output "subnet_id" {
  description = "ID of the Azure subnet. This can be used by future compute modules."
  value       = module.network_foundation.subnet_id
}
