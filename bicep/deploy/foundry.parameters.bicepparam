using 'foundry.bicep'

param resourceGroupName = 'foundry-rg'
param location = 'eastus2'

// Environment is added per VM from `environments` below
param tagValues = {
  Project: 'Foundry-VTT'
  CreatedBy: 'Bicep Template'
}

param PrefixName = 'fndry'
param myPublicIPv4 = ['69.249.125.110/32', '8.20.69.6/32']
param virtualNetworkName = '${PrefixName}-vnet'
param virtualNetworkAddressPrefix = '10.250.0.0/24'
param subnetName = '${PrefixName}-subnet'
param subnetAddressPrefix = '10.250.0.0/24'

// storageGrants: dev/prd can only READ artifacts (pull) and write their own backup container.
// Only tst can write artifacts and the shared-assets module (push).
param environments = [
  {
    name: 'dev' // testing new Foundry versions
    vmSize: 'Standard_B1ms'
    zone: '1'
    storageGrants: [
      { container: 'artifacts', access: 'read' }
      { container: 'dev', access: 'write' }
    ]
  }
  {
    name: 'tst' // building compendiums
    vmSize: 'Standard_B1ms'
    zone: '2'
    storageGrants: [
      { container: 'artifacts', access: 'write' }
      { container: 'silentcatfarts-shared-assets', access: 'write' }
      { container: 'tst', access: 'write' }
    ]
  }
  {
    name: 'prd' // running games
    vmSize: 'Standard_B8ms'
    zone: '3'
    storageGrants: [
      { container: 'artifacts', access: 'read' }
      { container: 'prd', access: 'write' }
    ]
  }
]

param dataDiskSizeGB = 64
param diskSku = 'StandardSSD_LRS'

param shutdownTime = '0115'
param shutdownTimeZone = 'Eastern Standard Time'
// Kept out of the repo: set from GitHub secrets in the workflow (export them locally for what-if)
param shutdownNotificationEmail = readEnvironmentVariable('SHUTDOWN_NOTIFICATION_EMAIL')

param storageAccountName = 'fndryst'
param assignStorageRoles = false
param adminUsername = 'foundry'
param adminPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCS5iyFyDcG8hAvYwQjEzijmGeJibEEuZ57WfZ0QzivUScWbF0vYtglpiXv9cxlclDGc6J2ehWdOvsg/beR89iN2dUHxQsoBDhkwBeSeuUa8NQCMsm3BdxqNW+R/PQzahGzcOQ0UNsdlj+U57AFnGStaogErR5o5rjhNEF9j4bpugGHIkMQY7SnEVpAPHypmvAb9WMU4uGnO0LqH5kZy3dA2XLsGCtfhlzst7p0MXNkoZqaWMwoXSVvaJjYFqNzfJW2WVkpbSdpa1mfNI/g0R7PT4Pm59HiF7y5Ex7HWczLkqp54LZwMaWR4Km7Brz0V4hidSBXm+eAPSgx0/CX1BmYfGfJ2yifd2EtdIVORY5btNAdstUtD1B6L0SH80hLuvFr9dYHsWFVLkOaeYypr/k0RWOiSFVip4DrKT2nGew194/jD/YIm/GuN97+qukxF7UVpqlJvfEW1wzTl7WwAceuJ90vi7gSvRRdwaSkVjxDLgGhnqSHcnIguTTcLGyuiNKGyW2nibTnTZqCYThYuOpHJ/3nBpPYuO9rjI8nayz7E7BBl3XxBrjzwiuffcMrY0Hwzatsm4W9ALl6lvRyzFOOW7lvc18UJjQ9c7BI5bCO4CGtFAjs0fejdfR9udDkSn1cbhMBi+8kMnPg4b4RKV6bl6P//MlBUhakIA7yUVaZw== aengleman@ASENj893Q13'

param logAnalSku = 'PerGB2018'
param actionGroupResourceId = readEnvironmentVariable('ACTION_GROUP_RESOURCE_ID')
