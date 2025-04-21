param location string = resourceGroup().location

// --- Log Analytics Workspace ---
param workspaceName string = 'la-${uniqueString(resourceGroup().id)}'

// --- VNET 1 parameters ---
param vnet1Name string = 'vnet-student-1'
param vnet1AddressPrefix string = '10.0.0.0/16'
param vnet1InfraPrefix string = '10.0.1.0/24'
param vnet1StoragePrefix string = '10.0.2.0/24'

// --- VNET 2 parameters ---
param vnet2Name string = 'vnet-student-2'
param vnet2AddressPrefix string = '10.1.0.0/16'
param vnet2InfraPrefix string = '10.1.1.0/24'
param vnet2StoragePrefix string = '10.1.2.0/24'

// --- VM parameters ---
param vm1Name string = 'vm-student-1'
param vm2Name string = 'vm-student-2'
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

// --- Storage Account parameters ---
param storage1Name string = 'storastudent1${uniqueString(resourceGroup().id)}'
param storage2Name string = 'storastudent2${uniqueString(resourceGroup().id)}'

// ========== RESOURCE DEPLOYMENTS ========== //

// Log Analytics Workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: workspaceName
  location: location
  properties: {}
}

// VNETs
module vnet1Module 'modules/vnet.bicep' = {
  name: 'vnet1Deploy'
  params: {
    vnetName: vnet1Name
    location: location
    addressPrefix: vnet1AddressPrefix
    infraSubnetPrefix: vnet1InfraPrefix
    storageSubnetPrefix: vnet1StoragePrefix
  }
}

module vnet2Module 'modules/vnet.bicep' = {
  name: 'vnet2Deploy'
  params: {
    vnetName: vnet2Name
    location: location
    addressPrefix: vnet2AddressPrefix
    infraSubnetPrefix: vnet2InfraPrefix
    storageSubnetPrefix: vnet2StoragePrefix
  }
}

// VNET Peering
module peerModule 'modules/peerVnets.bicep' = {
  name: 'peerVnets'
  dependsOn: [
    vnet1Module
    vnet2Module
  ]
  params: {
    vnet1Name: vnet1Name
    vnet2Name: vnet2Name
  }
}

// Virtual Machines
module vm1Module 'modules/vm.bicep' = {
  name: 'vm1Deploy'
  params: {
    vmName: vm1Name
    location: location
    subnetId: vnet1Module.outputs.infraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module vm2Module 'modules/vm.bicep' = {
  name: 'vm2Deploy'
  params: {
    vmName: vm2Name
    location: location
    subnetId: vnet2Module.outputs.infraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

// Storage Accounts
module storage1Module 'modules/storage.bicep' = {
  name: 'storage1Deploy'
  params: {
    storageAccountName: storage1Name
    location: location
    storageAccountSku: 'Standard_ZRS'
    storageSubnetId: vnet1Module.outputs.storageSubnetId
  }
}

module storage2Module 'modules/storage.bicep' = {
  name: 'storage2Deploy'
  params: {
    storageAccountName: storage2Name
    location: location
    storageAccountSku: 'Standard_ZRS'
    storageSubnetId: vnet2Module.outputs.storageSubnetId
  }
}

// ========== MONITORING CONFIGURATION ========== //
module monitorVnet1 'modules/monitor.bicep' = {
  name: 'monitorVnet1'
  params: {
    resourceId: vnet1Module.outputs.vnetId
    logAnalyticsWorkspaceId: workspace.id
  }
}

module monitorVnet2 'modules/monitor.bicep' = {
  name: 'monitorVnet2'
  params: {
    resourceId: vnet2Module.outputs.vnetId
    logAnalyticsWorkspaceId: workspace.id
  }
}

module monitorVm1 'modules/monitor.bicep' = {
  name: 'monitorVm1'
  params: {
    resourceId: vm1Module.outputs.vmId
    logAnalyticsWorkspaceId: workspace.id
  }
}

module monitorVm2 'modules/monitor.bicep' = {
  name: 'monitorVm2'
  params: {
    resourceId: vm2Module.outputs.vmId
    logAnalyticsWorkspaceId: workspace.id
  }
}

module monitorStorage1 'modules/monitor.bicep' = {
  name: 'monitorStorage1'
  params: {
    resourceId: storage1Module.outputs.storageAccountId
    logAnalyticsWorkspaceId: workspace.id
  }
}

module monitorStorage2 'modules/monitor.bicep' = {
  name: 'monitorStorage2'
  params: {
    resourceId: storage2Module.outputs.storageAccountId
    logAnalyticsWorkspaceId: workspace.id
  }
}
