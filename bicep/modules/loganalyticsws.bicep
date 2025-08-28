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
    overrideQueryTimeRange: 'P2D'   // <= max allowed
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
AzureActivity
| where TimeGenerated > ago(7d)
| where ActivityStatusValue in ("Success","Succeeded","Accept","Accepted","Start","Started")
| where tolower(OperationNameValue) contains "/virtualmachines/start/"
   or tolower(OperationNameValue) contains "/virtualmachines/restart/"
   or tolower(OperationNameValue) contains "/virtualmachines/deallocate/"
   or tolower(OperationNameValue) contains "/virtualmachines/poweroff/"
   or tolower(OperationNameValue) contains "/virtualmachinescalesets/virtualmachines/start/"
   or tolower(OperationNameValue) contains "/virtualmachinescalesets/virtualmachines/restart/"
   or tolower(OperationNameValue) contains "/virtualmachinescalesets/virtualmachines/deallocate/"
   or tolower(OperationNameValue) contains "/virtualmachinescalesets/virtualmachines/poweroff/"
| extend VmId = coalesce(
    ResourceId,
    tostring(todynamic(Authorization).scope),
    strcat('/subscriptions/', SubscriptionId, '/resourceGroups/', ResourceGroup,
           '/providers/Microsoft.Compute/virtualMachines/', Resource)
  )
| where isnotempty(VmId)
| project TimeGenerated, VmId, OperationNameValue
| summarize LastChange = arg_max(TimeGenerated, OperationNameValue) by VmId
| where tolower(OperationNameValue) contains "/virtualmachines/start/"
   or tolower(OperationNameValue) contains "/virtualmachines/restart/"
| where now() - LastChange > 4h
| project VmId
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          resourceIdColumn: 'VmId'   // one alert per VM
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
