-----------------------------
-- POLYGON MIGRATION
-----------------------------

-- building_polygon.building_id -> AKR_BLDG_PY.featureid
-- building_polygon.geometryid -> AKR_BLDG_PY.geometryid
-- building_polygon.polygon_type -> AKR_BLDG_PY.POLYGONTYPE
-- building_polygon.is_extant -> AKR_BLDG_PY.ISEXTANT
-- building_polygon.is_sensitive -> AKR_BLDG_PY.PUBLICDISPLAY
-- building_polygon.Source_Date -> AKR_BLDG_PY.SOURCEDATE
-- building_polygon.Edit_Date -> AKR_BLDG_PY.CREATEDATE
-- building_polygon.Edit_Date -> AKR_BLDG_PY.EDITDATE
-- building_polygon.Map_Method -> AKR_BLDG_PY.MAPMETHOD
-- building_polygon.Map_Source -> AKR_BLDG_PY.MAPSOURCE
-- building_polygon.Polygon_Notes -> AKR_BLDG_PY.NOTES
-- building_polygon.INPLACES -> /dev/null
-- building_polygon.ISCURRENTGEO -> AKR_BLDG_PY.ISCURRENTGEO
-- building_polygon.ISOUTPARK -> AKR_BLDG_PY.ISOUTPARK

-- What do we have?
SELECT * from AKR_BLDG_PY

SELECT featureid from AKR_BLDG_PY order by featureid
SELECT featureid, count(*) from AKR_BLDG_PY group by featureid having count(*) > 1
SELECT featureid, POLYGONTYPE, ISEXTANT, count(*) from AKR_BLDG_PY group by featureid, POLYGONTYPE, ISEXTANT having count(*) > 1
SELECT geometryid from AKR_BLDG_PY order by geometryid
SELECT CREATEDATE from AKR_BLDG_PY order by CREATEDATE
SELECT EDITDATE from AKR_BLDG_PY order by EDITDATE
SELECT SOURCEDATE from AKR_BLDG_PY order by SOURCEDATE
SELECT POLYGONTYPE, count(*) from AKR_BLDG_PY group by POLYGONTYPE
SELECT ISEXTANT, count(*) from AKR_BLDG_PY group by ISEXTANT
SELECT ISCURRENTGEO, count(*) from AKR_BLDG_PY group by ISCURRENTGEO
SELECT ISOUTPARK, count(*) from AKR_BLDG_PY group by ISOUTPARK
SELECT PUBLICDISPLAY, count(*) from AKR_BLDG_PY group by PUBLICDISPLAY
SELECT MAPMETHOD, count(*) from AKR_BLDG_PY group by MAPMETHOD
SELECT MAPSOURCE from AKR_BLDG_PY order by MAPSOURCE
SELECT NOTES from AKR_BLDG_PY order by NOTES

--What should it be?
select * from DOM_MAPMETHOD
select * from DOM_DATAACCESS
select * from DOM_PUBLICDISPLAY
select * from DOM_POLYGONTYPE
select * from DOM_YES_NO_UNK
select * from DOM_YES_NO_Both
select * from DOM_XYACCURACY

-- Attribute value remapping
update AKR_BLDG_PY set POLYGONTYPE = 'Perimeter polygon' where POLYGONTYPE = '0' -- 3554/3554
update AKR_BLDG_PY set ISEXTANT = 'No' where ISEXTANT = 'N' -- 155/3554
update AKR_BLDG_PY set ISEXTANT = 'Yes' where ISEXTANT = 'Y' -- 3399/3554
update AKR_BLDG_PY set PUBLICDISPLAY = 'Public Map Display', DATAACCESS = 'Unrestricted' where PUBLICDISPLAY = 'N' -- 2742/3554
update AKR_BLDG_PY set PUBLICDISPLAY = 'No Public Map Display', DATAACCESS = 'Internal NPS Only'  where PUBLICDISPLAY = 'Y' -- 812/3554
update AKR_BLDG_PY set EDITUSER = 'AKRO_GIS', CREATEUSER = 'AKRO_GIS' -- 3554/3554
update AKR_BLDG_PY set MAPSOURCE = 'Unknown' where MAPSOURCE is null or MAPSOURCE = ''  -- 8/3554
update AKR_BLDG_PY set MAPMETHOD = 'Unknown' where MAPMETHOD is null or MAPMETHOD = 'UNKN' --1370/3554
update AKR_BLDG_PY set MAPMETHOD = 'Surveyed/Geodetically Derived' where MAPMETHOD = 'SURV' -- 56/3554
update AKR_BLDG_PY set MAPMETHOD = 'Digitized' where MAPMETHOD = 'HDIG' -- 1421/3554
update AKR_BLDG_PY set MAPMETHOD = 'Derived' where MAPMETHOD = 'DERV' -- 24/3554
update AKR_BLDG_PY set MAPMETHOD = 'GNSS: Consumer Grade' where MAPMETHOD = 'AGPS' -- 11/3554
update AKR_BLDG_PY set MAPMETHOD = 'GNSS: Mapping Grade' where MAPMETHOD = 'DGPS' -- 672/3554

-- Problems:
-- Notes should not be an empty string, use NULL instead
select * from AKR_BLDG_PY where NOTES = ''  -- 427/3554

-- Source date should be NULL or inside a reasonable range
select * from AKR_BLDG_PY where SOURCEDATE > GETDATE() or SOURCEDATE < '1990' -- 1
-- solution set invalid dates to null;  At some future date explore NULL values, and see if they can be improved

-- ISCURRENTGEO should not be NULL
select * from AKR_BLDG_PY where ISCURRENTGEO is null -- 15
-- solution if there is only one footprint for the problem building, then ISCURRENTGEO should be 'Yes'
-- This is true for all except FEATUREID = '{3E75E27D-361F-4F83-A0F7-BE5735C2F41C}', with two versions, where the null value is non-extant, and the non-null is 'Yes'
select p2.FEATUREID, p1.ISCURRENTGEO, p2.ISCURRENTGEO from AKR_BLDG_PY as p1 left join AKR_BLDG_PY as p2 on p1.FEATUREID = p2.FEATUREID where p1.ISCURRENTGEO is null -- 15
select * from AKR_BLDG_PY where FEATUREID = '{3E75E27D-361F-4F83-A0F7-BE5735C2F41C}'

-- ISOUTPARK should be non-null
select * from AKR_BLDG_PY where ISOUTPARK is null -- 18
-- solution is a spatial query against the park polygons

