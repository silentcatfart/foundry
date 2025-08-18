targetScope = 'resourceGroup'

// Parameters
@description('The location for all resources.')
param location string = resourceGroup().location

// Prefix you control (any case, may include dashes). Keep it short.
param preFixName string = 'foundry'

// Storage account: lowercase letters & numbers only, 3–24 chars, globally unique
@description('Storage account name')
@minLength(3)
@maxLength(24)
param storageAccountName string = substring(
  // build + normalize inline
  '${replace(replace(replace(toLower(preFixName),'-',''), '_',''), ' ','')}${uniqueString(preFixName)}st',
  0,
  // hard-cap to 24
  min(24, length('${replace(replace(replace(toLower(preFixName),'-',''), '_',''), ' ', '')}${uniqueString(preFixName)}st'))
)

@description('Storage kind')
param storageKind string = 'StorageV2'

@description('Storage SKU')
param storageSku string = 'Standard_GRS'

@description('Tags to apply to the resource group')
param tags object = {}


// Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  kind: storageKind
  location: location
  name: storageAccountName
  sku: {
    name: storageSku
  }
  tags: tags
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
      }
    }
  }

  // Outputs
  output storageAccountId string = storageAccount.id
  output storageAccountName string = storageAccount.name
  output storageAccountPrimaryLocation string = storageAccount.location
