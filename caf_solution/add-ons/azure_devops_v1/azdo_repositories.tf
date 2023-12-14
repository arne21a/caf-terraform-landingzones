resource "azuredevops_git_repository" "main" {
  for_each  = var.repositories
  project_id           = data.azuredevops_project.project[each.value.project_key].id
  name                 = each.value.name
  parent_repository_id = try(each.value.parent_repository_name, null) != null ? data.azuredevops_git_repository.fork_repo[each.key].id : null
  default_branch       = try(each.value.default_branch, null)

   dynamic initialization {
    for_each = (each.value.initialization.init_type == "Clean" ? ["yes"] : [])
    content {
      init_type   = "Clean"
    }
  } 
  dynamic initialization {
    for_each = (each.value.initialization.init_type == "Uninitialized" ? ["yes"] : [])
    content {
      init_type   = "Uninitialized"
    }
  }
  dynamic initialization {
    for_each = each.value.initialization.init_type == "Import" ? ["yes"] : []
    content {
      init_type   = "Import"
      source_type = "Git"
      source_url = each.value.initialization.source_url
      service_connection_id = try(azuredevops_serviceendpoint_generic_git.main[try(each.value.initialization.generic_git_endpoint, null)].id, null)
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to initialization to support importing existing repositories
      # Given that a repo now exists, either imported into terraform state or created by terraform,
      # we don't care for the configuration of initialization against the existing resource
      initialization,
    ]
  }
}

data "azuredevops_project" "fork_project" {
  for_each = { for repo, config in var.repositories: repo => config if try(config.parent_repository_project_name, null) != null}
  name = each.value.parent_repository_project_name
}

data "azuredevops_git_repository" "fork_repo" {
  for_each = { for repo, config in var.repositories: repo => config if try(config.parent_repository_project_name, null) != null}
  project_id = data.azuredevops_project.fork_project[each.key].id
  name       = each.value.parent_repository_name
}

#project_key 
#name
#initialization {
#  type = "Clean" | "Import"
#  source_url = "https://github.com/microsoft/terraform-provider-azuredevops.git"
#}
#devops_service_endpoint_key