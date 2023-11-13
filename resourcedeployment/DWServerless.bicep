@description('List of tags to apply to each resource')
param tagValues object

@description('SQL Server name')
param SQLServerName string

@description('SQL database name')
param SQLDatabaseName string

@description('The Azure region where the resources will be created')
param location string

@description('Name of the DW SKU')
param DBSkuName string

@description('The DW SKU tier')
param DBSkuTier string

@description('The DW SKU capacity')
param DBSkuCapacity int

@description('The DW SKU minimum capacity')
param DBSkuMinCapacity int

@description('The initial DW storage size in bytes')
param maxSizeBytes int

@description('Microsoft Entra ID Admin for SQL Server')
param MSEntraIDAdminLogin string

@description('SID for Microsoft Entra ID Admin for SQL Server')
param MSEntraIDAdminObjectID string

@description('Backup storage redundancy setting for SQL Server')
@allowed([
  'Local'
  'Zone'
  'Geo'
])
param backupStorageRedundancy string

resource SQLServerName_SQLDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${SQLServerName}/${SQLDatabaseName}'
  location: location
  tags: tagValues
  sku: {
    name: DBSkuName
    tier: DBSkuTier
    family: 'Gen5'
    capacity: DBSkuCapacity
  }
  kind: 'v12.0,user,vcore,serverless'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    requestedBackupStorageRedundancy: backupStorageRedundancy
    minCapacity: DBSkuMinCapacity
    isLedgerOn: false
  }
  dependsOn: []
}

resource SQLServerName_ActiveDirectory 'Microsoft.Sql/servers/administrators@2021-08-01-preview' = {
  name: '${SQLServerName}/ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: MSEntraIDAdminLogin
    sid: MSEntraIDAdminObjectID
    tenantId: subscription().tenantId
  }
  dependsOn: []
}
