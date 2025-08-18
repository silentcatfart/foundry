// Scope
targetScope = 'subscription'

// Parameters
@description('Name of the resource group')
param rgName string

@description('Azure region for the resource group')
param location string

@description('Tags to apply to the resource group')
param tags object = {}

// Resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${rgName}-rg'
  location: location
  tags: tags
}

// Outputs
output resourceGroupId string = resourceGroup.id
output resourceGroupName string = resourceGroup.name
output resourceGroupLocation string = resourceGroup.location
