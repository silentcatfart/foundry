# Foundry VTT - Terraform and Ansible for Azure Hosting

Provision artifacts used to self-host a Foundry Virtual Table Top environment:

* Virtual Network/subnet with Network Security Group
* Foundry Production Virtual Machine
* Foundry Testing Virtual Machine
* LiveKit Virtual Machine
* 128 GB data drives
* Storage account

I have rclone configured on the server. There's a cron job that stops the Foundry service and syncs the Foundry code and user data to an Azure storage account nightly.

About [Foundry](https://foundryvtt.com/)

