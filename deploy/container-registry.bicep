param registryName string = 'chestist${substring(uniqueString(resourceGroup().id), 0, 3)}'
param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard'
  }
}

output registry string = acr.name
