param keyVaultLocation string
param tagValues object 
param keyVaultAccessObjectId string
param keyVaultAccessTenantId string 

@description('Key Vault naming rules - Alphanumerics and hyphens. Start with a letter. End with letter or number. Cant contain consecutive hyphens')
@minLength(3)
@maxLength(24)
param keyVaultName string = 'fndry${uniqueString(resourceGroup().id)}kv'


resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  location: keyVaultLocation
  name: keyVaultName
  tags: tagValues
  properties: {
    accessPolicies: [
      {
        objectId: keyVaultAccessObjectId
        tenantId: keyVaultAccessTenantId
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }        
      }      
    ]
      sku: {
      family: 'A'
      name: 'standard'
  }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    softDeleteRetentionInDays: 7
    tenantId: keyVaultAccessTenantId
  }
}
