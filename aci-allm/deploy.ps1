# Load .env file and set environment variables
$envFilePath = ".env"
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.*)\s*$") {
            $name = $matches[1]
            $value = $matches[2]
            [System.Environment]::SetEnvironmentVariable($name, $value)
            Write-Host "env variable: $name=$value"
        }
    }
}

$tenantId = [System.Environment]::GetEnvironmentVariable("TENANT_ID")
$subscriptionId = [System.Environment]::GetEnvironmentVariable("SUBSCRIPTION_ID")
$resourceGroup = [System.Environment]::GetEnvironmentVariable("RESOURCE_GROUP")
$location = [System.Environment]::GetEnvironmentVariable("LOCATION")
$containerGroupName = [System.Environment]::GetEnvironmentVariable("CONTAINER_GROUP_NAME")
$storageAccountName = [System.Environment]::GetEnvironmentVariable("STORAGE_ACCOUNT_NAME")
$overridePublicUrl = [System.Environment]::GetEnvironmentVariable("OVERRIDE_PUBLIC_URL")
$createAutomationAccount = [System.Environment]::GetEnvironmentVariable("CREATE_AUTOMATION_ACCOUNT")


# az config set core.login_experience_v2=off # Disable the new login experience
# az login --tenant $tenantId

az account set --subscription $subscriptionId
az group create --name $resourceGroup --location $location

az deployment group create `
    --resource-group $resourceGroup `
    --template-file main.bicep `
    --parameters containerGroupName=$containerGroupName `
    storageAccountName=$storageAccountName `
    overridePublicUrl=$overridePublicUrl `
    createAutomationAccount=$createAutomationAccount
