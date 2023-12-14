<#
 Terraform doesn't have SDK for Rest API v 6.1 in Azure Devops. so this is to make do
#>
param (
    # PAT that has auth to create pools 
    [Parameter()][string]$pat = $env:AZDO_PERSONAL_ACCESS_TOKEN,
    # Name of the Pool to create
    [Parameter(Mandatory=$true)][string]$poolName,
    # Organization Name 
    [Parameter(Mandatory=$true)][string]$organizationName

)

$uri = "https://dev.azure.com/$organizationName/_apis/distributedtask/pools?poolName=$poolName"
#$pat = $env:AZDO_PERSONAL_ACCESS_TOKEN
$auth = "terraform" + ':' + $pat
$Encoded = [System.Text.Encoding]::UTF8.GetBytes($auth)
$authorizationInfo = [System.Convert]::ToBase64String($Encoded)
$headers = @{"Authorization"="Basic $($authorizationInfo)"}
$check = (Invoke-WebRequest -Uri $uri -Method GET -Headers $headers)

if (($check.content | ConvertFrom-Json).count -gt 0) {

    $uriforpoolid = "https://dev.azure.com/$organizationName/_apis/distributedtask/pools?poolName=$poolName"
    $poolId = ((Invoke-WebRequest -Uri $uriforpoolid -Method GET -Headers $headers).content | ConvertFrom-Json).value.id
            
    #$pat = $env:AZDO_PERSONAL_ACCESS_TOKEN


    $uri ="https://dev.azure.com/$organizationName/_apis/distributedtask/pools/$($poolId)?api-version=6.1-preview.1"
    Invoke-WebRequest -Uri $uri -Method DELETE -Headers $headers  
}
