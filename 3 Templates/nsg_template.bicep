/*
.Synopsis
    Main Bicep template for virtual network and components:
      - nsg

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
module nsg_iac_resource '../4 Modules/nsg.bicep' = {
  name: toLower('${'${subscription}_landingzoneconfig'}-iac-nsg-${location}')
  params: {
    location: location
    application: 'iac'
    networkSecurityGroupName:  parameters['${subscription}_config']['${subscription}_landingzoneconfig'].networkSecurityGroupNames[3]
    logAnalyticsWorkspaceResourceGroupName: parameters.logAnalyticsWorkspaceResourceGroupName
    logAnalyticsWorkspaceName: parameters.logAnalyticsWorkspaceName
    tags: tags
  }
}
