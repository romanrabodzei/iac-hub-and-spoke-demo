/*
.Synopsis
    Bicep template for App Service Plans. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Web/serverfarms?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param appServicePlanName string
param appServicePlanSku string = 'B1'

/// tags
param tags object

/// resources
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: toLower(appServicePlanName)
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
  }
}
