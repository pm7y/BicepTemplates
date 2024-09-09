@description('The location to deploy the resources to.')
param location string = 'australiaeast'

@description('The name of the container group to create.')
param containerGroupName string

@description('The name of the storage account to create.')
param storageAccountName string

@description('Set this if you are using a custom domain, e.g. via CloudFlare or similar.')
param overridePublicUrl string = ''

@description('Set this to true to create an automation account to automatically stop the container group each day at 9.30pm.')
param createAutomationAccount bool = false

@description('Set this to the time zone you want to use.')
param timeZone string = 'Australia/Brisbane'

@description('Create a storage account and file shares to persist data for the n8n and Caddy containers.')
module storageAccount './storage-account.bicep' = {
  name: 'n8nStorageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName
    containerGroupName: containerGroupName
  }
}

@description('Create an ACI container group to run the n8n and Caddy containers.')
module n8nAci './aci.bicep' = {
  name: 'n8nAci'
  params: {
    location: location
    storageAccountName: storageAccountName
    containerGroupName: containerGroupName
    timeZone: timeZone
    n8nFileShareName: storageAccount.outputs.n8nFileShareName
    caddyDataFileShareName: storageAccount.outputs.caddyDataFileShareName
    overridePublicUrl: overridePublicUrl
  }
}

@description('Create an automation to automatically stop the container group each day at 9.30pm.')
module automation './automation.bicep' = if (createAutomationAccount) {
  name: 'n8nAutomation'
  params: {
    location: location
    containerGroupName: containerGroupName
    timeZone: timeZone
  }
}
