<#
 .SYNOPSIS
    Applied Customer Managed Key encryption to selected resources.

.EXAMPLE
    
    ./04_crypto.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg102 `
    -Environment DEV `
    -contributorGroupId f023a8ba-b533-4e07-8b08-a4294d7fb5c6 `
    -bronzeName mmgauemapbronzestre3 `
    -silverName mmgauemapsilveradle3 `
    -auditName mmgauemapauditstre3 `
    -keyVaultName mmg-aue-map-akv01-e3 `
    -sqlName mmg-aue-map-sqs01-e3  `
    -sqlKeyName SQLCRYPTOKEY `
    -storageKeyName STORAGECRYPTOKEY `
    -tempIPRequired $True 


    ./04_crypto.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg103 `
    -Environment PROD `
    -contributorGroupId f023a8ba-b533-4e07-8b08-a4294d7fb5c6 `
    -bronzeName mmgauemapbronzestre1 `
    -silverName mmgauemapsilveradle1 `
    -auditName mmgauemapauditstre1 `
    -keyVaultName mmg-aue-map-akv01-e1 `
    -sqlName mmg-aue-map-sqs01-e1  `
    -sqlKeyName SQLCRYPTOKEY `
    -storageKeyName STORAGECRYPTOKEY `
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
    [ValidateSet('DEV', 'PROD')]
    [string]
    $Environment,

    [Parameter(Mandatory = $True)]
    [string]
    $contributorGroupId,

    [Parameter(Mandatory = $True)]
    [string]
    $bronzeName,

    [Parameter(Mandatory = $True)]
    [string]
    $silverName,

    [Parameter(Mandatory = $True)]
    [string]
    $auditName,

    [Parameter(Mandatory = $True)]
    [string]
    $keyVaultName,

    [Parameter(Mandatory = $True)]
    [string]
    $sqlName,

    [Parameter(Mandatory = $True)]
    [string]
    $sqlKeyName,

    [Parameter(Mandatory = $True)]
    [string]
    $storageKeyName,

    [Parameter(Mandatory = $True)]
    [Boolean]
    $tempIPRequired
 
)

$RootFolder = $PSScriptRoot
. "$RootFolder/Functions.ps1"

$AzModuleVersion = "2.0.0"


#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# Verify that the Az module is installed 
if (!(Get-InstalledModule -Name Az -MinimumVersion $AzModuleVersion -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires to have Az Module version $AzModuleVersion installed..
It was not found, please install from: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps"
    exit
} 

# sign in
Write-Host "Logging in...";
Connect-AzAccount; 

# select subscription
log("Selecting subscription '$Subscription'")
Select-AzSubscription -Subscription $Subscription;

#Add local IP to the key vault

if ($tempIPRequired) {

    $localPublicIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim() + "/32"
    $localPublicIP = "220.245.183.74"
    Add-AzKeyVaultNetworkRule -VaultName $keyVaultName -IpAddressRange $localPublicIP
    
    Start-Sleep -Seconds 10
}

#Get the key vault URI

$vault = Get-AzKeyVault -VaultName $keyVaultName
$vaultURI = $vault.VaultURI

# Apply CMK encryption for storage

Write-Host "Applying encryption to storage accounts";

# create the key
$stkey = Add-AzKeyVaultKey `
    -VaultName $keyVaultName `
    -Name $storageKeyName `
    -Destination 'Software'

Set-AzKeyVaultKeyRotationPolicy -VaultName $keyVaultName `
    -KeyName $storageKeyName `
    -ExpiresIn P720D  `
    -KeyRotationLifetimeAction @{Action="Rotate";TimeAfterCreate="P700D"}

Set-AzStorageAccount -Name $bronzeName `
    -ResourceGroupName $ResourceGroupName `
    -KeyvaultEncryption `
    -KeyName $stkey.Name `
    -KeyVersion "" `
    -KeyVaultUri $vaultURI

Set-AzStorageAccount -Name $silverName `
    -ResourceGroupName $ResourceGroupName `
    -KeyvaultEncryption `
    -KeyName $stkey.Name `
    -KeyVersion "" `
    -KeyVaultUri $vaultURI

Set-AzStorageAccount -Name $auditName `
    -ResourceGroupName $ResourceGroupName `
    -KeyvaultEncryption `
    -KeyName $stkey.Name `
    -KeyVersion "" `
    -KeyVaultUri $vaultURI


Write-Host "Applied encryption to storage accounts";



# Apply CMK encryption for Azure SQL

Write-Host "Applying encryption to Azure SQL";

# create the key
$sqlkey = Add-AzKeyVaultKey `
    -VaultName $keyVaultName `
    -Name $sqlKeyName `
    -Destination 'Software'

Set-AzKeyVaultKeyRotationPolicy -VaultName $keyVaultName `
    -KeyName $sqlKeyName `
    -ExpiresIn P720D  `
    -KeyRotationLifetimeAction @{Action="Rotate";TimeAfterCreate="P700D"}

# add the key to the server
Add-AzSqlServerKeyVaultKey -ServerName $sqlName `
    -ResourceGroupName $ResourceGroupName `
    -KeyId $sqlkey.Id

# set the key as the TDE protector for all resources under the server
Set-AzSqlServerTransparentDataEncryptionProtector -ServerName $sqlName `
    -ResourceGroupName $ResourceGroupName `
    -Type AzureKeyVault `
    -KeyId $sqlkey.Id `
    -AutoRotationEnabled $true

Write-Host "Applied encryption to Azure SQL";




#Remove local IP from the key vault

if ($tempIPRequired) {

    Remove-AzKeyVaultNetworkRule -VaultName $keyVaultName -IpAddressRange $localPublicIP

}
    

