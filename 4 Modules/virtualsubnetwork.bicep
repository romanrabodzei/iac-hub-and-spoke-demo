/*
.Synopsis
    Bicep template for Virtual Network Subnet. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/virtualNetworks/subnets?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployments scope
targetScope = 'resourceGroup'

/// parameters
param virtualNetworkName string
param virtualNetworkSubnetName string
param virtualNetworkSubnetAddressPrefix string
param virtualNetworkSubnetNetworkSecurityGroupName string
param virtualNetworkSubnetNatGatewayName string = ''
param virtualNetworkSubnetDelegations array = []
param virtualNetworkSubnetServiceEndpoints array = []

/// resources
resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: toLower(virtualNetworkName)
}

resource networkSecurityGroup_resource 'Microsoft.Network/networkSecurityGroups@2022-07-01' existing = {
  name: toLower(virtualNetworkSubnetNetworkSecurityGroupName)
}

resource nat_resource 'Microsoft.Network/natGateways@2022-07-01' existing = if (!empty(virtualNetworkSubnetNatGatewayName)) {
  name: toLower(virtualNetworkSubnetNatGatewayName)
}

resource virtualNetworkSubnet_resource 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: toLower(virtualNetworkSubnetName)
  parent: virtualNetwork_resource
  properties: {
    addressPrefix: virtualNetworkSubnetAddressPrefix
    delegations: empty(virtualNetworkSubnetDelegations) ? null : virtualNetworkSubnetDelegations
    natGateway: empty(virtualNetworkSubnetNatGatewayName) ? null : { id: nat_resource.id }
    networkSecurityGroup: {
      id: networkSecurityGroup_resource.id
    }
    serviceEndpoints: empty(virtualNetworkSubnetServiceEndpoints) ? null : virtualNetworkSubnetServiceEndpoints
  }
}

output virtualNetworkSubnetId string = virtualNetworkSubnet_resource.id
