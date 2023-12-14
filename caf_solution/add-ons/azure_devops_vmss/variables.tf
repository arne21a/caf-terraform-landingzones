# Map of the remote data state for lower level
variable "lower_storage_account_name" {}
variable "lower_container_name" {}
variable "lower_resource_group_name" {}

variable "tfstate_storage_account_name" {}
variable "tfstate_container_name" {}
variable "tfstate_key" {}
variable "tfstate_resource_group_name" {}

variable "tfstate_subscription_id" {
  description = "This value is propulated by the rover. subscription id hosting the remote tfstates"
}

variable "global_settings" {
  default = {}
}

variable "tenant_id" {}

variable "landingzone" {}

variable "rover_version" {
  default = null
}

variable "tags" {
  default = null
}

variable "resource_groups" {
  description = "Resource groups configuration objects"
  default     = {}
}

variable "virtual_machine_scale_sets" {
  default = {}
}

variable "keyvaults" {
  default = {}
}

variable "keyvault_access_policies" {
  default = {}
}

variable "role_mapping" {
  default = {}
}

variable "vnets" {
  default = {}
}

variable "azure_devops" {
  default = {}
}

variable "storage_accounts" {
  default = {}
}

variable "storage_account_blobs" {
  default = {}
}

variable "managed_identities" {
  default = {}
}

variable "service_endpoints" {
  default = {}
}

variable "azuread_apps" {
  default = {}
}

variable "azuread_groups_membership" {
  default = {}
}
