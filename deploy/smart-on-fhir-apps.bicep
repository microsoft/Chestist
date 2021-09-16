param clientId string = '20560ea5-f224-4658-b667-4e6bab935c85'
param growthChartImageName string = 'growth-chart-app:v1.0.0'
param chestistImageName string = 'chestist-smart-app:v1.0.0'
param location string = resourceGroup().location

param dashboardAppName string = '${uniqueString(resourceGroup().id)}-fhir-dashboard'
param dashboardAppPlanName string = '${uniqueString(resourceGroup().id)}-app-plan'
param aadClientId string = '8a097d51-6cb3-49b7-8e2a-d9d3ad192584'
@secure()
param aadClientSecret string
@description('OAuth Authority')
param aadAuthority string = 'https://login.microsoftonline.com/c2c1d092-cf24-4636-a284-203c93601579'
param aadAudience string = 'https://chestist-fhir-api.azurehealthcareapis.com'

var appPlanName = '${uniqueString(resourceGroup().id)}-smartonfhirAppPlan'
var growthChartSiteName = '${uniqueString(resourceGroup().id)}-growth-chart-app'
var chestistSiteName = '${uniqueString(resourceGroup().id)}-chestist-app'
var growChartRegistryName = 'healthplatformregistry'
var chestistRegistryName = 'chestistzec'

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
  name: 'GrowthChartApp'
  params: {
    localAcr: false
    clientId: clientId
    imageName: growthChartImageName
    location: location
    siteName: growthChartSiteName
    registryName: growChartRegistryName
    appPlanName: smartAppPlan.name
  }
}

module chestistApp 'modules/smart-app.bicep' = {
  name: 'ChestistSmartApp'
  params: {
    localAcr: true
    clientId: clientId
    imageName: chestistImageName
    location: location
    siteName: chestistSiteName
    registryName: chestistRegistryName
    appPlanName: smartAppPlan.name
  }
}

module dashboardApp 'modules/dashboard.bicep' = {
  name: 'FHIR-Dashboard'
  params: {
    aadAudience: aadAudience
    aadAuthority: aadAuthority
    aadClientId: aadClientId
    aadClientSecret: aadClientSecret
    dashboardAppName: dashboardAppName
    dashboardAppPlanName: dashboardAppPlanName
    location: location
  }
}

output fhirDashboardAppName string = dashboardApp.outputs.fhirDashboardAppName
