[[_TOC_]]

# Introduction

App registrations in Microsoft Entra ID are required as a part of the framework to enable authentication between certain components.

To create app registrations you need the **Application developer** role in Microsoft Entra ID. At client site you may need someone else to create them on your behalf.

Once the registrations have been created, client secrets need to be generated and stored in Azure Key Vault


# Registrations

The following registrations need to be created. Note that the naming standards may need to change depending on the client. Secret names will need to be updated in the data factory if they change.


| **App Registration** |**Purpose**  |  **Application (client) ID - Secret Name**| **Client Secret - Secret Name** |
|--|--|--|--|
|  DatabricksApp|Used to allow Databricks to access the storage accounts  |AppReg-Databricks-AppId  | AppReg-Databricks-Secret |
| LogAnalyticsApp | Used for pipeline costs extraction and logging for ADF | AppReg-LogAnalytics-AppId | AppReg-LogAnalytics-Secret |

# Create an app registration

1. Go to Microsoft Entra ID and select **App Registrations** from the menu
1. Click **New Registration**
1. Give the app registration a name
1. Leave the default options and click **Register**
1. Make a note of the **Application (client) ID** as this needs to be added to the Key Vault as per above table
1. Create a client secret by clicking **Certificates and Secrets** in the menu. Click **New Client Secret** and give the secret a name (such as **DatabricksSecret**, and **LA_Secret**). Choose an expiry date based on client requirements (**24 months** for now)
1. Make a note of the secret value as this needs to be added to the Key Vault as per above table. _Once you navigate away from the screen the secret cannot be redisplayed and would need to be regenerated._

# Additional Key Vault entry for Tenant

Add additional Key Vault secret called **Tenant-Id** needs to be created with the client's tenant id. This can be found on the Azure AD overview page.

# Secrets for business systems and other sources

Secrets need to be created in the Key Vault for all of the references in `CTL.SourceEnvironments`.

# Note about secret expiration

Key Vault secrets should be set to expire on a regular basis, e.g. yearly or two-yearly. This applies to any value that can be changed, such as an app registration secret or service account password.

There is currently no notification system for expiring secrets. Manual reminders need to be configured for now, and a backlog task has been created to automate notifications using PowerShell runbooks.

#Utility PowerShell script for copying secrets

There is a script in the platform repo called **99_copySecrets.ps1** that can be used to copy secrets from one key vault to another. This script is handy for quickly generating secrets in different key vaults. There is a base key vault in the tenant called **MMG-AUE-DAP-AKV-SHARED** which stores all of the secrets for the reference platform. These can be quickly copied to new key vaults as required.

Note that your current IP needs to be registered on both the source and target key vaults. This can be done automatically using the `$tempIPRequired` parameter.
 

