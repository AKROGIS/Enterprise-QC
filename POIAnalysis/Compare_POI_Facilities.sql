-- List of POI Sources, ordered by popularity
select srcDBname, srcdbidfld, srcdbnmfld, count(*) as Count from gis.POI_PT
group by srcDBname, srcdbidfld, srcdbnmfld
order by count(*) desc -- srcDBname, srcdbidfld, srcdbnmfld

-- List of facility sources by popularity
select srcdbname, srcdbidfld, count(*) from gis.POI_PT
where srcdbname like 'akr_facility%' group by srcdbname, srcdbidfld order by count(*) desc

-- List of facility types by popularity
select srcdbname, POITYPE, count(*) from gis.POI_PT
where srcdbname like 'akr_facility%' group by srcdbname, POITYPE order by count(*) desc


-- BUILDINGS

-- Update the source DB values for buiidings
--update akr_socio.gis.POI_PT
--set SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT', SRCDBIDFLD = 'FEATUREID', srcdbnmfld = 'BLDGNAME'
--where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'

-- Normalize the building GUIDs
select FEATUREID, '{' + upper(FEATUREID) + '}' from akr_socio.GIS.POI_PT
-- update akr_socio.GIS.POI_PT SET FEATUREID = '{' + upper(FEATUREID) + '}' 
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building' and srcDBIDfld = 'BUILDING_ID'
and len(FEATUREID) = 36


-- POIs with broken links to buildings in akr_facilities (199 of 2512, 42 of which may be due to denormalized GUID)
select p.FEATUREID, p.MAPLABEL from akr_socio.gis.POI_PT as p
left join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where b.FEATUREID is null
and p.SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'
order by p.FEATUREID


-- Existing buildings within park boundary but not in POI (737)
-- This is expected, because admin buildings are not POIs
select b.FEATUREID, b.MAPLABEL, b.BLDGNAME from akr_socio.gis.POI_PT as p
Right join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBIDVAL is null
and b.ISEXTANT = 'True'
and b.BLDGSTATUS = 'Existing'
and b.ISOUTPARK = 'No'


-- Compare POIs with buildings (old facility link) (2313)
select p.MAPLABEL, b.MAPlabel, p.poiname, b.BLDGNAME, p.poialtname, b.BLDGALTNAME, p.POITYPE, b.BLDGTYPE from akr_socio.gis.POI_PT as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'

-- Compare POIs with buildings (new facility link) (1)
select p.MAPLABEL, b.MAPlabel, p.poiname, b.BLDGNAME, p.poialtname, b.BLDGALTNAME, p.POITYPE, b.BLDGTYPE from akr_socio.gis.POI_PT as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'


-- building map labels that do not match poi map label (312)
-- Recommend updating buidings map label with the value in POI map label
-- Therefore I am ignoring null building map labels
select p.MAPLABEL as [POI Map Label], b.MAPlabel as [buidling map label]from akr_socio.gis.POI_PT as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'
and ((p.MAPLABEL is null and b.MAPLABEL is not null) or p.MAPLABEL <> b.MAPLABEL) --  or (p.MAPLABEL is not null and b.MAPLABEL is null))


-- building names that do not match poi map label (467)
-- Recommend updating POI with the values in buildings
-- Terefore I am ignoring null POI Names
select p.poiname, b.BLDGNAME from akr_socio.gis.POI_PT as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'
and ((p.POINAME is not null and b.bldgname is null) or p.POINAME <> b.BLDGNAME) -- or (p.POINAME is null and b.bldgname is not null))


-- Compare building types with POI Type
-- POI type to BLDGTYPE Crosswalk
select p.POITYPE, b.BLDGTYPE, count(*) as Qty from akr_socio.gis.POI_PT as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building' OR SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
group by p.POITYPE, b.BLDGTYPE

-- Compare Location (305 issues, 50 significant)
select p.featureid, p.poiname, p.poitype,
round((p.Shape.STY - b.Shape.STY)*111319,1) as Lat_Diff_m,
round((p.Shape.STX - b.Shape.STX)*111319 * cos(p.Shape.STY*3.1415926/180),1) as Long_diff_m
from akr_socio.gis.POI_PT as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where (SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building' OR SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT')
 and (p.Shape.STX <> b.Shape.STX or p.Shape.STY <> b.Shape.STY)
order by abs(p.Shape.STX - b.Shape.STX)/2 + abs(p.Shape.STY - b.Shape.STY) desc




-- TRAIL FEATURE POINTS

-- Update the source DB values for buiidings
--update akr_socio.gis.POI_PT
--set SRCDBNAME = 'akr_facility2.GIS.TRAILS_Feature_pt', SRCDBIDFLD = 'GEOMETRYID', srcdbnmfld = 'TRLFEATNAME'
--where SRCDBNAME = 'akr_facility.GIS.TRAILS_Feature_pt'


-- POIs with broken links to trail feature points in akr_facilities (59 out of 270)
select p.FEATUREID, p.MAPLABEL from akr_socio.gis.POI_PT as p
left join akr_facility2.gis.TRAILS_FEATURE_PT_evw as t 
on p.SRCDBIDVAL = t.GEOMETRYID
where t.GEOMETRYID is null
and p.SRCDBNAME = 'akr_facility.GIS.TRAILS_Feature_pt'
order by p.FEATUREID

-- sample trail feature points
--select top 10 * from akr_facility2.gis.TRAILS_FEATURE_PT_evw 

-- Compare all poi and building names (212)
select p.MAPLABEL, t.MAPlabel, p.poiname, t.TRLFEATNAME, p.poialtname, t.TRLFEATALTNAME from akr_socio.gis.POI_PT as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility.GIS.TRAILS_Feature_pt'

--Suggest overwrite the maplabel and trlfeatname in trail_feature_pt with the POI values
select p.MAPLABEL as [POI map label], t.MAPlabel as [trail map label] from akr_socio.gis.POI_PT as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility.GIS.TRAILS_Feature_pt'
and t.MAPLABEL is not null and p.maplabel <> t.maplabel

select p.POINAME, TRLFEATNAME from akr_socio.gis.POI_PT as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility.GIS.TRAILS_Feature_pt'
and t.TRLFEATNAME is not null and p.POINAME <> t.TRLFEATNAME

-- Compare type
select p.POITYPE, TRLFEATTYPE, count(*) as Qty from akr_socio.gis.POI_PT as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility.GIS.TRAILS_Feature_pt'
group by p.POITYPE, TRLFEATTYPE

-- Compare Location (35 issues, 9 significant)
select p.featureid, p.poiname, p.poitype,
round((p.Shape.STY - t.Shape.STY)*111319,1) as Lat_Diff_m,
round((p.Shape.STX - t.Shape.STX)*111319 * cos(p.Shape.STY*3.1415926/180),1) as Long_diff_m
from akr_socio.gis.POI_PT as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility.GIS.TRAILS_Feature_pt' and (p.Shape.STX <> t.Shape.STX or p.Shape.STY <> t.Shape.STY)
order by abs(p.Shape.STX - t.Shape.STX)/2 + abs(p.Shape.STY - t.Shape.STY) desc