-- Building Calculation Queries
-- This script will calculate derivable values for fields left null by the editor
-- You must check and resolve all QC issues before running this script
-- This script must be run on a editor's version before posting.
-- It must be run a DBO outside of ArcGIS to avoid messing up the edit user/date and archive dates
-- Must run QC check after to make sure we didn't create a problem
--   (if there are new QC issues, then it is bug in our QC check;  In addition to fixing any issues, fix the QC check to alert the user
--    to the issue that will arise after running the calc.)

-- NOTE: an update with a join (say updating unitname based on unitcode by joining to DOM_UNITCODE) will fail with this error:
--       UPDATE is not allowed because the statement updates view "gis.AKR_BLDG_CENTER_PT_evw" which participates in a join and has an INSTEAD OF UPDATE trigger.
--       The solution is to use a MERGE statement instead (https://stackoverflow.com/a/5426404/542911)

-- To edit versioned data in SQL, see this help: http://desktop.arcgis.com/en/arcmap/latest/manage-data/using-sql-with-gdbs/edit-versioned-data-using-sql-sqlserver.htm

-- 1) Find the named version
--    List the named versions (select the following line and press F5 or the Execute button)
select owner, name from sde.SDE_versions where parent_version_id is not null order by owner, name

-- 2) Set the operable version to a named version
--    Edit 'owner.name' to be one of the versions in the previous list, then select all of the remaining code
--    and execute (press F5 or the execute button)
--    Alternatively, replace all occurrances of @version with the appropriate 'owner.name' version text,
---   then execute one statement (or a group of statements) at a time.
DECLARE @version nvarchar(255) = 'owner.name'
-- set the operable version to a named version
exec sde.set_current_version @version
-- Start editing
exec sde.edit_version @version, 1 -- 1 to start edits

-- 1a) Add POINTYPE = 'Center point' if null in gis.AKR_BLDG_CENTER_PT
update gis.AKR_BLDG_CENTER_PT_evw set POINTTYPE = 'Center point' where POINTTYPE is null
-- 1b) Add POLYGONTYPE = 'Perimeter polygon' if null in gis.AKR_BLDG_FOOTPRINT_PY
update gis.AKR_BLDG_FOOTPRINT_PY_evw set POLYGONTYPE = 'Perimeter polygon' where POLYGONTYPE is null
-- 2) Add GEOMETRYID if null in all
update gis.AKR_BLDG_CENTER_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null
update gis.AKR_BLDG_OTHER_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null
update gis.AKR_BLDG_FOOTPRINT_PY_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null
update gis.AKR_BLDG_OTHER_PY_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null
-- 3) Add FEATUREID if null in gis.AKR_BLDG_CENTER_PT
update gis.AKR_BLDG_CENTER_PT_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null
-- 4) if MAPMETHOD is NULL or an empty string, change to Unknown
update gis.AKR_BLDG_CENTER_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
update gis.AKR_BLDG_OTHER_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
update gis.AKR_BLDG_FOOTPRINT_PY_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
update gis.AKR_BLDG_OTHER_PY_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
-- 5) if MAPSOURCE is NULL or an empty string, change to Unknown
--    by SQL Magic '' is the same as any string of just white space
update gis.AKR_BLDG_CENTER_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
update gis.AKR_BLDG_OTHER_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
update gis.AKR_BLDG_FOOTPRINT_PY_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
update gis.AKR_BLDG_OTHER_PY_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
-- 6) SOURCEDATE: Nothing to do.
-- 7) XYACCURACY: Nothing to do.
-- 8) if NOTES is an empty string, change to NULL
update gis.AKR_BLDG_CENTER_PT_evw set NOTES = NULL where NOTES = ''
update gis.AKR_BLDG_OTHER_PT_evw set NOTES = NULL where NOTES = ''
update gis.AKR_BLDG_FOOTPRINT_PY_evw set NOTES = NULL where NOTES = ''
update gis.AKR_BLDG_OTHER_PY_evw set NOTES = NULL where NOTES = ''
-- 9) if BLDGNAME is an empty string, change to NULL
update gis.AKR_BLDG_CENTER_PT_evw set BLDGNAME = NULL where BLDGNAME = ''
-- 10) if BLDGALTNAME is an empty string, change to NULL
update gis.AKR_BLDG_CENTER_PT_evw set BLDGALTNAME = NULL where BLDGALTNAME = ''
-- 11) if MAPLABEL is an empty string, change to NULL
update gis.AKR_BLDG_CENTER_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
-- 12) if BLDGSTATUS; provide default value of Existing if missing
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID and ((p.BLDGSTATUS is null or BLDGSTATUS = '') and f.Status is not null)
  when matched then update set BLDGSTATUS = f.Status;
