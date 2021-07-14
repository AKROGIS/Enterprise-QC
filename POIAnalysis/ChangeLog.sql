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



-- 2021-07-07

-- I missed the map labels where bldg.maplabel is null and poi.maplabel is not null; I need to grab these from the history now

-- Missing Building map labels
select p.MAPLABEL, b.MAPLABEL
from akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
join akr_socio.gis.POI_PT_H as p
on p.SRCDBIDVAL = b.FEATUREID and p.ISEXTANT = b.ISEXTANT
and SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and p.SRCDBIDVAL <> '{2E473C2F-500C-47B7-A4C9-1D6E72F4EC7E}'  --duplicate POI will screw up the update command
and p.MAPLABEL is not null and b.maplabel is null
select SRCDBIDVAL, MAPLABEL, ISEXTANT, PUBLICDISPLAY from akr_socio.gis.POI_PT_H where SRCDBIDVAL = '{2E473C2F-500C-47B7-A4C9-1D6E72F4EC7E}'

-- Missing Trails Feature map labels
select p.MAPLABEL, b.MAPLABEL
from akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
join akr_socio.gis.POI_PT_H as p
on p.SRCDBIDVAL = b.GEOMETRYID and p.ISEXTANT = b.ISEXTANT
and SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
and p.MAPLABEL is not null and b.maplabel is null

-- Add Missing map labels to a new version
USE akr_facility2;
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec sde.set_current_version @version4
exec sde.edit_version @version4, 1 -- 1 to start edits
-- Buildings
merge into gis.AKR_BLDG_CENTER_PT_evw as b using 
    akr_socio.gis.POI_PT_H as p
    on p.SRCDBIDVAL = b.FEATUREID and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
       and p.MAPLABEL is not null and b.maplabel is null
       and p.SRCDBIDVAL <> '{2E473C2F-500C-47B7-A4C9-1D6E72F4EC7E}'
    when matched then update set b.MAPLABEL = p.MAPLABEL;
update gis.AKR_BLDG_CENTER_PT_evw set MAPLABEL = 'Richard L. Proenneke Cabin (Historic)' where FEATUREID = '{2E473C2F-500C-47B7-A4C9-1D6E72F4EC7E}'
-- Trail Features
merge into gis.TRAILS_FEATURE_PT_evw as b using 
    akr_socio.gis.POI_PT_H as p
    on p.SRCDBIDVAL = b.GEOMETRYID and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
       and p.MAPLABEL is not null and b.maplabel is null
    when matched then update set b.MAPLABEL = p.MAPLABEL;
exec sde.edit_version @version4, 2; -- 2 to stop edits


-- I need to close out all existing versions before I make the scheme change to akr_facility

-- The KATM version has conflicts due to the recent changes to the MAPLABEL
select MAPLABEL from akr_facility2.GIS.AKR_BLDG_CENTER_PT_evw where OBJECTID in (745,786,2277)
-- Reset MAPLABEL to avoid conflicts with KATM version
-- OID  | Old Facilities Value    | POI                     | Alyssa's Edits
-- 745  | Housing Unit 150        | NPS Housing Unit 150    | NPS House
-- 786  | 3rd Cabin East (Palace) | 3rd Cabin               | 3rd Cabin East (Princess Palace)
-- 2277 | <NULL>                  | King Salmon Housing 161 | NPS House
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec sde.set_current_version @version4
exec sde.edit_version @version4, 1 -- 1 to start edits
Update akr_facility2.GIS.AKR_BLDG_CENTER_PT_evw set MAPLABEL = 'Housing Unit 150' where OBJECTID = 745
Update akr_facility2.GIS.AKR_BLDG_CENTER_PT_evw set MAPLABEL = '3rd Cabin East (Palace)' where OBJECTID = 786
Update akr_facility2.GIS.AKR_BLDG_CENTER_PT_evw set MAPLABEL = NULL where OBJECTID = 2277
exec sde.edit_version @version4, 2; -- 2 to stop edits


-- Add a new POITYPE column
-- WARNING: this must be done with the esri tools to add the column to the history table and other GDB tables
-- alter table akr_facility2.GIS.AKR_BLDG_CENTER_PT add POITYPE nvarchar(50)
-- alter table akr_facility2.GIS.AKR_BLDG_CENTER_PT add POITYPE nvarchar(50)

-- Add the POITYPE data from POI_PT to akr_facility2
exec sde.set_default
select p.ISEXTANT, b.ISEXTANT, b.MAPLABEL, b.POITYPE, p.POITYPE from akr_facility2.GIS.AKR_BLDG_CENTER_PT_evw as b
join akr_socio.GIS.AKR_POI_pt_evw as p
on b.FEATUREID = p.SRCDBIDVAL
and p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and p.ISEXTANT <> b.ISEXTANT

