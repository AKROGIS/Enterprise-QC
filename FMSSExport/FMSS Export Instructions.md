FMSS Export/Import Instructions
===============================

Instructions for exporting data from the Facility Maintenence and
Management System (FMSS) and importing the data into our enterprise
facilities database. This process should take about 1 hour, and
should be done on a regular schedule to ensure that our GIS databases
are in sync with FMSS.

An automated solution to this problem has been attempted. See the
[Facility Processing Repo](https://github.com/AKROGIS/Facility-Processing/tree/master/FMSS)
for details.  Unfortunately, the SOAP services exposed by Maximo
(the FMSS vendor) do not provide all of the attributes that we need,
so we are using this manual process until we are successful at getting
Maximo to enhance those services.

## Export FMSS Data to Excel

* Browse to http://pfmdamrs.nps.gov/BOE/BI while on the NPS network
  - This site will use your windows identiry to authenticate.
  - You need to request access from Scott Vantrees.
  - Alternatively, browse to https://portal.pfmd.nps.gov/index.cfm and
    click on AMRS (Asset Management Reporting System) in the Application list.
* Click on the `Documents` tab (top left)
* Expand the `Locations` Folder

### Location Details
* Open (double-click) the `Location Detail Information` report.
* Select the following options in the report dialog
  - In the `Region/Park` group (groups are the gray boxes with the
    title in the top right corner), add `AKR` to the list of selected region(s). Leave the park list empty (implies all).
  - In the `Long Description` group, select `Yes` in the picklist.
  - In the `Format` group, select `Excel` in the picklist.
  - Click `OK` at the bottom of the dialog, and wait while the report
    is prepared.
* Click the `Export this report` buttton (in the middle of the toolbar).
  - In the File Format picklist, select `Microsoft Excel (97-2003) Data-only`.
  - Do not select `CSV`, which creates a 220MB file which includes a
    lot of header info on each line (and no column names).
  - Click the `Export` button.
  - After a significant pause you will be prompted with a file save
    dialog. Save this file as `Location Detail Information.xls` in
    your downloads folder.

### Location Specifications
* Click on the `Documents` tab.
* Open the `Location Specification Attributes Detail` report. 
  - Add `AKR` to the `Selected Values` list in the `Region/Park` group.
  - In the `spectemp Attribute` group, Add the following values to
    the `Selected Values` list. (Note 1: We need more than the 12
    attributes allowed per report, so we will do two reports and only select half for this report)
    - ASMISID
    - BLDGTYPE
    - CLASSSTR
    - CLINO
    - FAMARESP
    - FCLASS
    - NOLANE
    - NUMPLOT
    - OPSEAS
  - Click `OK`, and wait while the report is being prepared.
* Export to `Microsoft Excel (97-2003) Data-only` as above,
  saving the file as `Location Specification Attributes Detail.xls`.
* Repeat the `Location Specification Attributes Detail` report with the
  following attributes. (Note: The list of attributes is divided between
  two picklists.  To select attributes after `PARKNUMB`, Select `2` in
  the picklist below the `Available Attributes` list.) Save as `Location Specification Attributes Detail (1).xls`.
  - PARKNAME
  - PARKNUMB
  - PRIMUSE
  - PRKLNG
  - PRKWID
  - ROUTEID
  - RTENAME
  - TREADTYP
  - TRLGRADE
  - TRLUSE
  - TRLWIDTH

### FRP Data
* Click on the `Documents` tab.
* Expand the `FRP` folder.
* Open `FRP Related Data Information` report.
* Select the following options in the report dialog
  - In the `Region/Park` group, add `AKR` to the selected list.
  - In the `Location Type` group, select `Operating` in the picklist.
  - In the `Long Description` group, select `Yes` in the picklist.
  - Click `OK` , and wait while the report is being prepared.
* Export to `Microsoft Excel (97-2003) Data-only` as above,
  saving the file as `FRP Related Data Information.xls`.

### Assets
* Click on the `Documents` tab.
* Expand the `Assets` folder.
* Open the `Asset Inventory List` report.
* Select the following options in the report dialog
  - In the `Region/Park` group, add `AKR` to the selected list.
  - Click `OK`, and wait while the report is being prepared.
* Export to `Microsoft Excel (97-2003) Data-only` as above,
  saving the file as `Asset Inventory List.xls`.



## Convert Excel to Clean CSV

### Location Details
* Open `Location Detail Information.xls` in Excel.
* Delete the top 22 rows (everything above the column names row).
* Keep all data columns.
* Delete at least two "empty" columns to the right of the data columns. (There
  have been occassions where there are invisible values in some of these cells
  creating unexpected and unwanted columns in the output CSV).
* Select all cells in the spreadsheet and change the cell format from
  `General` to `Text`.
* Save As `CSV UTF-8 (comma delimited)` with the name `FMSSExport_Location1.csv`
* Close Excel without saving changes to the original file.
* Open `FMSSExport_Location1.csv` in VS Code or any text editor
  - Make sure the first line ends with a column name and not one or more 
    commas which would indicate there are bogus columns.  If there are bogus
    columns, then repeat the export to Excel to CSV process but remove more
    than two of the "empty" columns.
  - Search for lines beginning with zeros (e.g. `00001482`), If there are none,
    then the data was not formated as `Text` in the step above, and will generate errors later on.  Try again. 
  - Search and replace `,N/A,` with `,,` and `, ,` with `,,` (May need to be
    repeated a second time to find all occurances.)
  - Remove any lines at the end of the file that are all commas
  - Fix the data for the import bug (as described below)
  - Save the changes to `FMSSExport_Location1.csv`.

### Location Specifications
* Create `FMSSExport_Location2.csv` from
  `Location Specification Attributes Detail.xls` using _all_ the same steps
   for **Location Details** above, except: 
   - Delete the top 11 rows.
   - Sort (data has header) on column Location and delete empty rows.
   - Delete all the columns between `Location` and `ASMISID`
* Create `FMSSExport_Location3.csv` from
  `Location Specification Attributes Detail (1).xls` using _all_ the same
   steps for **Location Details** above, except: 
   - Delete the top 11 rows.
   - Delete all the columns between `Location` and `NOLANE`

### FRP Data
* Create `FMSSExport_FRP.csv` from
  `FRP Related Data Information.xls` using _all_ the same steps
   for **Location Details** above, except: 
   - Delete the top 18 rows.
   - Keep only the following columns
     + Location
     + DOI Code
     + Predominant Use
     + Asset Ownership
     + Occupant
     + Street Address
     + City
     + County
     + Primary Latitude (NAD 83)
     + Primary Longitude (NAD 83)
     + FRP Long Description

### Assets
* Open `Asset Inventory List.xls` in Excel.
* Delete the top 4 rows (everything above the column names row).
* Delete all data columns after `Location` (Keep `Asset`, `Description` and
  `Location`).
* Delete at least two "empty" columns to the right of the data columns.
* Select all cells in the spreadsheet and change the cell format from
  `General` to `Text`.
* Sort all data (the data has a header) on the `Asset` column
* Remove the bogus records at the bottom of the list (they do not have
  a number in the `Asset` column.
* Save As `CSV UTF-8 (comma delimited)` with the name `FMSSExport_Asset_new.csv`
* Close Excel without saving changes to the original file.
* Open `FMSSExport_Asset_new.csv` in VS Code or any text editor
  - Make sure the first line ends with a column name and not one or more 
    commas which would indicate there are bogus columns.  If there are bogus
    columns, then repeat the export to Excel to CSV process but remove more
    than two of the "empty" columns.
  - Remove any lines at the end of the file that are all commas
  - Fix the data for the import bug (as described below)
  - Save the changes to `FMSSExport_Asset_new.csv`.


## Import CSV in SQL Server

The following instructions were written assuming you are using
SQL Server Management Studio (SSMS) v18.  Similar capabilities are
available in other versions of SSMS, as well as Azure Data Studio
with the `SQL Server Import` extension.

* Open SSMS and connect to the `akr_facilities2` database
* Right click on the database and select `Tasks > Import Flat File...`

### Location Details
* Browse to the `Downloads` folder and select `FMSSExport_Location1.csv`
* The table name should default to the file name.
* Click `Next`.
* Skip `Preview Data` by clicking `Next`.
* In the `Modify Columns` page, check that the following properties are set:
  - All columns should have a data type of `nvarchar(50)` except:
    + `Description` should be `nvarchar(250)`
    + `FCI` should be `float`
    + `Long_Description` should be `nvarchar(4000)`
  - No column should be selected as a Primary Key.
  - All columns should Allow Nulls.
* Click `Next` and then `Finish`

### Location Specifications
* Import `FMSSExport_Location2.csv` as above, except in the `Modify Columns`
  page, check/set the following:
  - All columns should have a data type of `nvarchar(50)`
  - No column should be selected as a Primary Key.
  - All columns should Allow Nulls.
* Import `FMSSExport_Location3.csv` as above, except in the `Modify Columns`
  page, check/set the following:
  - All columns should have a data type of `nvarchar(50)` except:
    + `PARKNAME` should be `nvarchar(150)`
    + `RTENAME` should be `nvarchar(150)`
  - No column should be selected as a Primary Key.
  - All columns should Allow Nulls.

### FRP Data
* Import `FMSSExport_FRP.csv` as above, except in the `Modify Columns`
  page, check/set the following:
  - All columns should have a data type of `nvarchar(50)` except:
    + `FRP_Long_Description` should be `nvarchar(4000)`
  - No column should be selected as a Primary Key.
  - All columns should Allow Nulls.

### Assets
* Import `FMSSExport_Asset_new.csv` as above, except in the `Modify Columns`
  page, check/set the following:
  - All columns should have a data type of `nvarchar(50)` except:
    + `Description` should be `nvarchar(250)`
  - No column should be selected as a Primary Key.
  - All columns should Allow Nulls.


## SQL Server Processing

Open `fmss_import.sql` in SSMS or Azure Data Studio.  Highlight the code
for each step below and run.  Do not run the whole file at once, as that can
make it very difficult to troubleshoot and recover from any errors.

1) Delete bogus records required to get CSV import to work
2) Fix errors in data
3) Build the FMSSExport table
4) Fix the primary keys/indexes
5) Fix the permissions
6) Rename the existing tables
7) Test
8) Delete the old and input tables

