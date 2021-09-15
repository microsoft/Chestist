param siteName string = '${uniqueString(resourceGroup().id)}-growth-chart-app'
param clientId string = '20560ea5-f224-4658-b667-4e6bab935c85'
param imageName string = 'growth-chart-app:v1.0.0'
param location string = resourceGroup().location

var registryName = 'healthplatformregistry.azurecr.io'

resource appPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'growthchartAppPlan'
  kind: 'linux'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

resource growthApp 'Microsoft.Web/sites@2021-01-15' = {
  name: siteName
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'CLIENT_ID'
          value: clientId
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${registryName}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
      ]
      linuxFxVersion: 'DOCKER|${registryName}/${imageName}'
    }
    serverFarmId: appPlan.id
    httpsOnly: true
  }
}