select b.MAPLABEL, b.POITYPE, p.POITYPE from akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
join akr_socio.GIS.AKR_POI_pt_evw as p
on b.GEOMETRYID = p.SRCDBIDVAL
and p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'

USE akr_facility2;
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec sde.set_current_version @version4
exec sde.edit_version @version4, 1 -- 1 to start edits
-- Buildings
merge into gis.AKR_BLDG_CENTER_PT_evw as b using 
    akr_socio.gis.akr_POI_PT_evw as p
    on p.SRCDBIDVAL = b.FEATUREID --and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
    when matched then update set b.POITYPE = p.POITYPE;
-- Trail Features
merge into gis.TRAILS_FEATURE_PT_evw as b using 
    akr_socio.gis.akr_POI_PT_evw as p
    on p.SRCDBIDVAL = b.GEOMETRYID and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
    when matched then update set b.POITYPE = p.POITYPE;
exec sde.edit_version @version4, 2; -- 2 to stop edits

-- Add a missing MAPLABEL values due to ISEXTANT differences
USE akr_facility2;
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec sde.set_current_version @version4
exec sde.edit_version @version4, 1 -- 1 to start edits
-- Buildings
update gis.AKR_BLDG_CENTER_PT_evw set MAPLABEL = 'Baked Mountain Hut' where FEATUREID = '{48D40CE5-8EA9-4912-89B6-C6A69E093499}'
exec sde.edit_version @version4, 2; -- 2 to stop edits

-- Create a new versioned GDB table called GIS.QC_ISSUES_EXPLAINED (using ArcCatalog)
-- with the same structure as akr_facility2.GIS.QC_ISSUES_EXPLAINED
-- Create a new QC view called DBO.QC_ISSUES_POI_PT based on a similar view in akr_facility2


-- 2021-07-12

-- Update buildings (and trails) with poiname -> bldgname (or trlname) when facility value is null and poiname is not null
-- Update buildings (and trails) with poialtname -> bldgaltname (or trlaltname) when facility value is null and poiname is not null

DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.set_current_version @version4
exec akr_facility2.sde.set_current_version @version4
exec akr_facility2.sde.edit_version @version4, 1 -- 1 to start edits
-- Buildings (1 bldgname, 8 bldgaltname)
merge into akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b using 
    akr_socio.gis.akr_POI_PT_evw as p
    on p.SRCDBIDVAL = b.FEATUREID --and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
       and b.bldgname is null and p.poiname is not null
    when matched then update set b.bldgname = p.poiname;
merge into akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b using 
    akr_socio.gis.akr_POI_PT_evw as p
    on p.SRCDBIDVAL = b.FEATUREID --and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
       and b.bldgaltname is null and p.poialtname is not null
    when matched then update set b.bldgaltname = p.poialtname;
-- Trail Features (49 changes)
merge into akr_facility2.gis.TRAILS_FEATURE_PT_evw as b using 
    akr_socio.gis.akr_POI_PT_evw as p
    on p.SRCDBIDVAL = b.GEOMETRYID and p.ISEXTANT = b.ISEXTANT
       and SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
       and ((b.TRLFEATNAME is null and p.poiname is not null) or b.TRLFEATNAME <> p.poiname)
    when matched then update set b.TRLFEATNAME = p.poiname;
exec akr_facility2.sde.edit_version @version4, 2; -- 2 to stop edits

-- A miscellaneous missing Map Label (skipped before because ISEXTANT = 'False')

DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.set_current_version @version4
exec akr_facility2.sde.set_current_version @version4
exec akr_facility2.sde.edit_version @version4, 1 -- 1 to start edits
update akr_facility2.gis.AKR_BLDG_CENTER_PT_evw  set MAPLABEL = 'Frye-Bruhn Refrigerated Warehouse (Historic)' where MAPLABEL = 'Frye-Bruhn Cold Storage Building (Historic)'
exec akr_facility2.sde.edit_version @version4, 2; -- 2 to stop edits

