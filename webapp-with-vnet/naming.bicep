param appShortName string
param env string

/*

Abbreviation recommendations for Azure resources
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

*/

output resources object = {
  appInsights: {
    name: '${appShortName}-${env}-appi'
    abbreviation: 'appi'
  }
  logWorkspace: {
    name: '${appShortName}-${env}-log'
    abbreviation: 'log'
  }
  storageAccount: {
    name: '${appShortName}${env}st'
    abbreviation: 'st'
  }
  storageAccountContainer: {
    name: '${appShortName}${env}sc'
    abbreviation: 'sc'
  }
  sqlServer: {
    name: '${appShortName}-${env}-sql'
    abbreviation: 'sql'
  }
  sqlDatabase: {
    name: '${appShortName}-${env}-sqldb'
    abbreviation: 'sqldb'
  }
  keyVault: {
    name: '${appShortName}-${env}-kv'
    abbreviation: 'kv'
  }
  staticWebApp: {
    name: '${appShortName}-${env}-stapp'
    abbreviation: 'stapp'
  }
  appService: {
    name: '${appShortName}-${env}-app'
    abbreviation: 'app'
  }
  appServicePlan: {
    name: '${appShortName}-${env}-asp'
    abbreviation: 'asp'
  }
  virtualNetwork: {
    name: '${appShortName}-${env}-vnet'
    abbreviation: 'vnet'
  }
  subNetPrefix: {
    name: '${appShortName}-${env}-snet'
    abbreviation: 'snet'
  }
  privateEndpoints: {
    name: '${appShortName}-${env}-pep'
    abbreviation: 'pep'
  }
}