## Metadata

Update the Citation publication and revision date and the lineage processing step date in the SDE metadata files for FMSSExport and FMSSExport_Assets

Run the QC Checks, if there are errors, create a new version and correct any errors in GIS based on new FMSS values



## Work around for CSV Import Problems

SSMS v18 "upgraded" the CSV import tool with the ability to
interpret the schema in the CSV data.  Unfortunately it is broken
(https://feedback.azure.com/forums/908035-sql-server/suggestions/38096989-ssms-import-flat-file-fails-to-import-all-data).
To work around this problem, we need to add
dummy rows to the top of our CSV data so the importer will get close
enough to the correct Schema that we can import it without data loss.
It appears that Azure Data Studio uses the same CSV interpretation engine.

The solutions is to create new data rows below the first data row (not directly
below the header) such that there are more than 10% unique values that have the
correct data type.  The values in the columns must be unique.  For all but
assets, this means 2 new rows. For assets it means 7 new rows. Be sure to
keep the first row of column names. Paste these dummy rows after the first row
of data (rows 3+) otherwise the import will think these are multiple rows of
column names.

### FMSSExport_Location1
Insert the following 2 lines between lines 2 and 3 in `FMSS_Locations1.csv`
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,1.01,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,1.01,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_Location2
Insert the following 2 lines between lines 2 and 3 in `FMSS_Locations2.csv`
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_Location3
Insert the following 2 lines between lines 2 and 3 in `FMSS_Locations3.csv`
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_FRP
Insert the following 2 lines between lines 2 and 3 in `FMSS_Locations2.csv`
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_Asset_new
Insert the following 7 lines between lines 2 and 3 in `FMSSExport_Asset_new.csv`

```
a1,a1,a1
a2,a2,a2
a3,a3,a3
a4,a4,a4
a5,a5,a5
a6,a6,a6
a7,a7,a7
```
