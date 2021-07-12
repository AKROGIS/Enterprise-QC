exec sde.set_default
--exec akr_socio.sde.set_current_version 'dbo.res'
--exec akr_facility2.sde.set_current_version 'dbo.res'

-- List of POI Sources, ordered by popularity
select srcDBname, srcdbidfld, srcdbnmfld, count(*) as Count from gis.akr_POI_PT_evw
group by srcDBname, srcdbidfld, srcdbnmfld
order by count(*) desc -- srcDBname, srcdbidfld, srcdbnmfld

-- List of facility sources by popularity
select srcdbname, srcdbidfld, count(*) from gis.akr_POI_PT_evw
where srcdbname like 'akr_facility%' group by srcdbname, srcdbidfld order by count(*) desc

-- List of facility types by popularity
select srcdbname, POITYPE, count(*) from gis.akr_POI_PT_evw
where srcdbname like 'akr_facility%' group by srcdbname, POITYPE order by count(*) desc


-- BUILDINGS

-- Update the source DB values for buiidings
--update akr_socio.gis.akr_POI_PT_evw
--set SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT', SRCDBIDFLD = 'FEATUREID', srcdbnmfld = 'BLDGNAME'
--where SRCDBNAME = 'akr_facility.GIS.Building_Point, akr_facility.GIS.Building'

-- Normalize the building GUIDs
select FEATUREID, '{' + upper(FEATUREID) + '}' from akr_socio.gis.POI_PT
-- update akr_socio.gis.POI_PT SET FEATUREID = '{' + upper(FEATUREID) + '}' 
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and srcDBIDfld = 'FEATUREID'
and len(FEATUREID) = 36


-- POIs with broken links to buildings in akr_facilities (3 of 324)
select p.FEATUREID, p.MAPLABEL, p.ISEXTANT, p.ISCURRENTGEO from akr_socio.gis.akr_POI_PT_evw as p
left join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where b.FEATUREID is null
and p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
-- many broken links are due to removing iscurrentgeo = 'No' and ISEXTANT = 'False' from akr_facility2
-- these will be deleted from POI_PTs, as will those with PUBLICDISPLAY = 'No Public Map Display'
-- and p.ISEXTANT = 'True' and (ISCURRENTGEO = 'Yes' or ISCURRENTGEO is null) and p.PUBLICDISPLAY = 'Public Map Display'
order by p.FEATUREID


-- Existing buildings within park boundary but not in POI (1512)
-- This is expected, because admin buildings are not POIs
select b.FEATUREID, b.MAPLABEL, b.BLDGNAME from akr_socio.gis.akr_POI_PT_evw as p
Right join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBIDVAL is null
and b.ISEXTANT = 'True'
and b.BLDGSTATUS = 'Existing'
and b.ISOUTPARK = 'No'


-- Compare POIs with buildings (324)
select p.MAPLABEL, b.MAPlabel, p.poiname, b.BLDGNAME, p.poialtname, b.BLDGALTNAME, p.POITYPE, b.BLDGTYPE from akr_socio.gis.akr_POI_PT_evw as p
left join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
order by p.SRCDBIDVAL

-- Compare POIs with buildings - ISEXTANT Issues (5 of 324)
select p.SRCDBIDVAL, b.FEATUREID, p.MAPLABEL, b.MAPlabel, p.poiname, b.BLDGNAME, p.poialtname, b.BLDGALTNAME, p.POITYPE, b.POITYPE, b.BLDGTYPE, p.ISEXTANT, b.ISEXTANT
from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.isextant is null and b.isextant is not null) or p.isextant <> b.isextant or (p.isextant is not null or b.isextant is null)
  OR (p.PUBLICDISPLAY is null and b.PUBLICDISPLAY is not null) or p.PUBLICDISPLAY <> b.PUBLICDISPLAY or (p.PUBLICDISPLAY is not null or b.PUBLICDISPLAY is null))
order by p.SRCDBIDVAL

-- Compare bldgs to POIs based on Public Display and POITYPE; use history (before purge on 7/7/21)
-- 2029 bldg items in POI with POITYPE and No Public Map Display where bldg has Public Map Display
-- 4 bldgs with POITYPE and No Public Map Display where (POI has Public Map Display)
-- 7 mis matches in PUBLICDISPLAY when building has a POITYPE
select p.PUBLICDISPLAY, b.PUBLICDISPLAY, p.POITYPE, b.POITYPE, p.SRCDBIDVAL, b.FEATUREID, p.MAPLABEL, b.MAPlabel,
       p.poiname, b.BLDGNAME, p.poialtname, b.BLDGALTNAME, b.BLDGTYPE, p.ISEXTANT, b.ISEXTANT