-- Differences in ISEXTANT and PUBLICDISPLAY; Assume buildings is more accurate (it is always has a newer editdate)
-- FEATUREID                                MAPLABEL                                        POI     BLDG    POI                 BLDG
-- {244F1EBC-5994-4662-84C4-8C2F8368A206}	Crescent Lake Ranger Station	                True	True	Public Map Display	No Public Map Display
-- {48D40CE5-8EA9-4912-89B6-C6A69E093499}	Baked Mountain Hut	                            True	Partial	Public Map Display	No Public Map Display
-- {4AAFC217-F711-4E96-8DDE-9E8EB619B767}	Baked Mountain Hut #2	                        True	True	Public Map Display	No Public Map Display
-- {4DB86383-B88A-4DB7-9B84-A99A319889BB}	Baked Mountain Hut Outhouse	                    True	True	Public Map Display	No Public Map Display
-- {716D9BD2-EDB2-4688-B4E4-F62F06FBBF4A}	Frye-Bruhn Refrigerated Warehouse (Historic)	False	True	Public Map Display	Public Map Display



-- 2021-07-13

-- Run the calculation ueries to sync POI with buildings/trails
-- NOTE, due to an apparent bug, values from akr_facility2 are not read from the requested view, but from the base table
--       so we need to compress akr_facility2 to state 0 before running these calcs
-- NOTE2: these calcs have the shape calcs commented out, since those will get a manual review before a bulk update
DECLARE @version5 nvarchar(255) = 'dbo.res'
DECLARE @facility_version nvarchar(255) = 'dbo.res'
exec akr_socio.dbo.Sync_POI_Pt_with_Buildings @version5, @facility_version
exec akr_socio.dbo.Sync_POI_Pt_with_TrailFeatures @version5, @facility_version

-- POST the 371 records to DEFAULT, so they are a distinct set of changes in the history snapshot

-- Do some one time domain fixes (upgrades) that are not part of the calcs, but will create QC problems
-- replace DATAACCESS = 'Public' with DATAACCESS = 'Unrestricted'
-- Replace MAINTAINER = 'Unknown' with NULL; MAINTAINER will be assumed to contain values conistent with FACMAINTAIN (to match buildings)
--   FACMAINTAIN uses the domain akr_facility2.DOM_FACOCCUMAINT  (which does not have 'Unknown'), not akr_socio_DOM_MAINTAINER (which has Unknown)
-- Replace ISEXTANT = 'Yes' with 'True', and 'No' with 'False' to match new domain (and values in buildings)
exec akr_facility2.sde.set_current_version 'dbo.res'
exec akr_socio.sde.set_current_version 'dbo.res'
exec akr_socio.sde.set_default
select DATAACCESS, count(*) from akr_socio.gis.AKR_POI_PT_evw group by DATAACCESS
select ISEXTANT, count(*) from akr_socio.gis.AKR_POI_PT_evw group by ISEXTANT
select ISEXTANT, count(*) from akr_socio.gis.POI_PY_evw0 group by ISEXTANT
select ISEXTANT, count(*) from akr_socio.gis.POI_LN_evw0 group by ISEXTANT
select MAINTAINER, count(*) from akr_socio.gis.AKR_POI_PT_evw group by MAINTAINER
select MAINTAINER, count(*) from akr_socio.gis.POI_PY_evw0 group by MAINTAINER
select MAINTAINER, count(*) from akr_socio.gis.POI_LN_evw0 group by MAINTAINER

DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.set_current_version @version4
exec akr_socio.sde.edit_version @version4, 1 -- 1 to start edits
update akr_socio.gis.AKR_POI_PT_evw set DATAACCESS = 'Unrestricted' where DATAACCESS = 'Public' -- 17 rows
update akr_socio.gis.POI_PY_evw0 set ISEXTANT = 'True' where ISEXTANT = 'Yes' -- 52 rows
update akr_socio.gis.POI_LN_evw0 set ISEXTANT = 'True' where ISEXTANT = 'Yes' -- 58 rows
update akr_socio.gis.POI_LN_evw0 set ISEXTANT = 'False' where ISEXTANT = 'No' -- 1 row
update akr_socio.gis.AKR_POI_PT_evw set MAINTAINER = NULL where MAINTAINER = 'Unknown' -- 1737 rows
update akr_socio.gis.POI_PY_evw0 set MAINTAINER = NULL where MAINTAINER = 'Unknown'  -- 57 rows
update akr_socio.gis.POI_LN_evw0 set MAINTAINER = NULL where MAINTAINER = 'Unknown' -- 60 rows
exec akr_socio.sde.edit_version @version4, 2; -- 2 to stop edits


-- Run the queries to clean up calculated values
--  skipping POI_PT for now, because it is generating an error: Cannot insert duplicate key in object 'gis.a23'. The duplicate key value is (4641, 12556).
exec akr_socio.dbo.Calc_POI_LN @version4  -- Adds missing FEATUREID GUIDS, replaces some empty strings with NULL
exec akr_socio.dbo.Calc_POI_PY @version4 -- Adds missing FEATUREID GUIDS, fixes some incorrect UNITNAMES, corrects ISOUTPARK

