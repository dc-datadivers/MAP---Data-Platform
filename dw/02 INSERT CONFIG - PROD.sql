--PROD ENVIRONMENT SCRIPT


INSERT INTO [CTL].[SourceEnvironments]
(
    [SourceName],
    [SourceEnvironment],
    [SourceType],
    [SourceHost],
    [SourceDatabase],
    [SourceUser],
    [SourcePassword]
)
VALUES
( 'AdventureWorks', 'PROD', 'SQL Server', 'localhost', 'AdventureWorks2019', 'DataRead', 'Localhost-Pass' ),
( 'DimDateTime', 'PROD', 'CSV', 'C:\Data', 'N/A', 'DataRead', 'Localhost-Pass' ), --assumes SHIR is running on local machine
( 'AzureAdventureWorks', 'PROD', 'Azure SQL Database', 'mmg-aue-map-sqs01-e3.database.windows.net', 'AdventureWorks', 'MI', 'MI' ), --assumes this database was created in the portal with AdventureWorks sample
( 'Canning IOT', 'PROD', 'REST', 'https://canningiot-opendata.azurewebsites.net/api', 'N/A', 'Anonymous', 'Anonymous' ), 
( 'ExcelInputs', 'PROD', 'Excel', 'C:\Data', 'N/A', 'DataRead', 'Localhost-Pass' ) --assumes SHIR is running on local machine
GO

--SELECT * FROM CTL.SourceEnvironments