from akr_socio.gis.POI_PT_H as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and p.GDB_FROM_DATE < '2021-07-06' and p.GDB_TO_DATE > '2021-07-06'
and p.PUBLICDISPLAY <> b.PUBLICDISPLAY
and b.POITYPE is not null
order by b.PUBLICDISPLAY

-- Non-unique GUIDS (2)
select FEATUREID, count(FEATUREID) from akr_socio.GIS.akr_POI_PT_evw group by FEATUREID having count(FEATUREID) > 1
select GEOMETRYID, count(GEOMETRYID) from akr_socio.GIS.akr_POI_PT_evw group by GEOMETRYID having count(GEOMETRYID) > 1
select srcdbname, SRCDBIDVAL, count(*) from akr_socio.GIS.akr_POI_PT_evw group by srcdbname, SRCDBIDVAL having count(*) > 1 and srcdbname like 'akr%'
select * from akr_socio.GIS.akr_POI_PT_evw where featureid = '{DDC4471D-2A47-487F-A9B1-CD0611B5F24A}'


-- building map labels that do not match poi map label (5) by choice
-- Recommend updating buidings map label with the value in POI map label
-- Therefore I am ignoring null building map labels
select p.MAPLABEL as [POI Map Label], b.MAPlabel as [buidling map label]from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.MAPLABEL is null and b.MAPLABEL is not null) or p.MAPLABEL <> b.MAPLABEL) --  or (p.MAPLABEL is not null and b.MAPLABEL is null))

-- building names that do not match poiname (133 total, 1 where bldgname is null)
-- Recommend updating bldgname when null and poiname is not null
-- otherwise, all poinmames get replaced with the bldgname
select p.poiname, b.bldgname from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.poiname is not null and b.bldgname is null) or p.poiname <> b.bldgname) --  or (p.poiname is null and b.bldgname is not null))
order by b.bldgname

-- building alt names that do not match poi alt name (8 total, all where bldgaltname is null)
-- Recommend updating bldgaltname when null and poialtname is not null
-- otherwise, all poialtnames get replaced with the bldgaltnames
select p.poialtname, b.bldgaltname from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.poialtname is not null and b.bldgaltname is null) or p.poialtname <> b.bldgaltname) --  or (p.poialtname is null and b.bldgaltname is not null))
order by b.bldgaltname

-- Public Display and IsExtant differences between buildings and POIs (5 of 324)
select b.FEATUREID, p.MAPLABEL, p.ISEXTANT, b.ISEXTANT, p.PUBLICDISPLAY, b.PUBLICDISPLAY, p.EDITDATE, b.editdate
from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.isextant is null and b.isextant is not null) or p.isextant <> b.isextant or (p.isextant is not null and b.isextant is null)
  OR (p.PUBLICDISPLAY is null and b.PUBLICDISPLAY is not null) or p.PUBLICDISPLAY <> b.PUBLICDISPLAY or (p.PUBLICDISPLAY is not null and b.PUBLICDISPLAY is null))
order by p.SRCDBIDVAL


-- building names that do not match poi map label (133)
-- Recommend updating POI with the values in buildings
-- Terefore I am ignoring null POI Names
select p.poiname, b.BLDGNAME from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.POINAME is not null and b.bldgname is null) or p.POINAME <> b.BLDGNAME) -- or (p.POINAME is null and b.bldgname is not null))


-- Compare building types with POI Type
-- POI type to BLDGTYPE Crosswalk
select p.POITYPE, b.BLDGTYPE, count(*) as Qty from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
group by p.POITYPE, b.BLDGTYPE

-- building POITYPE that do not match poi POITYPE (0)
-- Recommend updating POI with the values in buildings
-- Terefore I am ignoring null POI Names
select p.POITYPE, b.POITYPE from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
and ((p.POITYPE is not null and b.POITYPE is null) or p.POITYPE <> b.POITYPE or (p.POITYPE is null and b.POITYPE is not null))

-- Compare Location (67 issues, 22 significant)
select p.featureid, p.poiname, p.poitype,
round((p.Shape.STY - b.Shape.STY)*111319,1) as Lat_Diff_m,
round((p.Shape.STX - b.Shape.STX)*111319 * cos(p.Shape.STY*3.1415926/180),1) as Long_diff_m
from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'
 and (p.Shape.STX <> b.Shape.STX or p.Shape.STY <> b.Shape.STY)
order by abs(p.Shape.STX - b.Shape.STX)/2 + abs(p.Shape.STY - b.Shape.STY) desc




-- TRAIL FEATURE POINTS

-- Update the source DB values for trail feature points
--update akr_socio.gis.akr_POI_PT_evw
--set SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT', SRCDBIDFLD = 'GEOMETRYID', srcdbnmfld = 'TRLFEATNAME'
--where SRCDBNAME = 'akr_facility.GIS.TRAILS_Feature_pt'