-- POST all these changes to default to simplify debugging the POI_PT calc query

-- The problem with calc_poi_pt was in the MAINTAINER field it was using the wrong domain and a single poi could have multiple FMSS Maintainers, which
-- resulted in multiple joined values
-- Fixed the queries and then ran the calc queries for POI_PT and POST to default
exec akr_socio.dbo.Calc_POI_PT @version4 



-- Fix the malformed GUIDS in POI_PT (from the QC query)
--   10 have a few random lowercase letters in the FEATUREID
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.set_current_version @version4
exec akr_socio.sde.edit_version @version4, 1 -- 1 to start edits

--select FEATUREID, upper(FEATUREID) from gis.AKR_POI_PT_evw where FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
update gis.AKR_POI_PT_evw set FEATUREID = upper(FEATUREID) where FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI

-- Fix the seasonal flags that conflict with FMSS in POI_PT (use value in FMSS)
--  150 records (mostly "No" that should be "Yes") will be assigned the value in FMSS
merge into gis.AKR_POI_PT_evw as p 
  using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID and p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
  when matched then update set SEASONAL = f.OPSEAS;

exec akr_socio.sde.edit_version @version4, 2; -- 2 to stop edits

-- Run the calcs to add a default Seasonal description for the records that went from No to Yes
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.dbo.Calc_POI_PT @version4 

--  Run the sync again.  Some of the seasonal may have
exec dbo.Sync_POI_Pt_with_Buildings 'dbo.res', 'dbo.res'
exec dbo.Sync_POI_Pt_with_TrailFeatures 'dbo.res', 'dbo.res'

-- When an error originates in a building or trail feature, then there is likely an exception for the issue in akr_facility2
--   Those exceptions will need to be repeated in akr_socio
--   We could skip the QC for these related records, but that might miss other issues, so this is safer
-- The following issues are documented as issues in akr_facility2, and are repeated in akr_socio
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.set_current_version @version4
exec akr_socio.sde.edit_version @version4, 1 -- 1 to start edits

insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT',646 , 'Error: UNITCODE is not a recognized value', 'Issue derives from akr_facility2 and is documented there')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT',967 , 'Error: UNITCODE is not a recognized value', 'Issue derives from akr_facility2 and is documented there')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT',2321 , 'Error: UNITCODE is not a recognized value', 'Issue derives from akr_facility2 and is documented there')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT',2322 , 'Error: UNITCODE is not a recognized value', 'Issue derives from akr_facility2 and is documented there')

insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT', 2379, 'Error: MAINTAINER does not match FMSS.FAMARESP', 'FMSS is out of date as documented in the building exceptions')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT', 2388, 'Error: MAINTAINER does not match FMSS.FAMARESP', 'FMSS is out of date as documented in the building exceptions')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT', 2389, 'Error: MAINTAINER does not match FMSS.FAMARESP', 'FMSS is out of date as documented in the building exceptions')

insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT', 2379, 'Error: SEASONAL does not match FMSS.OPSEAS', 'FMSS is out of date as documented in the building exceptions')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT', 2388, 'Error: SEASONAL does not match FMSS.OPSEAS', 'FMSS is out of date as documented in the building exceptions')
insert into akr_socio.gis.QC_ISSUES_EXPLAINED_evw (Feature_class, Feature_oid, Issue, Explanation) VALUES ('POI_PT', 2389, 'Error: SEASONAL does not match FMSS.OPSEAS', 'FMSS is out of date as documented in the building exceptions')

exec akr_socio.sde.edit_version @version4, 2; -- 2 to stop edits


-- 2021-07-14


-- Update ISCURRENTGEO on records that need attention.
--   In all cases, the records already have ISCURRENTGEO = 'Yes' (and this field is deprecated)
--   BB = Broken link to a building record (3)
--   BT = Broken link to a trail feature record (27)
--   MB = Location (Shape) is different than the related building (28 of 67, the others are close enough < ~5m)
--   MT = Location (Shape) is different than the related trail feature (7 of 15, the others are close enough < ~5m)
DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.set_current_version @version4
exec akr_socio.sde.edit_version @version4, 1 -- 1 to start edits

-- BB
merge into akr_socio.gis.akr_POI_PT_evw as Target
  using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as Source 
  on Target.SRCDBNAME is null or Target.SRCDBNAME <> 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' or Target.SRCDBIDVAL = Source.FEATUREID
  WHEN NOT MATCHED BY Source THEN update set Target.ISCURRENTGEO = 'BB';