INSERT INTO [CTL].[SourceConfig]
(
    [Id],
    [IsRunnable],
    [RunFrequency],
    [DeltaLoad],
    [SourceName],
    [SourceType],
    [SourceFilePath],
    [SourceLocation],
    [SourceFileExtension],
    [SourceFileDelimiter],
    [FetchQuery],
    [TabularTranslator],
    [ContainerName],
    [BLOBName],
    [BlobFileExtension],
    [DestinationSchema],
    [DestinationTable],
    [DeltaProcedure],
    [LastRefreshed],
    [DataDomain],
    [WatermarkColumn],
    [WatermarkInt],
    [WatermarkDateTime],
	[SlidingWindowMonthsToLoad]
)
VALUES
( 1, 1, 'Daily', 0, 'AdventureWorks', 'SQL Server', NULL, 'Production.Product', NULL, NULL, 'SELECT ProductID,
       Name,
       ProductNumber,
       MakeFlag,
       FinishedGoodsFlag,
       Color,
       SafetyStockLevel,
       ReorderPoint,
       CAST(StandardCost AS DECIMAL(18,2)) AS StandardCost,
	   CAST(ListPrice AS DECIMAL(18,2)) AS ListPrice,
       Size,
       SizeUnitMeasureCode,
       WeightUnitMeasureCode,
       Weight,
       DaysToManufacture,
       ProductLine,
       Class,
       Style,
       ProductSubcategoryID,
       ProductModelID,
       SellStartDate,
       SellEndDate,
       DiscontinuedDate,
       CAST(rowguid AS VARCHAR(100)) AS rowguid,
       ModifiedDate
FROM Production.Product;', '{ "type": "TabularTranslator", "mappings": [ { "source": { "name": "ProductID", "type": "String" }, "sink": { "name": "ProductID", "type": "String" } }, { "source": { "name": "Name", "type": "String" }, "sink": { "name": "Name", "type": "String" } }, { "source": { "name": "ProductNumber", "type": "String" }, "sink": { "name": "ProductNumber", "type": "String" } }, { "source": { "name": "MakeFlag", "type": "Boolean" }, "sink": { "name": "MakeFlag", "type": "Boolean" } }, { "source": { "name": "FinishedGoodsFlag", "type": "Boolean" }, "sink": { "name": "FinishedGoodsFlag", "type": "Boolean" } }, { "source": { "name": "Color", "type": "String" }, "sink": { "name": "Color", "type": "String" } }, { "source": { "name": "SafetyStockLevel", "type": "Int" }, "sink": { "name": "SafetyStockLevel", "type": "Int" } }, { "source": { "name": "ReorderPoint", "type": "Int" }, "sink": { "name": "ReorderPoint", "type": "Int" } }, { "source": { "name": "StandardCost", "type": "Decimal" }, "sink": { "name": "StandardCost", "type": "Decimal" } }, { "source": { "name": "ListPrice", "type": "Decimal" }, "sink": { "name": "ListPrice", "type": "Decimal" } }, { "source": { "name": "Size", "type": "String" }, "sink": { "name": "Size", "type": "String" } }, { "source": { "name": "SizeUnitMeasureCode", "type": "String" }, "sink": { "name": "SizeUnitMeasureCode", "type": "String" } }, { "source": { "name": "WeightUnitMeasureCode", "type": "String" }, "sink": { "name": "WeightUnitMeasureCode", "type": "String" } }, { "source": { "name": "Weight", "type": "Decimal" }, "sink": { "name": "Weight", "type": "Decimal" } }, { "source": { "name": "DaysToManufacture", "type": "Int" }, "sink": { "name": "DaysToManufacture", "type": "Int" } }, { "source": { "name": "ProductLine", "type": "String" }, "sink": { "name": "ProductLine", "type": "String" } }, { "source": { "name": "Class", "type": "String" }, "sink": { "name": "Class", "type": "String" } }, { "source": { "name": "Style", "type": "String" }, "sink": { "name": "Style", "type": "String" } }, { "source": { "name": "ProductSubcategoryID", "type": "Int" }, "sink": { "name": "ProductSubcategoryID", "type": "Int" } }, { "source": { "name": "ProductModelID", "type": "Int" }, "sink": { "name": "ProductModelID", "type": "Int" } }, { "source": { "name": "SellStartDate", "type": "Datetime" }, "sink": { "name": "SellStartDate", "type": "Datetime" } }, { "source": { "name": "SellEndDate", "type": "Datetime" }, "sink": { "name": "SellEndDate", "type": "Datetime" } }, { "source": { "name": "DiscontinuedDate", "type": "Datetime" }, "sink": { "name": "DiscontinuedDate", "type": "Datetime" } }, { "source": { "name": "rowguid", "type": "String" }, "sink": { "name": "rowguid", "type": "String" } }, { "source": { "name": "ModifiedDate", "type": "Datetime" }, "sink": { "name": "ModifiedDate", "type": "Datetime" } }, { "source": { "name": "DW_ModifiedDateTime", "type": "Datetime" }, "sink": { "name": "DW_ModifiedDateTime", "type": "Datetime" } } ] }', 'adworks', 'product', '.gz', 'SRC', 'ADWORKS_Production_Product', NULL, NULL, 'Sales', NULL, NULL, NULL, NULL ), 
( 2, 1, 'Ad Hoc', 1, 'DimDateTime', 'CSV', 'DimDateTime', 'DimDate.csv', '.csv', '|', NULL, '{ "type": "TabularTranslator", "mappings": [ { "source": { "name": "DateSK", "type": "Int64" }, "sink": { "name": "DateSK", "type": "Int64" } }, { "source": { "name": "Date", "type": "Datetime", "format": "d/MM/yyyy" }, "sink": { "name": "Date", "type": "Datetime" } }, { "source": { "name": "DayName", "type": "String" }, "sink": { "name": "DayName", "type": "String" } }, { "source": { "name": "DayOfWeek", "type": "Int64" }, "sink": { "name": "DayOfWeek", "type": "Int64" } }, { "source": { "name": "DayOfMonth", "type": "Int64" }, "sink": { "name": "DayOfMonth", "type": "Int64" } }, { "source": { "name": "DayOfYear", "type": "Int64" }, "sink": { "name": "DayOfYear", "type": "Int64" } }, { "source": { "name": "DaySuffix", "type": "String" }, "sink": { "name": "DaySuffix", "type": "String" } }, { "source": { "name": "MonthName", "type": "String" }, "sink": { "name": "MonthName", "type": "String" } }, { "source": { "name": "MonthShortName", "type": "String" }, "sink": { "name": "MonthShortName", "type": "String" } }, { "source": { "name": "MonthNumberOfYear", "type": "Int64" }, "sink": { "name": "MonthNumberOfYear", "type": "Int64" } }, { "source": { "name": "MonthNumberSinceStart", "type": "Int64" }, "sink": { "name": "MonthNumberSinceStart", "type": "Int64" } }, { "source": { "name": "MonthStartDate", "type": "Datetime", "format": "d/MM/yyyy" }, "sink": { "name": "MonthStartDate", "type": "Datetime" } }, { "source": { "name": "MonthEndDate", "type": "Datetime", "format": "d/MM/yyyy" }, "sink": { "name": "MonthEndDate", "type": "Datetime" } }, { "source": { "name": "MonthYear", "type": "String" }, "sink": { "name": "MonthYear", "type": "String" } }, { "source": { "name": "WeekNumberOfYear", "type": "Int64" }, "sink": { "name": "WeekNumberOfYear", "type": "Int64" } }, { "source": { "name": "WeekNumberSinceStart", "type": "Int64" }, "sink": { "name": "WeekNumberSinceStart", "type": "Int64" } }, { "source": { "name": "WeekdayInd", "type": "String" }, "sink": { "name": "WeekdayInd", "type": "String" } }, { "source": { "name": "WeekStartDate", "type": "Datetime", "format": "d/MM/yyyy" }, "sink": { "name": "WeekStartDate", "type": "Datetime" } }, { "source": { "name": "WeekEndDate", "type": "Datetime", "format": "d/MM/yyyy" }, "sink": { "name": "WeekEndDate", "type": "Datetime" } }, { "source": { "name": "WeekName", "type": "String" }, "sink": { "name": "WeekName", "type": "String" } }, { "source": { "name": "CalendarQuarterNumber", "type": "Int64" }, "sink": { "name": "CalendarQuarterNumber", "type": "Int64" } }, { "source": { "name": "CalendarQuarterName", "type": "String" }, "sink": { "name": "CalendarQuarterName", "type": "String" } }, { "source": { "name": "Year", "type": "Int64" }, "sink": { "name": "Year", "type": "Int64" } }, { "source": { "name": "LastDayOfMonthInd", "type": "String" }, "sink": { "name": "LastDayOfMonthInd", "type": "String" } }, { "source": { "name": "FiscalMonthNumber", "type": "Int64" }, "sink": { "name": "FiscalMonthNumber", "type": "Int64" } }, { "source": { "name": "FiscalQuarterNumber", "type": "Int64" }, "sink": { "name": "FiscalQuarterNumber", "type": "Int64" } }, { "source": { "name": "FiscalYear", "type": "Int64" }, "sink": { "name": "FiscalYear", "type": "Int64" } }, { "source": { "name": "FiscalQuarterName", "type": "String" }, "sink": { "name": "FiscalQuarterName", "type": "String" } }, { "source": { "name": "CalendarHalfNumber", "type": "Int64" }, "sink": { "name": "CalendarHalfNumber", "type": "Int64" } }, { "source": { "name": "CalendarHalfName", "type": "String" }, "sink": { "name": "CalendarHalfName", "type": "String" } }, { "source": { "name": "FiscalHalfNumber", "type": "Int64" }, "sink": { "name": "FiscalHalfNumber", "type": "Int64" } }, { "source": { "name": "FiscalHalfName", "type": "String" }, "sink": { "name": "FiscalHalfName", "type": "String" } }, { "source": { "name": "EndOfPreviousMonth", "type": "Datetime", "format": "d/MM/yyyy" }, "sink": { "name": "EndOfPreviousMonth", "type": "Datetime" } }, { "source": { "name": "TodayInd", "type": "String" }, "sink": { "name": "TodayInd", "type": "String" } }, { "source": { "name": "YesterdayInd", "type": "String" }, "sink": { "name": "YesterdayInd", "type": "String" } }, { "source": { "name": "LoadDateInd", "type": "String" }, "sink": { "name": "LoadDateInd", "type": "String" } }, { "source": { "name": "CalendarYearMonth", "type": "String" }, "sink": { "name": "CalendarYearMonth", "type": "String" } }, { "source": { "name": "EndOfCurrentMonthInd", "type": "String" }, "sink": { "name": "EndOfCurrentMonthInd", "type": "String" } }, { "source": { "name": "CurrentMTDInd", "type": "String" }, "sink": { "name": "CurrentMTDInd", "type": "String" } }, { "source": { "name": "CurrentHTDInd", "type": "String" }, "sink": { "name": "CurrentHTDInd", "type": "String" } }, { "source": { "name": "CurrentYTDInd", "type": "String" }, "sink": { "name": "CurrentYTDInd", "type": "String" } }, { "source": { "name": "CurrentFYTDInd", "type": "String" }, "sink": { "name": "CurrentFYTDInd", "type": "String" } }, { "source": { "name": "CurrentRollingYearInd", "type": "String" }, "sink": { "name": "CurrentRollingYearInd", "type": "String" } }, { "source": { "name": "DayRelative", "type": "Int64" }, "sink": { "name": "DayRelative", "type": "Int64" } }, { "source": { "name": "WeekRelative", "type": "Int64" }, "sink": { "name": "WeekRelative", "type": "Int64" } }, { "source": { "name": "MonthRelative", "type": "Int64" }, "sink": { "name": "MonthRelative", "type": "Int64" } }, { "source": { "name": "QuarterRelative", "type": "Int64" }, "sink": { "name": "QuarterRelative", "type": "Int64" } }, { "source": { "name": "YearRelative", "type": "Int64" }, "sink": { "name": "YearRelative", "type": "Int64" } }, { "source": { "name": "NationalHolidayInd", "type": "String" }, "sink": { "name": "NationalHolidayInd", "type": "String" } }, { "source": { "name": "NationalHolidayName", "type": "String" }, "sink": { "name": "NationalHolidayName", "type": "String" } }, { "source": { "name": "DW_ModifiedDateTime", "type": "Datetime" }, "sink": { "name": "DW_ModifiedDateTime", "type": "Datetime" } } ] }', 'reference', 'DimDate', '.gz', 'STG', 'DimDate', 'IDW.loadDimDate', NULL, 'Reference', NULL, NULL, NULL, NULL ), 
( 3, 1, 'Ad Hoc', 1, 'DimDateTime', 'CSV', 'DimDateTime', 'DimTime.csv', '.csv', '|', NULL, '{"type": "TabularTranslator", "mappings": [{"source":{"name":"Time","type":"Datetime"},"sink":{"name":"Time","type":"Datetime"}},{"source":{"name":"HourOfTheDay","type":"Int64"},"sink":{"name":"HourOfTheDay","type":"Int64"}},{"source":{"name":"AMPMHourOfTheDay","type":"Int64"},"sink":{"name":"AMPMHourOfTheDay","type":"Int64"}},{"source":{"name":"MinuteOfTheDay","type":"Int64"},"sink":{"name":"MinuteOfTheDay","type":"Int64"}},{"source":{"name":"SecondOfTheDay","type":"Int64"},"sink":{"name":"SecondOfTheDay","type":"Int64"}},{"source":{"name":"AMPM","type":"String"},"sink":{"name":"AMPM","type":"String"}},{"source":{"name":"HoursToNextDay","type":"Int64"},"sink":{"name":"HoursToNextDay","type":"Int64"}},{"source":{"name":"MinutesToNextDay","type":"Int64"},"sink":{"name":"MinutesToNextDay","type":"Int64"}},{"source":{"name":"SecondsToNextDay","type":"Int64"},"sink":{"name":"SecondsToNextDay","type":"Int64"}},{"source":{"name":"PeriodStart15","type":"Datetime"},"sink":{"name":"PeriodStart15","type":"Datetime"}},{"source":{"name":"PeriodEnd15","type":"Datetime"},"sink":{"name":"PeriodEnd15","type":"Datetime"}},{"source":{"name":"PeriodStart30","type":"Datetime"},"sink":{"name":"PeriodStart30","type":"Datetime"}},{"source":{"name":"PeriodEnd30","type":"Datetime"},"sink":{"name":"PeriodEnd30","type":"Datetime"}},{"source":{"name":"PeriodStart60","type":"Datetime"},"sink":{"name":"PeriodStart60","type":"Datetime"}},{"source":{"name":"PeriodEnd60","type":"Datetime"},"sink":{"name":"PeriodEnd60","type":"Datetime"}},{"source":{"name":"PeriodStart2hr","type":"Datetime"},"sink":{"name":"PeriodStart2hr","type":"Datetime"}},{"source":{"name":"PeriodEnd2hr","type":"Datetime"},"sink":{"name":"PeriodEnd2hr","type":"Datetime"}},{"source":{"name":"PeriodStart3hr","type":"Datetime"},"sink":{"name":"PeriodStart3hr","type":"Datetime"}},{"source":{"name":"PeriodEnd3hr","type":"Datetime"},"sink":{"name":"PeriodEnd3hr","type":"Datetime"}},{"source":{"name":"PeriodStart6hr","type":"Datetime"},"sink":{"name":"PeriodStart6hr","type":"Datetime"}},{"source":{"name":"PeriodEnd6hr","type":"Datetime"},"sink":{"name":"PeriodEnd6hr","type":"Datetime"}},{"source":{"name":"PeriodStart12hr","type":"Datetime"},"sink":{"name":"PeriodStart12hr","type":"Datetime"}},{"source":{"name":"PeriodEnd12hr","type":"Datetime"},"sink":{"name":"PeriodEnd12hr","type":"Datetime"}},{"source":{"name":"OnTheHourInd","type":"String"},"sink":{"name":"OnTheHourInd","type":"String"}},{"source":{"name":"DW_ModifiedDateTime","type":"Datetime"},"sink":{"name":"DW_ModifiedDateTime","type":"Datetime"}}]}', 'reference', 'DimTime', '.gz', 'STG', 'DimTime', 'IDW.loadDimTime', NULL, 'Reference', NULL, NULL, NULL, NULL ), 
( 4, 1, 'Daily', 0, 'AzureAdventureWorks', 'Azure SQL Database', NULL, 'SalesLT.Address', NULL, NULL, 'SELECT AddressID,
       AddressLine1,
       AddressLine2,
       City,
       StateProvince,
       CountryRegion,
       PostalCode,
       CAST(rowguid AS VARCHAR(100)) AS rowguid,
       ModifiedDate
FROM SalesLT.[Address];', '{ "type": "TabularTranslator", "mappings": [ { "source": { "name": "AddressID", "type": "Int" }, "sink": { "name": "AddressID", "type": "Int" } }, { "source": { "name": "AddressLine1", "type": "String" }, "sink": { "name": "AddressLine1", "type": "String" } }, { "source": { "name": "AddressLine2", "type": "String" }, "sink": { "name": "AddressLine2", "type": "String" } }, { "source": { "name": "City", "type": "String" }, "sink": { "name": "City", "type": "String" } }, { "source": { "name": "StateProvince", "type": "String" }, "sink": { "name": "StateProvince", "type": "String" } }, { "source": { "name": "CountryRegion", "type": "String" }, "sink": { "name": "CountryRegion", "type": "String" } }, { "source": { "name": "PostalCode", "type": "String" }, "sink": { "name": "PostalCode", "type": "String" } }, { "source": { "name": "rowguid", "type": "String" }, "sink": { "name": "rowguid", "type": "String" } }, { "source": { "name": "ModifiedDate", "type": "Datetime" }, "sink": { "name": "ModifiedDate", "type": "Datetime" } }, { "source": { "name": "DW_ModifiedDateTime", "type": "Datetime" }, "sink": { "name": "DW_ModifiedDateTime", "type": "Datetime" } } ] }', 'azadworks', 'address', '.gz', 'SRC', 'AZADWORKS_SalesLT_Address', NULL, NULL, 'Sales', NULL, NULL, NULL, NULL ), 
( 5, 1, 'Daily', 0, 'Canning IOT', 'REST', NULL, 'WaterQuality', NULL, NULL, 'OpenData?code=bojcyEKH8Dj4veXm5eQWSORTVFxjyGvnFa1sORW5mcwxtV43lJN85w==&entity=WaterQuality&duration=monthly&format=json', '{ "type": "TabularTranslator", "mappings": [ { "source": { "path": "$[''ID'']" }, "sink": { "name": "ID", "type": "String" } }, { "source": { "path": "$[''DeviceID'']" }, "sink": { "name": "DeviceID", "type": "String" } }, { "source": { "path": "$[''ObservationTimestamp'']" }, "sink": { "name": "ObservationTimestamp", "type": "String" } }, { "source": { "path": "$[''LocalTimestamp'']" }, "sink": { "name": "LocalTimestamp", "type": "DateTime" } }, { "source": { "path": "$[''DissolvedOxygen'']" }, "sink": { "name": "DissolvedOxygen", "type": "Decimal" } }, { "source": { "path": "$[''WaterConductivity'']" }, "sink": { "name": "WaterConductivity", "type": "Decimal" } }, { "source": { "path": "$[''WaterPh'']" }, "sink": { "name": "WaterPh", "type": "Decimal" } }, { "source": { "path": "$[''WaterTemperature'']" }, "sink": { "name": "WaterTemperature", "type": "Decimal" } }, { "source": { "path": "$[''DW_ModifiedDateTime'']" }, "sink": { "name": "DW_ModifiedDateTime", "type": "DateTime" } } ] }', 'canningiot', 'waterquality', '.json', 'SRC', 'CANNING_WaterQuality', NULL, NULL, 'Environmental', NULL, NULL, NULL, NULL ), 
( 7, 1, 'Daily', 0, 'AdventureWorks', 'SQL Server', NULL, 'Sales.SalesOrderDetail', NULL, NULL, 'SELECT SalesOrderID,
       SalesOrderDetailID,
       CarrierTrackingNumber,
       OrderQty,
       ProductID,
       SpecialOfferID,
       UnitPrice,
       UnitPriceDiscount,
       LineTotal,
       rowguid,
       ModifiedDate
FROM Sales.SalesOrderDetail;', '{ "type": "TabularTranslator", "mappings": [ { "source": { "name": "SalesOrderID", "type": "Int" }, "sink": { "name": "SalesOrderID", "type": "Int" } }, { "source": { "name": "SalesOrderDetailID", "type": "Int" }, "sink": { "name": "SalesOrderDetailID", "type": "Int" } }, { "source": { "name": "CarrierTrackingNumber", "type": "String" }, "sink": { "name": "CarrierTrackingNumber", "type": "String" } }, { "source": { "name": "OrderQty", "type": "Int" }, "sink": { "name": "OrderQty", "type": "Int" } }, { "source": { "name": "ProductID", "type": "Int" }, "sink": { "name": "ProductID", "type": "Int" } }, { "source": { "name": "SpecialOfferID", "type": "Int" }, "sink": { "name": "SpecialOfferID", "type": "Int" } }, { "source": { "name": "UnitPrice", "type": "Decimal" }, "sink": { "name": "UnitPrice", "type": "Decimal" } }, { "source": { "name": "UnitPriceDiscount", "type": "Decimal" }, "sink": { "name": "UnitPriceDiscount", "type": "Decimal" } }, { "source": { "name": "LineTotal", "type": "Decimal" }, "sink": { "name": "LineTotal", "type": "Decimal" } }, { "source": { "name": "rowguid", "type": "String" }, "sink": { "name": "rowguid", "type": "String" } }, { "source": { "name": "ModifiedDate", "type": "Datetime" }, "sink": { "name": "ModifiedDate", "type": "Datetime" } }, { "source": { "name": "DW_ModifiedDateTime", "type": "Datetime" }, "sink": { "name": "DW_ModifiedDateTime", "type": "Datetime" } } ] }', 'adworks', 'SalesOrderDetail', '.gz', 'SRC', 'ADWORKS_Sales_SalesOrderDetail', NULL, NULL, 'Sales', NULL, NULL, NULL, NULL );
GO

--excel source from local SHIR directory

INSERT INTO [CTL].[SourceConfig]
(
    [Id],
    [IsRunnable],
    [RunFrequency],
    [DeltaLoad],
    [SourceName],
    [SourceType],
    [SourceFilePath],
    [SourceLocation],
    [SourceFileExtension],
    [SourceFileDelimiter],
	[SheetName],
	[SheetRange],
    [FetchQuery],
    [TabularTranslator],
    [ContainerName],
    [BLOBName],
    [BlobFileExtension],
    [DestinationSchema],
    [DestinationTable],
    [DeltaProcedure],
    [LastRefreshed],
    [DataDomain],
    [WatermarkColumn],
    [WatermarkInt],
    [WatermarkDateTime],
	[SlidingWindowMonthsToLoad]
)
VALUES 
( 6, 1, 'Ad Hoc', 0, 'ExcelInputs', 'Excel', 'ExcelInputs', 'Public_holidays.xlsx', '.xlsx', NULL, 'Sheet1', 'A1', NULL, '{ "type": "TabularTranslator", "mappings": [ { "source": { "name": "Date", "type": "Datetime" }, "sink": { "name": "Date", "type": "Datetime" } }, { "source": { "name": "Year", "type": "Int" }, "sink": { "name": "Year", "type": "Int" } }, { "source": { "name": "Month", "type": "Int" }, "sink": { "name": "Month", "type": "Int" } }, { "source": { "name": "PublicHoliday", "type": "String" }, "sink": { "name": "PublicHoliday", "type": "String" } }, { "source": { "name": "Description", "type": "String" }, "sink": { "name": "Description", "type": "String" } }, { "source": { "name": "DW_ModifiedDateTime", "type": "Datetime" }, "sink": { "name": "DW_ModifiedDateTime", "type": "Datetime" } } ] }', 'reference', 
'Public_holidays', '.gz', 'SRC', 'REF_PublicHolidays', NULL, NULL, 'Reference', NULL, NULL, NULL, NULL )

--SELECT * FROM CTL.SourceConfig

INSERT INTO CTL.StarConfig
(
    isRunnable,
    StarSchemaName,
    ProcSchema,
    ProcName,
    TableName,
    ProcType,
    RunFrequency,
    GroupName,
    Sequence,
    Created,
	LastRefreshed
)
VALUES
(   1,    -- isRunnable - bit
    'DateTime',      -- StarSchemaName - varchar(100)
    'IDW',      -- ProcSchema - varchar(100)
    'loadDimDate',      -- ProcName - varchar(100)
    'DimDate',      -- TableName - varchar(100)
    'Dimension',      -- ProcType - varchar(100)
    'Daily',      -- Frequency - varchar(100)
    'DimDateTime',      -- GroupName - varchar(100)
    1,       -- Sequence - int
    DEFAULT, -- Created - datetime
	NULL   -- LastRefreshed - datetime
    ),
(   1,    -- isRunnable - bit
    'DateTime',      -- StarSchemaName - varchar(100)
    'IDW',      -- ProcSchema - varchar(100)
    'loadDimTime',      -- ProcName - varchar(100)
    'DimTime',      -- TableName - varchar(100)
    'Dimension',      -- ProcType - varchar(100)
    'Daily',      -- Frequency - varchar(100)
    'DimDateTime',      -- GroupName - varchar(100)
    2,       -- Sequence - int
    DEFAULT, -- Created - datetime
	NULL     -- LastRefreshed - datetime
    );

GO


--dummy batch log for test runs

SET IDENTITY_INSERT CTL.BatchLog ON;

INSERT CTL.BatchLog
(	BatchLogID,
    DataFactoryName,
    PipelineName,
    SourceName,
    SourceEnvironment,
    Status,
    FailureLayer,
    FailureReason,
    CreatedOn,
    ModifiedOn
)
VALUES
(   -1 ,
    'mmg-aue-map-adf01-e3',    -- DataFactoryName - varchar(256)
    'Test Run',    -- PipelineName - varchar(256)
    'Test Run',    -- SourceName - varchar(256)
    'PROD',    -- SourceEnvironment - varchar(10)
    'Succeeded',      -- Status - varchar(50)
    NULL,    -- FailureLayer - varchar(50)
    NULL,    -- FailureReason - varchar(1000)
    DEFAULT, -- CreatedOn - datetime
    CTL.fn_getSystemDateTime() -- ModifiedOn - datetime
    )

SET IDENTITY_INSERT CTL.BatchLog OFF;
