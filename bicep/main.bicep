// main.bicep nothing fancy here, just the basics.
// uses main.bicepparam for parameters

// parameters

@description('The location for all resources.')
param location string = resourceGroup().location

@description('Timestamp for the deployment')
param deploymentTimestamp string = utcNow()

@description('The prefix name for all resources.')
param PrefixName string = 'foundry'

@description('Storage kind')
param storageKind string = 'StorageV2'

@description('Storage SKU')
param storageSku string = 'Standard_GRS'

@description('VM sku size')
param vmSize string = 'Standard_B1ms'

@description('VM data disk size in GB')
param dataDiskSizeGB int = 64

@description('Admin username for the VM')
param adminUsername string = 'foundry'

@description('My public SSH key')
param adminPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCS5iyFyDcG8hAvYwQjEzijmGeJibEEuZ57WfZ0QzivUScWbF0vYtglpiXv9cxlclDGc6J2ehWdOvsg/beR89iN2dUHxQsoBDhkwBeSeuUa8NQCMsm3BdxqNW+R/PQzahGzcOQ0UNsdlj+U57AFnGStaogErR5o5rjhNEF9j4bpugGHIkMQY7SnEVpAPHypmvAb9WMU4uGnO0LqH5kZy3dA2XLsGCtfhlzst7p0MXNkoZqaWMwoXSVvaJjYFqNzfJW2WVkpbSdpa1mfNI/g0R7PT4Pm59HiF7y5Ex7HWczLkqp54LZwMaWR4Km7Brz0V4hidSBXm+eAPSgx0/CX1BmYfGfJ2yifd2EtdIVORY5btNAdstUtD1B6L0SH80hLuvFr9dYHsWFVLkOaeYypr/k0RWOiSFVip4DrKT2nGew194/jD/YIm/GuN97+qukxF7UVpqlJvfEW1wzTl7WwAceuJ90vi7gSvRRdwaSkVjxDLgGhnqSHcnIguTTcLGyuiNKGyW2nibTnTZqCYThYuOpHJ/3nBpPYuO9rjI8nayz7E7BBl3XxBrjzwiuffcMrY0Hwzatsm4W9ALl6lvRyzFOOW7lvc18UJjQ9c7BI5bCO4CGtFAjs0fejdfR9udDkSn1cbhMBi+8kMnPg4b4RKV6bl6P//MlBUhakIA7yUVaZw== aengleman@ASENj893Q13'

@description('My public IPv4 address')
param myPublicIPv4 string = '69.249.125.110/32'


//@description('Cloudflare CIDR IPs')
//param cloudflareCIDR array = ['173.245.48.0/20'
//                              '103.21.244.0/22'
//                              '103.22.200.0/22'
//                              '103.31.4.0/22'
//                              '141.101.64.0/18'
//                              '108.162.192.0/18'
//                              '190.93.240.0/20'
//                              '188.114.96.0/20'
//                              '197.234.240.0/22'
//                              '198.41.128.0/17'
//                              '162.158.0.0/15'
//                              '172.64.0.0/13'
//                              '131.0.72.0/22'
//                              '104.16.0.0/13'
//                              '104.24.0.0/14']

@description('The name of the virtual network.')
param virtualNetworkName string = '${PrefixName}-vnet'

@description('The address prefix for the virtual network.')
param virtualNetworkAddressPrefix string = '10.250.0.0/24'

@description('The name of the subnet.')
param subnetName string = '${PrefixName}-subnet'

@description('The address prefix for the subnet.')
param subnetAddressPrefix string = '10.250.0.0/24'

@description('Entra object ID for Key Vault Access.')
param keyVaultAccessObjectId string = '1d1d86b3-58ff-44c9-9443-f64fc2722bc9'

@description('Tenant ID for Key Vault Access.')
param keyVaultAccessTenantId string = 'a8059119-87be-4583-9a4e-7fc59ec6cbf9'

// variables

var tags = union(resourceGroup().tags, {
  CreatedBy: 'Bicep Template'
  CreatedOn: deploymentTimestamp
})

// Resources

// Storage Accounts

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  kind: storageKind
  location: location
  name: '${PrefixName}-st'
  sku: {
    name: storageSku
  }
  tags: tags
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// Key Vaults

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  location: location
  name: '${PrefixName}-kv'
  tags: tags
  properties: {
    accessPolicies: [
      {
        objectId: keyVaultAccessObjectId
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
        tenantId: keyVaultAccessTenantId
      }      
    ]
      sku: {
      family: 'A'
      name: 'standard'
  }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 7
    tenantId: keyVaultAccessTenantId
  }
}

// Network Security Groups

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${PrefixName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-Inbound'
        properties: {
          description: 'Needed for administering the server'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: myPublicIPv4
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 160
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowInternetOutbound'
        properties: {
          description: 'Allow outbound to Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Virtual Networks

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
// Subnets    

    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Public IP Addresses

resource publicIPAddress01 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-vm-01-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddress02 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-vm-02-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddress03 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-vm-03-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Network Interfaces
resource networkInterface01 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-vm-01-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddress01.id
          }
        }
      }
    ]
  }
}

resource networkInterface02 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-vm-02-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddress02.id
          }
        }
      }
    ]
  }
}

resource networkInterface03 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-vm-03-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddress03.id
          }
        }
      }
    ]
  }
}

// Virtual Machines
resource virtualMachine01 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${PrefixName}-dev-vm'
  location: location
  tags: tags
  zones:  [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${PrefixName}-dev-vm-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
        dataDisks: [
          {
            name: '${PrefixName}-dev-vm-datadisk'
            lun: 0
            diskSizeGB: dataDiskSizeGB
            createOption: 'Empty'
            managedDisk: {
              storageAccountType: 'Standard_LRS'
            }
          }
        ]
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: networkInterface01.id
          }
        ]
      }
      osProfile: {
        computerName: '${PrefixName}-dev-vm'
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminPublicKey
              }
            ]
          }
        }
      }
    }
  }
 
  resource virtualMachine02 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${PrefixName}-tst-vm'
  location: location
  tags: tags
  zones:  [
    '2'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${PrefixName}-tst-vm-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
        dataDisks: [
          {
            name: '${PrefixName}-tst-vm-datadisk'
            lun: 0
            diskSizeGB: dataDiskSizeGB
            createOption: 'Empty'
            managedDisk: {
              storageAccountType: 'Standard_LRS'
            }
          }
        ]
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: networkInterface01.id
          }
        ]
      }
      osProfile: {
        computerName: '${PrefixName}-tst-vm'
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminPublicKey
              }
            ]
          }
        }
      }
    }
  }

    resource virtualMachine03 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${PrefixName}-prd-vm'
  location: location
  tags: tags
  zones:  [
    '3'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${PrefixName}-prd-vm-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
        dataDisks: [
          {
            name: '${PrefixName}-prd-vm-datadisk'
            lun: 0
            diskSizeGB: dataDiskSizeGB
            createOption: 'Empty'
            managedDisk: {
              storageAccountType: 'Standard_LRS'
            }
          }
        ]
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: networkInterface01.id
          }
        ]
      }
      osProfile: {
        computerName: '${PrefixName}-prd-vm'
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminPublicKey
              }
            ]
          }
        }
      }
    }
  }