-- BT
merge into akr_socio.gis.akr_POI_PT_evw as Target
  using akr_facility2.gis.TRAILS_FEATURE_PT_evw as Source 
  on Target.SRCDBNAME is null or Target.SRCDBNAME <> 'akr_facility2.GIS.TRAILS_FEATURE_PT' or Target.SRCDBIDVAL = Source.GEOMETRYID
  WHEN NOT MATCHED BY Source THEN update set Target.ISCURRENTGEO = 'BT';

--MB
merge into akr_socio.gis.akr_POI_PT_evw as p
  using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
  on p.SRCDBIDVAL = b.FEATUREID and SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
  and (p.Shape.STX <> b.Shape.STX or p.Shape.STY <> b.Shape.STY)
  and abs(p.Shape.STX - b.Shape.STX)/2 + abs(p.Shape.STY - b.Shape.STY) > 5E-05
  when matched then update set ISCURRENTGEO = 'MB';

--MT
merge into akr_socio.gis.akr_POI_PT_evw as p
  using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b 
  on p.SRCDBIDVAL = b.GEOMETRYID and SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
  and (p.Shape.STX <> b.Shape.STX or p.Shape.STY <> b.Shape.STY)
  and abs(p.Shape.STX - b.Shape.STX)/2 + abs(p.Shape.STY - b.Shape.STY) > 5E-05
  when matched then update set ISCURRENTGEO = 'MT';

DECLARE @version4 nvarchar(255) = 'dbo.res'
exec akr_socio.sde.edit_version @version4, 2; -- 2 to stop edits

select * from akr_socio.dbo.QC_ISSUES_POI_PT_for_angie_on_20210713

-- POST these changes to DEFAULT


-- Changes to do
-- 4) Resolve outstanding QC issues (see akr_socio.dbo.QC_ISSUES_POI_PT_for_angie_on_20210713 or akr_socio.dbo.QC_ISSUES_POI_PT)
-- 5) Resolve the missing and shape issues
-- 6) New views for missing and extra POIs, Add to QC file
-- 7) query to create a missing POI
-- 8) when adding new building w/o POITYPE, raise question do you want to add to POI?
-- 9) query about changes to public properties and public display (changes that should be reviewed)


-- idea: Add all POI.POITYPES to BLDGS; only sync if BLDG.POITYPE is not null and PUBLIC DISPLAY = "Yes"
--   Compare PublicDisplay (bldgs to POIs), along with POITYPE to see exceptions to this idea
--   Too many (2029) mismatches with this idea; only 6 mismatches with current plan

-- What to do about POIDESC when related to a building (no matching field)
-- did not check for or correct errors in SRCDBNMVAL (maybe can be used to identify matches between bldg and POI)
-- POI_LN needs better geometry tyoe for Shape

/*
To do for Angie and/or Marty

Create a new version and do the following

Fix broken links (where ISCURRENTGEO like 'B%'); three options are:
 1) delete record
 2) correct SRCDBIDVAL
 3) remove SRCDB values (independent POI)

Research Moves (where ISCURRENTGEO like 'M%')
  Assume the source location is correct and POI location will be updated
  identify location where source bldg or trailhead is in the wrong location
  identify records where we need two different locations (I don't know how we will handle that yet)

Fix 37 QC Issues in QC_ISSUES_POI_PT_for_angie_on_20210713
    4  Error: FACLOCID is not a valid ID
    2  Error: FEATUREID is not unique
    7  Error: POITYPE is not a recognized value
    17 Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted
    1  Warning: SOURCEDATE is unexpectedly old (before 1995)
and all records in POI_LN with POITYPE = 'Road' or 'Boundary' (not a known POITYPE)
by doing either of the following:
 1) Fixing the offending value(s) in POI
 2) adding an exception in 
 3) adding missing values to the relevant DOM table


NOTES: 
* ISEXTANT and MAINTAINER have the bad domains in the GDB
  (that is the database is validated against a differnt set of domain values than ArcGIS will use)
* See akr_socio.dbo.POITYPES_OF_FACILITY_ITEMS_REMOVED_FROM_POI_PT_20210706 for POITYPES of buildings not in POI
* A building (or trail feature) that has a POITYPE but PUBLICDISPLAY = 'No public map display' may be retained in POI_PT, but will not be displayed
* If a building (or trail feature) gets a POITYPE (i.e POITYPE was null and is now not null), then the facility feature should be added to POI_PT
* If a building (or trail feature) loses a POITYPE (i.e POITYPE was not null and is now null), then the facility feature should be removed from POI_PT

*/
