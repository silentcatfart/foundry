targetScope = 'subscription'

@description('Name of the resource group to create')
param rgName string

@description('Azure region for the resource group (e.g., eastus2)')
param rgLocation string

@description('Base tags to apply to the resource group')
param tags object = {}

@description('Optional additional tags; these override duplicate keys in `tags`.')
param additionalTags object = {}

@description('Timestamp for this deployment (auto-filled)')
param deploymentTimestamp string = utcNow()

// Merge precedence (left to right): tags -> additionalTags -> templateTags
var templateTags = {
  CreatedBy: 'Bicep Template'
  UpdatedOn: deploymentTimestamp
}
var merged = union(tags, additionalTags)
var finalTags = union(merged, templateTags)

module resourceGroup './modules/resource-group.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: rgLocation
    tags: finalTags
  }
}

resource rgRef 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: rgName
}

module storageAccount './modules/storage-account.bicep' = {
  name: '${rgName}-storage'
  scope: rgRef
  params: {
    location: rgLocation
    preFixName: 'foundry'
    storageKind: 'StorageV2'
    storageSku: 'Standard_GRS'
    tags: finalTags
  }
}

output resourceGroupId string = resourceGroup.outputs.resourceGroupId
output resourceGroupName string = resourceGroup.outputs.resourceGroupName
output resourceGroupLocation string = resourceGroup.outputs.resourceGroupLocation
