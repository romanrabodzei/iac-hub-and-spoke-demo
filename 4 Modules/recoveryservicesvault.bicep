/*
.Synopsis
    Bicep template for Recovery Services Vault. Template  https://docs.microsoft.com/en-us/azure/templates/Microsoft.RecoveryServices/vaults?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param recoveryServicesVaultName string

/// tags
param tags object

/// resources
resource recoveryServicesVaultName_resource 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  location: toLower(location)
  name: toLower(recoveryServicesVaultName)
  tags: tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}
