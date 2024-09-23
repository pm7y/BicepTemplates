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
  dependsOn: [
    containerGroup
  ]
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
      uri: 'https://gist.githubusercontent.com/pm7y/8b9b9f1d2011402646484e622da9c591/raw/6f9f41ddd4f9a4f06c509506e0d871744767fb17/StopALLMContainerGroup.ps1'
      contentHash: {
        algorithm: 'SHA256'
        // https://codebeautify.org/sha256-hash-generator
        value: 'e8c987a139674494171c96cb9c526ac21d964eae05aa99838af8bb0553956d4e'
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
