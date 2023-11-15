param custPrefix string
param location string
param vnetAddressPrefix string
param subnet1Prefix string
param dnsServerIPAddress string = ''

param Tags object

// Create Network Security Group
resource nsgide 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${custPrefix}-nsg-snet-pl-ide-prd-001'
  location: location
  tags: Tags
}

//Create VNET with a single subnet
resource vnetide 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: '${custPrefix}-vnet-pl-ide-prd-westeu-001'
  location: location
  tags: Tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: ((!empty(dnsServerIPAddress)) ? array(dnsServerIPAddress) : null)
    }
    subnets: [
      {
        name: '${custPrefix}-snet-pl-ide-prd-001'
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: nsgide.id
          }
        }
      }
    ]
  }
}

output subnetId string = vnetide.properties.subnets[0].id
