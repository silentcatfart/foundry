// Grants a VM's managed identity access to specific blob containers in the existing storage account.
// Deploying role assignments needs Owner / User Access Administrator / RBAC Administrator rights.

param storageAccountName string
param principalId string

@description('Containers to grant: read = Storage Blob Data Reader, write = Storage Blob Data Contributor.')
param grants { container: string, access: 'read' | 'write' }[]

var roleIds = {
  read: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader
  write: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
}

resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageAccountName

  resource blob 'blobServices' existing = {
    name: 'default'
  }
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' existing = [
  for g in grants: {
    parent: storage::blob
    name: g.container
  }
]

resource assignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (g, i) in grants: {
    name: guid(containers[i].id, principalId, roleIds[g.access])
    scope: containers[i]
    properties: {
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIds[g.access])
    }
  }
]
