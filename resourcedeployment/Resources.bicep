@description('Azure Key Vault name.')
param azureKeyVaultName string

@description('Name of the Azure Monitor action group.')
param azureMonitorActionGroupName string

@description('Short name of the Azure Monitor action group. Maximum 12 characters.')
@minLength(5)
@maxLength(12)
param azureMonitorActionGroupShortName string

@description('Name of the storage account for the bronze datalake.')
param dataLakeBronzeName string

@description('Name of the storage account for the silver datalake.')
param dataLakeSilverName string

@description('Name of the storage account for the auditing.')
param dataPlatformAuditName string

@description('Bronze storage account type')
@allowed([
  'Standard_GRS'
  'Standard_LRS'
  'Standard_ZRS'
])
param bronzeStorageAccountType string

@description('Silver storage account type')
@allowed([
  'Standard_GRS'
  'Standard_LRS'
  'Standard_ZRS'
])
param silverStorageAccountType string

@description('Audit storage account type')
@allowed([
  'Standard_GRS'
  'Standard_LRS'
  'Standard_ZRS'
])
param auditStorageAccountType string

@description('SQL Server name')
param SQLServerName string

@description('The name for SQL Server administrator.')
param sqlServerAdministratorName string = uniqueString(resourceGroup().id, '{24CF6AE7-F4CA-44D7-ED47-B7F85C0BDDF6}')

@description('The password for SQL Server administrator.')
@secure()
param sqlServerAdministratorPassword string = 'C3@TbcdabVnr${uniqueString(resourceGroup().id, newGuid())}${toUpper(uniqueString(resourceGroup().id, newGuid()))}'

@description('Data factory name')
param factoryName string

@description('The Azure region where the resources will be created')
param location string

@description('List of tags to apply to each resource')
param tagValues object

@description('Microsoft Entra ID Admin for SQL Server')
param MSEntraIDAdminLogin string

@description('SID for Microsoft Entra ID Admin for SQL Server')
param MSEntraIDAdminObjectID string

@description('Action group notification email address')
param actionEmailAddress string

@description('Action group notification email name')
param actionEmailName string

@description('Virtual network name')
param vNetName string

@description('IP range for VNet')
param vNetAddressPrefix string

@description('IP range for Data subnet')
param dataSubnetAddressPrefix string

@description('Name of allowable IP for firewall rules')
param allowIPName string

@description('Allowable IP for firewall rules')
param allowIP string

@description('Name of the log analytics workspace')
param logAnalyticsName string

@description('The rentention period in days for deleted blobs and containers in storage')
param deletedBlobRetentionPeriod int

var storageBlobDataContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var keyVaultSecretsUserRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var keyVaultCryptoUserRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')

resource vNet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'Data'
        properties: {
          addressPrefix: dataSubnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                'australiaeast'
                'australiasoutheast'
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                'australiaeast'
                'australiasoutheast'
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
  dependsOn: []
}

resource vNetName_Data 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vNet
  name: 'Data'
  properties: {
    addressPrefix: dataSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          'australiaeast'
          'australiasoutheast'
        ]
      }
      {
        service: 'Microsoft.Sql'
        locations: [
          'australiaeast'
          'australiasoutheast'
        ]
      }
      {
        service: 'Microsoft.KeyVault'
        locations: [
          'australiaeast'
          'australiasoutheast'
        ]
      }
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource SQLServerName_VnetRule1 'Microsoft.Sql/servers/virtualNetworkRules@2020-08-01-preview' = {
  parent: SQLServer
  name: 'VnetRule1'
  properties: {
    virtualNetworkSubnetId: vNetName_Data.id
    ignoreMissingVnetServiceEndpoint: false
  }
}

resource azureMonitorActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  location: 'Global'
  name: azureMonitorActionGroupName
  tags: tagValues
  properties: {
    automationRunbookReceivers: []
    azureAppPushReceivers: []
    azureFunctionReceivers: []
    emailReceivers: [
      {
        emailAddress: actionEmailAddress
        name: actionEmailName
        useCommonAlertSchema: true
      }
    ]
    enabled: true
    groupShortName: azureMonitorActionGroupShortName
    itsmReceivers: []
    logicAppReceivers: []
    smsReceivers: []
    voiceReceivers: []
    webhookReceivers: []
  }
}

resource azureKeyVault 'Microsoft.KeyVault/vaults@2016-10-01' = {
  name: azureKeyVaultName
  location: location
  tags: tagValues
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: allowIP
        }
      ]
      virtualNetworkRules: [
        {
          id: vNetName_Data.id
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    enablePurgeProtection: true
  }
  dependsOn: [
    factory

  ]
}

resource azureKeyVaultName_Microsoft_Authorization_azureKeyVaultName_Microsoft_DataFactory_factories_factoryName_keyVaultSecretsUserRoleDefinitionId 'Microsoft.KeyVault/vaults/providers/roleAssignments@2020-03-01-preview' = {
  name: '${azureKeyVaultName}/Microsoft.Authorization/${guid(azureKeyVaultName, concat(factory.id), keyVaultSecretsUserRoleDefinitionId)}'
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinitionId
    principalId: reference(factory.id, '2018-06-01', 'Full').identity.principalId
    scope: azureKeyVault.id
    principalType: 'ServicePrincipal'
  }
}

