// Creates a virtual network with two subnets: 'infra' and 'storage'
// The 'storage' subnet has a service endpoint for Microsoft.Storage

param vnetName string
param location string = resourceGroup().location
param addressPrefix string
param infraSubnetPrefix string
param storageSubnetPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'infra'
        properties: {
          addressPrefix: infraSubnetPrefix
        }
      }
      {
        name: 'storage'
        properties: {
          addressPrefix: storageSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

// Output subnet IDs for use in downstream modules (VMs, storage)
output vnetId string = vnet.id
output infraSubnetId string = vnet.properties.subnets[0].id
output storageSubnetId string = vnet.properties.subnets[1].id
