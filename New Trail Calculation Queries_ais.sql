-- TODO: Coordinate with FMSS.  Per the standard, Possible TSDS fields that can be populated using FMSS data are: 
--       TRLNAME, TRLALTNAME, TRLSTATUS, TRLCLASS, TRLSURFACE, TRLTYPE, TRLUSE, SEASONAL, SEADESC, MAINTAINER, ISEXTENT, RESTRICTIION and ASSETID.

-- 1) if TRLNAME is an empty string, change to NULL
update gis.TRAILS_LN_evw set TRLNAME = NULL where TRLNAME = ''
-- 2) if TRLALTNAME is an empty string, change to NULL
update gis.TRAILS_LN_evw set TRLALTNAME = NULL where TRLALTNAME = ''
-- 3) if MAPLABEL is an empty string, change to NULL
update gis.TRAILS_LN_evw set MAPLABEL = NULL where MAPLABEL = ''
-- 4) TRLFEATTYPE - Required Domain Value; defaults to 'Unknown'
update gis.TRAILS_LN_evw set TRLFEATTYPE = 'Unknown' where TRLFEATTYPE is null or TRLFEATTYPE = ''
-- 5) TRLSTATUS - defaults to FMSSExport.Status or 'Existing'
merge into gis.TRAILS_LN_evw as p
  using (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from DOM_RDSTATUS)) as f
  on f.Location = p.FACLOCID and ((p.TRLSTATUS is null or p.TRLSTATUS = '') and f.Status is not null)
  when matched then update set TRLSTATUS = f.Status;
update gis.TRAILS_LN_evw set TRLSTATUS = 'Existing' where TRLSTATUS is null or TRLSTATUS = ''
-- 6) TRLTRACK: This is an AKR extension; Required domain element; defaults to 'Unknown'
update gis.TRAILS_LN_evw set TRLTRACK = 'Unknown' where TRLTRACK is null or TRLTRACK = ''
-- 7) TRLCLASS defaults to 'Unknown'
--     TODO: if a feature has a FACLOCID then the FMSS Funtional Class implies a TRLCLASS.  See section 4.3 of the standard
update gis.TRAILS_LN_evw set TRLCLASS = 'Unknown' where TRLCLASS is null or TRLCLASS = ''
-- 8) TRLUSE_* -- Nothing to do, invalid values (including empty string) will generate an error
-- 8) Create function to Calc TRLUSE from TRL_USE_*
--    TODO decide if we want TRLUSE to be non-compliant, or if we want to add another field for AKR custom uses;  dbo.TrailUse() is compliant, dbo.TrailUseAKR() is not
update gis.TRAILS_LN_evw set TRLUSE =
  dbo.TrailUse(TRLUSE_FOOT,TRLUSE_BICYCLE,TRLUSE_HORSE,TRLUSE_ATV,TRLUSE_4WD,TRLUSE_MOTORCYCLE,TRLUSE_SNOWMOBILE,TRLUSE_SNOWSHOE,TRLUSE_NORDIC,
               TRLUSE_DOGSLED,TRLUSE_MOTORBOAT,TRLUSE_CANOE,TRLUSE_OHVSUB,TRLUSE_SKITOUR,TRLUSE_DOWNHILL,TRLUSE_CANYONEER,TRLUSE_CLIMB,DEFAULT,DEFAULT,DEFAULT)
  where TRLUSE <> dbo.TrailUse(TRLUSE_FOOT,TRLUSE_BICYCLE,TRLUSE_HORSE,TRLUSE_ATV,TRLUSE_4WD,TRLUSE_MOTORCYCLE,TRLUSE_SNOWMOBILE,TRLUSE_SNOWSHOE,TRLUSE_NORDIC,
                               TRLUSE_DOGSLED,TRLUSE_MOTORBOAT,TRLUSE_CANOE,TRLUSE_OHVSUB,TRLUSE_SKITOUR,TRLUSE_DOWNHILL,TRLUSE_CANYONEER,TRLUSE_CLIMB,DEFAULT,DEFAULT,DEFAULT)
