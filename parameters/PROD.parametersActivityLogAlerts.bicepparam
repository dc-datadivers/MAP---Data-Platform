using '../resourcedeployment/ActivityLogAlerts.bicep'

param actionGroups_AZURE_ADMINS_AG_name = 'AZURE_ADMINS_AG'

param actionGroups_AZURE_ADMINS_AG_short_name = 'ADMINS'

param actionEmailAddress = 'david.cliff@datadivers.io'

param actionEmailName = 'David'

param subscription = '/subscriptions/5b4ee21e-2989-47ef-af55-eb8ce9ad1d06'

param activitylogalerts_Delete_firewall_rule_name = 'Delete firewall rule'

param activitylogalerts_Create_policy_assignment_name = 'Create policy assignment'

param activitylogalerts_Delete_policy_assignment_name = 'Delete policy assignment'

param activitylogalerts_Delete_public_IP_address_name = 'Delete public IP address'

param activitylogalerts_Delete_security_solution_name = 'Delete security solution'

param activitylogalerts_Delete_network_security_group_name = 'Delete network security group'

param activitylogalerts_Create_or_update_firewall_rule_name = 'Create or update firewall rule'

param activitylogalerts_Create_or_update_public_IP_address_name = 'Create or update public IP address'

param activitylogalerts_Create_or_update_security_solution_name = 'Create or update security solution'

param activitylogalerts_Create_or_update_network_security_group_name = 'Create or update network security group'

param tagValues = {
  Application: 'Mergers and Acquistions Analytics Platform'
  BusinessOwner: 'MMG'
  Environment: 'PROD'
}
