azure_devops = {


  url = "https://dev.azure.com/customer/"

  project = "asvm-integration"

  org_name = "customer-org"

  pats = {
    "admin" : {
      "keyvault_key" : "level3",
      "lz_key" : "asvm",
      "secret_name" : "azdo-pat-admin"
    }
  }

  service_endpoints = {
    "level4" : {
      "aad_app" : {
        "key" : "app_devops_vmss_level4",
        "lz_key" : "asvm-integration_shared_level3"
      },
      "endpoint_name" : "asvm-integration-level4",
      "keyvault" : {
        "key" : "azdosvc",
        "secret_name" : "sp-devops-vmss-level4"
      },
      "project_key" : "asvm-integration_shared",
      "subscription" : {
        "name" : "asvm-integration-shared"
      }
    }
  }

  agent_pools = {
    "l4" : {
      "name" : "asvm-integration-gitops-level4",
      "service_endpoint_key" : "level4",
      "virtual_machine_scale_set_key" : "l4",
      "virtual_machine_scale_set_lz_key" : "asvm-integration_shared_level3"
    }
  }
}