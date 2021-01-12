Enterprise Database QC Tools
============================

This repository contains tools and instructions for maintaining the integrity
of the Alaska Region's enterprise geospatial databases. These are esri 
geodatabases within the Spatial Database Engine (SDE).

The contents of this repository are described below.

## Attachments.md

The [Attachments](./Attachments.md) document describes the AKR additions to the
NPS Data Standard for the attachments tables (`AKR_ATTACH` and `AKR_ATTACH_PT`)
in the facilities database.

## Facility Migration

This folder contains documentation and SQL scripts for migrating Alaska's
buildings in the old (circa 2008) national data standard to the newer (circa
2016) national data standard.  This folder is obsolete now that the migration
is complete.

## Facility Editing

This folder contains documentation on the editing workflow for the facilities
database, as well as tools (SQL scripts) for managing this workflow.  See the
[Readme](./FacilityEditing/Readme.md) for details.

## Facility Analysis

SQL Scripts for manually checking for unusual issues in the facilities database.
These are typically issues that cannot be checked or corrected with the
standard Quality Control tools in the Facility Editing folder.  This folder
also contains some lists of outstanding issues (as CSV files).

## FMSS Export

This folder contains instructions and SQL scripts for exporting data from the
Facility Maintenance and Management System (FMSS) and importing it into our
enterprise datasets.  This allows us to link our GIS data to FMSS and join
the additional attributes in FMSS to our spatial features.
