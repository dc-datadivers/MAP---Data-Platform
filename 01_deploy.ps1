<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys a Bicep template

 .EXAMPLE
    
    ./01_deploy.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg102 `
    -Environment DEV `
    -ResourceGroupLocation "Australia East" `
    -Tags @{"Application" = "Mergers and Acquistions Analytics Platform"; "BusinessOwner" = "MMG"; "Environment" = "DEV"} `
    -DatabaseType "Serverless" `
    -RegisterResourceProviders $False


    ./01_deploy.ps1 -Subscription 5b4ee21e-2989-47ef-af55-eb8ce9ad1d06 `
    -ResourceGroupName Mmgs1auaearg103 `
    -Environment PROD `
    -ResourceGroupLocation "Australia East" `
    -Tags @{"Application" = "Mergers and Acquistions Analytics Platform"; "BusinessOwner" = "MMG"; "Environment" = "PROD"} `
    -DatabaseType "Serverless" `
    -RegisterResourceProviders $False
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
    $ResourceGroupLocation,

    [Parameter(Mandatory = $True)]
    [hashtable]
    $Tags,

    [Parameter(Mandatory = $True)]
    [String]
    $DatabaseType,

    [Parameter(Mandatory = $True)]
    [Boolean]
    $RegisterResourceProviders,

    [string]
    $TemplateFilePath = "resourcedeployment\resources.bicep",

    [string]
    $ParametersFilePath = "parameters\$Environment.parameters.bicepparam",

    [string]
    $DWTemplateFilePath = "resourcedeployment\DW$DatabaseType.bicep",

    [string]
    $DWParametersFilePath = "parameters\$Environment.parametersDW$DatabaseType.bicepparam",

    [string]
    $BlobLogTemplateFilePath = "resourcedeployment\LifecycleManagement.bicep",

    [string]
    $BlobLogParametersFilePath = "parameters\$Environment.parametersLifecycleManagement.bicepparam"

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


# Register RPs

if ($RegisterResourceProviders) {

    $resourceProviders = @("microsoft.insights", "microsoft.keyvault", "microsoft.sql", "microsoft.storage", "microsoft.compute");
    if ($resourceProviders.length) {
        log("Registering resource providers")
        foreach ($resourceProvider in $resourceProviders) {
            RegisterRP($resourceProvider);
        }
    }

}


#Create or check for existing resource group

log("Resource group creation")

$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (!$resourceGroup) {
    if (!$ResourceGroupLocation) {
        Write-Host "Resource group '$ResourceGroupName' does not exist. To create a new resource group, please enter a location.";
        $resourceGroupLocation = Read-Host "ResourceGroupLocation";
    }
    Write-Host "Creating resource group '$ResourceGroupName' in location '$ResourceGroupLocation'";
    New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
}
else {
    Write-Host "Using existing resource group '$ResourceGroupName'";
}


#Set tags on the resource group

log("Setting tags")

Set-AzResourceGroup -Name $ResourceGroupName -Tag $Tags


# Start the deployment
log("Starting deployment...")

if (Test-Path $ParametersFilePath) {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterFile $ParametersFilePath;
}
else {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath;
}

log("Infrastructure deployed. Deploying DW database...")

if (Test-Path $ParametersFilePath) {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $DWTemplateFilePath -TemplateParameterFile $DWParametersFilePath;
}
else {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $DWTemplateFilePath;
}

log("Deploying blob lifecycle rules...")

if (Test-Path $ParametersFilePath) {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $BlobLogTemplateFilePath -TemplateParameterFile $BlobLogParametersFilePath;
}
else {
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $BlobLogTemplateFilePath;
}


log("Deployment complete")