// Attaches diagnostic settings to a resource, sending logs and metrics to a Log Analytics workspace

param resourceId string
param logAnalyticsWorkspaceId string
param diagnosticName string = 'diag-${uniqueString(resourceId)}'

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticName
  scope: resourceId
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
