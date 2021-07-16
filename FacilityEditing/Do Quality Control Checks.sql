-- Building QC Queries
-- This script will check an editor's version for errors and issues.
-- It must be run on a editor's version and all errors resolved before the version to posting to DEFAULT.
-- After all errors are resolved, run the Calculate script before posting.


-- 1) List the named versions (select the following line and press F5 or the Execute button)
select owner, name from akr_facility2.sde.SDE_versions where parent_version_id is not null order by owner, name

-- 2) Set the operable version to a named version
--    Edit 'owner.name' to be one of the versions in the previous list, then select and execute the following line
exec akr_facility2.sde.set_current_version 'owner.name';
-- OR set the operable version to default
-- exec akr_facility2.sde.set_default
-- Do the same for the akr_socio database (for matching POI records for building centers and trail side features)
--   IMPORTANT:
--   As of 2021-07-16: When a source and a destination version are set, then source version view pulls from the source base table,
--   not the version or even default view. This appears to be a bug. Work around is to compress to state zero so that the source
--   version is in the base table.  Other solutions may be:
--      1) set master as current database, and run all queries with fully qualified view names
--      2) Upgrade the geodatabase on akr_socio (it is still at 10.2, while facilities is at 10.8)
exec akr_socio.sde.set_default
-- OR set to a specific facility version
-- exec akr_socio.sde.set_current_version 'owner.name';

-- 3) Select each of the following lines and then press F5 (or the Execute button)
--    If there are issues, then either email (copy/paste or save as csv) or describe them to the editor
--    If they are lengthy and complicated, save the issues into a table (the commented out lines) that the user can add to a map
--    Once the issues are corrected (or explained), delete those temporary tables.

select * from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_OTHER_PY
-- Create a table of issues
-- drop table QC_ISSUES_AKR_BLDG_OTHER_PY_for_owner_on_date
-- select * into QC_ISSUES_AKR_BLDG_OTHER_PY_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_OTHER_PY
select * from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_FOOTPRINT_PY
-- Create a table of issues
-- drop table QC_ISSUES_AKR_BLDG_FOOTPRINT_PY_for_owner_on_date
-- select * into QC_ISSUES_AKR_BLDG_FOOTPRINT_PY_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_FOOTPRINT_PY
select * from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_OTHER_PT
-- Create a table of issues
-- drop table QC_ISSUES_AKR_BLDG_OTHER_PT_for_owner_on_date
-- select * into QC_ISSUES_AKR_BLDG_OTHER_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_OTHER_PT
select * from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_CENTER_PT
-- Create a table of issues
-- drop table QC_ISSUES_AKR_BLDG_CENTER_PT_for_owner_on_date
-- select * into QC_ISSUES_AKR_BLDG_CENTER_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_BLDG_CENTER_PT
select * from akr_facility2.dbo.QC_ISSUES_PARKLOTS_PY
-- Create a table of issues
-- drop table QC_ISSUES_PARKLOTS_PY_for_owner_on_date
-- select * into QC_ISSUES_PARKLOTS_PY_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_PARKLOTS_PY
select * from akr_facility2.dbo.QC_ISSUES_ROADS_LN
-- Create a table of issues
-- drop table QC_ISSUES_ROADS_LN_for_owner_on_date
-- select * into QC_ISSUES_ROADS_LN_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_ROADS_LN
select * from akr_facility2.dbo.QC_ISSUES_ROADS_FEATURE_PT
-- Create a table of issues
-- drop table QC_ISSUES_ROADS_FEATURE_PT_for_owner_on_date
-- select * into QC_ISSUES_ROADS_FEATURE_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_ROADS_FEATURE_PT
select * from akr_facility2.dbo.QC_ISSUES_TRAILS_LN
-- Create a table of issues
-- drop table QC_ISSUES_TRAILS_LN_for_owner_on_date
-- select * into QC_ISSUES_TRAILS_LN_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_TRAILS_LN
select * from akr_facility2.dbo.QC_ISSUES_TRAILS_FEATURE_PT
-- Create a table of issues
-- drop table QC_ISSUES_TRAILS_FEATURE_PT_for_owner_on_date
-- select * into QC_ISSUES_TRAILS_FEATURE_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_TRAILS_FEATURE_PT
select * from akr_facility2.dbo.QC_ISSUES_TRAILS_ATTRIBUTE_PT
-- Create a table of issues
-- drop table QC_ISSUES_TRAILS_ATTRIBUTE_PT_for_owner_on_date
-- select * into QC_ISSUES_TRAILS_ATTRIBUTE_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_TRAILS_ATTRIBUTE_PT
select * from akr_facility2.dbo.QC_ISSUES_AKR_ATTACH
-- Create a table of issues
-- drop table QC_ISSUES_AKR_ATTACH_for_owner_on_date
-- select * into QC_ISSUES_AKR_ATTACH_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_ATTACH
select * from akr_facility2.dbo.QC_ISSUES_AKR_ATTACH_PT
-- Create a table of issues
-- drop table QC_ISSUES_AKR_ATTACH_PT_for_owner_on_date
-- select * into QC_ISSUES_AKR_ATTACH_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_ATTACH_PT
select * from akr_facility2.dbo.QC_ISSUES_AKR_ASSET
-- Create a table of issues
-- drop table QC_ISSUES_AKR_ASSET_for_owner_on_date
-- select * into QC_ISSUES_AKR_ASSET_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_ASSET
select * from akr_facility2.dbo.QC_ISSUES_AKR_ASSET_LN
-- Create a table of issues
-- drop table QC_ISSUES_AKR_ASSET_LN_for_owner_on_date
-- select * into QC_ISSUES_AKR_ASSET_LN_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_ASSET_LN
select * from akr_facility2.dbo.QC_ISSUES_AKR_ASSET_PT
-- Create a table of issues
-- drop table QC_ISSUES_AKR_ASSET_PT_for_owner_on_date
-- select * into QC_ISSUES_AKR_ASSET_PT_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_ASSET_PT
select * from akr_facility2.dbo.QC_ISSUES_AKR_ASSET_PY
-- Create a table of issues
-- drop table QC_ISSUES_AKR_ASSET_PY_for_owner_on_date
-- select * into QC_ISSUES_AKR_ASSET_PY_for_owner_on_date from akr_facility2.dbo.QC_ISSUES_AKR_ASSET_PY

exec akr_facility2.sde.set_default
