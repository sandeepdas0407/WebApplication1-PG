targetScope = 'subscription'

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Name of the resource group')
param resourceGroupName string

// Generate a unique token for resource names
var resourceToken = uniqueString(subscription().id, location, environmentName)

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    'azd-env-name': environmentName
  }
}

// Deploy main resources into the resource group
module main 'main-resources.bicep' = {
  name: 'main-resources'
  scope: rg
  params: {
    location: location
    environmentName: environmentName
    resourceToken: resourceToken
  }
}

// Outputs
output RESOURCE_GROUP_ID string = rg.id
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output WEBAPP_NAME string = main.outputs.WEBAPP_NAME
output WEBAPP_URL string = main.outputs.WEBAPP_URL
output APPLICATION_INSIGHTS_CONNECTION_STRING string = main.outputs.APPLICATION_INSIGHTS_CONNECTION_STRING
output AZURE_KEY_VAULT_ENDPOINT string = main.outputs.AZURE_KEY_VAULT_ENDPOINT