-- XYAccuracy is required (non-null
select * from AKR_BLDG_PY where XYACCURACY is null -- 3554
-- solution, use MAPMETHOD and DOM_XYACCURACY to pick a value (default to Unknown)

-- data fixes
update AKR_BLDG_PY set NOTES = NULL where NOTES = ''  -- 427/3554
update AKR_BLDG_PY set SOURCEDATE = NULL where SOURCEDATE > GETDATE() or SOURCEDATE < '1990' -- 1/3554
update AKR_BLDG_PY set ISCURRENTGEO = 'No' where ISCURRENTGEO is null and FEATUREID = '{3E75E27D-361F-4F83-A0F7-BE5735C2F41C}' -- 1/3554
update AKR_BLDG_PY set ISCURRENTGEO = 'Yes' where ISCURRENTGEO is null -- 14/3554
update AKR_BLDG_PY set XYACCURACY = '<5cm' where MAPMETHOD = 'Surveyed/Geodetically Derived' -- 56/3554
update AKR_BLDG_PY set XYACCURACY = '>=5m and <14m' where MAPMETHOD = 'GNSS: Consumer Grade' -- 11/3554
update AKR_BLDG_PY set XYACCURACY = '>=50cm and <1m' where MAPMETHOD = 'GNSS: Mapping Grade' -- 672/3554
update AKR_BLDG_PY set XYACCURACY = '>=14m' where MAPMETHOD = 'Digitized' -- 1421/3554
update AKR_BLDG_PY set XYACCURACY = 'Unknown' where XYACCURACY is null -- 1394/3554

-- Data quality improvements
-- source date should not be null, especially if there is a digitized source
select * from AKR_BLDG_PY where SOURCEDATE is null -- 36
select * from AKR_BLDG_PY where SOURCEDATE is null and MAPMETHOD = 'Digitized' -- 35
-- MapMethod should not be 'Unknown'
select * from AKR_BLDG_PY where MAPMETHOD = 'Unknown' -- 1370
-- MapSource should not be 'Unknown'
select * from AKR_BLDG_PY where MAPSOURCE = 'Unknown' -- 8
-- XYACCURACY should not be 'Unknown'
select * from AKR_BLDG_PY where XYACCURACY = 'Unknown' -- 1394
select * from AKR_BLDG_PY where XYACCURACY = 'Unknown' and MAPMETHOD = 'Derived' -- 24


-----------------------------
-- POINT MIGRATION
-----------------------------

-- building_point.building_id -> AKR_BLDG_PT.featureid
-- building_point.geometryid -> AKR_BLDG_PT.geometryid
-- building_point.point_type -> AKR_BLDG_PT.POINTTYPE
-- building_point.is_extant -> AKR_BLDG_PT.ISEXTANT
-- building_point.is_sensitive -> AKR_BLDG_PT.PUBLICDISPLAY
-- building_point.Source_Date -> AKR_BLDG_PT.SOURCEDATE
-- building_point.Edit_Date -> AKR_BLDG_PT.CREATEDATE
-- building_point.Edit_Date -> AKR_BLDG_PT.EDITDATE
-- building_point.Map_Method -> AKR_BLDG_PT.MAPMETHOD
-- building_point.Map_Source -> AKR_BLDG_PT.MAPSOURCE
-- building_point.Point_Notes -> AKR_BLDG_PT.NOTES

-- What do we have?
SELECT * from AKR_BLDG_PT

SELECT featureid from AKR_BLDG_PT order by featureid
SELECT featureid, count(*) from AKR_BLDG_PT group by featureid having count(*) > 1
SELECT featureid, POINTTYPE, ISEXTANT, count(*) from AKR_BLDG_PT group by featureid, POINTTYPE, ISEXTANT having count(*) > 1
SELECT geometryid from AKR_BLDG_PT order by geometryid
SELECT CREATEDATE from AKR_BLDG_PT order by CREATEDATE
SELECT EDITDATE from AKR_BLDG_PT order by EDITDATE
SELECT SOURCEDATE from AKR_BLDG_PT order by SOURCEDATE
SELECT POINTTYPE, count(*) from AKR_BLDG_PT group by POINTTYPE
SELECT ISEXTANT, count(*) from AKR_BLDG_PT group by ISEXTANT
SELECT PUBLICDISPLAY, count(*) from AKR_BLDG_PT group by PUBLICDISPLAY
SELECT MAPMETHOD, count(*) from AKR_BLDG_PT group by MAPMETHOD
SELECT MAPSOURCE from AKR_BLDG_PT order by MAPSOURCE
SELECT NOTES from AKR_BLDG_PT order by NOTES

--What should it be?
select * from DOM_MAPMETHOD
select * from DOM_DATAACCESS
select * from DOM_PUBLICDISPLAY
select * from DOM_POINTTYPE
select * from DOM_YES_NO_UNK
select * from DOM_YES_NO_Both

-- Attribute value remapping
update AKR_BLDG_PT set POINTTYPE = 'Center point' where POINTTYPE = '0' -- 3715/5039
update AKR_BLDG_PT set POINTTYPE = 'Entrance point' where POINTTYPE = '2' -- 1315/5039
update AKR_BLDG_PT set POINTTYPE = 'Photo point' where POINTTYPE = '3' -- 1/5039
update AKR_BLDG_PT set POINTTYPE = 'Other point' where POINTTYPE = '4' -- 2/5039
update AKR_BLDG_PT set ISEXTANT = 'No' where ISEXTANT = 'N' -- 243/5039
update AKR_BLDG_PT set ISEXTANT = 'Yes' where ISEXTANT = 'Y' -- 4782/5039
update AKR_BLDG_PT set PUBLICDISPLAY = 'Public Map Display', DATAACCESS = 'Unrestricted' where PUBLICDISPLAY = 'N' -- 4180/5039
update AKR_BLDG_PT set PUBLICDISPLAY = 'No Public Map Display', DATAACCESS = 'Internal NPS Only'  where PUBLICDISPLAY = 'Y' -- 859/5039
update AKR_BLDG_PT set EDITUSER = 'AKRO_GIS', CREATEUSER = 'AKRO_GIS' -- 5039/5039
update AKR_BLDG_PT set MAPSOURCE = 'Unknown' where MAPSOURCE is null or MAPSOURCE = ''  -- 122/5039
update AKR_BLDG_PT set MAPMETHOD = 'Unknown' where MAPMETHOD = 'UNKN' -- 3/5039
update AKR_BLDG_PT set MAPMETHOD = 'Surveyed/Geodetically Derived' where MAPMETHOD = 'SURV' -- 23/5039
update AKR_BLDG_PT set MAPMETHOD = 'Digitized' where MAPMETHOD = 'HDIG' -- 478/5039
update AKR_BLDG_PT set MAPMETHOD = 'Derived' where MAPMETHOD = 'DERV' -- 3397/5039
update AKR_BLDG_PT set MAPMETHOD = 'GNSS: Consumer Grade' where MAPMETHOD = 'AGPS' -- 261/5039
update AKR_BLDG_PT set MAPMETHOD = 'GNSS: Mapping Grade' where MAPMETHOD = 'DGPS' -- 876/5039


-- problems
select * from AKR_BLDG_PT where POINTTYPE is null -- 6  (they are all new versions of existing centroids, set the older to isextant = 'No' before setting pointtype)
select * from AKR_BLDG_PT where ISEXTANT is null -- 14  (all entrances, use same as centroid)
select * from AKR_BLDG_PT where CREATEDATE is null -- 1 (entrance, use same as centroid)
select * from AKR_BLDG_PT where EDITDATE is null -- 1 (entrance, use same as centroid)
select * from AKR_BLDG_PT where SOURCEDATE is null or SOURCEDATE > '2018'  --36 (see poly)
select * from AKR_BLDG_PT where XYACCURACY is null -- 5039  (use MAPMETHOD and DOM_XYACCURACY to pick a value (default to Unknown)

-- data fixes
update AKR_BLDG_PT set ISEXTANT = 'No' where FEATUREID in (select FEATUREID from AKR_BLDG_PT where POINTTYPE is null) and POINTTYPE is not null -- 6/5039
update AKR_BLDG_PT set POINTTYPE = 'Center point' where POINTTYPE is null -- 6/5039
update o set ISEXTANT = c.ISEXTANT from (select * from AKR_BLDG_PT where POINTTYPE = 'Center point') as c
       join (select * from AKR_BLDG_PT where POINTTYPE <> 'Center point') as o
       on o.FEATUREID = c.FEATUREID where o.ISEXTANT is null  -- 14/5039
update o set CREATEDATE = c.CREATEDATE from (select * from AKR_BLDG_PT where POINTTYPE = 'Center point') as c
       join (select * from AKR_BLDG_PT where POINTTYPE <> 'Center point') as o
       on o.FEATUREID = c.FEATUREID where o.CREATEDATE is null  -- 1/5039
update o set EDITDATE = c.EDITDATE from (select * from AKR_BLDG_PT where POINTTYPE = 'Center point') as c
       join (select * from AKR_BLDG_PT where POINTTYPE <> 'Center point') as o
       on o.FEATUREID = c.FEATUREID where o.EDITDATE is null  -- 1/5039
update AKR_BLDG_PT set MAPMETHOD = 'GNSS: Mapping Grade' where MAPMETHOD = 'DDGP' -- 1/5039  (typo)
update AKR_BLDG_PT set NOTES = NULL where NOTES = ''  -- 877/5039
update AKR_BLDG_PT set SOURCEDATE = NULL where SOURCEDATE > GETDATE() or SOURCEDATE < '1990' -- 1/5039
update AKR_BLDG_PT set XYACCURACY = '<5cm' where MAPMETHOD = 'Surveyed/Geodetically Derived' -- 23/5039
update AKR_BLDG_PT set XYACCURACY = '>=5m and <14m' where MAPMETHOD = 'GNSS: Consumer Grade' -- 261/5039
update AKR_BLDG_PT set XYACCURACY = '>=50cm and <1m' where MAPMETHOD = 'GNSS: Mapping Grade' -- 877/5039
update AKR_BLDG_PT set XYACCURACY = '>=14m' where MAPMETHOD = 'Digitized' -- 484/5039
update p set XYACCURACY = f.XYACCURACY from AKR_BLDG_PT as p join AKR_BLDG_PY as f
       on p.FEATUREID = f.FEATUREID where p.MAPMETHOD = 'Derived' --3420/5039
update AKR_BLDG_PT set XYACCURACY = 'Unknown' where XYACCURACY is null -- 12/5039


-- Data quality improvements
-- source date should not be null, especially if there is a digitized source
select * from AKR_BLDG_PT where SOURCEDATE is null -- 282
select * from AKR_BLDG_PT where SOURCEDATE is null and MAPMETHOD = 'Digitized' -- 135
-- MapMethod should not be 'Unknown'
select * from AKR_BLDG_PT where MAPMETHOD = 'Unknown' -- 3
-- MapSource should not be 'Unknown'
select * from AKR_BLDG_PT where MAPSOURCE = 'Unknown' -- 122
-- XYACCURACY should not be 'Unknown'
select * from AKR_BLDG_PT where XYACCURACY = 'Unknown' -- ??
select * from AKR_BLDG_PT where XYACCURACY = 'Unknown' and MAPMETHOD = 'Derived' -- ??


-----------------------------
-- BREAK INTO SEPARATE TABLES
-----------------------------

-- drop unused columns from AKR_BLDG_py
Alter table AKR_BLDG_PY drop column BLDGNAME, BLDGALTNAME, MAPLABEL, BLDGSTATUS, BLDGCODE, BLDGTYPE, FACOWNER, FACOCCUPANT, FACMAINTAIN, FACUSE, SEASONAL, SEASDESC, UNITCODE, UNITNAME, GROUPCODE, GROUPNAME, REGIONCODE, FACLOCID, FACASSETID, CRID, ASMISID, CLIID, LCSID, FIREBLDGID, PARKBLDGID
-- Use ArcCatalog to rename AKR_BLDG_PY to AKR_BLDG_FOOTPRINT_PY
-- Use ArcCatalog to copy AKR_BLDG_footprint_py to AKR_BLDG_other_py then empty other_py
delete from AKR_BLDG_OTHER_PY

-- Use ArcCatalog to rename AKR_BLDG_PT to AKR_BLDG_CENTER_PT
-- Use ArcCatalog to copy AKR_BLDG_CENTER_PT to AKR_BLDG_OTHER_PT then keep/clear Center points
delete from AKR_BLDG_CENTER_PT where POINTTYPE <> 'Center point'
delete from AKR_BLDG_OTHER_PT where POINTTYPE = 'Center point'
-- drop unused columns from AKR_BLDG_py
Alter table AKR_BLDG_OTHER_PT drop column BLDGNAME, BLDGALTNAME, MAPLABEL, BLDGSTATUS, BLDGCODE, BLDGTYPE, FACOWNER, FACOCCUPANT, FACMAINTAIN, FACUSE, SEASONAL, SEASDESC, UNITCODE, UNITNAME, GROUPCODE, GROUPNAME, REGIONCODE, FACLOCID, FACASSETID, CRID, ASMISID, CLIID, LCSID, FIREBLDGID, PARKBLDGID


-- To compare points and polygons we need to join on featureid, however that is not unique because of iscurrentgeo/isextant
-- Check for dups
-- There can be no dups in other points, especially entrance points, unless one is a currentgeo, and the rest are not currentgeo --38
select FEATUREID, count(*), min(POINTTYPE), max(POINTTYPE), min(ISEXTANT), max(ISEXTANT), min(iscurrentgeo), max(iscurrentgeo) from AKR_BLDG_OTHER_PT group by FEATUREID having count(*) > 1
-- features that are dup because the of a change in iscurrentgeo (isextant)  --12
select FEATUREID, count(*), min(POINTTYPE), max(POINTTYPE), min(ISEXTANT), max(ISEXTANT) from AKR_BLDG_OTHER_PT where FEATUREID in (select FEATUREID from AKR_BLDG_CENTER_PT group by FEATUREID having count(*) > 1) group by FEATUREID having count(*) > 1
-- features that are dup because there are multiple features (i.e. entrances)  --26
select FEATUREID, count(*), min(POINTTYPE), max(POINTTYPE), min(ISEXTANT), max(ISEXTANT) from AKR_BLDG_OTHER_PT where FEATUREID not in (select FEATUREID from AKR_BLDG_CENTER_PT group by FEATUREID having count(*) > 1) group by FEATUREID having count(*) > 1
-- There should be no dups in center points, unless one is a currentgeo, and the rest are not currentgeo -- 22
select FEATUREID, count(*), min(ISEXTANT), max(ISEXTANT), min(iscurrentgeo), max(iscurrentgeo) from AKR_BLDG_CENTER_PT group by FEATUREID having count(*) > 1
-- There should be no dups in footprints, unless one is a currentgeo, and the rest are not currentgeo  -- 16
select FEATUREID, count(*), min(ISEXTANT), max(ISEXTANT), min(iscurrentgeo), max(iscurrentgeo) from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1
-- If a feature is not the current geo then it better be a dup on one with a current geo --22
select old.FEATUREID, dups.FEATUREID, old.ISEXTANT from (select * from AKR_BLDG_CENTER_PT where ISEXTANT = 'No') as old
  join (select FEATUREID from AKR_BLDG_CENTER_PT where FEATUREID in (select FEATUREID from AKR_BLDG_CENTER_PT group by FEATUREID having count(*) > 1) and ISEXTANT = 'Yes') as dups
  on old.FEATUREID = dups.FEATUREID -- where dups.FEATUREID is null
-- If a feature is not the current geo then it better be a dup on one with a current geo -- 16
select old.FEATUREID, dups.FEATUREID, old.ISCURRENTGEO from (select * from AKR_BLDG_FOOTPRINT_PY where ISCURRENTGEO = 'No') as old
  join (select FEATUREID from AKR_BLDG_FOOTPRINT_PY where FEATUREID in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1) and ISCURRENTGEO = 'Yes') as dups
  on old.FEATUREID = dups.FEATUREID -- where dups.FEATUREID is null

-- Fix footprints which are duplicate, but not separated by iscurrentgeo, fortunately, isextant is different and assumed correct
update AKR_BLDG_FOOTPRINT_PY set ISCURRENTGEO = 'No' where FEATUREID in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1) and isextant <> ISCURRENTGEO
-- Set ISCURRENTGEO for duplicate points
update AKR_BLDG_CENTER_PT set ISCURRENTGEO = ISEXTANT where FEATUREID in (select FEATUREID from AKR_BLDG_CENTER_PT group by FEATUREID having count(*) > 1)

