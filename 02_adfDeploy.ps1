<#
 .SYNOPSIS
    Deploys an ARM template to Azure

 .EXAMPLE

    ./02_adfDeploy.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg102 `
    -ResourceGroupLocation "Australia East" `
    -Environment DEV `
    -contributorGroupId f023a8ba-b533-4e07-8b08-a4294d7fb5c6 `
    -DataFactoryName mmg-aue-map-adf01-e3 `
    -keyVaultName mmg-aue-map-akv01-e3 `
    -factoryKeyName FACTORYCRYPTOKEY `
    -tempIPRequired $True

    ./02_adfDeploy.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg103 `
    -ResourceGroupLocation "Australia East" `
    -Environment PROD `
    -contributorGroupId f023a8ba-b533-4e07-8b08-a4294d7fb5c6 `
    -DataFactoryName mmg-aue-map-adf01-e1 `
    -keyVaultName mmg-aue-map-akv01-e1 `
    -factoryKeyName FACTORYCRYPTOKEY `
    -tempIPRequired $True

   

#>

param(
   [Parameter(Mandatory = $True)]
   [string]
   $Subscription,
     
   [Parameter(Mandatory = $True)]
   [string]
   $ResourceGroupName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $ResourceGroupLocation,
     
   [Parameter(Mandatory = $True)]
   [ValidateSet('DEV', 'PROD')]
   [string]
   $Environment,
     
   [Parameter(Mandatory = $True)]
   [string]
   $contributorGroupId,

   [string]
   $TemplateFilePath = "adf\$Environment.ARMTemplateForFactory.json",

   [string]
   $ParametersFilePath = "adf\$Environment.ARMTemplateParametersForFactory.json",
     
   [Parameter(Mandatory = $True)]
   [string]
   $DataFactoryName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $keyVaultName,
     
   [Parameter(Mandatory = $True)]
   [string]
   $factoryKeyName,

   [Parameter(Mandatory = $True)]
   [Boolean]
   $tempIPRequired

)

# Sign in
Write-Host "Logging in...";
Connect-AzAccount; 
Write-Host "Using parameters file $ParametersFilePath";


# Select subscription
Write-Host "Selecting subscription '$Subscription'";
Select-AzSubscription -Subscription $Subscription;

# Set developer permissions to create key vault keys

Write-Host "Assigning Key Vault Crypto Officer role on the key vault for the contributor group..."

New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Key Vault Crypto Officer" -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $ResourceGroupName

Read-Host -Prompt "Check that the Key Vault Crypto Officer role was assigned. Once confirmed, press any key to continue"

#Add local IP to the key vault

(Invoke-WebRequest ifconfig.me/ip).Content

if ($tempIPRequired) {

   $localPublicIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim() + "/32"
   $localPublicIP = "220.245.183.74"
   Add-AzKeyVaultNetworkRule -VaultName $keyVaultName -IpAddressRange $localPublicIP
   
   Start-Sleep -Seconds 10

}

# Apply CMK encryption for data factory - note this needs to happen before deploying any pipeline code.

Write-Host "Applying CMK encryption for data factory...";

# create the key
Add-AzKeyVaultKey `
-VaultName $keyVaultName `
-Name $factoryKeyName `
-Destination 'Software'

Set-AzKeyVaultKeyRotationPolicy -VaultName $keyVaultName `
-KeyName $factoryKeyName `
-ExpiresIn P720D  `
-KeyRotationLifetimeAction @{Action="Rotate";TimeAfterCreate="P700D"}

$vault = Get-AzKeyVault -VaultName $keyVaultName

Set-AzDataFactoryV2 -Name $DataFactoryName `
-ResourceGroupName $ResourceGroupName `
-Location $ResourceGroupLocation `
-EncryptionVaultBaseUrl $vault.VaultURI `
-EncryptionKeyName $factoryKeyName


Write-Host "Applied encryption to data factory";


# Start the deployment of initial pipeline code for NPE and DEV only 

if ($Environment -eq 'DEV') {
   Write-Host "Starting deployment of initial pipeline code...";

   New-AzResourceGroupDeployment -Name ADFDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterFile $ParametersFilePath

   Write-Host "Data factory pipeline code deployed.";

}

#Remove local IP from the key vault

if ($tempIPRequired) {

   Remove-AzKeyVaultNetworkRule -VaultName $keyVaultName -IpAddressRange $localPublicIP

}

