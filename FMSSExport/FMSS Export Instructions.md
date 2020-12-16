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
Maximo to enhance those services

## Export FMSS Data to Excel

* Browse to http://pfmdamrs.nps.gov/BOE/BI while on the NPS network
  - This site will use your windows identiry to authenticate.
  - You need to request access from Scott Vantrees.
  - Alternatively, browse to https://portal.pfmd.nps.gov/index.cfm and
    click on AMRS (Asset Management Reporting System) in the Application list.
* Click on the `Documents` tab (top left)
* Expand the `Locations` Folder

### Location Details

* Open the `Location Detail Information` report
* Select the following options in the report dialog
  - Select `AKR` under region
  - Select `Excel` under Format
  - Select `Yes` for Long Description
  - Click `OK`, and wait while the report is being prepared.
* Click the `Export Report` buttton (top left)
  - Select `Microsoft Excel (97-2003) Data-only`. This creates a file
    called `Location Detail Information.xls` in your downloads folder.
  - Do not select `CSV`, this creates a 220MB file which includes a
    lot of header info on each line (and no column names).

### Location Specifications

* Double click the `Location Specification Attribute Detail` report 
  - Select `AKR` in region values then click '>'
  - In the `Location Spectemp Attribute(s)` select the following
    attributes. (Note: We want more than the 12 allowed per report,
    so we will do two reports and only select half for this report)
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
* Export to `Microsoft Excel (97-2003) Data-only` as above.
* Repeat the `Location Specification Attribute Detail` report with the
  following attributes.
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
* Expand the `FRP` folder
* Open `FRP Related Data Information` report
* Select the following options in the report dialog
  - Region` = AKR
  - Operating (this is for status of record, not feature)
  - Yes to include long Description
* Export to `Microsoft Excel (97-2003) Data-only` as above.

### Assets

* Open the `Asset` Folder
* Select the `Asset Inventory List` report
* Select the following options in the report dialog
  - Select `AKR` for Region
  - Click `OK`, and wait while the report is being prepared.
* Export to `Microsoft Excel (97-2003) Data-only` as above.


## Convert Excel to CSV

### Location Details

* Open in Excel
* Delete top 19 rows (everything above the column names)
* Keep all data columns, but delete at least two "empty" columns on the right
  (there are some empty cell values that will create two bad columns on the right)
* Select all cells and format as text (not general)
* Save as CSV with a name ``
* Open in VS Code or any text editor
  - Remove all N/A values; i.e. search and replace ",N/A," with ",,"
  - Make sure there are leading zeros on some locations
  - Fix the data for the import bug (as described below)

### Location Specifications

* Open in Excel
* Delete top 11 rows (everything above the column names)
* Delete all the columns between Location and ASMISID in the first report
* Delete all the columns between Location and NOLANE in the second report
* Delete at least two "empty" columns on the right
* Select all cells and format as text (not general)
* Save as CSV with a name ``
* Open in VS Code or any text editor
  - Remove all N/A values; i.e. search and replace ",N/A," with ",,"
  - Make sure there are leading zeros on some locations
  - Fix the data for the import bug (as described below)

### FRP Data

* Open in Excel
* Delete top 16 rows (everything above the column names)
* Delete the extra columns; keep Location, DOI Code, Predominant Use, Asset Ownership,
  Occupant, Street Address, City, County, Primary Latitude (NAD 83), Primary Longitude
  (NAD 83), FRP Long Description
* Delete at least two "empty" columns on the right
* Select all cells and format as text (not general)
* Save as CSV with a name ``
* Open in VS Code or any text editor
  - Remove all N/A values; i.e. search and replace ",N/A," with ",,"
  - Make sure there are leading zeros on some locations
  - Fix the data for the import bug (as described below)

### Assets

* Open in excel
* Delete junk at top (top 4 rows), but not column names (row 5)
* Delete all columns except Asset, Description and Location
* Sort by asset and delete junk rows at bottom
* Select all cells and format as text (not general)
* Save as CSV with a name ``
* Open in VS Code or any text editor
  - Make sure there are leading zeros on some locations
  - Fix the data for the import bug (as described below)


## Import CSV in SQL Server

### Location Details

Import to SQL Server as FMSSExport_Location1
  - allow null on all, no PK, all nvarchar(50) except FCI = float, Long_Description = nvarchar(4000), Description = nvarchar(250)

### Location Specifications

Import to SQL Server as FMSSExport_Location2 and 3
  - allow null on all, no PK, all nvarchar(50) except PARKNAME and RTENAME = nvarchar(150)

### FRP Data

Import to SQL Server as FMSSExport_FRP
  - allow null on all, no PK, all nvarchar(50) except FRP_Long_Description = nvarchar(4000)

### Assets

Import to SQL Server as FMSSExport_Asset_new
  - database -> tasks -> import as flatfile...
  - into table FMSSExport_Asset, nvarchar(50) for all except Description = nvarchar(250), Allow nulls on all, no PK 

## SQL Server Processing

Open `fmss_import.sql` in SSMS or Azure Data Studio.  Highlight the code
for each step and run.  Do not run the whole file at once, as that can
make it very difficult to troubleshoot and recover from any errors.

1) Delete bogus records required to get CSV import to work
2) Rename the existing tables
3) Build the FMSSExport table
4) Fix the primary keys/indexes
5) Fix the permissions
6) Test
7) Delete the old and input tables

## Metadata

Update the Citation publication and revision date and the lineage processing step date in the SDE metadata files for FMSSExport and FMSSExport_Assets

Run the QC Checks, if there are errors, create a new version and correct any errors in GIS based on new FMSS values



## Work around for CSV Import Problems

SSMS v18 "upgraded" the CSV import process tool with the ability to
interpret the schema in the CSV data.  Unfortunately it is broken
(link to bug report). To work around this problem, we need to add
dummy rows to the top of our CSV data so the importer will get close
enough to the correct Schema that we can import it without data loss.
It appears that Azure Data Studio uses the same CSV interpretation engine.

The solutions is to create new data rows below the first data row (not directly
below the header) that result in more than 10% unique values that have the
correct data type.  The values in the columns must be unique.  For all but
assets, this means 2 new rows. For assets it means 6 new rows. For example,
here is the first few rows of the FRP table, with details elided. Be sure to
keep the first row of column names. Paste these dummy rows after the first row
of data (rows 3+) else, the import may think these are multiple rows fo column
names.

### FMSSExport_Location1
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,1.01,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,1.01,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_Location2
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_Location3
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_FRP
```
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2
```

### FMSSExport_Asset
```
a1,a1,a1
a2,a2,a2
a3,a3,a3
a4,a4,a4
a5,a5,a5
a6,a6,a6
a7,a7,a7
```
