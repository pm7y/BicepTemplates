# Azure Container Instance (ACI)

Create an Azure Container Instance container group with two containers:

- [n8n](https://n8n.io/): n8n is a workflow automation tool that allows you to automate tasks across different services and applications.
- [caddy](https://caddyserver.com/): Caddy is a powerful, enterprise-ready, open-source web server with automatic HTTPS written in Go. It is used here to provide `https` to the n8n instance since ACI does not provide SSL.

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
  OVERRIDE_PUBLIC_URL=
  CREATE_AUTOMATION_ACCOUNT=false
  ```

- Run the PowerShell script [deploy.json](./deploy.ps1)

### Parameters

| Parameter                 | Description                                                                                                                             | Example                  |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `containerGroupName`      | The name of the Azure Container Instance container group.                                                                               | `myContainerGroup`       |
| `storageAccountName`      | The name of the storage account to be created.                                                                                          | `mystorageaccount`       |
| `overridePublicUrl`       | (Optional) Custom domain name for the public URL. Only use this if you have a custom DNS setup to point at the ACI e.g. via Cloudflare. | `mycustomdomainname.com` |
| `createAutomationAccount` | (Optional) Boolean flag to create an automation account to automatically stop the container group each day at 9.30pm.                   | `true` or `false`        |

## Bicep Files

| File                    | Description                                                                                                                                             |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `main.bicep`            | The main Bicep file that orchestrates the deployment of the entire solution.                                                                            |
| `storage-account.bicep` | Creates a storage account and file shares to persist data for the containers.                                                             |
| `aci.bicep`             | Defines the Azure Container Instance container group with two containers.                                                                |
| `automation.bicep`      | Creates an automation account to automatically stop the container group each day at 9.30pm if the `createAutomationAccount` parameter is set to `true`. |

## Bicep Resource Diagram

![Bicep Resource Diagram](/.docs/images/aci.png)
