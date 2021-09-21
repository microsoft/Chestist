param name string = '${uniqueString(resourceGroup().id)}-chestist-db'
param location string = resourceGroup().location
param locationName string = 'Central US'
param defaultExperience string = 'Azure Table'

resource name_resource 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  kind: 'GlobalDocumentDB'
  name: name
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: locationName
        failoverPriority: 0
      }
    ]
    isVirtualNetworkFilterEnabled: false
    capabilities: [
      {
        name: 'EnableTable'
      }
      {
        name: 'EnableServerless'
      }
    ]
  }
  tags: {
    defaultExperience: defaultExperience
  }
}
