using '../resourcedeployment/Resources.bicep'

param azureKeyVaultName = 'mmg-aue-map-akv01-e1'

param azureMonitorActionGroupName = 'mmg-aue-map-ag-e1'

param azureMonitorActionGroupShortName = 'map-ag-e1'

param dataLakeBronzeName = 'mmgauemapbronzestre1'

param dataLakeSilverName = 'mmgauemapsilveradle1'

param dataPlatformAuditName = 'mmgauemapauditstre1'

param bronzeStorageAccountType = 'Standard_GRS'

param silverStorageAccountType = 'Standard_GRS'

param auditStorageAccountType = 'Standard_GRS'

param tagValues = {
  Application: 'Mergers and Acquistions Analytics Platform'
  BusinessOwner: 'MMG'
  Environment: 'PROD'
}

param SQLServerName = 'mmg-aue-map-sqs01-e1'

param factoryName = 'mmg-aue-map-adf01-e1'

param location = 'Australia East'

param MSEntraIDAdminLogin = 'sg.global.map.dev.adm'

param MSEntraIDAdminObjectID = 'f023a8ba-b533-4e07-8b08-a4294d7fb5c6'

param actionEmailAddress = 'david.cliff@datadivers.io'

param actionEmailName = 'David'

param vNetName = 'mmg-aue-map-vnet-e1'

param vNetAddressPrefix = '10.0.0.0/16'

param dataSubnetAddressPrefix = '10.0.1.0/24'

param allowIPName = 'Data Divers Hut'

param allowIP = '220.245.183.74'

param logAnalyticsName = 'mmg-aue-map-la-e1'

param deletedBlobRetentionPeriod = 7
