[[_TOC_]]

# Monitor the production platform

Note that access to the platform must be done as per policy. The data plane may require you to be on the client's VPN or internal network (e.g., to access storage account data, key vault secrets or database). Control plane access (the portal) can be via any Internet connected machine.

The primary issue that can happen with the data loads is a pipeline failure of some sort. If a pipeline fails, an alert email will be sent to members of the Production Action Group

## Action to take on receipt of an alert email

Review the ADF Monitor page and look for the error message by clicking on the small bubble next to the Failed icon. There could be many different types of errors, such as network related errors, logic issues in processing such as duplicate data, or anything else.

![image.png](/.attachments/image-76e001cf-8754-4234-9f1a-4f2500326075.png)

Another way of viewing errors is in the logging tables from the control database:


```
SELECT *
FROM CTL.vwSourceLog
WHERE 1=1
AND BatchLogID = ( SELECT MAX(BatchLogID) FROM CTL.vwSourceLog ) --filter for latest run
AND SourceStatus = 'Failed' --failures only
```

_The support model for Data Divers should be invoked for any errors that cannot be resolved in-house._

##Rerunning the daily load

The daily load can be rerun in its entirety without any duplication of data. To rerun the entire load, trigger the PL_Daily_Load pipeline. A rerun will ensure all dependencies and parameters are taken care of.

![image.png](/.attachments/image-a85c0cf6-ab9a-431e-9dec-e408f15e868e.png)

It is possible to rerun failed components in isolation, however care must be taken to ensure that the sub-pipelines are rerun with the same parameters. One way of checking the parameters for a sub-pipeline is via the monitor page. There are also dependencies to consider as other elements may also need to be rerun in the correct sequence.

![image.png](/.attachments/image-5c2296b9-938e-4fe9-88fe-681456d49de2.png)



# How to set up an Azure Data Factory monitor alert

Data factory pipelines can be monitored and an automated email sent out on failure. The email is generic, however it will alert an operator who can then check the cause, either via the ADF monitor page or using reports built off the logging tables.

Emails are sent to members of an action group. An action group is created as a part of the deployment. To configure an alert:

1. Select the Data Factory in the Azure Portal and choose **Alerts** from the menu. 
1. Select **New Alert Rule**
1. Choose the **Failed pipeline runs metrics** signal
1. Change the **Threshold** value to 1 and click Done
1. Add the Action Group by clicking **Add action groups** then click the checkbox then **Select**
1. Under **Alert rule details**, give the alert rule a name and optionally a description
1. Click **Create alert rule**



