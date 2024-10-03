import { Config } from './types.bicep'

param config Config
param appServicePrincipalId string

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var kvSecretReaderRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var kvSecretOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

/*
Key Vault Role Assignments
*/
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: config.naming.keyVault.name
}

resource kvSecretReaderRA 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appServicePrincipalId, kvSecretReaderRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvSecretReaderRoleId)
    principalId: appServicePrincipalId
  }
}

var myOid = 'ecbecfe7-521a-465c-8b5a-27c4273808e9' // 'a5de0be6-250a-4e36-a2c0-904f8c0bd0c9'
resource meRA 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, myOid, kvSecretOfficerRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvSecretOfficerRoleId)
    principalId: myOid
  }
}