-- POIs with broken links to trail feature points in akr_facilities (27 out of 77)
select p.FEATUREID, p.MAPLABEL from akr_socio.gis.akr_POI_PT_evw as p
left join akr_facility2.gis.TRAILS_FEATURE_PT_evw as t 
on p.SRCDBIDVAL = t.GEOMETRYID
where t.GEOMETRYID is null
and p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_Feature_pt'
order by p.FEATUREID

-- sample trail feature points
--select top 10 * from akr_facility2.gis.TRAILS_FEATURE_PT_evw 

-- Compare all poi and trail names (50 out of 77)
select p.MAPLABEL, t.MAPlabel, p.poiname, t.TRLFEATNAME, p.poialtname, t.TRLFEATALTNAME from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility2.GIS.TRAILS_Feature_pt'

--Suggest overwrite the maplabel and trlfeatname in trail_feature_pt with the POI values (0)
select p.MAPLABEL as [POI map label], t.MAPlabel as [trail map label] from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility2.GIS.TRAILS_Feature_pt'
and ((p.MAPLABEL is null and t.MAPLABEL is not null) or p.MAPLABEL <> t.MAPLABEL) --  or (p.MAPLABEL is not null and t.MAPLABEL is null))

-- fix poiname (24)
select p.POINAME, TRLFEATNAME from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility2.GIS.TRAILS_Feature_pt'
and t.TRLFEATNAME is not null and p.POINAME <> t.TRLFEATNAME

-- Trail feature names that do not match poiname (49 total, 25 where bldgname is null)
-- Recommend updating TRLFEATNAME in all cases, in the future, 
-- poinmames get replaced with the TRLFEATNAME
select p.poiname, b.TRLFEATNAME from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw as b 
on p.SRCDBIDVAL = b.GEOMETRYID
where SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
and ((p.poiname is not null and b.TRLFEATNAME is null) or p.poiname <> b.TRLFEATNAME) --  or (p.poiname is null and b.TRLFEATNAME is not null))
order by b.TRLFEATNAME

-- trail feature alt names that do not match poi alt name (0)
-- IN the future all poialtnames get replaced with the TRLFEATALTNAME
select p.poialtname, b.TRLFEATALTNAME from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw as b 
on p.SRCDBIDVAL = b.GEOMETRYID
where SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
and ((p.poialtname is not null and b.TRLFEATALTNAME is null) or p.poialtname <> b.TRLFEATALTNAME) --  or (p.poialtname is null and b.TRLFEATALTNAME is not null))
order by b.TRLFEATALTNAME

-- trail feature desc that do not match poi desc (0)
-- In the future all poidesc get replaced with the TRLFEATDESC
select p.poidesc, b.TRLFEATDESC from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw as b 
on p.SRCDBIDVAL = b.GEOMETRYID
where SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'
and ((p.poidesc is not null and b.TRLFEATDESC is null) or p.poidesc <> b.TRLFEATDESC) --  or (p.poidesc is null and b.TRLFEATDESC is not null))
order by b.TRLFEATDESC

-- Compare type
select p.POITYPE, TRLFEATTYPE, t.poitype, count(*) as Qty from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility2.GIS.TRAILS_Feature_pt'
group by p.POITYPE, TRLFEATTYPE, t.poitype

-- Public Display and IsExtant differences between trail features and POIs (0)
select b.FEATUREID, p.MAPLABEL, p.ISEXTANT, b.ISEXTANT, p.PUBLICDISPLAY, b.PUBLICDISPLAY
from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_Feature_pt_evw as b 
on p.SRCDBIDVAL = b.FEATUREID
where p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_Feature_pt'
and ((p.isextant is null and b.isextant is not null) or p.isextant <> b.isextant or (p.isextant is not null and b.isextant is null)
  OR (p.PUBLICDISPLAY is null and b.PUBLICDISPLAY is not null) or p.PUBLICDISPLAY <> b.PUBLICDISPLAY or (p.PUBLICDISPLAY is not null and b.PUBLICDISPLAY is null))
order by p.SRCDBIDVAL

-- Compare Location (15 issues, 4 significant)
select p.featureid, p.poiname, p.poitype,
round((p.Shape.STY - t.Shape.STY)*111319,1) as Lat_Diff_m,
round((p.Shape.STX - t.Shape.STX)*111319 * cos(p.Shape.STY*3.1415926/180),1) as Long_diff_m
from akr_socio.gis.akr_POI_PT_evw as p
join akr_facility2.gis.TRAILS_FEATURE_PT_evw  as t
on p.SRCDBIDVAL = t.GEOMETRYID
where SRCDBNAME =  'akr_facility2.GIS.TRAILS_Feature_pt' and (p.Shape.STX <> t.Shape.STX or p.Shape.STY <> t.Shape.STY)
order by abs(p.Shape.STX - t.Shape.STX)/2 + abs(p.Shape.STY - t.Shape.STY) desc