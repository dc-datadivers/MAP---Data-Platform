[[_TOC_]]

# Create Source Environment entry

If you want to add a new source database for an existing type (e.g. SQL Server) then an entry needs to be made in the table CTL.SourceEnvironments


```
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
('<source name>', '<environment>', 'SQL Server', '<host name>', '<database name>', '<read only user>', '<key vault secret>')
```
##Multiple environments per source

If there are multiple environments for a single source, enter DEV, TEST or PROD in the `SourceEnvironment` column for each entry. Data Factory can then point to the required source environment at run time. You may also need separate entries in Key Vault for the credentials, depending on how access to the source is set up.

# Create source config entries

Follow the instructions in [Add a new source table or file to an existing source](/Maintain-Configuration/Add-a-new-source-table-or-file-to-an-existing-source) to add the required tables. Note that the `SourceName` and `SourceType` must match what you entered in `CTL.SourceEnvironments`.

# Verify the config

Run the below stored procedure, changing the parameters depending on the name of the new source, source type and environment. This will return a table of data elements to be processed from the source to the data lake.

```
EXEC CTL.getSourceDBToSilver @sourceName = '<source name>',
                            @sourceType = 'SQL Server',
                            @sourceEnvironment = '<environment>',
                            @runFrequency = 'Daily'
```

Verify that the config data returned is correct.

# Add a new Load pipeline

1. In Data Factory create a new branch
1. Clone and rename one of the Load pipelines that most resembles the new source
1. Save this and run the Load pipeline in Debug mode using the appropriate parameters
1. Test that the data was loaded successfully into the data lake and data warehouse
1. Make any other changes to the orchestration as needed and save
1. Create a pull request
1. Ask a peer to review the change
1. Merge the pull request back into Master
1. Ensure that all changes are published to Data Factory
