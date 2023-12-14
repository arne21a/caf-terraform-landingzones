<#
 Terraform doesn't have SDK for Rest API v 6.1 in Azure Devops. so this is to make do
#>
param (
    # PAT that has auth to create pools
    [Parameter()][string]$pat = $env:AZDO_PERSONAL_ACCESS_TOKEN,
    # Service Connection ID that has permissions to the VMSS
    [Parameter(Mandatory=$true)][string]$serviceEndpointId,
    # ProjectID the service connection lives in and also the Agent Pool will be authed for
    [Parameter(Mandatory=$true)][string]$projectId,
    # Name of the Pool to create
    [Parameter(Mandatory=$true)][string]$poolName,
    # exact resourceId in Azure e.g.   `"/subscriptions/id/resourceGroups/GABRIELTF2/providers/Microsoft.Compute/virtualMachineScaleSets/gabrieltf2`"
    [Parameter(Mandatory=$true)][string]$azureId,
    # Organization Name
    [Parameter(Mandatory=$true)][string]$organizationName,
    # Maximum number of nodes that will exist in the elastic pool
    [Parameter(Mandatory=$false)][string]$maxCapacity = 3,
    # Number of agents to have ready waiting for jobs
    [Parameter(Mandatory=$false)][string]$desiredIdle = 0,
    # Discard node after each job completes
    [Parameter(Mandatory=$false)][string]$recycleAfterEachUse = "false",
    # Keep nodes in the pool on failure for investigation
    [Parameter(Mandatory=$false)][string]$maxSavedNodeCount = 0,
    # Operating system type of the nodes in the pool
    [Parameter(Mandatory=$false)][string]$osType = "linux",
    # State of the pool
    [Parameter(Mandatory=$false)][string]$state = "online",
    # The desired size of the pool
    [Parameter(Mandatory=$false)][string]$desiredSize = 0,
    # The number of sizing attempts executed while trying to achieve a desired size
    [Parameter(Mandatory=$false)][string]$sizingAttempts = 0,
    # The minimum time in minutes to keep idle agents alive
    [Parameter(Mandatory=$false)][string]$timeToLiveMinutes = 30

)
$uri = "https://dev.azure.com/$organizationName/_apis/distributedtask/pools?poolName=$poolName"
#$pat = $env:AZDO_PERSONAL_ACCESS_TOKEN
$auth = "terraform" + ':' + $pat
$Encoded = [System.Text.Encoding]::UTF8.GetBytes($auth)
$authorizationInfo = [System.Convert]::ToBase64String($Encoded)
$headers = @{"Authorization"="Basic $($authorizationInfo)"}
$check = (Invoke-WebRequest -Uri $uri -Method GET -Headers $headers)

if (($check.content | ConvertFrom-Json).count -eq 0) {

    $uripost = "https://dev.azure.com/$($organizationName)/_apis/distributedtask/elasticpools?api-version=6.1-preview.1&poolName=$($poolName)&authorizeAllPipelines=false&autoProvisionProjectPools=false&projectId=$projectId"


    $body = "{
        `"serviceEndpointId`": `"$serviceEndpointId`",
        `"serviceEndpointScope`": `"$projectId`",
        `"azureId`": `"$azureId`",
        `"maxCapacity`": $maxCapacity,
        `"desiredIdle`": $desiredIdle,
        `"recycleAfterEachUse`": $recycleAfterEachUse,
        `"maxSavedNodeCount`": $maxSavedNodeCount,
        `"osType`": `"$osType`",
        `"state`": `"$state`",
        `"desiredSize`": $desiredSize,
        `"sizingAttempts`": $sizingAttempts,
        `"agentInteractiveUI`": false,
        `"timeToLiveMinutes`": $timeToLiveMinutes
    }"

    Write-Host $body

    Invoke-WebRequest -Uri $uripost -Method POST -Headers $headers -Body $body -ContentType 'application/json'
}
