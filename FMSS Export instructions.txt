This process should take about 45 minutes
It assumes you are using SSMS v17

** NOTE THAT THERE IS A BUG IN SSMS v18 upto at least 18.5.1 (15.0.18333.0) that replaces all alpha locations (i.e. AKRO) with NULL**

The solutions is to create new data rows below the first data row (not directly below the header) that result in more than 10% unique values
that have the correct data type.  The values in the columns must be unique.  For all but assets, this means 2 new rows. For assets it means 6 new rows
For example, here is the first few rows of the FRP table, with details elided. Be sure to keep the first row of column names
Paste these dummy rows after the first row of data (rows 3+) else, the import may think these are multiple rows fo column names

FMSSExport_Asset:
a1,a1,a1
a2,a2,a2
a3,a3,a3
a4,a4,a4
a5,a5,a5
a6,a6,a6
a7,a7,a7

FMSSExport_Location1:
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,1.01,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,1.01,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2

FMSSExport_Location2:
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2

FMSSExport_Location3:
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2

FMSSExport_FRP
a1,a1,a1,a1,a1,a1,a1,a1,a1,a1,a1
a2,a2,a2,a2,a2,a2,a2,a2,a2,a2,a2


Then you need to remove the bogus rows after import: delete from FMSSExport_FRP where location  = 'a2' or location  = 'a1'

delete from FMSSExport_Location1 where location in ('a1','a2')
delete from FMSSExport_Location2 where location in ('a1','a2')
delete from FMSSExport_Location3 where location in ('a1','a2')
delete from FMSSExport_FRP where location in ('a1','a2')
delete from FMSSExport_Asset where location in ('a1','a2','a3','a4','a5','a6','a7')


As of 6/24/2020, there are two location records with location = '1216'
select * from FMSSExport_Location1 where location = '1216'
delete from FMSSExport_Location1 where location = '1216' and parent is null


go to FMSS (need to request access from Scott Vantrees)
  - https://portal.pfmd.nps.gov/index.cfm
click on AMRS (Asset Management Reporting System) in the Application list
  - or go directly to http://pfmdamrs.nps.gov/BOE/BI
Click on the Documents tab (top left)
Expand the Locations Folder
Double click the Location Specification Attribute Detail 
In the Crystal report configuration:
  - Select AKR in region values then click '>'
  - In the Location Spectemp Attribute(s) select the following
    - ASMISID  (only one record has data)
    - BLDGTYPE (keep, seem interesting, still need or get from FRP)
    - CLASSSTR
    - CLINO
    - FAMARESP
    - FCLASS
    - NOLANE
    - NUMPLOT
    - OPSEAS
    (only 12 attributes per report; so do two reports)
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
  - Click OK, and wait while the document is being processed.
  - Click the Export report buttton (top left)
    - select Microsoft Excel (97-2003) Data-only.  This creates a file
      called Location Specification Attributes Detail.xls in your downloads Folder
      Do not select CSV, this creates a 220MB file which includes a lot of header
      info on each line (and no column names)
Open in Excel, delete top 11 rows (everything above the column names)
Delete all the columns between Location and ASMISID in the first report
Delete all the columns between Location and NOLANE in the second report
Delete at least two "empty" columns on the right (there are some empty cell values that will create two bad columns on the right)
make sure all data is formatted as text
Save as CSV
Open in VS Code or Atom and remove all N/A values; i.e. search and replace ",N/A," with ",,"
Import to SQL Server as FMSSExport_Location2 and 3
  - allow null on all, no PK, all nvarchar(50) except PARKNAME and RTENAME = nvarchar(150)

open the Location Detail Information report
  - Select AKR under region
  - Select Excel under Format
  - Select Yes for Long Description
  - OK, export to Microsoft Excel (97-2003) Data-only
Open in Excel, delete top 19 rows (everything above the column names)
Keep all data columns, but delete at least two "empty" columns on the right
make sure all data is formatted as text
Save as CSV
Open in VS Code or Atom and remove all N/A values; i.e. search and replace ",N/A," with ",,"
Import to SQL Server as FMSSExport_Location1
  - allow null on all, no PK, all nvarchar(50) except FCI = float, Long_Description = nvarchar(4000), Description = nvarchar(250)


Expand the FRP folder
open FRP Related Data Information
  - Region = AKR
  - Operating (this is for status of record, not feature)
  - Yes to include long Description
  - Export to Microsoft Excel (97-2003) Data-only
