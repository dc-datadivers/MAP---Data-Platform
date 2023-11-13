--PROD ENVIRONMENT SCRIPT 

--Ensure query is connected to the DW database

--DATABASE CONFIG

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF --prevent skipped identity values
GO

--USERS AND SECURITY

CREATE USER [sg.global.map.dev.adm] FROM  EXTERNAL PROVIDER --Developer AD group. Note you need to be signed in as the Microsoft Entra ID Admin to assign this security.
GO

CREATE USER [mmg-aue-map-adf01-e1]  FROM  EXTERNAL PROVIDER --Data factory managed identity
GO

CREATE USER [MMG_CICD_ServicePrincipal] FROM EXTERNAL PROVIDER --CICD agent
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

sys.sp_addrolemember @rolename = N'db_executor', @membername = N'mmg-aue-map-adf01-e1'
GO

sys.sp_addrolemember @rolename = N'db_owner', @membername = N'MMG_CICD_ServicePrincipal'
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


--Database structure to be deployed using CI / CD