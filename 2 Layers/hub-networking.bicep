/*
.Synopsis
    Main deployment template for HUB subscription. Public Connectivity Layer

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
        resourceGroupName: '${variables.customerCode}-rg-networking-${toLower(subscription)}-${variables.shortLocation}-01'
        virtualNetworkName: '${variables.customerCode}-vnet-${toLower(subscription)}-${variables.shortLocation}-01'
        virtualNetworkAddressPrefix: variables['${toLower(subscription)}_config'].virtualNetworkAddressPrefix
        virtualSubnetName: 'AzureBastionSubnet'
        virtualNetworkSubnetPrefix: variables['${toLower(subscription)}_config'].virtualNetworkSubnetPrefix
        networkSecurityGroupName: '${variables.customerCode}-nsg-bastion-${toLower(subscription)}-${variables.shortLocation}-01'
        bastionHost: {
            bastionName: '${variables.customerCode}-bastion-${toLower(subscription)}-${variables.shortLocation}-01'
            publicIPAddressName: '${variables.customerCode}-pip-bastion-${toLower(subscription)}-${variables.shortLocation}-01'
        }
        frontDoor: variables['${toLower(subscription)}_config'].frontDoor
    }
    logAnalyticsWorkspaceResourceGroupName: '${variables.customerCode}-rg-ucr-${toLower(subscription)}-${variables.shortLocation}-01'
    logAnalyticsWorkspaceName: '${variables.customerCode}-law-ucr-${toLower(subscription)}-${variables.shortLocation}-01'
}

/// templates deployment
param bastionTemplate bool = true
param frontdoorTemplate bool = true

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

resource resourceGroup_resource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: toLower(parameters['${toLower(subscription)}_config'].resourceGroupName)
    location: location
    tags: tags
    dependsOn: [
        customerAttribution
    ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  Bastion layer //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module bastion_Template '../3 Templates/bastion_template.bicep' = if (bastionTemplate) {
    scope: resourceGroup_resource
    name: toLower('bastion-template-deployment-${date}')
    params: {
        location: toLower(location)
        subscription: toLower(subscription)
        parameters: parameters
        tags: tags
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  Frontdoor layer //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module frontdoor_Tempalte '../3 Templates/frontdoor_template.bicep' = if (frontdoorTemplate) {
    scope: resourceGroup_resource
    name: toLower('${toLower(subscription)}-fb-template-deployment-${date}')
    params: {
        location: toLower(location)
        subscription: toLower(subscription)
        parameters: parameters
        tags: tags
    }
}
