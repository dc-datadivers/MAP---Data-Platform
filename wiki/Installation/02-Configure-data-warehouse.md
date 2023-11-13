[[_TOC_]]


# Deploy control schema and samples

Using SSMS (or some other DB client), log into the DW database using the credentials defined under **Microsoft Entra ID Admin** on the Azure SQL Server. You will need to use the **Azure Active Directory - Universal with MFA** sign in option. Make sure to enter **DW** as the database name under the **Options** page of the dialog.

![image.png](/.attachments/image-a07dc31c-67fb-48c1-8959-c337226572d6.png)

**Options** screen

![image.png](/.attachments/image-7f3ce3ed-5a62-4e80-a744-82b3fa5b7b1f.png)

Run the scripts in the **\dw** directory in sequence to deploy the control database tables and samples.

Note that for higher environments such as TEST and PROD, CI/CD pipelines are used to deploy the database code. These environments do however need some initial setup done as per the scripts.