Open in Excel, delete top 16 rows (everything above the column names)
Delete the extra columns; keep Location, DOI Code, Predominant Use, Asset Ownership, Occupant, Street Address, City, County, Primary Latitude (NAD 83), Primary Longitude (NAD 83), FRP Long Description
Delete at least two "empty" columns on the right (there are some empty cell values that will create two bad columns on the right)
make sure all data is formatted as text
Save as CSV
Open in VS Code or Atom and remove all N/A values; i.e. search and replace ",N/A," with ",,"
Import to SQL Server as FMSSExport_FRP
  - allow null on all, no PK, all nvarchar(50) except FRP_Long_Description = nvarchar(4000)

Build final table:
drop table FMSSExport
SELECT l1.*, 
  nullif(l2.ASMISID,'') ASMISID, nullif(l2.BLDGTYPE,'') BLDGTYPE, nullif(l2.CLASSSTR,'') CLASSSTR, nullif(l2.CLINO,'') CLINO, nullif(l2.FAMARESP,'') FAMARESP, nullif(l2.FCLASS,'') FCLASS, nullif(l2.OPSEAS,'') OPSEAS, nullif(l3.PARKNAME,'') PARKNAME, nullif(l3.PARKNUMB,'') PARKNUMB, nullif(l3.PRIMUSE,'') PRIMUSE,
  nullif(l2.NOLANE,'') NOLANE, nullif(l2.NUMPLOT,'') NUMPLOT, nullif(l3.PRKLNG,'') PRKLNG, nullif(l3.PRKWID,'') PRKWID, nullif(l3.ROUTEID,'') ROUTEID, nullif(l3.RTENAME,'') RTENAME, nullif(l3.TREADTYP,'') TREADTYP, nullif(l3.TRLGRADE,'') TRLGRADE, nullif(l3.TRLUSE,'') TRLUSE, nullif(l3.TRLWIDTH,'') TRLWIDTH,
  l4.DOI_Code, l4.Predominant_Use, l4.Asset_Ownership, l4.Street_Address, l4.City, l4.County, l4.Primary_Latitude_NAD_83 as lat, l4.Primary_Longitude_NAD_83 as lon, l4.FRP_Long_Description
into FMSSExport 
   FROM FMSSExport_Location1 as l1
left join FMSSExport_Location2 as l2 on l1.Location = l2.Location
left join FMSSExport_Location3 as l3 on l1.Location = l3.Location
left join FMSSExport_FRP as l4  on l1.Location = l4.Location;
alter table FMSSExport alter column Location NVARCHAR(50) not null;
alter table FMSSExport add primary key (Location)
drop table FMSSExport_Location1
drop table FMSSExport_Location2
drop table FMSSExport_Location3
drop table FMSSExport_FRP
GRANT SELECT ON FMSSExport TO akr_facility_editor AS dbo
GRANT SELECT ON FMSSExport TO akr_reader_web AS dbo
GRANT SELECT ON FMSSExport TO [nps\Domain Users] AS dbo


For Assets
    - Open the Asset Folder, and select the Asset Inventory List
    - Select AKR for Region, then click OK, wait
    - export to Microsoft Excel (97-2003) Data-only
    - open in excel
    - delete junk at top (top 4 rows), but not column names (row 5), sort by asset, and delete junk rows at bottom
    - delete all columns except Asset, Description and Location
    - make sure all data is formatted as text
    - save as CSV
    - Open in VS Code or Atom and change CRLF to LF and make sure there are leading zeros on some locations
    - import into SQLServer
      drop table FMSSExport_Asset
      - database -> tasks -> import as flatfile...
      - into table FMSSExport_Asset, nvarchar(50) for all except Description = nvarchar(250), Allow nulls on all, no PK 
      - remove null records, create index (no PK on Asset because it isn't unique ??)
          - select * from FMSSExport_Asset where asset in (select asset from FMSSExport_Asset group by asset having count(*) > 1) order by asset, location
        delete FMSSExport_Asset where Asset is null or location is null
        alter table FMSSExport_Asset alter column Asset NVARCHAR(10) not null
        CREATE INDEX idx_FMSSExport_Asset_Asset ON FMSSExport_Asset (Asset ASC)
        GRANT SELECT ON FMSSExport_Asset TO akr_facility_editor AS dbo
        GRANT SELECT ON FMSSExport_Asset TO akr_reader_web AS dbo
        GRANT SELECT ON FMSSExport_Asset TO [nps\Domain Users] AS dbo


Update the Citation publication and revision date and the lineage processing step date in the SDE metadata files for FMSSExport and FMSSExport_Assets

Run the QC Checks, if there are errors, create a new version and correct any errors in GIS based on new FMSS values



