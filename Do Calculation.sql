-- Calculation Queries
-- This script will calculate derivable values for fields left null by the editor
-- You must check and resolve all QC issues before running this script
-- This script must be run on a editor's version before posting.
-- It must be run by a DBO outside of ArcGIS to avoid messing up the edit user/date and archive dates
-- Must run QC check after to make sure we didn't create a problem
--   (if there are new QC issues, then it is bug in our QC check;  In addition to fixing any issues, fix the QC check to alert the user
--    to the issue that will arise after running the calc.)
-- You will need to exec sde.set_default then re-exec sde.edit_version in order for the QC to get the latest;
-- For ArcMap change version to default, and then change back to named edit version to see the changes.

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

exec dbo.Calc_Asset @version
exec dbo.Calc_Asset_Ln @version
exec dbo.Calc_Asset_Pt @version
exec dbo.Calc_Asset_Py @version
exec dbo.Calc_Attachments @version
exec dbo.Calc_Buildings @version
exec dbo.Calc_ParkingLots @version
exec dbo.Calc_Roads @version
exec dbo.Calc_Road_Features @version
exec dbo.Calc_Trails @version
exec dbo.Calc_Trail_Features @version
exec dbo.Calc_Trail_Attributes @version

-- Calcs to fix The fact that Regan has to edit as SDE and not Domain User
exec sde.set_current_version @version
exec sde.edit_version @version, 1 -- 1 to start edits

update gis.AKR_BLDG_CENTER_PT_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.AKR_BLDG_CENTER_PT_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.AKR_BLDG_FOOTPRINT_PY_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.AKR_BLDG_FOOTPRINT_PY_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.AKR_ATTACH_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.AKR_ATTACH_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.AKR_ATTACH_PT_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.AKR_ATTACH_PT_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.PARKLOTS_PY_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.PARKLOTS_PY_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.ROADS_LN_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.ROADS_LN_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.TRAILS_LN_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.TRAILS_LN_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.TRAILS_ATTRIBUTE_PT_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.TRAILS_ATTRIBUTE_PT_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'
update gis.TRAILS_FEATURE_PT_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.TRAILS_FEATURE_PT_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'

exec sde.edit_version @version, 2; -- 2 to stop edits

exec sde.set_default
