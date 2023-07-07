/*
.Synopsis
    Bicep template for NAT Gateway. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/natGateways?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param natGatewayName string
param publicIPAddressName string

/// tags
param tags object

/// resources
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' existing = {
  name: toLower(publicIPAddressName)
}

resource nat_resource 'Microsoft.Network/natGateways@2022-07-01' = {
  name: toLower(natGatewayName)
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: publicIPAddress.id
      }
    ]
  }
}
