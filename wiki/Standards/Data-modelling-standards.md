[[_TOC_]]

# Introduction

This page documents the data modelling standards for the data warehouse.

# Overall standards

- Foreign keys should not be implemented on the database to reduce overhead. 
- Every table needs a clustered index to organise the table on disk. 
For small tables less than 1,000,000 rows this should be a CLUSTERED PK (primary key). 
For larger tables, a NONCLUSTERED PK and a CLUSTERED COLUMNSTORE INDEX index should be used.
- Use **CamelCase** for column names in physical tables (no spaces)
- Reporting views should have spaces in the column names to provide a better experience in Power BI without needing to transform on a per dataset basis
- Each table has a control column at the end called **DW_ModifiedDateTime** which records when the record was last updated
- All tables updated via MERGE (upsert) processing need a **business key** implemented as a **unique index**, to identify what is unique for each row from a business perspective
- Date foreign key columns are in YYYYMMDD integer format (to link to DimDate)
- Columns originally defined as a **BIT** data type to be CAST and defined as **INT** in the DW

# IDW layer

The IDW layer contains the star schemas used to model the data for business consumption.

## Dimensions

Dimensions are used for grouping, filtering and report labels.

General standards:

- Avoid using NULLs where possible, decode these into 'Unknown', 'Not Applicable', 'Not Recorded' as appropriate (gives a reason why there is no business value present)
- For NULL codes, decode these into 'UNK', 'N/A', 'N/R' as appropriate
- All dimensions need a default row with an SK (surrogate key) of **-1** to cater for unlinked fact records
- SK column names are the same as the dimension name minus the Dim and add SK at the end, e.g. **DimEmployee** has an SK of **EmployeeSK**
- The SK is always the first column on the table, defined as the primary key, and is IDENTITY (1, 1) BIGINT NOT NULL

### Type 1 dimensions

Type 1 dimensions record the latest values for each row (no history).

### Type 2 dimensions

Type 2 dimensions track history, and have additional control columns to mark the record start date and end date, and an indicator to show which is the currently active record for a particular business key.

Additional control columns:

- DW_ActiveFlag INT which takes values 1 (active record) or 0
- DW_ValidFromDate DATETIME which is the begin effective timestamp for the record
- DW_ValidToDate DATETIME which is the end effective timestamp for the record (9999-12-31 for the active record)

## Facts

Facts contain measurements and links to related dimensions as at a point in time.

General standards:

- Fact tables contain measurements and links to dimensions only (with very few exceptions)
- Fact tables should also have an SK to positively identify each row (rather than needing to use a combination of FK columns), and is defined as the primary key
- Column order by convention is SK first, followed by all FKs, followed by measures
- Degenerate dimension columns can also be used to positively reconcile a fact row with a source unique identifier (e.g. SourceId)
- Missing numeric values should be recorded as NULL (not 0) to prevent incorrect results when averaging
- Foreign keys to dimensions should have the column names exactly the same as the related dimension PK (may be modified in case of aliasing. e.g. EmployeeSK and ManagerSK on the same fact table both linking to aliases of DimEmployee)

### Transactional facts

Transactional fact tables contain one row per event. The load style may be pure insert however upsert is also possible. 

### Snapshot facts

Snapshot fact tables record the business data as it was at a point in time to provide powerful history tracking and ease of querying. They are always loaded using append processing.

Snapshot facts should always have a column called SnapshotDateKey marking the date of the snapshot in YYYYMMDD format. 

## Bridges

See https://www.kimballgroup.com/2012/02/design-tip-142-building-bridges for reference.

# PBI layer

The PBI layer is where the Power BI dataset sources are defined. They will contain database views (based on the DW objects) that will provide a reporting layer for Power BI reporting purposes. It will be best practice to reference the views instead of directly accessing the DW objects, as they allow further refinements to the data prior to reporting, such as adding derived columns, removing non-required columns (ie.: Ids, audit columns, etc), data conversions, business specific column renaming and filtering of data.

PBI views should only be based on Fact and Dimension tables.
