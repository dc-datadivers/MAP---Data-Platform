

```
PRINT 'Start'
GO

DROP VIEW IF EXISTS SRC.vwDimAddress
GO

PRINT 'Create view with business logic'
GO


/***************************************************************************************************
* VIEW NAME: SRC.vwDimAddress
* DATE: xx/xx/xxxx
* AUTHOR: DataDivers
* VIEW DESC: Business logic for DimAddress
*
****************************************************************************************************
* DATE:			Developer 			Change
  --------		----------------- 	----------------------------------------------------------------
  xx/xx/xxxx	DataDivers			Initial Version

****************************************************************************************************/

CREATE VIEW [SRC].[vwDimAddress]

AS 

SELECT AddressID,
       AddressLine1,
       AddressLine2,
       City,
       StateProvince,
       CountryRegion,
       PostalCode
FROM SRC.AZADWORKS_SalesLT_Address


GO

PRINT 'Add extended property with the business key of the view'
GO


EXEC sys.sp_addextendedproperty @name=N'Column Role Description', 
								@value=N'Key Column' , 
								@level0type=N'SCHEMA',
								@level0name=N'SRC', 
								@level1type=N'VIEW',
								@level1name=N'vwDimAddress', 
								@level2type=N'COLUMN',
								@level2name=N'AddressID'
GO

-- Create dimension (get the shell of the CREATE TABLE script by running above query as a SELECT INTO IDW.Dimxxx then copying the CREATE TABLE script and deleting the table.
-- Check column lengths and increase for a buffer against larger data coming in future

PRINT 'Create dimension table'
GO

DROP TABLE IF EXISTS IDW.DimAddress
GO

CREATE TABLE IDW.DimAddress
(
    [AddressSK] BIGINT IDENTITY(1, 1) NOT NULL,
    [AddressID] [INT] NOT NULL,
    [AddressLine1] [NVARCHAR](60) NOT NULL,
    [AddressLine2] [NVARCHAR](60) NULL,
    [City] [NVARCHAR](30) NOT NULL,
    [StateProvince] [NVARCHAR](50) NOT NULL,
    [CountryRegion] [NVARCHAR](50) NOT NULL,
    [PostalCode] [NVARCHAR](15) NOT NULL,
    [DW_ModifiedDateTime] DATETIME NOT NULL
    DEFAULT CTL.fn_getSystemDateTime(),
    CONSTRAINT PK_DimAddress
        PRIMARY KEY CLUSTERED (AddressSK ASC)
        WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];
GO


PRINT 'Create unique index on business key'
GO

CREATE UNIQUE NONCLUSTERED INDEX UIX_DimAddress ON IDW.DimAddress ([AddressID])

GO


PRINT 'Auto generate merge procedure for Type 1 dimension'

DROP PROCEDURE IF EXISTS IDW.mergeDimAddress

GO

EXEC CTL.createMergeProc @mergeType = 0,
                         @sourceSchema = 'SRC',
                         @sourceView = 'vwDimAddress',
                         @targetSchema = 'IDW',
                         @targetTable = 'DimAddress',
                         @storedProc = 'mergeDimAddress'

GO

PRINT 'Insert default row'

SET IDENTITY_INSERT IDW.DimAddress ON

INSERT INTO IDW.DimAddress
(
     AddressSK,
     AddressID,
     AddressLine1,
     AddressLine2,
     City,
     StateProvince,
     CountryRegion,
     PostalCode,
     DW_ModifiedDateTime
)
VALUES
(   -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    DEFAULT);

SET IDENTITY_INSERT IDW.DimAddress OFF

GO


PRINT 'Load dimension'

EXEC IDW.mergeDimAddress

GO

PRINT 'Done'
```

