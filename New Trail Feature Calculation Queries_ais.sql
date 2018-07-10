-- 1) if TRLFEATNAME is an empty string, change to NULL
update gis.TRAILS_FEATURE_PT_evw set TRLFEATNAME = NULL where TRLFEATNAME = ''
-- 2) if TRLFEATALTNAME is an empty string, change to NULL
update gis.TRAILS_FEATURE_PT_evw set TRLFEATALTNAME = NULL where TRLFEATALTNAME = ''
-- 3) if MAPLABEL is an empty string, change to NULL
update gis.TRAILS_FEATURE_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
-- 4) TRLFEATTYPE - Required Domain Value; no default value; nothing to do.
-- 5) TRLFEATTYPEOTHER: This is an AKR extension; it is optional free text.  Set empty string to null
update gis.TRAILS_FEATURE_PT_evw set TRLFEATTYPEOTHER = null where TRLFEATTYPEOTHER = ''
update gis.TRAILS_FEATURE_PT_evw set TRLFEATTYPEOTHER = null where TRLFEATTYPE <> 'Other' and TRLFEATTYPEOTHER <> null 
-- 6) TRLFEATSUBTYPE: This is an AKR extension; it is optional free text.  Set empty string to null
update gis.TRAILS_FEATURE_PT_evw set TRLFEATSUBTYPE = NULL where TRLFEATSUBTYPE = ''
-- 7) TRLFEATDESC is an AKR extension; it is optional free text.  Set empty string to null
update gis.TRAILS_FEATURE_PT_evw set TRLFEATDESC = NULL where TRLFEATDESC = ''
-- 8) TRLFEATCOUNT is an AKR extension; it silently clears zero to null
update gis.TRAILS_FEATURE_PT_evw set TRLFEATCOUNT = NULL where TRLFEATCOUNT = 0
-- 9) WHLENGTH is an AKR extension; it silently clears zero to null
update gis.TRAILS_FEATURE_PT_evw set WHLENGTH = NULL where WHLENGTH = 0
-- 10) WHLENUOM  is an AKR extension; it silently defaults to 'No'
update gis.TRAILS_FEATURE_PT_evw set WHLENUOM = NULL where WHLENUOM = ''
update gis.TRAILS_FEATURE_PT_evw set WHLENUOM = NULL where WHLENGTH is NULL and WHLENUOM is not null
-- 11) POINTTYPE: if it is null/empty, then it will default to 'Arbitrary point'
update gis.TRAILS_FEATURE_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = '' 
-- 12) ISEXTANT defaults to 'True' with a warning (during QC)
update gis.TRAILS_FEATURE_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
-- 13) ISOUTPARK (See the end, this must be done after UNITCODE)
-- 14) PUBLICDISPLAY defaults to No Public Map Display
update gis.TRAILS_FEATURE_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
-- 15) DATAACCESS defaults to No Public Map Display
update gis.TRAILS_FEATURE_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
-- 16) UNITCODE is a spatial calc if null
merge into gis.TRAILS_FEATURE_PT_evw as t1 using gis.AKR_UNIT as t2
  on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
  when matched then update set UNITCODE = t2.Unit_Code;
-- 17) UNITNAME is always calc'd from UNITCODE
--     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
update gis.TRAILS_FEATURE_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
merge into gis.TRAILS_FEATURE_PT_evw as t1 using DOM_UNITCODE as t2
  on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
  when matched then update set UNITNAME = t2.UNITNAME;
-- 18) if GROUPCODE is an empty string, change to NULL
update gis.TRAILS_FEATURE_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
-- 19) GROUPNAME is always calc'd from GROUPCODE
update gis.TRAILS_FEATURE_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
merge into gis.TRAILS_FEATURE_PT_evw as t1 using gis.AKR_GROUP as t2
  on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
  when matched then update set GROUPNAME = t2.Group_Name;
-- 20) REGIONCODE is always set to AKR
update gis.TRAILS_FEATURE_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
-- 21) if MAPMETHOD is NULL or an empty string, change to Unknown
update gis.TRAILS_FEATURE_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
-- 22) if MAPSOURCE is NULL or an empty string, change to Unknown
update gis.TRAILS_FEATURE_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
-- 23) SOURCEDATE: Nothing to do.
-- 24) if XYACCURACY is NULL or an empty string, change to Unknown
update gis.TRAILS_FEATURE_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
-- 25) if FACLOCID is empty string change to null
update gis.TRAILS_FEATURE_PT_evw set FACLOCID = NULL where FACLOCID = ''
-- 26) if FACASSETID is empty string change to null
update gis.TRAILS_FEATURE_PT_evw set FACASSETID = NULL where FACASSETID = ''
-- 27) FEATUREID: No action
-- 28) Add GEOMETRYID if null/empty
update gis.TRAILS_FEATURE_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
-- 29) if NOTES is an empty string, change to NULL
update gis.TRAILS_FEATURE_PT_evw set NOTES = NULL where NOTES = ''
-- 13) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
merge into gis.TRAILS_FEATURE_PT_evw as t1 using gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
  when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
