# subscription_id  = "<set via TF_VAR_subscription_id>"
# livekit_api_key / livekit_api_secret = set via TF_VAR_* env vars, never commit them

ssh_source_ips = ["69.249.125.110/32"]

vms = {
  livekit = { size = "Standard_B2ms", hostname = "livekit-01", data_disk_size = 32, livekit = true }
  vtt-prd = { size = "Standard_B2ms", hostname = "foundryvtt-prd-01", data_disk_size = 128 }
  vtt-tst = { size = "Standard_B2ms", hostname = "foundryvtt-tst-01", data_disk_size = 128 }
}
