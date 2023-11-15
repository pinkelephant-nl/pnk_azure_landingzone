param custPrefix string
param custId string
param location string
param Tags object
param subnetID string

param localadmin string
@secure()
param localadminpassword string

// Reference Availibility set
resource avide 'Microsoft.Compute/availabilitySets@2023-03-01' existing = {
  name: '${custPrefix}-as-pl-ide-prd-001'
}

// Creating Network Interface Card
resource adcnic2 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-${custPrefix}azpadc05-01'
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

resource adcmachine2 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-adc-05'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpadc05-01'
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
      computerName: '${custPrefix}-azp-adc-05'
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
          id:adcnic2.id
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

// Creating secondairy Domain Controller
resource joinsecondairyDomainController 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: adcmachine2
  name: 'Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: 'https://github.com/MarksMultiverse/ALZ-standard/raw/main/Add-DomainController.zip'
      ConfigurationFunction: 'Add-DomainController.ps1\\Add-DomainController'
      Properties: {
        domainFQDN: '${custId}.local'
        adminCredential: {
          UserName: localadmin
          Password: 'PrivateSettingsRef:localadminpassword'
        }
        domainCredential: {
          Username: '${custId}.local\\${localadmin}'
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
