/*
.Synopsis
    Bicep template for Bastion host. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/bastionHosts?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param bastionName string
param publicIPAddressName string
param virtualNetworkName string

/// monitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: toLower(virtualNetworkName)
  resource AzureBastionSubnet 'subnets' existing = {
    name: 'AzureBastionSubnet'
  }
}

resource publicIpAddress_resource 'Microsoft.Network/publicIPAddresses@2022-07-01' existing = {
  name: publicIPAddressName
}

resource bastion_resource 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: toLower(bastionName)
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    dnsName: '${replace(bastionName, '.', '')}.bastion.azure.com'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress_resource.id
          }
          subnet: {
            id: virtualNetwork_resource::AzureBastionSubnet.id
          }
        }
      }
    ]
    scaleUnits: 2
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: bastion_resource
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'BastionAuditLogs'
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
