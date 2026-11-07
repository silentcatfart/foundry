@description('The prefix name for all resources.')
param PrefixName string

param location string
param tagValues object

@description('Public IPv4 address(es) allowed to SSH in.')
param myPublicIPv4 array

@description('The name of the virtual network.')
param virtualNetworkName string = '${PrefixName}-vnet'

@description('The address prefix for the virtual network.')
param virtualNetworkAddressPrefix string

@description('The name of the subnet.')
param subnetName string = '${PrefixName}-subnet'

@description('The address prefix for the subnet.')
param subnetAddressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${PrefixName}-nsg'
  location: location
  tags: tagValues
  properties: {
    securityRules: [
      // ---- Inbound ----
      {
        name: 'Allow-SSH-Inbound'
        properties: {
          description: 'Needed for administering the server'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefixes: myPublicIPv4
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 160
          direction: 'Inbound'
        }
      }
      {
        // Only Caddy is exposed. Foundry's own port (30000) stays closed so the
        // Caddy basic_auth on the GM-only PDFs can't be bypassed.
        name: 'Allow-Foundry-Inbound'
        properties: {
          description: 'HTTP/HTTPS to Caddy, which reverse-proxies Foundry'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 170
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-Intra-Subnet-Inbound'
        properties: {
          description: 'Allow traffic between VMs within the same subnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: subnetAddressPrefix
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Supercede default allow rules'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      // ---- Outbound ----
      {
        name: 'Allow-Web-Browsing-Outbound'
        properties: {
          description: 'Allow outbound web access to the Internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: subnetAddressPrefix
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Deny-All-Internet-Outbound'
        properties: {
          description: 'Supercede default allow outbound to the Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: subnetAddressPrefix
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 4096
          direction: 'Outbound'
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
