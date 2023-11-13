[[_TOC_]]

# Introduction

This procedure outlines how to add a new table to an existing source. A source is a specific instance of a source type such as SQL Server, e.g. 'AdventureWorks'

# Create entry for SourceConfig

There is a stored procedure called `CTL.generateFetchTabular` that automatically generates the FetchQuery and TabularTranslator.

The FetchQuery must remove any spaces from column names using AS syntax. 

_Parquet files in the data lake do not handle spaces_.

All sources also need a TabularTranslator entry, which has two functions:

- For a JSON source it instructs how to flatten the JSON into a tabular format
- For all other sources, it is needed to map the correct data types to the silver data lake parquet files

# Create target table in DW

## SQL Server or Azure SQL Server

1. Navigate to the source system database using SSMS and copy the table create script. 
1. Paste it in a query window connected to the DW environment. 
1. Change the target table name to be the same as you entered in SourceConfig, e.g. `SRC.TABLE_NAME`
1. Add a column at the end: `[DW_ModifiedDateTime] [DATETIME] NULL`
1. Change any uniqueidentifier values to varchar as this data type is not handled in parquet
1. Remove any source specific code such as IDENTITY, foreign keys, unnecessary indexes, etc.
1. Adjust any other data types as required, e.g. money should be converted to decimal
1. Remove any spaces from column names (not handled in parquet)
1. Create the table

## Other sources

For sources such as Oracle, follow a similar procedure as above but you need to convert the data types to SQL Server types.

For Excel and CSV sources a useful utility is csvkit https://pypi.org/project/csvkit/

To scan a CSV and automatically generate the table create script, run something like this in Python:

`csvsql -i mssql --db-schema SRC --tables TABLE_NAME.csv`

For JSON sources, the scripts may need to be prepared from scratch. Otherwise, convert them to CSV and use csvkit.

Another method is to convert the data to CSV and use the SQL Server Import and Export Wizard to import the flat file into SSMS. You can then tweak the table structure as above.

# Run pipeline

Run the relevant **Load** pipeline to refresh the data. If you only want to run a subset of tables for a source, you can set the flag `isRunnable = 0` for the tables to exclude and they will be ignored by ADF.
