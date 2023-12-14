repositories = {

  workload = {
    name        = "caf-infrastructure-resources"
    project_key = "asvm-integration"
    initialization = {
      init_type            = "Import"
      source_url           = "https://user@dev.azure.com/customer/azure-foundation/_git/template-workload-infrastructure-resources"
      generic_git_endpoint = "clone"
    }
  }

  shared = {
    name        = "caf-shared-infrastructure-resources"
    project_key = "asvm-integration"
    initialization = {
      init_type            = "Import"
      source_url           = "https://user@dev.azure.com/customer/azure-foundation/_git/template-workload-infrastructure-resources"
      generic_git_endpoint = "clone"
    }
  }

  landingzones = {
    name        = "caf-terraform-landingzones"
    project_key = "asvm-integration"
    initialization = {
      init_type = "Uninitialized"
    }
    parent_repository_name         = "caf-terraform-landingzones"
    parent_repository_project_name = "azure-foundation"
  }
}