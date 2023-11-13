[[_TOC_]]

#Introduction

The framework when implemented deployed generic pipelines for the following source types:

- Azure SQL Server
- SQL Server
- REST API
- Excel
- CSV

The following outlines the high-level steps to create a new source type.


##1. Create a new linked service

1. Under the **Manage** tab, click **Linked Services** and then click the **+ New** button. 
2. In the **New linked service** window, select the type of connector you want to add. 
3. Click **Continue**. In the following configuration screen enter a generic name, such as, `LS_AzureSQLDatabase`. Create parameters as required for the host, database, username and password. 

>Once the parameters are created, hover over each of the relevant config fields and click the blue **Add dynamic content** link. You can then select each of the parameters in turn to substitute the values. Ensure that the password is configured to use `Key Vault`.

4. To test the connection, a secret needs to be added to `Key Vault`. You can then click **Test connection** and fill in the parameter values to test that it works. 
5. Once tested, click **Create**.

##2. Create a new generic dataset

Each generic linked service needs to map to a generic dataset. To create the dataset:

1. Under the **Author** tab, click **Datasets / Sources** right click and select **New dataset**
2. Search for the source type, select it and click **Continue**
3. Give the dataset a generic name, such as `DS_AzureSQLDatabase`, select the linked service you created (e.g. `LS_AzureSQLDatabase`) and click **Create**
4. Create parameters in the dataset that match the parameters in the linked service
5. Add the parameters to the linked service properties by clicking the blue **Add dynamic content** link below each property
6. Save the dataset

##3. Create a new Source pipeline

1. Under the **Author** tab, go to the **3_Processing** folder and select one of the PL_Source... pipelines that most closely matches the one you need for the new source
2. Right-click on the selected `PL_Source...` pipeline and click **Clone**
3. Change the source dataset in the Copy activity to be the one you created as above
4. Ensure the parameter values are mapped correctly to the `item()` values as per below
5. Change the copy activity name if required, and any references to it in dependent activities
6. Save the pipeline

##4. Add the new source type to the `PL_GenericDBMaster` or `PL_GenericMaster` pipeline

1. Update the relevant Switch statement to include the new source
2. Save the pipeline

##5. Add new tables or files

Follow the instructions at [Add a new source system for an existing source type](/Maintain-Configuration/Add-a-new-source-system-for-an-existing-source-type)