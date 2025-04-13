param location string = resourceGroup().location

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
param storage1Name string = 'storastudent1'
param storage2Name string = 'storastudent2'

// Deploy VNET 1
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

// Deploy VNET 2
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

// Peer the VNETs (uses existing VNets in the module, so we only pass names)
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

// Deploy VM in each VNET
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

// Deploy Storage Accounts in each VNET
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

// (Optionally) Deploy a Log Analytics Workspace then attach diagnostic settings
// Call the monitor module for each resource as shown in the earlier examples.
