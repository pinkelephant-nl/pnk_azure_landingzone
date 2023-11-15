param custPrefix string
param location string
param Tags object
param subnetID string

@secure()
param tenantId string

// Creating Key Vault
resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: '${custPrefix}-kv-lz-${custPrefix}-prd-001'
  location: location
  tags: Tags
  properties: {
    accessPolicies: [
      
    ]
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
    enablePurgeProtection: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
  }
}

// Create Storage Account
resource salz 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${custPrefix}safileshareprd001'
  location: location
  tags: Tags
  sku: {
    name:  'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    largeFileSharesState: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
    /*
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: 'AD'
      activeDirectoryProperties: {
        domainGuid: domainGuid
        domainName: '${custId}.local'
        domainSid: domainSid
        forestName: '${custId}.local'
        netBiosDomainName: custId
      }*/
    }
}

// Creating File services
resource fileservices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: salz
}

// Creating File shares
resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileservices
  name: custPrefix
  properties: {
    accessTier: 'Hot'
  }
}

resource fslogixprod 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileservices
  name: 'fslogixprod'
  properties: {
    accessTier: 'TransactionOptimized'
  }
}

resource fslogixtest 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  parent: fileservices
  name: 'fslogixtest'
  properties: {
    accessTier: 'TransactionOptimized'
  }
}
/*
// Create Storage Account for SQL 
resource salzsql 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'testsa01uifduqvbddndufb3'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned' 
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
      }
      requireInfrastructureEncryption: true
    }
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices' 
    }
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    allowCrossTenantReplication: false
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
    isLocalUserEnabled: false
    isSftpEnabled: false
    supportsHttpsTrafficOnly: true
  }
}

output sqlsaname string = salzsql.name
output sqlnameid string = salzsql.id
output apiVersion string = salzsql.apiVersion

resource blobPe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${custPrefix}-pe-lz-${custPrefix}-${salzsql.name}-prd-001'
  location: location
  tags: Tags
  properties: {
    customNetworkInterfaceName: ''
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'blob'
          memberName: 'blob'
          privateIPAddress: ''
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: '${custPrefix}-pe-lz-${custPrefix}-${salzsql.name}-prd-001'
        properties: {
          privateLinkServiceId: salzsql.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: subnetID
    }
  }
}

resource dfsPe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${custPrefix}-pe-lz-${custPrefix}-${salz.name}-prd-001'
  location: location
  tags: Tags
  properties: {
    customNetworkInterfaceName: '${custPrefix}-nic-lz-${custPrefix}-${salz.name}-prd-001'
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'dfs'
          memberName: 'dfs'
          privateIPAddress: ''
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: '${custPrefix}-pe-lz-${custPrefix}-${salz.name}-prd-001'
        properties: {
          privateLinkServiceId: salz.id
          groupIds: [
            'dfs'
          ]
        }
      }
    ]
    subnet:  {
      id: subnetID
    }
  }
}
*/
