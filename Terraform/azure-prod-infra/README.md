# Overview
This project builds a production-grade Azure networking foundation using Terraform.
It follows a Hub-and-Spoke topology, where the Hub hosts shared services (Firewall, Bastion, Log Analytics Workspace) and multiple Spokes host application, database, and batch workloads.

The design follows enterprise best practices for:
•	Network isolation & segmentation
•	Centralized firewalling and logging
•	Role separation (infrastructure vs. apps)
•	Terraform modularity for reusability


## Architecture
•	Hub VNet
•	Subnets: GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet, Management, Shared, Data
•	Azure Firewall (with diagnostic logging to LAW)
•	Bastion host for secure management access
•	Log Analytics Workspace (centralized logging/monitoring)
•	Spoke VNets
•	Spoke 1: App + DB subnets with NSG rules
•	Spoke 2: Web subnet (public HTTP/HTTPS)
•	Spoke 3: Batch subnet (no inbound internet)
•	NSGs per subnet with least-privilege rules:
•	Allow intra-VNet traffic where needed
•	Explicit denies for Internet traffic where required
•	Application- and DB-tier isolation
•	Diagnostics
•	Firewall logs, NSG flow logs, and Bastion diagnostics sent to Log Analytics Workspace


## Project Structure
.
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── resource-group/
│   ├── vnet-hub/
│   ├── vnet-peering/
│   ├── vnet-spoke/
│   ├── nsg/
│   ├── network-watcher/
│   ├── firewall/
│   ├── bastion/
│   └── LAW/


## Outputs
On successful deployment, Terraform outputs:
•	Resource Group name
•	Hub VNet ID
•	Subnet IDs (including Firewall/Bastion)
•	Firewall ID & Public IP
•	Bastion ID
•	Log Analytics Workspace ID


## Notes
•	No VMs are deployed — focus is on network & security infrastructure.
•	Proof of operation is available via Terraform outputs and portal inspection.
•	Can be extended with VMs, AKS, or App Services if needed.
