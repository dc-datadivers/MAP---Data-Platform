param actionGroups_AZURE_ADMINS_AG_name string = 'AZURE-ADMINS-AG'
param actionGroups_AZURE_ADMINS_AG_short_name string = 'ADMINS'

@description('Action group notification email address')
param actionEmailAddress string

@description('Action group notification email name')
param actionEmailName string
param subscription string
param activitylogalerts_Delete_firewall_rule_name string = 'Delete firewall rule'
param activitylogalerts_Create_policy_assignment_name string = 'Create Policy Assignment'
param activitylogalerts_Delete_policy_assignment_name string = 'Delete Policy Assignment'
param activitylogalerts_Delete_public_IP_address_name string = 'Delete public IP address'
param activitylogalerts_Delete_security_solution_name string = 'Delete security solution'
param activitylogalerts_Delete_network_security_group_name string = 'Delete network security group'
param activitylogalerts_Create_or_update_firewall_rule_name string = 'Create or update firewall rule'
param activitylogalerts_Create_or_update_public_IP_address_name string = 'Create or update public IP address'
param activitylogalerts_Create_or_update_security_solution_name string = 'Create or update security solution'
param activitylogalerts_Create_or_update_network_security_group_name string = 'Create or update network security group'

@description('List of tags to apply to each resource')
param tagValues object

resource actionGroups_AZURE_ADMINS_AG_name_resource 'microsoft.insights/actionGroups@2023-01-01' = {
  name: actionGroups_AZURE_ADMINS_AG_name
  location: 'Global'
  tags: tagValues
  properties: {
    groupShortName: actionGroups_AZURE_ADMINS_AG_short_name
    enabled: true
    emailReceivers: [
      {
        emailAddress: actionEmailAddress
        name: actionEmailName
        useCommonAlertSchema: true
      }
    ]
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}

resource activitylogalerts_Create_or_update_firewall_rule_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Create_or_update_firewall_rule_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.DataLakeAnalytics/accounts/firewallRules/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Create_or_update_network_security_group_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Create_or_update_network_security_group_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/networkSecurityGroups/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Create_or_update_public_IP_address_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Create_or_update_public_IP_address_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/publicIPAddresses/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: false
  }
}

resource activitylogalerts_Create_or_update_security_solution_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Create_or_update_security_solution_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Security'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Security/securitySolutions/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Create_policy_assignment_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Create_policy_assignment_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Authorization/policyAssignments/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Delete_firewall_rule_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Delete_firewall_rule_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.DataLakeAnalytics/accounts/firewallRules/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Delete_network_security_group_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Delete_network_security_group_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.ClassicNetwork/networkSecurityGroups/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Delete_policy_assignment_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Delete_policy_assignment_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Authorization/policyAssignments/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}

resource activitylogalerts_Delete_public_IP_address_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Delete_public_IP_address_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/publicIPAddresses/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: false
  }
}

resource activitylogalerts_Delete_security_solution_name_resource 'microsoft.insights/activitylogalerts@2020-10-01' = {
  name: activitylogalerts_Delete_security_solution_name
  location: 'global'
  tags: tagValues
  properties: {
    scopes: [
      subscription
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Security'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Security/securitySolutions/delete'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroups_AZURE_ADMINS_AG_name_resource.id
          webhookProperties: {}
        }
      ]
    }
    enabled: true
  }
}