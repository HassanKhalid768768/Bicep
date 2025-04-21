// modules/monitor.bicep
@description('The full provider/type of the resource you want to monitor, e.g. Microsoft.Network/virtualNetworks')
param resourceType       string
@description('The API version of that resource, e.g. 2021-02-01')
param resourceApiVersion string
@description('The name of the existing resource to attach diagnostic settings to')
param resourceName       string
@description('The Resource ID of the Log Analytics workspace where logs/metrics will flow')
param logAnalyticsWorkspaceId string

// unique name for this diagnosticSettings instance
var diagName = 'diag-${uniqueString(resourceName)}'

// declare the target as an existing resource of the correct type
resource target '${resourceType}@${resourceApiVersion}' existing = {
  name: resourceName
}

// attach diagnostic settings to that resource
resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: scope: target   // ← now correctly points at the resource symbol, not a string
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditLogs'
        enabled: true
        retentionPolicy: { enabled: false; days: 0 }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: { enabled: false; days: 0 }
      }
    ]
  }
}
