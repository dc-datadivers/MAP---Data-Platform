[[_TOC_]]

#Introduction

Power BI artefacts such as datasets and reports delivered under the implementation project for the data platform should be stored in Azure DevOps source control.


#Workspaces

There are three workspaces in Power BI:

- **Dev** 
- **Test** 
- **Prod** 

#Development process

- If modifying an existing report or dataset, a copy should be taken from source control and used as the basis for development
- Development is then done using the Power BI full client. Note that if database access is required, the developer must be either on the Development SHIR or via the Data Divers Hut
- Once development is complete, the report should be migrated to the Test workspace and given to the users for testing
- Once the users have accepted the changes, the report should be migrated to the Production workspace
- In Azure DevOps, create a new branch
- Replace the reports with the new versions, or add any new reports
- Submit a pull request for the changes and optionally ask someone to review
- Complete the pull request and merge the changes into the main branch (delete the working branch created earlier)