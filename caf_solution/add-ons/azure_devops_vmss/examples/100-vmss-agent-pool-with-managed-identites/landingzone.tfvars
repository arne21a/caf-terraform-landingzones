landingzone = {
  backend_type        = "azurerm"
  level               = "level3"
  key                 = "asvm-integration_devops_vmss_level3"
  global_settings_key = "asvm-integration_subscriptions"
  tfstates = {
    asvm-integration_subscriptions = {
      tfstate   = "asvm-integration_subscriptions.tfstate"
      workspace = "tfstate"
    }
    asvm-integration_shared_level3 = {
      tfstate   = "asvm-integration_shared_level3.tfstate"
      workspace = "asvm-integration-shared"
    }
    asvm-integration_devops_level3 = {
      tfstate   = "asvm-integration_devops_level3.tfstate"
      workspace = "asvm-integration-devops"
    }
    asvm = {
      tfstate   = "asvm_subscription_vending_machine.tfstate"
      workspace = "tfstate"
      level     = "lower"
    }
  }
}
