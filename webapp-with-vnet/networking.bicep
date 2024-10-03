import { Config } from './types.bicep'

param config Config

var vnetName = config.naming.virtualNetwork.name
var webSubNetName = '${config.naming.subNetPrefix.name}-web'
var privateSubNetName = '${config.naming.subNetPrefix.name}-pvt'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: config.location
  tags: config.defaultTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: webSubNetName
        properties: {
          addressPrefix: '10.0.0.0/26'
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: [
                config.location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                config.location
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: privateSubNetName
        properties: {
          addressPrefix: '10.0.0.64/26'
          delegations: []
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: [
                config.location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                config.location
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource webSubNet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: webSubNetName
  parent: vnet
}

resource privateSubNet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: privateSubNetName
  parent: vnet
}

output vnetId string = vnet.id
output webSubNetId string = webSubNet.id
output privateSubNetId string = privateSubNet.id
