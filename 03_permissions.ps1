<#
 .SYNOPSIS
    Set permissions on resource group and other resources. Requires elevated permissions in Azure (Owner or User Access Administrator).

.EXAMPLE

        
    ./03_permissions.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg102 `
    -Environment DEV `
    -contributorGroupId f023a8ba-b533-4e07-8b08-a4294d7fb5c6 `
    -bronzeName mmgauemapbronzestre3 `
    -silverName mmgauemapsilveradle3 `
    -auditName mmgauemapauditstre3 `
    -keyVaultName mmg-aue-map-akv01-e3 `
    -sqlName mmg-aue-map-sqs01-e3  



    ./03_permissions.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg103 `
    -Environment PROD `
    -contributorGroupId f023a8ba-b533-4e07-8b08-a4294d7fb5c6 `
    -bronzeName mmgauemapbronzestre1 `
    -silverName mmgauemapsilveradle1 `
    -auditName mmgauemapauditstre1 `
    -keyVaultName mmg-aue-map-akv01-e1 `
    -sqlName mmg-aue-map-sqs01-e1  


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
    $sqlName

 
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

# Set developer permissions on resource group. Note if using an existing resource group, you might need to comment out any permissions already applied.

log("Set permissions")

 New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Contributor" -ResourceGroupName $ResourceGroupName
 New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Cost Management Reader" -ResourceGroupName $ResourceGroupName

Write-Host "Developer permissions applied to resource group '$ResourceGroupName'";

# Set developer permissions on storage accounts

 New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Storage Blob Data Contributor" -ResourceName $bronzeName -ResourceType Microsoft.Storage/storageAccounts -ResourceGroupName $ResourceGroupName
 New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Storage Blob Data Contributor" -ResourceName $silverName -ResourceType Microsoft.Storage/storageAccounts -ResourceGroupName $ResourceGroupName
 

 New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Storage Blob Data Contributor" -ResourceName $auditName -ResourceType Microsoft.Storage/storageAccounts -ResourceGroupName $ResourceGroupName

Write-Host "Developer permissions applied to storage accounts.";

# Set developer permissions on key vault

New-AzRoleAssignment -ObjectId $contributorGroupId -RoleDefinitionName "Key Vault Secrets Officer" -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $ResourceGroupName

Write-Host "Developer permissions applied to key vault.";


# Get service principal ids for storage and sql

$bronzeServicePrincipal = Get-AzADServicePrincipal -DisplayName $bronzeName
$bronzeServicePrincipalId = $bronzeServicePrincipal.Id

$silverServicePrincipal = Get-AzADServicePrincipal -DisplayName $silverName
$silverServicePrincipalId = $silverServicePrincipal.Id
$auditServicePrincipal = Get-AzADServicePrincipal -DisplayName $auditName
$auditServicePrincipalId = $auditServicePrincipal.Id

$sqlServicePrincipal = Get-AzADServicePrincipal -DisplayName $sqlName
$sqlServicePrincipalId = $sqlServicePrincipal.Id


# Set application permissions on key vault

New-AzRoleAssignment -ObjectId $bronzeServicePrincipalId -RoleDefinitionName "Key Vault Crypto User" -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $ResourceGroupName
New-AzRoleAssignment -ObjectId $silverServicePrincipalId -RoleDefinitionName "Key Vault Crypto User" -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $ResourceGroupName

New-AzRoleAssignment -ObjectId $auditServicePrincipalId -RoleDefinitionName "Key Vault Crypto User" -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $ResourceGroupName
New-AzRoleAssignment -ObjectId $sqlServicePrincipalId -RoleDefinitionName "Key Vault Crypto User" -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $ResourceGroupName


Write-Host "Application permissions applied to key vault.";


