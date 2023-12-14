# README
# About This Example
In this example, we are creating a private agent pool based on an existing virtual machine scale set for our workloads.  
The agents are configured with a managed identity, which allows transparent authentication to Azure without injecting credentials into the pipeline.  
To avoid placing many placeholders in the code, our example is closely based on an actual use case of ours. The created landing zone is called `asvm-integration` for the purposes of this demonstration.

To understand the references to other states in `landingzone.tfvars`, we need an outline of the Azure subscription vending machine landing zone setup. In our case, every workload gets three stage subscriptions, a shared subscription, a DevOps project, and a private VMSS agent pool within the shared subscription, which is preconfigured to work with the generated DevOps project.

This example includes:
- `azure_devops`: The configuration for the DevOps provider.
- `service_endpoints`: A service endpoint that allows the pipeline to control the VMSS in the shared subscription. In our case, this AAD app is created in the level3-shared state.

## Other states:
These are the main resources from other states used in this example  
Level3 - shared:
```
azuread_apps = { # Creating an azure AD App to control the vm scaleset. Credentials are stored in a keyvault to be accessed by an other state or automation
  app_devops_vmss_level4 = {
    application_name = "app-devops-vmss-asvm-integration-shared-level-4"
    app_role_assignment_required = true
    keyvaults = {
      azdosvc = {
        secret_prefix = "sp-devops-vmss-level4"
      }
    }
  }
}
resource_groups = { # Creating an empty resource group as a permissions boundary
  azdo_vmss = {
    name   = "asvm-integration-shared-azdo-vmss"
    region = "region1"
    tags = {
      ...
    }
  }
}
role_mapping = { # Assign contributor permissions to the aad_app with the scope of the resource group
  built_in_role_mapping = {
    resource_groups = {
      azdo_vmss = {
        "Contributor" = {
          azuread_apps = {
            keys = ["app_devops_vmss_level4"]
          }
        }
      }
    }
  }
}
- ```agent_pools```: Creates an agentpool in devops and links it to the scaleset created in level3-shared.
Level3-shared:
```
virtual_machine_scale_sets = {
  l4 = {
    resource_group_key = "azdo_vmss"
    os_type = "linux"
    keyvault_key = "azdossh"
    vmss_settings = {
      linux = {
        name = "l4-agents"
        sku = "Standard_DS2_v2"
        instances = 0
        admin_username = "adminuser"
        disable_password_authentication = true
        provision_vm_agent = true
        overprovision = false
        single_placement_group = false
        priority = "Spot"
        eviction_policy = "Delete"
        ultra_ssd_enabled = false
        upgrade_mode = "Manual"
        os_disk = {
          caching = "ReadWrite"
          storage_account_type = "Standard_LRS"
          disk_size_gb = 100
        }
        identity = {
          type = "UserAssigned"  # Attach a Managed Identity with privileges to deploy to the workload. This Identity is usable with pipelines running on this agent. In our case the Managed Identity is create in level3-subscriptions.
          remote = {
            asvm-integration_subscriptions = {
              managed_identity_keys = [
                "level4_provisioner"
              ]
            }
          }
        }
        custom_image_id = "/subscriptions/id/resourceGroups/rg-foo/providers/Microsoft.Compute/galleries/gal-bar/images/AzureDevOpsAgentLinuxwloxd/versions/0.0.1" # Images are generated separably.
      }
    }
    network_interfaces = {
      nic0 = {
        name = "0"
        primary = true
        vnet_key = "vnet"
        subnet_key = "release_agent_level4"
        enable_accelerated_networking = false
        enable_ip_forwarding = false
        internal_dns_name_label = "nic0"
      }
    }
  }
}
level3-subscription:

```
managed_identities = {
  level4_provisioner = {
    name               = "l4-provisioner-asvm-integration-msi"
    resource_group_key = "level4_provisioner_credentials"
    resource_group = {
      lz_key = "asvm"
    }
  }
}
# Add permissions or group memberships to the managed identity to allow deployments to your infrastructure.
```

```bash
#Note: close previous session if you logged with a different service principal using --impersonate-sp-from-keyvault-url
rover logout

# login a with a user member of the caf-maintainers group

rover \
  --impersonate-sp-from-keyvault-url https://some-keyvault.vault.azure.net/ \
  -lz /tf/caf/landingzones/caf_solution/add-ons/azure_devops_vmss \
  -var-folder /tf/caf/configurations/level3/asvm-integration/devops_vmss \
  -tfstate_subscription_id <sub_id> \
  -target_subscription asvm-integration-shared \
  -tfstate asvm-integration_devops_vmss_level3.tfstate \
  -env production \
  -level level3 \
  -w asvm-integration-devops-vmss \
  -p ${TF_DATA_DIR}/asvm-integration_devops_vmss_level3.tfstate.tfplan \
  -a plan

```
