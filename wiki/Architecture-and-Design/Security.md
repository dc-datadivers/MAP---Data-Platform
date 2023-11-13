[[_TOC_]]

#Security overview

Open Water Cloud has security features built into the design and configuration. Depending on the client site, not all features might be implemented. It is important to discuss these features with each client so that they are aware of the level of hardening that is available and can decide their configuration accordingly.

# Networking

## Base networking
- Firewalls at the resource level have been implemented to restrict public access to specific IPs
- All resources are deployed within a virtual network to more easily enable fully private networking and to allow communication with Databricks
- Databricks is deployed with no public IP (requires a virtual network)

## Fully private networking

Feature under development (Nov 2023)

The following features are under development:
- Disable public access
- Enable private endpoints
- Add Data Gateway VM to allow access from Power BI tenant
- Add point to site VPN to allow developer access to the virtual network

# Key vault

- The key vault is configured using RBAC for secret and key permissions
- The key vault is set to be non-purgeable to prevent the loss of encryption keys
- Soft delete has been enabled to prevent the loss of secrets
- Auditing has been configured to record all secret and key access, modifications to values etc.


# Customer managed key encryption

CMK encryption has been enabled on the following resources:
- Data factory
- Storage accounts
- Azure SQL database
- Databricks

This feature prevents a holder of a Microsoft managed key from decrypting client data.

# Resource-to-resource authentication

- All resource-to-resource authentication is set to use system assigned managed identities where possible
- If this is not possible, service principals are used instead
- Clients may wish to use user assigned managed identities. Currently, this method will need to be configured manually.

# Storage accounts

- Blob public access has been disabled
- Storage account key access has been disabled
- All authentication must be using Microsoft Entra Id authentication for users, and system assigned managed identity for resources
- TLS 1.2 as a minimum is required

# Database

- SQL Authentication has been disabled. All authentication must be using Microsoft Entra Id authentication for users, and System Assigned Managed Identity for resources.
- Power BI service access for dataset refreshes should use a service account held in Microsoft Entra Id
- Auditing has been configured to record all access to the database, including details of queries, users etc.

# Resource locks

- Delete locks are placed on key resource groups such as in Production, to prevent accidental or malicious deletion of critical resources.

# Monitoring and alerting

- Subscription level diagnostics have been configured to log high level operations to audit storage
- Alerts have been configured for when key aspects of the Azure environment are changed. Alerts are sent to Azure admins for the platform.

```
Create / Delete Policy Assignment
Create / Update / Delete NSGs
Create / Update / Delete Security Solution
Create / Update / Delete SQL Server Firewall Rule
Create / Update / Delete Update Public IP Address Rule
```














