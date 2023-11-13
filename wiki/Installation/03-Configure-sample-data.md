[[_TOC_]]

# Configure the on premise SQL Server sample database

To test the sample pipeline to load On Premise SQL database, you need to have a copy of **AdventureWorks2019** running on a local machine. Credentials need to be aligned in the AdventureWorks2019 database and the Key Vault.

The CTL.SourceEnvironments table contains an entry which has a hostname and the name of the database user and Key Vault secret. Update these as appropriate for your environment. **Localhost-Pass** is the secret name.

**AdventureWorks2019 (OLTP version)** can be downloaded and installed on a local instance of SQL Server from https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms

# Configure the Azure SQL Server sample database

To use the sample pipeline to load from Azure SQL database, you need to have a copy of **AdventureWorks** running on the Azure SQL Server.

1. In the Azure Portal, navigate to the Azure SQL Server and click **Create Database**
1. Call the database **AdventureWorks**
1. Under **Compute and Storage**, click **Configure database**
1. Change the configuration to **Basic S0** (the cheapest tier) and click **Apply**
1. Click **Additional Settings** and under **Data source** select **Sample** (AdventureWorksLT will be created as the sample database)
1. Click **Review and Create**, then **Create**
1. Log into the database as Sqladmin using SSMS and add the data factory with the code below. 
```
CREATE USER [mmg-aue-map-adf01-e3] FROM EXTERNAL PROVIDER --Data factory managed identity
GO

sys.sp_addrolemember @rolename = N'db_datareader', @membername = N'mmg-aue-map-adf01-e3' --Data factory managed identity
GO
```


# Copy sample CSV and Excel files to localhost SHIR

- To load the DimDateTime CSV data you need to create a share on the SHIR local host called **Data**, and create a directory within that called **DimDateTime**. The CSVs from the **\Data** directory in the repository should be placed here.
- To load the Excel sample data, create a directory in the **Data** share called **ExcelInputs** and place the **Public_holidays.xlxs** file there.
- Make sure there is a local user called **DataRead** that has access to the **Data** file share. Client sites should use a Windows service account rather than a local account.