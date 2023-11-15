param custPrefix string
param custId string
param location string
param Tags object
param subnetID string

param localadmin string
@secure()
param localadminpassword string

// Creating Availibility set
resource avide 'Microsoft.Compute/availabilitySets@2022-11-01' = {
  name: '${custPrefix}-as-pl-ide-prd-001'
  location: location
  tags: Tags
  sku: {
    name: 'Aligned' 
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
}

// Creating Network Interface Card
resource adcnic1 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-${custPrefix}azpadc04-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

output privateIPAddress string = adcnic1.properties.ipConfigurations[0].properties.privateIPAddress

// Creating Domain Controller
resource adcmachine1 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-adc-04'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpadc04-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-adc-04'
      adminUsername: localadmin
      adminPassword: localadminpassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id:adcnic1.id
        }
      ]
    }
    availabilitySet: {
      id: avide.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

// Creating Domain
resource domainControllerConfiguration 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: adcmachine1
  name: 'Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: 'https://github.com/MarksMultiverse/ALZ-standard/raw/main/Deploy-DomainServices.zip'
      ConfigurationFunction: 'Deploy-DomainServices.ps1\\Deploy-DomainServices'
      Properties: {
        domainFQDN: '${custId}.local'
        adminCredential: {
          UserName: localadmin
          Password: 'PrivateSettingsRef:localadminpassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        localadminpassword: localadminpassword
      }
    }
  }
}

// Creating OU Structure
resource ADOUdeploymentscript 'Microsoft.Compute/virtualMachines/runCommands@2023-03-01' = {
  parent: adcmachine1
  name: 'Creat_AD_OU_Structure'
  location: location
  properties: {
    source: {
      scriptUri: 'https://raw.githubusercontent.com/MarksMultiverse/ALZ-standard/main/Create_AD_OU_Structure.ps1'
    }
  }
  dependsOn: [
    domainControllerConfiguration
  ]
}
