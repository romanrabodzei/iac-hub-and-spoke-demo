/*
.Synopsis
    Main deployment template for Spoke subscription. Networking Layer

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
    hub_config: {
        virtualNetworkSubnetPrefix: variables.hub_config.virtualNetworkSubnetPrefix
    }
    '${toLower(subscription)}_config': {
        '${toLower(subscription)}_landingzoneconfig': {
            resourceGroupName: '${variables.customerCode}-rg-networking-${toLower(subscription)}-${variables.shortLocation}-01'
            virtualNetworks: [
                {
                    virtualNetworkName: '${variables.customerCode}-vnet-integration-${toLower(subscription)}-${variables.shortLocation}-01'
                    virtualNetworkAddressPrefix: variables['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].virtualNetworks[0].virtualNetworkAddressPrefix
                    virtualSubnetName: '${variables.customerCode}-snet-iac-${toLower(subscription)}-${variables.shortLocation}-01'
                    virtualNetworkSubnetPrefix: variables['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].virtualNetworks[0].virtualNetworkSubnetPrefix
                }
                {
                    virtualNetworkName: '${variables.customerCode}-vnet-backoffice-${toLower(subscription)}-${variables.shortLocation}-01'
                    virtualNetworkAddressPrefix: variables['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].virtualNetworks[1].virtualNetworkAddressPrefix
                    virtualSubnetName: '${variables.customerCode}-snet-iac-${toLower(subscription)}-${variables.shortLocation}-01'
                    virtualNetworkSubnetPrefix: variables['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].virtualNetworks[1].virtualNetworkSubnetPrefix
                }
            ]
            natGateway: {
                natGatewayName: '${variables.customerCode}-nat-${toLower(subscription)}-${variables.shortLocation}-01'
                publicIPAddressName: '${variables.customerCode}-nat-pip-${toLower(subscription)}-${variables.shortLocation}-01'
            }
            applicationSecurityGroupName: '${variables.customerCode}-asg-che-${toLower(subscription)}-${variables.shortLocation}-01'
            networkSecurityGroupNames: [
                '${variables.customerCode}-nsg-che-${toLower(subscription)}-${variables.shortLocation}-01'
                '${variables.customerCode}-nsg-fs-${toLower(subscription)}-${variables.shortLocation}-01'
                '${variables.customerCode}-nsg-app-${toLower(subscription)}-${variables.shortLocation}-01'
                '${variables.customerCode}-nsg-iac-${toLower(subscription)}-${variables.shortLocation}-01'
            ]
        }
    }
    logAnalyticsWorkspaceResourceGroupName: '${variables.customerCode}-rg-ucr-${toLower(subscription)}-${variables.shortLocation}-01'
    logAnalyticsWorkspaceName: '${variables.customerCode}-law-ucr-${toLower(subscription)}-${variables.shortLocation}-01'
}

/// templates deployment
param networkingTemplate bool = true

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
            '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json'
            contentVersion: '1.0.0.0'
            resources: []
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Resources groups ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

resource resourceGroup_resource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: toLower(parameters['${toLower(subscription)}_config']['${toLower(subscription)}_landingzoneconfig'].resourceGroupName)
    location: location
    tags: tags
    dependsOn: [
        customerAttribution
    ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  Outbound Conectivity layer //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module outboundConnectivity_Template '../3 Templates/outboundconnectivity_template.bicep' = if (networkingTemplate) {
    scope: resourceGroup_resource
    name: toLower('outboundconnectivity-template-deployment-${date}')
    params: {
        location: toLower(location)
        subscription: toLower(subscription)
        parameters: parameters
        tags: tags
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  NSG layer //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module nsg_Template '../3 Templates/nsg_template.bicep' = if (networkingTemplate) {
    scope: resourceGroup_resource
    name: toLower('nsg-template-deployment-${date}')
    params: {
        location: toLower(location)
        subscription: toLower(subscription)
        parameters: parameters
        tags: tags
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  Networking layer //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module networking_Template '../3 Templates/networking_template.bicep' = if (networkingTemplate) {
    scope: resourceGroup_resource
    name: toLower('networking-template-deployment-${date}')
    params: {
        location: toLower(location)
        subscription: toLower(subscription)
        parameters: parameters
        tags: tags
    }
    dependsOn: [
        outboundConnectivity_Template
        nsg_Template
    ]
}
