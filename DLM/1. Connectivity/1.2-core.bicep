// General parameters
param custPrefix string
param location string
param Tags object
param subPrefix string


var snetbastion = resourceId('${custPrefix}-pl-${subPrefix}-net-prd-001', 'Microsoft.Network/virtualNetworks/subnets', '${custPrefix}-vnet-pl-con-prd-westeu-001', 'AzureBastionSubnet')

//Creating Azure Bastion

resource bastionpip 'Microsoft.Network/publicIPAddresses@2022-11-01' existing = {
  name: '${custPrefix}-pip-pl-con-prd-002'
  scope: resourceGroup('${custPrefix}-pl-${subPrefix}-net-prd-001')
}

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: '${custPrefix}-bas-pl-con-prd-001'
  location: location
  tags: Tags
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionpip.id
          }
          subnet: {
            id: snetbastion
          }
        }
      }
    ]
  }
}
