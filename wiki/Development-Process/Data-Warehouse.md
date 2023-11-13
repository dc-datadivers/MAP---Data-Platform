[[_TOC_]]

#Introduction

The data warehouse database is set up to use source control via the DEV instance using a Visual Studio solution. This enables tracking of all changes made to the database and a secure backup of all the code.

See the repo [MMG_DW](https://dev.azure.com/data-divers/Open%20Water%20Cloud/_git/MMG_DW) for an example of what a Visual Studio solution looks like. Use [Visual Studio Community](https://visualstudio.microsoft.com/vs/community/) (or any other edition if available) to create and maintain the solution.

#CI/CD process flow

The following diagram represents the end-to-end process. Any time a merge to the main branch is done, a build is triggered automatically, and the code will automatically deploy to TEST. The PROD deployment requires one authoriser to approve the release before it is migrated to Production.

![image.png](/.attachments/image-aff92b6a-9258-4e0b-abf1-2208b8b0cffe.png)

For information on how to configure the CI/CD pipelines refer to [08 Configure CICD pipelines](/Installation/08-Configure-CICD-pipelines).

#Process

The procedure for developing in the data warehouse database is as follows:

**In SSMS**

- Develop in SSMS on the DEV database as you would normally
- Once you are ready to migrate a feature, proceed as follows:

**From Visual Studio:**

- Ensure you have pulled the latest version of the **origin/main** branch
- Create a new local branch for your changes and base it off origin/main
- Run the **SqlSchemaCompareDevToSolution.scmp** schema comparison to compare your local branch with the DEV DW database. Note that as SQL Server authentication is no longer permitted, you will need to authenticate use Microsoft Entra ID authentication. _Do not save your own login name in the Git repository scmp files_.
- Review the changes to the codebase and deselect any changes that you do not want to merge
- Click **Update** to update your local repository
- Click **Compare** to ensure all of the required changes have made it across to the branch
- Build the solution by right clicking on the DW project and selecting **Build**
- Resolve any build errors
- Commit the changes with a meaningful comment
- Push the branch up to DevOps

Once the above steps are complete, switch to use the **DevOps** interface

- Create a pull request
- Review all of the changes to ensure they are correct
- Small changes can then be approved by the developer
- Significant changes should be referred to a peer for approval by adding an approver to the pull request
- Once the changes are reviewed and accepted, approve and close the pull request
- Merge the working branch into main and then delete the working branch (note: this step triggers the build and release to TEST environment)

To complete the cycle, now switch back to **Visual Studio**

- Switch to **main** branch
- Pull the new changes down to your local main branch
- Delete the previously created local working branch

#Preventing a build with a commit message

To prevent a merge to main triggering a build, end your commit message with `***NO_CI***`