targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string
param storageLocation string
param storageName string
param storageKind string
param storageSku string
param tagValues object
param keyVaultLocation string
param keyVaultName string
param keyVaultAccessObjectId string
param keyVaultAccessTenantId string
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

resource newRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: tagValues
}

module storageModule '../modules/storage.bicep' = {
  name: 'storageModule'
  scope: newRG
  params: {
    storageLocation: storageLocation
    storageName: storageName
    storageKind: storageKind
    storageSku: storageSku
    tagValues: tagValues
  }
}

module keyVaultModule '../modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  scope: newRG
  params: {
    keyVaultLocation: keyVaultLocation
    keyVaultName: keyVaultName
    keyVaultAccessObjectId: keyVaultAccessObjectId
    keyVaultAccessTenantId: keyVaultAccessTenantId
    tagValues: tagValues
  }
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