-- Check for any points that have duplicate polygons, but that do not have iscurrentgeo defined
select * from AKR_BLDG_CENTER_PT where ISCURRENTGEO is null and FEATUREID in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1)
select * from AKR_BLDG_CENTER_PT where ISCURRENTGEO is null and FEATUREID not in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1)
select pt.ISCURRENTGEO, py.ISCURRENTGEO from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID where pt.ISCURRENTGEO is null and py.FEATUREID not in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1)

-- Set iscurrentgeo from polygon; default to Yes where point has not polygon (
update pt set ISCURRENTGEO = py.ISCURRENTGEO from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID where pt.ISCURRENTGEO is null and py.FEATUREID not in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1)
update AKR_BLDG_CENTER_PT set ISCURRENTGEO = 'Yes' where ISCURRENTGEO is null
update pt set ISCURRENTGEO = py.ISCURRENTGEO from AKR_BLDG_OTHER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID where pt.ISCURRENTGEO is null and py.FEATUREID not in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1)
update AKR_BLDG_OTHER_PT set ISCURRENTGEO = 'Yes' where ISCURRENTGEO is null

-- Now we can join on featureid and iscurrentgeo
-- center point to poly
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO -- 3554 matches
select count(*) from AKR_BLDG_CENTER_PT as pt left join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO where py.FEATUREID is null -- 167 point with no poly
select count(*) from AKR_BLDG_CENTER_PT as pt right join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO where pt.FEATUREID is null -- 0 poly with no point
-- center point to other point
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_OTHER_PT as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO -- 1318 matches
select count(*) from AKR_BLDG_CENTER_PT as pt left join AKR_BLDG_OTHER_PT as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO where py.FEATUREID is null -- 2451 center point with no other point
select count(*) from AKR_BLDG_CENTER_PT as pt right join AKR_BLDG_OTHER_PT as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO where pt.FEATUREID is null -- 0 other points with no center point


