-- 1) if LOTNAME is an empty string, change to NULL
update gis.PARKLOTS_PY_evw set LOTNAME = NULL where LOTNAME = ''
-- 2) if LOTALTNAME is an empty string, change to NULL
update gis.PARKLOTS_PY_evw set LOTALTNAME = NULL where LOTALTNAME = ''
-- 3) if MAPLABEL is an empty string, change to NULL
update gis.PARKLOTS_PY_evw set MAPLABEL = NULL where MAPLABEL = ''
-- 4) Add LOTTYPE = 'Parking Lot' if null in gis.PARKLOTS_PY
update gis.PARKLOTS_PY_evw set POLYGONTYPE = 'Circumscribed polygon' where POLYGONTYPE is null or POLYGONTYPE = '' 
-- 5) if SEASONAL is null and FACLOCID is non-null use FMSS Lookup.
merge into gis.PARKLOTS_PY_evw as p
  using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
  when matched then update set SEASONAL = f.OPSEAS;
-- 6) if SEASDESC is an empty string, change to NULL
--    Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
update gis.PARKLOTS_PY_evw set SEASDESC = NULL where SEASDESC = ''
update gis.PARKLOTS_PY_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
-- 7) if MAINTAINER is null and FACLOCID is non-null use FMSS Lookup.
--    TODO: requires changing the domain to match FMSS and then populate from FMSS
merge into gis.PARKLOTS_PY_evw as p
  using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID and (p.MAINTAINER is null and f.FAMARESP is not null)
  when matched then update set MAINTAINER = f.FAMARESP;
-- 8) ISEXTANT defaults to 'True' with a warning (during QC)
update gis.PARKLOTS_PY_evw set ISEXTANT = 'True' where ISEXTANT is NULL
-- 9) Add POLYGONTYPE = 'Perimeter polygon' if null/empty in gis.PARKLOTS_PY
-- 10) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
--     TODO: set to BOTH if the parking lot straddles a boundary (currently set to YES if any part of a parking lot is within the boundary)
merge into gis.PARKLOTS_PY_evw as t1 using gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK)
  when matched then update set ISOUTPARK = CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END;
update gis.PARKLOTS_PY_evw set POLYGONTYPE = 'Perimeter polygon' where POLYGONTYPE is null or POLYGONTYPE = '' 
-- 11) PUBLICDISPLAY defaults to No Public Map Display
update gis.PARKLOTS_PY_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
-- 12) DATAACCESS defaults to No Public Map Display
update gis.PARKLOTS_PY_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
-- 13) UNITCODE is a spatial calc if null
-- TODO: Should we first calc from FMSS? would also need to fix qc check.  What if FMSS value is not in spatial extent?
merge into gis.PARKLOTS_PY_evw as t1 using gis.AKR_UNIT as t2
  on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
  when matched then update set UNITCODE = t2.Unit_Code;
-- 14) UNITNAME is always calc'd from UNITCODE
update gis.PARKLOTS_PY_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is null
merge into gis.PARKLOTS_PY_evw as t1 using DOM_UNITCODE as t2
  on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
  when matched then update set UNITNAME = t2.UNITNAME;
--  TODO: Should we get UNITNAME from AKR_UNIT or DOM_UNITCODE?  Unit codes and Names differ
--  merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_UNIT as t2
--    on t1.UNITCODE = t2.Unit_Code and t1.UNITNAME <> t2.UNIT_NAME
--    when matched then update set UNITNAME = t2.UNIT_NAME;
-- 15) if GROUPCODE is an empty string, change to NULL
update gis.PARKLOTS_PY_evw set GROUPCODE = NULL where GROUPCODE = ''
-- 16) GROUPNAME is always calc'd from GROUPCODE
update gis.PARKLOTS_PY_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
merge into gis.PARKLOTS_PY_evw as t1 using gis.AKR_GROUP as t2
  on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
  when matched then update set GROUPNAME = t2.Group_Name;
-- 17) REGIONCODE is always set to AKR
update gis.PARKLOTS_PY_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
-- 18) if MAPMETHOD is NULL or an empty string, change to Unknown
update gis.PARKLOTS_PY_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
-- 19) if MAPSOURCE is NULL or an empty string, change to Unknown
--     by SQL Magic '' is the same as any string of just white space
update gis.PARKLOTS_PY_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
-- 20) SOURCEDATE: Nothing to do.
-- 21) if XYACCURACY is NULL or an empty string, change to Unknown
update gis.PARKLOTS_PY_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
-- 22) if FACLOCID is empty string change to null
update gis.PARKLOTS_PY_evw set FACLOCID = NULL where FACLOCID = ''
-- 23) if FACASSETID is empty string change to null
update gis.PARKLOTS_PY_evw set FACASSETID = NULL where FACASSETID = ''
-- 24) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
update gis.PARKLOTS_PY_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
-- 25) Add GEOMETRYID if null/empty
update gis.PARKLOTS_PY_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
-- 26) if NOTES is an empty string, change to NULL
update gis.PARKLOTS_PY_evw set NOTES = NULL where NOTES = ''
