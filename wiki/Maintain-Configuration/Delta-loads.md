[[_TOC_]]

#Introduction

Some tables in the framework are loaded incrementally. The logic used is based on high watermark. Once a delta load is complete the maximum datetime of the data is recorded in configuration. The next time the load is run, the fetch query filters for records after the high watermark.

There are two methods to configure a table for delta load:

1. Create a permanent staging table to hold the change set, or
2. Use dynamic upsert and transient staging table to hold the change set.

Each method is described below. Generally, you will use the first method if you need to do subsequent processing using the change set staging table, e.g. to load a large fact table. 

The second method has fewer moving parts and is easier to configure however you will lose the ability to leverage the staging change set for further processing as this table is created, used and immediately dropped by data factory.

#Method 1 - Permanent staging table and merge procedure

The framework always truncates the target table when moving from the data lake to data warehouse. In the case of delta loads, the table that is truncated is a Staging version of the table, rather than the master (which is never truncated unless a full load is required).

![image.png](/.attachments/image-41ac791d-1941-4112-81bb-87a0d6eb4627.png)

To get a list of tables that are loaded using this method of the delta framework run the following:

```
SELECT * FROM CTL.SourceConfig
WHERE DeltaLoad = 1
and DeltaProcedure IS NOT NULL
AND KeyColumns IS NULL;
```

Note that `KeyColumns` should be left blank when using Method 1. This column is only used in [Method 2](https://dev.azure.com/data-divers/Open%20Water%20Cloud/_wiki/wikis/OpenWaterCloudWiki/24/Delta-loads?_a=edit&anchor=method-2---transient-staging-table-and-keycolumns) (see below).

The differences with these configuration entries compared to a full load are:

- `DeltaLoad = 1`
- There is a high watermark column specified (the timestamp or integer column for tracking changes)
- The framework pulls the changed records into a permanent staging table which is truncated and reloaded each time
- There is a merge procedure specified in the `DeltaProcedure` column which is called to merge (or append) the changed data set from the staging table to the master table
- The `FetchQuery` has a placeholder in it for the dynamic watermark filter



```
--FetchQuery value in SourceConfig
SELECT * --columns will be listed
FROM TABLE_NAME
WHERE DB_MODIFIED_ON > 'WATERMARK';
```

Running the procedure as below dynamically replaces the `WATERMARK` text in the FetchQuery with the high value. This is then sent to Data Factory for executing the filtered query on the source.

```
EXEC CTL.getSourceToBronze @sourceName = 'VTMIS', 
                         @sourceType = 'SQL Server', 
                         @sourceEnvironment = 'PROD',
                         @runFrequency= 'Daily'

--FetchQuery result sent to Data Factory

SELECT * --columns will be listed
FROM TABLE_NAME
WHERE DB_MODIFIED_ON > '2021-09-30 10:58:54.710';
```




#Method 2 - Transient staging table and KeyColumns

This method of setting up a delta load uses the **dynamic upsert** feature of the data factory copy activity. 

![image.png](/.attachments/image-63ae68bf-e57c-4944-9a44-7388f0893466.png)

To get a list of tables that are loaded using this method of the delta framework run the following:

```
SELECT * FROM CTL.SourceConfig
WHERE DeltaLoad = 1
and DeltaProcedure IS NULL
AND KeyColumns IS NOT NULL;
```


As a part of **PL_SilverToDW** pipeline, the framework looks for the **KeyColumns** value in SourceConfig. This entry stores the unique columns to do the upsert in this format: 

`'["source_log_file"]' --single column PK`

`'["site_id", "timestamp", "checkname"]' --multiple column PK`

- If KeyColumns is blank and DeltaLoad = 1 then Method 1 will be used
- If KeyColumns is **not** blank and DeltaLoad = 1 then Method 2 will be used



![image.png](/.attachments/image-1f8f86ac-70a5-436e-8f79-bc5e1baa7876.png)

All of the other configuration entries in Method 1 apply, except for the following:

- No merge stored procedure is required as ADF generates this dynamically
- No STG table is required
- Target table is SRC as per a full load

Here is a sample entry for Method 2:


```
INSERT CTL.SourceConfig
(
    Id,
    IsRunnable,
    RunFrequency,
    DeltaLoad,
    SourceName,
    SourceType,
    SourceFilePath,
    SourceLocation,
    SourceFileExtension,
    SourceFileDelimiter,
    SheetName,
    SheetRange,
    FetchQuery,
    TabularTranslator,
    ContainerName,
    BLOBName,
    BlobFileExtension,
    DestinationSchema,
    DestinationTable,
    DeltaProcedure,
    LastRefreshed,
    DataDomain,
    WatermarkColumn,
    WatermarkInt,
    WatermarkDateTime,
    Created,
    SlidingWindowMonthsToLoad,
    KeyColumns
)
VALUES

( 4, 1, 'Daily', 1, 'Timescale', 'PostgreSQL', NULL, 'landing_audit_trail', NULL, NULL, NULL, NULL, 'SELECT site_id,
       source_log_file,
       landing_log_file,
       log_size,
       last_updated,
       last_read,
	   1 as shir_transferred
FROM landing_audit_trail
WHERE last_updated >= ''WATERMARK''
', '{"type": "TabularTranslator", "mappings": [{"source": {"name": "site_id", "type": "String", "path": null}, "sink": {"name": "site_id", "type": "String"}}, {"source": {"name": "source_log_file", "type": "String", "path": null}, "sink": {"name": "source_log_file", "type": "String"}}, {"source": {"name": "landing_log_file", "type": "String", "path": null}, "sink": {"name": "landing_log_file", "type": "String"}}, {"source": {"name": "log_size", "type": "Int", "path": null}, "sink": {"name": "log_size", "type": "Int"}}, {"source": {"name": "last_updated", "type": "Datetime", "path": null}, "sink": {"name": "last_updated", "type": "Datetime"}}, {"source": {"name": "last_read", "type": "Datetime", "path": null}, "sink": {"name": "last_read", "type": "Datetime"}}, {"source": {"name": "shir_transferred", "type": "Int", "path": null}, "sink": {"name": "shir_transferred", "type": "Int"}}, {"source": {"name": "DW_ModifiedDateTime", "type": "Datetime", "path": null}, "sink": {"name": "DW_ModifiedDateTime", "type": "Datetime"}}]}', 'timescale', 'landing_audit_trail', '.parquet', 'SRC', 'TIMESCALE_landing_audit_trail', NULL, NULL, 'LXM', 'last_updated', NULL, '1900-01-01', N'2022-08-08T12:22:03.637', NULL, '["source_log_file"]' )
```


#Delta load pipeline

In the Generic Master pipelines there is an activity to process the delta loads, i.e. to call the merge procedures and set the watermarks. The base piepline is called **PL_ProcessDeltas**.

As long as the configuration is set correctly, each specified procedure gets called to merge the data from the staging table to the master. The pipline detects Method 1 vs. Method 2 using KeyColumns and won't try to run a merge procedure for Method 2 (remember an upsert is done in PL_SilverToDW for Method 2).

This pipeline also updates the watermarks in SourceConfig, ready for the next load.

Any tables where `DeltaLoad = 0` (full load) are ignored by this step.

#Run a full load

In the case you want to blow away the data in the master table and reload it, perform these steps:

1. Truncate the Master table (i.e. the SRC target)
1. Set the watermark column value in SourceConfig to a low value, such as '1900-01-01'
1. Run the load and all data will be refreshed into the master table