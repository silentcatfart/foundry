project-tag                     = "Foundry VTT"
azure-resource-name             = "foundry"
azure-resource-name-nospace     = "fndry"

## LiveKit
vm-01-size                      = "Standard_B2ms"
vm-01-hostname                  = "livekit"
vm-01-data-disk-size            = "32"

## Production
vm-02-size                      = "Standard_B2ms"
vm-02-hostname                  = "foundryvtt-prd"
vm-02-data-disk-size            = "128"

## Test
vm-03-size                      = "Standard_B2ms"
vm-03-hostname                  = "foundryvtt-tst"
vm-03-data-disk-size            = "128"

location                        = "eastus2"

vm-admin                        = "foundry"
time-zone                       = "Eastern Standard Time"

my-public-ip                    = "71.230.53.86"
vnet-cidr                       = "10.250.0.0/24"
snet-0-cidr                     = "10.250.0.0/24"

cloudflare-cidr                 = ["173.245.48.0/20",
                                   "103.21.244.0/22",
                                   "103.22.200.0/22",
                                   "103.31.4.0/22",
                                   "141.101.64.0/18",
                                   "108.162.192.0/18",
                                   "190.93.240.0/20",
                                   "188.114.96.0/20",
                                   "197.234.240.0/22",
                                   "198.41.128.0/17",
                                   "162.158.0.0/15",
                                   "172.64.0.0/13",
                                   "131.0.72.0/22",
                                   "104.16.0.0/13",
                                   "104.24.0.0/14"]
