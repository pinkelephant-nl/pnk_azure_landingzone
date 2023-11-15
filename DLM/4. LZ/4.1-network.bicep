// General parameters
param custPrefix string
param location string
param Tags object
// VNET parameters
param vnetAddressPrefix string
param subnet1Prefix string
param subnet2Prefix string
// AVD parameters
param avd bool
param subnet3Prefix string

// Create Network Security Groups
resource nsginf 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${custPrefix}-nsg-snet-lz-${custPrefix}-inf-prd-001'
  location: location
  tags: Tags
}

resource nsgapp 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${custPrefix}-nsg-snet-lz-${custPrefix}-app-prd-001'
  location: location
  tags: Tags
}

resource nsgavd 'Microsoft.Network/networkSecurityGroups@2022-07-01' = if (avd) {
  name: '${custPrefix}-nsg-snet-lz-${custPrefix}-avd-prd-001'
  location: location
  tags: Tags
}


//Create VNET with a two subnets
resource vnetlz 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: '${custPrefix}-vnet-lz-${custPrefix}-prd-westeu-001'
  location: location
  tags: Tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: '${custPrefix}-snet-lz-${custPrefix}-core-prd-001'
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: nsginf.id
          }
        }
      }
      {
        name: '${custPrefix}-snet-lz-${custPrefix}-app-prd-001'
        properties: {
          addressPrefix: subnet2Prefix
          networkSecurityGroup: {
            id: nsgapp.id
          }
        }
      }
    ]
  }
}
output subnetID string = vnetlz.properties.subnets[0].id

resource avdsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = if (avd) {
  name:  '${custPrefix}-snet-lz-${custPrefix}-avd-prd-001'
  parent: vnetlz
  properties: {
    addressPrefix: subnet3Prefix
    networkSecurityGroup: {
      id: nsgavd.id
    }
  }
}
