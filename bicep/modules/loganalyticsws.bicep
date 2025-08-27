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

// Get the list of tables in the workspace
resource logAnalyticsTables 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' existing = [for table in logAnalyticsWorkspace.listTables(): {
  name: table.name
}]

// Update the retention for each table
resource updatedLogAnalyticsTables 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = [for table in logAnalyticsTables: {
  name: table.name
  properties: {
    retentionInDays: 30
  }
}]

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
