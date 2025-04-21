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
    location     : location
  }
}

// --- Deploy VNET 1 ---
module vnet1Module 'modules/vnet.bicep' = {
  name: 'vnet1Deploy'
  params: {
    vnetName            : vnet1Name
    location            : location
    addressPrefix       : vnet1AddressPrefix
    infraSubnetPrefix   : vnet1InfraPrefix
    storageSubnetPrefix : vnet1StoragePrefix
  }
}

// Attach diagnostics to VNET 1
module monitorVnet1 'modules/monitor.bicep' = {
  name: 'monitorVnet1'
  params: {
    resourceType           : 'Microsoft.Network/virtualNetworks'
    resourceApiVersion     : '2021-02-01'
    resourceName           : vnet1Name
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// --- Deploy VNET 2 ---
module vnet2Module 'modules/vnet.bicep' = {
  name: 'vnet2Deploy'
  params: {
    vnetName            : vnet2Name
    location            : location
    addressPrefix       : vnet2AddressPrefix
    infraSubnetPrefix   : vnet2InfraPrefix
    storageSubnetPrefix : vnet2StoragePrefix
  }
}

// Attach diagnostics to VNET 2
module monitorVnet2 'modules/monitor.bicep' = {
  name: 'monitorVnet2'
  params: {
    resourceType           : 'Microsoft.Network/virtualNetworks'
    resourceApiVersion     : '2021-02-01'
    resourceName           : vnet2Name
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// --- Peer the VNETs ---
module peerModule 'modules/peerVnets.bicep' = {
  name: 'peerVnets'
  params: {
    vnet1Name: vnet1Name
    vnet2Name: vnet2Name
  }
  dependsOn: [
    vnet1Module
    vnet2Module
  ]
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

// Attach diagnostics to VM 1
module monitorVm1 'modules/monitor.bicep' = {
  name: 'monitorVm1'
  params: {
    resourceType           : 'Microsoft.Compute/virtualMachines'
    resourceApiVersion     : '2021-07-01'
    resourceName           : vm1Name
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
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

// Attach diagnostics to VM 2
module monitorVm2 'modules/monitor.bicep' = {
  name: 'monitorVm2'
  params: {
    resourceType           : 'Microsoft.Compute/virtualMachines'
    resourceApiVersion     : '2021-07-01'
    resourceName           : vm2Name
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
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

// Attach diagnostics to Storage Account 1
module monitorStorage1 'modules/monitor.bicep' = {
  name: 'monitorStorage1'
  params: {
    resourceType           : 'Microsoft.Storage/storageAccounts'
    resourceApiVersion     : '2021-08-01'
    resourceName           : storage1Name
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
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

// Attach diagnostics to Storage Account 2
module monitorStorage2 'modules/monitor.bicep' = {
  name: 'monitorStorage2'
  params: {
    resourceType           : 'Microsoft.Storage/storageAccounts'
    resourceApiVersion     : '2021-08-01'
    resourceName           : storage2Name
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}
