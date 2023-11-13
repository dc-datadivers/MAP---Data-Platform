[[_TOC_]]

# Introduction

The data warehouse is partitioned into several schemas based on function as per below.



![image.png](/.attachments/image-1ce5e10a-84d1-4f14-9060-6056daaa7a14.png)

# CTL 

This schema contains the metadata framework and logging tables used to operate the data factory.

# STG

This schema is used for temporary storage of delta data sets or for staging complex logic prior to loading the IDW.

# SRC

This contains the latest view of all source data as it was received from the source system with no transformations. The format of the table name is SYSTEM_SCHEMA_TABLENAME with the SCHEMA component being optional.

# NRM

Optional normalised model.

# IDW

This is the integrated data warehouse that stores the star schemas used in reporting.

# PBI

This schema is made up of views that Power BI utilises in its data models. All Power BI access should be via this schema.