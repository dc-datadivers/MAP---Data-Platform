[[_TOC_]]


# Introduction

The pipeline costings framework utilises Log Analytics and Databricks to extract and record pipeline run costs into the control database.

# Add app registration to Log Analytics

The **LogAnalyticsApp** app registration completed in a previous step needs to be added to the log analytics workspace. Under **Access Control (IAM)**, give the app registration **Log Analytics Contributor** access.

# Test the linked service

Ensure that the correct Base URL has been configured in the LogAnalytics linked service. The workspace id can be retrieved from the Properties pane in Log Analytics.

# Test the pipeline

The pipeline is called **PL_ExtractPipelineRunCosts** and is located in the **9_Operations** folder in ADF. Parameter values have been prefilled. Ensure that the correct environment specific values are listed.

Cost rates have been taken from **Microsoft ADS Go Fast** codebase at https://github.com/microsoft/azure-data-services-go-fast-codebase/blob/main/solution/FunctionApp/FunctionApp/DataAccess/KqlTemplates/ADFServiceRates.json

Watch this repository for any changes.

# Check output in DW

Once the pipeline has run, check that the costs were logged correctly.

`SELECT * FROM CTL.PipelineCosts`

Note that this table can be joined to the other CTL log tables via the Pipeline Run Id for detailed reporting.

# Scheduling

The pipeline uses sliding window processing to reduce the risk of missing records (pipelines being executed at the same time as the cost logging). Scheduling is recommended on a daily basis with a **QueryWindowDays** setting of 2. If for any reason history is missed, the window can temporarily be increased up to 30 days.