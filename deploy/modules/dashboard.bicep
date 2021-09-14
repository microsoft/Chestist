param dashboardAppName string = '${uniqueString(resourceGroup().id)}-fhir-dashboard'
param dashboardAppPlanName string = '${uniqueString(resourceGroup().id)}-app-plan'
param location string = resourceGroup().location
param aadClientId string = '8a097d51-6cb3-49b7-8e2a-d9d3ad192584'
@secure()
param aadClientSecret string
@description('OAuth Authority')
param aadAuthority string = 'https://login.microsoftonline.com/c2c1d092-cf24-4636-a284-203c93601579'
param aadAudience string = 'https://chestist-fhir-api.azurehealthcareapis.com'

resource dashboardAppPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: dashboardAppPlanName
  location: location
  kind: 'app'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource dashboardApp 'Microsoft.Web/sites@2020-12-01' = {
  name: dashboardAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: dashboardAppPlan.id
    siteConfig: {
      netFrameworkVersion: 'v5.0'
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
        redirectToProvider: 'azureactivedirectory'
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
              'scope=openid offline_access'
            ]
          }
        }
      }      
      login: {
        tokenStore: {
          enabled: true
        }
      }
      httpSettings: {
        requireHttps: true
        routes: {
          apiPrefix: '/.auth'
        }
      }
    }
  }

}

output fhirDashboardAppName string = dashboardApp.name
