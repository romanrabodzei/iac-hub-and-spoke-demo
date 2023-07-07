/*
.Synopsis
    Main Bicep template for virtual network and components:
      - public ip 
      - nsg
      - bastion host

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707

           _
       .__(.)<  (MEOW)
        \___)
~~~~~~~~~~~~~~~~~~~~~~~~
*/

/// deploymentScope
targetScope = 'resourceGroup'

/// parameters and variables
param location string
param subscription string
param parameters object

/// tags
param tags object

/// resources
module hub_virtualNetwork_resource '../4 Modules/virtualnetwork.bicep' = {
  name: toLower('hub-network-${location}')
  params: {
    location: toLower(location)
    virtualNetworkName: parameters['${subscription}_config'].virtualNetworkName
    virtualNetworkAddressPrefix: parameters['${subscription}_config'].virtualNetworkAddressPrefix
    virtualSubnetName: parameters['${subscription}_config'].virtualSubnetName
    virtualNetworkSubnetPrefix: parameters['${subscription}_config'].virtualNetworkSubnetPrefix
    networkSecurityGroupName: parameters['${subscription}_config'].networkSecurityGroupName
    tags: tags
  }
  dependsOn: [
    hub_bastion_nsg_resource
  ]
}
module hub_bastion_nsg_resource '../4 Modules/nsg.bicep' = {
  name: toLower('hub-bastion-nsg')
  params: {
    location: location
    application: 'bastion'
    networkSecurityGroupName:  parameters['${subscription}_config'].networkSecurityGroupName
    logAnalyticsWorkspaceResourceGroupName: parameters.logAnalyticsWorkspaceResourceGroupName
    logAnalyticsWorkspaceName: parameters.logAnalyticsWorkspaceName
    tags: tags
  }
}

module hub_bastion_publicIp_resource '../4 Modules/publicipaddress.bicep' = {
  name: toLower('hub-bastion-pip-${location}')
  params: {
    location: toLower(location)
    publicIPAddressName: parameters['${subscription}_config'].bastionHost.publicIPAddressName
    tags: tags
  }
}

module hub_bastion_resource '../4 Modules/bastion.bicep' = {
  name: toLower('hub-bastion-${location}')
  params: {
    location: toLower(location)
    bastionName: parameters['${subscription}_config'].bastionHost.bastionName
    publicIPAddressName: parameters['${subscription}_config'].bastionHost.publicIPAddressName
    virtualNetworkName: parameters['${subscription}_config'].virtualNetworkName
    tags: tags
  }
  dependsOn: [
    hub_virtualNetwork_resource
    hub_bastion_publicIp_resource
  ]
}
