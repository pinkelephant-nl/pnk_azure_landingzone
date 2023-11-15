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
param dataDisks6 array = [
  {
    createOption: 'Empty'
    caching: 'None'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 4096
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
param dataDisks8 array = [
  {
    createOption: 'Empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 127
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

// Creating Network Interface Card AppServer 4 (ProdX Checkwegers)
resource app4nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp04-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.4'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 5 (Prophix)
resource app5nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp05-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.5'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 6 (Prophix DB)
resource app6nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp06-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.6'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 7 (Toegangsys)
resource app7nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp07-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.7'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 8 (Corades)
resource app8nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp08-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.8'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating AppServer 4 (ProdX Checkwegers)
resource appserver4 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-04'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp04-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 256
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-04'
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
          id: app4nic.id
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

// Creating AppServer 5 (Prophix)
resource appserver5 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-05'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp05-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 256
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-05'
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
          id: app5nic.id
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

// Creating AppServer 6 (Prophix DB)
resource appserver6 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${custPrefix}-azp-app-06'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      dataDisks: [for (item, j) in dataDisks6: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        name: '${custPrefix}-datadisk-${custPrefix}azpapp06-0${j+1}'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp06-01'
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
      computerName: '${custPrefix}-azp-app-06'
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
          id: app6nic.id
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

// Installing extension for AppServer 6 (Prophix DB)
resource appserver6extension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'GuestAttestation'
  parent: appserver6
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.WindowsAttestation'
    type: 'GuestAttestation'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: 'GuestAttestation'
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

// Creating SQL for AppServer 6 (Prophix DB)
resource appserver6sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: '${custPrefix}-azp-app-06'
  location: location
  properties: {
    virtualMachineResourceId: appserver6.id
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
    autoPatchingSettings: {
      dayOfWeek: 'Sunday'
      enable: true
      maintenanceWindowDuration: 60
      maintenanceWindowStartingHour: 6
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        sqlAuthUpdateUserName: 'SQL_Pink'
        sqlAuthUpdatePassword: 'WKEWpU3PfqTpe7CJ'
      }
    }
  }
}

// Creating AppServer 7 (Toegangsys)
resource appserver7 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-07'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpapp07-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 256
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-07'
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
          id: app7nic.id
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

// Creating AppServer 8 (Corades)
resource appserver8 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${custPrefix}-azp-app-08'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      dataDisks: [for (item, j) in dataDisks8: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        name: '${custPrefix}-datadisk-${custPrefix}azpapp08-0${j+1}'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp08-01'
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
      computerName: '${custPrefix}-azp-app-08'
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
          id: app8nic.id
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

// Installing extension for AppServer 8 (Corades)
resource appserver8extension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'GuestAttestation'
  parent: appserver8
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.WindowsAttestation'
    type: 'GuestAttestation'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: 'GuestAttestation'
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

// Creating SQL for AppServer 8 (Corades)
resource appserver8sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: '${custPrefix}-azp-app-08'
  location: location
  properties: {
    virtualMachineResourceId: appserver8.id
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
