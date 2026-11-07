# Archived: Terraform

**Not deployed. There is no state for this code.** The live environment is managed by the Bicep in
[`../../bicep`](../../bicep) and configured by the Ansible in [`../../ansible`](../../ansible).

This is the original Terraform build (LiveKit spot VM + Foundry prd/tst spot VMs, VNet/NSG, storage
account), kept for reference and refactored so it still validates:

* `azurerm` 4.x and `cloudinit` providers (the deprecated `template` provider is gone)
* VMs, NICs, public IPs and data disks are one `for_each` over `var.vms`
* NSG rules are inline and match the Bicep NSG (no port 30000, LiveKit ports split by protocol)
* LiveKit API key/secret are sensitive variables instead of being hard-coded in cloud-init
* No backend - the old Terraform Cloud workspace is empty

Resource names follow the original Terraform naming, **not** the live Bicep naming (`fndry-*-vm`),
so applying this into `foundry-rg` would create new resources rather than adopt the existing ones.

```bash
terraform init -backend=false
terraform validate
```
