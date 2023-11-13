using '../resourcedeployment/SubscriptionDiagnostics.bicep'

param settingName = 'Azure Monitor diagnostics'

param workspaceId = '/subscriptions/5b4ee21e-2989-47ef-af55-eb8ce9ad1d06/resourceGroups/MMG-AUE-DAP-RG-SHARED/providers/Microsoft.OperationalInsights/workspaces/MMG-AUE-DAP-LA-SHARED'

param storageAccountId = '/subscriptions/5b4ee21e-2989-47ef-af55-eb8ce9ad1d06/resourceGroups/MMG-AUE-DAP-RG-SHARED/providers/Microsoft.Storage/storageAccounts/mmgdapauditshared'

param location = 'australiaeast'
