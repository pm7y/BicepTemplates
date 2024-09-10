import { Config } from './types.bicep'

param config Config
param privateSubNetId string
param vnetId string

var sqlServerHost = '${sqlServer.name}${environment().suffixes.sqlServerHostname}'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: config.naming.sqlServer.name
  location: config.location
  tags: config.defaultTags
  properties: {
    administratorLogin: config.sqlAdminLogin
    administratorLoginPassword: config.sqlAdminPassword

    administrators: {
      azureADOnlyAuthentication: false
      administratorType: 'ActiveDirectory'
      principalType: 'Group' // Allow admin login from an Azure AD group
      login: 'paulmcilreavyadmin' // The name of the group
      sid: '6896e88a-096e-4673-8342-37cdb02c5f33' // Object ID of the group
      tenantId: subscription().tenantId
    }

    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
    isIPv6Enabled: 'Disabled'
    restrictOutboundNetworkAccess: 'Enabled'
    version: '12.0'
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: config.naming.sqlDatabase.name
  location: config.location
  tags: config.defaultTags
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 10 // DTUs ~ AUD$25/month
  }
  properties: {
    createMode: 'Default'
    zoneRedundant: false
    requestedBackupStorageRedundancy: 'Zone'
    maxSizeBytes: 10 * 1024 * 1024 * 1024 // 10 GB
  }
}

resource strp 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2023-08-01-preview' = {
  name: 'default'
  parent: sqlServerDatabase
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${config.naming.sqlServer.name}-${config.naming.privateEndpoints.abbreviation}'
  location: config.location
  tags: config.defaultTags
  properties: {
    customNetworkInterfaceName: '${config.naming.sqlServer.name}-${config.naming.privateEndpoints.abbreviation}-nic'
    privateLinkServiceConnections: [
      {
        name: '${config.naming.sqlServer.name}-${config.naming.privateEndpoints.abbreviation}-con'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: ['sqlServer']
        }
      }
    ]
    subnet: {
      id: privateSubNetId
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'Global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${config.naming.sqlServer.name}-${config.naming.privateEndpoints.abbreviation}-lnk'
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
        name: '${config.naming.sqlServer.name}-${config.naming.privateEndpoints.abbreviation}-dnsgrp'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

/*
CREATE USER [tp-demo-dev-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [tp-demo-dev-app];
ALTER ROLE db_datawriter ADD MEMBER [tp-demo-dev-app];
*/

output connectionString string = 'Server=tcp:${sqlServerHost},1433;Database=${sqlServerDatabase.name};Encrypt=True;TrustServerCertificate=False;Authentication=Active Directory Default;'
