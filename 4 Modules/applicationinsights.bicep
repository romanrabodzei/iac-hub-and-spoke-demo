/*
.Synopsis
    Bicep template for Microsoft Insights Components. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/components?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param appInsightsName string
param logAnalyticsWorkspaceResourceId string

/// tags
param tags object

/// resources
resource appInsights_resource 'Microsoft.Insights/components@2020-02-02' = {
  name: toLower(appInsightsName)
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}
