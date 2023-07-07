/*
.Synopsis
    Bicep template for FrontDoor. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/frontdoors?tabs=bicep#template-format

    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param frontDoorName string
param domain string
param frontDoorPrefix string

//// service names
param frontDoorBackendServiceName string

///// backend address
param frontDoorBackendAddress001 string
param frontDoorBackendAddress002 string

///// backend endpoint address
var frontendEndpointProd = replace('${frontDoorBackendServiceName}.${domain}', '.', '-')

var environmentName = 'PRD'

var deploymentSettings = {
  PRD: {
    frontendEndpoints: [
      {
        // default frontdoor url
        name: toLower('${frontDoorName}-azurefd-net')
        id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/FrontendEndpoints/${frontDoorName}-azurefd-net')
        properties: {
          hostName: toLower(replace('${frontDoorName}-azurefd-net', '-', '.'))
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 0
        }
      }
      {
        // prod storage account custom dns url
        name: frontendEndpointProd
        id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/FrontendEndpoints/${frontendEndpointProd}')
        properties: {
          hostName: toLower('${frontDoorBackendServiceName}.${domain}')
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 0
        }
      }
    ]
    backendPools: [
      {
        // prod storage account backend pool
        name: toLower('${frontDoorPrefix}-fd-BackendPool-${frontDoorBackendServiceName}')
        id: '${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/BackendPools/${frontDoorPrefix}-fd-BackendPool-${frontDoorBackendServiceName}'
        properties: {
          backends: [
            {
              address: toLower(frontDoorBackendAddress001)
              backendHostHeader: toLower(frontDoorBackendAddress001)
              httpPort: 80
              httpsPort: 443
              priority: ((location == 'uksouth') ? 1 : 2 )
              weight: ((location == 'uksouth') ? 100 : 1 )
              enabledState: ((location == 'uksouth') ? 'Enabled' : 'Disabled' )
            }
            {
              address: toLower(frontDoorBackendAddress002)
              backendHostHeader: toLower(frontDoorBackendAddress002)
              httpPort: 80
              httpsPort: 443
              priority: ((location == 'ukwest') ? 1 : 2 )
              weight: ((location == 'ukwest') ? 100 : 1 )
              enabledState: ((location == 'ukwest') ? 'Enabled' : 'Disabled' )
            }
          ]
          loadBalancingSettings: {
            id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/LoadBalancingSettings/${frontDoorPrefix}-fd-LBSettings-${frontDoorBackendServiceName}')
          }
          healthProbeSettings: {
            id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/HealthProbeSettings/${frontDoorPrefix}-fd-Probes-${frontDoorBackendServiceName}')
          }
        }
      }
    ]
    loadBalancingSettings: [
      {
        // prod storage account load balancing rule
        name: toLower('${frontDoorPrefix}-fd-LBSettings-${frontDoorBackendServiceName}')
        id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/LoadBalancingSettings/${frontDoorPrefix}-fd-LBSettings-${frontDoorBackendServiceName}')
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
          additionalLatencyMilliseconds: 0
        }
      }
    ]
    healthProbeSettings: [
      {
        // prod storage account health probes
        name: toLower('${frontDoorPrefix}-fd-Probes-${frontDoorBackendServiceName}')
        id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/HealthProbeSettings/${frontDoorPrefix}-fd-Probes-${frontDoorBackendServiceName}')
        properties: {
          path: '/blobstatus'
          protocol: 'Https'
          intervalInSeconds: 30
          healthProbeMethod: 'HEAD'
          enabledState: 'Enabled'
        }
      }
    ]
    routingRules: [
      {
        // prod storage account routing rule
        name: toLower('${frontDoorPrefix}-fd-Rule-${frontDoorBackendServiceName}')
        id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}${frontDoorPrefix}-fd-Rule-${frontDoorBackendServiceName}')
        properties: {
          frontendEndpoints: [
            {
              id: toLower('${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/FrontendEndpoints/${frontendEndpointProd}')
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: '${resourceId('Microsoft.Network/frontdoors', frontDoorName)}/BackendPools/${frontDoorPrefix}-fd-BackendPool-${frontDoorBackendServiceName}'
            }
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }
}

/// monitoring
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

/// tags
param tags object

/// resources
resource frontDoor 'Microsoft.Network/frontdoors@2020-05-01' = {
  name: toLower(frontDoorName)
  location: 'global'
  tags: tags
  properties: {
    friendlyName: toLower(frontDoorName)
    frontendEndpoints: deploymentSettings[environmentName].frontendEndpoints
    backendPools: deploymentSettings[environmentName].backendPools
    loadBalancingSettings: deploymentSettings[environmentName].loadBalancingSettings
    healthProbeSettings: deploymentSettings[environmentName].healthProbeSettings
    routingRules: deploymentSettings[environmentName].routingRules
    backendPoolsSettings: {
      enforceCertificateNameCheck: 'Enabled'
      sendRecvTimeoutSeconds: 120
    }
    enabledState: 'Enabled'
  }
}

resource logAnalytics_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
  name: logAnalyticsWorkspaceName
}

resource send_data_to_logAnalyticsWorkspace 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceName)) {
  scope: frontDoor
  name: toLower('send-data-to-${logAnalyticsWorkspaceName}')
  properties: {
    workspaceId: logAnalytics_resource.id
    logs: [
      {
        category: 'FrontdoorAccessLog'
        enabled: true
      }
      {
        category: 'FrontdoorWebApplicationFirewallLog'
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
