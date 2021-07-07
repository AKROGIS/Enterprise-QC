-- AKR_SOCIO database cleanup

-- Change Log
-- 2021-07-06

-- Update the source DB values for buiidings (2512 fixes)
update akr_socio.gis.POI_PT
set SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT', SRCDBIDFLD = 'FEATUREID', srcdbnmfld = 'BLDGNAME'
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'

-- Update the source DB values for trail feature points (271 fixes)
update akr_socio.gis.POI_PT
set SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT', SRCDBIDFLD = 'GEOMETRYID', srcdbnmfld = 'TRLFEATNAME'
where SRCDBNAME = 'akr_facility.GIS.TRAILS_Feature_pt'

-- Normalize the building and trail GUIDs (42 fixes)
update akr_socio.GIS.POI_PT SET SRCDBIDVAL = '{' + upper(SRCDBIDVAL) + '}' 
where SRCDBNAME like 'akr%'
and len(SRCDBIDVAL) = 36

-- Normalize the FEATUREID GUIDs (42 fixes)
update akr_socio.GIS.POI_PT SET FEATUREID = '{' + upper(FEATUREID) + '}' 
where len(FEATUREID) = 36

-- Normalize the GEOMETRYID GUIDs (2 fixes)
update akr_socio.GIS.POI_PT SET GEOMETRYID = '{' + upper(GEOMETRYID) + '}' 
where len(GEOMETRYID) = 36

-- Replace empty strings with nulls
select count(*) from akr_socio.gis.POI_PT where SRCDBNMVAL = ''
Update akr_socio.gis.POI_PT set SRCDBNAME = null where SRCDBNAME = '' -- 11 fixes
Update akr_socio.gis.POI_PT set SRCDBIDFLD = null where SRCDBIDFLD = '' -- 1 fix
Update akr_socio.gis.POI_PT set SRCDBNMFLD = null where SRCDBNMFLD = '' -- 1 fix
Update akr_socio.gis.POI_PT set SRCDBIDVAL = null where SRCDBIDVAL = '' -- 1 fix
Update akr_socio.gis.POI_PT set SRCDBNMVAL = null where SRCDBNMVAL = '' -- 2 fix

-- Repeat the previous commands on the history table to keep it is sync (it is only updated when posintg a version to default)
-- At this point the history table is "identical" to the base table, so this is safe
-- In the future all changes hsould be made to a version so the changes are captured in the history

-- Update the source DB values for buiidings
update akr_socio.gis.POI_PT_H
set SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT', SRCDBIDFLD = 'FEATUREID', srcdbnmfld = 'BLDGNAME'
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'

-- Update the source DB values for trail feature points
update akr_socio.gis.POI_PT_H
set SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT', SRCDBIDFLD = 'GEOMETRYID', srcdbnmfld = 'TRLFEATNAME'
where SRCDBNAME = 'akr_facility.GIS.TRAILS_Feature_pt'

-- Normalize the building and trail GUIDs (42 fixes)
update akr_socio.GIS.POI_PT_H SET SRCDBIDVAL = '{' + upper(SRCDBIDVAL) + '}' 
where SRCDBNAME like 'akr%'
and len(SRCDBIDVAL) = 36

-- Normalize the FEATUREID GUIDs (42 fixes)
update akr_socio.GIS.POI_PT_H SET FEATUREID = '{' + upper(FEATUREID) + '}' 
where len(FEATUREID) = 36

-- Normalize the GEOMETRYID GUIDs (2 fixes)
update akr_socio.GIS.POI_PT_H SET GEOMETRYID = '{' + upper(GEOMETRYID) + '}' 
where len(GEOMETRYID) = 36

-- Replace empty strings with nulls
--select count(*) from akr_socio.gis.POI_PT where SRCDBNMVAL = ''
Update akr_socio.gis.POI_PT_H set SRCDBNAME = null where SRCDBNAME = '' -- 11 fixes
Update akr_socio.gis.POI_PT_H set SRCDBIDFLD = null where SRCDBIDFLD = '' -- 1 fix
Update akr_socio.gis.POI_PT_H set SRCDBNMFLD = null where SRCDBNMFLD = '' -- 1 fix
Update akr_socio.gis.POI_PT_H set SRCDBIDVAL = null where SRCDBIDVAL = '' -- 1 fix
Update akr_socio.gis.POI_PT_H set SRCDBNMVAL = null where SRCDBNMVAL = '' -- 2 fix


-- Create archive of POITYPES
-- The POI points for buildings that are no public map display will be deleted
-- and the POITYPE value will not be transfered to the BLDG table (BLDGS with a non-null POITYPE should be added to POI points)
select SRCDBNAME, SRCDBIDVAL, POITYPE into akr_socio.DBO.POITYPES_OF_FACILITY_ITEMS_REMOVED_FROM_POI_PT_20210706 from akr_socio.GIS.POI_PT  where SRCDBNAME like 'akr%' and PUBLICDISPLAY = 'No Public Map Display' 


