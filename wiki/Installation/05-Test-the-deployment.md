[[_TOC_]]

# Source types

The following source types are available out-of-the-box in the ADF framework:

- SQL Server
- Azure SQL Server
- REST API
- Excel
- CSV

# Generic masters

There are master pipelines called **PL_Generic_Master** and **PL_Generic_DBMaster** that orchestrates the loading of data through the architecture.

# Test the loads

To load data from the various sample sources, trigger the pipelines in the **1. Loads** folder.

To view the pipeline runs, look at the ADF Monitor page. It will show the chain of pipelines used to load the data through all layers of the architecture.

In addition, a custom logging framework writes the run statistics out to log tables in the CTL schema.

`SELECT * FROM CTL.vwSourceLog`

# Data validation

Use Azure Storage Explorer or the Azure Portal to view the files loaded into each zone of the data lake. Use SSMS or Azure Data Studio to view the data loaded into the sample DW tables.

# Configure scale up and scale down

To save costs there are sample triggers set up to automatically scale the database down to the lowest tier after hours. These triggers can be enabled in the **Manage** page of ADF. The parameters and schedules can be changed as required.