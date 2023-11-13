@description('Name of the storage account for the bronze datalake.')
param dataLakeBronzeName string

@description('Name of the storage account for the silver datalake.')
param dataLakeSilverName string

@description('Name of the storage account for the auditing.')
param dataPlatformAuditName string

resource dataLakeBronzeName_default 'Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01' = {
  name: '${dataLakeBronzeName}/default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'Hot to Cool 30 Days'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                enableAutoTierToHotFromCool: true
                tierToCool: {
                  daysAfterLastAccessTimeGreaterThan: 30
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
  dependsOn: []
}

resource dataLakeSilverName_default 'Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01' = {
  name: '${dataLakeSilverName}/default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'Hot to Cool 30 Days'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                enableAutoTierToHotFromCool: true
                tierToCool: {
                  daysAfterLastAccessTimeGreaterThan: 30
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
  dependsOn: []
}

resource dataPlatformAuditName_default 'Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01' = {
  name: '${dataPlatformAuditName}/default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'auditRetention'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                delete: {
                  daysAfterModificationGreaterThan: 90
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
  dependsOn: []
}