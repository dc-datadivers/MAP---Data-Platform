[[_TOC_]]

# Introduction

There is a schema named **CTL** on the data warehouse database which is called the **Control Schema** and is used to drive the generic data factory pipelines. The schema also contains the tables for the logging framework.

#SourceEnvironments

This table contains one row per source system and source environment that needs to be loaded into the data warehouse.

`SELECT * FROM CTL.SourceEnvironments`

| Column Name       | Datatype | Description  |
|-------------------|----------|---|
| Id (PK)               | int      | A unique identifier for this entry. Set automatically using IDENTITY.  |
| SourceName (BK)       | varchar  | The name of the source system. Forms part of the unique set of parameters that drives the data factory source loads. Must match the entries in SourceConfig for this source.  |
| SourceEnvironment (BK) | varchar  | This is the environment of the source system being pulled from, e.g. DEV, TEST or PROD. It is possible to have multiple entries for a particular source system. Data factory parameters can be used to switch from loading from the TEST source system to loading from the PROD source system.<BR><BR> Note that sources on the SHIR such as files shares typically have a value that matches the data platform environment. For example, if configuring the DEV CTL database, to pull CSVs from the SHIR should mean that the value in this column is DEV. |
| SourceType        | varchar  | The type of source to be loaded. Must match the entries in SourceConfig for this source. These values have tight integration with the PL_Source* pipelines, which are in turn referenced by the two generic Master pipelines. <BR><BR> Out of the box, the framework comes with SQL Server, Azure SQL Database, REST, Excel and CSV as allowable values. Any other values used in this column must have a matching PL_Source* pipeline created. The Generic Master pipelines will also need review (see the Switch activities).  |
| SourceHost        | varchar  | The source host or REST endpoint. Typically, this is a database server, a file server, or the base URL for a REST API.  |
| SourceDatabase (BK)   | varchar  | The source database name. N/A for non-database sources.  |
| SourceUser        | varchar  | The user name for authenticating against the source.   |
| SourcePassword    | varchar  | The key vault secret name where the password or API key is held. Does not hold the actual password, just a pointer to the key vault.|
| Created           | datetime | The timestamp when this SourceEnvironments record was created.  |
| PaginationValue   | varchar  | Used for REST endpoints to help control pagination. NULL for all other cases.  |

#SourceConfig

This table contains one row per table, file, or REST endpoint to be loaded into the data warehouse.

`SELECT * FROM CTL.SourceConfig`


| Column Name         | Datatype | Description  |
|---------------------|----------|---|
| Id (PK)                 | int      | A unique identifier for a row. This is assigned manually and should be consistent across environments for a particular table.  |
| IsRunnable          | bit      | 1 if this table is to be loaded into the data platform. Set to 0 to exclude this table from all data loads.  |
| RunFrequency (BK)       | varchar  | Sets the frequency of the data load for this table. Typical values are 'Daily' or 'Hourly' (for example). A single table could be loaded at one or more frequencies, e.g. a full load once a day and delta loads throughout the day. Note that the data factory pipelines use this value to control which sets of tables to ingest. The values are completely configurable however the values between CTL and ADF must be aligned. |
| DeltaLoad           | bit      | 1 if this table is loaded using [delta processing](/Maintain-Configuration/Delta-loads) else 0. <BR><BR> Note that some older versions of the framework have a column called DeltaID. If this column exists then the value should be the same as Id for delta load records, else NULL. |
| SourceName (BK)          | varchar  | The name of the source system. Forms part of the unique set of parameters that drives the data factory source loads. Must match the entries in SourceEnvironments for this source. |
| SourceType          | varchar  | The type of source to be loaded. Must match the entries in SourceEnvironments for this source. These values have tight integration with the PL_Source* pipelines, which are in turn referenced by the two generic Master pipelines. <BR><BR> Out of the box, the framework comes with SQL Server, Azure SQL Database, REST, Excel and CSV as allowable values. Any other values used in this column must have a matching PL_Source* pipeline created. The Generic Master pipelines will also need review (see the Switch activities). |
| SourceFilePath      | varchar  | If this is a file source, this is the path to the file. NULL for database tables.  |
| SourceLocation (BK)     | varchar  | The location in the source system that holds the required data. This can be a table, view, file, or endpoint.  |
| SourceFileExtension | varchar  | If this is a file source, this is the extension of the file. NULL for database tables.   |
| SourceFileDelimiter | varchar  | If this is a delimited file source, this is the delimiter in the file. NULL for other sources.  |
| SheetName           | varchar  | If this is an Excel file source, this is the sheet name in the file. NULL for other sources.  |
| SheetRange          | varchar  | If this is an Excel file source, this is the range in the file. NULL for other sources.  |
| FetchQuery          | varchar  | This the query to be run on the source system. In the case of a SELECT query, this must be a valid SQL query on the source system, selecting from either a table or a view. All columns should be listed in the SELECT query (do not use `SELECT * `). It is possible to create complex, multi-table SELECT statements, but this requirement is rare. Normally, individual tables are imported and joined in the data platform. <BR><BR> This column can also hold the unique portion of a REST endpoint. See the Canning IOT example in the reference platform. |
| TabularTranslator   | varchar  | This is a mandatory column that defines the column mappings between the source and target. It takes the form of a JSON snippet that is dynamically inserted into the data factory pipelines. Defining this mapping in configuration minimises the number of pipelines and datasets in data factory. It also ensures that data types are defined in all parquet files in the data lake. <BR><BR> For flat sources such as tables and CSV files, there are two main methods of generating the tabular translator. Either use the dphelper Python utility, or run the `CTL.GenerateTablularTranslator` procedure (using the target SRC table as the parameter). Alternatively, an existing entry can be copied and modified. <BR><BR> For semi-structured sources such as JSON, the tabular translator can be more complex. There is a sample pipeline called PL_GenerateTabluarTranslatorJSON that can be used to help get the first cut of a mapping. Complex JSON inputs sometimes require multiple output flat files; in this case there would need to be multiple config entries for this particular source JSON.|
| ContainerName             | varchar   | The container name in the data lake. Must be all lowercase. Generally, this is the same as the source name but lowercase.  |
| BLOBName                  | varchar   | The name of the blob file in the data lake. Usually, the same as the source table or file name.  |
| BlobFileExtension         | varchar   | The extension to assign to the data lake file. Some parts of the framework ignore this and will always write parquet. |
| DatabricksNotebookName    | varchar   | Placeholder for future requirement to run a Databricks notebook as a part of the ingestion. Defaults to Not Applicable.  |
| DatabricksNotebookPath    | varchar   | Placeholder for future requirement to run a Databricks notebook as a part of the ingestion. Defaults to Not Applicable.  |
| DestinationSchema         | varchar   | The destination schema in the data platform data warehouse database. Most commonly this will be SRC. <BR><BR> Importantly, for delta loads (method 1) this value must be set to STG. In all other cases, the value should be SRC.  |
| DestinationTable          | varchar   | The destination table name in the data platform.  |
| DeltaProcedure            | varchar   | This is the MERGE procedure for delta loads (Method 1 only)  |
| LastRefreshed             | datetime  | The framework will populate this column with the timestamp for when the table was last refreshed. Set this to NULL for initial entries.  |
| DataDomain                | varchar   | This is the business subject area of the data and is used for metadata only. (Some clients may include it in the data lake folder structure, but this is not a currently feature of the reference platform).  |
| WatermarkColumn           | varchar   | For delta loads this is the column name(s) for tracking the high watermark.  |
| WatermarkInt              | bigint    | If the watermark column is an INT, then this is the current high watermark value.  |
| WatermarkDateTime         | datetime2 | If the watermark column is a datetime, then this is the current high watermark value.  |
| Created                   | datetime  | The timestamp when this SourceConfig record was created.   |
| SlidingWindowMonthsToLoad | int       | Used for sliding window processing where the Fetch Query has the required placeholder for a sliding load based on months. |
| KeyColumns	| varchar| This column controls the delta load for Method 2. See the [documentation for delta loads](/Maintain-Configuration/Delta-loads) for usage examples.  |


