@description('Configuration for the deployment')
@export()
type Config = {
  appShortName: string
  env: string
  location: string
  // resourceGroupName: string
  initKeyVaultSecrets: bool
  naming: object
  sqlAdminLogin: string
  sqlAdminPassword: string
  defaultTags: object
}
