targetScope= 'subscription'

// General parameters
param custPrefix string = 'dlm'
param subPrefix string = 'management'
param location string = 'westeurope'
param Tags object = {
  Environment: 'Prod'
  Department: 'IT'
  Supportedby: 'Pink'
}

// VNET parameters
param vnetAddressPrefix string ='0.0.0.0/24'
param subnet1Prefix string = '0.0.0.0/25'

//VM parameters
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

resource rgsiem 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-siem-prd-001'
  location: location
}

//Import modules
module network '3.1-network.bicep' = {
  scope: rgnet
  name: 'NetworkDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Prefix: subnet1Prefix
  }
}

/*
module core '3.2-core.bicep' = {
  scope: rgcore
  name: 'CoreDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    subPrefix: subPrefix
  }
}
*/

module vms '3.3-vms.bicep' = {
  scope: rgvms
  name: 'VMsDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    subnetID: network.outputs.ManagementsubnetID
    Tags: Tags
    localadmin: localadmin
    localadminpassword: localadminpassword
  }
  dependsOn: [
    network
  ]
}

module siem '3.4-siem.bicep' = {
  scope: rgsiem
  name: 'SiemDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
  }
}
