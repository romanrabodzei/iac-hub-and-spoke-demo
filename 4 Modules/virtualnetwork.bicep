/*
.Synopsis
    Bicep template for Virtual Network. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualNetworks?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param virtualNetworkName string
param virtualNetworkAddressPrefix string
param virtualSubnetName string
param virtualNetworkSubnetPrefix string
param networkSecurityGroupName string = ''
var networkSecurityGroupId = {
  id: resourceId('Microsoft.Network/networkSecurityGroups', toLower(networkSecurityGroupName))
}

/// monitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: toLower(virtualNetworkName)
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: toLower(virtualSubnetName)
        properties: {
          addressPrefix: virtualNetworkSubnetPrefix
          networkSecurityGroup: networkSecurityGroupName != '' ? networkSecurityGroupId : null
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: virtualNetwork
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output virtualNetworkId string = virtualNetwork.id
