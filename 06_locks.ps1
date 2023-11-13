<#
 .SYNOPSIS
    Configures a delete lock on a resource group. Note that lower environments may not need to be locked (i.e. only production might need to be locked).

 .EXAMPLE

    
    ./06_locks.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg102 `
    -Environment DEV


    ./06_locks.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg103 `
    -Environment PROD


#>

param(
   [Parameter(Mandatory = $True)]
   [string]
   $Subscription,
     
   [Parameter(Mandatory = $True)]
   [string]
   $ResourceGroupName,
     
   [Parameter(Mandatory = $True)]
   [ValidateSet('DEV','PROD')]
   [string]
   $Environment

)

# Sign in
Write-Host "Logging in to Azure CLI...";
az login; 

# Select subscription
Write-Host "Selecting subscription '$Subscription'";
Select-AzSubscription -Subscription $Subscription;

# Configure resource group lock
Write-Host "Configuring resource group delete lock...";

az lock create --name RGDelete --resource-group $ResourceGroupName --lock-type CanNotDelete --notes "Don't delete this resource group"

Write-Host "Configuration of resource group delete lock complete.";


