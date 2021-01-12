exec sde.set_default
exec sde.set_current_version 'owner.name'
exec sde.set_current_version 'dbo.res_new_fmss'
exec sde.set_current_version '"NPS\JJCUSICK".joel_facilities';

-- Count of operating features
select d.Code, d.Description, count(*) from FMSSExport as f
join DOM_FMSS_ASSETCODE as d on f.Asset_Code = d.Code
where f.Type = 'OPERATING' and f.status = 'OPERATING' or f.status = 'SITE'
group by d.Code, d.Description
order by d.code

-- 
-- All top level location records (no parent)
-- 95
select * from FMSSExport where Type <> 'SALVAGE' and (parent is null or parent = 'N/A') order by Park, Asset_Code

-- All top level location records with at least one child
-- 17
select p.location, p.description from FMSSExport as p left join FMSSExport as c on p.location = c.parent where c.location is not null and c.Type <> 'SALVAGE' and p.Type <> 'SALVAGE' and p.parent = 'N/A' group by p.location, p.description

-- All top level location records with no children
-- 78
select p.location, p.description, p.Park, p.Asset_Code from FMSSExport as p left join FMSSExport as c on p.location = c.parent where c.location is null and p.Type <> 'SALVAGE' and p.parent = 'N/A' group by p.location, p.description, p.Park, p.Asset_Code order by p.Asset_code, p.Park


-- What's Missing
-- missing/operational/all status/all

-- 0/80/87/106 Site/Area
select * from FMSSExport where Asset_Code = '0000' and Type = 'OPERATING' and status = 'SITE'
order by Type, status, park

-- 0/80/87/106 roads
select f.* from FMSSExport as f
left join gis.ROADS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '1100' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 0/116/125/149 parking areas
select f.* from FMSSExport as f
left join gis.PARKLOTS_PY_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '1300' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 0/13/13/15 road bridges
select f.* from FMSSExport as f
left join gis.ROADS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '1700' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 0/176/189/198 Trails
select f.* from FMSSExport as f
left join gis.TRAILS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '2100' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park, location

-- 0/34/38/40 Trail Bridges
select f.* from FMSSExport as f
left join gis.TRAILS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '2200' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 1/1/1/1 Trail Tunnels (utilidor)
select f.* from FMSSExport as f
left join gis.TRAILS_LN_evw as r on r.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '2300' and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 140/140/148/170 Maintained Landscapes
select * from FMSSExport where Asset_Code = '3100' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 1/1/1/3 Boundary (Fence)
select * from FMSSExport where Asset_Code = '3800' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 0/1268/1408/1608 buildings (note 8 buildings have been demoed and removed from GIS, but FMSS has not caught up) 
select case when r2.faclocid is null then 'No' else 'Yes' end as gis_deleted, f.* from FMSSExport as f
left join gis.AKR_BLDG_CENTER_PT_evw as r on r.FACLOCID = f.Location
left join gis.AKR_BLDG_CENTER_PT_H as r2 on r2.FACLOCID = f.Location
where r.FACLOCID is null and f.Asset_Code = '4100' and r2.faclocid is null and f.Type = 'OPERATING' and f.status = 'OPERATING'
order by Status, park

-- 1/1/1/1 Constructed Waterway
select * from FMSSExport where Asset_Code = '6200' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 17/17/19/24 Marina/Waterfront System
select * from FMSSExport where Asset_Code = '6300' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 33/33/33/35 Aviation System
select * from FMSSExport where Asset_Code = '6400' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 0/21/24/33 Outdoor Sculptures/Monu/Interp
select * from FMSSExport where Asset_Code = '7100' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 9/9/10/11 Maintained Archeological Sites
select * from FMSSExport where Asset_Code = '7200' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 0/0/0/1 Towers/Missile Silos
select * from FMSSExport where Asset_Code = '7400' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 104/104/116/128 Intepretive Media
select * from FMSSExport where Asset_Code = '7500' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park

-- 4/4/4/4 Amphitheaters
select * from FMSSExport where Asset_Code = '7900' and Type = 'OPERATING' and status = 'OPERATING'
order by Type, status, park



