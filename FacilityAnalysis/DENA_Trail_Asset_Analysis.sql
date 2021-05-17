
--Report: DENA Trail assets where location description is not exactly in the asset description
select a.asset, a.[Description], f.DESCRIPTION from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
where f.Park = 'DENA'  AND f.Asset_Code = '2100' and a.[Description] not like '%' + f.DESCRIPTION + '%'
order by f.DESCRIPTION

--Report: DENA trail name in asset description does not match name in location description
select a.asset, a.[Description], a.location, f.DESCRIPTION as [location Description] from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
where f.Park = 'DENA'  AND f.Asset_Code = '2100' and a.[Description] not like '%' + f.DESCRIPTION + '%'
and a.asset <> '583085%'
and a.asset in (1494138,1502607,1492737,1492736,1492735,1494129,1494119,1494120,1494121,1494122,1494123,1494124,1494125,1494126,1494127,1494129)
order by f.location, a.asset

-- count of all DENA trail assets (not salavaged) by trail (546 total)
--select count(*)
select a.location, count(*) as Qty
from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
where f.Park = 'DENA'  AND f.Asset_Code = '2100' and f.type = 'OPERATING'
group by a.location order by Qty


-- list of all DENA trail assets (not salavaged)
select a.*
from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
where f.Park = 'DENA'  AND f.Asset_Code = '2100' and f.type = 'OPERATING'
order by a.DESCRIPTION

-- DENA Trail Assets in FMSS but not in SDE
exec sde.set_default
exec sde.set_current_version 'SDE.res_trail_assets';
select a.location, a.description, a.asset
from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
left join gis.TRAILS_FEATURE_PT_evw as g on a.Asset = g.FACASSETID
where f.Park = 'DENA'  AND f.Asset_Code = '2100' and f.type = 'OPERATING' and a.description not like '%Surface%'
and g.FACASSETID is null
order by a.location, a.description

-- DENA Trail assets in GIS but not in FMSS
select t.FACLOCID, g.TRLFEATTYPE, g.TRLFEATSUBTYPE, g.TRLFEATDESC, g.TRLFEATCOUNT --, c.cnt as qty
FROM gis.TRAILS_FEATURE_PT_evw as g left join gis.TRAILS_LN_evw as t on g.SEGMENTID = t.GEOMETRYID
-- left join (select FACASSETID, count(*) as cnt from gis.TRAILS_FEATURE_PT_evw group by FACASSETID) as c ON c.FACASSETID = g.FACASSETID
WHERE t.FACLOCID is not null and g.FACASSETID is null and g.UNITCODE = 'DENA'
and g.SOURCEDATE > '2015' and g.TRLFEATTYPE not like 'TRAIL %'
and g.TRLFEATSUBTYPE <> 'Swale' and g.TRLFEATSUBTYPE <> 'Drainage Ditch'
order by t.FACLOCID, g.TRLFEATTYPE, g.TRLFEATSUBTYPE


-- DENA Trail assets in GIS and FMSS (compare desctiptions/quanities)
select t.FACLOCID, g.FACASSETID, case when g.TRLFEATTYPE = 'Other' then g.TRLFEATTYPEOTHER else g.TRLFEATTYPE end as [Type],
g.TRLFEATSUBTYPE, g.TRLFEATDESC, g.TRLFEATCOUNT, c.cnt as gis_qty, a.DESCRIPTION
FROM gis.TRAILS_FEATURE_PT_evw as g left join gis.TRAILS_LN_evw as t on g.SEGMENTID = t.GEOMETRYID
left join (select FACASSETID, count(*) as cnt from gis.TRAILS_FEATURE_PT_evw group by FACASSETID) as c ON c.FACASSETID = g.FACASSETID
join dbo.FMSSExport_Asset as a on g.FACASSETID = a.Asset
WHERE t.FACLOCID is not null and g.UNITCODE = 'DENA'
and g.SOURCEDATE > '2015' 
--order by gis_qty DESC -- check quantity
order by [Type], g.TRLFEATSUBTYPE
--order by g.TRLFEATSUBTYPE, [Type]


-- Area Assets, picnic tables, seating, fire rings, area gravel, 
select a.*, f.Description
from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
where PARK='DENA' and Asset_Code like '3%' and TYPE = 'OPERATING'

-- I&M Assets, Signs, Kiosks, media displays, 
select a.*, f.Description
from FMSSExport_Asset as a join FMSSExport as f on a.[Location] = f.[Location]
where PARK='DENA' and Asset_Code like '7%' and TYPE = 'OPERATING'
order by f.[Description], a.[Description]

-- DENA trails surveyed in 2015
select Location, Description, qty from FMSSExport where PARK = 'DENA' AND Asset_Code = '2100' and type = 'OPERATING' and location IN ( 
  '109837','111187','113057','19970','19971','19972','19973','19975','19976','19977','19978','19979','19980','19982',
  '19983','19984','19986','19988','19989','19990','19991','19992','19993','231390','240163','83277','83278','88040','88873',
  '226534','103121','98599'
  ) order by description

-- DENA trails NOT surveyed in 2015    
select Location, Description, qty, Status, Type from FMSSExport where PARK = 'DENA' AND Asset_Code = '2100'
AND Location not in (
  '109837','111187','113057','19970','19971','19972','19973','19975','19976','19977','19978','19979','19980','19982',
  '19983','19984','19986','19988','19989','19990','19991','19992','19993','231390','240163','83277','83278','88040','88873',
  '226534','103121','98599'
)
order by type, status, description

-- ACTIVE DENA trails NOT surveyed in 2015
select Location, Description, qty from FMSSExport where PARK = 'DENA' AND Asset_Code = '2100' and type = 'OPERATING' and location IN ( 
  '109323','83275','19981','109324','19985','83279','109322','109371','226005','109321','244102','244103'
  ) order by description


-- ####################
-- Scratch area 
-- ####################
SELECT * FROM [akr_facility2].[dbo].[FMSSExport_Asset] where location = '19983' order by Asset
SELECT * FROM [akr_facility2].[dbo].FMSSExport where Location = '244871'
SELECT Location, Asset, Description FROM [akr_facility2].[dbo].[FMSSExport_Asset] order by Location,Asset

select * from FMSSExport_Asset where location is null

select * from FMSSExport_Asset where Asset = '202028'

select Description from FMSSExport where location = '19970'

select * from FMSSExport_Asset where Location =  '19971' order by description

select * from gis.akr_attach_evw  where faclocid = '113051'

exec sde.set_default
exec sde.set_current_version 'DBO.res_trails';

select g.TRLFEATTYPE, g.FACLOCID, t.FACLOCID from gis.TRAILS_FEATURE_PT_evw as g
join gis.TRAILS_LN as t on g.SEGMENTID = t.GEOMETRYID
where g.TRLFEATTYPE in ('Trail Head', 'Trail End') and g.FACLOCID IS NULL AND t.FACLOCID IS NOT NULL

SELECT COALESCE(FACLOCID, COALESCE(FEATUREID, COALESCE(FACASSETID, GEOMETRYID))) AS id,
			        REPLACE(ATCHLINK, 'https://akrgis.nps.gov/fmss/photos/web/', '') AS photo
               FROM gis.AKR_ATTACH_evw
              WHERE ATCHALTNAME IS NOT NULL AND (FACLOCID IS NOT NULL OR FACASSETID IS NOT NULL OR FEATUREID IS NOT NULL OR GEOMETRYID IS NOT NULL)
           ORDER BY id, ATCHDATE DESC