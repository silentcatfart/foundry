using 'foundry.bicep'

param resourceGroupName = 'foundry-rg'

param tagValues = {
  Project: 'Foundry-VTT'
  Environment: 'Production'
  CreatedBy: 'Bicep Template'
}

param PrefixName = 'fndry'
param virtualNetworkLocation = 'eastus2'
param myPublicIPv4 = '69.249.125.110/32'
param virtualNetworkName  = '${PrefixName}-vnet'
param virtualNetworkAddressPrefix = '10.250.0.0/24'
param subnetName = '${PrefixName}-subnet'
param subnetAddressPrefix = '10.250.0.0/24'

param publicIPLocation = 'eastus2'

param vmSize = 'Standard_B1ms'
param dataDiskSizeGB = 64
param adminUsername = 'foundry'
param adminPublicKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCS5iyFyDcG8hAvYwQjEzijmGeJibEEuZ57WfZ0QzivUScWbF0vYtglpiXv9cxlclDGc6J2ehWdOvsg/beR89iN2dUHxQsoBDhkwBeSeuUa8NQCMsm3BdxqNW+R/PQzahGzcOQ0UNsdlj+U57AFnGStaogErR5o5rjhNEF9j4bpugGHIkMQY7SnEVpAPHypmvAb9WMU4uGnO0LqH5kZy3dA2XLsGCtfhlzst7p0MXNkoZqaWMwoXSVvaJjYFqNzfJW2WVkpbSdpa1mfNI/g0R7PT4Pm59HiF7y5Ex7HWczLkqp54LZwMaWR4Km7Brz0V4hidSBXm+eAPSgx0/CX1BmYfGfJ2yifd2EtdIVORY5btNAdstUtD1B6L0SH80hLuvFr9dYHsWFVLkOaeYypr/k0RWOiSFVip4DrKT2nGew194/jD/YIm/GuN97+qukxF7UVpqlJvfEW1wzTl7WwAceuJ90vi7gSvRRdwaSkVjxDLgGhnqSHcnIguTTcLGyuiNKGyW2nibTnTZqCYThYuOpHJ/3nBpPYuO9rjI8nayz7E7BBl3XxBrjzwiuffcMrY0Hwzatsm4W9ALl6lvRyzFOOW7lvc18UJjQ9c7BI5bCO4CGtFAjs0fejdfR9udDkSn1cbhMBi+8kMnPg4b4RKV6bl6P//MlBUhakIA7yUVaZw== aengleman@ASENj893Q13'

param logAnalyticsWorkspaceLocation = 'eastus2'
param logAnalSku = 'PerGB2018'
param actionGroupResourceId = '/subscriptions/0B755FD2-62D3-4D90-B61C-43FC501C75BF/resourceGroups/azureapp-auto-alerts-46cf52-silentcatfart_gmail_com/providers/microsoft.insights/actionGroups/email'
