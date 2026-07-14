locals {
  name_prefix = "ea-lab-${var.environment}"

  default_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "network-foundation"
  }

  common_tags = merge(local.default_tags, var.tags)

  resource_group_name = "rg-${local.name_prefix}"
  vnet_name           = "vnet-${local.name_prefix}"
  subnet_name         = "snet-${local.name_prefix}-main"
  nsg_name            = "nsg-${local.name_prefix}-main"
}
