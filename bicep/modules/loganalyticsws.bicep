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

// Provide the list of table names as a parameter
param logAnalyticsTableNames array = []

// Update the retention for each table
resource updatedLogAnalyticsTables 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = [for tableName in logAnalyticsTableNames: {
  name: tableName
  properties: {
    retentionInDays: 30
  }
}]

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
