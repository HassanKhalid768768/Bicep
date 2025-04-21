// main.bicep

@description('Location for all resources')
param location           string = resourceGroup().location

// --- VNET 1 parameters ---
param vnet1Name          string = 'vnet-student-1'
param vnet1AddressPrefix string = '10.0.0.0/16'
param vnet1InfraPrefix   string = '10.0.1.0/24'
param vnet1StoragePrefix string = '10.0.2.0/24'

// --- VNET 2 parameters ---
param vnet2Name          string = 'vnet-student-2'
param vnet2AddressPrefix string = '10.1.0.0/16'
param vnet2InfraPrefix   string = '10.1.1.0/24'
param vnet2StoragePrefix string = '10.1.2.0/24'

// --- VM parameters ---
param vm1Name            string = 'vm-student-1'
param vm2Name            string = 'vm-student-2'
param adminUsername      string = 'azureuser'
@secure()
param adminPassword      string

// --- Storage Account parameters ---
param storage1Name       string = 'storastudent1hassan786'
param storage2Name       string = 'storastudent2hassan786'

// --- Log Analytics Workspace ---
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'deployLaw'
  params: {
    workspaceName: 'law-student-workspace'
    location:      location
  }
}

// --- Deploy VNET 1 ---
module vnet1Module 'modules/vnet.bicep' = {
  name: 'vnet1Deploy'
  params: {
    vnetName             : vnet1Name
    location             : location
    addressPrefix        : vnet1AddressPrefix
    infraSubnetPrefix    : vnet1InfraPrefix
    storageSubnetPrefix  : vnet1StoragePrefix
  }
}

// Attach diagnostics to VNET 1
module monitorVnet1 'modules/monitor.bicep' = {
  name: 'monitorVnet1'
  params: {
    resourceId              : vnet1Module.outputs.vnetId
    logAnalyticsWorkspaceId : logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    vnet1Module
    logAnalytics
  ]
}

// --- Deploy VNET 2 ---
module vnet2Module 'modules/vnet.bicep' = {
  name: 'vnet2Deploy'
  params: {
    vnetName             : vnet2Name
    location             : location
    addressPrefix        : vnet2AddressPrefix
    infraSubnetPrefix    : vnet2InfraPrefix
    storageSubnetPrefix  : vnet2StoragePrefix
  }
}

// Attach diagnostics to VNET 2
module monitorVnet2 'modules/monitor.bicep' = {
  name: 'monitorVnet2'
  params: {
    resourceId              : vnet2Module.outputs.vnetId
    logAnalyticsWorkspaceId : logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    vnet2Module
    logAnalytics
  ]
}

// --- Peer the VNETs ---
module peerModule 'modules/peerVnets.bicep' = {
  name: 'peerVnets'
  dependsOn: [
    vnet1Module
    vnet2Module
  ]
  params: {
    vnet1Name : vnet1Name
    vnet2Name : vnet2Name
  }
}

// --- Deploy VM in VNET 1 infra subnet ---
module vm1Module 'modules/vm.bicep' = {
  name: 'vm1Deploy'
  params: {
    vmName        : vm1Name
    location      : location
    subnetId      : vnet1Module.outputs.infraSubnetId
    adminUsername : adminUsername
    adminPassword : adminPassword
  }
}

// Attach diagnostics to VM1
module monitorVm1 'modules/monitor.bicep' = {
  name: 'monitorVm1'
  params: {
    resourceId              : vm1Module.outputs.vmId
    logAnalyticsWorkspaceId : logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    vm1Module
    logAnalytics
  ]
}

// --- Deploy VM in VNET 2 infra subnet ---
module vm2Module 'modules/vm.bicep' = {
  name: 'vm2Deploy'
  params: {
    vmName        : vm2Name
    location      : location
    subnetId      : vnet2Module.outputs.infraSubnetId
    adminUsername : adminUsername
    adminPassword : adminPassword
  }
}

// Attach diagnostics to VM2
module monitorVm2 'modules/monitor.bicep' = {
  name: 'monitorVm2'
  params: {
    resourceId              : vm2Module.outputs.vmId
    logAnalyticsWorkspaceId : logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    vm2Module
    logAnalytics
  ]
}

// --- Deploy Storage Account in VNET 1 storage subnet ---
module storage1Module 'modules/storage.bicep' = {
  name: 'storage1Deploy'
  params: {
    storageAccountName : storage1Name
    location           : location
    storageSubnetId    : vnet1Module.outputs.storageSubnetId
  }
}

// Attach diagnostics to Storage1
module monitorStorage1 'modules/monitor.bicep' = {
  name: 'monitorStorage1'
  params: {
    resourceId              : storage1Module.outputs.storageAccountId
    logAnalyticsWorkspaceId : logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    storage1Module
    logAnalytics
  ]
}

// --- Deploy Storage Account in VNET 2 storage subnet ---
module storage2Module 'modules/storage.bicep' = {
  name: 'storage2Deploy'
  params: {
    storageAccountName : storage2Name
    location           : location
    storageSubnetId    : vnet2Module.outputs.storageSubnetId
  }
}

// Attach diagnostics to Storage2
module monitorStorage2 'modules/monitor.bicep' = {
  name: 'monitorStorage2'
  params: {
    resourceId              : storage2Module.outputs.storageAccountId
    logAnalyticsWorkspaceId : logAnalytics.outputs.workspaceId
  }
  dependsOn: [
    storage2Module
    logAnalytics
  ]
}
