landingzone = {
  backend_type        = "azurerm"
  level               = "level3"
  key                 = "asvm-integration_devops_level3"
  global_settings_key = "global_settings_key" # <- replace with real key 
  tfstates = {
    asvm-integration_subscriptions = {
      tfstate   = "asvm-integration_subscriptions.tfstate"
      workspace = "tfstate"
    }
    identity_level2 = {
      tfstate   = "identity_level2.tfstate"
      workspace = "tfstate"
      level     = "lower"
    }
    asvm = {
      tfstate   = "asvm_subscription_vending_machine.tfstate"
      workspace = "tfstate"
      level     = "lower"
    }
  }
}
