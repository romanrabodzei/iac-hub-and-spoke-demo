/*
.Synopsis
    Bicep template for Storage Account. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/storageAccounts?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param storageAccountName string
param storageAccountKind string = 'StorageV2'
param storageAccountType string = 'Standard_RAGZRS'
param storageAccountAccessTier string = 'Cool'

/// tags
param tags object

/// resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountType
  }
  kind: storageAccountKind
  properties: {
    accessTier: storageAccountAccessTier
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowCrossTenantReplication: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    isHnsEnabled: false
    isLocalUserEnabled: false
    isNfsV3Enabled: false
    isSftpEnabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 90
    }
    largeFileSharesState: 'Disabled'
    publicNetworkAccess: 'Enabled'

  }
}
