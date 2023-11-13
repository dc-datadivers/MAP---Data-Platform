[[_TOC_]]

#Introduction
This page documents the backup and disaster recovery configuration for the data platform as it was initially deployed. Subsequent changes to the configuration should be reflected in this document.

Note that different settings are usually applied to Production compared with Dev / Test. This is primarily to manage costs.

#Azure SQL Database

Please refer to the Microsoft documentation for full details on how backups work in Azure SQL Database: https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql

##Production

- Geo-redundant backup storage has been configured
- Point in time backups are enabled going back 7 days (the default)
- Long term retention (LTR) policies have not been implemented

##Dev/Test

- Locally redundant backup storage has been configured
- Point in time backups are enabled going back 7 days (the default)
- LTR policies have not been implemented
- Database zone redundancy has not been enabled

#Storage accounts (data lake)

Please refer to the Microsoft documentation for full details on how redundancy and failover works for Azure Storage: https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy

##Production

- Geo-redundant storage (GRS) has been enabled (Primary: Australia East, Secondary: Australia Southeast)

![image.png](/.attachments/image-3b95486b-db16-48e5-9fa5-6b686c0208fc.png)

##Dev/Test

- Locally-redundant storage (LRS) has been enabled (Primary: Australia East)


