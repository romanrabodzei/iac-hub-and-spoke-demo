/*
.Synopsis
    Bicep template for Public Ip Address. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/publicIPAddresses?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param publicIPAddressName string
var domainNameLabel = replace(publicIPAddressName, '.', '')
var zoneRedundancy  = {
  usgovvirginia: [
    '1'
    '2'
    '3'
  ]
  eastus: [
    '1'
    '2'
    '3'
  ]
  uksouth: [
    '1'
    '2'
    '3'
  ]
  ukwest: [
    '1'
  ]
}

/// tags
param tags object

/// resources
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: toLower(publicIPAddressName)
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: zoneRedundancy[location]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: toLower(domainNameLabel)
      fqdn: '${domainNameLabel}.${location}.cloudapp.azure.com'
    }
  }
}

output publicIPAddress_id string = publicIPAddress.id
