/*
.Synopsis
    Main deployment template for Spoke subscription. Backup Layer

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707

           _
       .__(.)<  (MEOW)
        \___)
~~~~~~~~~~~~~~~~~~~~~~~~
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// Deployment scope /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope = 'subscription'

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Parameters and variables ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

param location string = toLower(deployment().location)

var variables = json(loadTextContent('../1 Subscriptions/parameters.json'))

param subscription string

var parameters = {
    '${toLower(subscription)}_config': {
        '${toLower(subscription)}_landingzoneconfig': {
            resourceGroupName: '${variables.customerCode}-rg-infrastructure-${toLower(subscription)}-${variables.shortLocation}-01'
            recoveryServicesVaultName: '${variables.customerCode}-rsv-common-${toLower(subscription)}-${variables.shortLocation}-01'
            storageAccountName: '${variables.customerCode}bckpsa${toLower(subscription)}01'
        }
    }
    logAnalyticsWorkspaceResourceGroupName: '${variables.customerCode}-rg-ucr-${toLower(subscription)}-${variables.shortLocation}-01'
    logAnalyticsWorkspaceName: '${variables.customerCode}-law-ucr-${toLower(subscription)}-${variables.shortLocation}-01'
}

/// templates deployment
param vaultTemplate bool = true

param date string = utcNow('yyyyMMdd')

var tags = {
    ManagedBy: variables.TagManagedBy
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Customer usage attribution ///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

param guid string

resource customerAttribution 'Microsoft.Resources/deployments@2022-09-01' = {
    name: 'pid-${guid}'
    location: location
    properties: {
        mode: 'Incremental'
        template: {
            '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
            contentVersion: '1.0.0.0'
            resources: []
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource backupResourceGroup_resource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: toLower(parameters['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].resourceGroupName)
    location: location
    tags: tags
    dependsOn: [
        customerAttribution
    ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// VAULTS ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module backup_template '../3 Templates/backup_template.bicep' = if (vaultTemplate) {
    scope: backupResourceGroup_resource
    name: toLower('backup-template-deployment-${date}')
    params: {
        location: toLower(location)
        parameters: parameters
        subscription: toLower(subscription)
        tags: tags
    }
}
