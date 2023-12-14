azure_devops = {

  # The addon expects only one of these objects, templating offers more anyway

  url = "https://dev.azure.com/customer/"
  // Note: org_service_url

  # The devops provider requires a personal access token (PAT) to authenticate to azure devops. As of now, there is no way to automate this or use a technical user.
  # Therefore a PAT of a named user has to generated and provided to the provider.
  # PAT Token should be updated manually to the keyvault after running level2 asvm
  pats = {
    admin = {
      secret_name  = "azdo-pat-admin"
      lz_key       = "asvm"
      keyvault_key = "level3"
    }
  }

}