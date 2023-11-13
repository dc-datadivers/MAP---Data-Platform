<#
 .SYNOPSIS
    Configures diagnostic settings on selected resources.

 .EXAMPLE

    
    ./05_diagnostics.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg102 `
    -Environment DEV `
    -SQLServerName mmg-aue-map-sqs01-e3 `
    -SQLDBName DW `
    -StorageLoggingName mmgauemapauditstre3 `
    -LogAnalyticsName mmg-aue-map-la-e3 `
    -DataFactoryName mmg-aue-map-adf01-e3 `
    -KeyVaultName mmg-aue-map-akv01-e3 


    ./05_diagnostics.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg103 `
    -Environment PROD `
    -SQLServerName mmg-aue-map-sqs01-e1 `
    -SQLDBName DW `
    -StorageLoggingName mmgauemapauditstre1 `
    -LogAnalyticsName mmg-aue-map-la-e1 `
    -DataFactoryName mmg-aue-map-adf01-e1 `
    -KeyVaultName mmg-aue-map-akv01-e1 


#>

param(
   [Parameter(Mandatory = $True)]
   [string]
   $Subscription,
     
   [Parameter(Mandatory = $True)]
   [string]
   $ResourceGroupName,
     
   [Parameter(Mandatory = $True)]
   [ValidateSet('DEV', 'PROD')]
   [string]
   $Environment,

   [Parameter(Mandatory = $True)]
   [string]
   $SQLServerName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $SQLDBName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $StorageLoggingName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $LogAnalyticsName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $DataFactoryName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $KeyVaultName

)

# Sign in
Write-Host "Logging in to Azure CLI...";
az login; 

# Select subscription
Write-Host "Selecting subscription '$Subscription'";
Select-AzSubscription -Subscription $Subscription;

# Create SQL Diagnostic Settings
Write-Host "Configuring SQL diagnostics...";

$logsSetting = "[{categoryGroup:allLogs,enabled:true,retention-policy:{enabled:false,days:0}}]" 
$metricsSetting = "[{category:Basic,enabled:true,retention-policy:{enabled:false,days:0}}]"


$result = az monitor diagnostic-settings create `
   --name SQLDiagnostics `
   --export-to-resource-specific true `
   --resource "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Sql/servers/$SQLServerName/databases/$SQLDBName" `
   --logs $logsSetting `
   --metrics $metricsSetting `
   --storage-account "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageLoggingName" `
   --workspace "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$LogAnalyticsName"

Write-Host "Configuration of SQL diagnostics complete.";




# Create ADF Diagnostic Settings
Write-Host "Configuring ADF diagnostics...";

$logsSetting = "[{category:ActivityRuns,enabled:true,retention-policy:{enabled:false,days:0}},{category:PipelineRuns,enabled:true,retention-policy:{enabled:false,days:0}},{category:TriggerRuns,enabled:true,retention-policy:{enabled:false,days:0}},{category:SandboxPipelineRuns,enabled:true,retention-policy:{enabled:false,days:0}},{category:SandboxActivityRuns,enabled:true,retention-policy:{enabled:false,days:0}}]"
$metricsSetting = "[{category:AllMetrics,enabled:true,retention-policy:{enabled:false,days:0}}]"

$result = az monitor diagnostic-settings create `
   --name ADF-Diagnostics `
   --export-to-resource-specific true `
   --resource "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$DataFactoryName" `
   --logs $logsSetting `
   --metrics $metricsSetting `
   --storage-account "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageLoggingName" `
   --workspace "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$LogAnalyticsName"

Write-Host "Configuration of ADF diagnostics complete.";




# Create Key Vault Diagnostic Settings
Write-Host "Configuring Key Vault diagnostics...";

$logsSetting = "[{categoryGroup:allLogs,enabled:true,retention-policy:{enabled:false,days:0}}]" 
$metricsSetting = "[{category:AllMetrics,enabled:true,retention-policy:{enabled:false,days:0}}]"

$result = az monitor diagnostic-settings create `
   --name AKV-Diagnostics `
   --export-to-resource-specific true `
   --resource "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.KeyVault/vaults/$KeyVaultName" `
   --logs $logsSetting `
   --metrics $metricsSetting `
   --storage-account "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageLoggingName" `
   --workspace "/subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/microsoft.operationalinsights/workspaces/$LogAnalyticsName"

Write-Host "Configuration of Key Vault diagnostics complete.";
