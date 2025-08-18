// main.bicep nothing fancy here, just the basics.
// parameters

@description('The location for all resources.')
param location string = resourceGroup().location

@description('Timestamp for the deployment')
param deploymentTimestamp string = utcNow()

@description('The prefix name for all resources.')
param PrefixName string = 'foundry'

@description('Storage account name - Storage Account naming rules - Lowercase letters and numbers')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'foundry${uniqueString(resourceGroup().id)}st'

@description('Key Vault naming rules - Alphanumerics and hyphens. Start with a letter. End with letter or number. Cant contain consecutive hyphens')
@minLength(3)
@maxLength(24)
param keyVaultName string = 'foundry${uniqueString(resourceGroup().id)}kv'

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

// Safely inherit RG tags if they exist; otherwise use {}
var rgTags = resourceGroup().?tags ?? {}

var tags = union(
  rgTags,
  {
    CreatedBy: 'Bicep Template'
    CreatedOn: deploymentTimestamp
  }
)

// Resources

// Storage Accounts

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  kind: storageKind
  location: location
  name: storageAccountName
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
  name: keyVaultName
  tags: tags
  properties: {
    accessPolicies: [
      {
        objectId: keyVaultAccessObjectId
        tenantId: keyVaultAccessTenantId
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
      }      
    ]
      sku: {
      family: 'A'
      name: 'standard'
  }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    softDeleteRetentionInDays: 7
    tenantId: keyVaultAccessTenantId
  }
}

// Key Vault Secret for Storage Account Key

resource storageAccountKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'StorageAccountKey'
  properties: {
    value: storageAccount.listKeys().keys[0].value
    contentType: 'Storage Account Key'
  }
}

// Admin Public Key for Key Vault   
resource adminPublicSSHKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AdminPublicSSHKey'
  properties: {
    value: adminPublicKey // Use the adminPublicKey parameter value
  }
}

// Network Security Groups

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${PrefixName}-nsg'
  location: location
  properties: {
    securityRules: [

//inbound rules

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
        name: 'Allow-Foundry-Inbound'
        properties: {
          description: 'Ports needed to access Foundry'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443', '30000']
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 170
          direction: 'Inbound'
        }
      }
      {  
        name: 'Allow-Livekit-Inbound'
        properties: {
          description: 'Ports needed to access LiveKit'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: ['50000-60000', '443', '80', '7881', '3478']
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 180
          direction: 'Inbound'
        }
      }
        {  
        name: 'Allow-Intra-Subnet-Inbound'
        properties: {
          description: 'Allow traffic between VMs within the same subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: subnetAddressPrefix
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
        {  
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Supercede default deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }               
//outbound rules            
      {
        name: 'Allow-Web-Browsing-Outbound'
        properties: {
          description: 'Allow outbound web access to the Internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: subnetAddressPrefix
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Deny-All-Internet-Outbound'
        properties: {
          description: 'Supercede default deny outbound to the Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: subnetAddressPrefix
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 4096
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

resource publicIPAddressdev 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-dev-vm-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddresstst 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-tst-vm-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddressprd 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-prd-vm-pip'
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
resource networkInterfacedev 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-dev-vm-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-dev-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddressdev.id
          }
        }
      }
    ]
  }
}

resource networkInterfacetst 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-tst-vm-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-tst-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddresstst.id
          }
        }
      }
    ]
  }
}

resource networkInterfaceprd 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-prd-vm-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-prd-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddressprd.id
          }
        }
      }
    ]
  }
}

// Virtual Machines
// development VM
resource virtualMachinedev 'Microsoft.Compute/virtualMachines@2024-07-01' = {
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
            id: networkInterfacedev.id
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
 
// test VM

resource virtualMachinetst 'Microsoft.Compute/virtualMachines@2024-07-01' = {
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
            id: networkInterfacetst.id
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

// production VM

resource virtualMachineprd 'Microsoft.Compute/virtualMachines@2024-07-01' = {
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
            id: networkInterfaceprd.id
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
