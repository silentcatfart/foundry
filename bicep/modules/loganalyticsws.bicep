param PrefixName string = 'fndry'
param location string
param tagValues object
param logAnalSku string = 'PerGB2018'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: '${PrefixName}-la-ws'
  location: location
  tags: tagValues
  properties: {
    retentionInDays: 30
    sku: {
      name: logAnalSku
    }
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
