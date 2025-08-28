param PrefixName string = 'fndry'
param location string
param tagValues object
param logAnalSku string = 'PerGB2018'

@description('Action Group resource ID to notify.')
param actionGroupResourceId string

var ruleName = 'vm-running-over-4h'

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

// Scheduled query alert: “VM has been running > 4 hours” - It looks at the last power event per VM in AzureActivity and alerts when the last change was a Start more than 4 hours ago.

resource rule 'Microsoft.Insights/scheduledQueryRules@2025-01-01-preview' = {
  name: ruleName
  location: location
  tags: tagValues
  kind: 'LogAlert'
  properties: {
    displayName: 'VM running > 4h since last start'
    description: 'Alerts when a VM started > 4h ago and is still running.'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT30M' // check every 30 minutes
    windowSize: 'PT4H'           // 4-hour lookback
    scopes: [
      logAnalyticsWorkspace.id
    ]
    targetResourceTypes: [
      'Microsoft.Compute/virtualMachines'
    ]
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          query: '''
let cutoff = 4h;
let horizon = 7d;
let powerEvents = AzureActivity
| where TimeGenerated > ago(horizon)
| where ResourceProviderValue == "Microsoft.Compute"
| where OperationNameValue in ("Microsoft.Compute/virtualMachines/start/action",
                               "Microsoft.Compute/virtualMachines/deallocate/action",
                               "Microsoft.Compute/virtualMachines/powerOff/action")
| project TimeGenerated, ResourceId, OperationNameValue;
let lastChange = powerEvents
| summarize LastChange = arg_max(TimeGenerated, OperationNameValue) by ResourceId;
lastChange
| where OperationNameValue == "Microsoft.Compute/virtualMachines/start/action"
| extend RunningFor = now() - LastChange
| where RunningFor > cutoff
| project ResourceId
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          resourceIdColumn: 'ResourceId'
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: empty(actionGroupResourceId) ? [] : [ actionGroupResourceId ]
    }
  }
}
