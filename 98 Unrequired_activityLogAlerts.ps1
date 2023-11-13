<#
 .SYNOPSIS
    Deploys a template to Azure for activity log alerts. The resource group should be pre-existing.

    

 .DESCRIPTION
    Deploys a Bicep template

 .EXAMPLE
    ***WHEN DOING A TEST DEPLOYMENT PLEASE DO NOT RUN THIS SCRIPT.**

     ./07_activityLogAlerts.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName MMG-AUE-DAP-RG-SHARED `
    -Environment PROD `
    -ResourceGroupLocation "Australia East" `
    -Tags @{"Application" = "Mergers and Acquistions Analytics Platform"; "BusinessOwner" = "MMG"; "Environment" = "PROD"}
#>

param(
    [Parameter(Mandatory = $True)]
    [string]
    $Subscription,

    [Parameter(Mandatory = $True)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory = $True)]
    [ValidateSet('PROD')]
    [string]
    $Environment,

    [Parameter(Mandatory = $True)]
    [string]
    $ResourceGroupLocation,

    [Parameter(Mandatory = $True)]
    [hashtable]
    $Tags,

    [string]
    $TemplateFilePath = "resourcedeployment\ActivityLogAlerts.bicep",

    [string]
    $ParametersFilePath = "parameters\$Environment.parametersActivityLogAlerts.bicepparam"
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
    log("This script requires to have Az Module version $AzModuleVersion installed..
    It was not found, please install from: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps")
    exit
} 


# sign in
Write-Host "Logging in...";
Connect-AzAccount; 
Write-Host "Using parameters file $ParametersFilePath";


# select subscription
log("Selecting subscription '$Subscription'")
Select-AzSubscription -Subscription $Subscription;



# Start the deployment
log("Starting deployment...")

if (Test-Path $ParametersFilePath) {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterFile $ParametersFilePath;
}
else {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath;
}

log("Activity log alerts deployed.")

