# Facility Analysis

Scripts to analyze the facilities database as described herein.  Also see
comments in the individual script files which might provide additional details.

## Folders

They contain CSV lists of issues as described in the folder and file names.

## `DENA_Trail_Asset_Analysis.sql`

Queries for comparing GIS to FMSS for the trail side features in Denali.

## `FMSS-GIS_Check_and_Fix.sql`

These queries summarize the data imported from the FMSS databases and compare
it to data in our enterprise GIS databases. These queries were developed and
used during the development of our `facilities2` SDE database. Some of the
queries can be used to correct *broken* data in the GIS database.

## `FMSS-GIS_Domain_Comparison.sql`

Queries to identify the range of selected domains in FMSS, and compare with
the range of values in the GIS domains.  Queries are not complete.

## `FMSS-GIS_Location_Comparison.sql`

Queries to compare the location of the GIS feature with the primary lat/long
stored in FMSS.  This query was run in late 2019 and provided to Scott V.
who used it to do a bulk update of FMSS.  There is no mechanism in place to
update FMSS as GIS locations are improved or as new features are added, so
these queries may need to be run again in the future to once again update
FMSS.

## `FMSS-GIS_Quantity_Comparison.sql`

These queries identify roads, trails and parking lots that have a different
length (or area) in FMSS compared to the calculated value in GIS.  It is
expected that there may be some round off differences, but large differences
should be investigated as they identify and error in FMSS and/or GIS.

## `Finding_Unconnected_Trail_Segments.sql`

Queries to help find trail segments that should be connected, but are not.
Often it can be tricky to find the spot where trail segments almost, but don't
quite, connect.  These queries start with a trail `FEATUREID` for a trail that
should be connected but is not (from the standard QC queries in the Faciity
Editing folder).  All known issues of this problem have been resolved. New
problems should be easier to identify.

## `Missing_Photos.sql`

A query to selects buildings in FMSS that have less than one photo, and those
for which the photos are older than 10 years.

## `Photo_ForeignKey_Errors.sql`

A set of queries to help identify errors in the foreign key for photos (the
attributes that link the photos to a spatial feature).  See the
[Attachments](../Attachments.md) document for a discussion of how AKR is
using the attributes of the standard attachments table as foreign keys.

## `Trail Status Issues.sql`

Queries to show the count of trails by status, existence and type.

## `Whats Missing.sql`

Queries to print the count of the various asset types in FMSS by type (Salvage
or operating), and status.  As well as queries to show how many of the
operating features have a matching feature in GIS.
