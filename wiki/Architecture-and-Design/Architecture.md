[[_TOC_]]

#Open Water Cloud architecture

The data platform implementation at <<client name>> follows the standard Open Water Cloud framework developed by Data Divers. This architecture is based on the standard [Microsoft modern data platform architecture](https://learn.microsoft.com/en-au/azure/architecture/solution-ideas/articles/enterprise-data-warehouse), with some simplification and substitution of products.

The architecture is a standard Extract, Load, Transform (ELT) pattern often used in cloud implementations. Source data is ingested into the data lake and data warehouse, where it is then transformed and modelled to present information to the end users.

![image.png](/.attachments/image-69b82018-211d-445c-a359-1cd39a1b4381.png)

