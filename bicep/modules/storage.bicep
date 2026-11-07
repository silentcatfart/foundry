// Existing storage account used by rclone (backups, artifacts, shared-assets module).
// Settings match what was originally created; only public blob access is turned off.

param storageAccountName string
param location string
param tagValues object

resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: location
  tags: tagValues
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false // all containers are private; nothing is served anonymously
    allowSharedKeyAccess: true // the account key is still used for local rclone pulls
  }
}

// Soft delete: anything an rclone sync deletes or overwrites stays recoverable for 7 days
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
      allowPermanentDelete: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

output name string = storage.name
