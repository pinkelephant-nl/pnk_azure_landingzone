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

@description('Optional. Tier 5 management groups. Must contain id, displayName and ParentId properties.')
param tier5MgmtGroups array = []

@description('Optional. Tier 6 management groups. Must contain id, displayName and ParentId properties.')
param tier6MgmtGroups array = []

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = ''

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool = true

@description('Optional. Indicates whether Settings for default MG for new subscription and permissions for creating new MGs are configured. This configuration is applied on Tenant Root MG.')
param configMGSettings bool = false

var tenantRootMgId = tenant().tenantId

var allMgs = union(tier1MgmtGroups, tier2MgmtGroups, tier3MgmtGroups, tier4MgmtGroups, tier5MgmtGroups, tier6MgmtGroups)

//Deploy tier 1 Mgmt Groups
@batchSize(1)
resource tier_1_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier1MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', tenantRootMgId)
      }
    }
  }
}]

//Deploy tier 2 Mgmt Groups
@batchSize(1)
resource tier_2_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier2MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_1_mgs
  ]
}]

//Deploy tier 3 Mgmt Groups
@batchSize(1)
resource tier_3_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier3MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_2_mgs
  ]
}]

//Deploy tier 4 Mgmt Groups
@batchSize(1)
resource tier_4_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier4MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_3_mgs
  ]
}]

//Deploy tier 5 Mgmt Groups
@batchSize(1)
resource tier_5_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier5MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_4_mgs
  ]
}]

//Deploy tier 6 Mgmt Groups
@batchSize(1)
resource tier_6_mgs 'Microsoft.Management/managementGroups@2021-04-01' = [for mg in tier6MgmtGroups: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', mg.parentId)
      }
    }
  }
  dependsOn: [
    tier_5_mgs
  ]
}]

resource mg_creation_auth 'Microsoft.Management/managementGroups/settings@2021-04-01' = if (configMGSettings) {
  name: '${tenantRootMgId}/default'
  properties: {
    requireAuthorizationForGroupCreation: authForNewMG
    defaultManagementGroup: empty(defaultMgId) ? null : tenantResourceId('Microsoft.Management/managementGroups', defaultMgId)
  }
  dependsOn: [
    tier_1_mgs
    tier_2_mgs
    tier_3_mgs
    tier_4_mgs
    tier_5_mgs
    tier_6_mgs
  ]
}

output managementGroups array = [for mg in allMgs: {
  id: tenantResourceId('Microsoft.Management/managementGroups', mg.id)
  displayName: mg.displayName
}]

output tier_1_mgs array = [for (mg, i) in tier1MgmtGroups: {
  id: tier_1_mgs[i].id
  displayName: tier_1_mgs[i].properties.displayName
  parentId: tier_1_mgs[i].properties.details.parent.id
}]

output tier_2_mgs array = [for (mg, i) in tier2MgmtGroups: {
  id: tier_2_mgs[i].id
  displayName: tier_2_mgs[i].properties.displayName
  parentId: tier_2_mgs[i].properties.details.parent.id
}]

output tier_3_mgs array = [for (mg, i) in tier3MgmtGroups: {
  id: tier_3_mgs[i].id
  displayName: tier_3_mgs[i].properties.displayName
  parentId: tier_3_mgs[i].properties.details.parent.id
}]

output tier_4_mgs array = [for (mg, i) in tier4MgmtGroups: {
  id: tier_4_mgs[i].id
  displayName: tier_4_mgs[i].properties.displayName
  parentId: tier_4_mgs[i].properties.details.parent.id
}]

output tier_5_mgs array = [for (mg, i) in tier5MgmtGroups: {
  id: tier_5_mgs[i].id
  displayName: tier_5_mgs[i].properties.displayName
  parentId: tier_5_mgs[i].properties.details.parent.id
}]

output tier_6_mgs array = [for (mg, i) in tier6MgmtGroups: {
  id: tier_6_mgs[i].id
  displayName: tier_6_mgs[i].properties.displayName
  parentId: tier_6_mgs[i].properties.details.parent.id
}]

output root_mg_settings object = mg_creation_auth
