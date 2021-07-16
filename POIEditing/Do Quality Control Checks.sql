-- Building QC Queries
-- This script will check an editor's version for errors and issues.
-- It must be run on a editor's version and all errors resolved before the version to posting to DEFAULT.
-- After all errors are resolved, run the Calculate script before posting.


-- 1) List the named versions (select the following line and press F5 or the Execute button)
select owner, name from akr_socio.sde.SDE_versions where parent_version_id is not null order by owner, name

-- 2) Set the versions to check
-- 2a) first set the version of the related features.  Due a [bug](https://github.com/AKROGIS/Enterprise-QC/issues/4),
--     the first version set will be ignored and the query will compare against the base table of the related features.
exec akr_facility2.sde.set_default;
--   OR set to a specific facility version
--   exec akr_facility2.sde.set_current_version 'owner.name';
-- 2b) Set the version of the database to be checked
exec akr_socio.sde.set_current_version 'owner.name';
--   OR set the operable version to default
--   exec akr_socio.sde.set_default

-- 3) Select each of the following lines and then press F5 (or the Execute button)
--    If there are issues, then either email (copy/paste or save as csv) or describe them to the editor
--    If they are lengthy and complicated, save the issues into a table (the commented out lines) that the user can add to a map
--    Once the issues are corrected (or explained), delete those temporary tables.

select * from akr_socio.dbo.QC_ISSUES_POI_PT
-- Create a table of issues
-- drop table QC_ISSUES_POI_PT_for_owner_on_date
-- select * into QC_ISSUES_POI_PT_for_owner_on_date from akr_socio.dbo.QC_ISSUES_POI_PT
select * from akr_socio.dbo.QC_ISSUES_POI_LN
-- Create a table of issues
-- drop table QC_ISSUES_POI_LN_for_owner_on_date
-- select * into QC_ISSUES_POI_LN_for_owner_on_date from akr_socio.dbo.QC_ISSUES_POI_LN
select * from akr_socio.dbo.QC_ISSUES_POI_PY
-- Create a table of issues
-- drop table QC_ISSUES_POI_PY_for_owner_on_date
-- select * into QC_ISSUES_POI_PY_for_owner_on_date from akr_socio.dbo.QC_ISSUES_POI_PY

exec akr_socio.sde.set_default
