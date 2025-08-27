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
param vmSize string
param dataDiskSizeGB int
param adminUsername string
param adminPublicKey string

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
    vmSize: vmSize
    dataDiskSizeGB: dataDiskSizeGB
    adminUsername: adminUsername
    adminPublicKey: adminPublicKey
  }
}

