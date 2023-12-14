# The PAT token must be provisioned in a different deployment
provider "azuredevops" {
  org_service_url = var.azure_devops.url
  # NOTE: It's always the same PAT token - see vm_extension_devops_agent.tf
  personal_access_token = data.azurerm_key_vault_secret.pat.value
}

data "azurerm_key_vault_secret" "pat" {
  name         = var.azure_devops.pats["admin"].secret_name
  key_vault_id = local.remote.keyvaults[var.azure_devops.pats["admin"].lz_key][var.azure_devops.pats["admin"].keyvault_key].id
}

data "azuredevops_project" "project" {
  name = var.azure_devops.project
}


data "azurerm_key_vault_secret" "client_secret" {
  depends_on = [module.caf]
  for_each   = try(var.azure_devops.service_endpoints, {})

  name = format("%s-client-secret",
    local.combined.aad_apps[try(each.value.aad_app.lz_key, var.landingzone.key)][each.value.aad_app.key]
    .keyvaults[each.value.keyvault.key]
    .secret_name_client_secret
  )
  key_vault_id = local.combined.aad_apps[try(each.value.aad_app.lz_key, var.landingzone.key)][each.value.aad_app.key].keyvaults[each.value.keyvault.key].id
}
resource "azuredevops_serviceendpoint_azurerm" "azure" {
  depends_on = [module.caf]
  for_each   = try(var.azure_devops.service_endpoints, {})

  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = each.value.endpoint_name

  credentials {
    serviceprincipalid  = local.combined.aad_apps[try(each.value.aad_app.lz_key, var.landingzone.key)][each.value.aad_app.key].azuread_application.application_id
    serviceprincipalkey = data.azurerm_key_vault_secret.client_secret[each.key].value
  }

  azurerm_spn_tenantid      = local.combined.aad_apps[try(each.value.aad_app.lz_key, var.landingzone.key)][each.value.aad_app.key].tenant_id
  azurerm_subscription_id   = try(each.value.subscription.id, data.azurerm_subscriptions.available[each.key].subscriptions[0].subscription_id)
  azurerm_subscription_name = each.value.subscription.name
}


data "azurerm_subscriptions" "available" {
  for_each            = try(var.azure_devops.service_endpoints, {})
  display_name_prefix = each.value.subscription.name
}
#
# Grant acccess to service endpoint to all pipelines in the project
#

resource "azuredevops_resource_authorization" "endpoint" {
  for_each = azuredevops_serviceendpoint_azurerm.azure

  project_id  = data.azuredevops_project.project.id
  resource_id = each.value.id
  type        = "endpoint"
  authorized  = true
}

# FIXME: Authorization is missing after VMSS is recreated (e.g due to change of image)
resource "null_resource" "add_vmss_agent_pool" {

  depends_on = [
    #module.caf.virtual_machine_scale_sets,
    azuredevops_serviceendpoint_azurerm.azure
  ]

  for_each = try(var.azure_devops.agent_pools, {})

  provisioner "local-exec" {
    command = format("pwsh -File %s/scripts/VMSSAgentPoolCreate.ps1 -serviceEndpointId %s -projectId %s -azureId %s -poolName %s -organizationName %s",
      path.module,
      azuredevops_serviceendpoint_azurerm.azure[each.value.service_endpoint_key].id,
      data.azuredevops_project.project.id,
      local.combined.virtual_machine_scale_sets[try(each.value.virtual_machine_scale_set_lz_key, var.landingzone.key)][each.value.virtual_machine_scale_set_key].id,
      each.value.name,
      var.azure_devops.org_name
    )

    environment = {
      AZDO_PERSONAL_ACCESS_TOKEN = data.azurerm_key_vault_secret.pat.value
    }
  }

  triggers = {
    vmss       = local.combined.virtual_machine_scale_sets[try(each.value.virtual_machine_scale_set_lz_key, var.landingzone.key)][each.value.virtual_machine_scale_set_key].id,
    sc         = azuredevops_serviceendpoint_azurerm.azure[each.value.service_endpoint_key].id
    script     = filesha256(format("%s/scripts/VMSSAgentPoolCreate.ps1", path.module))
    #always_run = timestamp()
  }
}


resource "null_resource" "RemoveVMSSAgentPool" {

  for_each = try(var.azure_devops.agent_pools, {})

  provisioner "local-exec" {
    when = destroy

    command = format("pwsh -File %s/scripts/VMSSAgentPoolDestroy.ps1 -poolName %s -organizationName %s",
      path.module,
      self.triggers.poolname,
      self.triggers.organizationName
    )

    # environment = {
    #   AZDO_PERSONAL_ACCESS_TOKEN = data.azurerm_key_vault_secret.pat.value
    # }
  }

  triggers = {
    poolname         = each.value.name
    organizationName = var.azure_devops.org_name
    #always_run       = timestamp()
  }
}
