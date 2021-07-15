# Enterprise Database QC Tools

This repository contains tools and instructions for maintaining the integrity
of the Alaska Region's enterprise geospatial databases. These are esri
geodatabases within the Spatial Database Engine (SDE).

## Contents

The contents of this repository are described below.

### Attachments.md

The [Attachments](./Attachments.md) document describes the AKR additions to the
NPS Data Standard for the attachments tables (`AKR_ATTACH` and `AKR_ATTACH_PT`)
in the facilities database.

### Facility Migration

This folder contains documentation and SQL scripts for migrating Alaska's
buildings in the old (circa 2008) national data standard to the newer (circa
2016) national data standard.  This folder is obsolete now that the migration
is complete.

### Facility Editing

This folder contains documentation on the editing workflow for the facilities
database, as well as tools (SQL scripts) for managing this workflow.  See the
[Readme](./FacilityEditing/Readme.md) for details.

### Facility Analysis

SQL Scripts for manually checking for unusual issues in the facilities database.
These are typically issues that cannot be checked or corrected with the
standard Quality Control tools in the Facility Editing folder.  This folder
also contains some lists of outstanding issues (as CSV files).

### POI Analysis

This folder contains an SQL Script for analyzing the POI database (in `akr_socio`)
before updates in July 2021 to support automated QC, Calculated values, and
synchronizing with source databases.  It also contains a log of all changes made
to `akr_socio` in syncing with `akr_facility2`and cleaning up QC issues.

### POI Editing

A SQL schema file (`*Schema.sql`) to create the views and stored procedures
needed to implement the QC and calculated value in `akr_socio`. The `Do*.sql`
scripts are intended to be run on a version of `akr_socio` before posting
changes to `DEFAULT`.  These files are very similar to the files for facility
editing as described in the  [Facility Editing Readme](./FacilityEditing/Readme.md).
Details on managing the editing, review, posting process is very similar to the
process described in the
 [Facility Editing document](./FacilityEditing/Editing Facilities.md).

### FMSS Export

This folder contains instructions and SQL scripts for exporting data from the
Facility Maintenance and Management System (FMSS) and importing it into our
enterprise datasets.  This allows us to link our GIS data to FMSS and join
the additional attributes in FMSS to our spatial features.

## Build

There is nothing to build to use these tools.

## Deploy

These tools do not need to be deployed.  Just clone this repository
to a local file system.

## Use

### Python

Before executing a python script, open it in a text editor and check any
path or file names in the script that should be edited to reflect the
file system where the script and data are deployed.  The script can then
be run in a CMD/Powershell window, with the
[IDLE](https://en.wikipedia.org/wiki/IDLE) application,
with the
[Python extension to VS Code](https://code.visualstudio.com/docs/languages/python),
or any other Python execution environment.

### SQL Scripts

1) Open the script file in SQL Server Management Studio
([SSMS](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15)),
or [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15).
2) Connect to the appropriate server and database.
3) Select the statement you want to run and click `Run` in the toolbar.
   When applicable, see the comments in the file, you can run all the SQL
   commands in the file sequentially by clicking `Run` when nothing is selected.
