// One Foundry environment: public IP, NIC and VM with a data disk.
// Deployed once per entry in the `environments` param of foundry.bicep.

@description('Prefix for all resource names.')
param PrefixName string

@description('Environment short name, e.g. dev, tst, prd. Used in resource names.')
param envName string

param location string
param tagValues object

param vmSize string

@description('Availability zone for the VM.')
param zone string

param subnetId string
param dataDiskSizeGB int
param adminUsername string
param adminPublicKey string

@description('Managed disk SKU for the OS and data disks. Changing it requires the VM to be deallocated.')
param diskSku string

@description('Daily auto-shutdown time (HHmm) in shutdownTimeZone.')
param shutdownTime string
param shutdownTimeZone string

@description('Email for the 30-minute auto-shutdown warning. Empty disables the notification.')
param shutdownNotificationEmail string

var baseName = '${PrefixName}-${envName}-vm'

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${baseName}-pip'
  location: location
  tags: tagValues
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${baseName}-nic'
  location: location
  tags: tagValues
  properties: {
    ipConfigurations: [
      {
        name: '${PrefixName}-${envName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: baseName
  location: location
  tags: tagValues
  identity: {
    type: 'SystemAssigned' // used by rclone to reach blob storage without a key
  }
  zones: [
    zone
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
        name: '${baseName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: diskSku
        }
      }
      dataDisks: [
        {
          name: '${baseName}-datadisk'
          lun: 0
          diskSizeGB: dataDiskSizeGB
          createOption: 'Empty'
          caching: 'None' // matches the deployed disks
          deleteOption: 'Detach' // keep the data disk if the VM is ever deleted
          managedDisk: {
            storageAccountType: diskSku
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: baseName
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

// Name and settings match the schedules originally created in the portal
resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vm.name}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: shutdownTime
    }
    timeZoneId: shutdownTimeZone
    targetResourceId: vm.id
    notificationSettings: {
      status: empty(shutdownNotificationEmail) ? 'Disabled' : 'Enabled'
      emailRecipient: shutdownNotificationEmail
      notificationLocale: 'en'
      timeInMinutes: 30
    }
  }
}

output vmId string = vm.id
output principalId string = vm.identity.principalId
output publicIPAddress string = publicIP.properties.ipAddress