#Logging framework

A logging framework has been built into the generic pipelines to write to the following two tables:

`SELECT TOP (100) * FROM CTL.BatchLog ORDER BY CreatedOn DESC` 

`SELECT TOP (100) * FROM CTL.SourceLog ORDER BY CreatedOn DESC` 

**BatchLog** contains one row per batch executed by Data Factory. A single batch Id will link together all of the sub pipelines that were called.

**SourceLog** contains one row per object that was loaded, and information such as time to load, and number of rows copied.

The logging tables can be used to troubleshoot errors as all of the error messages are written to these tables in case of failures.

Reporting views have been set up to use in reporting tools such as Power BI in case monitoring dashboards are required.

`SELECT TOP (1000) * FROM CTL.vwSourceLog ORDER BY [Source Created On] DESC`

#Data factory layout

The data factory contains pipelines that have been written with parameterisation and reuse in mind. A single pipeline can load many different sources depending on the parameters that are used. This significantly reduces the number of pipelines, datasets and linked services to maintain. New tables can be added to an existing source without any data factory coding at all.

## 3_Processing folder

This folder contains pipelines that do a particular unit of work to move data through the architecture.

For example, the pipeline **PL_SourceSQLServerToSilver** moves a set of tables from any SQL Server to the silver data lake.

Most of the pipelines in this folder have the same logic: a **Lookup** activity which calls a stored procedure to get a set of objects to process, then a **ForEach** Loop which processes the requested tables in batches.

The source database pipelines each call a procedure called `CTL.getSourceDBToSilver`

```
EXEC CTL.getSourceDBToSilver @sourceName = 'AdventureWorks',
                            @sourceType = 'SQL Server',
                            @sourceEnvironment = 'DEV',
                            @runFrequency = 'Daily'
```


The table of data that is returned is used by Data Factory to connect to the source, execute the FetchQuery for each table and load the source data into the bronze data lake.

## 2_Masters folder

The **2_Masters** folder contains the orchestration pipelines that move source data all of the way through the architecture. The main pipeline for file and semi-structured source is called **PL_GenericMaster**; this chains together sub-pipelines from the **3_Processing** subfolder, using appropriate parameters.

There is also a database-specific version of this pipeline called **PL_GenericDBMaster** that skips the bronze data lake and goes straight from source database to the silver data lake parquet files.


## 1_Loads folder

The **1_Loads** folder contains the pipelines for each specific instance of a source system. There could be several Load pipelines that call one of the **GenericMaster** pipelines, each with different parameters. 

## Orchestration pipelines

Orchestration pipelines on scheduled triggers are used to chain together source loads, star schema loads and Power BI dataset refreshes for a particular subject area. The reference framework does not have an example of an orchestration pipeline, however, below is an example of what one might look like.

![image.png](/.attachments/image-388e80b6-6973-4db2-85fe-38662f6c1740.png)