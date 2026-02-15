targetScope='subscription'

param resourceGroupName string
param tagValues object
param PrefixName string
param virtualNetworkLocation string
param myPublicIPv4 string
param virtualNetworkName string
param virtualNetworkAddressPrefix string
param subnetName string
param subnetAddressPrefix string
param publicIPLocation string
param vmSizeDev string 
param vmSizeTst string 
param vmSizePrd string
param dataDiskSizeGB int
param adminUsername string
param adminPublicKey string
param logAnalyticsWorkspaceLocation string
param logAnalSku string
param actionGroupResourceId string

resource newRG 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: resourceGroupName
}

module virtualNetworkModule '../modules/vnet.bicep' = {
  name: 'virtualNetworkModule'
  scope: newRG
  params: {
    PrefixName: PrefixName
    virtualNetworkName: virtualNetworkName
    virtualNetworkLocation: virtualNetworkLocation
    myPublicIPv4: myPublicIPv4
    tagValues: tagValues
    virtualNetworkAddressPrefix : virtualNetworkAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
  }
}

module publicIPModule '../modules/publicip.bicep' = {
  name: 'publicIPModule'
  scope: newRG
  params: {
    publicIPLocation: publicIPLocation
    PrefixName : PrefixName 
    tagValues: tagValues
  }
}

module linuxVmModule '../modules/linuxvm.bicep' = {
  name: 'linuxVmModule'
  scope: newRG
  params: {
    location: publicIPLocation
    pipModuleDevId: publicIPModule.outputs.publicIPAddressdevId
    pipModuleTstId: publicIPModule.outputs.publicIPAddresststId
    pipModulePrdId: publicIPModule.outputs.publicIPAddressprdId
    vnetModuleSubId: virtualNetworkModule.outputs.subnetId
    PrefixName : PrefixName
    tagValues: tagValues
    vmSizeDev: vmSizeDev
    vmSizeTst: vmSizeTst
    vmSizePrd: vmSizePrd
    dataDiskSizeGB: dataDiskSizeGB
    adminUsername: adminUsername
    adminPublicKey: adminPublicKey
  }
}

module logAnalyticsWorkspaceModule '../modules/loganalyticsws.bicep' = {
  name: 'logAnalyticsWorkspaceModule'
  scope: newRG
  params: {
    location: logAnalyticsWorkspaceLocation
    PrefixName : PrefixName 
    tagValues: tagValues
    logAnalSku: logAnalSku
    actionGroupResourceId: actionGroupResourceId
  }
}

// Send the subscription Activity Log to a Log Analytics workspace (required for the KQL alert)

var logAnalyticsWorkspaceId = logAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceId

resource exportActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'export-activity-logs-to-law'
  scope: subscription()
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    // Common Activity Log categories
    logs: [
      { category: 'Administrative',  enabled: true }
      { category: 'Security',        enabled: true }
      { category: 'ServiceHealth',   enabled: true }
      { category: 'Alert',           enabled: true }
      { category: 'Recommendation',  enabled: true }
      { category: 'Policy',          enabled: true }
      { category: 'Autoscale',       enabled: true }
      { category: 'ResourceHealth',  enabled: true }
    ]
  }
}

