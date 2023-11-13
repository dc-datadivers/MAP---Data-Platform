<# OPTIONAL UTILITY SCRIPT FOR COPYING SECRETS ACROSS VAULTS

 .EXAMPLE


 # copy DEV to PROD
    ./99_copySecrets.ps1 -SourceKeyVaultName mmg-aue-map-akv01-e3 `
    -DestKeyVaultName mmg-aue-map-akv01-e1 `
    -tempIPRequired $True

#>

param(

 [Parameter(Mandatory=$True)]
 [string]
 $SourceKeyVaultName,

 [Parameter(Mandatory=$True)]
 [string]
 $DestKeyVaultName,

 [Parameter(Mandatory=$True)]
 [boolean]
 $tempIPRequired

 )


 $RootFolder = $PSScriptRoot
 . "$RootFolder/Functions.ps1"
 
 $AzModuleVersion = "8.0.0"
 
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

#Add temporary IP to source and destination key vaults

if ($tempIPRequired) {

   $localPublicIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim() + "/32"
   Add-AzKeyVaultNetworkRule -VaultName $SourceKeyVaultName -IpAddressRange $localPublicIP
   Add-AzKeyVaultNetworkRule -VaultName $DestKeyVaultName -IpAddressRange $localPublicIP

   Start-Sleep -Seconds 10
   
}



#copy the Azure Key Vault secrets from source to target environment

$secretNames = (Get-AzKeyVaultSecret -VaultName $SourceKeyVaultName).Name
$secretNames.foreach{
    Set-AzKeyVaultSecret -VaultName $DestKeyVaultName -Name $_ `
        -SecretValue (Get-AzKeyVaultSecret -VaultName $SourceKeyVaultName -Name $_).SecretValue `
        -Expires (Get-AzKeyVaultSecret -VaultName $SourceKeyVaultName -Name $_).Expires
}

Write-Host "Copied secrets from '$SourceKeyVaultName' to '$DestKeyVaultName'"; 


#Remove temporary IP from source and destnation key vaults

if ($tempIPRequired) {

   Remove-AzKeyVaultNetworkRule -VaultName $SourceKeyVaultName -IpAddressRange $localPublicIP
   Remove-AzKeyVaultNetworkRule -VaultName $DestKeyVaultName -IpAddressRange $localPublicIP
   
}