-- Fixed the fololowing two problems visually in ArcMap

-- A number of old entrances (building moved) were not marked as ISCURRENTGEOM = 'No'  This fixes them
-- If OBJECTIDs change, then they can be found be looking at buildings with dup FEATUREID and ISCURRENTGEOM = 'No'
update AKR_BLDG_OTHER_PT set ISCURRENTGEO = 'No' where OBJECTID in (4523, 4517, 4410, 4462, 1607, 361, 1066, 1068, 974, 975, 1001, 3112, 3114)

-- The 6 points with duplicate centroids, new/old geom are the same, notes are different; no duplicate footprints.  Deleted older centroids
-- These are the 6 points that had no POINTTYPE earlier
delete from AKR_BLDG_CENTER_PT where objectid in (4991, 4992, 4993, 4994, 4995, 4996)


-- Look for mismatches between redundant columns in points and polygons
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO
  where pt.ISEXTANT <> py.ISEXTANT  -- 0
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_OTHER_PT as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO
  where pt.ISEXTANT <> py.ISEXTANT -- 1
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO
  where pt.PUBLICDISPLAY <> py.PUBLICDISPLAY  -- 0
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_OTHER_PT as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO
  where pt.PUBLICDISPLAY <> py.PUBLICDISPLAY -- 1
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO
  where pt.DATAACCESS <> py.DATAACCESS  -- 0