update gis.AKR_BLDG_CENTER_PT_evw set BLDGSTATUS = 'Existing' where BLDGSTATUS is null or BLDGSTATUS = ''
-- 13/14) if BLDGCODE or BLDGTYPE is null but not the other replace null with lookup
--     Be sure to set BLDGCODE from BLDGTYPE before comparing BLDGCODE to FMSS (do not compare BLDGTYPE to FMSS directly)
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using DOM_BLDGCODETYPE as t2
  on t1.BLDGTYPE = t2.Type and t1.BLDGCODE is null and t1.BLDGTYPE is not null and t2.Code is not null
  when matched then update set BLDGCODE = t2.Code;
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using DOM_BLDGCODETYPE as t2
  on t1.BLDGCODE = t2.Code and t1.BLDGTYPE is null and t1.BLDGCODE is not null and t2.Type is not null
  when matched then update set  BLDGTYPE = t2.Type;
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT DOI_Code, Location FROM dbo.FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID and (p.BLDGCODE is null and f.DOI_Code is not null)
  when matched then update set BLDGCODE = f.DOI_Code;
-- 15) if FACOWNER is null and FACLOCID is non-null use FMSS Lookup.
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT Asset_Ownership, Location FROM dbo.FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID and (p.FACOWNER is null and f.Asset_Ownership is not null)
  when matched then update set FACOWNER = f.Asset_Ownership;
-- 16) if FACOCCUPANT is null and FACLOCID is non-null use FMSS Lookup.
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT Occupant, Location FROM dbo.FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID and (p.FACOCCUPANT is null and f.Occupant is not null)
  when matched then update set FACOCCUPANT = f.Occupant;
-- 17) if FACMAINTAIN is null and FACLOCID is non-null use FMSS Lookup.
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID and (p.FACMAINTAIN is null and f.FAMARESP is not null)
  when matched then update set FACMAINTAIN = f.FAMARESP;
-- 18) if FACUSE is null and FACLOCID is non-null use FMSS Lookup.
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT PRIMUSE, Location FROM dbo.FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID and (p.FACUSE is null and f.PRIMUSE is not null)
  when matched then update set FACUSE = f.PRIMUSE;
-- 19) if SEASONAL is null and FACLOCID is non-null use FMSS Lookup.
merge into gis.AKR_BLDG_CENTER_PT_evw as p
  using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
  when matched then update set SEASONAL = f.OPSEAS;
-- 20) if SEASDESC is an empty string, change to NULL
--     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
update gis.AKR_BLDG_CENTER_PT_evw set SEASDESC = NULL where SEASDESC = ''
update gis.AKR_BLDG_CENTER_PT_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
-- 21) ISEXTANT defaults to 'True' with a warning (during QC)
update gis.AKR_BLDG_CENTER_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
-- 22) PUBLICDISPLAY defaults to No Public Map Display
update gis.AKR_BLDG_CENTER_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL
-- 23) DATAACCESS defaults to No Public Map Display
update gis.AKR_BLDG_CENTER_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL
-- 24) UNITCODE is a spatial calc if null
-- TODO: Should we first calc from FMSS? would also need to fix qc check.  What if FMSS value is not in spatial extent?
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_UNIT as t2
  on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
  when matched then update set UNITCODE = t2.Unit_Code;
-- 25) UNITNAME is always calc'd from UNITCODE
update gis.AKR_BLDG_CENTER_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is null
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using DOM_UNITCODE as t2
  on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
  when matched then update set UNITNAME = t2.UNITNAME;
--  TODO: Should we get UNITNAME from AKR_UNIT or DOM_UNITCODE?  Unit codes and Names differ
--  merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_UNIT as t2
--    on t1.UNITCODE = t2.Unit_Code and t1.UNITNAME <> t2.UNIT_NAME
--    when matched then update set UNITNAME = t2.UNIT_NAME;
-- 26) if GROUPCODE is an empty string, change to NULL
update gis.AKR_BLDG_CENTER_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
-- 27) GROUPNAME is always calc'd from GROUPCODE
update gis.AKR_BLDG_CENTER_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_GROUP as t2
  on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
  when matched then update set GROUPNAME = t2.Group_Name;
-- 28) REGIONCODE is always set to AKR
update gis.AKR_BLDG_CENTER_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
-- 29) if FACLOCID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set FACLOCID = NULL where FACLOCID = ''
-- 30) if FACASSETID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set FACASSETID = NULL where FACASSETID = ''
-- 31) if CRID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set CRID = NULL where CRID = ''
-- 32) if ASMISID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set ASMISID = NULL where ASMISID = ''
-- 33) if CLIID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set CLIID = NULL where CLIID = ''
-- 34) if LCSID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set LCSID = NULL where LCSID = ''
-- 35) if FIREBLDGID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set FIREBLDGID = NULL where FIREBLDGID = ''
-- 36) if PARKBLDGID is empty string change to null
update gis.AKR_BLDG_CENTER_PT_evw set PARKBLDGID = NULL where PARKBLDGID = ''
-- 37) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
--     TODO: for more accuracy, use the building footprint (some footprints in Skagway straddle the boundary)
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK)
  when matched then update set ISOUTPARK = CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END;

-- Stop editing
exec sde.edit_version @version, 2; -- 2 to stop edits
