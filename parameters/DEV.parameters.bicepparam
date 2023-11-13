using '../resourcedeployment/Resources.bicep'

param azureKeyVaultName = 'mmg-aue-map-akv01-e3'

param azureMonitorActionGroupName = 'mmg-aue-map-ag-e3'

param azureMonitorActionGroupShortName = 'map-ag-e3'

param dataLakeBronzeName = 'mmgauemapbronzestre3'

param dataLakeSilverName = 'mmgauemapsilveradle3'

param dataPlatformAuditName = 'mmgauemapauditstre3'

param bronzeStorageAccountType = 'Standard_LRS'

param silverStorageAccountType = 'Standard_LRS'

param auditStorageAccountType = 'Standard_LRS'

param tagValues = {
  Application: 'Mergers and Acquistions Analytics Platform'
  BusinessOwner: 'MMG'
  Environment: 'DEV'
}

param SQLServerName = 'mmg-aue-map-sqs01-e3'

param factoryName = 'mmg-aue-map-adf01-e3'

param location = 'Australia East'

param MSEntraIDAdminLogin = 'sg.global.map.dev.adm'

param MSEntraIDAdminObjectID = 'f023a8ba-b533-4e07-8b08-a4294d7fb5c6'

param actionEmailAddress = 'david.cliff@datadivers.io'

param actionEmailName = 'David'

param vNetName = 'mmg-aue-map-vnet-e3'

param vNetAddressPrefix = '10.0.0.0/16'

param dataSubnetAddressPrefix = '10.0.1.0/24'

param allowIPName = 'Data Divers Hut'

param allowIP = '220.245.183.74'

param logAnalyticsName = 'mmg-aue-map-la-e3'

param deletedBlobRetentionPeriod = 7
