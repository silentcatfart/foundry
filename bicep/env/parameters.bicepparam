// reference to main Bicep file
// This file is used to define parameters for the Bicep deployment  
using '../main.bicep'

// Parameters for the resource group
param rgName = 'foundry-test'
param rgLocation = 'eastus2'

// Base tags (inherited)
param tags = {
  Env: 'dev'
  Owner: 'Asa Engleman'
}

// Optional, overrides keys in `tags`
param additionalTags = {
  Project: 'Foundry-VTT'
}
