using '../resourcedeployment/DWServerless.bicep'

param tagValues = {
  Application: 'Mergers and Acquistions Analytics Platform'
  BusinessOwner: 'MMG'
  Environment: 'DEV'
}

param SQLServerName = 'mmg-aue-map-sqs01-e3'

param SQLDatabaseName = 'DW'

param location = 'Australia East'

param DBSkuName = 'GP_S_Gen5'

param DBSkuTier = 'GeneralPurpose'

param DBSkuCapacity = 4

param DBSkuMinCapacity = 1

param maxSizeBytes = 107374182400

param MSEntraIDAdminLogin = 'sg.global.map.dev.adm'

param MSEntraIDAdminObjectID = 'f023a8ba-b533-4e07-8b08-a4294d7fb5c6'

param backupStorageRedundancy = 'Local'
