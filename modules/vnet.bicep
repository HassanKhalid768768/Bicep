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

output vnetId string = vnet.id
output infraSubnetId string = vnet.properties.subnets[0].id
output storageSubnetId string = vnet.properties.subnets[1].id
