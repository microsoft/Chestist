param dashboardAppName string
param dashboardAppPlanName string
param location string
param aadClientId string
@secure()
param aadClientSecret string
@description('OAuth Authority')
param aadAuthority string
param aadAudience string

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
