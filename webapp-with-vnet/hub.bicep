import { Config } from './types.bicep'

param config Config
param vnetId string

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'hub-vnet'
  location: config.location
  //tags: config.defaultTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    // encryption: {
    //   enabled: true
    //   enforcement: 'DropUnencrypted'
    // }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.1.0.0/24'
          // privateEndpointNetworkPolicies: 'Disabled'
          // privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'hub-to-dev-peering'
        properties: {
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: false
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          peerCompleteVnets: true
          remoteVirtualNetwork: {
            id: vnetId
          }
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'hub-ip'
  location: config.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: 'hub-gateway'
  location: config.location
  properties: {
    vpnType: 'RouteBased'
    activeActive: false
    gatewayType: 'Vpn'

    sku: {
      name: 'Basic'
      tier: 'Basic'
    }

    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subNetId string = vnet.properties.subnets[0].id
