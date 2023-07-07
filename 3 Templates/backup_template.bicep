/*
.Synopsis
    Main Bicep template for workloads.

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
param parameters object
param subscription string

param tags object

/// resources
module recoveryServicesVault_resource '../4 Modules/recoveryservicesvault.bicep' = {
  name: toLower('recoveryservicesvault-${toLower(subscription)}-${location}')
  params: {
    location: location
    recoveryServicesVaultName: toLower(parameters['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].recoveryServicesVaultName)
    tags: tags
  }
}

module storageAccount_resource '../4 Modules/storageaccount.bicep' = {
  name: toLower('storageaccount-${toLower(subscription)}-${location}')
  params: {
    location: location
    tags: tags
    storageAccountName: toLower(parameters['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].storageAccountName)
  }
}
