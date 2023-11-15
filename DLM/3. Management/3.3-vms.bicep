// General parameters
param custPrefix string
param location string
param Tags object
param subnetID string

// VM parameters
@secure()
param localadmin string
@secure()
param localadminpassword string

// Creating Network Interface Card MgtServer 1
resource mgt1nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-${custPrefix}azpgmt01-01'
  location: location
  tags: Tags
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

// Creating Network Interface Card DMPserver 1
resource dmp1nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-${custPrefix}azpdmp01-01'
  location: location
  tags: Tags
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

// Creating Network Interface Card DMPserver 2
resource dmp2nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-${custPrefix}azpdmp02-01'
  location: location
  tags: Tags
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


// Creating MgtServer 1
resource mgtserver1 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-mgt-01'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2ads_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpmgt01-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_ZRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-mgt-01'
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
          id:mgt1nic.id
        }
      ]
    }
    /*
    securityProfile: {
      encryptionAtHost: true
      uefiSettings: {
        secureBootEnabled: true
      }
    }
    */
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

// Creating DMPServer 1
resource dmpserver1 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-dmp-01'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_E2ds_v5'
    }
    storageProfile: {
      dataDisks: [
        {
          name: '${custPrefix}-datadisk-${custPrefix}azpdmp01-01'
          createOption: 'Empty'
          lun: 0
          diskSizeGB: 400
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Premium_ZRS'
          }
        }
        {
          name: '${custPrefix}-datadisk-${custPrefix}azpdmp01-02'
          createOption: 'Empty'
          lun: 1
          diskSizeGB: 400
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'StandardSSD_ZRS'
          }
        }
      ]
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpdmp01-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_ZRS'
        }
        diskSizeGB: 200
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-dmp-01'
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
          id:dmp1nic.id
        }
      ]
    }
    /*
    securityProfile: {
      encryptionAtHost: true
      uefiSettings: {
        secureBootEnabled: true
      }
    }
    */
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

// Creating DMPServer 2
resource dmpserver2 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-dmp-02'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2lds_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpdmp02-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_ZRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-dmp-02'
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
          id:dmp2nic.id
        }
      ]
    }
    /*
    securityProfile: {
      encryptionAtHost: true
      uefiSettings: {
        secureBootEnabled: true
      }
    }
    */
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

