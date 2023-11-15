// General parameters
param custPrefix string
param location string
param Tags object

// VNET parameters
param vnetAddressPrefix string
param subnet1Prefix string


//Create VNET with a single subnet
resource vnetman 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: '${custPrefix}-vnet-pl-man-prd-westeu-001'
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
        name: '${custPrefix}-snet-pl-man-prd-001'
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: nsgman.id
          }
        }
      }
    ]
  }
}

output ManagementsubnetID string = vnetman.properties.subnets[0].id

// Create Network Security Group
resource nsgman 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${custPrefix}-nsg-snet-pl-man-prd-001'
  location: location
  tags: Tags
}
