/*
.Synopsis
    Main Bicep template for frontdoor

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
module frontdoor_resource '../4 Modules/frontdoor.bicep' = {
  name: toLower('hub-network-${location}')
  params: {
    location: toLower(location)
    frontDoorName: parameters['${subscription}_config'].frontDoor.frontDoorName
    frontDoorPrefix: parameters['${subscription}_config'].frontDoor.frontDoorPrefix
    frontDoorBackendAddress001: parameters['${subscription}_config'].frontDoor.frontDoorBackendAddress001
    frontDoorBackendAddress002: parameters['${subscription}_config'].frontDoor.frontDoorBackendAddress002
    frontDoorBackendServiceName: parameters['${subscription}_config'].frontDoor.frontDoorBackendServiceName
    domain: parameters['${subscription}_config'].customerDomain
    tags: tags
  }
}
