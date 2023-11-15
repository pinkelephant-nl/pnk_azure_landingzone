targetScope= 'subscription'
param location string = 'westeurope'
param custPrefix string = 'dlm'
param subPrefix string = 'lz'
param tenantId string = 'fd7050d1-7fe7-4411-8539-0b2ee218b709'

// VNET parameters
param vnetAddressPrefix string ='10.210.12.0/22'
param subnet1Prefix string = '10.210.12.0/25'
param subnet2Prefix string = '10.210.14.0/25'

// AVD parameters
param avd bool = true
param subnet3Prefix string = '10.210.13.0/25'

param Tags object = {
  Environment: 'Prod'
  Department: 'IT'
  Supportedby: 'Pink'
}

param localadmin string = 'adm_pink'

@secure()
param localadminpassword string

// Create resourcegroups
resource rgcore 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-core-prd-001'
  location: location
}

resource rgnet 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-net-prd-001'
  location: location
}

resource rgvms 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-vms-prd-001'
  location: location
}

resource rgmem 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-mem-prd-001'
  location: location
}

resource rgavdprd 'Microsoft.Resources/resourceGroups@2022-09-01' = if (avd) {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-avd-prd-001'
  location: location
}

resource rgavddev 'Microsoft.Resources/resourceGroups@2022-09-01' = if (avd) {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-avd-dev-001'
  location: location
}

resource rgvaibprd 'Microsoft.Resources/resourceGroups@2022-09-01' = if (avd) {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-aib-prd-001'
  location: location
}

resource rgaibdev 'Microsoft.Resources/resourceGroups@2022-09-01' = if (avd) {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-aib-dev-001'
  location: location
}

resource rgilnprd 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-iln-prd-001'
  location: location
}

resource rgilndev 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-iln-dev-001'
  location: location
}

resource rgilntst 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-${subPrefix}-${custPrefix}-iln-tst-001'
  location: location
}


module network '4.1-network.bicep' = {
  scope: rgnet
  name: 'NetworkDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    avd: avd
    subnet1Prefix: subnet1Prefix
    subnet2Prefix: subnet2Prefix
    subnet3Prefix: subnet3Prefix
    vnetAddressPrefix: vnetAddressPrefix
  }
}

module core '4.2-core.bicep' = {
  scope: rgcore
  name: 'CoreDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    tenantId: tenantId
    //custId: custId
    subnetID: network.outputs.subnetID
    //custId: custId
    //domainGuid: domainGuid
    //domainSid: domainSid
  }
  dependsOn: [
    network
  ]
}

module vms '4.3-vms.bicep' = {
  scope: rgvms
  name: 'VMDeployment'
  params: {
    //custId: custId
    custPrefix: custPrefix
    localadmin: localadmin
    localadminpassword: localadminpassword
    location: location
    Tags: Tags
  }
  dependsOn: [
    network, core
  ]
}

module ilnprd '4.4-vms-inlprod.bicep' = {
  scope: rgilnprd
  name: 'ILNprdDeployment'
  params: {
    custPrefix: custPrefix
    localadmin: localadmin
    localadminpassword: localadminpassword
    location: location
    Tags: Tags
  }
  dependsOn: [
    network, core
  ]
}

module ilndev '4.5-vms-inldev.bicep' = {
  scope: rgilndev
  name: 'ILNdevDeployment'
  params: {
    custPrefix: custPrefix
    localadmin: localadmin
    localadminpassword: localadminpassword
    location: location
    Tags: Tags
  }
  dependsOn: [
    network, core
  ]
}
