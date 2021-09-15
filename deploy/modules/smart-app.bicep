param siteName string
param clientId string
param imageName string
param location string
param appPlanName string
param registryName string
param localAcr bool

var acrPullRoleDefinitionId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
var registryLoginUri = '${registryName}.azurecr.io'

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = if (localAcr) {
  name: registryName
}

resource appPlan 'Microsoft.Web/serverfarms@2021-01-15' existing = {
  name: appPlanName
}

resource growthApp 'Microsoft.Web/sites@2021-01-15' = {
  name: siteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'CLIENT_ID'
          value: clientId
        }        
      ]
      linuxFxVersion: 'DOCKER|${registryLoginUri}/${imageName}'
      acrUseManagedIdentityCreds: true
    }
    serverFarmId: appPlan.id
    httpsOnly: true
  }
}

resource rbacPull 'Microsoft.Authorization/roleAssignments@2015-07-01' = if (localAcr) {
  dependsOn: [
    growthApp
  ]
  name: guid(resourceGroup().id, siteName)
  properties: {
    principalId: growthApp.identity.principalId
    roleDefinitionId: acrPullRoleDefinitionId
  }
  scope: acr
}
