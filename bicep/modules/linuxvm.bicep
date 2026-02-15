param PrefixName string = 'fndry'
param location string
param tagValues object
param vmSizeDev string = 'Standard_B1ms'
param vmSizeTst string = 'Standard_B1ms'
param vmSizePrd string = 'Standard_B1ms'
param dataDiskSizeGB int = 64
param adminUsername string = 'foundry'
param adminPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCS5iyFyDcG8hAvYwQjEzijmGeJibEEuZ57WfZ0QzivUScWbF0vYtglpiXv9cxlclDGc6J2ehWdOvsg/beR89iN2dUHxQsoBDhkwBeSeuUa8NQCMsm3BdxqNW+R/PQzahGzcOQ0UNsdlj+U57AFnGStaogErR5o5rjhNEF9j4bpugGHIkMQY7SnEVpAPHypmvAb9WMU4uGnO0LqH5kZy3dA2XLsGCtfhlzst7p0MXNkoZqaWMwoXSVvaJjYFqNzfJW2WVkpbSdpa1mfNI/g0R7PT4Pm59HiF7y5Ex7HWczLkqp54LZwMaWR4Km7Brz0V4hidSBXm+eAPSgx0/CX1BmYfGfJ2yifd2EtdIVORY5btNAdstUtD1B6L0SH80hLuvFr9dYHsWFVLkOaeYypr/k0RWOiSFVip4DrKT2nGew194/jD/YIm/GuN97+qukxF7UVpqlJvfEW1wzTl7WwAceuJ90vi7gSvRRdwaSkVjxDLgGhnqSHcnIguTTcLGyuiNKGyW2nibTnTZqCYThYuOpHJ/3nBpPYuO9rjI8nayz7E7BBl3XxBrjzwiuffcMrY0Hwzatsm4W9ALl6lvRyzFOOW7lvc18UJjQ9c7BI5bCO4CGtFAjs0fejdfR9udDkSn1cbhMBi+8kMnPg4b4RKV6bl6P//MlBUhakIA7yUVaZw== aengleman@ASENj893Q13'
param pipModuleDevId string
param pipModuleTstId string
param pipModulePrdId string
param vnetModuleSubId string

// Network Interfaces
resource networkInterfacedev 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-dev-vm-nic'
  location: location
  tags: tagValues
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-dev-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetModuleSubId
          }
          publicIPAddress: {
            id: pipModuleDevId
          }
        }
      }
    ]
  }
}

resource networkInterfacetst 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-tst-vm-nic'
  location: location
  tags: tagValues
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-tst-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetModuleSubId
          }
          publicIPAddress: {
            id: pipModuleTstId
          }
        }
      }
    ]
  }
}

resource networkInterfaceprd 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${PrefixName}-prd-vm-nic'
  location: location
  tags: tagValues
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-prd-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetModuleSubId
          }
          publicIPAddress: {
            id: pipModulePrdId
          }
        }
      }
    ]
  }
}

// development VM
resource virtualMachinedev 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: '${PrefixName}-dev-vm'
  location: location
  tags: tagValues
  zones:  [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSizeDev
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
  tags: tagValues
  zones:  [
    '2'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSizeTst
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
  tags: tagValues
  zones:  [
    '3'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSizePrd
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
