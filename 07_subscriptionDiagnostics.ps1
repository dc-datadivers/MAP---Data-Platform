<#
 .SYNOPSIS
    Deploys a template to Azure for subscription diagnostics.

    

 .DESCRIPTION
    Deploys a Bicep template

 .EXAMPLE
    ***WHEN DOING A TEST DEPLOYMENT PLEASE DO NOT RUN THIS SCRIPT.**
    
     ./08_subscriptionDiagnostics.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -Environment PROD
#>

param(
    [Parameter(Mandatory = $True)]
    [string]
    $Subscription,

    [Parameter(Mandatory = $True)]
    [ValidateSet('PROD')]
    [string]
    $Environment,

    [string]
    $TemplateFilePath = "resourcedeployment\SubscriptionDiagnostics.bicep",

    [string]
    $ParametersFilePath = "parameters\$Environment.parametersSubscriptionDiagnostics.bicepparam"
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
    New-AzSubscriptionDeployment -TemplateFile $TemplateFilePath -TemplateParameterFile $ParametersFilePath;
}
else {
    New-AzSubscriptionDeployment -TemplateFile $TemplateFilePath;
}

log("Subscription diagnostics deployed.")