-- 9) TRLISSOCIAL is an AKR extension; it silently defaults to 'No'
update gis.TRAILS_LN_evw set TRLISSOCIAL = 'No' where TRLISSOCIAL is null or TRLISSOCIAL = ''
-- 10) TRLISANIMAL  is an AKR extension; it silently defaults to 'No'
update gis.TRAILS_LN_evw set TRLISANIMAL = 'No' where TRLISANIMAL is null or TRLISANIMAL = ''
-- 11) TRLISADMIN is an AKR extension; it silently defaults to 'No'
update gis.TRAILS_LN_evw set TRLISADMIN = 'No' where TRLISADMIN is null or TRLISADMIN = ''
-- 12) TRLSURFACE defaults to 'Unknown'
update gis.TRAILS_LN_evw set TRLSURFACE = 'Unknown' where TRLSURFACE is null or TRLSURFACE = ''
-- 13) WHLENGTH_FT: This is an AKR extension; it is an optional numerical value > Zero. If zero is provided convert to Null.
update gis.TRAILS_LN_evw set WHLENGTH_FT = NULL where WHLENGTH_FT = 0
-- 14) TRLDESC: This is an AKR extension; Optional free text; it should not be an empty string
update gis.TRAILS_LN_evw set TRLDESC = NULL where TRLDESC = ''
-- 15) ISBRIDGE is an AKR extension; it silently defaults to 'No'
update gis.TRAILS_LN_evw set ISBRIDGE = 'No' where ISBRIDGE is null or ISBRIDGE = ''
-- 16) ISTUNNEL  is an AKR extension; it silently defaults to 'No'
update gis.TRAILS_LN_evw set ISTUNNEL = 'No' where ISTUNNEL is null or ISTUNNEL = ''
-- 17) if SEASONAL is null and FACLOCID is non-null use FMSS Lookup.
--     TODO: Get GOOD FMSS data
--merge into gis.TRAILS_LN_evw as p
--  using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
--  on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
--  when matched then update set SEASONAL = f.OPSEAS;
-- 18) if SEASDESC is an empty string, change to NULL
--     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
update gis.TRAILS_LN_evw set SEASDESC = NULL where SEASDESC = ''
update gis.TRAILS_LN_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
-- 19) if MAINTAINER is null and FACLOCID is non-null use FMSS Lookup.
--     TODO: requires changing the domain to match FMSS and then populate from FMSS
--merge into gis.TRAILS_LN_evw as p
--  using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
--  on f.Location = p.FACLOCID and (p.MAINTAINER is null and f.FAMARESP is not null)
--  when matched then update set MAINTAINER = f.FAMARESP;
-- 20) ISEXTANT defaults to 'True' with a warning (during QC)
update gis.TRAILS_LN_evw set ISEXTANT = 'True' where ISEXTANT is NULL
-- 21) Add LINETYPE = 'Center line' if null/empty in gis.ROADS_LN
update gis.TRAILS_LN_evw set LINETYPE = 'Center line' where LINETYPE is null or LINETYPE = '' 
-- 22) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
--     Takes about 26 seconds on the base table;  To check for both in/out takes about 51 seconds on base table
--merge into gis.TRAILS_LN_evw as t1 using gis.AKR_UNIT as t2
--  on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK)
--  when matched then update set ISOUTPARK = CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END;
-- Adds a check for both in/out 
merge into gis.TRAILS_LN_evw as t1 using gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
  when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
-- 23) PUBLICDISPLAY defaults to No Public Map Display
update gis.TRAILS_LN_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
-- 24) DATAACCESS defaults to No Public Map Display
update gis.TRAILS_LN_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
-- 25) UNITCODE is a spatial calc if null
-- TODO: Should we first calc from FMSS? would also need to fix qc check.  What if FMSS value is not in spatial extent?
merge into gis.TRAILS_LN_evw as t1 using gis.AKR_UNIT as t2
  on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
  when matched then update set UNITCODE = t2.Unit_Code;
-- 26) UNITNAME is always calc'd from UNITCODE
--     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
update gis.TRAILS_LN_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
merge into gis.TRAILS_LN_evw as t1 using DOM_UNITCODE as t2
  on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
  when matched then update set UNITNAME = t2.UNITNAME;
-- 27) if GROUPCODE is an empty string, change to NULL
update gis.TRAILS_LN_evw set GROUPCODE = NULL where GROUPCODE = ''
-- 28) GROUPNAME is always calc'd from GROUPCODE
update gis.TRAILS_LN_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
merge into gis.TRAILS_LN_evw as t1 using gis.AKR_GROUP as t2
  on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
  when matched then update set GROUPNAME = t2.Group_Name;
-- 29) REGIONCODE is always set to AKR
update gis.TRAILS_LN_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
-- 30) if MAPMETHOD is NULL or an empty string, change to Unknown
update gis.TRAILS_LN_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
-- 31) if MAPSOURCE is NULL or an empty string, change to Unknown
update gis.TRAILS_LN_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
-- 32) SOURCEDATE: Nothing to do.
-- 33) if XYACCURACY is NULL or an empty string, change to Unknown
update gis.TRAILS_LN_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
-- 34) if FACLOCID is empty string change to null
update gis.TRAILS_LN_evw set FACLOCID = NULL where FACLOCID = ''
-- 35) if FACASSETID is empty string change to null
update gis.TRAILS_LN_evw set FACASSETID = NULL where FACASSETID = ''
-- 36) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
update gis.TRAILS_LN_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
-- 37) Add GEOMETRYID if null/empty
update gis.TRAILS_LN_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
-- 38) if NOTES is an empty string, change to NULL
update gis.TRAILS_LN_evw set NOTES = NULL where NOTES = ''
