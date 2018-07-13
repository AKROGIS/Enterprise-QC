-- Building QC Queries
-- This script will check an editor's version for errors and issues.
-- It must be run on a editor's version and all errors resolved before the version to posting to DEFAULT.
-- After all errors are resolved, run the Calculate script before posting.


-- 1) List the named versions (select the following line and press F5 or the Execute button)
select owner, name from sde.SDE_versions where parent_version_id is not null order by owner, name

-- 2) Set the operable version to a named version
--    Edit 'owner.name' to be one of the versions in the previous list, then select and execute the following line
exec sde.set_current_version 'owner.name';
-- OR set the operable version to default
-- exec sde.set_default

-- 3) Select each of the following lines and then press F5 (or the Execute buttton)
--    If there are issues, then either email (copy/paste or save as csv) or describe them to the editor
--    If they are lengthy and complicated, save the issues into a table (the commented out lines) that the user can add to a map
--    Once the issues are corrected (or explained), delete those temporary tables.

select * from dbo.QC_ISSUES_AKR_BLDG_OTHER_PY
-- Create a table of issues
-- select * into QC_ISSUES_AKR_BLDG_OTHER_PY_for_owner_on_date from dbo.QC_ISSUES_AKR_BLDG_OTHER_PY
select * from dbo.QC_ISSUES_AKR_BLDG_FOOTPRINT_PY
-- Create a table of issues
-- select * into QC_ISSUES_AKR_BLDG_FOOTPRINT_PY_for_owner_on_date from dbo.QC_ISSUES_AKR_BLDG_FOOTPRINT_PY
select * from dbo.QC_ISSUES_AKR_BLDG_OTHER_PT
-- Create a table of issues
-- select * into QC_ISSUES_AKR_BLDG_OTHER_PT_for_owner_on_date from dbo.QC_ISSUES_AKR_BLDG_OTHER_PT
select * from dbo.QC_ISSUES_AKR_BLDG_CENTER_PT
-- Create a table of issues
-- select * into QC_ISSUES_AKR_BLDG_CENTER_PT_for_owner_on_date from dbo.QC_ISSUES_AKR_BLDG_CENTER_PT
select * from dbo.QC_ISSUES_PARKLOTS_PY
-- Create a table of issues
-- select * into QC_ISSUES_PARKLOTS_PY_for_owner_on_date from dbo.QC_ISSUES_PARKLOTS_PY
select * from dbo.QC_ISSUES_ROADS_LN
-- Create a table of issues
-- select * into QC_ISSUES_ROADS_LN_for_owner_on_date from dbo.QC_ISSUES_ROADS_LN
select * from dbo.QC_ISSUES_TRAILS_LN
-- Create a table of issues
-- select * into QC_ISSUES_TRAILS_LN_for_owner_on_date from dbo.QC_ISSUES_TRAILS_LN
select * from dbo.QC_ISSUES_TRAILS_FEATURE_PT
-- Create a table of issues
-- select * into QC_ISSUES_TRAILS_FEATURE_PT_for_owner_on_date from dbo.QC_ISSUES_TRAILS_FEATURE_PT
select * from dbo.QC_ISSUES_TRAILS_ATTRIBUTE_PT
-- Create a table of issues
-- select * into QC_ISSUES_TRAILS_ATTRIBUTE_PT_for_owner_on_date from dbo.QC_ISSUES_TRAILS_ATTRIBUTE_PT

exec sde.set_default
