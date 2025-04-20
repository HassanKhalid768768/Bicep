@description('Location for all resources')
param location string = resourceGroup().location

@description('Prefix for resource names')
param prefix string = 'student'

var vnet1Name = '${prefix}-vnet1'
var vnet2Name = '${prefix}-vnet2'

// Deploy VNET 1
module vnet1Module 'modules/vnet.bicep' = {
  name: 'vnet1'
  params: {
    namePrefix: vnet1Name
    location: location
  }
}

// Deploy VNET 2
module vnet2Module 'modules/vnet.bicep' = {
  name: 'vnet2'
  params: {
    namePrefix: vnet2Name
    location: location
  }
}

// Peer the VNETs
module peerModule 'modules/peerVnets.bicep' = {
  name: 'peerVnets'
  dependsOn: [
    vnet1Module
    vnet2Module
  ]
  params: {
    vnet1Name: vnet1Module.outputs.vnetName
    vnet1Id: vnet1Module.outputs.vnetId
    vnet2Name: vnet2Module.outputs.vnetName
    vnet2Id: vnet2Module.outputs.vnetId
  }
}

// Deploy VM in VNET 1
module vm1Module 'modules/vm.bicep' = {
  name: 'vm1'
  dependsOn: [vnet1Module]
  params: {
    namePrefix: '${prefix}-vm1'
    location: location
    subnetId: vnet1Module.outputs.infraSubnetId
  }
}

// Deploy VM in VNET 2
module vm2Module 'modules/vm.bicep' = {
  name: 'vm2'
  dependsOn: [vnet2Module]
  params: {
    namePrefix: '${prefix}-vm2'
    location: location
    subnetId: vnet2Module.outputs.infraSubnetId
  }
}

// Deploy ZRS Storage Account in VNET 1
module storage1Module 'modules/storage.bicep' = {
  name: 'storage1'
  dependsOn: [vnet1Module]
  params: {
    namePrefix: '${prefix}stg1'
    location: location
    subnetId: vnet1Module.outputs.storageSubnetId
  }
}

// Deploy ZRS Storage Account in VNET 2
module storage2Module 'modules/storage.bicep' = {
  name: 'storage2'
  dependsOn: [vnet2Module]
  params: {
    namePrefix: '${prefix}stg2'
    location: location
    subnetId: vnet2Module.outputs.storageSubnetId
  }
}

// Deploy Log Analytics Workspace
module laModule 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'logAnalytics'
  params: {
    name: '${prefix}-la'
    location: location
  }
}

// Monitor all resources with diagnostics
module monitorVnet1 'modules/monitor.bicep' = {
  name: 'monitorVnet1'
  dependsOn: [vnet1Module, laModule]
  params: {
    resourceId: vnet1Module.outputs.vnetId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorVnet2 'modules/monitor.bicep' = {
  name: 'monitorVnet2'
  dependsOn: [vnet2Module, laModule]
  params: {
    resourceId: vnet2Module.outputs.vnetId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorVM1 'modules/monitor.bicep' = {
  name: 'monitorVM1'
  dependsOn: [vm1Module, laModule]
  params: {
    resourceId: vm1Module.outputs.vmId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorVM2 'modules/monitor.bicep' = {
  name: 'monitorVM2'
  dependsOn: [vm2Module, laModule]
  params: {
    resourceId: vm2Module.outputs.vmId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorStorage1 'modules/monitor.bicep' = {
  name: 'monitorStorage1'
  dependsOn: [storage1Module, laModule]
  params: {
    resourceId: storage1Module.outputs.storageAccountId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorStorage2 'modules/monitor.bicep' = {
  name: 'monitorStorage2'
  dependsOn: [storage2Module, laModule]
  params: {
    resourceId: storage2Module.outputs.storageAccountId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}
