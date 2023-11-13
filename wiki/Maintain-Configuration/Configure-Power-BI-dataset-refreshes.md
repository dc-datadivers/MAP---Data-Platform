[[_TOC_]]

# Introduction

Pipelines and configuration tables have been created to enable Power BI datasets to be refreshed from ADF pipelines. This means that Power BI datasets can be refreshed as a part of the overall orchestration of the data loads.

The following two references were used to build the solution:

https://datasavvy.me/2020/07/09/refreshing-a-power-bi-dataset-in-azure-data-factory/

https://www.moderndata.ai/2019/05/powerbi-dataset-refresh-using-adf/

# ADF configuration tables

The following shows the config and logging tables with some sample entries. 

**GroupName** is a parameter in the pipeline and is used to group related datasets together.

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
( 1, 'Test Group', 'da700587-d06e-4641-9372-0c415dbb8957', 'Test Workspace', '04d569dc-5da8-4a03-b47e-b000cf1e2d90', 'Azure SQL Test', 1 )

SELECT * FROM CTL.PBIRefreshConfig


EXEC CTL.getPBIRefreshes @groupName = 'Test Group'

SELECT * FROM CTL.PBIRefreshLog --for logging of refreshes
```

The **PBIWorkspaceId** and **PBIDatasetId** for the workspace and dataset can be retrieved via the Power BI Service. Click on the dataset and copy the Ids from the URL.


# ADF pipelines

Two pipelines support the solution. The first is called **PL_RefreshPBIDataset** and was adapted from the above links.
It calls the Power BI API to refresh a particular dataset in a workspace.

The second pipeline called **PL_ProcessPBIRefreshes** reads the configuration tables to loop through the required datasets to refresh.