select count(*) from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_OTHER_PT as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO
  where pt.DATAACCESS <> py.DATAACCESS -- 1
-- 1 entrance is private while center and poly are public; assume entrance is wrong.
--   fix by deleting data from other points

-- 1 polys have extant different from center; the polygon isextant was not updated when move
--   fix by deleting data from polys

-- Move ISOUTPARK to center from poly
--  NOTE: {596F8242-787C-4AAA-8FCE-DB046293B0E7} is not both it is inside; all other both are in Skagway
update AKR_BLDG_CENTER_PT set ISOUTPARK = 'No' where FEATUREID = '{596F8242-787C-4AAA-8FCE-DB046293B0E7}'
--  NOTE: All Values should be verified with current park geometry
update pt set ISOUTPARK = py.ISOUTPARK from AKR_BLDG_CENTER_PT as pt join AKR_BLDG_FOOTPRINT_PY as py
  on pt.FEATUREID = py.FEATUREID and pt.ISCURRENTGEO = py.ISCURRENTGEO

select ISOUTPARK, count(*) from AKR_BLDG_CENTER_PT group by ISOUTPARK

-- Remove redundant columns from polys and other points
Alter table AKR_BLDG_FOOTPRINT_PY drop column ISEXTANT, ISOUTPARK, PUBLICDISPLAY, DATAACCESS
Alter table AKR_BLDG_OTHER_PY drop column ISEXTANT, ISOUTPARK, PUBLICDISPLAY, DATAACCESS
Alter table AKR_BLDG_OTHER_PT drop column ISEXTANT, ISOUTPARK, PUBLICDISPLAY, DATAACCESS


-- There is one POINTTYPE = 'Photo point' which is now an invalid type
-- It could get moved into AKR_ATTACH_PT, but we have no attachment info.
-- Since there is only one of these and it has no useful information, I am just going to delete it.
delete from AKR_BLDG_OTHER_PT where POINTTYPE = 'Photo point'


-- -----------------------------------------------------------
-- Add attributes to center points from building & link tables
-- -----------------------------------------------------------

-- Make sure that there is no ancillary data that doesn't map onto a center point
select count(*) from BUILDING as b left join AKR_BLDG_CENTER_PT as p on p.FEATUREID = b.Building_ID where p.FEATUREID is null -- 0; Good
select count(*) from BUILDING_LINK as b left join AKR_BLDG_CENTER_PT as p on p.FEATUREID = b.Building_ID where p.FEATUREID is null -- 0; Good

-- Mapping
-- BUILDING.Unit_code -> AKR_BLDG_CENTER_PT.UNITCODE
-- BUILDING.Common_Name -> AKR_BLDG_CENTER_PT.BLDGNAME
-- BUILDING.Federal_Entity_Type -> AKR_BLDG_CENTER_PT.??
-- BUILDING.FCode -> AKR_BLDG_CENTER_PT.??
-- BUILDING.POILABEL -> AKR_BLDG_CENTER_PT.MAPLABEL
-- BUILDING.Description -> AKR_BLDG_CENTER_PT.NOTES (if null; otherwise concatenate with existing Notes)
-- BUILDING.Usage -> AKR_BLDG_CENTER_PT.FACUSE
-- BUILDING.Admin_Type -> AKR_BLDG_CENTER_PT.FACOWNER
-- BUILDING.Admin_Type -> AKR_BLDG_CENTER_PT.FACOCCUPANT
-- BUILDING.Admin_Type -> AKR_BLDG_CENTER_PT.FACMAINTAIN
-- BUILDING_LINK.FMSS_ID -> AKR_BLDG_CENTER_PT.FACLOCID
-- BUILDING_LINK.LCS_ID -> AKR_BLDG_CENTER_PT.LCSID
-- BUILDING_LINK.ASMIS_ID -> AKR_BLDG_CENTER_PT.ASMISID
-- BUILDING_LINK.Park_ID -> AKR_BLDG_CENTER_PT.PARKBLDGID
-- BUILDING_LINK.FPPID -> AKR_BLDG_CENTER_PT.FIREBLDGID

update p set UNITCODE = b.Unit_Code from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
update p set BLDGNAME = b.Common_Name from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
update p set MAPLABEL = b.POILABEL from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
update p set FACUSE = b.Usage from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
-- Tescription is tricky because it is a merge with Notes
-- There are only one cases where both notes will not fit.  this is ok since Notes is already incorporated into description
select p.Notes, len(p.Notes), b.[Description], len(b.[Description]),  len(p.Notes) + len(b.[Description]) from  AKR_BLDG_CENTER_PT as p join BUILDING as b
       on p.FEATUREID = b.Building_ID where p.Notes is not null and b.Description is not null order by len(p.Notes) + len(b.[Description]) desc
update p set NOTES = b.[Description] from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
       where p.Notes is null and b.Description is not null
update p set NOTES = p.Notes + '; ' + b.[Description] from  AKR_BLDG_CENTER_PT as p join BUILDING as b
       on p.FEATUREID = b.Building_ID where p.Notes is not null and b.Description is not null and len(p.Notes) + len(b.[Description]) < 254
update p set NOTES = b.[Description] from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
       where p.Notes is not null and b.Description is not null and len(p.Notes) + len(b.[Description]) > 254
