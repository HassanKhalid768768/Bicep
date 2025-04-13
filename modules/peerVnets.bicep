param vnet1Name string
param vnet1Id string
param vnet2Name string
param vnet2Id string

resource vnet1ToVnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${vnet1Name}-to-${vnet2Name}'
  parent: {
    id: vnet1Id
  }
  properties: {
    remoteVirtualNetwork: {
      id: vnet2Id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource vnet2ToVnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${vnet2Name}-to-${vnet1Name}'
  parent: {
    id: vnet2Id
  }
  properties: {
    remoteVirtualNetwork: {
      id: vnet1Id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
