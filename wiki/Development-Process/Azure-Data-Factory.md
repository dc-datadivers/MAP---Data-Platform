[[_TOC_]]

#Introduction

Data Factory is configured to use source control in the DEV instance. This enables tracking of all changes made to the data factory and a secure backup of all the code.

For detailed information on using Data Factory with Git, refer to this document:

https://docs.microsoft.com/en-us/azure/data-factory/source-control#version-control

#CI/CD process flow

The following diagram represents the end-to-end process. Any time a merge to the main branch is done, a build is triggered automatically, and the code will automatically deploy to TEST. The PROD deployment requires one authoriser to approve the release before it is migrated to Production.

![image.png](/.attachments/image-9d6d5bee-a4d6-4b9d-b93b-beee43898dc2.png)

For information on how to configure the CI/CD pipelines refer to [08 Configure CICD pipelines](/Installation/08-Configure-CICD-pipelines).

#Process

The procedure for developing in Data Factory is as follows:

1. In the **DEV** instance of Data Factory create a new branch for your work.

2. Make the required changes in your branch. Note that when you click the **Save** button, all of your changes are saved to Git in your branch.

3. Use the **Debug** functionality to test your changes. Doing a debug run executes all of the required code in your pipeline without first publishing it to the main runtime data factory.

4. Once you have tested your work, create a pull request.

5. Azure DevOps will open. Click **Create**. 

6. If you need to review the code you can do so in the resulting screen.

7. Click **Approve** then **Complete**. Note that if you have processes for code review you should get someone else to review the changes.

8. Merge the changes you made back into the main branch. Note that this step triggers the CI/CD build and release to TEST.

9. Go back to Data Factory and change back to the **main** branch.

10. Click **Publish**. _You must do this to align the code in the adf_collaboration branch with the runtime code of the data factory_.

11. Click **OK** and your changes will be published into the DEV runtime.

12. Integration testing then should be done in TEST. Once the users are happy with the changes, then the PROD deployment should be authorised by any one of the authorisers listed in the CI/CD pipeline.

#Preventing a build with a commit message

To prevent a merge to main triggering a build, end your commit message with `***NO_CI***`