update p set FACOWNER = b.Admin_Type from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
update p set FACOCCUPANT = b.Admin_Type from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
update p set FACMAINTAIN = b.Admin_Type from  AKR_BLDG_CENTER_PT as p join BUILDING as b on p.FEATUREID = b.Building_ID
update p set FACLOCID = b.FMSS_ID from  AKR_BLDG_CENTER_PT as p join BUILDING_LINK as b on p.FEATUREID = b.Building_ID and b.FMSS_ID not like '%temp%'
update p set LCSID = b.LCS_ID from  AKR_BLDG_CENTER_PT as p join BUILDING_LINK as b on p.FEATUREID = b.Building_ID
update p set ASMISID = b.ASMIS_ID from  AKR_BLDG_CENTER_PT as p join BUILDING_LINK as b on p.FEATUREID = b.Building_ID
update p set PARKBLDGID = b.Park_ID from  AKR_BLDG_CENTER_PT as p join BUILDING_LINK as b on p.FEATUREID = b.Building_ID
update p set FIREBLDGID = b.FPPID from  AKR_BLDG_CENTER_PT as p join BUILDING_LINK as b on p.FEATUREID = b.Building_ID

-- Check and Fix for domains
-- First Built and Ran QC checks and Calculated Values

select UNITCODE, count(*) from AKR_BLDG_CENTER_PT group by UNITCODE order by count(*) desc
select BLDGNAME, count(*) from AKR_BLDG_CENTER_PT group by BLDGNAME order by count(*) desc
select MAPLABEL, count(*) from AKR_BLDG_CENTER_PT group by MAPLABEL order by count(*) desc
select FACUSE, count(*) from AKR_BLDG_CENTER_PT group by FACUSE order by count(*) desc
select NOTES, count(*) from AKR_BLDG_CENTER_PT group by NOTES order by count(*) desc
select FACOWNER, count(*) from AKR_BLDG_CENTER_PT group by FACOWNER order by count(*) desc
select FACOCCUPANT, count(*) from AKR_BLDG_CENTER_PT group by FACOCCUPANT order by count(*) desc
select FACMAINTAIN, count(*) from AKR_BLDG_CENTER_PT group by FACMAINTAIN order by count(*) desc
select FACLOCID, count(*) from AKR_BLDG_CENTER_PT group by FACLOCID order by count(*) desc
select LCSID, count(*) from AKR_BLDG_CENTER_PT group by LCSID order by count(*) desc
select ASMISID, count(*) from AKR_BLDG_CENTER_PT group by ASMISID order by count(*) desc
select PARKBLDGID, count(*) from AKR_BLDG_CENTER_PT group by PARKBLDGID order by count(*) desc
select FIREBLDGID, count(*) from AKR_BLDG_CENTER_PT group by FIREBLDGID order by count(*) desc

select BLDGCODE, count(*) from AKR_BLDG_CENTER_PT group by BLDGCODE order by count(*) desc
select BLDGTYPE, count(*) from AKR_BLDG_CENTER_PT group by BLDGTYPE order by count(*) desc
select SEASONAL, count(*) from AKR_BLDG_CENTER_PT group by SEASONAL order by count(*) desc
select SEASDESC, count(*) from AKR_BLDG_CENTER_PT group by SEASDESC order by count(*) desc
select ISEXTANT, count(*) from AKR_BLDG_CENTER_PT group by ISEXTANT order by count(*) desc
select PUBLICDISPLAY, DATAACCESS, count(*) from AKR_BLDG_CENTER_PT group by PUBLICDISPLAY, DATAACCESS order by count(*) desc

select BLDGSTATUS, count(*) from AKR_BLDG_CENTER_PT group by BLDGSTATUS order by count(*) desc

-- FACOWNER, FACOCCUPANT, FACMAINTAIN values are not in domain
update AKR_BLDG_CENTER_PT set FACOWNER = upper(FACOWNER) Collate Latin1_General_CS_AI
update AKR_BLDG_CENTER_PT set FACOWNER = 'CITY GOV' where FACOWNER = 'MUNICIPAL'
update AKR_BLDG_CENTER_PT set FACOWNER = NULL where FACOWNER = 'NON-FEDERAL' or FACOWNER = 'UNKNOWN'
update AKR_BLDG_CENTER_PT set FACOCCUPANT = upper(FACOCCUPANT) Collate Latin1_General_CS_AI
update AKR_BLDG_CENTER_PT set FACOCCUPANT = 'CITY GOV' where FACOCCUPANT = 'MUNICIPAL'
update AKR_BLDG_CENTER_PT set FACOCCUPANT = NULL where FACOCCUPANT = 'NON-FEDERAL' or FACOCCUPANT = 'UNKNOWN'
update AKR_BLDG_CENTER_PT set FACMAINTAIN = upper(FACMAINTAIN) Collate Latin1_General_CS_AI
update AKR_BLDG_CENTER_PT set FACMAINTAIN = 'CITY GOV' where FACMAINTAIN = 'MUNICIPAL'
update AKR_BLDG_CENTER_PT set FACMAINTAIN = NULL where FACMAINTAIN = 'NON-FEDERAL' or FACMAINTAIN = 'UNKNOWN'
--FACUSE values are not in domain
update AKR_BLDG_CENTER_PT set FACUSE = 'Admin Use' where FACUSE = 'Admin'
update AKR_BLDG_CENTER_PT set FACUSE = 'Public Use' where FACUSE = 'Public'
update AKR_BLDG_CENTER_PT set FACUSE = NULL where FACUSE = 'Unknown' or FACUSE = ''
update AKR_BLDG_CENTER_PT set FACUSE = NULL, FACOWNER = 'PRIVATE', FACOCCUPANT = 'PRIVATE', FACMAINTAIN = 'PRIVATE' where FACUSE = 'Private'
update AKR_BLDG_CENTER_PT set FACUSE = NULL, BLDGTYPE = FACUSE where FACUSE not in ('Admin Use', 'Public Use')  --Invalid BLDGTYPEs to be corrected later
-- ISEXTANT values are not in domain
update AKR_BLDG_CENTER_PT set ISEXTANT = 'True' where ISEXTANT = 'Yes'
update AKR_BLDG_CENTER_PT set ISEXTANT = 'False' where ISEXTANT = 'No'

-- UNITCODE: WEAR is in the UNITCODE but it is a GROUPCODE; move it (UNITCODE will be calcd if null)
select UNITCODE, GROUPCODE from AKR_BLDG_CENTER_PT where UNITCODE = 'WEAR'
update AKR_BLDG_CENTER_PT set UNITCODE = NULL, GROUPCODE = 'WEAR' where UNITCODE = 'WEAR'
-- 16 were inside park boundaries, and they got correct unit codes, the rest are outside; 33 in Kotz should get unit = WEAR
-- These and a few other issues (i.e. Eagle) were corrected in ArcGIS

