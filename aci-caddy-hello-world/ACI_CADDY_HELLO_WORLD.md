# Azure Container Instance (ACI)

Create an Azure Container Instance container group with two containers:

- [aci-helloworld](https://github.com/Azure-Samples/aci-helloworld): A simple hello world node application designed to run in ACI.
- [caddy](https://hub.docker.com/_/caddy): Caddy is a powerful, enterprise-ready, open-source web server with automatic HTTPS written in Go. It is used here to provide `https` to the hello world instance since ACI does not provide SSL.

## Deployment Instructions

- Copy the `.env.template` file in this folder and rename to `.env` (this will be ignored by `git`).
- Populate with the necessary values.

  ```env
  TENANT_ID=
  SUBSCRIPTION_ID=
  RESOURCE_GROUP=
  LOCATION=
  CONTAINER_GROUP_NAME=
  STORAGE_ACCOUNT_NAME=
  ```

- Run the PowerShell script [deploy.json](./deploy.ps1)

### Parameters

| Parameter                 | Description                                                                                                                             | Example                  |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `containerGroupName`      | The name of the Azure Container Instance container group.                                                                               | `myContainerGroup`       |
| `storageAccountName`      | The name of the storage account to be created.                                                                                          | `mystorageaccount`       |

## Bicep Files

| File                    | Description                                                                                                                                             |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `main.bicep`            | The main Bicep file that orchestrates the deployment of the entire solution.                                                                            |
| `storage-account.bicep` | Creates a storage account and file shares to persist data for the containers.                                                             |
| `aci.bicep`             | Defines the Azure Container Instance container group with two containers.                                                                |
