targetScope = 'resourceGroup'

// General parameters
param custPrefix string
param location string
param Tags object

// VM parameters
param localadmin string
@secure()
param localadminpassword string

// SQL parameters
param dataPath string = 'F:\\SQL_DB'
param logPath string  = 'G:\\SQL_LOG'
param tempPath string = 'H:\\TEMP_DB'

param dataDisks21 array = [
  {
    createOption: 'Empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 1500
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
]

param dataDisks22 array = [
  {
    createOption: 'Empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 300
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 32
  }
]

resource vnetlz 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'dlm-vnet-lz-dlm-prd-westeu-001'
  scope: resourceGroup('dlm-lz-dlm-net-prd-001')
}


// Creating Network Interface Card AppServer 21 (Infor LN/ SQL db/ Hidox)
resource app21nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp21-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.21'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 22 (SQL db tbv Infor OS)
resource app22nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp22-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.22'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 23 (Infor OS)
resource app23nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp23-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.23'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 24 (Webserver tbv GGP)
resource app24nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp24-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.24'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating AppServer 21 (Infor LN/ SQL db/ Hidox)
resource appserver21 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${custPrefix}-azp-app-21'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D8ls_v5'
    }
    storageProfile: {
      dataDisks: [for (item, j) in dataDisks21: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        name: '${custPrefix}-datadisk-${custPrefix}azpapp21-0${j+1}'
        managedDisk: {
          storageAccountType: item.storageAccountType
        }
      }]
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2022'
        sku: 'Standard-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpapp21-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_ZRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-21'
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
          id: app21nic.id
        }
      ]
    }
    /*
    securityProfile: {
      securityType: 'TrustedLaunch'
      encryptionAtHost: true
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: vTpm
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

// Creating SQL for AppServer 21 (Infor LN/ SQL db/ Hidox)
resource appserver21sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: '${custPrefix}-azp-app-21'
  location: location
  properties: {
    virtualMachineResourceId: appserver21.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: 'GENERAL'
      sqlDataSettings: {
        luns: [
          0
        ]
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: [
          1
        ]
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        luns: [
          2
        ]
        defaultFilePath: tempPath
      }
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        sqlAuthUpdateUserName: 'SQL_Pink'
        sqlAuthUpdatePassword: 'WKEWpU3PfqTpe7CJ'
      }
    }
  }
}

// Creating AppServer 22 (SQL db tbv Infor OS)
resource appserver22 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${custPrefix}-azp-app-22'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      dataDisks: [for (item, j) in dataDisks22: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        name: '${custPrefix}-datadisk-${custPrefix}azpapp22-0${j+1}'
        managedDisk: {
          storageAccountType: item.storageAccountType
        }
      }]
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2022'
        sku: 'Standard-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpapp22-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_ZRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-22'
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
          id: app22nic.id
        }
      ]
    }
    /*
    securityProfile: {
      securityType: 'TrustedLaunch'
      encryptionAtHost: true
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: vTpm
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

// Creating SQL for AppServer 22 (SQL db tbv Infor OS)
resource appserver22sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: '${custPrefix}-azp-app-22'
  location: location
  properties: {
    virtualMachineResourceId: appserver22.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: 'GENERAL'
      sqlDataSettings: {
        luns: [
          0
        ]
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: [
          1
        ]
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        luns: [
          2
        ]
        defaultFilePath: tempPath
      }
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        sqlAuthUpdateUserName: 'SQL_Pink'
        sqlAuthUpdatePassword: 'WKEWpU3PfqTpe7CJ'
      }
    }
  }
}

// Creating AppServer 23 (Infor OS)
resource appserver13 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-23'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_E4s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpapp23-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_ZRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-23'
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
          id: app23nic.id
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

// Creating AppServer 24 (Webserver tbv GGP)
resource appserver14 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-24'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpapp24-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_ZRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-24'
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
          id: app24nic.id
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
