@description('The full ARM ID of the resource to attach diagnostics to')
param resourceId string

@description('The ARM ID of the Log Analytics workspace')
param logAnalyticsWorkspaceId string

@description('Name for the diagnostic setting')
param diagnosticName string = 'diag-${uniqueString(resourceId)}'

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticName
  scope: resource(resourceId)
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
