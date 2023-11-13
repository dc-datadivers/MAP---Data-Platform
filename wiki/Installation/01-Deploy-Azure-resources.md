[[_TOC_]]

# Git repository

The [OpenWaterCloud](https://dev.azure.com/data-divers/Open%20Water%20Cloud/_git/OpenWaterCloud) repository stores the code required to deploy the solution. The code is managed using Visual Studio Code, which is linked to the Git repository in Azure DevOps.

For a tutorial on how to set this up, see this link: https://azuredevopslabs.com/labs/azuredevops/git/

When deploying to a new client, a copy of the codebase should be made into a new repository in the Data Divers environment (see below [How to work with a specific version of MMG.](https://dev.azure.com/data-divers/Open%20Water%20Cloud/_wiki/wikis/OpenWaterCloudWiki/9/01-Deploy-Azure-resources?anchor=how-to-work-with-a-specific-version-of-mmg) The code can then be customised and the deployments tested using the client's naming standards. 

Note: do not use the exact resource names required at client site as this might reserve a name that cannot be used again. Often using a different environment identifier such as SBX (sandbox) or NPE (non-production environment) will be enough to make the names unique and still test the client's naming standards against Azure limitations (such as length, capitalisation etc.)

At client site, branch protection policies should be implemented on the platform repository to prevent accidental changes to the codebase.

## How to work with a specific version of MMG

Periodically, new versions of MMG are released. To view the release notes for each version, see [00 Release Notes](/Installation/00-Release-Notes).

Each release is tagged with a version number in the Git repo. You can view the tags in DevOps:

![image.png](/.attachments/image-14b48548-9b26-4cab-a1a9-7f7f2492eacd.png)

When doing any test deployment, or copying the code for use at client site, it is recommended to check out a particular release. This is to make sure that incomplete releases are not used as a baseline for a new client installation.

To check out a release, first clone the MMG repo to your local machine. Then run

`git checkout tags/vx.x` 

as per the below:

![image.png](/.attachments/image-eb0134f2-9835-4237-8dc7-e0f562d16b7d.png)

Your VS Code codebase will then be at the point where that release was tagged. You can then copy the code into a new repo, either in the DD DevOps or at client site. You are then baselined at the specific version that you chose.

Note: To flip back to the main branch in your OpenWaterCloud local repo, run 

`git checkout main`

# Prerequisites

Install and/or update with the latest version for the following:

- PowerShell (https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
- Latest Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- VS Code (https://code.visualstudio.com/download)
- Bicep CLI (https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- Git (https://git-scm.com/downloads)
- In PowerShell run the following:

```
Install-Module -Name Az -AllowClobber -Scope CurrentUser
Install-Module -Name AzureADPreview -AllowClobber -Scope CurrentUser
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

- A **Self Hosted Integration Runtime (SHIR)** server needs to be provisioned as a VM in the local network. Recommended specs are 16GB RAM, 8 vCores, Windows Server 2019 (or newer).
- The SHIR needs the latest version of the **Microsoft build of the OpenJDK** installed. Ensure this installation also sets JAVA_HOME https://docs.microsoft.com/en-au/java/openjdk/download
- The Java memory on the SHIR should also be set to use the maximum memory on the server. Add the following System environment variable: `_JAVA_OPTIONS` with the value `-Xms256m -Xmx16g`
- Ensure that .Net Framework 4.7.2 or higher is installed on the SHIR server
- Run the following script in an administrator CMD window to enable the reading of files from the SHIR file system

```
cd "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\"
.\dmgcmd.exe -DisableLocalFolderPathValidation
```


# Setup

1. Clone the Git repository to your local machine.
1. Ensure that you have all the required parameters from the client. Use the **Client Parameter Questionnaire.xlsx** file in the **\parameters** directory of the repository to collect these. Parameters need to align with the client's naming standards, and in some instances must be unique across Azure. Parameters need to be updated in the two **bicepparam** files in the **\parameters** directory as well as the JSON file in the **\datafactory** directory.
1. Open a PowerShell session as admin and cd to the repository directory. Alternatively, use the PowerShell terminal in Visual Studio.
1. Execute the following steps in sequence.

# Deploy Azure resources
## 01_deploy.ps1

Execute the command at the top of the file for the environment you want to deploy, by copying it and pasting it into the PowerShell terminal. Prior to running the command, ensure all the parameter values have been changed to reflect the subscription you are deploying into.

Note that **NPE** stands for **Non-Production Environment** and is only used for testing new code. This environment is not normally deployed at client site.

There is also a parameter in this script (and some others) that toggles Databricks deployment on or off. Make sure to set this to `$False` for those deployments that do not require Databricks.

![image.png](/.attachments/image-4647e63e-9f50-4714-9832-8c0ba47674fa.png)

You will be prompted to log into Azure via a web browser. Note that in some of the installation scripts you may be asked to authenticate multiple times (Azure PowerShell and Azure CLI).

The script will trigger the deployment of Bicep templates for the following:
- Base infrastructure
- Database
- Blob lifecycle rules

For the database deployment, use **Serverless** for lower costs and if the database is expected to have lengthy periods of downtime (e.g., data is loaded daily). Choose **Hyperscale** for 24/7 operation and higher intensity workloads.

Registering the resource providers does not need to be done at Data Divers. However, this is likely required at client site, so be sure to set the parameter appropriately.

Wait for the deployment to complete. You can monitor the deployment using the Deployments screen for the resource group.

![image.png](/.attachments/image-86ed7300-662c-42c0-9596-67123c6c6d4c.png)

Once all the deployments are complete navigate to the new resource group. 12 resources will have been created.

![image.png](/.attachments/image-b5fbaf6b-9ed1-4bc3-b379-a78ca327daf1.png)


## Create Self Hosted Integration Runtime (SHIR) - dedicated version

An Integration Runtime called **integrationRuntime01** needs to be created on a local machine. At client site, this will be a local VM. 

1. Log into the local machine that will host the integration runtime.
2. Log into the Azure Portal using Chrome or Edge.
3. Navigate to the Azure Data Factory resource in the newly created resource group and launch Azure Data Factory
4. Click the **Manage** icon in the left-hand toolbar.
5. Click **Integration Runtimes**, then **New** then **Self Hosted**.
6. When prompted for the network environment, select **Self Hosted**.
7. Change the name of the IR from integrationRuntime1 to **integrationRuntime01**.
8. Hit **Create**.
9. Under **Manual setup**, download and install the Integration Runtime on the local machine. Note that there will be two keys displayed on this page; one of these is required in the next step.
10. Once the installation is complete the software will ask for a key. Enter one of the keys found on the above page to link the SHIR with the data factory. Hit **Register**, then **Finish**.
11. Verify that the SHIR was created and is in the **Running** state in the Data Factory UI.
12. Review the **number of concurrent jobs** setting by editing the SHIR and selecting the Nodes setting. This is dependent on the size of the VM being used to host the SHIR.

### Note on the shared SHIR

The MMG platform code by default uses a shared SHIR. The shared data factory is called MMG-AUE-DAP-ADF-SHARED and it is located in the [MMG-AUE-DAP-RG-SHARED](https://portal.azure.com/#@journeyone.com.au/resource/subscriptions/5b4ee21e-2989-47ef-af55-eb8ce9ad1d06/resourceGroups/MMG-AUE-DAP-RG-SHARED/overview) resource group.

If you want to use the shared SHIR in Data Divers tenant you will need to assign permissions prior to running the **02_adfDeploy.ps1** script. Open the data factory **MMG-AUE-DAP-ADF-SHARED** and navigate to the integrationRuntime01. Go to the Sharing tab and add the new data factory.

![image.png](/.attachments/image-3657fded-ae08-4c3a-9648-edd2eb327f52.png)

To use a standalone SHIR rather than the shared SHIR the ADF code needs to be changed:

- Remove the parameter called **integrationRuntime01_properties_typeProperties_linkedInfo_resourceId** from **DEV.ARMTemplateParametersForFactory.json**
- Remove the parameter called **integrationRuntime01_properties_typeProperties_linkedInfo_resourceId** from the top of the **DEV.ARMTemplateForFactory.json** file
- Change the following code in **DEV.ARMTemplateForFactory.json**

                
```
"typeProperties": {
                    "linkedInfo": {
                        "resourceId": "[parameters('integrationRuntime01_properties_typeProperties_linkedInfo_resourceId')]",
                        "authorizationType": "Rbac"
                    }
                }
```


to be

`"typeProperties": {}`

### Using a clustered SHIR

To setup clustered nodes for SHIR, refer to steps provided in https://www.techtalkcorner.com/self-hosted-integration-runtime-cluster/

# Deploy Azure Data Factory code
## 02_adfDeploy.ps1

This step deploys the pipelines, datasets and linked services into the Data Factory.

The **Log Analytics workspace URL** needs to be entered in the placeholder parameter. The format of this is https://api.loganalytics.io/v1/workspaces/xxxxxxxxxxxxxxxx/ where the placeholder is substituted with the workspace ID (found under **Properties** in the log analytics workspace).

Execute the command at the top of the file for the environment you want to deploy, by copying it and pasting it into the PowerShell terminal. Prior to running the command, ensure all the parameter values have been changed to reflect the subscription you are deploying into.

Note that during the script you will be asked to confirm details of permissions. Also, you will be asked to confirm about overwriting an existing data factory, choose Y for this warning.

# Set permissions
## 03_permissions.ps1

This script sets permissions on resource group and other resources. Requires elevated permissions in Azure (Owner or User Access Administrator).

Run the script in the same way as in previous steps.

Note that the **databricksEnterpriseApplicationObjectId** parameter is static at the tenant level. A Databricks workspace may need to be created manually then deleted to create the Enterprise Application (TBC). The below screenshot shows where the Object Id can be found in Microsoft Entra ID.

![image.png](/.attachments/image-b089adc7-bb7c-4c4c-b225-d9b1d2aebf96.png)

# Apply encryption to resources
## 04_crypto.ps1

This script applies encryption using **Customer Managed Key** to the storage accounts, data factory, database and Databricks workspace. The CMKs are stored in the Key Vault. Purge protection and soft delete is enabled on the Key Vault to protect the keys from being accidentally deleted.

_Note that the scripts progressively create objects, and sometimes a value might need to be provided from the results of a previous step / script._

An example is **databricksStorageObjectId** parameter. The Databricks storage account was established after the **03_permissions.ps1** script was run. To get this value:

- Go to the Databricks managed resource group (e.g., **MMG-AUE-DAP-ADB-MRG-DEV**)
- Copy the name of the storage account (e.g., **dbstoragesf77iobv5kmvm**)
- Go to Microsoft Entra ID and search for the storage account
- Find the Enterprise Application related to the storage account, and copy its Object ID
- Paste this value into the placeholder in **04_crypto.ps1**

Run the script in the same way as in previous steps. Note that if you have a different public IP to the one listed in the parameters, then set the **tempIPRequired** parameter to **$True**.

The script will pause at the SQL database. Select **Y** when asked if you want to proceed.

The script will again pause and ask for the Object ID of the Disk Encryption Set that was just created. To get this value:

- Go to the Databricks managed resource group (e.g., **MMG-AUE-DAP-ADB-MRG-DEV**)
- Copy the name of the disk encryption set (e.g., **dbdiskencryptionsetef091f135045d**)
- Go to Microsoft Entra ID and search for the disk encryption set
- Find the Enterprise Application related to the disk encryption set, and copy its Object ID
- Paste this value into the terminal


# Configure diagnostics
## 05_diagnostics.ps1

_Note: If reinstalling a previous environment, you will need to check Azure Monitor to ensure no old diagnostic settings remain for the resource group._

This script configures the diagnostic settings. This enables key audit events to be logged in Log Analytics and audit storage. Resources with diagnostics enabled are:

- Azure SQL Database
- Key Vault
- Data Factory
- Databricks workspace
- Network Security Group for Databricks (including Flow Logs)

Retention of logs in audit storage is set to 90 days using Lifecycle Management.

Run the script in the same way as in previous steps.

# Configure locks
## 06_locks.ps1

This script configures a resource group delete lock. This is to protect a resource group and the resources within it from accidental deletion. Typically, this will only be enabled for Production.

Run the script in the same way as in previous steps.

# Configure Activity Log alerts
## 07_activityLogAlerts.ps1

_Note: Do not run this script when testing in Data Divers tenant._

This script deploys alerts for specific events that occur within Azure. The scope is set at a subscription level. The script creates resources in a resource group (typically PROD) that define alerts for the following:

- Create / Delete Policy Assignment
- Create / Update / Delete NSGs
- Create / Update / Delete Security Solution
- Create / Update / Delete SQL Server Firewall Rule
- Create / Update / Delete Update Public IP Address Rule

An action group is created as a part of this script. Set the distribution list to Azure admins who want to keep track of unusual activity within the Azure environment.

Only deploy this once per subscription that you want to monitor (typically this is just Production).

Run the script in the same way as in previous steps.

# Configure subscription level diagnostics
## 08_subscriptionDiagnostics.ps1

_Note: Do not run this script when testing in Data Divers tenant._

This step configures diagnostics at the subscription level. Only deploy this once per subscription that you want to monitor (typically this is just Production).

Run the script in the same way as in previous steps.


# Configure Databricks to work with Key Vault and ADF

To enable Databricks to work with Key Vault, a secret scope needs to be created to allow Databricks to read secrets. In addition, a Databricks cluster needs to be created and the linked service in Azure Data Factory updated to point to the new cluster.

## Create secret scope

_Note: there is currently an issue with using the RBAC model Key Vault and Databricks secret scopes. This issue has been logged under task_ #81

1. Open the Azure Portal using Chrome or Edge
1. Navigate to the resource group 
1. Select the Azure Databricks resource
1. Select **Launch Workspace**
1. Generate a secret scope that links Databricks to Key Vault by navigating to https://xxxxxxxx.azuredatabricks.net/#secrets/createScope --adjust for DB workspace URL
1. Ensure you select the correct Databricks workspace if prompted
1. Call the scope name **keyVault**
1. Change **Manage Principal** to **All Users**
1. Under **DNS Name** enter the Azure Key Vault (**Vault URI** in Key Vault Properties page)
1. Under the **Resource ID** enter the Azure Key Vault (**Resource ID** in Key Vault Properties page)
1. Hit **Create** and verify that the scope was added. Then click **OK**. 


## Create Databricks cluster

1. Create the Databricks cluster by clicking **Compute** in the left-hand menu of the Databricks UI
1. Click **Create Cluster**
1. Under Cluster Name enter **databricks-cluster-01**
1. Set Access Mode to be **No isolation shared**
1. Change the value for Terminate after x minutes of activity to **30**
1. Leave all other options as their defaults
1. Click **Create Cluster**
1. The cluster will appear in the below screen and have a state of **Pending**.
1. After some time, the cluster will appear as **Running**.
1. Once the cluster is created, be sure to **Pin** the cluster by clicking the pin icon next to the cluster name (prevents cluster being auto dropped).
1. Go to the key vault and add the Databricks app registration as a 

# Configure SQL Server features

1. Under the SQL Server, select **Features** then **Microsoft Defender for SQL**
2. Under Microsoft Defender for SQL: Enabled at the subscription-level select **Configure**
3. Under **Vulnerability Assessment Settings** click **Enable**
4. Click **Save**. Wait for the process to finish before moving on.
5. Click **Enable Auditing for better threats investigation experience**
6. Enable the **Storage** destination and choose the appropriate resources, and for the **Storage Authentication Type**, choose **Managed Identity**. You will receive a message about the audit storage being behind a firewall. Accept this dialog by clicking OK.
7. Enable the Log Analytics destination

![image.png](/.attachments/image-63bb2e79-2b9a-4dd0-a715-d5b96a739643.png)

8. Hit **Save**. This step might take some time to complete.
9. All features except for failover groups should now have a green icon on the **Features** page

![image.png](/.attachments/image-9afd31a2-818e-401d-ae77-f2bc01169795.png)

# System time zone

Open Water Cloud can be run in any time zone. Operations on Azure SQL are all in UTC by default. The framework is preset to run in **W. Australia Standard Time**. This ensures that all operational timestamps for the framework are recorded in WA time.

Time zones are set in the control database and in an ADF global parameter. These can be changed to **'UTC'** for clients wanting to run the framework with all generated timestamps in UTC. Of course, any other time zone may be used, just ensure that the control database and ADF are aligned.

## Control database

```
SELECT * 
FROM CTL.SystemTimezone

--W. Australia Standard Time

--Note that a list of supported time zones can be found here: 

SELECT * 
FROM sys.time_zone_info 
ORDER BY NAME
```


## Azure Data Factory global parameter

![image.png](/.attachments/image-e229ade2-e0fe-4bce-bb00-ae5e93acd766.png)
