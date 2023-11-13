[[_TOC_]]

# Introduction

Pipelines and configuration tables have been created to enable Power BI datasets to be refreshed from ADF pipelines. This means that Power BI datasets can be refreshed as a part of the overall orchestration of the data loads.

Note that in prior versions of MMG, service principal authentication was used. As of version 1.2, authentication is done using managed identity.

The following two references were used to build the solution:

https://datasavvy.me/2020/07/09/refreshing-a-power-bi-dataset-in-azure-data-factory/

https://www.moderndata.ai/2019/05/powerbi-dataset-refresh-using-adf/

# High level steps

1. Create a Microsoft Entra ID Security Group and add the managed identities of the data factories used (dev / test / prod) to the group
1. In the Power BI tenant settings, register the above group for API access "Allow service principals to use Power BI APIs"
1. Create a Power BI App Workspace (only V2 is supported)
1. Add the data factory managed identities as Members to the workspace

![image.png](/.attachments/image-67bd872e-32fd-46c0-9a08-dff8e03d1779.png)



# ADF configuration tables

The following shows the config and logging tables with some sample entries. 

**GroupName** is a parameter in the pipeline and is used to group together related datasets.

```
INSERT CTL.PBIRefreshConfig
(
    isRunnable,
    GroupName,
    PBIWorkspaceId,
    PBIWorkspaceName,
    PBIDatasetId,
    PBIDatasetName,
    [Sequence]
)
VALUES
( 1, 'Test Group', 'da700587-d06e-4641-9372-0c415dbb8957', 'TST - BI Sandpit', '04d569dc-5da8-4a03-b47e-b000cf1e2d90', 'Azure SQL Test', 1 ), 
( 1, 'Test Group', 'da700587-d06e-4641-9372-0c415dbb8957', 'TST - BI Sandpit', 'a27e5414-7aed-4326-9387-150a48652063', 'DS - Plant Costs', 2 ), 
( 1, 'Test Group', 'da700587-d06e-4641-9372-0c415dbb8957', 'TST - BI Sandpit', 'e4ec1812-f233-413f-af50-d31c7fc677b2', 'DS - Purchase Requisitions', 3 )

SELECT * FROM CTL.PBIRefreshConfig


EXEC CTL.getPBIRefreshes @groupName = 'Test Group'

SELECT * FROM CTL.PBIRefreshLog --for logging of refreshes
```
The **PBIWorkspaceId** and **PBIDatasetId** for your workspace and dataset can be retrieved via the Power BI Service. Have a look at the dataset URL - the first UID is for the workspace and the secod is for the dataset.


# ADF pipelines

Two pipelines support the solution. The first is called **PL_RefreshPBIDataset** and was adapted from the above links. It calls the Power BI API for a particular dataset in a workspace.

![image.png](/.attachments/image-fcada63b-6203-4ae2-8914-30ab73cc2a31.png)

The second pipeline called **PL_ProcessPBIRefreshes** reads the configuration tables to loop through the required datasets to refresh.

![image.png](/.attachments/image-3fc37075-2d56-4cfc-b7f3-ed7d5b4a500f.png)