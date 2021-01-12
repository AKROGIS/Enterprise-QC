# Facility Editing

## `Do Calculations`

A script (with internal instructions) for updating the calculated fields
in new features in an SDE version in the facilities database.  This script
must be run before posting a version to `DEFAULT`. See
[Editing Facilities](./Editing%20Facilities.md) for a discussion of the
edit/review/publish work flow.

## `Do Quality Control Checks.sql`

A script (with internal instructions) for running the quality controls tests
on a SDE version with edits.  Only once there are no results from all these
queries is it allowable to post the version to `DEFAULT`. See
[Editing Facilities](./Editing%20Facilities.md) for a discussion of the
edit/review/publish work flow.

## `Example_Add_QC_Explanation.sql`

An example of how to add an explanation to silence a QC issue in SQL without
having to launch ArcGIS and make the edits in the mapping environment.

## `Facilities_QualityControl_Schema.sql`

An export of the custom objects (tables, views, store procedures, and functions)
created to support the calculated fields and QC queries in the facilities
database.  See the
[Database Export Instructions](https://github.com/AKROGIS/AnimalMovement/blob/master/Documentation/Database%20Export%20Instructions.md)
in the [Animal Movements Repo](https://github.com/AKROGIS/AnimalMovement)
for instructions on recreating this file whenever the schema in the database
is changed.  **NOTE:** this file does not track changes to the feature classes
only the tables, etc used for the calculated fields and qualtiy control.

## `Potential_QC_Checks.sql`

These are queries that were considered for inclusion in the queries called by
`Do Quality Control Checks.sql`.  However they were not included because:

* They result in an overwhelming number of issues that would need to be researched
  and edited in order to get a clean database.
* There is no requirement in the standard, but maybe there should be an AKR
  requirement.
* It is not clear how (or even if we can) define our requirements (i.e. a
  spatial identification for `GROUPCODE`).

## Editing Facilities

This [document](./Editing%20Facilities.md)
describes the workflow for getting changes published in
`DEFAULT`.

## To Do

A [list](./To_Do.md) of things to do that would improve the quality of the
facilities database.
