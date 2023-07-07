/*
.Synopsis
    Main Bicep template for virtual network and components:
      - vnet

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
module vnet_integration_resource '../4 Modules/virtualnetwork.bicep' = {
  name: toLower('${'${subscription}_landingzoneconfig'}-integration-network-${location}')
  params: {
    location: toLower(location)
    virtualNetworkName: toLower(parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[0].virtualNetworkName)
    virtualNetworkAddressPrefix: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[0].virtualNetworkAddressPrefix
    virtualSubnetName: toLower(parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[0].virtualSubnetName)
    virtualNetworkSubnetPrefix: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[0].virtualNetworkSubnetPrefix
    tags: tags
  }
}

module vnet_backoffice_resource '../4 Modules/virtualnetwork.bicep' = if (toLower(subscription) != 'prod') {
  name: toLower('${'${subscription}_landingzoneconfig'}-ackoffice-network-${location}')
  params: {
    location: toLower(location)
    virtualNetworkName: toLower(parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[1].virtualNetworkName)
    virtualNetworkAddressPrefix: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[1].virtualNetworkAddressPrefix
    virtualSubnetName: toLower(parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[1].virtualSubnetName)
    virtualNetworkSubnetPrefix: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].virtualNetworks[1].virtualNetworkSubnetPrefix
    networkSecurityGroupName: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].networkSecurityGroupNames[3]
    tags: tags
  }
}
