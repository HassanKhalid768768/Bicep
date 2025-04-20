@description('The location into which all resources should be deployed.')
param location string = resourceGroup().location

@description('Name of the first virtual network.')
param vnet1Name string = 'vnet-student-1'

@description('Name of the second virtual network.')
param vnet2Name string = 'vnet-student-2'

@description('Name of the subnet in each VNET.')
param subnetName string = 'default'

@description('Name of the first VM.')
param vm1Name string = 'vm-student-1'

@description('Name of the second VM.')
param vm2Name string = 'vm-student-2'

@description('Admin username for the VMs.')
param adminUsername string

@secure()
@description('Admin password for the VMs.')
param adminPassword string

@description('Name of the first storage account.')
param storage1Name string = 'mystorageacct0126'

@description('Name of the second storage account.')
param storage2Name string = 'mystorageacct0226'

/* Deploy VNETs */
module vnetModule './modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    vnet1Name: vnet1Name
    vnet2Name: vnet2Name
    subnetName: subnetName
  }
}

/* Deploy Log Analytics */
module laModule './modules/logAnalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    location: location
  }
}

/* Deploy VMs */
module vm1Module './modules/vm.bicep' = {
  name: 'vm1Deployment'
  params: {
    location: location
    vmName: vm1Name
    subnetId: vnetModule.outputs.subnet1Id
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module vm2Module './modules/vm.bicep' = {
  name: 'vm2Deployment'
  params: {
    location: location
    vmName: vm2Name
    subnetId: vnetModule.outputs.subnet2Id
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

/* Deploy Storage Accounts */
module storage1Module './modules/storage.bicep' = {
  name: 'storage1Deployment'
  params: {
    location: location
    storageAccountName: storage1Name
    storageSubnetId: vnetModule.outputs.subnet1Id
  }
}

module storage2Module './modules/storage.bicep' = {
  name: 'storage2Deployment'
  params: {
    location: location
    storageAccountName: storage2Name
    storageSubnetId: vnetModule.outputs.subnet2Id
  }
}

/* Diagnostic Setting for VM1 */
resource diagVm1 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(vm1Name)}'
  scope: vm1Module.outputs.vmId
  properties: {
    workspaceId: laModule.outputs.workspaceId
    metrics: [
      {
        category: 'PerformanceCounters'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    logs: [
      {
        category: 'Administrative'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

/* Diagnostic Setting for VM2 */
resource diagVm2 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(vm2Name)}'
  scope: vm2Module.outputs.vmId
  properties: {
    workspaceId: laModule.outputs.workspaceId
    metrics: [
      {
        category: 'PerformanceCounters'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    logs: [
      {
        category: 'Administrative'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

/* Diagnostic Setting for Storage1 */
resource diagStorage1 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(storage1Name)}'
  scope: resource(storage1Module.outputs.storageAccountId, '2021-08-01')
  properties: {
    workspaceId: laModule.outputs.workspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

/* Diagnostic Setting for Storage2 */
resource diagStorage2 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(storage2Name)}'
  scope: resource(storage2Module.outputs.storageAccountId, '2021-08-01')
  properties: {
    workspaceId: laModule.outputs.workspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
