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

param dataDisks11 array = [
  {
    createOption: 'Empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Premium_LRS'
    diskSizeGB: 1400
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Standard_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Standard_LRS'
    diskSizeGB: 32
  }
]

param dataDisks12 array = [
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
    storageAccountType: 'Standard_LRS'
    diskSizeGB: 32
  }
  {
    createOption: 'empty'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    storageAccountType: 'Standard_LRS'
    diskSizeGB: 32
  }
]

resource vnetlz 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'dlm-vnet-lz-dlm-prd-westeu-001'
  scope: resourceGroup('dlm-lz-dlm-net-prd-001')
}

// Creating Network Interface Card AppServer 11 (Infor LN/ SQL db/ Hidox)
resource app11nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp11-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.11'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 12 (SQL db tbv Infor OS)
resource app12nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp12-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.12'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 13 (Infor OS)
resource app13nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp13-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.13'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 14 (Webserver tbv GGP)
resource app14nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp14-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.14'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating Network Interface Card AppServer 15 (LN UI)
resource app15nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${custPrefix}-nic-qizazpapp15-01'
  location: location
  tags: Tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.210.14.15'
          subnet: {
            id: vnetlz.properties.subnets[1].id
          }
        }
      }
    ]
    enableIPForwarding: false
  }
}

// Creating AppServer 11 (Infor LN/ SQL db/ Hidox)
resource appserver11 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${custPrefix}-azp-app-11'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D16s_v5'
    }
    storageProfile: {
      dataDisks: [for (item, j) in dataDisks11: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        name: '${custPrefix}-datadisk-${custPrefix}azpapp11-0${j+1}'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp11-01'
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
      computerName: '${custPrefix}-azp-app-11'
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
          id: app11nic.id
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

// Installing extension for AppServer 11 (Infor LN/ SQL db/ Hidox)
resource appserver11extension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'GuestAttestation'
  parent: appserver11
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

// Creating SQL for AppServer 11 (Infor LN/ SQL db/ Hidox)
resource appserver11sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: '${custPrefix}-azp-app-11'
  location: location
  properties: {
    virtualMachineResourceId: appserver11.id
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

// Creating AppServer 12 (SQL db tbv Infor OS)
resource appserver12 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${custPrefix}-azp-app-12'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      dataDisks: [for (item, j) in dataDisks12: {
        lun: j
        createOption: item.createOption
        caching: item.caching
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
        diskSizeGB: item.diskSizeGB
        name: '${custPrefix}-datadisk-${custPrefix}azpapp12-0${j+1}'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp12-01'
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
      computerName: '${custPrefix}-azp-app-12'
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
          id: app12nic.id
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

// Installing extension for AppServer 12 (Infor LN/ SQL db/ Hidox)
resource appserver12extension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'GuestAttestation'
  parent: appserver12
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

// Creating SQL for AppServer 12 (SQL db tbv Infor OS)
resource appserver12sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: '${custPrefix}-azp-app-12'
  location: location
  properties: {
    virtualMachineResourceId: appserver12.id
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

// Creating AppServer 13 (Infor OS)
resource appserver13 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-13'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp13-01'
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
      computerName: '${custPrefix}-azp-app-13'
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
          id: app13nic.id
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

// Creating AppServer 14 (Webserver tbv GGP)
resource appserver14 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-14'
  location: location
  tags: Tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D8s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${custPrefix}-osdisk-${custPrefix}azpapp14-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-14'
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
          id: app14nic.id
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

// Creating AppServer 15 (LN UI)
resource appserver7 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: '${custPrefix}-azp-app-15'
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
        name: '${custPrefix}-osdisk-${custPrefix}azpapp15-01'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 127
        deleteOption: 'Detach'
      }
    }
    osProfile: {
      computerName: '${custPrefix}-azp-app-15'
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
          id: app15nic.id
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
