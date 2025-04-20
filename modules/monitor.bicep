@description('Name of the diagnostic setting (e.g. diag-<hash>)')
param diagnosticName string = 'diag-${uniqueString(deployment().name)}'

@description('ARM ID of the Log Analytics workspace to send diagnostics to')
param logAnalyticsWorkspaceId string

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticName
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
