param dashboardAppName string = '${uniqueString(resourceGroup().id)}-fhir-dashboard'
param dashboardAppPlanName string = '${uniqueString(resourceGroup().id)}-app-plan'
param location string = resourceGroup().location
param aadClientId string = '6fc6d527-d420-46d3-83f3-8e7c5e663848'
@secure()
param aadClientSecret string
@description('OAuth Authority')
param aadAuthority string = 'https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47'
param aadAudience string = 'https://chestist-fhir-api.azurehealthcareapis.com'

resource dashboardAppPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: dashboardAppPlanName
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

resource dashboardApp 'Microsoft.Web/sites@2020-12-01' = {
  name: dashboardAppName
  location: location
  properties: {
    serverFarmId: dashboardAppPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|14-lts'
      appSettings: [
        {
          name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
          value: aadClientSecret
        }
      ]
    }
    reserved: true
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource authconfig 'config' = {
    name: 'authsettingsV2'
    properties: {
      platform: {
        enabled: true
      }
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'RedirectToLoginPage'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            openIdIssuer: aadAuthority
            clientId: aadClientId
            clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'            
          }
          login: {
            loginParameters: [
              'resource=${aadAudience}'
            ]
          }
        }
      }
    }
  }

}

