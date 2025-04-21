param location string = resourceGroup().location

// --- VNET 1 parameters ---
// Defines name and subnet address ranges for the first virtual network
param vnet1Name string = 'vnet-student-1'
param vnet1AddressPrefix string = '10.0.0.0/16'
param vnet1InfraPrefix string = '10.0.1.0/24'
param vnet1StoragePrefix string = '10.0.2.0/24'

// --- VNET 2 parameters ---
// Defines name and subnet address ranges for the second virtual network
param vnet2Name string = 'vnet-student-2'
param vnet2AddressPrefix string = '10.1.0.0/16'
param vnet2InfraPrefix string = '10.1.1.0/24'
param vnet2StoragePrefix string = '10.1.2.0/24'

// --- VM parameters ---
// Defines the virtual machine names and admin credentials
param vm1Name string = 'vm-student-1'
param vm2Name string = 'vm-student-2'
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

// --- Storage Account parameters ---
// Names of the two storage accounts to be deployed in each VNet
param storage1Name string = 'storastudent1hassan786'
param storage2Name string = 'storastudent2hassan786'

// --- Deploy VNET 1 ---
// Deploys the first virtual network with infra and storage subnets
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

// --- Deploy VNET 2 ---
// Deploys the second virtual network with infra and storage subnets
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

// --- Peer the VNETs ---
// Establishes bidirectional peering between the two VNets
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

// --- Deploy Virtual Machines ---
// Deploys a VM in the infra subnet of VNET 1
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

// Deploys a VM in the infra subnet of VNET 2
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

// --- Deploy Storage Accounts ---
// Deploys a storage account in the storage subnet of VNET 1
module storage1Module 'modules/storage.bicep' = {
  name: 'storage1Deploy'
  params: {
    storageAccountName: storage1Name
    location: location
    storageAccountSku: 'Standard_ZRS'
    storageSubnetId: vnet1Module.outputs.storageSubnetId
  }
}

// Deploys a storage account in the storage subnet of VNET 2
module storage2Module 'modules/storage.bicep' = {
  name: 'storage2Deploy'
  params: {
    storageAccountName: storage2Name
    location: location
    storageAccountSku: 'Standard_ZRS'
    storageSubnetId: vnet2Module.outputs.storageSubnetId
  }
}

// (Optionally) Deploy a Log Analytics Workspace and attach diagnostic settings to resources
