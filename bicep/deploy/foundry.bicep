targetScope = 'subscription'

@export()
type environment = {
  @description('Short name used in resource names and the Environment tag (dev, tst, prd).')
  name: string
  vmSize: string
  @description('Availability zone for the VM.')
  zone: '1' | '2' | '3'
  @description('Blob containers this VM\'s managed identity may use (only applied when assignStorageRoles = true).')
  storageGrants: { container: string, access: 'read' | 'write' }[]
}

param resourceGroupName string
param location string
param tagValues object
param PrefixName string
param myPublicIPv4 array
param virtualNetworkName string
param virtualNetworkAddressPrefix string
param subnetName string
param subnetAddressPrefix string
param environments environment[]
param dataDiskSizeGB int
param adminUsername string
param adminPublicKey string
param diskSku string
param shutdownTime string
param shutdownTimeZone string
param shutdownNotificationEmail string

@description('Storage account (fndryst) used by rclone.')
param storageAccountName string

@description('Create the container role assignments for the VM identities. Needs RBAC-admin rights the pipeline service principal does not have by default.')
param assignStorageRoles bool = false

param logAnalSku string
param actionGroupResourceId string

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: resourceGroupName
}

module virtualNetworkModule '../modules/vnet.bicep' = {
  name: 'virtualNetworkModule'
  scope: rg
  params: {
    PrefixName: PrefixName
    location: location
    tagValues: tagValues
    myPublicIPv4: myPublicIPv4
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
  }
}

module linuxVmModule '../modules/linuxvm.bicep' = [
  for env in environments: {
    name: 'linuxVm-${env.name}'
    scope: rg
    params: {
      PrefixName: PrefixName
      envName: env.name
      location: location
      tagValues: union(tagValues, { Environment: env.name })
      vmSize: env.vmSize
      zone: env.zone
      subnetId: virtualNetworkModule.outputs.subnetId
      dataDiskSizeGB: dataDiskSizeGB
      adminUsername: adminUsername
      adminPublicKey: adminPublicKey
      diskSku: diskSku
      shutdownTime: shutdownTime
      shutdownTimeZone: shutdownTimeZone
      shutdownNotificationEmail: shutdownNotificationEmail
    }
  }
]

module storageModule '../modules/storage.bicep' = {
  name: 'storageModule'
  scope: rg
  params: {
    storageAccountName: storageAccountName
    location: location
    tagValues: tagValues
  }
}

module storageAccessModule '../modules/storage-access.bicep' = [
  for (env, i) in environments: if (assignStorageRoles) {
    name: 'storageAccess-${env.name}'
    scope: rg
    params: {
      storageAccountName: storageModule.outputs.name
      principalId: linuxVmModule[i].outputs.principalId
      grants: env.storageGrants
    }
  }
]

module logAnalyticsWorkspaceModule '../modules/loganalyticsws.bicep' = {
  name: 'logAnalyticsWorkspaceModule'
  scope: rg
  params: {
    location: location
    PrefixName: PrefixName
    tagValues: tagValues
    logAnalSku: logAnalSku
    actionGroupResourceId: actionGroupResourceId
  }
}

// Send the subscription Activity Log to the Log Analytics workspace (required for the KQL alert)
resource exportActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'export-activity-logs-to-law'
  scope: subscription()
  properties: {
    workspaceId: logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId
    logs: [
      { category: 'Administrative', enabled: true }
      { category: 'Security', enabled: true }
      { category: 'ServiceHealth', enabled: true }
      { category: 'Alert', enabled: true }
      { category: 'Recommendation', enabled: true }
      { category: 'Policy', enabled: true }
      { category: 'Autoscale', enabled: true }
      { category: 'ResourceHealth', enabled: true }
    ]
  }
}

output vmPublicIPs array = [
  for (env, i) in environments: {
    name: env.name
    ip: linuxVmModule[i].outputs.publicIPAddress
  }
]
