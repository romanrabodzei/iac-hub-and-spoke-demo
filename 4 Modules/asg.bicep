/*
.Synopsis
    Bicep template for Application Security Group. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/applicationSecurityGroups?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param applicationSecurityGroupName string

/// tags
param tags object

/// resources
resource applicationSecurityGroup_resource 'Microsoft.Network/applicationSecurityGroups@2022-07-01' = {
  name: toLower(applicationSecurityGroupName)
  location: location
  tags: tags
}
