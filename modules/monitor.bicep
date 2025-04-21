param resourceId string
param logAnalyticsWorkspaceId string
param diagnosticName string = 'diag-${uniqueString(resourceId)}'

var logCategories = [
  'AuditLogs'
  'Requests'
  'NetworkSecurityGroupEvent'
  'NetworkSecurityGroupRuleCounter'
]

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticName
  scope: resourceId
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      for category in logCategories: {
        category: category
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
