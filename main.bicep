@description('The Azure region to deploy into')
param location string = resourceGroup().location

//
// VNET #1 parameters
//
param vnet1Name string           = 'vnet-student-1'
param vnet1AddressPrefix string = '10.0.0.0/16'
param vnet1InfraPrefix string   = '10.0.1.0/24'
param vnet1StoragePrefix string = '10.0.2.0/24'

//
// VNET #2 parameters
//
param vnet2Name string           = 'vnet-student-2'
param vnet2AddressPrefix string = '10.1.0.0/16'
param vnet2InfraPrefix string   = '10.1.1.0/24'
param vnet2StoragePrefix string = '10.1.2.0/24'

//
// VM parameters
//
param vm1Name      string
param vm2Name      string
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

//
// Storage Account parameters
//
param storage1Name string
param storage2Name string

// --------------------------------------------------
// 1) Deploy VNET #1
// --------------------------------------------------
module vnet1Module 'modules/vnet.bicep' = {
  name: 'deployVnet1'
  params: {
    vnetName             : vnet1Name
    location             : location
    addressPrefix        : vnet1AddressPrefix
    infraSubnetPrefix    : vnet1InfraPrefix
    storageSubnetPrefix  : vnet1StoragePrefix
  }
}

// --------------------------------------------------
// 2) Deploy VNET #2
// --------------------------------------------------
module vnet2Module 'modules/vnet.bicep' = {
  name: 'deployVnet2'
  params: {
    vnetName             : vnet2Name
    location             : location
    addressPrefix        : vnet2AddressPrefix
    infraSubnetPrefix    : vnet2InfraPrefix
    storageSubnetPrefix  : vnet2StoragePrefix
  }
}

// --------------------------------------------------
// 3) Peer the two VNETs
//    (must wait for both to exist)
// --------------------------------------------------
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

// --------------------------------------------------
// 4) Deploy one VM in each `infra` subnet
// --------------------------------------------------
module vm1Module 'modules/vm.bicep' = {
  name: 'deployVm1'
  params: {
    vmName       : vm1Name
    location     : location
    subnetId     : vnet1Module.outputs.infraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module vm2Module 'modules/vm.bicep' = {
  name: 'deployVm2'
  params: {
    vmName       : vm2Name
    location     : location
    subnetId     : vnet2Module.outputs.infraSubnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

// --------------------------------------------------
// 5) Deploy one ZRS Storage account in each `storage` subnet
// --------------------------------------------------
module storage1Module 'modules/storage.bicep' = {
  name: 'deployStorage1'
  params: {
    storageAccountName: storage1Name
    location          : location
    storageSubnetId   : vnet1Module.outputs.storageSubnetId
  }
}

module storage2Module 'modules/storage.bicep' = {
  name: 'deployStorage2'
  params: {
    storageAccountName: storage2Name
    location          : location
    storageSubnetId   : vnet2Module.outputs.storageSubnetId
  }
}

// --------------------------------------------------
// 6a) Deploy an Azure Monitor Log Analytics Workspace
// --------------------------------------------------
module laModule 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'deployLogAnalytics'
  params: {
    name     : 'la-student-workspace'
    location : location
  }
}

// --------------------------------------------------
// 6b) Attach Diagnostic Settings to *every* resource
//     (no explicit dependsOn needed — references imply ordering)
// --------------------------------------------------
module monitorVnet1 'modules/monitor.bicep' = {
  name: 'diagVnet1'
  params: {
    resourceId             : vnet1Module.outputs.vnetId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorVnet2 'modules/monitor.bicep' = {
  name: 'diagVnet2'
  params: {
    resourceId             : vnet2Module.outputs.vnetId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorVm1 'modules/monitor.bicep' = {
  name: 'diagVm1'
  params: {
    resourceId             : vm1Module.outputs.vmId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorVm2 'modules/monitor.bicep' = {
  name: 'diagVm2'
  params: {
    resourceId             : vm2Module.outputs.vmId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorStorage1 'modules/monitor.bicep' = {
  name: 'diagStorage1'
  params: {
    resourceId             : storage1Module.outputs.storageAccountId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}

module monitorStorage2 'modules/monitor.bicep' = {
  name: 'diagStorage2'
  params: {
    resourceId             : storage2Module.outputs.storageAccountId
    logAnalyticsWorkspaceId: laModule.outputs.workspaceId
  }
}
