# Foundry VTT - Bicep and Ansible for Azure Hosting

Provision and configure a self-hosted [Foundry Virtual Table Top](https://foundryvtt.com/) environment.

## Bicep (`bicep/`)

Deployed by GitHub Actions on push to `main` (what-if, then an approval-gated deploy).

Repository secrets used by the workflow:

| Secret | Used for |
| --- | --- |
| `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` | OIDC login |
| `SHUTDOWN_NOTIFICATION_EMAIL` | Auto-shutdown warning email |
| `ACTION_GROUP_RESOURCE_ID` | Action group for the "VM running > 4h" alert |

The last two are read by the param file with `readEnvironmentVariable()`. For a local what-if, export them first.

* Virtual Network/subnet with Network Security Group
* One VM per entry in `environments` (dev, tst, prd), each with a public IP and 64 GB data drive
* Daily auto-shutdown at 01:15 Eastern with a 30-minute warning email
* Log Analytics workspace, Activity Log export and a "VM running > 4h" alert
* Storage account `fndryst` (public blob access off; account key still allowed)
* Optional (`assignStorageRoles`): container-scoped blob roles for each VM's managed identity

## Ansible (`ansible/`)

Run from the `ansible/` folder, e.g. `ansible-playbook caddy.yml --ask-vault-pass`.

* `group_vars/all/vars.yml` - shared paths and settings
* `group_vars/all/vault.yml` - secrets (ansible-vault)
* `group_vars/<dev|tst|prd>.yml` - per-environment settings
* `templates/` - Caddyfile, helper scripts, systemd units
* `new-servers.yml` - full build of a new server; `big-upgrade.yml` - major Foundry version upgrade

Nightly backups run at 00:50 (before the 01:15 auto-shutdown). Compendium artifacts are pushed from
tst only (`~/release`); dev and prd pull them at boot. tst never pulls automatically.

## Runbooks

### Convert disks to Standard SSD (no rebuild)

```bash
az vm deallocate -g foundry-rg -n fndry-prd-vm
az disk update -g foundry-rg -n fndry-prd-vm-osdisk   --sku StandardSSD_LRS
az disk update -g foundry-rg -n fndry-prd-vm-datadisk --sku StandardSSD_LRS
az vm start -g foundry-rg -n fndry-prd-vm
```

Repeat per VM, then set `diskSku = 'StandardSSD_LRS'` in the param file so the what-if shows no change.

### Switch rclone to managed identity

1. Give the pipeline service principal *Role Based Access Control Administrator* on `fndryst`
   (or deploy once yourself), set `assignStorageRoles = true` and deploy.
2. Set `rclone_auth: msi` in `ansible/group_vars/all/vars.yml` and run `rclone.yml`.
3. The storage account key keeps working for local use.

## Archive

`archive/terraform/` holds the original Terraform build. It is not deployed and has no state.

![Foundry dice Image](/images/foundry-dice.png)
