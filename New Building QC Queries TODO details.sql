-------------------------
-- TODO PUBLICDISPLAY
-------------------------
select BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE, FACOWNER, MAPLABEL, BLDGNAME from gis.AKR_BLDG_CENTER_PT where PUBLICDISPLAY = 'Public Map Display'
  and (BLDGSTATUS <> 'Existing' or isextant = 'False' or unitcode is null )
select BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE, FACOWNER, MAPLABEL, BLDGNAME from gis.AKR_BLDG_CENTER_PT where PUBLICDISPLAY = 'Public Map Display'
  and (ISOUTPARK = 'Yes'  or facuse = 'Admin Use')
select BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE, FACOWNER, MAPLABEL, BLDGNAME from gis.AKR_BLDG_CENTER_PT where PUBLICDISPLAY = 'Public Map Display'
  and (FACOWNER not in ('NPS', 'FEDERAL'))

-------------------------
-- TODO: UNITCODE
-------------------------
-- No missing unit codes
select t1.UNITCODE, t1.MAPLABEL, t1.BLDGNAME from gis.AKR_BLDG_CENTER_PT_evw as t1 where t1.UNITCODE is null
-- All unit codes match FMSS (except some in WEAR)
select  f.Park, p.UNITCODE, p.GROUPCODE from gis.AKR_BLDG_CENTER_PT_evw as p join
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park -- and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
-- Unit codes not in DOM
select t1.UNITCODE, t1.MAPLABEL, t1.BLDGNAME from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null order by t1.UNITCODE
-- UNIT codes not in akr_bnd
select t1.UNITCODE, t1.MAPLABEL, t1.BLDGNAME  from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null order by t1.UNITCODE

-------------------------
-- TODO UNITNAME: UNIT DOM v. AKR_BND
-------------------------

SELECT * FROM DOM_UNITCODE
select * from gis.akr_unit
-- Units in domain, but not akr_bnd
select * from DOM_UNITCODE as d left join gis.akr_unit u on d.code = u.Unit_Code where u.Unit_Code is null
-- Units in akr_bnd, but not domain
select * from DOM_UNITCODE as d right join gis.akr_unit u on d.code = u.Unit_Code where d.Code is null
-- mismatch in unit name
select d.code, d.UNITNAME, u.Unit_Name from DOM_UNITCODE as d inner join gis.akr_unit u on d.code = u.Unit_Code where d.UNITNAME <> u.Unit_Name
-- mismatch in unit_type
select d.code, d.UNITTYPE, u.Unit_Type from DOM_UNITCODE as d inner join gis.akr_unit u on d.code = u.Unit_Code where d.UNITTYPE <> u.Unit_Type

-------------------------
-- TODO GROUPCODE
-------------------------
select GROUPCODE, count(*) from gis.AKR_BLDG_CENTER_PT_evw group by GROUPCODE
select GROUPCODE, count(*) from dbo.DOM_UNITCODE group by GROUPCODE
--select * from dbo.DOM_UNITCODE where GROUPCODE = 'WEAR'
select GROUP_CODE, count(*) from gis.AKR_GROUP group by GROUP_CODE
-- Spatial check of group code fails - i.e. Kotzebue buildings should have group code of WEAR, but are not in in a WEAR park, but they are in the ARCN boundary
--   Could expand WEAR and YUGA boundaries to include admin facilities


---------------------------
-- Data Improvement Queries
---------------------------

-- 1) missing FMSS Records
-- BLDGS, etc.  in FMSS, but not in current building center points
select * from dbo.FMSSExport as f left join gis.AKR_BLDG_CENTER_PT as p on f.Location = p.FACLOCID where p.FACLOCID is null order by status, convert(int, f.Location)
-- BLDGS, etc in FMSS, but not in historic building center points
select * from dbo.FMSSExport as f left join gis.AKR_BLDG_CENTER_PT_H as p on f.Location = p.FACLOCID where p.FACLOCID is null order by status, convert(int, f.Location)
-- Existing buildings in FMSS not in current building center points
select * from dbo.FMSSExport as f left join gis.AKR_BLDG_CENTER_PT as p on f.Location = p.FACLOCID where p.FACLOCID is null and status = 'Existing' and Asset_Code = 4100 order by park, convert(int, f.Location)
-- Existing buildings in FMSS not in historical building center points (some of the the FMSS 'Existing' buildings are gone)
select * from dbo.FMSSExport as f left join gis.AKR_BLDG_CENTER_PT_H as p on f.Location = p.FACLOCID where p.FACLOCID is null and status = 'Existing' and Asset_Code = 4100 order by park, convert(int, f.Location)

-- 2) Use of Unknown

-- 3) Missing data (where we should have something)
---- UNITNAME
select * from gis.AKR_BLDG_CENTER_PT where unitname is null
---- MAPLABEL
select * from gis.AKR_BLDG_CENTER_PT where MAPLABEL is null and PUBLICDISPLAY = 'Public Map Display' order by UNITCODE
