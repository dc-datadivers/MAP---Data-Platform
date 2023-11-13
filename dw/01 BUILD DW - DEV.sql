--DEV ENVIRONMENT SCRIPT 

--Ensure query is connected to the DW database

--Find and replace xx/xx/xxxx to be the deployment date

--DATABASE CONFIG

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF --prevent skipped identity values
GO

--USERS AND SECURITY

CREATE USER [sg.global.map.dev.adm] FROM  EXTERNAL PROVIDER --Developer group. Note you need to be signed in as the Microsoft Entra ID Admin to assign this security.
GO

CREATE USER [mmg-aue-map-adf01-e3]  FROM  EXTERNAL PROVIDER --Data factory managed identity
GO

CREATE ROLE [db_executor]
GO

GRANT ALTER,
      DELETE,
      EXECUTE,
      INSERT,
      SELECT,
      UPDATE,
      VIEW DEFINITION,
      REFERENCES,
      SHOWPLAN,
      VIEW DATABASE PERFORMANCE STATE
TO  [db_executor];
GO

sys.sp_addrolemember @rolename = N'db_executor', @membername = N'sg.global.map.dev.adm'
GO

sys.sp_addrolemember @rolename = N'db_executor', @membername = N'mmg-aue-map-adf01-e3'
GO

--Schemas

CREATE SCHEMA [CTL]
GO

CREATE SCHEMA [IDW]
GO

CREATE SCHEMA [PBI]
GO

CREATE SCHEMA [SRC]
GO

CREATE SCHEMA [STG]
GO

-- Timezone config

CREATE TABLE [CTL].[SystemTimezone](
	[Timezone] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_SystemTimezone] PRIMARY KEY CLUSTERED 