-- Two errors were found: 712 / {7AAFE425-8199-4E31-9A97-2943CE40E0C5} is in ANIA not YUCH
-- 3346 / {7C5C91E5-A855-41CC-AF1F-71909B1644F9} is in KOVA not LACL
select objectid, featureid, UNITCODE, GROUPCODE from AKR_BLDG_CENTER_PT where objectid in (712, 3346)
update AKR_BLDG_CENTER_PT set UNITCODE = 'ANIA' where featureid = '{7AAFE425-8199-4E31-9A97-2943CE40E0C5}'
update AKR_BLDG_CENTER_PT set UNITCODE = 'KOVA' where featureid = '{7C5C91E5-A855-41CC-AF1F-71909B1644F9}'

select UNITCODE, GROUPCODE from AKR_BLDG_CENTER_PT where GROUPCODE = 'WEAR' and UNITCODE is null and ISOUTPARK = 'Yes'

-- Fix Building names that are not proper case
update p set bldgname = 'Historic Cabin' from AKR_BLDG_CENTER_PT as p join AKR_BLDG_FOOTPRINT_PY as f on p.FEATUREID = f.FEATUREID where bldgname = 'historic' and f.notes = 'cabin'
update p set bldgname = 'Historic House' from AKR_BLDG_CENTER_PT as p join AKR_BLDG_FOOTPRINT_PY as f on p.FEATUREID = f.FEATUREID where bldgname = 'historic' and f.notes = 'house'
update p set bldgname = 'Historic Building' from AKR_BLDG_CENTER_PT as p join AKR_BLDG_FOOTPRINT_PY as f on p.FEATUREID = f.FEATUREID where bldgname = 'historic' and f.notes is null
update p set BLDGALTNAME = p.bldgname, p.bldgname = p.MAPLABEL from AKR_BLDG_CENTER_PT as p join
  (select OBJECTID from AKR_BLDG_CENTER_PT where BLDGNAME = upper(BLDGNAME) Collate Latin1_General_CS_AI or BLDGNAME = lower(BLDGNAME) Collate Latin1_General_CS_AI) as i
  on i.OBJECTID = p.OBJECTID where p.ISCURRENTGEO = 'Yes' and p.UNITCODE = 'WRST'
update AKR_BLDG_CENTER_PT set bldgaltname = bldgname, bldgname = 'Toilet #1' where bldgname = 'SST#1'
update AKR_BLDG_CENTER_PT set bldgaltname = bldgname, bldgname = 'Toilet #2' where bldgname = 'SST#2'
update AKR_BLDG_CENTER_PT set bldgaltname = bldgname, bldgname = 'Toilet #3' where bldgname = 'SST#3'
update AKR_BLDG_CENTER_PT set bldgaltname = bldgname, bldgname = MapLabel where bldgname = 'VRAA-SHOP W-1'
update AKR_BLDG_CENTER_PT set bldgname = 'Historic Cabin (burned)' where bldgname = 'historic - burned cabin'
update AKR_BLDG_CENTER_PT set bldgname = 'Wonder Lake Trails Trailer' where bldgname = 'wl trails trailer'

-- Fix invalid building types
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Warehouse Shed Outbuilding', bldgaltname = 'Fuel System' where BLDGTYPE = 'Fuel System'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Service Shop Maintenance' where BLDGTYPE = 'Storage' and BLDGNAME = 'Warehouse and Shop'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Service Shop Maintenance' where BLDGTYPE = 'Storage' and BLDGNAME = 'Maintenance Barn and Shop'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Pole Barn' where BLDGTYPE = 'Storage' and (bldgname = 'Lumber Storage' or bldgname = 'Covered Boat Storage')
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Warehouse Shed Outbuilding' where BLDGTYPE = 'Storage'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Lodge/Motel/Hotel' where BLDGTYPE = 'Lodging' and FACOWNER = 'PRIVATE'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Lodge/Motel/Hotel' where BLDGTYPE = 'Lodging' and BLDGNAME = 'Kantishna Roadhouse'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Housing Multi- Family Plex' where BLDGTYPE = 'Lodging' and BLDGNAME = 'Duplex'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Housing Cabin' where BLDGTYPE = 'Lodging'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Housing Cabin' where BLDGTYPE = 'Housing' and BLDGNAME like '%cabin%'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Housing Apartment' where BLDGTYPE = 'Housing' and BLDGNAME = 'Leased Housing Units'
update AKR_BLDG_CENTER_PT set BLDGTYPE = 'Bldg Housing Single Family' where BLDGTYPE = 'Housing'

-- Update old (assumed bad data with current data from FMSS)
-- Not all fields from FMSS are overwritten with FMSS data, since we might have edited the GIS to fix problems, need to track some as QC issues and fix manually
-- *******************************
-- FIXES - ERRORS in Existing Data
-- if FACLOCID is in FMSSEXPORT and the FMSS value does not match the GIS value (both must be valid and non null)
-- UNITCODE (0)
select p.UNITCODE, p.GROUPCODE, f.Park from AKR_BLDG_CENTER_PT as p join
  (SELECT Park, Location FROM FMSSEXPORT2 where Park in (select Code from DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT') order by p.UNITCODE, f.Park
-- REGION (Ignore FMSS region code value - we ensure it is always AKR; if FMSS says something different it is wrong)
-- FACOCCUPANT (1398 Fixed)
select p.FACOCCUPANT, f.Occupant from AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSEXPORT2 where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant order by p.FACOCCUPANT, f.Occupant
update p set FACOCCUPANT = f.Occupant from AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSEXPORT2 where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant
-- LCSID (61 - Fixed, all but three were due to leading zeros; no reason to think the GIS value is right for the others)
--   Accept the FMSS values until I can compare with LCS
select p.faclocid, p.unitcode, f.CLASSSTR, p.LCSID, p.* from AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSEXPORT2 where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR order by p.LCSID, f.CLASSSTR
update p set LCSID = f.CLASSSTR from AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSEXPORT2 where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR
-- FACOWNER (1284 Fixed)
select p.FACOWNER, f.Asset_Ownership from AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSEXPORT2 where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership order by p.FACOWNER, f.Asset_Ownership
update p set FACOWNER = f.Asset_Ownership from AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSEXPORT2 where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership
-- CLIID (0)
select p.CLIID, f.CLINO from AKR_BLDG_CENTER_PT as p join
  (select CLINO, Location FROM FMSSEXPORT2 where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where p.CLIID <> f.CLINO order by p.CLIID, f.CLINO
-- FACMAINTAIN (1378 - Fixed)
select p.FACMAINTAIN, f.FAMARESP from AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSEXPORT2) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP order by p.FACMAINTAIN, f.FAMARESP
update p set FACMAINTAIN = f.FAMARESP from AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSEXPORT2) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP
-- SEASONAL (0)
select p.SEASONAL, f.OPSEAS from AKR_BLDG_CENTER_PT as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM FMSSEXPORT2) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS order by p.SEASONAL, f.OPSEAS
-- FACUSE (21 FIXED - about 50/50 right/wrong; I saved this list for discussion with FMSS Specialist, and accepted all the FMSS values for now)
select f.Location, p.unitcode, f.Description, f.PRIMUSE, p.FACUSE from AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Description, Location FROM FMSSEXPORT2 where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE order by p.FACUSE, f.PRIMUSE
update p set FACUSE = f.PRIMUSE from AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Location FROM FMSSEXPORT2 where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE
-- BLDGCODE (10 FIXED- investigate)
-- These differences were mostly from my guesses above (based on the name); I will accept the FMSS values (save issues for discussion with FMSS Specialist)
select p.faclocid, f.description, f.DOI_Code, d.Description, p.BLDGCODE, p.bldgtype from AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, description, Location FROM FMSSEXPORT2 where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID left join DOM_BLDGCODETYPE as d on f.DOI_Code = d.Code where p.BLDGCODE <> f.DOI_Code order by p.BLDGCODE, f.DOI_Code
update p set BLDGCODE = f.DOI_Code from AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, Location FROM FMSSEXPORT2 where DOI_Code in (select Code from DOM_BLDGCODE)) as f
  on f.Location = p.FACLOCID where p.BLDGCODE <> f.DOI_Code
