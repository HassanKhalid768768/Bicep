param name string
param location string = resourceGroup().location

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: name
  location: location
  properties: { sku: { name: 'PerGB2018' } }
}

output workspaceId string = workspace.id
