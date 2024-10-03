import { Config } from './types.bicep'

param config Config
param exampleSecretUri string
param webSubNetId string
param databaseConnectionString string
// @secure()
// param appInsightsConnectionString string

// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?pivots=deployment-language-bicep
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: config.naming.appServicePlan.name
  location: config.location
  tags: config.defaultTags
  kind: 'app'
  sku: {
    name: 'P0v3' // ~ AUD$85/month
    tier: 'Premium0V3'
    size: 'P0v3'
    family: 'Pv3'
    capacity: 1
  }
  properties: {
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 5
    zoneRedundant: false
  }
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep
resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: config.naming.appService.name
  location: config.location
  tags: config.defaultTags
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    clientCertEnabled: false
    clientAffinityEnabled: false
    httpsOnly: true
    vnetRouteAllEnabled: true
    publicNetworkAccess: 'Enabled'
    virtualNetworkSubnetId: webSubNetId

    siteConfig: {
      alwaysOn: true
      webSocketsEnabled: false
      websiteTimeZone: 'AUS Eastern Standard Time'
      scmIpSecurityRestrictionsUseMain: false
      scmMinTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
      vnetRouteAllEnabled: true

      appSettings: [
        // {
        //   name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        //   value: appInsightsConnectionString
        // }
        // {
        //   name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
        //   value: '~2'
        // }
        {
          name: 'ExampleSecret'
          value: '@Microsoft.KeyVault(SecretUri=${exampleSecretUri})'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
      ]

      connectionStrings: [
        {
          name: 'Default'
          connectionString: databaseConnectionString
          type: 'SQLAzure'
        }
      ]

      managedPipelineMode: 'Integrated'
      ftpsState: 'Disabled'
      use32BitWorkerProcess: false
      remoteDebuggingEnabled: false
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: false
      http20Enabled: true
      minTlsVersion: '1.2'
      javaVersion: 'off'
      nodeVersion: 'off'
      phpVersion: 'off'
      pythonVersion: 'off'
    }
  }
}

resource networkConfig 'Microsoft.Web/sites/networkConfig@2023-12-01' = {
  parent: appService
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: webSubNetId
    swiftSupported: true
  }
}

output principalId string = appService.identity.principalId
