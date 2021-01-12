Updating the Facilities GIS
===========================

_[The master copy of this document can be found at https://github.com/AKROGIS/Enterprise-QC/blob/master/Editing%20Facilities.md]_

The Alaska Region facilities GIS lives in SDE on INPAKROVMAIS
in the akr_acility2 SQL Server database.
Updates are controlled by the regional GIS data manager (DM)
and go through a rigorous quality control (QC) process.
In general the following process is applied:

1) [User edits a new version](./Editing%20Facilities.md#user-editing)
2) [DM reviews the version](./Editing%20Facilities.md#dm-review)
3) [DM updates from FMSS](./Editing%20Facilities.md#fmss-update)
4) [DM runs QC checks](./Editing%20Facilities.md#quality-check)
5) [DM/User address QC Issues](./Editing%20Facilities.md#quality-control-fixes)
6) Repeat steps 4 and 5 as needed
7) [DM calculates fields](./Editing%20Facilities.md#calculate-fields)
8) [DM posts to default](./Editing%20Facilities.md#post-to-default)
9) [DM Updates Metadata](./Editing%20Facilities.md#update-metadata)
9) [DM publishes copy to PDS](./Editing%20Facilities.md#publish-to-pds)

This document does not cover bulk updates with new data, such as a
new trail data collection effort.  It also does not cover updating
the facilities web application
(see https://github.com/AKROGIS/Facility-Processing/tree/master/Photo%20Processing/scripts)
or facility related photo processing
(see https://github.com/AKROGIS/Facility-Processing/tree/master/Photo%20Processing)

User Editing
------------
The user creates a new version in SDE.
The user then edits this version with the desired changes.
Edits should be limited and discreet.
The DM will reject a version in total, if the changes cannot be simply
summarized. See the discussion below in the section DM Review. Once all
edits are complete, the user must notify the DM that the version is ready
for checking and posting.

If there are multiple sets of changes, it is best to create multiple
versions so that they can be reviewed separately.

If a bulk update of existing features is desired, please discuss this
with the DM before proceeding.

Before submitting the version to the DM, it is a good idea for the
user to:

1) Review the changes in their version (see instructions in
the following section) to ensure there are no unintended changes.
2) Reconcile their version with any changes to DEFAULT since the
check out was made.  Any conflicts (someone else has modified the
same feature you modified) must be resolved before submitting.


DM Review
---------
The DM should open a map with all facility feature classes and
tables loaded in it.  The connection to the feature classes
is best done as SDE to ensure complete visibility of all changes.
In the database pane of the TOC, right click on the SDE database
and switch to the user's version.  In the versioning
toolbar pick the **Version Changes** tool.  (You must have the
database connection selected in the TOC).  Compare the user's version
to SDE.DEFAULT.  Make note of the feature classes with edits.  Also
verify that the number of changes is small. Changes must be discreet
and limited to just the features needing updates. This is to ensure
that the user has not done something unintended,
like deleting all the trails in another park (accidentally).

If DEFAULT has been updated since the checkout was made, the DM should
open the user's version for editing, and reconcile the version with
DEFAULT (that is, bring the updates in DEFAULT into the user's version)

A few operations that might get a version rejected: A large unexplained deletion.
A field calculation on several hundred records, a large copy/paste operation.
Exporting features to a different format, editing them,
and then reimporting the features.


FMSS Update
-----------
Until such time as the FMSS tables (**dbo.FMSSExport** and **dbo.FMSSExport_Asset**)
can be automatically updated nightly, the DM must update them manually.
Instructions for doing this are at
https://github.com/AKROGIS/Enterprise-QC/blob/master/FMSS%20Export%20instructions.txt
and take about 1 hour to complete if you are familiar with the process.
This process will update the FMSS tables in SDE with the latest updates
in the master tables of FMSS.

This is optional at the time of processing a user's version unless
the QC check determines there are errors (mismatches) between
the GIS attributes and the FMSS attributes for the same feature.
In that case, hopefully updating to the latest FMSS data will make
the issue go away.

The FMSS tables are not versioned and they will effect the QC results
for all versions including DEFAULT.  After the FMSS tables have been
updated  A complete QC check must be done against DEFAULT.  If there
are issues (they must be new and due to recent changes in the FMSS data),
they need to be corrected in a new maintenance version.
That version should be QC checked following this same process and then
posted to DEFAULT.
The user's version then needs to reconciled with the updated DEFAULT
before additional processing can occur.


Quality Check
-------------
The DM edits and runs a SQL script
(https://github.com/AKROGIS/Enterprise-QC/blob/master/Do%20Quality%20Control%20Checks.sql)
to check the changes to a given feature class.  The script can
be run on all feature classes, but only needs to be run on the
feature classes with changes (as identified in the DM Review section
above).  Some feature classes, like
attachments, run fairly quickly (a few seconds), while trails
takes several minutes to run.

This script must be run against the user's version.
There are comments in the script to help the DM edit the script
for the version at hand.  There is no need to save the edits.
The bulk of the QC logic is in saved views in the database.


Quality Control Fixes
---------------------
If there are issues with some features in a feature class, then the
QC query will provide one record per issue.  These issues can by sent
to the user for correction either by email (copy/paste or save as csv)
or described verbally.
If they are lengthy and complicated the query results can be save into
a temporary table (you need to uncomment some of the lines in the QC
script and rerun it).
The temporary table should be named with the user's version.
If they are saved as a table, then the
user can add that table to ArcMap to aid in resolving the issues.
These tables should be deleted once all correction have been made.

Alternatively, if the resolution is obvious, the DM can choose to do
the corrections. The corrections must be done in the user's version.
The corrections can be made with a SQL query against the user's version or
in an ArcMap edit session.  Unfortunately, using ArcMap will put the DM's
network username in the **EDITUSER** feature level metadata.
Editing a version with SQL is beyond this document, but you can
see examples in the stored procedures used in the following section.

For some issues, running the calculations (section below) will
resolve the issue. However, this should not be done until the user
(or DM) has a chance to see the warnings which will disappear
after the calculations have been run.

Some issue cannot be resolved by editing the GIS. For example:
* The GIS may be correct, but there is an issue because it
  disagrees with FMSS -- probably because FMSS needs to be updated.
* The change is valid but violates the normal QC rules. For example
  in general it is an error if two buildings have the same
  FMSS FACLOCID, but this can happen.

In these cases, the user or DM can create
new records in the **gis.QC_ISSUES_EXPLAINED** table.  The
columns for _Feature_oid_ and _Issue_ must match exactly the
_ObjectID_ and _Issue_ fields in the QC Check output. The _Explanation_
and _Feature_class_ attributes cannot be empty.


Calculate Fields
----------------
The DM edits and runs a SQL script
(https://github.com/AKROGIS/Enterprise-QC/blob/master/Do%20Calculation.sql)
to calculate missing values and correct and make other minor
corrections like replacing empty or all space strings with null.
This script must be run against the user's version, and it will
almost always update some of the records in the user's version.
The script only needs to be run on the feature classes with
changes (see DM Review above), however it doesn't hurt to run
it on all the feature classes.  Some feature classes, like
attachments, run fairly quickly (a few seconds), while trails
takes several minutes to run.

There are comments in the script to help the DM edit the script
for the version at hand.  There is no need to save the edits.
The bulk of the calculation logic is in stored procedures in the
database.

The script should not be run before the QC check because the
QC check will issue warnings for the user to verify that they
accept certain default values which will be applied by the
calculation process.  If the user
does not like the default, they can provide a more suitable
value before the calculation provides the unwanted default.

This script can be run at any time if there are no _default value
warnings_ or the user has indicated acceptance.  However,
this script uses the links to FMSS (**FACLOCID** or **FACASSETID**)
as well as the FMSS tables (see above) to populate some fields
in the user's version.  If any of these items change during the QC
process, then this script must be run again.
This script can be run repeatedly without concern.  When in doubt,
run this script one final time after all changes are made and the QC
check comes back clean.


Post To Default
---------------
The user's version should be reconciled one last time and then posted
to DEFAULT.  As a safety check, the DM can open the map used in the
DM Review step above, and confirm that there are now *NO* differences
between the user's version and DEFAULT.  The user's version should
then be deleted.

The DM can optionally reconcile all other versions with the updated
DEFAULT.  However, if there are conflicts, the reconcile should be
aborted and the owner of the version notified so that they can
do the reconcile and properly address the conflicts.


Update Metadata
---------------
It is a judgement call as to whether or not the changes in this
version warrant a new processing step in the lineage.  It also
seems like a good idea to update the _update date_.

**TODO: Identify metadata attributes to check and update**


Publish to PDS
--------------
The DM saves a copy of DEFAULT into a file geodatabase that is
published on the PDS (X drive) and replicated to all the parks.
This does not need to be done after every small update,
especially if there are additional updates pending in
short order.  However the user will not be able to see
their hard work in Theme Manager until this step is done.

Instructions are at
https://github.com/AKROGIS/PDS-Data-Management/blob/master/Facility-Sync/Instructions.txt,
and the script is in the same folder.
This process takes less than 15 minutes when familiar
with the process.