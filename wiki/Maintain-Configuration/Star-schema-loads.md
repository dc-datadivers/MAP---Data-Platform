[[_TOC_]]

#Star schema configuration

All configuration for star schema orchestration is in **CTL.StarConfig**

Related tables are grouped together by **Group**. Within each Group, the **ProcType** splits out into **Staging**, **Dimension** and **Fact**.

Within each ProcType there is a **Sequence**. It is possible to orchestrate the loading of a set of star schemas in the order Staging, Dimension then Fact. Each procedure within these groupings are configured to be called in the desired order, set by Sequence.

#Star schema pipelines
##PL_ProcessStarSchemas

This pipeline works in a similar way to the Source pipelines in that it loops through a series of objects to load. It does this for a particular Group and ProcType (Staging, Dimension or Fact).

Note that parallelism is not enabled, procs will run in sequence.

This pipeline should not be scheduled directly, it is called by **Star Schema Master** (see below).

##PL_StarSchemaMaster

This pipeline orchestrates the loading of Staging tables, then Dimensions, then Facts for a Group.

