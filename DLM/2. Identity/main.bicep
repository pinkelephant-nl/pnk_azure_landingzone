targetScope= 'subscription'

// General parameters
param custPrefix string = 'dlm'
param subPrefix string = 'identity'
param location string = 'westeurope'
param Tags object = {
  Environment: 'Prod'
  Department: 'IT'
  Supportedby: 'Pink'
}

// Domain parameters
param custId string = 'daelmans'

// VNET parameters
param vnetAddressPrefix string = '10.210.10.0/24'
param subnet1Prefix string = '10.210.10.0/25'

// VM parameters
param localadmin string = 'adm_pink'
@secure()
param localadminpassword string

// Create resourcegroups
resource rgcore 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-core-prd-001'
  location: location
}

resource rgnet 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-net-prd-001'
  location: location
}

resource rgvms 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-vms-prd-001'
  location: location
}

module network '2.1-network.bicep' = {
  scope: rgnet
  name: 'NetworkDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    subnet1Prefix: subnet1Prefix
    vnetAddressPrefix: vnetAddressPrefix
  }
}

module vms '2.3-vms.bicep' = {
  scope: rgvms
  name: 'VMsDeployment'
  params: {
    custPrefix: custPrefix
    localadminpassword: localadminpassword
    location: location
    Tags: Tags
    custId: custId
    subnetID: network.outputs.subnetId
    localadmin: localadmin
  }
}

module vnetDNS '2.1-network.bicep' = {
  scope: rgnet
  name: 'DNSdeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    dnsServerIPAddress: vms.outputs.privateIPAddress
    subnet1Prefix: subnet1Prefix
    vnetAddressPrefix: vnetAddressPrefix
  }
  dependsOn: [
    vms
  ]
}

module dc2 '2.3.1-dc2.bicep' = {
  scope: rgvms
  name: 'DC2deployment'
  params: {
    custId: custId
    custPrefix: custPrefix
    localadmin: localadmin
    localadminpassword: localadminpassword
    location: location
    subnetID: network.outputs.subnetId
    Tags: Tags
  }
  dependsOn: [
    vnetDNS
  ]
}