-- BLDGTYPE (Ignore values in FMSS; we will calc from BLDGCODE)
-- BLDGSTATUS (143; FIXED - spot inspection showed FMSS to be better data; mostly existing -> Decommissioned; these might be default Existing may be from my processing)
select f.location, p.unitcode, f.Description, f.Status, p.BLDGSTATUS, p.ISEXTANT, p.* from AKR_BLDG_CENTER_PT as p join
  (SELECT Status, description, Location FROM FMSSEXPORT2 where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where p.BLDGSTATUS <> f.Status order by p.BLDGSTATUS, f.Status
update p set BLDGSTATUS = f.Status from AKR_BLDG_CENTER_PT as p join
  (SELECT Status, Location FROM FMSSEXPORT2 where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where p.BLDGSTATUS <> f.Status
-- PARKBLDGID (145 - fixed, needs manual correction)
--   some have obviously been improved in GIS, some of the FMSS seem newer
--   there seems to be about a 50/50 match between the FMSS PARKNUMB and the number in the FMSS Description.  Which is better?
--   I will save the differences, and then update to the FMSS values.  We can make fixes with the saved list later.
select f.location, p.unitcode, f.Description, f.PARKNUMB, p.PARKBLDGID, p.BLDGNAME from AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Description, Location FROM FMSSEXPORT2 where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB order by p.PARKBLDGID, f.PARKNUMB
update p set PARKBLDGID = f.PARKNUMB from AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Location FROM FMSSEXPORT2 where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB

-- Need to correct 10 BLDGTYPE value to align with 10 corrected BLDGCODE values (from FMSS fixes above)
update t1 set BLDGTYPE = t2.Description from AKR_BLDG_CENTER_PT as t1 left join DOM_BLDGCODETYPE as t2
       on t1.BLDGCODE = t2.Code where t1.BLDGTYPE <> t2.Description

-- Some of the buildings that got a default status of Existing before FMSS integration should be decomissioned based on the is_extant property
update AKR_BLDG_CENTER_PT set BLDGSTATUS = 'Decommissioned' where BLDGSTATUS = 'Existing' and ISEXTANT = 'False' and FACLOCID is null


-- Flag current versions of features that have an old version; we will delete the old and then add the new one into the history.
update AKR_BLDG_FOOTPRINT_PY set ISCURRENTGEO = 'fut' where FEATUREID in (select FEATUREID from AKR_BLDG_FOOTPRINT_PY group by FEATUREID having count(*) > 1 where ISCURRENTGEO = 'No') where ISCURRENTGEO = 'Yes'
update AKR_BLDG_CENTER_PT set ISCURRENTGEO = 'fut' where FEATUREID in (select FEATUREID from AKR_BLDG_CENTER_PT group by FEATUREID having count(*) > 1 where ISCURRENTGEO = 'No') where ISCURRENTGEO = 'Yes'
update AKR_BLDG_OTHER_PT set ISCURRENTGEO = 'fut' where FEATUREID in (select FEATUREID from AKR_BLDG_OTHER_PT group by FEATUREID having count(*) > 1 where ISCURRENTGEO = 'No') where ISCURRENTGEO = 'Yes'

-- Make a copy with ArcCatalog AKR_BLDG_FOOTPRINT_PY -> AKR_BLDG_FOOTPRINT_save_PY
-- Make a copy with ArcCatalog AKR_BLDG_OTHER_PT -> AKR_BLDG_OTHER_save_PT
-- Make a copy with ArcCatalog AKR_BLDG_CENTER_PT -> AKR_BLDG_CENTER_save_PT

-- delete future records
delete from AKR_BLDG_FOOTPRINT_PY where ISCURRENTGEO = 'fut'
delete from AKR_BLDG_OTHER_PT where ISCURRENTGEO = 'fut'
delete from AKR_BLDG_CENTER_PT where ISCURRENTGEO = 'fut'

-- *********************************************************************************
--     From here on (or earlier) the data needs to be in the final geodatabase!
--        (when you copy a feature class the archiving does not go with it)
-- *********************************************************************************

-- In ArcCatalog
---- Enable editor tracking (need to use toolbox to assign existing columns to role.)
---- Register as versioned (no push to base)
---- Enable Archiving
---- Create a new version
-- In ArcMap
---- Start editing in the new version
---- Delete all features with ISCURRENTGEO = 'No'
---- Add all features from the save version with ISCURRENTGEO = 'fut'
---- Save Edits
-- In ArcCatalog
---- Reconcile, post, delete version, compress
---- Remove the ISCURRENTGEO field (don't remove in SSMS, because it needs to happen in version and archives as well)
---- Test
---- delete the 'save' copy

--- WORKING AREA
