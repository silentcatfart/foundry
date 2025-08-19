param storageLocation string
param storageName string
param tagValues object 
param storageKind string = 'Storage'
param storageSku string = 'Standard_LRS'

resource storageAcct 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageName
  location: storageLocation 
  tags: tagValues
  kind: storageKind
  sku: {
    name: storageSku
  }
  properties: {}
}

  // Outputs
  output storageAcctId string = storageAcct.id
  output storageAcctName string = storageAcct.name
  output storageAcctPrimaryLocation string = storageAcct.location
