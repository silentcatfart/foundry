# Foundry VTT - Bicep and Ansible for Azure Hosting

Provision and configure a self-hosted [Foundry Virtual Table Top](https://foundryvtt.com/) environment on Azure.

| Server | Purpose | Hostname |
| --- | --- | --- |
| dev | Testing new Foundry versions (beta channel) | `dev.foundry.silentcatfart.com` |
| tst | Building compendiums; the only server that publishes artifacts | `tst.foundry.silentcatfart.com` |
| prd | Running games | `prd.foundry.silentcatfart.com` |

## Bicep (`bicep/`)

Deployed by GitHub Actions on push to `main` when `bicep/` or `.github/workflows/` changes
(README and Ansible changes don't trigger it). The what-if job writes its result to the run summary;
the deploy job waits for approval on the `prod` environment.

What it manages, all in `foundry-rg`:

* VNet/subnet and NSG: inbound SSH from `myPublicIPv4` only, 80/443 from the Internet (Caddy).
  Foundry's own port 30000 is **not** exposed, so Caddy's GM-only PDF password can't be bypassed.
* One VM per entry in `environments` (dev, tst, prd): public IP, NIC, Standard SSD OS + 64 GB data disk,
  system-assigned managed identity
* Daily auto-shutdown at 01:15 Eastern with a 30-minute warning email
* Storage account `fndryst`: public blob access off, account key still allowed (for local use),
  7-day blob and container soft delete
* Container-scoped blob roles for each VM identity (see [Storage access](#storage-access))
* Log Analytics workspace, Activity Log export and a "VM running > 4h" alert

Repository secrets used by the workflow:

| Secret | Used for |
| --- | --- |
| `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` | OIDC login (`github-workload-identity`) |
| `SHUTDOWN_NOTIFICATION_EMAIL` | Auto-shutdown warning email |
| `ACTION_GROUP_RESOURCE_ID` | Action group for the "VM running > 4h" alert |

The last two are read by the param file with `readEnvironmentVariable()`. For a local what-if, export them first:

```bash
export SHUTDOWN_NOTIFICATION_EMAIL=... ACTION_GROUP_RESOURCE_ID=...
az deployment sub what-if -l eastus2 \
  --template-file bicep/deploy/foundry.bicep \
  --parameters bicep/deploy/foundry.parameters.bicepparam
```

The pipeline identity is Contributor on the subscription, plus *Role Based Access Control Administrator*
on `fndryst` with a condition that only allows assigning Storage Blob Data Reader/Contributor.

## Storage access

VMs reach blob storage with their managed identity (`use_msi = true` in rclone; official rclone build,
since Ubuntu 22.04's package is too old). No storage key is stored on the servers.

| Server | `artifacts` | `silentcatfarts-shared-assets` | Own backup container |
| --- | --- | --- | --- |
| dev | read | - | `dev` (write) |
| tst | write | write | `tst` (write) |
| prd | read | - | `prd` (write) |

So only tst can publish compendium content; dev and prd get 403 if they try.

## Ansible (`ansible/`)

Run from the `ansible/` folder. The inventory is set in `ansible.cfg`.

```bash
ansible-playbook caddy.yml --vault-password-file ~/.vault-pass          # or --ask-vault-pass
ansible-playbook caddy.yml --check --diff --limit tst.foundry.silentcatfart.com ...   # dry run first
```

* `group_vars/all/vars.yml` - shared paths and settings (`rclone_auth: msi`)
* `group_vars/all/vault.yml` - secrets (ansible-vault)
* `group_vars/<dev|tst|prd>.yml` - per-environment settings
* `templates/` - Caddyfile, helper scripts, systemd units
* `new-servers.yml` - full build of a new server; `big-upgrade.yml` - major Foundry version upgrade

### Backups and compendium flow

* **Backups:** `~/backup` runs nightly at 00:50 (before the 01:15 auto-shutdown) on every server.
  It stops Foundry, syncs the Foundry drive to that server's container (excluding `artifacts` and
  `age-shared`), and starts Foundry again. Output goes to `~/backup.log`. A VM that is already off at
  00:50 skips that night.
* **Publish (tst only):** `~/release` pushes the shared-assets module and `artifacts` to blob storage.
* **Pull (dev and prd):** `rclone-az-compendium-to-local.service` pulls `artifacts` at every boot
  (log: `~/rclone-az.log`). tst never pulls automatically; this is enforced in the playbooks.
* **New tst server:** `~/compendium-content-refresh-one-time` pulls `artifacts` once, and refuses to run
  if the local folder isn't empty.
* `check-artifacts.yml` reports whether each server's `artifacts` matches blob storage.

## Runbooks

### Restore something a sync deleted or overwrote

Blob and container soft delete keep deleted data for 7 days. In the portal: Storage account `fndryst`
> Containers > the container > *Show deleted blobs* > Undelete.

### Change disk SKU (no rebuild)

Disks are Standard SSD (converted 2026-11-07). To change SKU again, with the VM deallocated:

```bash
az vm deallocate -g foundry-rg -n fndry-prd-vm
az disk update -g foundry-rg -n fndry-prd-vm-osdisk   --sku <SKU>
az disk update -g foundry-rg -n fndry-prd-vm-datadisk --sku <SKU>
```

Then set `diskSku` in the param file to match so the what-if shows no change.

### Give a server access to another container

Add a `{ container, access }` entry to that server's `storageGrants` in
`bicep/deploy/foundry.parameters.bicepparam` and deploy.

### Fall back to the storage key

Set `rclone_auth: key` in `ansible/group_vars/all/vars.yml` and run `rclone.yml`. (The config is only
rewritten automatically in `msi` mode, so delete `~/.config/rclone/rclone.conf` on the server first.)

## Archive

`archive/terraform/` holds the original Terraform build. It is not deployed and has no state.

![Foundry dice Image](/images/foundry-dice.png)
