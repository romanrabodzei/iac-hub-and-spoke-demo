/*
.Synopsis
    Bicep template for SQL Server. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/servers?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param sqlServerName string

param networkingResourceGroupName string = ''
param virtualNetworkName string = ''
param virtualNetworkSubnetName string = ''

/// authentication
param sqlServerAdminUsername string = 'CoESqlAdmin'
@secure()
param sqlServerAdminPassword string = newGuid()
// param AADGroupName string
// param AADGroupSid string

/// tags
param tags object

/// resources
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: toLower(sqlServerName)
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlServerAdminUsername
    administratorLoginPassword: sqlServerAdminPassword
    // administrators: {
    //   administratorType: 'ActiveDirectory'
    //   login: AADGroupName
    //   sid: AADGroupSid
    //   tenantId: tenant().tenantId
    //   azureADOnlyAuthentication: true
    //   principalType: 'Group'
    // }
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
  resource allowAllWindowsAzureIps 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
  resource virtualNetworkRule 'virtualNetworkRules' = if (!empty(virtualNetworkName)) {
    name: toLower('${sqlServerName}-vNetRule')
    properties: {
      virtualNetworkSubnetId: virtualNetwork::virtualSubnet.id
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' existing = if (!empty(virtualNetworkName)) {
  scope: resourceGroup(networkingResourceGroupName)
  name: toLower(virtualNetworkName)
  resource virtualSubnet 'subnets' existing = {
    name: toLower(virtualNetworkSubnetName)
  }
}
