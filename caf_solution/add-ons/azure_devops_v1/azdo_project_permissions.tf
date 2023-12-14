data "azuredevops_group" "main" {
  for_each = var.project_role_assignment
  project_id = data.azuredevops_project.project[each.value.project_key].id
  name       = each.value.group
}

resource "azuredevops_user_entitlement" "main" {
  for_each = local.user_entitlement
  principal_name = each.key
}


resource "azuredevops_group" "main" {
  for_each = local.group_entitlement
  origin_id = each.value.origin_id
  lifecycle {
    ignore_changes = [
      # Ignore changes to group description inherited from AAD
      description,
    ]
  }
}


resource "azuredevops_group_membership" "main" {
  for_each = var.project_role_assignment

  group = data.azuredevops_group.main[each.key].descriptor
  members = [
    try(azuredevops_user_entitlement.main[each.key].descriptor, azuredevops_group.main[each.key].descriptor)
  ]
}

locals {
  user_entitlement = { for k, v in var.project_role_assignment:
    k => v
    if try(v.aad_group_key, null) == null
  }

  group_entitlement = { for k, v in var.project_role_assignment:
    k => merge(v,
        {
          origin_id = local.remote.azuread_groups[v.lz_key][v.aad_group_key].id
        }
      )
    if try(v.aad_group_key, null) != null
  }
}
