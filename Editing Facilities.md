Updating the Facilities GIS
===========================

_[The master copy of this document can be found at https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md]_

The Alaska Region facilities GIS lives in SDE on INPAKROVMAIS.
Updates are controlled by the regional GIS data manager (DM)
and go through a rigorous quality control (QC) process.
In general the following process is applied:

1) [User edits a new version](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#user-editing)
2) [DM reviews the version](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#dm-review)
3) [DM updates from FMSS](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#fmss-update)
4) [DM runs QC checks](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#quality-check)
5) [DM/User address QC Issues](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#quality-control-fixes)
6) Repeat steps 4/6 as needed
7) [DM calculates fields](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#calculate-fields)
8) [DM posts to default](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#post-to-default)
9) [DM Updates Metadata](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#update-metadata)
9) [DM publishes copy to PDS](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Editing%20Facilities.md#publish-to-pds)


User Editing
------------
The user creates a new version in SDE. The user edits this version with the desired changes.  Edits should be limited and discreet.  The DM will reject a version in total, if the changes cannot be simply summarized.  See the discussion on DM review. Once all edits are complete, the user
must notify the DM that the version is ready for checking and posting.

If there are multiple sets of changes, it is best to create multiple
versions so that they can be reviewed separately.

If a bulk update of existing features is needed discuss this first
with the DM.

Before submitting the version to the DM, it is a good idea for the
user to:

1) Review the changes in thier version (see instructions in 
the following section) to ensure there are no unintended changes.
2) Reconcile their version with changes to DEFAULT since the
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
to SDE.Default.  Make note of the feature classes with edits.  Also
verify that the number of changes is small. Changes must be discreet and limited to just the features needing updates. This is to ensure that the user has not done something unintended,
like deleting all the trails in another park (accidentally).

If DEFAULT has been updated since the checkout was made, the DM should
open the user's version for editing, and reconcile the version with
DEFAULT (that is, bring the updates in DEFAULT into the user's version)

A few operations that might get a version rejected: A large unexplained deletion.  A field calculation on several hundered records, a large copy/paste operation.  Exporting features to a different format, editing them,
and then reimporting the features.


FMSS Update
-----------
Until such time as the FMSS tables (**dbo.FMSSExport** and **dbo.FMSSExport_Asset**) can be automatically updated nightly, the DM must update them manually.  Instructions for doing this are at
https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/FMSS%20Export%20instructions.txt and take
about 1 hour to complete if you are familiar with the process.  This process will update the FMSS tables in SDE with the latest updates
in the master tables of FMSS.

This is optional at the time of processing a user's version unless the QC check determines there are errors (mismatches) between
the GIS attributes and the FMSS attributes for the same feature.

The FMSS tables are not versioned and they will effect the QC results
for all versions including DEFAULT.  After the FMSS tables have been
updated  A complete QC check must be done against DEFAULT.  If there
are issues (they must be new and due to recent changes in the FMSS data),
they need to be corrected in a new maintenance version.  That version should be QC checked following this same process and then posted to
DEFAULT.  The user's version then needs to reconciled with the new version of DEFAULT before additional processing can occur.


Quality Check
-------------
The DM edits and runs a SQL script
(https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Do%20Quality%20Control%20Checks.sql)
to check the changes to a given feature class.  The script can
be run on all feature classes, but only needs to be run on the
feature classes with changes (as identified in the review section
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
QC query will provide one record per issue.  These issues can by sent to the user for correction either by email (copy/paste or save as csv) or described verbally.  If they are lengthy and complicated the query results can be save into a temporary table (you need to uncomment
some of the lines in the QC script and rerun it).
The temporary table should be named with the user's version.
If they are saved as a table, then the
user can add that table to ArcMap to aid in resolving the issues.
These tables should be deleted once all correction have been made.

Alternatively, if the resolution is obvious, the DM can choose to do the corrections.  The corrections must be done in the user's version.  They
corrections can be made with a SQL query against the user's version or in an ArcMap edit session.  Unfortunately, using ArcMap will put the DM's network username in the **EDITUSER** feature level metadata.
Editing a version with SQL is beyond this document, but you can
see examples in the stored procedures used in the following section.


Calculate Fields
----------------
The DM edits and runs a SQL script
(https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/Do%20Calculation.sql)
to calculate missing fields.
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

The script should not be run before the QC check, because the
QC check will issue warnings for the user to verify that they
accepts certain default values which will be applies by the
calculation process without warning.  In this way, if the user
does not like the default, they can provide a more suitable
value before the calculation provides the unwanted default.

This script can be run at any time if there are no _default value
warnings_ or tha user has indicated acceptance.  However, 
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
Review step above, and confirm that there are now *NO* differences
between the user's version and DEFAULT.  The user's version should
then be deleted.

The DM can optionally reconcile all other versions with the updated
DEFAULT.  However, if there are conflicts, the reconcile should be
aborted, and the owner of the version notified so that they can
do the reconcile and properly address the conflicts.


Update Metadata
---------------
It is a judgement call as to wether or not the changes in this
version warrant a new processing step in the lineage.  It also
seems like a good idea to update the _update date_.

**TODO: Identify metadata attributes to check and update**


Publish to PDS
--------------
The DM saves a copy of DEFAULT into a file geodatabase that
is published on the PDS (X drive) and replicated to all the
park.
This does not need to be done after every small update,
especially if there are additional updates pending in
short order.  However the user will not be able to see
their hard work in Theme Manager until this step is done.

Instructions are at https://github.com/regan-sarwas/pds-reorg/blob/master/Facility-Sync/Instructions.txt, and the script is in the
same folder.  This process takes less than 15 minutes when familiar
with the process.
