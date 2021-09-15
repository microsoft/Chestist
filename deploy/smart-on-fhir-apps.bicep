param clientId string = '20560ea5-f224-4658-b667-4e6bab935c85'
param growthChartImageName string = 'grow-chart-app:v1.0.0'
param location string = resourceGroup().location

var appPlanName = '${uniqueString(resourceGroup().id)}-smartonfhirAppPlan'
var growthChartSiteName = '${uniqueString(resourceGroup().id)}-growth-chart-app'
var chestistSiteName = '${uniqueString(resourceGroup().id)}-chestist-app'
var registryName = 'chestistzec'

resource smartAppPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appPlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

module growChartApp 'modules/smart-app.bicep' = {
  dependsOn: [
    smartAppPlan
  ]
  name: 'GrowthChartApp'
  params: {
    clientId: clientId
    imageName: growthChartImageName
    location: location
    siteName: growthChartSiteName
    registryName: registryName
    appPlanName: appPlanName
  }
}

