# Foundry VTT - Terraform and Ansible for Azure Hosting

Provision artifacts used to self-host a Foundry Virtual Table Top environment:

* Virtual Network
* Subnet(s) with Network Security Group
* Foundry Production Virtual Machine with public IP
* Foundry Testing Virtual Machine with public IP
* LiveKit Virtual Machine with public IP
* 128 GB data drive
* Storage account

I have rclone configured on the server. There's a cron job that stops the Foundry service and synchs the
Foundry code and user data to an Azure storage account nightly.

About [Foundry](https://foundryvtt.com/)

