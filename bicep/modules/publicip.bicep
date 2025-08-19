param PrefixName string = 'fndry'
param publicIPLocation string
param tagValues object 

resource publicIPAddressdev 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-dev-vm-pip'
  location: publicIPLocation
  tags: tagValues
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddresstst 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-tst-vm-pip'
  location: publicIPLocation
  tags: tagValues
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddressprd 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: '${PrefixName}-prd-vm-pip'
  location: publicIPLocation
  tags: tagValues
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

  // Outputs
  output publicIPAddressdevId string = publicIPAddressdev.id
  output publicIPAddresststId string = publicIPAddresstst.id
  output publicIPAddressprdId string = publicIPAddressprd.id
