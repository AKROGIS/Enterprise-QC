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
--       UPDATE is not allowed because the statement updates view "gis.AKR_POI_PT_evw" which participates in a join and has an INSTEAD OF UPDATE trigger.
--       The solution is to use a MERGE statement instead (https://stackoverflow.com/a/5426404/542911)

-- To edit versioned data in SQL, see this help: http://desktop.arcgis.com/en/arcmap/latest/manage-data/using-sql-with-gdbs/edit-versioned-data-using-sql-sqlserver.htm

-- This file should be run in chunks (i.e. opened in SSMS or azure data
-- studio then selecting the commands to run and press F5 or clicking the run/execute button).
-- Note that the line that declare the version will not be "remembered", so it
-- needs to be copied to locations that will allow it to be selected with the
-- commands you want to run, or delete the intervening commands.

-- 1) Find the named version
--    List the named versions (select the following line and press F5 or the Execute button)
select owner, name from sde.SDE_versions where parent_version_id is not null order by owner, name

-- 2) Set the version to fix/calculate, and calculate the features.
--    tables without changes can be removed from this list (leaving them will
--    not hurt, but take longer).
DECLARE @version nvarchar(255) = 'owner.name'

exec dbo.Calc_POI_PT @version
exec dbo.Calc_POI_LN @version
exec dbo.Calc_POI_PY @version

-- 3) Correct any changes in POI that break the synchronization with facilities.
-- These commands should work with any version of facilities, however, as of
-- July 2021, there is a bug (https://github.com/AKROGIS/Enterprise-QC/issues/4)
-- that precludes this, as a result the version is ignored and POI is synced
-- 3a )First specify the version of facilites to sync with
DECLARE @facility_version nvarchar(255) = 'owner.name'
-- 3b) Create missing POIs from the building center points and trail feature
--     points that have defined a POITYPE
exec akr_socio.dbo.Create_POI_Points @version, @facility_version
-- 3c) Update any POIs that are linked to facilities with updates to the
--     facility attributes and/or locations
exec dbo.Sync_POI_Pt_with_Buildings @version, @facility_version
exec dbo.Sync_POI_Pt_with_TrailFeatures @version, @facility_version
-- 3d) Run the following query to delete records in POI_PT with a broken link to a source record in akr_facility2
--    This only needs to be run if there are "Missing record" errors in the QC queries.
--    It should only be run after verifying that the POI record should be deleted,
--    and that there is not some other QC related problem.
exec dbo.Delete_POI_PTs_no_longer_linked_to_facilities @version, @facility_version

-- 4) Fix Create/Edit user (optional)
--   This is only required because a bug prevents the DBO from editing in ArcMap.
--   Either use Pro to do editing, or edit as SDE and then run these fixes.
exec sde.set_current_version @version
exec sde.edit_version @version, 1 -- 1 to start edits

update gis.AKR_POI_PT_evw set CREATEUSER = 'RESARWAS' where CREATEUSER = 'SDE'
update gis.AKR_POI_PT_evw set EDITUSER = 'RESARWAS' where EDITUSER = 'SDE'

exec sde.edit_version @version, 2; -- 2 to stop edits

exec sde.set_default
