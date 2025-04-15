// Establishes two-way peering between two existing VNets

param vnet1Name string
param vnet2Name string

resource vnet1 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet1Name
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnet2Name
}

resource vnet1ToVnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${vnet1Name}-to-${vnet2Name}'
  parent: vnet1
  properties: {
    remoteVirtualNetwork: {
      id: vnet2.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource vnet2ToVnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${vnet2Name}-to-${vnet1Name}'
  parent: vnet2
  properties: {
    remoteVirtualNetwork: {
      id: vnet1.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
