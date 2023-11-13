[[_TOC_]]

# Set up authentication between Databricks and ADLS Gen 2

In order for Databricks to connect to the silver data lake, an app registration needs to be created as per a previous step.

# Add the app registration to the storage account

1. In the Azure portal, navigate to the **silver** storage account
1. Select **Access Control (IAM)**
1. Select **Add** then **Add role assignment**
1. Assign the **Storage Blob Data Contributor** role to the **DatabricksApp** app registration

# Ensure that the Data Factory has access to Databricks

Under **Access Control (IAM)** for the Databricks workspace, ensure that the Azure Data Factory has **Contributor** access.

# Copy notebooks into target environment

Sample notebooks are found in the **databricks\samples** folder of platform code repository. The notebooks should be imported into the **Shared/samples** section of the workspace.

# Test the notebooks

The sample notebooks are mostly self-documenting. Each notebook needs to be attached to the cluster before it is run. 

The sample notebooks contain useful functions for connecting to the data lake, which can be reused in client notebooks. Notebooks can also be triggered from Azure Data Factory (see Pipeline Run Costs).

Note that when storage mount points are created, they are persisted across sessions. You may need to detach any previously attached mount points before running certain cells in the notebooks.

