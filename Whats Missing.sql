exec sde.set_default
exec sde.set_current_version 'owner.name'


-- Count of operating features
select d.Code, d.Description, count(*) from FMSSExport as f
join DOM_FMSS_ASSETCODE as d on f.Asset_Code = d.Code
where f.Type = 'OPERATING' and f.status = 'OPERATING'
group by d.Code, d.Description
order by d.code

-- What's Missing

-- 0/80 roads
select f.* from FMSSExport as f
left join gis.ROADS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '1100' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 0/116 parking areas
select f.* from FMSSExport as f
left join gis.PARKLOTS_PY_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '1300' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 0/13 road bridges
select f.* from FMSSExport as f
left join gis.ROADS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '1700' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 27/176 Trails
select f.* from FMSSExport as f
left join gis.TRAILS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '2100' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 5/34 Trail Bridges
select f.* from FMSSExport as f
left join gis.TRAILS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '2200' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 1/1 Trail Tunnels (utilidor)
select f.* from FMSSExport as f
left join gis.TRAILS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '2300' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 140/169 Maintained Landscapes
select * from FMSSExport where Asset_Code = '3100'

-- 1/3 Boundary (Fence)
select * from FMSSExport where Asset_Code = '3800'

-- 31/1268 buildings (note 8 buildings have been demoed and removed from GIS, but FMSS has not caught up) 
select case when r2.faclocid is null then 'No' else 'Yes' end as gis_deleted, f.* from FMSSExport as f
left join gis.AKR_BLDG_CENTER_PT_evw as r on r.FACLOCID = f.Location
left join gis.AKR_BLDG_CENTER_PT_H as r2 on r2.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '4100' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park