(
	[Timezone] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT CTL.SystemTimezone
(
    Timezone
)
VALUES
(N'W. Australia Standard Time' -- Timezone - nvarchar(256)
)

--INSERT CTL.SystemTimezone
--(
--    Timezone
--)
--VALUES
--(N'UTC' -- Timezone - nvarchar(256) - for UTC based clients
--)



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* FUNCTION NAME: CTL.fn_convertUTCDateTime
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* FUNCTION DESC: Converts UTC datetime value to the required timezone
*
* TEST: SELECT CTL.fn_convertUTCDateTime('2021-12-08 13:04:52', 'W. Australia Standard Time') as Converted
*
* Note that a list of supported timezones can be found here: SELECT * FROM sys.time_zone_info ORDER BY NAME 
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE   FUNCTION [CTL].[fn_convertUTCDateTime]
(
    @dt AS DATETIME,
    @timezone NVARCHAR(100)
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @dto AS DATETIMEOFFSET;

    SET @dto = CONVERT(DATETIMEOFFSET, @dt) AT TIME ZONE @timezone;

    RETURN CONVERT(DATETIME, @dto);

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* FUNCTION NAME: CTL.fn_getSystemDateTime
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* FUNCTION DESC: Gets the current system datetime based on the system timezone
*
* TEST: SELECT CTL.fn_getSystemDateTime
*
* Note that a list of supported timezones can be found here: SELECT * FROM sys.time_zone_info ORDER BY NAME 
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE FUNCTION [CTL].[fn_getSystemDateTime]()
RETURNS DATETIME
AS
BEGIN
    DECLARE @dto AS DATETIMEOFFSET;

    SET @dto = CONVERT(DATETIMEOFFSET, GETDATE()) AT TIME ZONE (SELECT MAX(Timezone) FROM CTL.SystemTimezone);

    RETURN CONVERT(DATETIME, @dto);

END;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[BatchLog](
	[BatchLogID] [bigint] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] [varchar](256) NULL,
	[PipelineName] [varchar](256) NULL,
	[PipelineRunID] [varchar](256) NULL,
	[SourceName] [varchar](256) NULL,
	[SourceEnvironment] [varchar](10) NULL,
	[Status] [varchar](50) NOT NULL,
	[FailureLayer] [varchar](50) NULL,
	[FailureReason] [varchar](max) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_BatchLog_ID] PRIMARY KEY CLUSTERED 
(
	[BatchLogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[SourceConfig](
	[Id] [int] NOT NULL,
	[IsRunnable] [bit] NOT NULL,
	[RunFrequency] [varchar](255) NULL,
	[DeltaLoad] [bit] NULL,
	[SourceName] [varchar](255) NOT NULL,
	[SourceType] [varchar](255) NOT NULL,
	[SourceFilePath] [varchar](max) NULL,
	[SourceLocation] [varchar](500) NULL,
	[SourceFileExtension] [varchar](10) NULL,
	[SourceFileDelimiter] [varchar](10) NULL,
	[SheetName] [varchar](100) NULL,
	[SheetRange] [varchar](100) NULL,
	[FetchQuery] [varchar](max) NULL,
	[TabularTranslator] [varchar](max) NOT NULL,
	[ContainerName] [varchar](255) NULL,
	[BLOBName] [varchar](255) NULL,
	[BlobFileExtension] [varchar](10) NULL,
	[DatabricksNotebookName] [varchar](100) NULL,
	[DatabricksNotebookPath] [varchar](500) NULL,
	[DestinationSchema] [varchar](10) NULL,
	[DestinationTable] [varchar](256) NULL,
	[DeltaProcedure] [varchar](256) NULL,
	[LastRefreshed] [datetime] NULL,
	[DataDomain] [varchar](256) NULL,
	[WatermarkColumn] [varchar](128) NULL,
	[WatermarkInt] [bigint] NULL,
	[WatermarkDateTime] [datetime2](7) NULL,
	[Created] [datetime] NOT NULL,
	[SlidingWindowMonthsToLoad] [int] NULL,
	[KeyColumns] [varchar](256) NULL,
 CONSTRAINT [PK_SourceConfig_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[SourceLog](
	[SourceLogID] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceConfigID] [int] NOT NULL,
	[BatchLogID] [bigint] NOT NULL,
	[PipelineName] [varchar](255) NULL,
	[PipelineRunID] [varchar](256) NULL,
	[Status] [varchar](255) NOT NULL,
	[StatusDescription] [varchar](255) NULL,
	[RowsCopied] [int] NULL,
	[DatabricksNotebookURL] [varchar](1000) NULL,
	[FailureReason] [varchar](max) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NULL,
	[DurationInQueue] [int] NULL,
 CONSTRAINT [PK_SourceLog_SourceLogID] PRIMARY KEY CLUSTERED 
(
	[SourceLogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[StarConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[isRunnable] [bit] NOT NULL,
	[StarSchemaName] [varchar](100) NOT NULL,
	[ProcSchema] [varchar](100) NOT NULL,
	[ProcName] [varchar](100) NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[ProcType] [varchar](100) NOT NULL,
	[RunFrequency] [varchar](100) NOT NULL,
	[GroupName] [varchar](100) NOT NULL,
	[Sequence] [int] NOT NULL,
	[Created] [datetime] NOT NULL,
	[LastRefreshed] [datetime] NULL,
 CONSTRAINT [PK_StarConfig_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[StarLog](
	[StarLogID] [bigint] IDENTITY(1,1) NOT NULL,
	[StarConfigID] [int] NOT NULL,
	[BatchLogID] [bigint] NOT NULL,
	[PipelineName] [varchar](255) NULL,
	[PipelineRunID] [varchar](256) NULL,
	[ProcSchema] [varchar](100) NULL,
	[ProcName] [varchar](100) NULL,
	[TableName] [varchar](100) NULL,
	[ProcType] [varchar](100) NULL,
	[RunFrequency] [varchar](100) NULL,
	[GroupName] [varchar](100) NULL,
	[Sequence] [int] NULL,
	[ExecCommand] [varchar](100) NULL,
	[Status] [varchar](255) NOT NULL,
	[StatusDescription] [varchar](255) NULL,
	[FailureReason] [varchar](max) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_StarLog_StarLogID] PRIMARY KEY CLUSTERED 
(
	[StarLogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* VIEW NAME: CTL.vwBatchLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* VIEW DESC: Reporting view for batch level loads
*
****************************************************************************************************
* DATE:			Developer 			Change
  --------		----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/


CREATE   VIEW [CTL].[vwBatchLog]
AS

--SourceConfig based batches
SELECT bl.BatchLogID,
       bl.PipelineName,
	   bl.PipelineRunID,
	   sc.RunFrequency,
       bl.SourceName,
       bl.SourceEnvironment,
       bl.Status AS BatchStatus,
       ISNULL(bl.FailureLayer, 'No Failure') AS BatchFailureLayer,
       ISNULL(bl.FailureReason, 'No Failure') AS BatchFailureReason,
       bl.CreatedOn,
       bl.ModifiedOn AS BatchModifiedOn,
       DATEDIFF(SECOND, bl.CreatedOn, bl.ModifiedOn) AS ExecutionSeconds,
       COUNT(sl.SourceLogID) AS ObjectsLoaded,
       CAST(bl.CreatedOn AS DATE) AS ProcessingDate,
       CASE
           WHEN CONVERT(TIME, bl.CreatedOn) > '12:59:59' THEN  --9pm WA time
               CAST(bl.CreatedOn AS DATE)
           ELSE
               DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
       END AS LoadDate
FROM CTL.BatchLog bl
    LEFT JOIN CTL.SourceLog sl ON sl.BatchLogID = bl.BatchLogID
	LEFT JOIN CTL.SourceConfig sc ON sl.SourceConfigID = sc.Id
WHERE bl.PipelineName NOT IN ('StarSchemaMaster', 'ExtractPipelineRunCosts')
GROUP BY bl.BatchLogID,
         bl.PipelineName,
		 bl.PipelineRunID,
		 sc.RunFrequency,
         bl.SourceName,
         bl.SourceEnvironment,
         bl.Status,
         ISNULL(bl.FailureLayer, 'No Failure'),
         ISNULL(bl.FailureReason, 'No Failure'),
         bl.CreatedOn,
         bl.ModifiedOn,
         DATEDIFF(SECOND, bl.CreatedOn, bl.ModifiedOn),
         CAST(bl.CreatedOn AS DATE),
         CASE
             WHEN CONVERT(TIME, bl.CreatedOn) > '12:59:59' THEN  --9pm WA time
                 CAST(bl.CreatedOn AS DATE)
             ELSE
                 DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
         END

--StarSchemaMaster based batches
UNION ALL

SELECT bl.BatchLogID,
       bl.PipelineName,
	   bl.PipelineRunID,
	   sc.RunFrequency,
       bl.SourceName,
       bl.SourceEnvironment,
       bl.Status AS BatchStatus,
       ISNULL(bl.FailureLayer, 'No Failure') AS BatchFailureLayer,
       ISNULL(bl.FailureReason, 'No Failure') AS BatchFailureReason,
       bl.CreatedOn,
       bl.ModifiedOn AS BatchModifiedOn,
       DATEDIFF(SECOND, bl.CreatedOn, bl.ModifiedOn) AS ExecutionSeconds,
       COUNT(sl.StarLogID) AS ObjectsLoaded,
       CAST(bl.CreatedOn AS DATE) AS ProcessingDate,
       CASE
           WHEN CONVERT(TIME, bl.CreatedOn) > '12:59:59' THEN  --9pm WA time
               CAST(bl.CreatedOn AS DATE)
           ELSE
               DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
       END AS LoadDate
FROM CTL.BatchLog bl
    LEFT JOIN CTL.StarLog sl ON sl.BatchLogID = bl.BatchLogID
	LEFT JOIN CTL.StarConfig sc ON sl.StarConfigID = sc.Id
WHERE bl.PipelineName = 'StarSchemaMaster'
GROUP BY bl.BatchLogID,
         bl.PipelineName,
		 bl.PipelineRunID,
		 sc.RunFrequency,
         bl.SourceName,
         bl.SourceEnvironment,
         bl.Status,
         ISNULL(bl.FailureLayer, 'No Failure'),
         ISNULL(bl.FailureReason, 'No Failure'),
         bl.CreatedOn,
         bl.ModifiedOn,
         DATEDIFF(SECOND, bl.CreatedOn, bl.ModifiedOn),
         CAST(bl.CreatedOn AS DATE),
         CASE
             WHEN CONVERT(TIME, bl.CreatedOn) > '12:59:59' THEN  --9pm WA time
                 CAST(bl.CreatedOn AS DATE)
             ELSE
                 DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
         END

-- ExtractPipelineRunCosts batches
UNION ALL 

SELECT bl.BatchLogID,
       bl.PipelineName,
	   bl.PipelineRunID,
	   'Daily' AS RunFrequency,
       bl.SourceName,
       bl.SourceEnvironment,
       bl.Status AS BatchStatus,
       ISNULL(bl.FailureLayer, 'No Failure') AS BatchFailureLayer,
       ISNULL(bl.FailureReason, 'No Failure') AS BatchFailureReason,
       bl.CreatedOn,
       bl.ModifiedOn AS BatchModifiedOn,
       DATEDIFF(SECOND, bl.CreatedOn, bl.ModifiedOn) AS ExecutionSeconds,
       1 AS ObjectsLoaded,
       CAST(bl.CreatedOn AS DATE) AS ProcessingDate,
       CASE
           WHEN CONVERT(TIME, bl.CreatedOn) > '12:59:59' THEN  --9pm WA time
               CAST(bl.CreatedOn AS DATE)
           ELSE
               DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
       END AS LoadDate
FROM CTL.BatchLog bl
WHERE bl.PipelineName = 'ExtractPipelineRunCosts'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[PBIRefreshLog](
	[PBIRefreshLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[PBIRefreshId] [int] NOT NULL,
	[BatchLogId] [bigint] NOT NULL,
	[PipelineName] [varchar](255) NULL,
	[PipelineRunID] [varchar](256) NULL,
	[GroupName] [varchar](100) NOT NULL,
	[PBIWorkspaceId] [varchar](100) NOT NULL,
	[PBIWorkspaceName] [varchar](100) NOT NULL,
	[PBIDatasetId] [varchar](100) NOT NULL,
	[PBIDatasetName] [varchar](100) NOT NULL,
	[Sequence] [int] NOT NULL,
	[Status] [varchar](255) NOT NULL,
	[StatusDescription] [varchar](255) NULL,
	[FailureReason] [varchar](max) NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_PBIRefreshLog_Id] PRIMARY KEY CLUSTERED 
(
	[PBIRefreshLogId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* VIEW NAME: CTL.vwPBIRefreshLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* VIEW DESC: Reporting view for Power BI dataset refreshes executed via Azure Data Factory.
*
*
****************************************************************************************************
* DATE:			Developer 			Change
  --------		----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE VIEW [CTL].[vwPBIRefreshLog]
AS
SELECT bl.BatchLogID,
       bl.PipelineName AS BatchPipeline,
	   bl.PipelineRunID AS BatchPipelineRunID,
       bl.[Status] AS BatchStatus,
       ISNULL(bl.FailureLayer, 'No Failure') AS BatchFailureLayer,
       ISNULL(bl.FailureReason, 'No Failure') AS BatchFailureReason,
       bl.CreatedOn AS BatchCreatedOn,
       bl.ModifiedOn AS BatchModifiedOn,
       CAST(bl.CreatedOn AS DATE) AS ProcessingDate,
       CASE
           WHEN CONVERT(TIME, bl.CreatedOn) > '19:59:59' THEN
               CAST(bl.CreatedOn AS DATE)
           ELSE
               DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
       END AS LoadDate,
       pbi.PBIRefreshLogId,
       pbi.PBIRefreshId,	   
       pbi.PipelineName AS PBIRefreshPipeline,
	   pbi.PipelineRunID AS PBIRefreshPipelineRunID,
       pbi.GroupName,
       pbi.PBIWorkspaceId,
       pbi.PBIWorkspaceName,
       pbi.PBIDatasetId,
       pbi.PBIDatasetName,
       pbi.[Sequence],
       pbi.[Status] AS PBIRefreshStatus,
       pbi.StatusDescription AS PBIRefreshStatusDescription,
       ISNULL(pbi.FailureReason, 'No Failure') AS PBIRefreshFailureReason,
       pbi.CreatedOn AS PBIRefreshCreatedOn,
       pbi.ModifiedOn AS PBIRefreshModifiedOn,
       DATEDIFF(SECOND, pbi.CreatedOn, pbi.ModifiedOn) AS ExecutionSeconds
FROM CTL.BatchLog bl
    INNER JOIN CTL.PBIRefreshLog pbi ON pbi.BatchLogId = bl.BatchLogID;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* VIEW NAME: CTL.vwSourceLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* VIEW DESC: Reporting view for source level loads
*
****************************************************************************************************
* DATE:			Developer 			Change
  --------		----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/

CREATE   VIEW [CTL].[vwSourceLog]
AS
SELECT bl.BatchLogID,
	   bl.DataFactoryName,
       bl.PipelineName AS BatchPipeline,
	   bl.PipelineRunID AS BatchPipelineRunID,
       bl.[Status] AS BatchStatus,
       ISNULL(bl.FailureLayer, 'No Failure') AS BatchFailureLayer,
       ISNULL(bl.FailureReason, 'No Failure') AS BatchFailureReason,
       bl.CreatedOn AS BatchCreatedOn,
       bl.ModifiedOn AS BatchModifiedOn,
       CAST(bl.CreatedOn AS DATE) AS ProcessingDate,
       CASE
           WHEN CONVERT(TIME, bl.CreatedOn) > '11:59:59' THEN  --8pm WA time
               CAST(bl.CreatedOn AS DATE)
           ELSE
               DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
       END AS LoadDate,
       sl.SourceLogID,
       sl.SourceConfigID,
       sl.PipelineName AS SourcePipeline,
	   sl.PipelineRunID AS SourcePipelineRunID,
       sl.[Status] AS SourceStatus,
       sl.StatusDescription AS SourceStatusDescription,
       sl.RowsCopied AS RowsCopied,
	   sl.DurationInQueue AS DurationInQueue,
       sl.DatabricksNotebookURL AS DatabricksRunURL,
       ISNULL(sl.FailureReason, 'No Failure') AS SourceFailureReason,
       sl.CreatedOn AS SourceCreatedOn,
       sl.ModifiedOn AS SourceModifiedOn,
       DATEDIFF(SECOND, sl.CreatedOn, sl.ModifiedOn) AS ExecutionSeconds,
       sc.RunFrequency,
       sc.DeltaLoad,
       sc.SourceName,
       sc.SourceType,
       sc.ContainerName,
       sc.BLOBName,
       sc.DestinationSchema,
       sc.DestinationTable,
       sc.SourceLocation,
       sc.DeltaProcedure,
       sc.DestinationSchema + '.' + REPLACE(sc.DestinationTable, '_DELTA', '') AS Destination,
	   sc.DataDomain
FROM CTL.BatchLog bl
    INNER JOIN CTL.SourceLog sl ON sl.BatchLogID = bl.BatchLogID
    INNER JOIN CTL.SourceConfig sc ON sl.SourceConfigID = sc.Id
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* VIEW NAME: CTL.vwStarLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* VIEW DESC: Reporting view for star schema loads
*
****************************************************************************************************
* DATE:			Developer 			Change
  --------		----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/

CREATE   VIEW [CTL].[vwStarLog]
AS
SELECT bl.BatchLogID,
       bl.PipelineName AS BatchPipeline,
	   bl.PipelineRunID AS BatchPipelineRunID,
       bl.[Status] AS BatchStatus,
       ISNULL(bl.FailureLayer, 'No Failure') AS BatchFailureLayer,
       ISNULL(bl.FailureReason, 'No Failure') AS BatchFailureReason,
       bl.CreatedOn AS BatchCreatedOn,
       bl.ModifiedOn AS BatchModifiedOn,
       CAST(bl.CreatedOn AS DATE) AS ProcessingDate,
       CASE
           WHEN CONVERT(TIME, bl.CreatedOn) > '11:59:59' THEN  --8pm WA time
               CAST(bl.CreatedOn AS DATE)
           ELSE
               DATEADD(DAY, -1, CAST(bl.CreatedOn AS DATE))
       END AS LoadDate,
       sl.StarLogID,
       sl.StarConfigID,	   
       sl.PipelineName,
	   sl.PipelineRunID AS StarPipelineRunID,
	   sc.StarSchemaName AS StarSchemaName,
       sl.ProcSchema + '.' + sl.ProcName AS ProcName,
       sl.TableName AS TableName,
       sl.ProcType,
       sl.RunFrequency,
       sl.GroupName,
       sl.[Sequence],
       sl.[Status] AS StarStatus,
       sl.StatusDescription AS StarStatusDescription,
       ISNULL(sl.FailureReason, 'No Failure') AS StarFailureReason,
       sl.CreatedOn AS StarCreatedOn,
       sl.ModifiedOn AS StarModifiedOn,
       DATEDIFF(SECOND, sl.CreatedOn, sl.ModifiedOn) AS ExecutionSeconds
FROM CTL.BatchLog bl
    INNER JOIN CTL.StarLog sl ON sl.BatchLogID = bl.BatchLogID
    INNER JOIN CTL.StarConfig sc ON sl.StarConfigID = sc.Id
WHERE bl.SourceName = 'StarSchema';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IDW].[DimDate](
	[DateSK] [bigint] NOT NULL,
	[Date] [date] NOT NULL,
	[DayName] [varchar](9) NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[DayOfMonth] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[DaySuffix] [varchar](4) NOT NULL,
	[MonthName] [varchar](9) NOT NULL,
	[MonthShortName] [char](3) NOT NULL,
	[MonthNumberOfYear] [tinyint] NOT NULL,
	[MonthNumberSinceStart] [smallint] NOT NULL,
	[MonthStartDate] [date] NOT NULL,
	[MonthEndDate] [date] NOT NULL,
	[MonthYear] [varchar](8) NOT NULL,
	[WeekNumberOfYear] [smallint] NOT NULL,
	[WeekNumberSinceStart] [smallint] NOT NULL,
	[WeekdayInd] [char](1) NOT NULL,
	[WeekStartDate] [date] NOT NULL,
	[WeekEndDate] [date] NOT NULL,
	[WeekName] [varchar](7) NOT NULL,
	[CalendarQuarterNumber] [tinyint] NOT NULL,
	[CalendarQuarterName] [char](6) NOT NULL,
	[Year] [smallint] NOT NULL,
	[LastDayOfMonthInd] [char](1) NOT NULL,
	[FiscalMonthNumber] [int] NOT NULL,
	[FiscalQuarterNumber] [int] NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[FiscalQuarterName] [varchar](6) NOT NULL,
	[CalendarHalfNumber] [tinyint] NOT NULL,
	[CalendarHalfName] [char](6) NOT NULL,
	[FiscalHalfNumber] [tinyint] NOT NULL,
	[FiscalHalfName] [char](6) NOT NULL,
	[EndOfPreviousMonth] [date] NOT NULL,
	[TodayInd] [char](1) NOT NULL,
	[YesterdayInd] [char](1) NOT NULL,
	[LoadDateInd] [char](1) NOT NULL,
	[CalendarYearMonth] [varchar](6) NOT NULL,
	[EndOfCurrentMonthInd] [char](1) NOT NULL,
	[CurrentMTDInd] [char](1) NOT NULL,
	[CurrentHTDInd] [char](1) NOT NULL,
	[CurrentYTDInd] [char](1) NOT NULL,
	[CurrentFYTDInd] [char](1) NOT NULL,
	[CurrentRollingYearInd] [char](1) NOT NULL,
	[DayRelative] [int] NOT NULL,
	[WeekRelative] [int] NOT NULL,
	[MonthRelative] [int] NOT NULL,
	[QuarterRelative] [int] NOT NULL,
	[YearRelative] [int] NOT NULL,
	[NationalHolidayInd] [char](1) NOT NULL,
	[NationalHolidayName] [varchar](30) NOT NULL,
	[DW_ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	[DateSK] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* VIEW NAME: PBI.vwDimDate
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* VIEW DESC: View to be referenced by Power BI datasets
*
****************************************************************************************************
* DATE:			Developer 			Change
  ----------	----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	Data Divers         Initial Version

****************************************************************************************************/

CREATE VIEW [PBI].[vwDimDate]
AS
SELECT [DateSK]
      ,[Date]
      ,[DayName] AS [Day Name]
      ,[DayOfWeek] AS [Day of Week]
      ,[DayOfMonth] AS [Day of Month]
      ,[DayOfYear] AS [Day of Year]
      ,[DaySuffix] AS [Day Suffix]
      ,[MonthName] AS [Month Name]
      ,[MonthShortName] AS [Month Short Name]
      ,[MonthNumberOfYear] AS [Month Number of Year]
      ,[MonthNumberSinceStart] AS [Month Number Since Start]
      ,[MonthStartDate] AS [Month Start Date]
      ,[MonthEndDate] AS [Month End Date]
      ,[MonthYear] AS [Month Year]
      ,[WeekNumberOfYear] AS [Week Number of Year]
      ,[WeekNumberSinceStart] AS [Week Number Since Start]
      ,[WeekdayInd] AS [Weekday Indicator]
      ,[WeekStartDate] AS [Week Start Date]
      ,[WeekEndDate] AS [Week End Date]
      ,[WeekName] AS [Week Name]
      ,[CalendarQuarterNumber] AS [Calendar Quarter Number]
      ,[CalendarQuarterName] AS [Calendar Quarter Name]
      ,[Year]
      ,[LastDayOfMonthInd] AS [Last Day of Month Indicator]
      ,[FiscalMonthNumber] AS [Fiscal Month Number]
      ,[FiscalQuarterNumber] AS [Fiscal Quarter Number]
      ,[FiscalYear] AS [Fiscal Year]
      ,[FiscalQuarterName] AS [Fiscal Quarter Name]
      ,[CalendarHalfNumber] AS [Calendar Half Number]
      ,[CalendarHalfName] AS [Calendar Half Name]
      ,[FiscalHalfNumber] AS [Fiscal Half Number]
      ,[FiscalHalfName] AS [Fiscal Half Name]
      ,[EndOfPreviousMonth] AS [End of Previous Month]
      ,[TodayInd] AS [Today Indicator]
      ,[YesterdayInd] AS [Yesterday Indicator]
      --,[LoadDateInd]
      ,[CalendarYearMonth] AS [Calendar Year Month]
      ,[EndOfCurrentMonthInd] AS [End of Current Month Indicator]
      ,[CurrentMTDInd] AS [Current MTD Indicator]
      ,[CurrentHTDInd] AS [Current HTD Indicator]
      ,[CurrentYTDInd] AS [Current YTD Indicator]
      ,[CurrentFYTDInd] AS [Current FYTD Indicator]
      ,[CurrentRollingYearInd] AS [Current Rolling Year Indicator]
      ,[DayRelative] AS [Day Relative]
      ,[WeekRelative] AS [Week Relative]
      ,[MonthRelative] AS [Month Relative]
      ,[QuarterRelative] AS [Quarter Relative]
      ,[YearRelative] AS [Year Relative]
      ,[NationalHolidayInd] AS [National Holiday Indicator]
      ,[NationalHolidayName] AS [National Holiday Name]
  FROM IDW.DimDate
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[PBIRefreshConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[isRunnable] [bit] NOT NULL,
	[GroupName] [varchar](100) NOT NULL,
	[PBIWorkspaceId] [varchar](100) NOT NULL,
	[PBIWorkspaceName] [varchar](100) NOT NULL,
	[PBIDatasetId] [varchar](100) NOT NULL,
	[PBIDatasetName] [varchar](100) NOT NULL,
	[Sequence] [int] NOT NULL,
	[LastRefreshed] [datetime] NULL,
	[Created] [datetime] NOT NULL,
 CONSTRAINT [PK_PBIRefreshConfig_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[PipelineCosts](
	[PipelineRunUid] [varchar](100) NOT NULL,
	[Activities] [bigint] NULL,
	[TotalCost] [real] NULL,
	[CloudOrchestrationCost] [real] NULL,
	[SelfHostedOrchestrationCost] [real] NULL,
	[SelfHostedDataMovementCost] [real] NULL,
	[SelfHostedPipelineActivityCost] [real] NULL,
	[CloudPipelineActivityCost] [real] NULL,
	[CloudDataMovementCost] [real] NULL,
	[rowsCopied] [bigint] NULL,
	[dataRead] [bigint] NULL,
	[dataWritten] [bigint] NULL,
	[FailedActivities] [bigint] NULL,
	[MaxActivityTimeGenerated] [datetime] NULL,
	[DW_ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [PK_PCosts_PipelineRunUid] PRIMARY KEY CLUSTERED 
(
	[PipelineRunUid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CTL].[SourceEnvironments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceName] [varchar](256) NOT NULL,
	[SourceEnvironment] [varchar](10) NOT NULL,
	[SourceType] [varchar](256) NOT NULL,
	[SourceHost] [varchar](256) NOT NULL,
	[SourceDatabase] [varchar](256) NOT NULL,
	[SourceUser] [varchar](256) NOT NULL,
	[SourcePassword] [varchar](256) NOT NULL,
	[Created] [datetime] NOT NULL,
	[PaginationValue] [varchar](256) NULL,
 CONSTRAINT [PK_SourceEnvironments_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IDW].[DimTime](
	[TimeSK] [bigint] NOT NULL,
	[Time] [datetime] NOT NULL,
	[HourOfTheDay] [tinyint] NOT NULL,
	[AMPMHourOfTheDay] [tinyint] NOT NULL,
	[MinuteOfTheDay] [smallint] NOT NULL,
	[SecondOfTheDay] [int] NOT NULL,
	[AMPM] [varchar](2) NOT NULL,
	[HoursToNextDay] [tinyint] NOT NULL,
	[MinutesToNextDay] [smallint] NOT NULL,
	[SecondsToNextDay] [int] NOT NULL,
	[PeriodStart15] [datetime] NOT NULL,
	[PeriodEnd15] [datetime] NOT NULL,
	[PeriodStart30] [datetime] NOT NULL,
	[PeriodEnd30] [datetime] NOT NULL,
	[PeriodStart60] [datetime] NOT NULL,
	[PeriodEnd60] [datetime] NOT NULL,
	[PeriodStart2hr] [datetime] NOT NULL,
	[PeriodEnd2hr] [datetime] NOT NULL,
	[PeriodStart3hr] [datetime] NOT NULL,
	[PeriodEnd3hr] [datetime] NOT NULL,
	[PeriodStart6hr] [datetime] NOT NULL,
	[PeriodEnd6hr] [datetime] NOT NULL,
	[PeriodStart12hr] [datetime] NOT NULL,
	[PeriodEnd12hr] [datetime] NOT NULL,
	[OnTheHourInd] [char](1) NOT NULL,
	[DW_ModifiedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED 
(
	[TimeSK] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* VIEW NAME: PBI.vwDimTime
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* VIEW DESC: Power BI reporting view
*
****************************************************************************************************
* DATE:			Developer 			Change
  --------		----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/
CREATE VIEW [PBI].[vwDimTime]
AS
SELECT TimeSK,
       CAST(Time AS TIME(0)) AS [Time],
       HourOfTheDay AS [Hour Of The Day],
       AMPMHourOfTheDay AS [AMPM Hour Of The Day],
       MinuteOfTheDay AS [Minute Of The Day],
       SecondOfTheDay AS [Second Of The Day],
       AMPM AS [AMPM],
       HoursToNextDay AS [Hours To Next Day],
       MinutesToNextDay AS [Minutes To Next Day],
       SecondsToNextDay AS [Seconds To Next Day],
       CAST(PeriodStart15 AS TIME(0)) AS [Period Start 15],
       CAST(PeriodEnd15 AS TIME(0)) AS [Period End 15],
       CAST(PeriodStart30 AS TIME(0)) AS [Period Start 30],
       CAST(PeriodEnd30 AS TIME(0)) AS [Period End 30],
       CAST(PeriodStart60 AS TIME(0)) AS [Period Start 60],
       CAST(PeriodEnd60 AS TIME(0)) AS [Period End 60],
       CAST(PeriodStart2hr AS TIME(0)) AS [Period Start 2hr],
       CAST(PeriodEnd2hr AS TIME(0)) AS [Period End 2hr],
       CAST(PeriodStart3hr AS TIME(0)) AS [Period Start 3hr],
       CAST(PeriodEnd3hr AS TIME(0)) AS [Period End 3hr],
       CAST(PeriodStart6hr AS TIME(0)) AS [Period Start 6hr],
       CAST(PeriodEnd6hr AS TIME(0)) AS [Period End 6hr],
       CAST(PeriodStart12hr AS TIME(0)) AS [Period Start 12hr],
       CAST(PeriodEnd12hr AS TIME(0)) AS [Period End 12hr],
       OnTheHourInd AS [On The Hour Ind]
FROM IDW.DimTime;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SRC].[ADWORKS_Production_Product](
	[ProductID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [bit] NOT NULL,
	[FinishedGoodsFlag] [bit] NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [decimal](18, 2) NOT NULL,
	[ListPrice] [decimal](18, 2) NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [varchar](100) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[DW_ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [PK_Product_ProductID] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SRC].[ADWORKS_Sales_SalesOrderDetail](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[UnitPriceDiscount] [decimal](18, 2) NOT NULL,
	[LineTotal] [decimal](18, 2) NULL,
	[rowguid] [varchar](100) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[DW_ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED 
(
	[SalesOrderID] ASC,
	[SalesOrderDetailID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SRC].[AZADWORKS_SalesLT_Address](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateProvince] [nvarchar](50) NOT NULL,
	[CountryRegion] [nvarchar](50) NOT NULL,
	[PostalCode] [nvarchar](15) NOT NULL,
	[rowguid] [nvarchar](100) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[DW_ModifiedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SRC].[CANNING_WaterQuality](
	[ID] [varchar](100) NULL,
	[DeviceID] [varchar](100) NULL,
	[ObservationTimestamp] [varchar](100) NULL,
	[LocalTimestamp] [datetime] NULL,
	[DissolvedOxygen] [decimal](18, 2) NULL,
	[WaterConductivity] [decimal](18, 2) NULL,
	[WaterPh] [decimal](18, 2) NULL,
	[WaterTemperature] [decimal](18, 2) NULL,
	[DW_ModifiedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SRC].[FLIGHT_ONTIME_REPORTING](
	[YEAR] [nvarchar](max) NULL,
	[QUARTER] [nvarchar](max) NULL,
	[MONTH] [nvarchar](max) NULL,
	[DAY_OF_MONTH] [nvarchar](max) NULL,
	[DAY_OF_WEEK] [nvarchar](max) NULL,
	[FL_DATE] [nvarchar](max) NULL,
	[OP_UNIQUE_CARRIER] [nvarchar](max) NULL,
	[OP_CARRIER_AIRLINE_ID] [nvarchar](max) NULL,
	[OP_CARRIER] [nvarchar](max) NULL,
	[TAIL_NUM] [nvarchar](max) NULL,
	[OP_CARRIER_FL_NUM] [nvarchar](max) NULL,
	[ORIGIN_AIRPORT_ID] [nvarchar](max) NULL,
	[ORIGIN_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[ORIGIN_CITY_MARKET_ID] [nvarchar](max) NULL,
	[ORIGIN] [nvarchar](max) NULL,
	[ORIGIN_CITY_NAME] [nvarchar](max) NULL,
	[ORIGIN_STATE_ABR] [nvarchar](max) NULL,
	[ORIGIN_STATE_FIPS] [nvarchar](max) NULL,
	[ORIGIN_STATE_NM] [nvarchar](max) NULL,
	[ORIGIN_WAC] [nvarchar](max) NULL,
	[DEST_AIRPORT_ID] [nvarchar](max) NULL,
	[DEST_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[DEST_CITY_MARKET_ID] [nvarchar](max) NULL,
	[DEST] [nvarchar](max) NULL,
	[DEST_CITY_NAME] [nvarchar](max) NULL,
	[DEST_STATE_ABR] [nvarchar](max) NULL,
	[DEST_STATE_FIPS] [nvarchar](max) NULL,
	[DEST_STATE_NM] [nvarchar](max) NULL,
	[DEST_WAC] [nvarchar](max) NULL,
	[CRS_DEP_TIME] [nvarchar](max) NULL,
	[DEP_TIME] [nvarchar](max) NULL,
	[DEP_DELAY] [nvarchar](max) NULL,
	[DEP_DELAY_NEW] [nvarchar](max) NULL,
	[DEP_DEL15] [nvarchar](max) NULL,
	[DEP_DELAY_GROUP] [nvarchar](max) NULL,
	[DEP_TIME_BLK] [nvarchar](max) NULL,
	[TAXI_OUT] [nvarchar](max) NULL,
	[WHEELS_OFF] [nvarchar](max) NULL,
	[WHEELS_ON] [nvarchar](max) NULL,
	[TAXI_IN] [nvarchar](max) NULL,
	[CRS_ARR_TIME] [nvarchar](max) NULL,
	[ARR_TIME] [nvarchar](max) NULL,
	[ARR_DELAY] [nvarchar](max) NULL,
	[ARR_DELAY_NEW] [nvarchar](max) NULL,
	[ARR_DEL15] [nvarchar](max) NULL,
	[ARR_DELAY_GROUP] [nvarchar](max) NULL,
	[ARR_TIME_BLK] [nvarchar](max) NULL,
	[CANCELLED] [nvarchar](max) NULL,
	[CANCELLATION_CODE] [nvarchar](max) NULL,
	[DIVERTED] [nvarchar](max) NULL,
	[CRS_ELAPSED_TIME] [nvarchar](max) NULL,
	[ACTUAL_ELAPSED_TIME] [nvarchar](max) NULL,
	[AIR_TIME] [nvarchar](max) NULL,
	[FLIGHTS] [nvarchar](max) NULL,
	[DISTANCE] [nvarchar](max) NULL,
	[DISTANCE_GROUP] [nvarchar](max) NULL,
	[CARRIER_DELAY] [nvarchar](max) NULL,
	[WEATHER_DELAY] [nvarchar](max) NULL,
	[NAS_DELAY] [nvarchar](max) NULL,
	[SECURITY_DELAY] [nvarchar](max) NULL,
	[LATE_AIRCRAFT_DELAY] [nvarchar](max) NULL,
	[FIRST_DEP_TIME] [nvarchar](max) NULL,
	[TOTAL_ADD_GTIME] [nvarchar](max) NULL,
	[LONGEST_ADD_GTIME] [nvarchar](max) NULL,
	[DIV_AIRPORT_LANDINGS] [nvarchar](max) NULL,
	[DIV_REACHED_DEST] [nvarchar](max) NULL,
	[DIV_ACTUAL_ELAPSED_TIME] [nvarchar](max) NULL,
	[DIV_ARR_DELAY] [nvarchar](max) NULL,
	[DIV_DISTANCE] [nvarchar](max) NULL,
	[DIV1_AIRPORT] [nvarchar](max) NULL,
	[DIV1_AIRPORT_ID] [nvarchar](max) NULL,
	[DIV1_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[DIV1_WHEELS_ON] [nvarchar](max) NULL,
	[DIV1_TOTAL_GTIME] [nvarchar](max) NULL,
	[DIV1_LONGEST_GTIME] [nvarchar](max) NULL,
	[DIV1_WHEELS_OFF] [nvarchar](max) NULL,
	[DIV1_TAIL_NUM] [nvarchar](max) NULL,
	[DIV2_AIRPORT] [nvarchar](max) NULL,
	[DIV2_AIRPORT_ID] [nvarchar](max) NULL,
	[DIV2_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[DIV2_WHEELS_ON] [nvarchar](max) NULL,
	[DIV2_TOTAL_GTIME] [nvarchar](max) NULL,
	[DIV2_LONGEST_GTIME] [nvarchar](max) NULL,
	[DIV2_WHEELS_OFF] [nvarchar](max) NULL,
	[DIV2_TAIL_NUM] [nvarchar](max) NULL,
	[DIV3_AIRPORT] [nvarchar](max) NULL,
	[DIV3_AIRPORT_ID] [nvarchar](max) NULL,
	[DIV3_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[DIV3_WHEELS_ON] [nvarchar](max) NULL,
	[DIV3_TOTAL_GTIME] [nvarchar](max) NULL,
	[DIV3_LONGEST_GTIME] [nvarchar](max) NULL,
	[DIV3_WHEELS_OFF] [nvarchar](max) NULL,
	[DIV3_TAIL_NUM] [nvarchar](max) NULL,
	[DIV4_AIRPORT] [nvarchar](max) NULL,
	[DIV4_AIRPORT_ID] [nvarchar](max) NULL,
	[DIV4_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[DIV4_WHEELS_ON] [nvarchar](max) NULL,
	[DIV4_TOTAL_GTIME] [nvarchar](max) NULL,
	[DIV4_LONGEST_GTIME] [nvarchar](max) NULL,
	[DIV4_WHEELS_OFF] [nvarchar](max) NULL,
	[DIV4_TAIL_NUM] [nvarchar](max) NULL,
	[DIV5_AIRPORT] [nvarchar](max) NULL,
	[DIV5_AIRPORT_ID] [nvarchar](max) NULL,
	[DIV5_AIRPORT_SEQ_ID] [nvarchar](max) NULL,
	[DIV5_WHEELS_ON] [nvarchar](max) NULL,
	[DIV5_TOTAL_GTIME] [nvarchar](max) NULL,
	[DIV5_LONGEST_GTIME] [nvarchar](max) NULL,
	[DIV5_WHEELS_OFF] [nvarchar](max) NULL,
	[DIV5_TAIL_NUM] [nvarchar](max) NULL,
	[_c109] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SRC].[REF_PublicHolidays](
	[Date] [date] NULL,
	[Year] [smallint] NULL,
	[Month] [smallint] NULL,
	[PublicHoliday] [varchar](10) NULL,
	[Description] [varchar](100) NULL,
	[DW_ModifiedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STG].[DimDate](
	[DateSK] [bigint] NOT NULL,
	[Date] [date] NOT NULL,
	[DayName] [varchar](9) NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[DayOfMonth] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[DaySuffix] [varchar](4) NOT NULL,
	[MonthName] [varchar](9) NOT NULL,
	[MonthShortName] [char](3) NOT NULL,
	[MonthNumberOfYear] [tinyint] NOT NULL,
	[MonthNumberSinceStart] [smallint] NOT NULL,
	[MonthStartDate] [date] NOT NULL,
	[MonthEndDate] [date] NOT NULL,
	[MonthYear] [varchar](8) NOT NULL,
	[WeekNumberOfYear] [smallint] NOT NULL,
	[WeekNumberSinceStart] [smallint] NOT NULL,
	[WeekdayInd] [char](1) NOT NULL,
	[WeekStartDate] [date] NOT NULL,
	[WeekEndDate] [date] NOT NULL,
	[WeekName] [varchar](7) NOT NULL,
	[CalendarQuarterNumber] [tinyint] NOT NULL,
	[CalendarQuarterName] [char](6) NOT NULL,
	[Year] [smallint] NOT NULL,
	[LastDayOfMonthInd] [char](1) NOT NULL,
	[FiscalMonthNumber] [int] NOT NULL,
	[FiscalQuarterNumber] [int] NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[FiscalQuarterName] [varchar](6) NOT NULL,
	[CalendarHalfNumber] [tinyint] NOT NULL,
	[CalendarHalfName] [char](6) NOT NULL,
	[FiscalHalfNumber] [tinyint] NOT NULL,
	[FiscalHalfName] [char](6) NOT NULL,
	[EndOfPreviousMonth] [date] NOT NULL,
	[TodayInd] [char](1) NOT NULL,
	[YesterdayInd] [char](1) NOT NULL,
	[LoadDateInd] [char](1) NOT NULL,
	[CalendarYearMonth] [varchar](6) NOT NULL,
	[EndOfCurrentMonthInd] [char](1) NOT NULL,
	[CurrentMTDInd] [char](1) NOT NULL,
	[CurrentHTDInd] [char](1) NOT NULL,
	[CurrentYTDInd] [char](1) NOT NULL,
	[CurrentFYTDInd] [char](1) NOT NULL,
	[CurrentRollingYearInd] [char](1) NOT NULL,
	[DayRelative] [int] NOT NULL,
	[WeekRelative] [int] NOT NULL,
	[MonthRelative] [int] NOT NULL,
	[QuarterRelative] [int] NOT NULL,
	[YearRelative] [int] NOT NULL,
	[NationalHolidayInd] [char](1) NOT NULL,
	[NationalHolidayName] [varchar](30) NOT NULL,
	[DW_ModifiedDateTime] [datetime] NULL,
 CONSTRAINT [PK_STGDimDate] PRIMARY KEY CLUSTERED 
(
	[DateSK] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STG].[DimTime](
	[Time] [datetime] NOT NULL,
	[HourOfTheDay] [tinyint] NOT NULL,
	[AMPMHourOfTheDay] [tinyint] NOT NULL,
	[MinuteOfTheDay] [smallint] NOT NULL,
	[SecondOfTheDay] [int] NOT NULL,
	[AMPM] [varchar](2) NOT NULL,
	[HoursToNextDay] [tinyint] NOT NULL,
	[MinutesToNextDay] [smallint] NOT NULL,
	[SecondsToNextDay] [int] NOT NULL,
	[PeriodStart15] [datetime] NOT NULL,
	[PeriodEnd15] [datetime] NOT NULL,
	[PeriodStart30] [datetime] NOT NULL,
	[PeriodEnd30] [datetime] NOT NULL,
	[PeriodStart60] [datetime] NOT NULL,
	[PeriodEnd60] [datetime] NOT NULL,
	[PeriodStart2hr] [datetime] NOT NULL,
	[PeriodEnd2hr] [datetime] NOT NULL,
	[PeriodStart3hr] [datetime] NOT NULL,
	[PeriodEnd3hr] [datetime] NOT NULL,
	[PeriodStart6hr] [datetime] NOT NULL,
	[PeriodEnd6hr] [datetime] NOT NULL,
	[PeriodStart12hr] [datetime] NOT NULL,
	[PeriodEnd12hr] [datetime] NOT NULL,
	[OnTheHourInd] [char](1) NOT NULL,
	[DW_ModifiedDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_PBIRefreshConfig] ON [CTL].[PBIRefreshConfig]
(
	[GroupName] ASC,
	[PBIWorkspaceId] ASC,
	[PBIDatasetId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_SourceConfig] ON [CTL].[SourceConfig]
(
	[SourceName] ASC,
	[SourceLocation] ASC,
	[RunFrequency] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_SourceEnvironments] ON [CTL].[SourceEnvironments]
(
	[SourceName] ASC,
	[SourceEnvironment] ASC,
	[SourceDatabase] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_StarConfig] ON [CTL].[StarConfig]
(
	[GroupName] ASC,
	[ProcName] ASC,
	[RunFrequency] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_DimDate] ON [IDW].[DimDate]
(
	[Date] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [CTL].[BatchLog] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [CreatedOn]
GO
ALTER TABLE [CTL].[PBIRefreshConfig] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [Created]
GO
ALTER TABLE [CTL].[PBIRefreshLog] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [CreatedOn]
GO
ALTER TABLE [CTL].[SourceConfig] ADD  DEFAULT ('Not Applicable') FOR [DatabricksNotebookName]
GO
ALTER TABLE [CTL].[SourceConfig] ADD  DEFAULT ('Not Applicable') FOR [DatabricksNotebookPath]
GO
ALTER TABLE [CTL].[SourceConfig] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [Created]
GO
ALTER TABLE [CTL].[SourceEnvironments] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [Created]
GO
ALTER TABLE [CTL].[SourceLog] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [CreatedOn]
GO
ALTER TABLE [CTL].[StarConfig] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [Created]
GO
ALTER TABLE [CTL].[StarLog] ADD  DEFAULT ([CTL].[fn_getSystemDateTime]()) FOR [CreatedOn]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* PROCEDURE NAME: CTL.copySilverToProcessed
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Backs up files with a timestamp in the /processed directory in the data lake.  
*				  Ensures history is maintained when multiple loads occur in the same day.
*
* TEST: EXEC CTL.copySilverToProcessed 'AdventureWorks', 'SQL Server', 'Daily'
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/

CREATE   PROCEDURE [CTL].[copySilverToProcessed]
(
    @sourceName VARCHAR(255),
    @sourceType VARCHAR(255),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

	DECLARE @today DATETIME = CTL.fn_getSystemDateTime()
	DECLARE @yearFolder CHAR(4) = CONVERT(CHAR(4), YEAR(@today)) + '/' + RIGHT('0' + CONVERT(CHAR(4), MONTH(@today)), 2)
	DECLARE @monthFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), MONTH(@today)), 2)
	DECLARE @dayFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), DAY(@today)), 2)


    SELECT sc.Id,
           sc.SourceName AS sourceName,
           sc.SourceType AS sourceType,
           sc.ContainerName AS containerName,
           sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder AS folderName,
           sc.BLOBName + '.parquet' AS blobName, 
		   sc.ContainerName AS destContainerName,
           sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder + '/processed' AS destFolder,
		   sc.BLOBName + '_' + REPLACE(CONVERT(VARCHAR(20), @today, 111),'/','') + '_' 
					   + REPLACE(CONVERT(VARCHAR(20), @today, 108),':','') + '.parquet' AS destBlobName,
           @today AS ExecutionTime
    FROM CTL.SourceConfig sc
    WHERE sc.SourceType = @sourceType
          AND sc.SourceName = @sourceName
		  AND sc.RunFrequency = @runFrequency
          AND sc.IsRunnable = 1;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***************************************************************************************************
* PROCEDURE NAME: CTL.createMergeProc
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Creates a stored procedure to merge from source to target as specified
*		          @mergeType :	    0 = Merge, 
*									1 = Truncate & Load,
*									2 = SCD2,
*									3 = Append (Insert into select)
*
*				  Input (source) for MERGE should be a view with following extended property (add multiple extended properties for a composite key)
*
*				  EXECUTE sp_addextendedproperty @name = N'Column Role Description',
*				                            @value = N'Key Column',
*				                            @level0type = N'SCHEMA',
*				                            @level0name = N'STG',
*				                            @level1type = N'VIEW',
*				                            @level1name = N'vwDimProject',
*				                            @level2type = N'COLUMN',
*				                            @level2name = N'ProjectId';
*
*				  Target table for MERGE must have a single unique index defined
*
* TEST: EXEC CTL.createMergeProc 0, 'SRC', 'vwDimProject', 'IDW', 'DimProject', 'mergeDimProject'
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/


CREATE     PROCEDURE [CTL].[createMergeProc]
    @mergeType INT,
    @sourceSchema VARCHAR(255),
    @sourceView VARCHAR(255),
    @targetSchema VARCHAR(255),
    @targetTable VARCHAR(255),
    @storedProc AS VARCHAR(255)
AS
BEGIN

    ---check if schema already created
    IF SCHEMA_ID(@targetSchema) IS NULL
    BEGIN
        PRINT ('Create Schema: ' + @targetSchema);
        EXEC ('CREATE SCHEMA ' + @targetSchema);
        --SELECT @targetSchema
        PRINT ('Create Schema: ' + @targetSchema + ' Successful');
    END;
    ELSE
    BEGIN
        PRINT (@targetSchema + ' Schema Already Present');
    END;

    --check for target schema and table and create
    IF NOT EXISTS
    (
         SELECT TABLE_NAME
         FROM INFORMATION_SCHEMA.TABLES
         WHERE LTRIM(RTRIM(TABLE_SCHEMA)) = LTRIM(RTRIM(@targetSchema))
         AND LTRIM(RTRIM(TABLE_NAME)) = LTRIM(RTRIM(@targetTable))
    )
    BEGIN
        PRINT (@targetTable + ' - Table Not Present');
        PRINT ('Create Table: ' + @targetTable);

        DECLARE @TableList TABLE
        (
            Table_Catalog VARCHAR(50) NULL,
            Table_Schema VARCHAR(255) NULL,
            Table_Name VARCHAR(255) NULL,
            SQL_CreateTable VARCHAR(MAX) NULL
        );
        INSERT INTO @TableList
        SELECT t.TABLE_CATALOG,
               t.TABLE_SCHEMA,
               t.TABLE_NAME,
               'CREATE TABLE ' + LTRIM(RTRIM(@targetSchema)) + '.' + LTRIM(RTRIM(@targetTable)) + ' ('
               + REPLACE(@targetTable, 'Dim', '') + 'Key BigInt IDENTITY(1,1) NOT NULL, '
               + LEFT(o.list, LEN(o.list) - 1)
               + ', [Deleted] bit DEFAULT ''FALSE'', [DW_Active] bit DEFAULT ''TRUE'', [InsertedDateTime] datetime DEFAULT CTL.fn_getSystemDateTime(), [DW_ModifiedDateTime] datetime NULL'
               + CASE
                     WHEN @mergeType = 2 THEN
                         ',[DW_ValidFrom] datetime DEFAULT CTL.fn_getSystemDateTime(), [DW_ValidTo] datetime DEFAULT ''9999-12-31'' );'
                     ELSE
                         ');  '
                 END
               + CASE
                     WHEN j.list IS NULL THEN
                         ''
                     ELSE
                         'ALTER TABLE ' + LTRIM(RTRIM(@targetSchema)) + '.' + LTRIM(RTRIM(@targetTable))
                         + ' ADD CONSTRAINT ' + 'PK_' + LTRIM(RTRIM(@targetTable)) + ' PRIMARY KEY ' + ' ('
                         + REPLACE(@targetTable, 'Dim', '') + 'Key );  '
                 END AS 'SQL_CREATE_TABLE'
        FROM INFORMATION_SCHEMA.TABLES t

            --get columns
            CROSS APPLY
        (
            SELECT '  [' + COLUMN_NAME + '] ' + DATA_TYPE
                   + CASE DATA_TYPE
                         WHEN 'sql_variant' THEN
                             ''
                         WHEN 'text' THEN
                             ''
                         WHEN 'ntext' THEN
                             ''
                         WHEN 'decimal' THEN
                             '(' + CAST(NUMERIC_PRECISION AS VARCHAR) + ', ' + CAST(NUMERIC_SCALE AS VARCHAR) + ')'
                         WHEN 'numeric' THEN
                             '(' + CAST(NUMERIC_PRECISION AS VARCHAR) + ', ' + CAST(NUMERIC_SCALE AS VARCHAR) + ')'
                         ELSE
                             COALESCE(   '(' + CASE
                                                   WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN
                                                       'MAX'
                                                   ELSE
                                                       CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR)
                                               END + ')',
                                         ''
                                     )
                     END + ' ' + (CASE
                                      WHEN IS_NULLABLE = 'No' THEN
                                          'NOT '
                                      ELSE
                                          ''
                                  END
                                 ) + 'NULL ' + CASE
                                                   WHEN COLUMN_DEFAULT IS NOT NULL THEN
                                                       'DEFAULT ' + COLUMN_DEFAULT
                                                   ELSE
                                                       ''
                                               END + ','
            FROM INFORMATION_SCHEMA.COLUMNS sc
            WHERE TABLE_NAME = t.TABLE_NAME
            ORDER BY ORDINAL_POSITION
            FOR XML PATH('')
        ) o(list)

            --get key columns
            CROSS APPLY
        (
            SELECT QUOTENAME(c.name) + ', '
            FROM sys.extended_properties AS ep
                INNER JOIN sys.views AS v
                    ON ep.major_id = v.object_id
                INNER JOIN sys.columns AS c
                    ON ep.major_id = c.object_id
                       AND ep.minor_id = c.column_id
            WHERE ep.[value] = 'Key Column'
                  AND v.name = t.TABLE_NAME
            ORDER BY minor_id
            FOR XML PATH('')
        ) j(list)
        WHERE t.TABLE_SCHEMA = @sourceSchema
              AND t.TABLE_NAME = @sourceView
              AND t.TABLE_TYPE = 'VIEW';

        DECLARE @SQLString AS VARCHAR(MAX);
        SET @SQLString =
        (
            SELECT SQL_CreateTable
            FROM @TableList
            WHERE Table_Schema = @sourceSchema
                  AND Table_Name = @sourceView
        );

        EXEC (@SQLString);
        --SELECT (@SQLString) AS SQLString;
        PRINT ('Create Table: ' + @targetTable + ' Successful');
    END;
    ELSE
    BEGIN
        PRINT (@targetTable + ' Target Table Already Present');
    END;

    --check for target proc and create	
    IF OBJECT_ID(@targetSchema + '.' + @storedProc, 'P') IS NULL
    BEGIN
        PRINT (@storedProc + ' - SP Not Present');
        PRINT ('Create SP: ' + @targetSchema + '.' + @storedProc);

        DECLARE @Source TABLE
        (
            Source_Row INT NOT NULL,
            Source_Schema VARCHAR(255) NOT NULL,
            Source_Table VARCHAR(255) NOT NULL,
            Source_Column VARCHAR(255) NOT NULL,
            Source_Key_Column INT NULL
        );

      -- all join to sys.schemas so we can also pass in the source schema name (the same view can exist in different schemas)
        INSERT INTO @Source
        (
            Source_Row,
            Source_Schema,
            Source_Table,
            Source_Column,
            Source_Key_Column
        )
        SELECT c.column_id [Source_Row],
               @targetSchema,
               sv.name AS [Source_Table],
               c.name [Source_Column],
               CASE
                   WHEN ep.value = 'Key Column' THEN
                       1
                   ELSE
                       0
               END AS [Source_Key_Column]
        FROM sys.views sv
            INNER JOIN sys.schemas sc ON (sv.schema_id = sc.schema_id)
            INNER JOIN sys.columns AS c
                ON sv.object_id = c.object_id
            LEFT JOIN sys.extended_properties AS ep
                ON sv.object_id = ep.major_id
                   AND ep.minor_id = c.column_id

            ---Match to Columns in target table
            CROSS APPLY
        (
            SELECT DISTINCT
                   t.COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS t
            WHERE t.COLUMN_NAME = c.name
                  AND t.TABLE_NAME = @targetTable
                  AND t.TABLE_SCHEMA = @targetSchema
        ) ca
        WHERE sv.name = @sourceView
        AND sc.name = @sourceSchema
        AND [type] = 'V';

        --Create result set and SQL string
        DECLARE @ResultSet TABLE
        (
            [Schema] VARCHAR(255) NULL,
            [SourceView] VARCHAR(255) NULL,
            TargetTable VARCHAR(255) NULL,
            SQLString0 VARCHAR(MAX) NULL,
            SQLString1 VARCHAR(MAX) NULL,
            SQLString2 VARCHAR(MAX) NULL,
            SQLString3 VARCHAR(MAX) NULL
        );
        INSERT INTO @ResultSet
        SELECT DISTINCT
               '[' + so.Source_Schema + ']' AS [Schema],
               so.Source_Table AS SourceView,
               @targetTable AS TargetTable,
               '/**************************************************************************************
* DATABASE: DW
* PROCEDURE NAME: ' + @targetSchema + '.' + @storedProc + '
* DATE: ' +    CAST(CTL.fn_getSystemDateTime() AS VARCHAR(35)) + '
* AUTHOR: CTL.createMergeProc
* TEST: EXEC ' + @targetSchema + '.' + @storedProc
               + '
**************************************************************************************/

CREATE OR ALTER PROCEDURE ' + @targetSchema + '.' + @storedProc
               + ' AS
 BEGIN
 SET NOCOUNT ON

 DECLARE @today DATETIME = CTL.fn_getSystemDateTime()
  
 	   MERGE [' + @targetSchema + '].' + @targetTable + ' AS TARGET  
	   USING [' + @sourceSchema + '].[' + @sourceView + '] AS SOURCE  
	   ON '    + LEFT(mk.list, LEN(mk.list) - 3) + '
	   WHEN MATCHED 
					
					AND EXISTS 
	   (
		SELECT  ' + REPLACE(LEFT(sme.list, LEN(sme.list) - 1), ',', '
			,  ') + ' 
		EXCEPT 
		SELECT  ' + REPLACE(LEFT(tme.list, LEN(tme.list) - 1), ',', '
			,  ') + '
	   )
	   THEN UPDATE SET 
					  ' + REPLACE(LEFT(us.list, LEN(us.list) - 1), ',', '
					,')
               + '
					, TARGET.DW_ModifiedDateTime = @today
	   WHEN NOT  MATCHED 
	   THEN INSERT 
	   ( 
		 '     + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', ',  ')     + ',	 DW_ModifiedDateTime) 
	   VALUES 
	   ( 
		 '     + REPLACE(LEFT(sme.list, LEN(sme.list) - 1), ',', ',  ')     + ',	 @today);   
 END'          AS SQLString0,
               '/**************************************************************************************
* DATABASE: DW
* PROCEDURE NAME: ' + @targetSchema + '.' + @storedProc + '
* DATE: ' +    CAST(CTL.fn_getSystemDateTime() AS VARCHAR(35)) + '
* AUTHOR: CTL.createMergeProc
* TEST: EXEC ' + @targetSchema + '.' + @storedProc
               + '
**************************************************************************************/

CREATE OR ALTER PROCEDURE ' + @targetSchema + '.' + @storedProc + '
AS 
BEGIN 
	SET NOCOUNT ON

	DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

	TRUNCATE TABLE ' + @targetSchema + '.' + @targetTable + ';

	INSERT INTO '  + LTRIM(RTRIM(@targetSchema)) + '.' + LTRIM(RTRIM(@targetTable)) + '('
		          + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', ',  ')     + ',	 DW_ModifiedDateTime)  
	SELECT '       +  REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', ',  ')     + ',	 @today 
	  FROM  ' + @sourceSchema + '.' + @sourceView + ';   
END
'              AS SQLString1,
               '/**************************************************************************************
* DATABASE: DW
* PROCEDURE NAME: ' + @targetSchema + '.' + @storedProc + '
* DATE: ' +    CAST(CTL.fn_getSystemDateTime() AS VARCHAR(35)) + '
* AUTHOR: CTL.createMergeProc
* TEST: EXEC ' + @targetSchema + '.' + @storedProc
               + '
**************************************************************************************/

CREATE OR ALTER PROCEDURE ' + @targetSchema + '.' + @storedProc
               + ' AS
 BEGIN
 SET NOCOUNT ON

 DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

 INSERT INTO  [' + @targetSchema + '].' + @targetTable + '
	   ( 
		 '     + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', '
	 ,  ')     + '
	   ) 
	   SELECT 
		 '     + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', '
	 ,  ')     + '
	   FROM (
 	   MERGE [' + @targetSchema + '].' + @targetTable + ' AS TARGET  
	   USING [' + @sourceSchema + '].[' + @sourceView + '] AS SOURCE  
	   ON '    + LEFT(mk.list, LEN(mk.list) - 3)
               + '
	   AND TARGET.DW_Active = 1
	   WHEN MATCHED 
					
					AND EXISTS 
	   (
		SELECT  ' + REPLACE(LEFT(sme.list, LEN(sme.list) - 1), ',', '
			,  ') + ' 
		EXCEPT 
		SELECT  ' + REPLACE(LEFT(tme.list, LEN(tme.list) - 1), ',', '
			,  ')
               + '
	   )
	   THEN UPDATE SET 

					TARGET.DW_ModifiedDateTime = @today
				,   TARGET.DW_ValidTo = @today-1
				,   TARGET.DW_Active = 0
	   WHEN NOT  MATCHED 
	   THEN INSERT 
	   ( 
		 '     + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', '
	 ,  ')     + '
	   ) 
	   VALUES 
	   ( 
		 '     + REPLACE(LEFT(sme.list, LEN(sme.list) - 1), ',', '
	 ,  ')     + '
	   )
	   OUTPUT $action
	 ,   '     + REPLACE(LEFT(sme.list, LEN(sme.list) - 1), ',', '
	 ,  ')     + '
	 ,   @today
	 ,  ''9999-12-31''
	 )--END OF FROM 
	 as changes
	 (   action
	 ,   '     + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', '
	 ,  ')     + '
	 ,   DW_ValidFrom
	 ,   DW_ValidTo
	 ) 
	 WHERE action = ''UPDATE'';   
 END'          AS SQLString2,
               '/**************************************************************************************
* DATABASE: DW
* PROCEDURE NAME: ' + @targetSchema + '.' + @storedProc + '
* DATE: ' +    CAST(CTL.fn_getSystemDateTime() AS VARCHAR(35)) + '
* AUTHOR: CTL.createMergeProc
* TEST: EXEC ' + @targetSchema + '.' + @storedProc
               + '
**************************************************************************************/

CREATE OR ALTER PROCEDURE ' + @targetSchema + '.' + @storedProc + ' AS BEGIN SET NOCOUNT ON

INSERT INTO '  + LTRIM(RTRIM(@targetSchema)) + '.' + LTRIM(RTRIM(@targetTable)) + '('
               + REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', ',') + ') 
SELECT '       +  REPLACE(LEFT(sac.list, LEN(sac.list) - 1), ',', ',') + ' FROM  ' + @sourceSchema + '.' + @sourceView
               + ';   
END
'              AS SQLString3
        FROM @Source so
            --Matched key columns 
            CROSS APPLY
        (
            SELECT ('TARGET.' + QUOTENAME(Source_Column) + ' = SOURCE.' + QUOTENAME(Source_Column)) + ' AND '
            FROM @Source mc
            WHERE LTRIM(RTRIM(mc.Source_Table)) = LTRIM(RTRIM(so.Source_Table))
                  AND mc.Source_Key_Column IN ( 1 )
            ORDER BY Source_Row
            FOR XML PATH('')
        ) mk(list)

            --Source matched and exists
            CROSS APPLY
        (
            SELECT 'SOURCE.' + QUOTENAME(Source_Column) + ', '
            FROM @Source mc
            WHERE mc.Source_Table = so.Source_Table
            ORDER BY Source_Row
            FOR XML PATH('')
        ) sme(list)

            --Target matched And exists
            CROSS APPLY
        (
            SELECT 'TARGET.' + QUOTENAME(Source_Column) + ', '
            FROM @Source mc
            WHERE mc.Source_Table = so.Source_Table
            ORDER BY Source_Row
            FOR XML PATH('')
        ) tme(list)

            --Source attribute columns
            CROSS APPLY
        (
            SELECT QUOTENAME(Source_Column) + ', '
            FROM @Source mc
            WHERE mc.Source_Table = so.Source_Table
            ORDER BY Source_Row
            FOR XML PATH('')
        ) sac(list)

            --Update set
            CROSS APPLY
        (
            SELECT ('TARGET.' + QUOTENAME(Source_Column) + ' = SOURCE.' + QUOTENAME(Source_Column)) + ', '
            FROM @Source mc
            WHERE mc.Source_Table = so.Source_Table
                  AND mc.Source_Key_Column NOT IN ( 1 )
                  AND mc.Source_Column NOT IN ( 'DW_BatchID' )
                  AND mc.Source_Column NOT IN ( 'DW_ModifiedByBatch' )
            ORDER BY Source_Row
            FOR XML PATH('')
        ) us(list);

        PRINT ('Create SQLString for SP: ' + @targetSchema + '.' + @storedProc + ' Successful');


        DECLARE @SQLString4 AS VARCHAR(MAX);
        SET @SQLString4 =
        (
            SELECT CASE
                       WHEN @mergeType = 1 THEN
                           [SQLString1]
                       WHEN @mergeType = 2 THEN
                           [SQLString2]
                       WHEN @mergeType = 3 THEN
                           [SQLString3]
                       ELSE
                           [SQLString0]
                   END AS SQLString
            FROM @ResultSet
            WHERE [SourceView] = @sourceView
        );
        IF @SQLString4 IS NOT NULL
        BEGIN
            EXEC (@SQLString4);
            --PRINT (@SQLString4);
            PRINT ('Execute SQLString for SP: ' + @targetSchema + '.' + @storedProc + ' Successful');
        END;

        ELSE
        BEGIN
            PRINT ('SQL String: ' + @SQLString4 + ' is empty');
        END;
    END;
    ELSE
    BEGIN

        PRINT (@targetSchema + '.' + @storedProc + ' Stored procedure already present');
    END;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generateBatchLogID
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Generates a unique run ID for a pipeline run.
*
* TEST: EXEC CTL.generateBatchLogID
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/


CREATE   PROCEDURE [CTL].[generateBatchLogID]
(
    @DataFactoryName VARCHAR(256),
	@PipelineName VARCHAR(256),
	@PipelineRunID VARCHAR(256),
    @SourceName VARCHAR(256),
    @SourceEnvironment VARCHAR(10),
    @batchLogID INT = -1
)
AS
BEGIN

    --DECLARE @batchLogID INT;

    IF @batchLogID = -1
    BEGIN
        INSERT INTO CTL.BatchLog
        (
            [DataFactoryName],
			[PipelineName],
			[PipelineRunID],
            [SourceName],
            [SourceEnvironment],
            [Status],
            CreatedOn
        )
        VALUES
        (@DataFactoryName, @PipelineName, @PipelineRunID, @SourceName, @SourceEnvironment, 'Issued', CTL.fn_getSystemDateTime());

        SELECT @batchLogID = SCOPE_IDENTITY();
    END;

    SELECT @batchLogID AS BatchLogID;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generateDeltaView
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: For source config records that are setup as delta/incremental loads, 
*                 this creates a view and executes CTL.createMergeProc to CREATE OR ALTER the merge procedure.
*
*
****************************************************************************************************
* DATE:			Developer 			Change
----------- 	---------------- 	------------------------------------------------
 xx/xx/xxxx     Data Divers			Initial Version

****************************************************************************************************/
CREATE     PROCEDURE [CTL].[generateDeltaView]
   (@sourceName VARCHAR(255)
   , @sourceLocation VARCHAR(500)
   , @runFrequency VARCHAR(255)
   , @targetSchema VARCHAR(10) = NULL
   )
AS
BEGIN
   DECLARE @id INT
   DECLARE @sourceType VARCHAR(255)
   DECLARE @schemaName VARCHAR(10)
   DECLARE @tableName VARCHAR(255)
   DECLARE @deltaload BIT
   DECLARE @columnList VARCHAR(MAX)
   DECLARE @SQL VARCHAR(MAX)
   DECLARE @viewName VARCHAR(255)
   DECLARE @pkColumn VARCHAR(255)
   DECLARE @mergeSPName VARCHAR(255)

   SELECT
      @id = Id
      ,@deltaload = DeltaLoad
      ,@sourceType = SourceType
      ,@schemaName = DestinationSchema
      ,@tableName = DestinationTable
   FROM
      CTL.SourceConfig
   WHERE SourceName = @sourceName
     AND SourceLocation = @sourceLocation
	 AND RunFrequency = @runFrequency;

   -- Only proceed if the config record is a delta/incremental load
   IF @deltaload = 1

	   BEGIN

		  PRINT ('Source of view: ' + @schemaName + '.' + @tableName)
				  
		  SET @targetSchema = ISNULL(@targetSchema, 'SRC')
		  SET @viewName = 'vw' + @tableName
		  SET @mergeSPName = 'merge' + @tableName

		  PRINT ('View: ' + @schemaName + '.' + @viewName)
		  PRINT ('Target Schema: ' + @targetSchema)

		  -- Get column list
		  SELECT
			 @columnList = CASE 
				WHEN UPPER(@sourceType) LIKE 'SQL%'
					THEN COALESCE(@columnList + '],[', '') + c.COLUMN_NAME
				ELSE COALESCE(@columnList + ',', '') + c.COLUMN_NAME
				END
		  FROM
			 INFORMATION_SCHEMA.COLUMNS c
		  WHERE c.TABLE_SCHEMA = @schemaName
			 AND c.TABLE_NAME = @tableName
			 AND c.COLUMN_NAME <> 'DW_ModifiedDateTime'
		  ORDER BY c.ORDINAL_POSITION ASC;

		  SET @columnList = CASE 
				WHEN UPPER(@sourceType) LIKE 'SQL%'
					THEN '[' + @columnList + ']'
				ELSE @columnList
				END;

		  SET @SQL = 'DROP VIEW IF EXISTS ' + @schemaName + '.' + @viewName
		  PRINT ('DROP VIEW: ' + @SQL)
		  EXEC (@SQL);

		  SET @SQL = 'CREATE OR ALTER VIEW ' + @schemaName + '.' + @viewName + ' AS (SELECT ' + @columnList + ' FROM ' + @schemaName + '.' + @tableName + ')'
    	  PRINT ('CREATE OR ALTER VIEW: ' + @SQL)
		  EXEC (@SQL);

		  DECLARE column_cursor CURSOR
		FOR
		SELECT
			 k.COLUMN_NAME
		  FROM
			 INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
		  WHERE k.TABLE_SCHEMA = @schemaName
			 AND k.TABLE_NAME = @tableName
		  ORDER BY k.ORDINAL_POSITION ASC;

		  OPEN column_cursor;

		  FETCH NEXT
		FROM column_cursor
		INTO @pkColumn;

		  WHILE @@FETCH_STATUS = 0
		BEGIN
			 PRINT ('Found PK: ' + @pkColumn);

			 SET @SQL = 'EXECUTE sp_addextendedproperty @name = N''Column Role Description'',
												@value = N''Key Column'',
												@level0type = N''SCHEMA'',
												@level0name = N''' + @schemaName + ''',
												@level1type = N''VIEW'',
												@level1name = N''' + @viewName + ''',
												@level2type = N''COLUMN'',
												@level2name = N''' + @pkColumn + ''';'

			 PRINT ('Add Property: ' + @SQL)
             EXEC (@SQL);

			 FETCH NEXT
			FROM column_cursor
			INTO @pkColumn;
		  END;

		  CLOSE column_cursor;

		  DEALLOCATE column_cursor;

		  SET @SQL = 'DROP PROCEDURE IF EXISTS ' + @targetSchema + '.' + @mergeSPName
		  PRINT ('DROP Merge SP: ' + @SQL)
		  EXEC (@SQL);

		  SET @SQL = 'EXEC CTL.createMergeProc 0, ' + '''' + @schemaName + ''',' + '''' + @viewName + ''',' + '''' + @targetSchema + ''',' + '''' + @tableName + ''',' + '''' + @mergeSPName + ''''
		  PRINT ('CREATE OR ALTER Merge SP: ' + @SQL)
		  EXEC (@SQL);
	   END

	ELSE
	   PRINT ('Delta not required for SourceConfig.Id = ' + CAST(@id AS VARCHAR));

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generateFetchTabular
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Generates a fetch SQL for the source table (based on the defined target table definition).
*                 Generates a tabular translator for a table (code taken from CTL.generateTabularTranslator). 
*                 Used in CTL.SourceConfig to add data types to a parquet file.
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/
CREATE     PROCEDURE [CTL].[generateFetchTabular]
(
	@sourceName VARCHAR(255)
	,@sourceLocation VARCHAR(500)
	,@runFrequency VARCHAR(255)
)
AS
BEGIN

	DECLARE @id INT
	DECLARE @schemaName VARCHAR(10)
	DECLARE @tableName VARCHAR(255)
	DECLARE @sourceType VARCHAR(255)
	DECLARE @fetchSchemaName VARCHAR(50)
	DECLARE @columnList VARCHAR(MAX)
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @jsonConstruct VARCHAR(MAX) = '{"type": "TabularTranslator", "mappings": {X}}'
	DECLARE @json VARCHAR(MAX)

	SELECT
		@id = Id
		,@schemaName = DestinationSchema
		,@tableName = DestinationTable
		,@sourceType = SourceType
	FROM CTL.SourceConfig
	WHERE SourceName = @sourceName
	AND SourceLocation = @sourceLocation
	AND RunFrequency = @runFrequency;

	-- Get column list (excluding DW columns)
	SELECT
		@columnList = CASE 
						WHEN UPPER(@sourceType) LIKE 'SQL%'
							THEN COALESCE(@columnList + '],[', '') + c.COLUMN_NAME
						ELSE COALESCE(@columnList + ',', '') + c.COLUMN_NAME
					END
	FROM INFORMATION_SCHEMA.COLUMNS c
	WHERE TABLE_SCHEMA = @schemaName
	AND TABLE_NAME = @tableName
	AND COLUMN_NAME NOT IN ('DW_Company', 'DW_ModifiedDateTime')
	ORDER BY ORDINAL_POSITION ASC;

	SET @columnList = CASE 
						WHEN UPPER(@sourceType) LIKE 'SQL%'
							THEN '[' + @columnList + ']'
						ELSE @columnList
					END

	SELECT @fetchSchemaName = 'dbo'


	--generate fetch query
	SET @SQL = 'SELECT ' + @columnList + ' FROM ' + @fetchSchemaName + '.' + SUBSTRING(@tableName, CHARINDEX('_', @tableName, 1) + 1, LEN(@tableName))

	PRINT ('Updating source config record: ' + CAST(@id AS VARCHAR))

	--get data types for each column
	DROP TABLE IF EXISTS #table;

	SELECT DISTINCT
		c.column_id
		,s.[name] AS [schema_name]
		,tb.[name] AS table_name
		,c.[name] AS source_column
		,c.name AS target_column
		,CASE 
			WHEN t.[name] LIKE '%char%'
				THEN 'String'
			WHEN t.[name] LIKE '%bit%'
				THEN 'String'
			WHEN t.[name] = 'uniqueidentifier'
				THEN 'String'
			WHEN t.[name] LIKE '%int%'
				THEN 'Int64'
			WHEN t.[name] LIKE '%decimal%'
				THEN 'Decimal'
			WHEN t.[name] LIKE '%numeric%'
				THEN 'Decimal'
			WHEN t.[name] = 'real'
				THEN 'Decimal'
			WHEN t.[name] LIKE '%date%'
				THEN 'Datetime'
			ELSE t.[name]
		END AS data_type
	INTO #table
	FROM sys.columns c
		INNER JOIN sys.tables tb ON c.object_id = tb.object_id
		INNER JOIN sys.schemas s ON tb.schema_id = s.schema_id
		INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
		LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id
			AND ic.column_id = c.column_id
	WHERE tb.[name] = @tableName
	AND s.[name] = @schemaName
	ORDER BY tb.[name],
			c.column_id;

	-- generate tabular translator
	SET @json = (
				SELECT
					t.[source_column] AS [source.name]
					,t.[data_type] AS [source.type]
					,t.[target_column] AS [sink.name]
					,t.[data_type] AS [sink.type]
				FROM #table t
				WHERE t.[schema_name] = @schemaName
				AND t.[table_name] = @tableName
				FOR JSON PATH
				);

	UPDATE CTL.SourceConfig
	SET FetchQuery = @SQL,
		TabularTranslator = REPLACE(@jsonConstruct, '{X}', @json)
	WHERE Id = @id;

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generatePBIRefreshLogID
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Generates a unique run ID for a Power BI dataset refresh and writes an entry in PBIRefreshLog.
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE   PROCEDURE [CTL].[generatePBIRefreshLogID]
(
    @PBIRefreshId BIGINT,    
	@BatchLogId BIGINT,
    @PipelineName VARCHAR(255),
	@PipelineRunID VARCHAR(256),
    @GroupName VARCHAR(100),
	@PBIWorkspaceId VARCHAR(100),
	@PBIWorkspaceName VARCHAR(100),
	@PBIDatasetId VARCHAR(100),
	@PBIDatasetName VARCHAR(100),
    @Sequence INT
)
AS
BEGIN

    DECLARE @PBIRefreshLogId BIGINT;

    INSERT INTO [CTL].[PBIRefreshLog]
    (
        [PBIRefreshId]
        ,[BatchLogId]
        ,[PipelineName]
		,[PipelineRunID]
        ,[GroupName]
        ,[PBIWorkspaceId]
        ,[PBIWorkspaceName]
        ,[PBIDatasetId]
        ,[PBIDatasetName]
        ,[Sequence]
        ,[Status]
        ,[StatusDescription]
    )
    VALUES
    (@PBIRefreshId, @BatchLogId, @PipelineName, @PipelineRunID, @GroupName, @PBIWorkspaceId, @PBIWorkspaceName, @PBIDatasetId, @PBIDatasetName,
     @Sequence, 'Issued', 'Refresh Initiated');

    SELECT @PBIRefreshLogId = SCOPE_IDENTITY();

    SELECT @PBIRefreshLogId AS PBIRefreshLogId;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generateSourceLogID
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Generates a unique run ID for a pipeline run and writes an entry in SourceLog.
*
* TEST: EXEC CTL.generateSourceLogID 1, 1
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE   PROCEDURE [CTL].[generateSourceLogID]
(
    @BatchLogID BIGINT,
    @SourceConfigId BIGINT,
    @PipelineName VARCHAR(255),
	@PipelineRunID VARCHAR(256)
)
AS
BEGIN
    DECLARE @SourceLogID BIGINT;

    INSERT INTO [CTL].[SourceLog]
    (
        [SourceConfigID],
        [BatchLogID],
        [PipelineName],
		[PipelineRunID],
        [Status],
        [StatusDescription]
    )
    VALUES
    (@SourceConfigId, @BatchLogID, @PipelineName, @PipelineRunID, 'Issued', 'Process Initiated');

    SELECT @SourceLogID = SCOPE_IDENTITY();

    SELECT @SourceLogID AS SourceLogID;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generateStarLogID
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Generates a unique run ID for a star object load and writes an entry in StarLog.
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE   PROCEDURE [CTL].[generateStarLogID]
(
    @BatchLogID BIGINT,
    @StarConfigId BIGINT,
    @PipelineName VARCHAR(255),
	@PipelineRunID VARCHAR(255),
    @ProcSchema VARCHAR(100),
    @ProcName VARCHAR(100),
    @TableName VARCHAR(100),
    @ProcType VARCHAR(100),
    @RunFrequency VARCHAR(100),
    @GroupName VARCHAR(100),
    @Sequence INT,
    @ExecCommand VARCHAR(100)
)
AS
BEGIN
    DECLARE @StarLogID BIGINT;

    INSERT INTO [CTL].[StarLog]
    (
        [StarConfigID],
        [BatchLogID],
        [PipelineName],
		[PipelineRunID],
        [ProcSchema],
        [ProcName],
        [TableName],
        [ProcType],
        [RunFrequency],
        [GroupName],
        [Sequence],
        [ExecCommand],
        [Status],
        [StatusDescription]
    )
    VALUES
    (@StarConfigId, @BatchLogID, @PipelineName, @PipelineRunID, @ProcSchema, @ProcName, @TableName, @ProcType, @RunFrequency, @GroupName,
     @Sequence, @ExecCommand, 'Issued', 'Process Initiated');

    SELECT @StarLogID = SCOPE_IDENTITY();

    SELECT @StarLogID AS StarLogID;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.generateTabularTranslator
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Generates a tabular translator for a table. Used in CTL.SourceConfig to add 
*				  data types to a parquet file
*
* TEST: EXEC CTL.generateTabularTranslator 'SRC', 'ADWORKS_Production_Product'
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE     PROCEDURE [CTL].[generateTabularTranslator]
(
	@schemaName VARCHAR(10)
	,@tableName VARCHAR(100)
)
AS
BEGIN

DECLARE @json_construct VARCHAR(MAX) = '{"type": "TabularTranslator", "mappings": {X}}';
DECLARE @json VARCHAR(MAX);

	--get data types for each column

	DROP TABLE IF EXISTS #table; 

	SELECT DISTINCT
		c.column_id
		,s.[name] AS [schema_name]
		,tb.[name] AS table_name
		,c.[name] AS source_column
		,c.name AS target_column
		,CASE 
			WHEN t.[name] LIKE '%char%'
				THEN 'String'
			WHEN t.[name] LIKE '%bit%'
				THEN 'String'
			WHEN t.[name] = 'uniqueidentifier'
				THEN 'String'
			WHEN t.[name] LIKE '%int%'
				THEN 'Int64'
			WHEN t.[name] LIKE '%decimal%'
				THEN 'Decimal'
			WHEN t.[name] LIKE '%numeric%'
				THEN 'Decimal'
			WHEN t.[name] = 'real'
				THEN 'Decimal'
			WHEN t.[name] LIKE '%date%'
				THEN 'Datetime'
			ELSE t.[name]
		END AS data_type
	INTO #table
	FROM sys.columns c
		INNER JOIN sys.tables tb ON c.object_id = tb.object_id
		INNER JOIN sys.schemas s ON tb.schema_id = s.schema_id
		INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
		LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id
			AND ic.column_id = c.column_id
	WHERE tb.[name] = @tableName
		AND s.[name] = @schemaName
	ORDER BY tb.[name],
			c.column_id;

	--generate tabular translator

	SET @json =
	(
		SELECT t.[source_column] AS [source.name],
			t.[data_type] AS [source.type],
			t.[target_column] AS [sink.name],
			t.[data_type] AS [sink.type]
		FROM #table t
		WHERE t.[schema_name] = @schemaName
			AND t.[table_name] = @tableName
		FOR JSON PATH
	);

	SELECT REPLACE(@json_construct, '{X}', @json) AS tabular_translator;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.getBronzeToSilver
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the files to move from Bronze zone to Silver zone in the data lake.
*
* TEST: EXEC CTL.getBronzeToSilver 'AdventureWorks', 'SQL Server', 'Daily'
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE   PROCEDURE [CTL].[getBronzeToSilver]
(
    @sourceName VARCHAR(255),
    @sourceType VARCHAR(255),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

	DECLARE @today DATETIME = CTL.fn_getSystemDateTime()
	DECLARE @yearFolder CHAR(4) = CONVERT(CHAR(4), YEAR(@today)) + '/' + RIGHT('0' + CONVERT(CHAR(4), MONTH(@today)), 2)
	DECLARE @monthFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), MONTH(@today)), 2)
	DECLARE @dayFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), DAY(@today)), 2)


    SELECT sc.Id,
           sc.SourceType AS srcType,
           sc.SourceName AS sourceName,
           sc.ContainerName AS srcContainerName,
		   sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder AS srcFolder,
           sc.BLOBName + sc.BlobFileExtension AS srcBlobName,
           sc.ContainerName AS destContainerName,
           sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder AS destFolder, 
           sc.BLOBName + '.parquet' AS destBlobName,
		   sc.TabularTranslator,
           @today AS ExecutionTime
    FROM CTL.SourceConfig sc
    WHERE 1 = 1
          AND sc.SourceType = @sourceType
          AND sc.SourceName = @sourceName
		  AND sc.RunFrequency = @runFrequency
          AND sc.IsRunnable = 1;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* PROCEDURE NAME: CTL.getDeltas
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the procedures to process for delta loads
*
* TEST EXEC CTL.getDeltas 'AdventureWorks', 'SQL Server', 'Daily'
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/

CREATE   PROCEDURE [CTL].[getDeltas]
(
    @sourceName VARCHAR(255),
    @sourceType VARCHAR(255),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    SELECT sc.Id,
           sc.SourceName AS sourceName,
           sc.SourceType AS sourceType,
           sc.DestinationSchema AS destinationSchema,
           sc.DestinationTable AS destinationTableName,
           sc.DeltaProcedure AS deltaProcedure,
           @today AS executionTime,
           sc.WatermarkColumn AS watermarkColumn,
		   CASE WHEN sc.WatermarkInt IS NOT NULL THEN 'Int'
				WHEN sc.WatermarkDateTime IS NOT NULL THEN 'DateTime'
				ELSE 'None'
		   END AS watermarkType,
		   sc.KeyColumns
    FROM CTL.SourceConfig sc
    WHERE sc.SourceType = @sourceType
          AND sc.SourceName = @sourceName
          AND sc.IsRunnable = 1
          AND sc.DeltaLoad = 1
		  AND sc.RunFrequency = @runFrequency
    ORDER BY sc.Id;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***************************************************************************************************
* PROCEDURE NAME: CTL.getPBIRefreshes
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the Power BI datasets to be refreshed for a particular group
*
* TEST: EXEC CTL.getPBIRefreshes 'Daily Test Group'
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[getPBIRefreshes]
(
    @groupName VARCHAR(100)
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    SELECT pbi.Id AS PBIRefreshId,
           pbi.GroupName,
		   pbi.PBIWorkspaceId,
           pbi.PBIWorkspaceName,
           pbi.PBIDatasetId,
           pbi.PBIDatasetName,
           pbi.[Sequence],
           @today AS ExecutionTime
    FROM CTL.PBIRefreshConfig pbi
    WHERE pbi.GroupName = @groupName
          AND pbi.isRunnable = 1
    ORDER BY pbi.[Sequence];
END;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* PROCEDURE NAME: CTL.getSilverToDW
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the files to move from the Silver data lake zone to the DW database.
*
* TEST: EXEC CTL.getSilverToDW 'AdventureWorks', 'SQL Server', 'Daily'
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[getSilverToDW]
(
    @sourceName VARCHAR(255),
    @sourceType VARCHAR(255),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

	DECLARE @today DATETIME = CTL.fn_getSystemDateTime()
	DECLARE @yearFolder CHAR(4) = CONVERT(CHAR(4), YEAR(@today)) + '/' + RIGHT('0' + CONVERT(CHAR(4), MONTH(@today)), 2)
	DECLARE @monthFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), MONTH(@today)), 2)
	DECLARE @dayFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), DAY(@today)), 2)


    SELECT sc.Id,
           sc.SourceName AS sourceName,
           sc.SourceType AS sourceType,
           sc.ContainerName AS containerName,
           sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder AS folderName,
           sc.BLOBName + '.parquet' AS blobName, 
           sc.DestinationSchema AS destinationSchema,
           sc.DestinationTable AS destinationTableName,
		   sc.KeyColumns AS keyColumns,
           @today AS ExecutionTime
    FROM CTL.SourceConfig sc
    WHERE sc.SourceType = @sourceType
          AND sc.SourceName = @sourceName
		  AND sc.RunFrequency = @runFrequency
          AND sc.IsRunnable = 1;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.getSourceDBToSilver
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the tables to process from the source database directly to the silver zone in the data lake.
*
* TEST: EXEC CTL.getSourceDBToSilver 'AdventureWorks', 'SQL Server', 'DEV', 'Daily' 
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version


****************************************************************************************************/

CREATE PROCEDURE [CTL].[getSourceDBToSilver]
(
    @sourceName VARCHAR(255),
    @sourceType VARCHAR(255),
    @sourceEnvironment VARCHAR(10),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

	DECLARE @today DATETIME = CTL.fn_getSystemDateTime()
	DECLARE @yearFolder CHAR(4) = CONVERT(CHAR(4), YEAR(@today)) + '/' + RIGHT('0' + CONVERT(CHAR(4), MONTH(@today)), 2)
	DECLARE @monthFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), MONTH(@today)), 2)
	DECLARE @dayFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), DAY(@today)), 2)

    SELECT sc.Id,
           sc.RunFrequency,
           sc.DeltaLoad,
           sc.SourceName,
           sc.SourceType,
           e.SourceHost,
           e.SourceDatabase,
           e.SourceUser,
           e.SourcePassword,
           sc.SourceLocation,
           CASE WHEN sc.SlidingWindowMonthsToLoad IS NOT NULL THEN
					REPLACE(sc.FetchQuery, '''MONTHS_TO_LOAD''', sc.SlidingWindowMonthsToLoad) 
				WHEN sc.WatermarkDateTime IS NOT NULL THEN 
					REPLACE(sc.FetchQuery, 'WATERMARK', CONVERT(VARCHAR, WatermarkDateTime, 120)) 
				WHEN sc.WatermarkInt IS NOT NULL THEN
					REPLACE(sc.FetchQuery, 'WATERMARK', CAST(sc.WatermarkInt AS VARCHAR(23))) 
				ELSE sc.FetchQuery
		   END AS FetchQuery,
           sc.ContainerName,
           sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder AS FolderName,
		   sc.BLOBName + '.parquet' AS BlobName,
		   sc.TabularTranslator,
           @today AS ExecutionTime
    FROM CTL.SourceConfig sc
        INNER JOIN CTL.SourceEnvironments e
            ON sc.SourceName = e.SourceName
    WHERE 1=1
		  AND sc.SourceType = @sourceType
          AND sc.SourceName = @sourceName
          AND e.SourceEnvironment = @sourceEnvironment
		  AND sc.RunFrequency = @runFrequency
          AND sc.IsRunnable = 1;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***************************************************************************************************
* PROCEDURE NAME: CTL.getSourceEnvironment
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Returns source environment details for a pipeline run.
* TEST EXEC CTL.getSourceEnvironment 'AdventureWorks', 'DEV'
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[getSourceEnvironment]
(
    @sourceName VARCHAR(255),
    @sourceEnvironment VARCHAR(255)
)
AS
BEGIN

    SELECT e.SourceName,
           e.SourceEnvironment,
           e.SourceHost,
           e.SourceDatabase,
           e.SourceUser,
           e.SourcePassword
    FROM CTL.SourceEnvironments e
    WHERE e.SourceEnvironment = @sourceEnvironment
          AND e.SourceName = @sourceName;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************************************
* PROCEDURE NAME: CTL.getSourceToBronze
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the tables or files to process from the source to the bronze zone in the data lake.
*
* TEST: EXEC CTL.getSourceToBronze 'AdventureWorks', 'SQL Server', 'PROD', 'Daily' 
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[getSourceToBronze]
(
    @sourceName VARCHAR(255),
    @sourceType VARCHAR(255),
    @sourceEnvironment VARCHAR(10),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

	DECLARE @today DATETIME = CTL.fn_getSystemDateTime()
	DECLARE @yearFolder CHAR(4) = CONVERT(CHAR(4), YEAR(@today)) + '/' + RIGHT('0' + CONVERT(CHAR(4), MONTH(@today)), 2)
	DECLARE @monthFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), MONTH(@today)), 2)
	DECLARE @dayFolder CHAR(2) = RIGHT('0' + CONVERT(VARCHAR(3), DAY(@today)), 2)

    SELECT sc.Id,
           sc.RunFrequency,
           sc.DeltaLoad,
           sc.SourceName,
           sc.SourceType,
           e.SourceHost,
           e.SourceDatabase,
           e.SourceUser,
           e.SourcePassword,
           sc.SourceLocation,
           sc.SourceFilePath,
           sc.SourceFileExtension,
           sc.SourceFileDelimiter AS Delimiter,
		   sc.SheetName,
		   sc.SheetRange,
           CASE WHEN sc.SlidingWindowMonthsToLoad IS NOT NULL THEN
					REPLACE(sc.FetchQuery, '''MONTHS_TO_LOAD''', sc.SlidingWindowMonthsToLoad) 
				WHEN sc.WatermarkDateTime IS NOT NULL THEN 
					REPLACE(sc.FetchQuery, 'WATERMARK', CONVERT(VARCHAR, WatermarkDateTime, 120)) 
				WHEN sc.WatermarkInt IS NOT NULL THEN
					REPLACE(sc.FetchQuery, 'WATERMARK', CAST(sc.WatermarkInt AS VARCHAR(23))) 
				ELSE sc.FetchQuery
		   END AS FetchQuery,
           sc.ContainerName,
           sc.BLOBName + '/' + @yearFolder + '/' + @monthFolder + '/' + @dayFolder AS FolderName,
		   sc.BLOBName + ISNULL(sc.BlobFileExtension, '') AS BlobName,
		   e.PaginationValue,
           @today AS ExecutionTime
    FROM CTL.SourceConfig sc
        INNER JOIN CTL.SourceEnvironments e
            ON sc.SourceName = e.SourceName
    WHERE 1=1
		  AND sc.SourceType = @sourceType
          AND sc.SourceName = @sourceName
          AND e.SourceEnvironment = @sourceEnvironment
		  AND sc.RunFrequency = @runFrequency
          AND sc.IsRunnable = 1;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: CTL.getStarSchemaProcessing
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Lists the procedures to call for the star schema loads
*
* TEST: EXEC CTL.getStarSchemaProcessing 'DimDateTime', 'Dimension', 'Daily'
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[getStarSchemaProcessing]
(
    @groupName VARCHAR(100),
    @procType VARCHAR(100),
	@runFrequency VARCHAR(255)
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    SELECT sc.Id,
		   sc.StarSchemaName,
           sc.ProcSchema,
           sc.ProcName,
           sc.TableName,
           sc.ProcType,
           sc.RunFrequency,
           sc.GroupName,
           sc.[Sequence],
           sc.ProcSchema + '.' + sc.ProcName AS ExecCommand,
           @today AS ExecutionTime
    FROM CTL.StarConfig sc
    WHERE sc.GroupName = @groupName
          AND sc.ProcType = @procType
		  AND sc.RunFrequency = @runFrequency
          AND sc.isRunnable = 1
    ORDER BY sc.[Sequence];
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***************************************************************************************************
* PROCEDURE NAME: CTL.scaleDB
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Scales the database to the requested service tier
*
* TEST: EXEC CTL.scaleDB 'Hyperscale', 'HS_Gen5_2'
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[scaleDB]
(
    @edition NVARCHAR(255),
    @serviceObjective NVARCHAR(255)
)
AS
BEGIN

    DECLARE @sql NVARCHAR(MAX);

    SET @sql
        = N'ALTER DATABASE [DW] MODIFY (EDITION = ''' + @edition + N''', SERVICE_OBJECTIVE = ''' + @serviceObjective
          + N''')';

    EXEC (@sql);

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***************************************************************************************************
* PROCEDURE NAME: CTL.updateBatchLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates BatchLog with results of the batch run
*
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updateBatchLog]
(
    @batchLogID INT,
    @status VARCHAR(50),
    @failureLayer VARCHAR(50),
    @failureReason VARCHAR(255)
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    UPDATE CTL.BatchLog
    SET [Status] = @status,
        FailureLayer = @failureLayer,
        FailureReason = @failureReason,
        ModifiedOn = @today
    WHERE BatchLogID = @batchLogID;

    RETURN 0;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: CTL.updateLastRefreshed
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates LastRefreshed metadata in source config.
*
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updateLastRefreshed]

(@sourceConfigId BIGINT)

AS

BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    UPDATE [CTL].SourceConfig
    SET LastRefreshed = @today
    WHERE Id = @sourceConfigId;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: CTL.updatePBIRefreshLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates PBIRefreshLog with refresh results.
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updatePBIRefreshLog]
(
    @PBIRefreshLogId BIGINT,
    @Status VARCHAR(255),
    @StatusDescription VARCHAR(255),
    @FailureReason VARCHAR(1000)
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    UPDATE CTL.PBIRefreshLog
    SET [Status] = @Status,
        StatusDescription = @StatusDescription,
        FailureReason = @FailureReason,
        ModifiedOn = @today
    WHERE PBIRefreshLogId = @PBIRefreshLogId;

	IF @Status = 'Completed' --refresh succeeded
	BEGIN
		UPDATE c
		SET LastRefreshed = @today
		FROM CTL.PBIRefreshConfig c
		INNER JOIN CTL.PBIRefreshLog l ON c.Id = l.PBIRefreshId
					AND l.PBIRefreshLogId = @PBIRefreshLogId;
	END 

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: CTL.updateSourceLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates SourceLog with results.
*
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updateSourceLog]
(
    @sourceLogID BIGINT,
    @pipelineName VARCHAR(255),
    @status VARCHAR(255),
    @statusDescription VARCHAR(255),
    @rowsCopied INT,
    @notebookURL VARCHAR(1000),
    @failureReason VARCHAR(1000),
	@durationInQueue INT
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    UPDATE [CTL].SourceLog
    SET [Status] = @status,
        PipelineName = @pipelineName,
        StatusDescription = @statusDescription,
        RowsCopied = @rowsCopied,
        DatabricksNotebookURL = @notebookURL,
        FailureReason = @failureReason,
        ModifiedOn = @today,
		DurationInQueue = @durationInQueue
    WHERE SourceLogID = @sourceLogID;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: CTL.updateStarLog
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates StarLog with results of the load.
*
*
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updateStarLog]
(
    @StarLogID BIGINT,
    @status VARCHAR(255),
    @statusDescription VARCHAR(255),
    @failureReason VARCHAR(1000)
)
AS
BEGIN

DECLARE @today DATETIME = CTL.fn_getSystemDateTime()

    UPDATE CTL.StarLog
    SET [Status] = @status,
        StatusDescription = @statusDescription,
        FailureReason = @failureReason,
        ModifiedOn = @today
    WHERE StarLogID = @StarLogID;

	IF @status = 'Completed' --load succeeded
	BEGIN
		UPDATE sc
		SET LastRefreshed = @today
		FROM CTL.StarConfig sc
		INNER JOIN CTL.StarLog l ON sc.Id = l.StarConfigID
					AND l.StarLogID = @StarLogID;
	END 

END;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: CTL.updateWatermarkDateTime
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates watermark in source config for incremental load.
*
* TEST: EXEC CTL.updateWatermarkDateTime 8, 'ModifiedDate'
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updateWatermarkDateTime] 
(
    @sourceConfigId BIGINT,
    @ColumnName NVARCHAR(128)
)
AS
BEGIN

    DECLARE @tableName NVARCHAR(128) = ( SELECT MAX(DestinationTable) FROM CTL.SourceConfig WHERE Id = @sourceConfigId );
	DECLARE @schemaName NVARCHAR(128) = ( SELECT MAX(DestinationSchema) FROM CTL.SourceConfig WHERE Id = @sourceConfigId );

    DECLARE @selectMaxValueSQL NVARCHAR(MAX)
        = N'(SELECT ISNULL(MAX( ' + @ColumnName + N'), ''1900-01-01'') FROM ' + @schemaName + '.' + REPLACE(@tableName, 'STG_', '') + N') WHERE Id = '
          + CAST(@sourceConfigId AS VARCHAR(5)); 

    DECLARE @dynSQL NVARCHAR(MAX) = N'UPDATE [CTL].SourceConfig SET WatermarkDateTime = ' + @selectMaxValueSQL;

	--SELECT @dynSQL
    EXECUTE sp_executesql @dynSQL;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: CTL.updateWatermarkInt
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates watermark in source config for incremental load.
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/

CREATE PROCEDURE [CTL].[updateWatermarkInt] 
(
    @sourceConfigId BIGINT,
    @ColumnName NVARCHAR(128)
)
AS
BEGIN

    DECLARE @tableName NVARCHAR(128) = ( SELECT MAX(DestinationTable) FROM CTL.SourceConfig WHERE Id = @sourceConfigId );
	DECLARE @schemaName NVARCHAR(128) = ( SELECT MAX(DestinationSchema) FROM CTL.SourceConfig WHERE Id = @sourceConfigId );

    DECLARE @selectMaxValueSQL NVARCHAR(MAX)
        = N'(SELECT MAX( ' + @ColumnName + N') FROM ' + @schemaName + '.' + @tableName + N') WHERE Id = '
          + CAST(@sourceConfigId AS VARCHAR(5)); 

    DECLARE @dynSQL NVARCHAR(MAX) = N'UPDATE [CTL].SourceConfig SET WatermarkInt = ' + @selectMaxValueSQL;

    EXECUTE sp_executesql @dynSQL;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
* PROCEDURE NAME: IDW.loadDimDate
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Loads DimDate
*
* TEST: EXEC IDW.loadDimDate
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/


CREATE PROCEDURE [IDW].[loadDimDate]
AS
BEGIN

    SET NOCOUNT ON;

    TRUNCATE TABLE IDW.DimDate;


    INSERT INTO [IDW].[DimDate]
    (
        [DateSK],
        [Date],
        [DayName],
        [DayOfWeek],
        [DayOfMonth],
        [DayOfYear],
        [DaySuffix],
        [MonthName],
        [MonthShortName],
        [MonthNumberOfYear],
        [MonthNumberSinceStart],
        [MonthStartDate],
        [MonthEndDate],
        [MonthYear],
        [WeekNumberOfYear],
        [WeekNumberSinceStart],
        [WeekdayInd],
        [WeekStartDate],
        [WeekEndDate],
        [WeekName],
        [CalendarQuarterNumber],
        [CalendarQuarterName],
        [Year],
        [LastDayOfMonthInd],
        [FiscalMonthNumber],
        [FiscalQuarterNumber],
        [FiscalYear],
        [FiscalQuarterName],
        [CalendarHalfNumber],
        [CalendarHalfName],
        [FiscalHalfNumber],
        [FiscalHalfName],
        [EndOfPreviousMonth],
        [TodayInd],
        [YesterdayInd],
        [LoadDateInd],
        [CalendarYearMonth],
        [EndOfCurrentMonthInd],
        [CurrentMTDInd],
        [CurrentHTDInd],
        [CurrentYTDInd],
        [CurrentFYTDInd],
        [CurrentRollingYearInd],
        [DayRelative],
        [WeekRelative],
        [MonthRelative],
        [QuarterRelative],
        [YearRelative],
        [NationalHolidayInd],
        [NationalHolidayName],
        [DW_ModifiedDateTime]
    )
    SELECT CONVERT(INT, (CONVERT(CHAR(8), [DateSK], 112))) AS DateSK,
           [Date],
           [DayName],
           [DayOfWeek],
           [DayOfMonth],
           [DayOfYear],
           [DaySuffix],
           [MonthName],
           [MonthShortName],
           [MonthNumberOfYear],
           [MonthNumberSinceStart],
           [MonthStartDate],
           [MonthEndDate],
           [MonthYear],
           [WeekNumberOfYear],
           [WeekNumberSinceStart],
           [WeekdayInd],
           [WeekStartDate],
           [WeekEndDate],
           [WeekName],
           [CalendarQuarterNumber],
           [CalendarQuarterName],
           [Year],
           [LastDayOfMonthInd],
           [FiscalMonthNumber],
           [FiscalQuarterNumber],
           [FiscalYear],
           [FiscalQuarterName],
           [CalendarHalfNumber],
           [CalendarHalfName],
           [FiscalHalfNumber],
           [FiscalHalfName],
           [EndOfPreviousMonth],
           [TodayInd],
           [YesterdayInd],
           [LoadDateInd],
           [CalendarYearMonth],
           [EndOfCurrentMonthInd],
           [CurrentMTDInd],
           [CurrentHTDInd],
           [CurrentYTDInd],
           [CurrentFYTDInd],
           [CurrentRollingYearInd],
           [DayRelative],
           [WeekRelative],
           [MonthRelative],
           [QuarterRelative],
           [YearRelative],
           [NationalHolidayInd],
           [NationalHolidayName],
           [DW_ModifiedDateTime]
    FROM [STG].[DimDate]
    ORDER BY [Date];



END;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************************************
* PROCEDURE NAME: IDW.loadDimTime
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Loads DimTime.
*
* TEST: EXEC IDW.loadDimTime
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/


CREATE PROCEDURE [IDW].[loadDimTime]
AS
BEGIN

    SET NOCOUNT ON;

    TRUNCATE TABLE IDW.DimTime;


    INSERT INTO [IDW].[DimTime]
    (
        [TimeSK],
		[Time],
		[HourOfTheDay],
		[AMPMHourOfTheDay],
		[MinuteOfTheDay],
		[SecondOfTheDay],
		[AMPM],
		[HoursToNextDay],
		[MinutesToNextDay],
		[SecondsToNextDay],
		[PeriodStart15],
		[PeriodEnd15],
		[PeriodStart30],
		[PeriodEnd30],
		[PeriodStart60],
		[PeriodEnd60],
		[PeriodStart2hr],
		[PeriodEnd2hr],
		[PeriodStart3hr],
		[PeriodEnd3hr],
		[PeriodStart6hr],
		[PeriodEnd6hr],
		[PeriodStart12hr],
		[PeriodEnd12hr],
		[OnTheHourInd],
        [DW_ModifiedDateTime]
    )
    SELECT ROW_NUMBER() OVER(ORDER BY [Time] ASC) AS [TimeSK],
		   CAST([Time] AS TIME(0)) AS [Time],
           [HourOfTheDay],
           [AMPMHourOfTheDay],
           [MinuteOfTheDay],
           [SecondOfTheDay],
           [AMPM],
           [HoursToNextDay],
           [MinutesToNextDay],
           [SecondsToNextDay],
           CAST([PeriodStart15] AS TIME(0)) AS [PeriodStart15],
           CAST([PeriodEnd15] AS TIME(0)) AS [PeriodEnd15],
           CAST([PeriodStart30] AS TIME(0)) AS [PeriodStart30],
           CAST([PeriodEnd30] AS TIME(0)) AS [PeriodEnd30],
           CAST([PeriodStart60] AS TIME(0)) AS [PeriodStart60],
           CAST([PeriodEnd60] AS TIME(0)) AS [PeriodEnd60],
           CAST([PeriodStart2hr] AS TIME(0)) AS [PeriodStart2hr],
           CAST([PeriodEnd2hr] AS TIME(0)) AS [PeriodEnd2hr],
           CAST([PeriodStart3hr] AS TIME(0)) AS [PeriodStart3hr],
           CAST([PeriodEnd3hr] AS TIME(0)) AS [PeriodEnd3hr],
           CAST([PeriodStart6hr] AS TIME(0)) AS [PeriodStart6hr],
           CAST([PeriodEnd6hr] AS TIME(0)) AS [PeriodEnd6hr],
           CAST([PeriodStart12hr] AS TIME(0)) AS [PeriodStart12hr],
           CAST([PeriodEnd12hr] AS TIME(0)) AS [PeriodEnd12hr],
           [OnTheHourInd],
           [DW_ModifiedDateTime]
    FROM [STG].[DimTime]
	ORDER BY [TimeSK];



END;

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/***************************************************************************************************
* PROCEDURE NAME: IDW.updateDailyDimDate
* DATE: xx/xx/xxxx
* AUTHOR: Data Divers
* PROCEDURE DESC: Updates DimDate attributes for the current date
*
* TEST: EXEC IDW.updateDailyDimDate
*
****************************************************************************************************
* DATE:			Developer 			Change
---------- 		---------------- 	------------------------------------------------
  xx/xx/xxxx	Data Divers			Initial Version

****************************************************************************************************/
CREATE PROCEDURE [IDW].[updateDailyDimDate]
AS
BEGIN

    SET NOCOUNT ON;

    --declare variables

    DECLARE @today DATE = CAST(CTL.fn_getSystemDateTime() AS DATE); 


    DECLARE @StartofYear DATE =
            (
                SELECT MAX(dd.Date)
                FROM IDW.DimDate dd
                WHERE dd.Year = DATEPART(YEAR, @today)
                      AND dd.DayOfYear = 1
            );

    DECLARE @HalfDate DATE = CASE
                                 WHEN DATEPART(MONTH, DATEADD(DAY, -1, @today)) > 6 THEN
                                     CAST(CONCAT('1 Jul ', CAST(DATEPART(YEAR, @StartofYear) AS VARCHAR(4))) AS DATE)
                                 ELSE
                                     @StartofYear
                             END;

    DECLARE @FYdate DATE = CASE
                               WHEN @HalfDate = @StartofYear THEN
                                   CAST(CONCAT('1 Jul ', CAST(DATEPART(YEAR, @StartofYear) - 1 AS VARCHAR(4))) AS DATE)
                               ELSE
                                   CAST(CONCAT('1 Jul ', CAST(DATEPART(YEAR, @StartofYear) AS VARCHAR(4))) AS DATE)
                           END;

    DECLARE @rollingYear DATE = DATEADD(YEAR, -1, @today);

    --reset values

    UPDATE dd
	SET TodayInd='N',
	YesterdayInd='N',
	LoadDateInd='N',
	EndOfCurrentMonthInd='N',
	CurrentMTDInd='N',
	CurrentHTDInd='N',
	CurrentYTDInd='N',
	CurrentFYTDInd='N',
	CurrentRollingYearInd='N'
    FROM IDW.DimDate dd;

    --[Today Ind]
    UPDATE dd
    SET TodayInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date = @today;

    --[Yesterday Ind]
    UPDATE dd
    SET YesterdayInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date = DATEADD(dd, -1, @today);

    --[Load Date Ind]
    UPDATE dd
    SET LoadDateInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date = DATEADD(dd, -1, @today);

    --[End Of Current Month Ind]
    UPDATE dd
    SET EndOfCurrentMonthInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date = CAST(DATEADD(SECOND, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @today) + 1, 0)) AS DATE);

    --[Current MTD Ind]
    UPDATE dd
    SET CurrentMTDInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.MonthNumberOfYear = DATEPART(MONTH, @today)
          AND dd.Year = DATEPART(YEAR, @today)
          AND dd.Date <= @today;

    --[Current HTD Ind]
    UPDATE dd
    SET CurrentHTDInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date
    BETWEEN @HalfDate AND
    (
        SELECT MAX(Date) FROM IDW.DimDate WHERE LoadDateInd = 'Y'
    );

    --[Current YTD Ind]
    UPDATE dd
    SET CurrentYTDInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date >= @StartofYear
          AND dd.Date <= @today;

    --[Current FYTD Ind]
    UPDATE dd
    SET CurrentFYTDInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date
    BETWEEN @FYdate AND @today;

    --[Current Rolling Year Ind]
    UPDATE dd
    SET CurrentRollingYearInd = 'Y'
    FROM IDW.DimDate dd
    WHERE dd.Date
    BETWEEN @rollingYear AND @today;

    --[Day Relative]
    UPDATE dd
    SET DayRelative = DATEDIFF(DAY, @today, dd.Date)
    FROM IDW.DimDate dd;

    --[Week Relative]
    UPDATE dd
    SET WeekRelative = DATEDIFF(WEEK, @today, dd.Date)
    FROM IDW.DimDate dd;

    --[Month Relative]
    UPDATE dd
    SET MonthRelative = DATEDIFF(MONTH, @today, dd.Date)
    FROM IDW.DimDate dd;

    --[Quarter Relative]
    UPDATE dd
    SET QuarterRelative = DATEDIFF(QUARTER, @today, dd.Date)
    FROM IDW.DimDate dd;

    --[Year Relative]
    UPDATE dd
    SET YearRelative = DATEDIFF(YEAR, @today, dd.Date)
    FROM IDW.DimDate dd;


END;

GO

