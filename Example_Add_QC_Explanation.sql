--select top 1 * from gis.QC_ISSUES_EXPLAINED_evw

DECLARE @version nvarchar(500) = 'owner.version'
exec sde.set_current_version @version
exec sde.edit_version @version, 1 -- 1 to start edits

INSERT INTO gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation)
VALUES ('AKR_BLDG_CENTER_PT', 721, 
  'Error: BLDGSTATUS does not match the FMSS Status',
  'FMSS is out of date, GIS is correct per field visit');

exec sde.edit_version @version, 2; -- 2 to stop edits
