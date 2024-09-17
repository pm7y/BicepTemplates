import { Config } from './types.bicep'

//targetScope = 'subscription'

param appShortName string = 'wa-demo'
@allowed([
  'dev'
  'test'
  'uat'
  'prod'
  'shared'
])
param env string = 'dev'
// param resourceGroupName string = '${appShortName}-${env}-rg'
param location string = 'australiaeast'
param initKeyVaultSecrets bool = false
param sqlAdminLogin string = 'sqladmin'
@secure()
param sqlAdminPassword string = 'Pa$$w0rd!1234'

var defaultTags = {
  app: appShortName
  environment: env
}

// resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
//   name: 'hub'
//   location: location
//   // tags: defaultTags
// }

// resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
//   name: resourceGroupName
//   location: location
//   tags: defaultTags
// }

module naming 'naming.bicep' = {
  name: 'naming.bicep'
  params: {
    appShortName: appShortName
    env: env
  }
}

var config = {
  appShortName: appShortName
  env: env
  location: location
  // resourceGroupName: resourceGroupName
  initKeyVaultSecrets: initKeyVaultSecrets
  naming: naming.outputs.resources
  sqlAdminLogin: '${sqlAdminLogin}${env}'
  sqlAdminPassword: sqlAdminPassword
  defaultTags: defaultTags
}

module network './networking.bicep' = {
  name: 'networking.bicep'
  params: {
    config: config
  }
}

// module appInsights './appInsights.bicep' = {
//   name: 'appInsights.bicep'
//   scope: resourceGroup('pm-demo-dev-ause-rg01')
//   params: {
//     // None yet
//   }
// }

// module keyVault './keyVault.bicep' = {
//   name: 'keyVault.bicep'
//   params: {
//     config: config
//     vnetId: network.outputs.vnetId
//     privateSubNetId: network.outputs.privateSubNetId
//   }
// }

// module db './database.bicep' = {
//   name: 'database.bicep'
//   params: {
//     config: config
//     vnetId: network.outputs.vnetId
//     privateSubNetId: network.outputs.privateSubNetId
//   }
// }

// module appService './appService.bicep' = {
//   name: 'appService.bicep'
//   params: {
//     config: config
//     webSubNetId: network.outputs.webSubNetId
//     databaseConnectionString: db.outputs.connectionString
//     exampleSecretUri: keyVault.outputs.exampleSecretUri
//     //appInsightsConnectionString: appinsights.outputs.appInsightsConnectionString
//   }
// }

// module ra './roleAssignments.bicep' = {
//   name: 'roleAssignments.bicep'
//   params: {
//     config: config
//     appServicePrincipalId: appService.outputs.principalId
//   }
// }

// module hub './hub.bicep' = {
//   name: 'hub.bicep'
//   scope: hubResourceGroup
//   params: {
//     config: config
//     vnetId: network.outputs.vnetId
//   }
// }
