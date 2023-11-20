targetScope = 'tenant'

@sys.description('Prefix for the management group hierarchy. This management group will be created as part of the deployment. Default: alz')
@minLength(2)
@maxLength(10)
param parCustomerID string = 'tst'

@sys.description('Display name for top level management group. This name will be applied to the management group prefix defined in parTopLevelManagementGroupPrefix parameter. Default: Azure Landing Zones')
@minLength(2)
param parCustomerFullName string = 'test'


@description('Tier 1 management groups. Must contain id and displayName properties.')
param tier1MgmtGroups array = [
{
          id: parCustomerFullName
          displayName: parCustomerFullName
          
        }

]

@description('Optional. Tier 2 management groups. Must contain id, displayName and ParentId properties.')
param tier2MgmtGroups array = [
{
          id: '${parCustomerID}-platform'
          displayName: '${parCustomerID}-platform'
          parentId: parCustomerFullName
        }
        {
          id: '${parCustomerID}-landingzones'
          displayName: '${parCustomerID}-landingzones'
          parentId: parCustomerFullName
        }
        {
          id: '${parCustomerID}-sandbox'
          displayName: '${parCustomerID}-sandbox'
          parentId: parCustomerFullName
        }
        {
          id: '${parCustomerID}-decommissioned'
          displayName: '${parCustomerID}-decommissioned'
          parentId: parCustomerFullName
        }
      
]

@description('Optional. Tier 3 management groups. Must contain id, displayName and ParentId properties.')
param tier3MgmtGroups array = [
{
          id: '${parCustomerID}-platform-connectivity'
          displayName: '${parCustomerID}-platform-connectivity'
          parentId: '${parCustomerID}-platform'
        }
        {
          id: '${parCustomerID}-platform-identity'
          displayName: '${parCustomerID}-platform-identity'
          parentId: '${parCustomerID}-platform'
        }
        {
          id: '${parCustomerID}-platform-management'
          displayName: '${parCustomerID}-platform-management'
          parentId: '${parCustomerID}-platform'
        }
        {
          id: '${parCustomerID}-landingzones-${parCustomerID}'
          displayName: '${parCustomerID}-landingzones-${parCustomerID}'
          parentId: '${parCustomerID}-landingzones'
        }
        {
          id: '${parCustomerID}-landingzones-xxx'
          displayName: '${parCustomerID}-landingzones-xxx'
          parentId: '${parCustomerID}-landingzones'
        }
]

@description('Optional. Tier 4 management groups. Must contain id, displayName and ParentId properties.')
param tier4MgmtGroups array = [
{
          id: '${parCustomerID}-landingzones-${parCustomerID}-prod'
          displayName: '${parCustomerID}-landingzones-${parCustomerID}-prod'
          parentId: '${parCustomerID}-landingzones-${parCustomerID}'
        }
        {
          id: '${parCustomerID}-landingzones-${parCustomerID}-nonprod'
          displayName: '${parCustomerID}-landingzones-${parCustomerID}-nonprod'
          parentId: '${parCustomerID}-landingzones-${parCustomerID}'
        }
        {
          id: '${parCustomerID}-landingzones-xxx-prod'
          displayName: '${parCustomerID}-landingzones-xxx-prod'
          parentId: '${parCustomerID}-landingzones-xxx'
        }
        {
          id: '${parCustomerID}-landingzones-xxx-nonprod'
          displayName: '${parCustomerID}-landingzones-xxx-nonprod'
          parentId: '${parCustomerID}-landingzones-xxx'
        }
        
]

@description('Tier 5 management groups')
param tier5MgmtGroups array = []

@description('Tier 6 management groups')
param tier6MgmtGroups array = []

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = '${parCustomerID}-decommissioned'

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool = true

@description('Optional. Indicates whether Settings for default MG for new subscription and permissions for creating new MGs are configured. This configuration is applied on Tenant Root MG.')
param configMGSettings bool = false

module mg_hierarchy './modules/managementGroupHierarchy.bicep' = {
  name: 'management_groups'
  params: {
    tier1MgmtGroups: tier1MgmtGroups
    tier2MgmtGroups: tier2MgmtGroups
    tier3MgmtGroups: tier3MgmtGroups
    tier4MgmtGroups: tier4MgmtGroups
    tier5MgmtGroups: tier5MgmtGroups
    tier6MgmtGroups: tier6MgmtGroups
    defaultMgId: defaultMgId
    authForNewMG: authForNewMG
    configMGSettings: configMGSettings
  }
}

output managementGroups array = mg_hierarchy.outputs.managementGroups
output root_mg_settings object = mg_hierarchy.outputs.root_mg_settings
output tier_1_mgs array = mg_hierarchy.outputs.tier_1_mgs
output tier_2_mgs array = mg_hierarchy.outputs.tier_2_mgs
output tier_3_mgs array = mg_hierarchy.outputs.tier_3_mgs
output tier_4_mgs array = mg_hierarchy.outputs.tier_4_mgs
output tier_5_mgs array = mg_hierarchy.outputs.tier_5_mgs
output tier_6_mgs array = mg_hierarchy.outputs.tier_6_mgs
