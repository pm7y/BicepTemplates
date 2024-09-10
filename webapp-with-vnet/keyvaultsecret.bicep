import { Config } from './types.bicep'

param config Config
param secretName string
param contentType string

var secretNameFull = '${config.naming.keyVault.name}/${secretName}'

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (config.initKeyVaultSecrets) {
  name: secretNameFull
  tags: config.defaultTags
  properties: {
    value: '--CHANGE-ME--'
    contentType: contentType
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultSecretRef 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = if (!config.initKeyVaultSecrets) {
  name: secretNameFull
}

output secretUri string = config.initKeyVaultSecrets
  ? keyVaultSecret.properties.secretUri
  : keyVaultSecretRef.properties.secretUri
