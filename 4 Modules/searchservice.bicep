/*
.Synopsis
    Bicep template for Cognitive Search Service. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Search/searchServices?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param searchServiceName string

/// tags
param tags object

/// resources
resource searchService 'Microsoft.Search/searchServices@2020-08-01' = {
  name: toLower(searchServiceName)
  location: toLower(location)
  tags: tags
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
  }
}
