-- This file is intended to be used in conjunction with 
-- The FMSS Export Instructions.

-- WARNING: This file is not intended to be run as a single script.
-- useful lines (or sections) should be highlighted and run in SSMS
-- or Azure Data Studio as needed.

-- Step 0) Import the FMSS export CSVs into tables
-- database -> tasks -> import as flatfile...

-- Step 1) Delete bogus records required to get CSV import to work
delete from FMSSExport_Location1 where location in ('a1','a2')
delete from FMSSExport_Location2 where location in ('a1','a2')
delete from FMSSExport_Location3 where location in ('a1','a2')
delete from FMSSExport_FRP where location in ('a1','a2')
delete from FMSSExport_Asset_new where location in ('a1','a2','a3','a4','a5','a6','a7')

-- Step 2) Check and fix error in existing data
-- As of 6/24/2020, there are two location records with location = '1216'
select * from FMSSExport_Location1 where location = '1216'  --CHECK
delete from FMSSExport_Location1 where location = '1216' and parent is null  -- FIX

-- Step 3) Build the FMSSExport table
SELECT l1.*, 
  nullif(l2.ASMISID,'') ASMISID, nullif(l2.BLDGTYPE,'') BLDGTYPE, nullif(l2.CLASSSTR,'') CLASSSTR, nullif(l2.CLINO,'') CLINO, nullif(l2.FAMARESP,'') FAMARESP, nullif(l2.FCLASS,'') FCLASS, nullif(l2.OPSEAS,'') OPSEAS, nullif(l3.PARKNAME,'') PARKNAME, nullif(l3.PARKNUMB,'') PARKNUMB, nullif(l3.PRIMUSE,'') PRIMUSE,
  nullif(l2.NOLANE,'') NOLANE, nullif(l2.NUMPLOT,'') NUMPLOT, nullif(l3.PRKLNG,'') PRKLNG, nullif(l3.PRKWID,'') PRKWID, nullif(l3.ROUTEID,'') ROUTEID, nullif(l3.RTENAME,'') RTENAME, nullif(l3.TREADTYP,'') TREADTYP, nullif(l3.TRLGRADE,'') TRLGRADE, nullif(l3.TRLUSE,'') TRLUSE, nullif(l3.TRLWIDTH,'') TRLWIDTH,
  l4.DOI_Code, l4.Predominant_Use, l4.Asset_Ownership, l4.Street_Address, l4.City, l4.County, l4.Primary_Latitude_NAD_83 as lat, l4.Primary_Longitude_NAD_83 as lon, l4.FRP_Long_Description
into FMSSExport_new 
   FROM FMSSExport_Location1 as l1
left join FMSSExport_Location2 as l2 on l1.Location = l2.Location
left join FMSSExport_Location3 as l3 on l1.Location = l3.Location
left join FMSSExport_FRP as l4  on l1.Location = l4.Location;


-- Step 4a) Fix the primary keys/indexes for Locations
alter table FMSSExport_new alter column Location NVARCHAR(50) not null;
GO
alter table FMSSExport_new add primary key (Location)

-- Step 4b) Fix the primary keys/indexes for Assets
-- remove null records, create index (no PK on Asset because it isn't unique ??)
-- select * from FMSSExport_Asset where asset in (select asset from FMSSExport_Asset group by asset having count(*) > 1) order by asset, location
delete FMSSExport_Asset_new where Asset is null or location is null;
alter table FMSSExport_Asset_new alter column Asset NVARCHAR(10) not null;
GO
CREATE INDEX idx_FMSSExport_Asset_Asset ON FMSSExport_Asset_new (Asset ASC)

-- Step 5a) Fix the permissions for Locations
GRANT SELECT ON FMSSExport_new TO akr_facility_editor AS dbo
GRANT SELECT ON FMSSExport_new TO akr_reader_web AS dbo
GRANT SELECT ON FMSSExport_new TO [nps\Domain Users] AS dbo

-- Step 5b) Fix the permissions for assets
GRANT SELECT ON FMSSExport_Asset_new TO akr_facility_editor AS dbo
GRANT SELECT ON FMSSExport_Asset_new TO akr_reader_web AS dbo
GRANT SELECT ON FMSSExport_Asset_new TO [nps\Domain Users] AS dbo

-- Step 6) Swap in the new tables
--  (Save the old tables incase we have problems and need to swap back)
EXEC sp_rename 'FMSSExport', 'FMSSExport_old';
EXEC sp_rename 'FMSSExport_new', 'FMSSExport';
EXEC sp_rename 'FMSSExport_Asset', 'FMSSExport_Asset_old';
EXEC sp_rename 'FMSSExport_Asset_new', 'FMSSExport_Asset';
-- The following code will revert to the old tables in case there is a major problem
/*
EXEC sp_rename 'FMSSExport', 'FMSSExport_new';
EXEC sp_rename 'FMSSExport_old', 'FMSSExport';
EXEC sp_rename 'FMSSExport_Asset', 'FMSSExport_Asset_new';
EXEC sp_rename 'FMSSExport_Asset_old', 'FMSSExport_Asset';
*/

-- Step 7) Test by running the QC routines (there will likely be
-- a few QC issues due to changes in FMSS since the last export.
-- However hundereds of issues, or errors in the QC process may
-- indicate that there is a problem with the export/import process
-- Check FMSS_Export_old against FMSSExport for structural changes
-- or large changes in the record count.  Same for FMSSExport_Asset.
-- If there are significant problems, restore the original tables
-- while you figure out how to resolve the issue.

-- Step 8) Delete the old and input tables
drop table FMSSExport_old
drop table FMSSExport_Asset_old
drop table FMSSExport_Location1
drop table FMSSExport_Location2
drop table FMSSExport_Location3
drop table FMSSExport_FRP
