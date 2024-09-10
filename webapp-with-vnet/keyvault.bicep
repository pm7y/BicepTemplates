import { Config } from './types.bicep'

param config Config
param vnetId string
param privateSubNetId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: config.naming.keyVault.name
  location: config.location
  tags: config.defaultTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Disabled'
    accessPolicies: []
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

module exampleSecret './keyVaultSecret.bicep' = {
  dependsOn: [keyVault]
  name: 'example-secret'
  params: {
    config: config
    secretName: 'ExampleSecret'
    contentType: ''
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${config.naming.keyVault.name}-${config.naming.privateEndpoints.abbreviation}'
  location: config.location
  tags: config.defaultTags
  properties: {
    customNetworkInterfaceName: '${config.naming.keyVault.name}-${config.naming.privateEndpoints.abbreviation}-nic'
    privateLinkServiceConnections: [
      {
        name: '${config.naming.keyVault.name}-${config.naming.privateEndpoints.abbreviation}-con'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
    subnet: {
      id: privateSubNetId
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.keyvaultDns}'
  location: 'Global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${config.naming.keyVault.name}-${config.naming.privateEndpoints.abbreviation}-lnk'
  parent: privateDnsZone
  location: 'Global'
  tags: config.defaultTags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${config.naming.keyVault.name}-${config.naming.privateEndpoints.abbreviation}-dnsgrp'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

// resource kvDeleteLock 'Microsoft.Authorization/locks@2020-05-01' = {
//   name: '${config.naming.keyVault.name}-lock'
//   scope: keyVault
//   properties: {
//     level: 'CanNotDelete'
//     notes: 'This lock protects the Key Vault from deletion.'
//   }
// }

output exampleSecretUri string = exampleSecret.outputs.secretUri
