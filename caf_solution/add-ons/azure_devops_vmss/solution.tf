module "caf" {
  source  = "aztfmod/caf/azurerm"
  version = "~>5.5.9"
  # NOTE: Upstream could be used as soon as https://github.com/aztfmod/terraform-azurerm-caf/pull/1259 gets merged
  #source = "../../../../terraform-azurerm-caf"

  current_landingzone_key = var.landingzone.key
  tenant_id               = var.tenant_id
  tfstates                = local.tfstates
  tags                    = local.tags
  global_settings         = local.global_settings
  diagnostics             = local.diagnostics

  resource_groups = var.resource_groups

  keyvaults                = var.keyvaults
  keyvault_access_policies = var.keyvault_access_policies
  role_mapping             = var.role_mapping

  compute = {
    virtual_machine_scale_sets = var.virtual_machine_scale_sets
  }

  networking = {
    vnets = var.vnets
  }

  storage_accounts  = var.storage_accounts

  storage = {
    storage_account_blobs  = var.storage_account_blobs
  }

  azuread = {
    azuread_apps = var.azuread_apps
    azuread_groups_membership = var.azuread_groups_membership
  }

  managed_identities                    = var.managed_identities

  # Pass the remote objects you need to connect to.
  remote_objects = {
    keyvaults      = local.remote.keyvaults
    azuread_groups = local.remote.azuread_groups
    image_definitions = local.remote.image_definitions
    managed_identities = local.remote.managed_identities
  }

  providers = {
    azurerm.vhub = azurerm
  }
}
