[[_TOC_]]

# Introduction

There are cloud costs associated with running the platform. The deployment in each subscription as its own running costs and associated invoices.

This article describes tools and techniques that can be used to manage costs.

# Types of costs

There are four main buckets of costs to consider.

**1. Cloud Orchestration Activity Run** - this is a Data Factory charge for running activities.

**2. Cloud Data Movement** - this is a Data Factory charge for copying data from source to sink

**3. vCore for SQL Database** - this is the amount of compute and memory assigned to the Azure SQL Server

**4. Other** - Other costs such as storage, Key Vault, geo-replication and others


# Practical steps to reduce costs

- Disable triggers in the lower environments unless integration testing is taking place (to reduce ADF costs)
- Refresh data sources at the just required frequency for business benefit / value. More frequent refreshes increases the ADF run costs
- Keep the vCore setting on the database to the minimum in lower environments (unless performance testing where it can be increased to a maximum of 8 vCores)
- _Under no circumstances use a setting on the database higher than 8 vCores_ unless a thorough analysis of performance vs. business benefit vs. costs is undertaken
- Utilise the **ScaleDB** pipeline where needed to automate the increase and decrease of vCores dependent on workload
- When configuring new sources only bring in the required tables for reporting. Extra tables will increase the ADF costs without getting any benefit
- Ensure that the DIU setting on all copy activities is set to 2 (rather than Auto or some other number), unless needed for specific performance reasons

# Cost management in the Azure portal

An overview of Azure Cost Management can be found [here](https://docs.microsoft.com/en-us/azure/cost-management-billing/cost-management-billing-overview). You need specific permissions in Azure to be able to view costs (Cost Management Reader).

# Cost estimation worksheet

Attached below is a cost estimation worksheet that can be used at client site to communicate expected costs.

[MMG Azure Cost Estimate Template.xlsx](/.attachments/MMG%20Azure%20Cost%20Estimate%20Template-1d046d08-11fe-457a-b135-abfd286b464d.xlsx)