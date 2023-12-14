resource "azuredevops_serviceendpoint_generic_git" "main" {
  for_each = var.generic_git_endpoints
  project_id     = data.azuredevops_project.project[each.value.project_key].id
  repository_url        = each.value.repository_url
  username              = try(each.value.username, null)
  password              = each.value.use_admin_pat_for_serivce_connection ? try(data.external.pat[0].result.value) : try(each.value.password, null) #For AzureDevOps Git, PAT should be used as the password.
  service_endpoint_name = each.value.name
  description           = try(each.value.description, "Managed by Terraform")
}