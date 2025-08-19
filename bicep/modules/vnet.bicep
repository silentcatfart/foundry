@description('The prefix name for all resources.')
param PrefixName string = 'fndry'

param virtualNetworkLocation string
param tagValues object 

@description('My public IPv4 address')
param myPublicIPv4 string = '69.249.125.110/32'

//@description('Cloudflare CIDR IPs')
//param cloudflareCIDR array = ['173.245.48.0/20'
//                              '103.21.244.0/22'
//                              '103.22.200.0/22'
//                              '103.31.4.0/22'
//                              '141.101.64.0/18'
//                              '108.162.192.0/18'
//                              '190.93.240.0/20'
//                              '188.114.96.0/20'
//                              '197.234.240.0/22'
//                              '198.41.128.0/17'
//                              '162.158.0.0/15'
//                              '172.64.0.0/13'
//                              '131.0.72.0/22'
//                              '104.16.0.0/13'
//                              '104.24.0.0/14']

@description('The name of the virtual network.')
param virtualNetworkName string = '${PrefixName}-vnet'

@description('The address prefix for the virtual network.')
param virtualNetworkAddressPrefix string = '10.250.0.0/24'

@description('The name of the subnet.')
param subnetName string = '${PrefixName}-subnet'

@description('The address prefix for the subnet.')
param subnetAddressPrefix string = '10.250.0.0/24'


// Virtual Networks

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: virtualNetworkLocation
  tags: tagValues
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
// Subnets    

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

// Network Security Groups

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: '${PrefixName}-nsg'
  location: virtualNetworkLocation
  tags: tagValues
  properties: {
    securityRules: [

//inbound rules

      {
        name: 'Allow-SSH-Inbound'
        properties: {
          description: 'Needed for administering the server'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: myPublicIPv4
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 160
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-Foundry-Inbound'
        properties: {
          description: 'Ports needed to access Foundry'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443', '30000']
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 170
          direction: 'Inbound'
        }
      }
      {  
        name: 'Allow-Livekit-Inbound'
        properties: {
          description: 'Ports needed to access LiveKit'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: ['50000-60000', '443', '80', '7881', '3478']
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 180
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
          description: 'Supercede default deny'
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
//outbound rules            
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
          description: 'Supercede default deny outbound to the Internet'
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

output subnetId  string = vnet.properties.subnets[0].id
