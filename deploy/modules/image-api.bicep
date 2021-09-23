param functionAppName string
param appPlanName string
param location string
param imageStoreConnStr string
param imageStoreContainer string

var storageName = toLower('func${uniqueString(resourceGroup().id)}SA')
var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'

resource functionAppPlan 'Microsoft.Web/serverfarms@2021-01-15' existing = {
  name: appPlanName
}

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-01-15' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    siteConfig: {    
      appSettings: [
          {
              name: 'FUNCTIONS_EXTENSION_VERSION'
              value: '~3'
          }
          {
              name: 'FUNCTIONS_WORKER_RUNTIME'
              value: 'dotnet'
          }          
          {
              name: 'AzureWebJobsStorage'              
              value: blobStorageConnectionString
          }
          {
            name: 'ImageStoreConnectionString'
            value: imageStoreConnStr
          }
          {
            name: 'ContainerName'
            value: imageStoreContainer
          }
      ]
      linuxFxVersion: 'dotnet|3.1'
    }
    serverFarmId: functionAppPlan.id    
  }
}

output imageApiFuncAppName string = functionApp.name
