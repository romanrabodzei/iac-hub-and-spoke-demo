/*
.Synopsis
    Main Bicep template for virtual network and components:
      - nat

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
module natgw_resource '../4 Modules/natgateway.bicep' = {
  name: toLower('${'${subscription}_landingzoneconfig'}-natgw-${location}')
  params: {
    location: toLower(location)
    natGatewayName: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].natGateway.natGatewayName
    publicIPAddressName: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].natGateway.publicIPAddressName
    tags: tags
  }
  dependsOn: [
    natgw_publicIp_resource
  ]
}

module natgw_publicIp_resource '../4 Modules/publicipaddress.bicep' = {
  name: toLower('${'${subscription}_landingzoneconfig'}-natgw-pip-${location}')
  params: {
    location: toLower(location)
    publicIPAddressName: parameters['${subscription}_config']['${subscription}_landingzoneconfig'].natGateway.publicIPAddressName
    tags: tags
  }
}
