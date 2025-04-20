@description('The Azure region to deploy into')
param location string = resourceGroup().location

param vnet1Name string = 'vnet-student-1'
param vnet1AddressPrefix string = '10.0.0.0/16'
param vnet1InfraPrefix string = '10.0.1.0/24'
param vnet1StoragePrefix string = '10.0.2.0/24'

param vnet2Name string = 'vnet-student-2'
param vnet2AddressPrefix string = '10.1.0.0/16'
param vnet2InfraPrefix string = '10.1.1.0/24'
param vnet2StoragePrefix string = '10.1.2.0/24'

param vm1Name string
param vm2Name string
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

param storage1Name string
param storage2Name string

module vnet1Module 'modules/vnet.bicep' = {
  name: 'deployVnet1'
  params: {
    vnetName: vnet1Name
    location: location
    addressPrefix: vnet1AddressPrefix
    infraSubnetPrefix: vnet1InfraPrefix
    storageSubnetPrefix: vnet1StoragePrefix
  }
}

module vnet2Module 'modules/vnet.bicep' = {
  name: 'deployVnet2'
  params: {
    vnetName: vnet2Name
    location: location
    addressPrefix: vnet2AddressPrefix
    infraSubnetPrefix: vnet2InfraPrefix
    storageSubnetPrefix: vnet2StoragePrefix
  }
}

module peerModule 'modules/peerVnets.bicep' = {
  name: 'peerVnets'
  dependsOn: [vnet1Module, vnet2Module]
  params: {
    vnet1Name: vnet1Name
    vnet2Name: vnet2Name
  }
}

module vm1Module 'modules/vm.bicep' = {
  name: 'deployVm1'
  params: {
    vmName: vm1Name
    location: location
    subnetId: vnet1Module.outputs.infraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module vm2Module 'modules/vm.bicep' = {
  name: 'deployVm2'
  params: {
    vmName: vm2Name
    location: location
    subnetId: vnet2Module.outputs.infraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module storage1Module 'modules/storage.bicep' = {
  name: 'deployStorage1'
  params: {
    storageAccountName: storage1Name
    location: location
    storageSubnetId: vnet1Module.outputs.storageSubnetId
  }
}

module storage2Module 'modules/storage.bicep' = {
  name: 'deployStorage2'
  params: {
    storageAccountName: storage2Name
    location: location
    storageSubnetId: vnet2Module.outputs.storageSubnetId
  }
}

module laModule 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'deployLogAnalytics'
  params: {
    name: 'la-student-workspace'
    location: location
  }
}

resource vnet1Res 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet1Name
}

resource vnet2Res 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet2Name
}

resource vm1Res 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: vm1Name
}

resource vm2Res 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: vm2Name
}

resource storage1Res 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storage1Name
}

resource storage2Res 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storage2Name
}

resource diagVnet1 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(vnet1Name)}'
  scope: vnet1Res
  properties: {
    workspaceId: laModule.outputs.workspaceId
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

resource diagVnet2 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(vnet2Name)}'
  scope: vnet2Res
  properties: {
    workspaceId: laModule.outputs.workspaceId
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

resource diagVm1 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(vm1Name)}'
  scope: vm1Res
  properties: {
    workspaceId: laModule.outputs.workspaceId
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

resource diagVm2 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(vm2Name)}'
  scope: vm2Res
  properties: {
    workspaceId: laModule.outputs.workspaceId
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

resource diagStorage1 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(storage1Name)}'
  scope: storage1Res
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

resource diagStorage2 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${uniqueString(storage2Name)}'
  scope: storage2Res
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
