/*
.Synopsis
    Bicep template for Virtual Machine. Template https://docs.microsoft.com/en-us/azure/templates/Microsoft.Compute/virtualMachines?tabs=bicep#template-format

.NOTES
    Author     : Roman Rabozei
    Version    : 1.0.2300707
*/

/// deployment scope
targetScope = 'resourceGroup'

/// parameters
param location string

param virtualMachineName string
param virtualMachineSize string = 'Standard_B4ms'
param virtualMachineImage string = '2022-datacenter-azure-edition'
@allowed([
  'Standard'
  'TrustedLaunch'
])
param virtualMachineSecurityType string = 'TrustedLaunch'
var virtualMachineSecurityProfile = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: virtualMachineSecurityType
}
param virtualNetworkResourceGroupName string
param virtualNetworkName string
param virtualSubnetName string

/// authentication
param virtualMachineAdminUsername string = 'CoELocalAdmin'
@secure()
param virtualMachineAdminPassword string = newGuid()

/// tags
param tags object

/// resources
resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(virtualNetworkResourceGroupName)
  name: toLower(virtualNetworkName)
  resource subnet 'subnets' existing = {
    name: toLower(virtualSubnetName)
  }
}

resource nic_resource 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: toLower('${virtualMachineName}-nic-01')
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork_resource::subnet.id
          }
        }
      }
    ]
  }
}

resource virtualMachine_resource 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: toLower(virtualMachineName)
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    osProfile: {
      computerName: toLower(virtualMachineName)
      adminUsername: virtualMachineAdminUsername
      adminPassword: virtualMachineAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: virtualMachineImage
        version: 'latest'
      }
      osDisk: {
        name: toLower('${virtualMachineName}-osdisk')
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          name: toLower('${virtualMachineName}-datadisk-01')
          diskSizeGB: 256
          lun: 0
          createOption: 'Empty'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_resource.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    securityProfile: ((virtualMachineSecurityType == 'TrustedLaunch') ? virtualMachineSecurityProfile : null)
  }
}