-- Buildings

-- Create a list of map label updates that can be edited before being applied
select p.Publicdisplay, b.FEATUREID, p.MAPLABEL as POI_MAPLABEL, '' as unused_POI_map_label, b.MAPLABEL AS BLDG_MAPLABEL, 'Y' as USE_POI, b.BLDGSTATUS 
into akr_socio.dbo.bldg_map_label_updates
from akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
left join akr_socio.gis.POI_PT as p
-- POI_PT has duplicats that differ on ISExtant and/or iscurrentgeo
on p.SRCDBIDVAL = b.FEATUREID and p.ISEXTANT = b.ISEXTANT
where  SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
-- only pick up the changes yo a non-null label value
and p.MAPLABEL is not null and p.mapLABEL <> b.maplabel
order by p.Publicdisplay, p.MAPLABEL

-- Manually review and edit the use_POI column (Y/N), and update the POI_MAPLABEL (saving the original value in unused_POI_map_label)

-- Update facilities version
-- Create a version in akr_facilitiy2

-- with select poi_maplabel from akr_socio.dbo.bldg_map_label_updates where USE_POI = 'Y'
USE akr_facility2;

DECLARE @version nvarchar(255) = 'dbo.res_poi_labels'
exec sde.set_current_version @version
exec sde.edit_version @version, 1 -- 1 to start edits

-- can't update the view with joined data except via the merge command
merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using 
    akr_socio.dbo.bldg_map_label_updates as t2
    on t1.FEATUREID = t2.FEATUREID and t2.USE_POI = 'Y'
    when matched then update set t1.MAPLABEL = t2.POI_MAPLABEL;

exec sde.edit_version @version, 2; -- 2 to stop edits

-- Trail Features
exec sde.set_default
-- Create a list of map label updates that can be edited before being applied
select p.Publicdisplay, b.FEATUREID, p.MAPLABEL as POI_MAPLABEL, '' as unused_POI_map_label, b.MAPLABEL AS TRL_MAPLABEL, 'Y' as USE_POI 
--into akr_socio.dbo.trail_map_label_updates
from akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
left join akr_socio.gis.POI_PT as p
-- POI_PT has duplicats that differ on ISExtant and/or iscurrentgeo
on p.SRCDBIDVAL = b.GEOMETRYID and p.ISEXTANT = b.ISEXTANT
where  SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
-- only pick up the changes yo a non-null label value
and p.MAPLABEL is not null and p.mapLABEL <> b.maplabel
order by p.Publicdisplay, p.MAPLABEL

-- There is only one Trail point map label difference, so we will do it without an intermediate table
select MAPLABEL from gis.TRAILS_FEATURE_PT_evw  where FeatureID = '{0C3502C1-C5F4-4E19-90F4-C448CA10DFD7}'

DECLARE @version2 nvarchar(255) = 'dbo.res'
exec sde.set_current_version @version2
exec sde.edit_version @version2, 1 -- 1 to start edits
update gis.TRAILS_FEATURE_PT_evw set MAPLABEL = 'Morino Trailhead' where FeatureID = '{0C3502C1-C5F4-4E19-90F4-C448CA10DFD7}'
exec sde.edit_version @version2, 2; -- 2 to stop edits

-- Do QC checks and post to default


-- Create a version in Catalog for akr_socio
-- exec sde.set_default
-- exec sde.set_current_version 'dbo.res'
-- 401 items from facilities have Public Map Display, and 2383 have No Public Map Display
-- select count(*) from akr_socio.gis.akr_poi_pt_evw where SRCDBNAME like 'akr%' and PUBLICDISPLAY = 'No Public Map Display' 

DECLARE @version3 nvarchar(255) = 'dbo.res'
exec sde.set_current_version @version3
exec sde.edit_version @version3, 1 -- 1 to start edits
delete akr_socio.gis.akr_poi_pt_evw where SRCDBNAME like 'akr%' and PUBLICDISPLAY = 'No Public Map Display'
exec sde.edit_version @version3, 2; -- 2 to stop edits



-- Changes to do
-- 0) Add MapLabel from POI (and history) where bldg.maplabel is null
-- 1) remove isextant='False'
-- 2) resolve duplicate FeatureID (remove larger OID)
-- 3) Write general QC query
-- 3a) resolve issues
-- 4) write query for QC comparing facilities to POOI
-- 4a) resolve issues
-- 4b) Add POITYPE to bldgs and trail_features
-- 5) write calcs to update poi for diffs with facilities
-- 5a) update pois
-- 6) query for missing and extra POIs
-- 7) query to create a missing POI
-- 8) when adding new building w/o POITYPE, raise question do you want to add to POI?
-- 9) query about changes to public properties and public display (changes that should be reviewed)