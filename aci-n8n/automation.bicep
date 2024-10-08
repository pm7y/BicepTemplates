param containerGroupName string
param location string
param timeZone string = 'Australia/Brisbane'
param timeZoneOffset string = '+10:00'
param baseDate string = utcNow('u')

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2024-05-01-preview' existing = {
  name: containerGroupName
}

resource containerInstanceContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: containerGroup
  // Azure Container Instances Contributor Role
  // See https://github.com/microsoft/azure-roles
  name: '5d977122-f97e-4b4d-a52f-6b43003ddb4d'
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: '${containerGroupName}-aa'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: true
    disableLocalAuth: true
    sku: {
      name: 'Basic'
    }
  }
}

resource stopSchedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = {
  parent: automationAccount
  name: '${containerGroupName}-stopSchedule'
  properties: {
    frequency: 'Day'
    interval: 1
    startTime: '${dateTimeAdd(baseDate, 'P1D', 'yyyy-MM-dd')}T21:30:00${timeZoneOffset}'
    timeZone: timeZone
    description: 'Stop the container group every day to save money.'
  }
}

resource stopRunbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  parent: automationAccount
  name: '${containerGroupName}-stopRunbook'
  location: location
  properties: {
    runbookType: 'PowerShell72'
    logVerbose: false
    logProgress: false
    description: 'Stop the container group every night to save money'
    publishContentLink: {
      uri: 'https://gist.githubusercontent.com/pm7y/ab5c855752b53550ac4689dba793f33a/raw/f92b33efe9d5c882a570f4695816457dbf3634c3/StopN8NContainerGroup.ps1'
      contentHash: {
        algorithm: 'SHA256'
        // https://codebeautify.org/sha256-hash-generator
        value: 'f720f24c45596e9279734bf8e1cbb4d46bdd0ec52f77ebb485b2ede043a745c3'
      }
      version: '1.0.0'
    }
  }
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-11-01' = {
  parent: automationAccount
  name: guid(resourceGroup().id, automationAccount.id, stopRunbook.id) // must be a guid
  properties: {
    runbook: {
      name: stopRunbook.name
    }
    schedule: {
      name: stopSchedule.name
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerGroup
  name: guid(containerGroup.id, containerInstanceContributorRole.id) // must be a guid
  properties: {
    roleDefinitionId: containerInstanceContributorRole.id
    principalId: automationAccount.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
