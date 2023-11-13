[[_TOC_]]

# Introduction

There are a few **App Registrations** for the platform registered in Microsoft Entra ID. These are used in various parts of the infrastructure to enable authentication between components.

https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps



# Secrets in the Key Vault

The secrets for each app registration are recorded in the Azure Key Vault. The secrets have an expiry of 2 years. New secrets need to be generated and stored in the Key Vault prior to the expiry. Remember that there are three Key Vaults to update - DEV, TEST and PROD.


# Alert for expiration of secrets

A calendar alert should be set up to warn that the secrets need to be regenerated or certain parts of the platform will stop working.

# Create new secret and store in Key Vault

To create a new version of a secret click on **New client secret** and follow the prompts. Note that once the secret is created it will appear on the screen and should be copied immediately. If you navigate away from the screen, the secret cannot be seen again and would need to be regenerated.

Once the secret is created and copied, navigate to the relevant Key Vault and create a new secret version:

