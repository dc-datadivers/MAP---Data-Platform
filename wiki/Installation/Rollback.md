[[_TOC_]]
#Rollback procedure

To rollback a deployment, it is necessary to delete the resources in two batches, then optionally delete the resource group.

##Delete all resources except for Key Vault

Due to the customer managed key feature, all resources except for the Key Vault should be deleted first. Go to the portal, select all resources then deselect the Key Vault. Hit **Delete** in the toolbar.

![image.png](/.attachments/image-bf19353c-b5d2-48a1-a9ed-b82a2c55ee22.png)


## Delete the Key Vault

The Key Vault can now be deleted. Note that if you need to redeploy it, you will need to create a Key Vault with a different name, then if necessary, use the restore function to restore the previously deleted vault. It is no longer possible to purge a deleted key vault due to it holding CMK keys.

## Optionally delete the resource group

The resource group can now be deleted. Note that if you have had a resource group created for you with permissions, do not delete the resource group (you may have to ask for it to be recreated with permissions).