resource azureKeyVaultName_Microsoft_Authorization_azureKeyVaultName_Microsoft_DataFactory_factories_factoryName_keyVaultCryptoUserRoleDefinitionId 'Microsoft.KeyVault/vaults/providers/roleAssignments@2020-03-01-preview' = {
  name: '${azureKeyVaultName}/Microsoft.Authorization/${guid(azureKeyVaultName, concat(factory.id), keyVaultCryptoUserRoleDefinitionId)}'
  properties: {
    roleDefinitionId: keyVaultCryptoUserRoleDefinitionId
    principalId: reference(factory.id, '2018-06-01', 'Full').identity.principalId
    scope: azureKeyVault.id
    principalType: 'ServicePrincipal'
  }
}

resource logAnalytics 'microsoft.operationalinsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsName
  location: location
  tags: tagValues
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource factory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: factoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tagValues
  properties: {}
}

resource dataLakeBronze 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: dataLakeBronzeName
  location: location
  tags: tagValues
  sku: {
    name: bronzeStorageAccountType
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: vNetName_Data.id
          action: 'Allow'
          state: 'succeeded'
        }
      ]
      ipRules: [
        {
          value: allowIP
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource dataLakeBronzeName_Microsoft_Authorization_dataLakeBronzeName_Microsoft_DataFactory_factories_factoryName_storageBlobDataContributorRoleDefinitionId 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2020-03-01-preview' = {
  name: '${dataLakeBronzeName}/Microsoft.Authorization/${guid(dataLakeBronzeName, concat(factory.id), storageBlobDataContributorRoleDefinitionId)}'
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleDefinitionId
    principalId: reference(factory.id, '2018-06-01', 'Full').identity.principalId
    scope: dataLakeBronze.id
    principalType: 'ServicePrincipal'
  }
}

resource dataLakeBronzeName_default 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: dataLakeBronze
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: deletedBlobRetentionPeriod
    }
    lastAccessTimeTrackingPolicy: {
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
      blobType: [
        'blockBlob'
      ]
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: deletedBlobRetentionPeriod
    }
  }
}

resource dataLakeSilver 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: dataLakeSilverName
  location: location
  tags: tagValues
  sku: {
    name: silverStorageAccountType
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: 'None'
    }
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    isHnsEnabled: true
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: vNetName_Data.id
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      ipRules: [
        {
          value: allowIP
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource dataLakeSilverName_Microsoft_Authorization_dataLakeSilverName_Microsoft_DataFactory_factories_factoryName_storageBlobDataContributorRoleDefinitionId 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2020-03-01-preview' = {
  name: '${dataLakeSilverName}/Microsoft.Authorization/${guid(dataLakeSilverName, concat(factory.id), storageBlobDataContributorRoleDefinitionId)}'
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleDefinitionId
    principalId: reference(factory.id, '2018-06-01', 'Full').identity.principalId
    scope: dataLakeSilver.id
    principalType: 'ServicePrincipal'
  }
}

resource dataLakeSilverName_default 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: dataLakeSilver
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: deletedBlobRetentionPeriod
    }
    lastAccessTimeTrackingPolicy: {
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
      blobType: [
        'blockBlob'
      ]
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: deletedBlobRetentionPeriod
    }
  }
}

resource dataPlatformAudit 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: dataPlatformAuditName
  location: location
  tags: tagValues
  sku: {
    name: auditStorageAccountType
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: [
        {
          value: allowIP
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
  dependsOn: []
}

resource dataPlatformAuditName_default 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: dataPlatformAudit
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: deletedBlobRetentionPeriod
    }
    lastAccessTimeTrackingPolicy: {
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
      blobType: [
        'blockBlob'
      ]
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: deletedBlobRetentionPeriod
    }
  }
}

resource SQLServer 'Microsoft.Sql/servers@2015-05-01-preview' = {
  name: SQLServerName
  location: location
  tags: tagValues
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    version: '12.0'
    administratorLogin: sqlServerAdministratorName
    administratorLoginPassword: sqlServerAdministratorPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: MSEntraIDAdminLogin
      sid: MSEntraIDAdminObjectID
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

resource SQLServerName_Default 'Microsoft.Sql/servers/securityAlertPolicies@2017-03-01-preview' = {
  parent: SQLServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    disabledAlerts: []
    emailAddresses: null
    emailAccountAdmins: false
  }
}

resource Microsoft_Sql_servers_connectionPolicies_SQLServerName_default 'Microsoft.Sql/servers/connectionPolicies@2021-05-01-preview' = {
  parent: SQLServer
  name: 'default'
  properties: {
    connectionType: 'Default'
  }
}

resource SQLServerName_CreateIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: SQLServer
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

resource SQLServerName_DropIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: SQLServer
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [

    SQLServerName_CreateIndex
  ]
}

resource SQLServerName_ForceLastGoodPlan 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: SQLServer
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
  dependsOn: [

    SQLServerName_DropIndex
  ]
}

resource Microsoft_Sql_servers_auditingPolicies_SQLServerName_Default 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: SQLServer
  name: 'Default'
  properties: {
    auditingState: 'Disabled'
  }
}

resource SQLServerName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = {
  parent: SQLServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource SQLServerName_allowIP 'Microsoft.Sql/servers/firewallRules@2020-08-01-preview' = {
  parent: SQLServer
  name: allowIPName
  properties: {
    startIpAddress: allowIP
    endIpAddress: allowIP
  }
}
