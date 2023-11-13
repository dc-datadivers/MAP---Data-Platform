[[_TOC_]]

# Introduction

This document describes the Azure and related infrastructure that has been deployed for the **Open Water Cloud** solution.

# Installation

Refer to the wiki page [01 Deploy Azure resources](/Installation/01-Deploy-Azure-resources) for installation instructions. The [OpenWaterCloud](https://dev.azure.com/data-divers/Open%20Water%20Cloud/_git/OpenWaterCloud) repository contains all the infrastructure-as-code and parameters used to create the DEV, TEST and PROD environments.

# Azure resource groups

Each resource group is a container for all the resources used to operate an instance of the platform in Azure. 

DEV RESOURCE GROUP NAME: 

TEST RESOURCE GROUP NAME: 

PROD RESOURCE GROUP NAME: 

## Resources 

| **DEV NAME** | **TEST NAME** | **PROD NAME** |**TYPE**  |  **PURPOSE**|
|--|--|--|--|--|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Data factory (V2)|Performs orchestration and data integration between sources and Azure. Triggers data transformation logic held in the Azure SQL Database.|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Key vault|Stores the credentials used to access source systems and Azure related components of the platform.|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Log Analytics workspace|Used to log Azure platform operations for troubleshooting and auditing.|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|SQL server|The logical server that holds the Azure SQL Database.|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Blob storage account|The bronze data lake that stores raw data in the format it was received, such as CSVs, JSON files and Excel spreadsheets. Note that data from databases goes directly to the silver data lake and is not stored in bronze|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Azure Data Lake Storage Gen 2|The silver data lake that stores historical data ingested into the platform, unified as parquet files. Does not stored modelled data as all modelling is done in the Azure SQL Database.|
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Blob storage account|Stores auditing and log data for the platform.|
|DW (xxxxxxxxxxxxxx/DW)|DW (xxxxxxxxxxxxxx/DW)|DW (xxxxxxxxxxxxxx/DW)|Azure SQL database|Used to store the integration framework metadata, full copies of all source data, business logic to transform the data, and integrated models for reporting.|	
|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|xxxxxxxxxxxxxx|Azure Databricks|On demand compute that can be used for advanced analytics.|
	
# Infrastructure map

The infrastructure map can be displayed using the Resource Visualiser for a resource group.

![image.png](/.attachments/image-442f62db-3067-4949-84d4-c6a208379d98.png)

#Self-hosted integration runtime (SHIR) servers

The SHIR server in the data platform is the link between on-premises systems and Azure. 

Linking a single SHIR to multiple data factories is best done using an intermediate SHARED data factory. This ensures that each runtime data factory (DEV, TEST and PROD) has the same configuration, which is required for CI/CD to work.

![image.png](/.attachments/image-a2624949-b43a-4167-af64-d17b3510cda5.png)

##SHIR VM names

DEV/TEST: 

PRODUCTION: 

##Shared data factory names

DEV / TEST: 

PROD: 


