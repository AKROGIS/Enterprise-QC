-- Building QC Queries
-- This script will check an editor's version for errors and issues.
-- It must be run on a editor's version and all errors resolved before the version to posting to DEFAULT.
-- After all errors are resolved, run the Calculate script before posting.


-- 1) List the named versions (select the following line and press F5 or the Execute button)
select owner, name from akr_facility2.sde.SDE_versions where parent_version_id is not null order by owner, name

-- 2) Set the versions to check
-- 2a) first set the version of the related features.  Due a [bug](https://github.com/AKROGIS/Enterprise-QC/issues/4),
--     the first version set will be ignored and the query will compare against the base table of the related features.
exec akr_socio.sde.set_default;
--   OR set to a specific socio version
--   exec akr_socio.sde.set_current_version 'owner.name';
-- 2b) Set the version of the database to be checked
exec akr_facility2.sde.set_current_version 'owner.name';
--   OR set the operable version to default
--   exec akr_facility2.sde.set_default

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
