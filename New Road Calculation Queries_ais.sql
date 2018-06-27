-- 1) if RDNAME is an empty string, change to NULL
update gis.ROADS_LN_evw set RDNAME = NULL where RDNAME = ''
-- 2) if RDALTNAME is an empty string, change to NULL
update gis.ROADS_LN_evw set RDALTNAME = NULL where RDALTNAME = ''
-- 3) if MAPLABEL is an empty string, change to NULL
update gis.ROADS_LN_evw set MAPLABEL = NULL where MAPLABEL = ''
-- 4) RDSTATUS - defaults FMSSExport.Status or 'Existing'
merge into gis.ROADS_LN_evw as p
  using (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from DOM_RDSTATUS)) as f
  on f.Location = p.FACLOCID and ((p.RDSTATUS is null or RDSTATUS = '') and f.Status is not null)
  when matched then update set RDSTATUS = f.Status;
update gis.ROADS_LN_evw set RDSTATUS = 'Existing' where RDSTATUS is null or RDSTATUS = ''
-- 5) RDCLASS defaults to 'Unknown'
--     TODO: if a feature has a FACLOCID then the FMSS Funtional Class implies a RDCLASS.  See section 4.3 of the standard
update gis.ROADS_LN_evw set RDCLASS = 'Unknown' where RDCLASS is null or RDCLASS = ''
-- 6) RDSURFACE defaults to 'Unknown'
update gis.ROADS_LN_evw set RDSURFACE = 'Unknown' where RDSURFACE is null or RDSURFACE = ''
-- 7) RDONEWAY is not required, but if it provided is it should not be an empty string
update gis.ROADS_LN_evw set RDONEWAY = NULL where RDONEWAY = ''
-- 9) RDLANES -- Nothing to do.
-- 10) RDHICLEAR is not required, but if it provided is it should not be an empty string
update gis.ROADS_LN_evw set RDHICLEAR = NULL where RDHICLEAR = ''
-- 11) RTENUMBER is not required, but if it provided is it should not be an empty string
update gis.ROADS_LN_evw set RTENUMBER = NULL where RTENUMBER = ''
-- 12) ISBRIDGE is an AKR extension; it silently defaults to 'No'
update gis.ROADS_LN_evw set ISBRIDGE = 'No' where ISBRIDGE is null or ISBRIDGE = ''
-- 13) ISTUNNEL  is an AKR extension; it silently defaults to 'No'
update gis.ROADS_LN_evw set ISTUNNEL = 'No' where ISTUNNEL is null or ISTUNNEL = ''
-- 14) if SEASONAL is null and FACLOCID is non-null use FMSS Lookup.
--     TODO: Get GOOD FMSS data
--merge into gis.ROADS_LN_evw as p
--  using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
--  on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
--  when matched then update set SEASONAL = f.OPSEAS;
-- 15) if SEASDESC is an empty string, change to NULL
--     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
update gis.ROADS_LN_evw set SEASDESC = NULL where SEASDESC = ''
update gis.ROADS_LN_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
-- 16) if RDMAINTAINER is null and FACLOCID is non-null use FMSS Lookup.
--     TODO: requires changing the domain to match FMSS and then populate from FMSS
--merge into gis.ROADS_LN_evw as p
--  using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
--  on f.Location = p.FACLOCID and (p.RDMAINTAINER is null and f.FAMARESP is not null)
--  when matched then update set RDMAINTAINER = f.FAMARESP;
-- 17) ISEXTANT defaults to 'True' with a warning (during QC)
update gis.ROADS_LN_evw set ISEXTANT = 'True' where ISEXTANT is NULL
-- 18) Add LINETYPE = 'Center line' if null/empty in gis.ROADS_LN
update gis.ROADS_LN_evw set LINETYPE = 'Center line' where LINETYPE is null or LINETYPE = '' 
-- 19) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
--     TODO: set to BOTH if the road straddles a boundary (currently set to YES if any part of a road is within the boundary)
merge into gis.ROADS_LN_evw as t1 using gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK)
  when matched then update set ISOUTPARK = CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END;
-- 20) PUBLICDISPLAY defaults to No Public Map Display
update gis.ROADS_LN_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
-- 21) DATAACCESS defaults to No Public Map Display
update gis.ROADS_LN_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
-- 22) UNITCODE is a spatial calc if null
-- TODO: Should we first calc from FMSS? would also need to fix qc check.  What if FMSS value is not in spatial extent?
merge into gis.ROADS_LN_evw as t1 using gis.AKR_UNIT as t2
  on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
  when matched then update set UNITCODE = t2.Unit_Code;
-- 23) UNITNAME is always calc'd from UNITCODE
--     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
update gis.ROADS_LN_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
merge into gis.ROADS_LN_evw as t1 using DOM_UNITCODE as t2
  on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
  when matched then update set UNITNAME = t2.UNITNAME;
-- 24) if GROUPCODE is an empty string, change to NULL
update gis.ROADS_LN_evw set GROUPCODE = NULL where GROUPCODE = ''
-- 25) GROUPNAME is always calc'd from GROUPCODE
update gis.ROADS_LN_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
merge into gis.ROADS_LN_evw as t1 using gis.AKR_GROUP as t2
  on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
  when matched then update set GROUPNAME = t2.Group_Name;
-- 26) REGIONCODE is always set to AKR
update gis.ROADS_LN_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
-- 27) if MAPMETHOD is NULL or an empty string, change to Unknown
update gis.ROADS_LN_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
-- 28) if MAPSOURCE is NULL or an empty string, change to Unknown
--     by SQL Magic '' is the same as any string of just white space
update gis.ROADS_LN_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
-- 29) SOURCEDATE: Nothing to do.
-- 30) if XYACCURACY is NULL or an empty string, change to Unknown
update gis.ROADS_LN_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
-- 31) ROUTEID is not required, but if it provided is it should not be an empty string
update gis.ROADS_LN_evw set ROUTEID = NULL where ROUTEID = ''
-- 32) if FACLOCID is empty string change to null
update gis.ROADS_LN_evw set FACLOCID = NULL where FACLOCID = ''
-- 33) if FACASSETID is empty string change to null
update gis.ROADS_LN_evw set FACASSETID = NULL where FACASSETID = ''
-- 34) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
update gis.ROADS_LN_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
-- 35) Add GEOMETRYID if null/empty
update gis.ROADS_LN_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
-- 36) if NOTES is an empty string, change to NULL
update gis.ROADS_LN_evw set NOTES = NULL where NOTES = ''
