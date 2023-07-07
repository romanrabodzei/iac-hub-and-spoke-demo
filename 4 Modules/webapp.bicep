/*
.Synopsis
    Bicep template for WebApps. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Web/sites?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param webAppName string

param appServicePlanResourceGroupName string
param appServicePlanName string

param appInsightsResourceGroupName string
param appInsightsName string

param networkingResourceGroupName string = ''
param virtualNetworkName string = ''
param virtualNetworkSubnetName string = ''

/// tags
param tags object

/// resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (!empty(virtualNetworkName)) {
  scope: resourceGroup(networkingResourceGroupName)
  name: toLower(virtualNetworkName)
  resource subnet 'subnets' existing = {
    name: toLower(virtualNetworkSubnetName)
  }
}

var virtualNetworkSubnetId = ((empty(virtualNetwork::subnet.id)) ? null : virtualNetwork::subnet.id)

resource appInsights_resource 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(appInsightsResourceGroupName)
  name: toLower(appInsightsName)
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  scope: resourceGroup(appServicePlanResourceGroupName)
  name: toLower(appServicePlanName)
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: toLower(webAppName)
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights_resource.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights_resource.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
      ]
      netFrameworkVersion: 'v6.0'
      remoteDebuggingVersion: 'VS2019'
      use32BitWorkerProcess: false
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    virtualNetworkSubnetId: virtualNetworkSubnetId
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
