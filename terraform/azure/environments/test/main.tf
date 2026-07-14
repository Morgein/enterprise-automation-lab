module "network_foundation" {
  source = "../../modules/network-foundation"

  project_name            = var.project_name
  environment             = var.environment
  location                = var.location
  address_space           = var.address_space
  subnet_address_prefixes = var.subnet_address_prefixes
  allowed_ssh_source      = var.allowed_ssh_source

  tags = {
    stage       = "terraform-environment-separation"
    environment = "test"
  }
}
