[[_TOC_]]


# Introduction

CI/CD pipelines are currently used for the DW and ADF codebases. In the future, CI/CD will also be used for the IAC (infrastructure as code).

# Azure AD access

Application Developer role access is required in Azure AD in order to set up the Azure Resource Manager connections. These use Service Principals in the background, which are objects created in the Azure AD.

# Open Water Cloud environments

A prerequisite for setting up CI/CD is to have a minimum of three Open Water Cloud environments. The code examples assume these environments are called DEV, TEST and PROD.

|MMG Environment| Resource group |
|--|--|
|DEV| Mmgs1auaearg102|
|TEST| MMG-AUE-DAP-RG-TST|
|PROD| Mmgs1auaearg103|

# DevOps environments

Four environments are required in DevOps (these are a different but related concept to the three Open Water Cloud environments).

|DevOps Environment| Purpose |
|--|--|
|ADF-Test| Represents the test data factory environment|
|ADF-Prod| Represents the production data factory environment|
|DW-Test| Represents the test data warehouse database environment|
|DW-Prod| Represents the production data warehouse database environment|

Create these in the Environments tab. Make sure the names are consistent with the examples; if they change then certain parts of the YAML code would need to be updated.

![image.png](/.attachments/image-bdab4258-7f47-438e-915b-79d28bdd7fe0.png)

Both of the Production environments require an approval to be set up to stop the pipeline deploying code to PROD without any testing:

![image.png](/.attachments/image-cd2b98f5-f1f2-4a16-8bbe-d2896b314060.png)


# Configure DW for CI/CD

In the database solution repository, create a directory at the top level called **cicd**.

![image.png](/.attachments/image-da00e498-9527-4950-b666-6cf7ea99fa7d.png)

Copy the two files in the Platform repository **cicd/dw** directory into this directory

![image.png](/.attachments/image-02a5ce05-dbe5-4ac7-9815-2fe1df4df882.png)

Create a new pipeline in DevOps which is based on the **dw-cicd.yml** file

![image.png](/.attachments/image-e908abb7-dcbc-4355-9310-f46ff4778d65.png)

Certain parameters in the YAML file will need to be updated with the required values:

![image.png](/.attachments/image-afa8fcf3-86ce-4de4-b2f5-360ec13e3e42.png)


Make sure the following passwords for **Sqladmin** have been added to the pipeline:

![image.png](/.attachments/image-afacda2b-d0df-4a30-891d-c2dc8721a577.png)

Once the pipeline has been set up, whenever there is a merge to the main branch the deployment will kick off as per [Development Process for Data Warehouse](/Development-Process/Data-Warehouse).


# Configure ADF for CI/CD

Copy the three directories and two files in the Platform repository **cicd/adf** directory to the main branch of the ADF repo:

![image.png](/.attachments/image-b66167b8-f35b-4a31-9ba3-cd8f98dabaff.png)

Make sure the variable files are updated with the correct values:

![image.png](/.attachments/image-58bf9318-3295-425c-b1ce-e8c1f5963631.png)

Update the environments config files in the **environments** folder of the master branch. 

Take the **ARMTemplateParametersForFactory.json** file in the **adf_publish** branch as a base to build the TEST and PROD files. 

This is the base parameter template from the **adf_publish** branch:

![image.png](/.attachments/image-c32a55f7-89d6-4971-8995-80e96d8edd61.png)

This is where the parameter files go. Note that the filenames are different in the main branch.


![image.png](/.attachments/image-4401df92-357c-42b7-912b-e65d27cd1be4.png)



Create a new pipeline in DevOps which is based on the **adf-cicd.yml** file. Certain parameters in the YAML file will need to be updated with the required values:

![image.png](/.attachments/image-42035b3e-692f-4c1e-8e5a-323c0a89f839.png)

Once the pipeline has been set up, whenever there is a merge to the main branch the deployment will kick off as per [Development Process for Azure Data Factory](/Development-Process/Azure-Data-Factory).
