## Tags
project-tag                     = "use-infrastructure-core"

# Azure region prefix mapping
# US East        - use  01
# US West        - usw  02
# Central Canada - cca  03
# UK South       - uks  04
# Japan East     - jpe  05
# Western Eurpoe - euw  06
# Hong Kong      - hk   07
azure-resource-name             = "use-prd-co"
azure-resource-name-nospace     = "useprdco"
azure-resource-name-stg         = "use-stg-co"
azure-resource-name-stg-nospace = "usestgco"

server-hostname                 = "01prdco"

## Azure region (location) mapping
## eastus
## westus
## uksouth
## westeurope
## canadacentral
## japaneast
## eastasia
location                        = "eastus"

## use subnet IDs
dc-snet                         = "/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-rg/providers/Microsoft.Network/virtualNetworks/use-prd-co-net-hub-vnet/subnets/use-prd-co-net-hub-dc-snet"
utility-snet                    = "/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-rg/providers/Microsoft.Network/virtualNetworks/use-prd-co-net-hub-vnet/subnets/use-prd-co-net-hub-utility-snet"
jb-snet                         = "/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-rg/providers/Microsoft.Network/virtualNetworks/use-prd-co-net-hub-vnet/subnets/use-prd-co-net-hub-jb-snet"
vpn-snet                         = "/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-rg/providers/Microsoft.Network/virtualNetworks/use-prd-co-net-hub-vnet/subnets/use-prd-co-net-hub-vpn-snet"

key-vault-id                    = "/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-rg/providers/Microsoft.KeyVault/vaults/use-prd-co-net-hub-kv"

vm-size                         = "Standard_B2ms"
al-vm-size                      = "Standard_F4s_v2"
vm-admin                        = "gatewayadmin"
data-disk-size                  = "32"

sql-vm-size                     = "Standard_B2ms"
sql-data-disk-size              = "1024"

## Time Zones
## Eastern Standard Time
## Pacific Standard Time
## GMT Standard Time
## Tokyo Standard Time

time-zone                       = "Eastern Standard Time"

## VM User Managed Identity
vm-managed-identity             = "/subscriptions/12b725ed-bf43-48cc-89a0-902622097dcf/resourceGroups/use-prd-co-net-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/use-prd-co-net-vm-id"

## Log Analytics
mmagent-workspaceid             = "698b36fc-9031-4b01-8432-6ce5ee43446a"
mmagent-workspacekey            = "eKSvBOqpNtwpgAAYVAf8qvnpVveNmJ1WtauTY+L4mJhbOYxtfZykoqTtnU+XdWCxl/ouMHVQWmYBIuLZfSGGnA=="

#####################################################################
############################# 3rd party #############################
#####################################################################
logicmonitor-company            = "gatewayticketing"

# Logic Monitor Collector IDs
# US East        - 117
# US West        - 121
# Central Canada - 119
# UK South       - 120
# Japan East     - 118
logicmonitor-collector-id       = "117"