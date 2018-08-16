exec sde.set_default
EXEC sde.set_current_version 'bldg_from_fmss';

-- Query to compare the FMSS Location with the GIS location

select b.faclocid as Location, f.Park, f.Description, f.Status, round(shape.STX,5) as gis_lon, round(shape.STY,5) as gis_lat , f.lat as fmss_lat, f.lon as fmss_lon, 
  GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText('POINT('+lon+' '+lat+')',4269)) as dist_m
  from gis.AKR_BLDG_CENTER_PT_evw as b left join FMSSExport as f on b.FACLOCID = f.Location
  where b.faclocid is not null and (
  GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText('POINT('+lon+' '+lat+')',4269)) > 50
  or f.lat is null or f.lon is null) and f.Status <> 'REMOVED'
union all 
select f.Location, f.Park, f.Description, f.Status, null as gis_lon, null as gis_lat, f.lat, f.lon, null as dist_m
  from FMSSExport as f left join gis.AKR_BLDG_CENTER_PT_evw as b on b.FACLOCID = f.Location
  where f.Asset_Code = '4100' and f.Type_ = 'OPERATING' and b.shape is null
  and f.Status = 'OPERATING' --  and f.lat is not null --


-- Several FMSS items without GIS locations are no longer extant, and are in the history table (gis.AKR_BLDG_CENTER_PT_H)
-- The 5 records in WRST (4 future bldgs at kennecott and the Bonanza mine trail toilet) are in the wrong location in FMSS



-- The following code is to create new center points, and then QC them.

  select top 10 shape.STAsText(), round(shape.STX,6) as gis_lon, round(shape.STY,6) as gis_lat from gis.AKR_BLDG_CENTER_PT
  select top 10 lat, lon from FMSSExport

-- What I want to to create
 select f.Location, f.Park, f.Description, f.Description,
  geometry::STGeomFromText('point ('+f.lon+' '+f.lat+')', 4269) as Shape,
  getdate() as CREATEDATE, 'RESARWAS' as CREATEUSER,
  'Other' as MAPMETHOD, 'FMSS Export' as MAPSOURCE, '2018-07-11' as sourcedate
  from FMSSExport as f left join gis.AKR_BLDG_CENTER_PT_evw as b on b.FACLOCID = f.Location
  where f.Asset_Code = '4100' and f.Type_ = 'OPERATING' and b.shape is null
  and f.lat is not null --and f.Status = 'OPERATING' 

-- Create a new version, and then edit it to add new features
EXEC sde.create_version 'sde.DEFAULT', 'bldg_from_fmss', 1, 2, 'Using lat/lon in FMSS to create new buildings';
EXEC sde.set_current_version 'bldg_from_fmss';
EXEC sde.edit_version 'bldg_from_fmss', 1;

INSERT INTO gis.AKR_BLDG_CENTER_PT_evw (FACLOCID, UNITCODE, BLDGNAME, BLDGALTNAME, Shape, CREATEDATE, CREATEUSER, MAPMETHOD, MAPSOURCE, SOURCEDATE)
 select f.Location, f.Park, f.Description, f.Description,
  geometry::STGeomFromText('point ('+f.lon+' '+f.lat+')', 4269) as Shape,
  getdate() as CREATEDATE, 'RESARWAS' as CREATEUSER,
  'Other' as MAPMETHOD, 'FMSS Export' as MAPSOURCE, '2018-07-11' as sourcedate
  from FMSSExport as f left join gis.AKR_BLDG_CENTER_PT_evw as b on b.FACLOCID = f.Location
  where f.Asset_Code = '4100' and f.Type_ = 'OPERATING' and b.shape is null
  and f.lat is not null --and f.Status = 'OPERATING' ;

COMMIT;
EXEC sde.edit_version 'bldg_from_fmss', 2;

-- Do some QC testing
select Asset_Code, count(*) from FMSSExport where lat is not null and Asset_Code <> '4100' group by Asset_Code order by Asset_Code

-- replace existing single family with a new duplex
select * from FMSSExport where location in ('229446', '42600')

-- Kennecott locations
select location, description, lat, lon, status from FMSSExport where Description like '%KENN%' and park = 'WRST' order by lat

select * from FMSSExport where location in ('94364', '42563', '246444')
