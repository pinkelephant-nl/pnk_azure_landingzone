targetScope= 'subscription'

// General parameters
param custPrefix string = 'dlm'
param subPrefix string = 'connectivity'
param location string = 'westeurope'
param Tags object = {
  Environment: 'Prod'
  Department: 'IT'
  Supportedby: 'Pink'
}

// VNET parameters
param vnetAddressPrefix string ='10.210.8.0/23'
param subnet1Prefix string = '10.210.9.0/25'
param GatewaySubnetPrefix string = '10.210.8.0/27'
param bastionSubnetPrefix string = '10.210.8.32/28'

// VPN 1 parameters
param LocalNetworkGateway1destination string = 'true'
param LocalNetworkGateway1addressprefixes array = [
  '10.10.0.0/23'
  '10.79.0.0/23'
]
param LocalNetworkGateway1GatewayAddress string = '87.233.40.5'
param connection1sharedkey string = 'Lvc8!78MTaaY1kzP@hsfUy'

// VPN 2 parameters
param LocalNetworkGateway2destination string = 'oss'
param LocalNetworkGateway2addressprefixes array = [
  '10.10.0.0/23'
  '10.79.0.0/23'
]
param LocalNetworkGateway2GatewayAddress string = '10.40.5.7'
param connection2sharedkey string = ''

// VPN 3 parameters
param LocalNetworkGateway3destination string = 'scherpenzeel'
param LocalNetworkGateway3addressprefixes array = [
  '10.10.0.0/23'
  '10.79.0.0/23'
]
param LocalNetworkGateway3GatewayAddress string = '10.40.5.8'
param connection3sharedkey string = ''

// VPN 4 parameters
param LocalNetworkGateway4destination string = 'nieuwkuijk'
param LocalNetworkGateway4addressprefixes array = [
  '10.10.0.0/23'
  '10.79.0.0/23'
]
param LocalNetworkGateway4GatewayAddress string = '10.40.5.9'
param connection4sharedkey string = ''

// Create resourcegroups
resource rgcore 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-core-prd-001'
  location: location
}

resource rgnet 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-net-prd-001'
  location: location
}

//Import modules
module network '1.1-network.bicep' = {
  scope: rgnet
  name: 'NetworkDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    subPrefix: subPrefix
    Tags: Tags
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Prefix: subnet1Prefix
    GatewaySubnetPrefix: GatewaySubnetPrefix
    bastionSubnetPrefix: bastionSubnetPrefix
    LocalNetworkGateway1addressprefixes: LocalNetworkGateway1addressprefixes
    LocalNetworkGateway1destination: LocalNetworkGateway1destination
    LocalNetworkGateway1GatewayAddress: LocalNetworkGateway1GatewayAddress
    connection1sharedkey: connection1sharedkey
    LocalNetworkGateway2addressprefixes: LocalNetworkGateway2addressprefixes
    LocalNetworkGateway2destination: LocalNetworkGateway2destination
    LocalNetworkGateway2GatewayAddress: LocalNetworkGateway2GatewayAddress
    connection2sharedkey: connection2sharedkey
    LocalNetworkGateway3addressprefixes: LocalNetworkGateway3addressprefixes
    LocalNetworkGateway3destination: LocalNetworkGateway3destination
    LocalNetworkGateway3GatewayAddress: LocalNetworkGateway3GatewayAddress
    connection3sharedkey: connection3sharedkey
    LocalNetworkGateway4addressprefixes: LocalNetworkGateway4addressprefixes
    LocalNetworkGateway4destination: LocalNetworkGateway4destination
    LocalNetworkGateway4GatewayAddress: LocalNetworkGateway4GatewayAddress
    connection4sharedkey: connection4sharedkey
  }
}

module core '1.2-core.bicep' = {
  scope: rgcore
  name: 'CoreDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    subPrefix: subPrefix
  }
  dependsOn: [
    network
  ]
}
