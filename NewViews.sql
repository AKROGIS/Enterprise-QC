USE [akr_facility2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[QC_ALL_FC_DOMAIN_VALUES] AS
-- Codes/Values specified in the ArcGIS domains
SELECT
  Name,
  codedValue.value('Code[1]', 'nvarchar(max)') AS "Code",
  codedValue.value('Name[1]', 'nvarchar(max)') AS "Value"
FROM
   sde.GDB_ITEMS
CROSS APPLY
   Definition.nodes('/GPCodedValueDomain2/CodedValues/CodedValue') AS CodedValues(codedValue)
WHERE
   type = '8C368B12-A12E-4C7E-9638-C9C64E69E98F'  -- Item Type Name = 'Coded Value Domain' from sde.GDB_ITEMTYPES
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ALL_QC_DOMAIN_VALUES] as SELECT * FROM (
-- Union the different QC domains into a table for comparison with ArcGIS Domains
select 'DOM_ATCHTYPE' as TableName, 'DOM_ATCHTYPE_NPS2017' as DomainName, Code, Code as Value from DOM_ATCHTYPE
union all
select 'DOM_BLDGCODETYPE' as TableName, 'DOM_BLDGCODE_NPS2017' as DomainName, Code, Code as Value from DOM_BLDGCODETYPE
union all
select 'DOM_BLDGCODETYPE' as TableName, 'DOM_BLDGTYPE_NPS2017' as DomainName, Type, Type as Value from DOM_BLDGCODETYPE
union all
select 'DOM_BLDGSTATUS' as TableName, 'DOM_BLDGSTATUS_NPS2017' as DomainName, Code, Code as Value from DOM_BLDGSTATUS
union all
select 'DOM_DATAACCESS' as TableName, 'DOM_DATAACCESS_NPS2016' as DomainName, Code, Code as Value from DOM_DATAACCESS
union all
select 'DOM_FACOCCUMAINT' as TableName, 'DOM_FACOCCUMAINT_NPS2017' as DomainName, Code, Code as Value from DOM_FACOCCUMAINT
union all
select 'DOM_FACOWNER' as TableName, 'DOM_FACOWNER_NPS2017' as DomainName, Code, Code as Value from DOM_FACOWNER
union all
select 'DOM_FACUSE' as TableName, 'DOM_FACUSE_NPS2017' as DomainName, Code, Code as Value from DOM_FACUSE
union all
select 'DOM_ISEXTANT' as TableName, 'DOM_ISEXTANT_NPS2016' as DomainName, Code, Code as Value from DOM_ISEXTANT
union all
select 'DOM_LINETYPE' as TableName, 'DOM_LINETYPE_NPS2016' as DomainName, Code, Code as Value from DOM_LINETYPE
union all
select 'DOM_LOTTYPE' as TableName, 'DOM_LOTTYPE_NPSAKR2016' as DomainName, Code, Code as Value from DOM_LOTTYPE
union all
select 'DOM_MAINTAINER' as TableName, 'DOM_MAINTAINER_NPS2016A' as DomainName, Code, Code as Value from DOM_MAINTAINER
union all
select 'DOM_MAPMETHOD' as TableName, 'DOM_MAPMETHOD_NPSAKR2016' as DomainName, Code, Code as Value from DOM_MAPMETHOD
union all
select 'DOM_POINTTYPE' as TableName, 'DOM_POINTTYPE_NPS2016' as DomainName, Code, Code as Value from DOM_POINTTYPE
union all
select 'DOM_POLYGONTYPE' as TableName, 'DOM_POLYGONTYPE_NPS2016' as DomainName, Code, Code as Value from DOM_POLYGONTYPE
union all
select 'DOM_PUBLICDISPLAY' as TableName, 'DOM_PUBLICDISPLAY_NPS2016' as DomainName, Code, Code as Value from DOM_PUBLICDISPLAY
union all
select 'DOM_UNITCODE' as TableName, 'DOM_UNITCODE_NPSAKR2016' as DomainName, Code, Code as Value from DOM_UNITCODE
union all
select 'DOM_XYACCURACY' as TableName, 'DOM_XYACCURACY_NPS2016' as DomainName, Code, Code as Value from DOM_XYACCURACY
union all
select 'DOM_YES_NO' as TableName, 'DOM_YES_NO_NPSAKR2016' as DomainName, Code, Code as Value from DOM_YES_NO
union all
select 'DOM_YES_NO_BOTH' as TableName, 'DOM_YES_NO_BOTH_NPSAKR2016' as DomainName, Code, Code as Value from DOM_YES_NO_BOTH
union all
select 'DOM_YES_NO_UNK' as TableName, 'DOM_YES_NO_UNK_NPS2016' as DomainName, Code, Code as Value from DOM_YES_NO_UNK
) as d
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_DOMAIN_VALUES_NOT_IN_FC] as
-- Values in the DOM_* tables but not in a feature class picklist
select qc.* from QC_ALL_QC_DOMAIN_VALUES as qc
left join QC_ALL_FC_DOMAIN_VALUES as d
on qc.DomainName = d.Name and qc.Code = d.Code
left join 
(
	select i2.Name as Domain, i1.Name as Feature from sde.GDB_ITEMRELATIONSHIPS r
	  join sde.GDB_ITEMS as i1 on r.OriginID = i1.UUID
	  join sde.GDB_ITEMS as i2 on r.DestID = i2.UUID
	WHERE r.type = '17E08ADB-2B31-4DCD-8FDD-DF529E88F843'  -- Relationship Type Name = 'DomainInDataset' from sde.GDB_ITEMRELATIONSHIPTYPES
)
as f on qc.DomainName = f.Domain
where d.Code is null or f.Domain is null
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_FEATURE_CLASS_DOMAIN_VALUES_NOT_IN_QC_DOM_TABLE] as
-- feature classes using domain values not in the QC tables
select f.Feature, d.* from
(
	select i2.Name as Domain, i1.Name as Feature from sde.GDB_ITEMRELATIONSHIPS r
	  join sde.GDB_ITEMS as i1 on r.OriginID = i1.UUID
	  join sde.GDB_ITEMS as i2 on r.DestID = i2.UUID
	WHERE r.type = '17E08ADB-2B31-4DCD-8FDD-DF529E88F843'  -- Relationship Type Name = 'DomainInDataset' from sde.GDB_ITEMRELATIONSHIPTYPES
)
as f
left join QC_ALL_FC_DOMAIN_VALUES as d
on f.Domain = d.Name
left join QC_ALL_QC_DOMAIN_VALUES as qc
on f.Domain = qc.DomainName and d.Code = qc.Code
where d.Name is null or qc.DomainName is null
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AKR_BLDG_PT] as
-- Center Points
SELECT [OBJECTID]
      ,[BLDGNAME]
      ,[BLDGALTNAME]
      ,[MAPLABEL]
      ,[BLDGSTATUS]
      ,[BLDGCODE]
      ,[BLDGTYPE]
      ,[FACOWNER]
      ,[FACOCCUPANT]
      ,[FACMAINTAIN]
      ,[FACUSE]
      ,[SEASONAL]
      ,[SEASDESC]
      ,[ISEXTANT]
      ,[POINTTYPE]
      ,[ISOUTPARK]
      ,[PUBLICDISPLAY]
      ,[DATAACCESS]
      ,[UNITCODE]
      ,[UNITNAME]
      ,[GROUPCODE]
      ,[GROUPNAME]
      ,[REGIONCODE]
      ,[CREATEDATE]
      ,[CREATEUSER]
      ,[EDITDATE]
      ,[EDITUSER]
      ,[MAPMETHOD]
      ,[MAPSOURCE]
      ,[SOURCEDATE]
      ,[XYACCURACY]
      ,[FACLOCID]
      ,[FACASSETID]
      ,[CRID]
      ,[ASMISID]
      ,[CLIID]
      ,[LCSID]
      ,[FIREBLDGID]
      ,[PARKBLDGID]
      ,[FEATUREID]
      ,[GEOMETRYID]
      ,[NOTES]
      ,[WEBEDITUSER]
      ,[WEBCOMMENT]
      ,[Shape]
  FROM [gis].[AKR_BLDG_CENTER_PT_evw]

  UNION ALL

  -- Other points (with common attributes from related center point)
  SELECT o.[OBJECTID] * -1 as [OBJECTID]
      ,[BLDGNAME]
      ,[BLDGALTNAME]
      ,[MAPLABEL]
      ,[BLDGSTATUS]
      ,[BLDGCODE]
      ,[BLDGTYPE]
      ,[FACOWNER]
      ,[FACOCCUPANT]
      ,[FACMAINTAIN]
      ,[FACUSE]
      ,[SEASONAL]
      ,[SEASDESC]
      ,[ISEXTANT]
      ,o.[POINTTYPE]
      ,[ISOUTPARK]
      ,[PUBLICDISPLAY]
      ,[DATAACCESS]
      ,[UNITCODE]
      ,[UNITNAME]
      ,[GROUPCODE]
      ,[GROUPNAME]
      ,[REGIONCODE]
      ,o.[CREATEDATE]
      ,o.[CREATEUSER]
      ,o.[EDITDATE]
      ,o.[EDITUSER]
      ,o.[MAPMETHOD]
      ,o.[MAPSOURCE]
      ,o.[SOURCEDATE]
      ,o.[XYACCURACY]
      ,[FACLOCID]
      ,[FACASSETID]
      ,[CRID]
      ,[ASMISID]
      ,[CLIID]
      ,[LCSID]
      ,[FIREBLDGID]
      ,[PARKBLDGID]
      ,o.[FEATUREID]
      ,o.[GEOMETRYID]
      ,o.[NOTES]
      ,o.[WEBEDITUSER]
      ,o.[WEBCOMMENT]
      ,o.[Shape]
  FROM [gis].[AKR_BLDG_OTHER_PT_evw] AS o join [gis].[AKR_BLDG_CENTER_PT_evw] AS c ON o.FEATUREID = c.FEATUREID
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AKR_BLDG_PY] as
  -- Footprint polygons (with common attributes from related center point)
SELECT f.[OBJECTID]
      ,[BLDGNAME]
      ,[BLDGALTNAME]
      ,[MAPLABEL]
      ,[BLDGSTATUS]
      ,[BLDGCODE]
      ,[BLDGTYPE]
      ,[FACOWNER]
      ,[FACOCCUPANT]
      ,[FACMAINTAIN]
      ,[FACUSE]
      ,[SEASONAL]
      ,[SEASDESC]
      ,[ISEXTANT]
      ,[POLYGONTYPE]
      ,[ISOUTPARK]
      ,[PUBLICDISPLAY]
      ,[DATAACCESS]
      ,[UNITCODE]
      ,[UNITNAME]
      ,[GROUPCODE]
      ,[GROUPNAME]
      ,[REGIONCODE]
      ,f.[CREATEDATE]
      ,f.[CREATEUSER]
      ,f.[EDITDATE]
      ,f.[EDITUSER]
      ,f.[MAPMETHOD]
      ,f.[MAPSOURCE]
      ,f.[SOURCEDATE]
      ,f.[XYACCURACY]
      ,[FACLOCID]
      ,[FACASSETID]
      ,[CRID]
      ,[ASMISID]
      ,[CLIID]
      ,[LCSID]
      ,[FIREBLDGID]
      ,[PARKBLDGID]
      ,f.[FEATUREID]
      ,f.[GEOMETRYID]
      ,f.[NOTES]
      ,f.[WEBEDITUSER]
      ,f.[WEBCOMMENT]
      ,f.[Shape]
  FROM [gis].[AKR_BLDG_FOOTPRINT_PY_evw] AS f join [gis].[AKR_BLDG_CENTER_PT_evw] AS c ON f.FEATUREID = c.FEATUREID

  UNION ALL

  -- Other polygons (with common attributes from related center point)
  SELECT o.[OBJECTID] * -1 as [OBJECTID]
      ,[BLDGNAME]
      ,[BLDGALTNAME]
      ,[MAPLABEL]
      ,[BLDGSTATUS]
      ,[BLDGCODE]
      ,[BLDGTYPE]
      ,[FACOWNER]
      ,[FACOCCUPANT]
      ,[FACMAINTAIN]
      ,[FACUSE]
      ,[SEASONAL]
      ,[SEASDESC]
      ,[ISEXTANT]
      ,o.[POLYGONTYPE]
      ,[ISOUTPARK]
      ,[PUBLICDISPLAY]
      ,[DATAACCESS]
      ,[UNITCODE]
      ,[UNITNAME]
      ,[GROUPCODE]
      ,[GROUPNAME]
      ,[REGIONCODE]
      ,o.[CREATEDATE]
      ,o.[CREATEUSER]
      ,o.[EDITDATE]
      ,o.[EDITUSER]
      ,o.[MAPMETHOD]
      ,o.[MAPSOURCE]
      ,o.[SOURCEDATE]
      ,o.[XYACCURACY]
      ,[FACLOCID]
      ,[FACASSETID]
      ,[CRID]
      ,[ASMISID]
      ,[CLIID]
      ,[LCSID]
      ,[FIREBLDGID]
      ,[PARKBLDGID]
      ,o.[FEATUREID]
      ,o.[GEOMETRYID]
      ,o.[NOTES]
      ,o.[WEBEDITUSER]
      ,o.[WEBCOMMENT]
      ,o.[Shape]
  FROM [gis].[AKR_BLDG_OTHER_PY_evw] AS o join [gis].[AKR_BLDG_CENTER_PT_evw] AS c ON o.FEATUREID = c.FEATUREID
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[QC_ISSUES_AKR_BLDG_CENTER_PT] AS select I.Issue, D.* from  gis.AKR_BLDG_CENTER_PT_evw AS D
join (

-------------------------
-- gis.AKR_BLDG_CENTER_PT
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be 'Center point' (if NULL assumed to be 'Center point' - no warning)
--    even if the "Center point" is actually arbitrary, or derived, there must be one and only one
--    identified as the 'Center point' as required by the building data standard
select OBJECTID, 'Error: POINTTYPE is not a Center point' as Issue from gis.AKR_BLDG_CENTER_PT_evw where POINTTYPE is not null and POINTTYPE <> '' and POINTTYPE <> 'Center point'
union all 
-- 2) GEOMETRYID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw where GEOMETRYID in
       (select GEOMETRYID from gis.AKR_BLDG_CENTER_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
	from gis.AKR_BLDG_CENTER_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: FEATUREID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw where FEATUREID in
       (select FEATUREID from gis.AKR_BLDG_CENTER_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.AKR_BLDG_CENTER_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.AKR_BLDG_CENTER_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.AKR_BLDG_CENTER_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) BLDGNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: BLDGNAME must use proper case' as Issue from gis.AKR_BLDG_CENTER_PT_evw where BLDGNAME = upper(BLDGNAME) Collate Latin1_General_CS_AI or BLDGNAME = lower(BLDGNAME) Collate Latin1_General_CS_AI
union all
-- 10) BLDGALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) BLDGSTATUS is required and must be in domain; default is a valid FMSS value or Existing;
--     Additional AKR Constraint: BLDGSTATUS must match valid value in FMSS Lookup.
--     TODO: discuss this additional AKR Constraint
select p.OBJECTID, 'Warning: BLDGSTATUS is not provided, default value of *Existing* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p
  left join (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from dbo.DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where (BLDGSTATUS is null or BLDGSTATUS = '') and f.Status is null
union all
select t1.OBJECTID, 'Error: BLDGSTATUS is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGSTATUS as t2 on t1.BLDGSTATUS = t2.Code where BLDGSTATUS is not null and BLDGSTATUS <> '' and t2.Code is null
union all
select p.OBJECTID, 'Error: BLDGSTATUS does not match FMSS.Status' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from dbo.DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where p.BLDGSTATUS <> f.Status and p.BLDGSTATUS <> ''
union all
-- 13) BLDGCODE is an optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: BLDGCODE is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGCODETYPE as t2 on t1.BLDGCODE = t2.Code where t1.BLDGCODE is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: BLDGCODE does not match FMSS.DOI_Code' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT DOI_Code, Location FROM dbo.FMSSExport where DOI_Code in (select Code from dbo.DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID where p.BLDGCODE <> f.DOI_Code
union all
-- 14) BLDGTYPE is an optional domain value
select t1.OBJECTID, 'Error: BLDGTYPE is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGCODETYPE as t2 on t1.BLDGTYPE = t2.Type where t1.BLDGTYPE is not null and t2.Type is null
union all
-- 13/14) BLDGCODE and BLDGTYPE are related; if one is null and not the other, null is populated with lookup
--     if BLDGCODE is null but gets set later by BLDGTYPE (not null and valid), then we should compare that value with FMSS
select t1.OBJECTID, 'Error: BLDGCODE does not match BLDGTYPE' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGCODETYPE as t2 on t1.BLDGCODE = t2.Code left join dbo.DOM_BLDGCODETYPE as t3 on t1.BLDGTYPE = t3.Type
	   where (t1.BLDGTYPE <> t2.Type and t3.Type is not null)
	      or (t1.BLDGCODE <> t3.Code and t2.Code is not null)
union all
select p.OBJECTID, 'Error: BLDGTYPE does not match type related to FMSS.DOI_Code' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT DOI_Code, Location FROM dbo.FMSSExport where DOI_Code in (select Code from dbo.DOM_BLDGCODETYPE)) as f on f.Location = p.FACLOCID 
  join dbo.DOM_BLDGCODETYPE as d on p.BLDGTYPE = d.Type where p.BLDGCODE is null and d.Code <> f.DOI_Code
union all
-- 15) FACOWNER is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACOWNER is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACOWNER as t2 on t1.FACOWNER = t2.Code where t1.FACOWNER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACOWNER does not match FMSS.Asset_Ownership' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Asset_Ownership, Location FROM dbo.FMSSExport where Asset_Ownership in (select Code from dbo.DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership
union all
-- 16) FACOCCUPANT is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACOCCUPANT is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACOCCUMAINT as t2 on t1.FACOCCUPANT = t2.Code where t1.FACOCCUPANT is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACOCCUPANT does not match FMSS.Occupant' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Occupant, Location FROM dbo.FMSSExport where Occupant in (select Code from dbo.DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant
union all
-- 17) FACMAINTAIN is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACMAINTAIN is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACOCCUMAINT as t2 on t1.FACMAINTAIN = t2.Code where t1.FACMAINTAIN is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACMAINTAIN does not match FMSS.FAMARESP' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP
union all
-- 18) FACUSE is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACUSE is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACUSE as t2 on t1.FACUSE = t2.Code where FACUSE is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACUSE does not match FMSS.PRIMUSE' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT PRIMUSE, Location FROM dbo.FMSSExport where PRIMUSE in (select Code from dbo.DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE
union all
-- 19) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS
union all
-- 20) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 21) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 12/21 ISEXTANT must align with BLDGSTATUS. Status: Existing requires Extant not False (other combinations are acceptable)
select t1.OBJECTID, 'Error: ISEXTANT does not match BLDGSTATUS' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from dbo.DOM_BLDGSTATUS)) as f
  on f.Location = t1.FACLOCID where t1.ISEXTANT = 'False' and (t1.BLDGSTATUS = 'Existing' or (t1.BLDGSTATUS is null and f.Status = 'Existing'))
union all
-- 22) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 23) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue from gis.AKR_BLDG_CENTER_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 22/23) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue from gis.AKR_BLDG_CENTER_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 24) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- TODO This query is very slow (~30-60sec) with versioning.  Figure it out, live with it, or run as separate check occasionally
select t1.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE <> t2.Unit_Code
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 25) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 26) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_BLDG_CENTER_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 27) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 28) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue from gis.AKR_BLDG_CENTER_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 29) FACLOCID is optional free text, but if provided it must be unique and match a Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FACLOCID from gis.AKR_BLDG_CENTER_PT_evw where FACLOCID is not null and FACLOCID <> '' group by FACLOCID having count(*) > 1) as t2 on t1.FACLOCID = t2.FACLOCID
union all
-- 30) FACASSETID is optional free text, but if provided it must be unique and match an ID in the FMSS Assets Export
--     TODO:  Get asset export from FMSS and compare
select t1.OBJECTID, 'Error: FACASSETID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FACASSETID from gis.AKR_BLDG_CENTER_PT_evw where FACASSETID is not null and FACASSETID <> '' group by FACASSETID having count(*) > 1) as t2 on t1.FACASSETID = t2.FACASSETID
union all
-- 31) CRID is optional free text, but if provided it must be unique and match an CR_ID in the Cultural Resource Database
--     TODO:  Get a link to the Cultural Resource Database and compare
select t1.OBJECTID, 'Error: CRID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select CRID from gis.AKR_BLDG_CENTER_PT_evw where CRID is not null and CRID <> '' group by CRID having count(*) > 1) as t2 on t1.CRID = t2.CRID
union all
-- 32) ASMISID is optional free text, but if provided it must be unique and match an ID in Archeological Sites Management Information System
--     TODO:  Get export from ASMIS and compare
select t1.OBJECTID, 'Error: ASMISID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select ASMISID from gis.AKR_BLDG_CENTER_PT_evw where ASMISID is not null and ASMISID <> '' group by ASMISID having count(*) > 1) as t2 on t1.ASMISID = t2.ASMISID
union all
-- 33) CLIID is optional free text, but if provided it must be unique and match an ID in the Cultural Landscape Inventory and a valid value in FMSS Lookup.
--     TODO:  Get export from CLI and compare
select t1.OBJECTID, 'Error: CLIID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select CLIID from gis.AKR_BLDG_CENTER_PT_evw where CLIID is not null and CLIID <> '' group by CLIID having count(*) > 1) as t2 on t1.CLIID = t2.CLIID
union all
select p.OBJECTID, 'Error: CLIID does not match FMSS.CLINO' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (select CLINO, Location FROM dbo.FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where p.CLIID <> f.CLINO
union all
-- 34) LCSID is optional free text, but if provided it must be unique and match an ID in the List of Classified Structures and a valid value in FMSS Lookup.
--     TODO:  Get export from LCS and compare
select t1.OBJECTID, 'Error: LCSID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select LCSID from gis.AKR_BLDG_CENTER_PT_evw where LCSID is not null and LCSID <> '' group by LCSID having count(*) > 1) as t2 on t1.LCSID = t2.LCSID
union all
select p.OBJECTID, 'Error: LCSID does not match FMSS.CLASSSTR' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (select CLASSSTR, Location FROM dbo.FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR
union all
-- 35) FIREBLDGID is optional free text, but if provided it must be unique and match an ID in the National Fire Database for Buildings
--     TODO:  Get export from FIREBLDG and compare
select t1.OBJECTID, 'Error: FIREBLDGID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FIREBLDGID from gis.AKR_BLDG_CENTER_PT_evw where FIREBLDGID is not null and FIREBLDGID <> '' group by FIREBLDGID having count(*) > 1) as t2 on t1.FIREBLDGID = t2.FIREBLDGID
union all
-- 36) PARKBLDGID is optional free text, but if provided it should be unique in a unit and match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: PARKBLDGID is not unique in the unit' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select PARKBLDGID, UNITCODE from gis.AKR_BLDG_CENTER_PT_evw where PARKBLDGID is not null and PARKBLDGID <> '' group by PARKBLDGID, UNITCODE having count(*) > 1) as t2
	    on t1.PARKBLDGID = t2.PARKBLDGID and t1.UNITCODE = t2.UNITCODE
union all
select p.OBJECTID, 'Error: PARKBLDGID does not match FMSS.PARKNUMB' as Issue from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT PARKNUMB, Location FROM dbo.FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB
-- 37) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_CENTER_PT'
WHERE E.feature_oid IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_BLDG_FOOTPRINT_PY] AS select I.Issue, D.* from  gis.AKR_BLDG_FOOTPRINT_PY_evw AS D
join (

----------------------------
-- gis.AKR_BLDG_FOOTPRINT_PY
----------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POLYGONTYPE must be 'Perimeter polygon' (if NULL assumed to be 'Perimeter polygon')
--    For AKR, 'Perimeter polygon' means the best available projection of the roof edge on the ground.  It is not the
--    foundation of the building.  It may be derived or estimated.  A building can have only one footprint, which will be
--    used for general mapping purposes.  Other polygon representations of the building for detailed mapping or analysis
--    need to be stored in gis.AKR_BLDG_OTHER_PY_evw with a POLYGONTYPE not equal to 'Perimeter polygon'
select OBJECTID, 'Error: POLYGONTYPE is not Perimeter polygon' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where POLYGONTYPE is not null and POLYGONTYPE <> '' and POLYGONTYPE <> 'Perimeter polygon'
union all
-- 2) GEOMETRYID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.AKR_BLDG_FOOTPRINT_PY_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
from gis.AKR_BLDG_FOOTPRINT_PY_evw where
  -- Will ignore GEOMETRYID = NULL 
  len(GEOMETRYID) <> 38 
  OR left(GEOMETRYID,1) <> '{'
  OR right(GEOMETRYID,1) <> '}'
  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must non-null, and must match one and only one record in gis.AKR_BLDG_CENTER_PT
--    Since FEATUREID must be unique in gis.AKR_BLDG_CENTER_PT, multiple matches will be caught checking gis.AKR_BLDG_CENTER_PT.
--    For footprints, we also add an additional contraint that they are unique (only on footprint per building)
--        the history (other versions) of a footprint will be available in the archive tracking feature of ArcGIS.
select OBJECTID, 'Error: FEATUREID is not provided' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where FEATUREID is null
union all
select t1.OBJECTID, 'Error: FEATUREID not found in AKR_BLDG_CENTER_PT' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw as t1
  left join gis.AKR_BLDG_CENTER_PT_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
union all
select OBJECTID, 'Error: FEATUREID not unique' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw
  where FEATUREID in (select FEATUREID from gis.AKR_BLDG_FOOTPRINT_PY_evw group by FEATUREID having count(*) > 1)
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_FOOTPRINT_PY'
WHERE E.feature_oid IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_BLDG_OTHER_PT] AS select I.Issue, D.* from  gis.AKR_BLDG_OTHER_PT_EVW AS D
join (
--------------------
-- gis.AKR_BLDG_OTHER_PT
--------------------

-- 1) POINTYPE must be an acceptable value; see discussion for gis.AKR_BLDG_CENTER_PT
select OBJECTID, 'Error: POINTTYPE must not be null' as Issue from gis.AKR_BLDG_OTHER_PT_evw where POINTTYPE is null
union all
select OBJECTID, 'Error: POINTTYPE must not be Center point' as Issue from gis.AKR_BLDG_OTHER_PT_evw where POINTTYPE = 'Center point'
union all
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> 'Center point' and t2.Code is null
union all
-- 2-8) Are equivalent to those for gis.AKR_BLDG_FOOTPRINT_PY; see discussion for gis.AKR_BLDG_FOOTPRINT_PY_evw for details
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.AKR_BLDG_OTHER_PT_evw where GEOMETRYID in
       (select GEOMETRYID from gis.AKR_BLDG_OTHER_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
from gis.AKR_BLDG_OTHER_PT_evw where
  -- Will ignore GEOMETRYID = NULL 
  len(GEOMETRYID) <> 38 
  OR left(GEOMETRYID,1) <> '{'
  OR right(GEOMETRYID,1) <> '}'
  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
select OBJECTID, 'Error: FEATUREID is not provided' as Issue from gis.AKR_BLDG_OTHER_PT_evw where FEATUREID is null
union all
select t1.OBJECTID, 'Error: FEATUREID not found in AKR_BLDG_CENTER_PT' as Issue from gis.AKR_BLDG_OTHER_PT_evw as t1
  left join gis.AKR_BLDG_CENTER_PT_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
union all
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_OTHER_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_OTHER_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.AKR_BLDG_OTHER_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.AKR_BLDG_OTHER_PT_evw where SOURCEDATE > GETDATE()
union all
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_OTHER_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_OTHER_PT'
WHERE E.feature_oid IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_BLDG_OTHER_PY] AS select I.Issue, D.* from  gis.AKR_BLDG_OTHER_PY_EVW AS D
join (
--------------------
-- gis.AKR_BLDG_OTHER_PY
--------------------
-- 1) POLYGONTYPE must be an acceptable value; see discussion for gis.AKR_BLDG_FOOTPRINT_PY
select OBJECTID, 'Error: POLYGONTYPE must not be null' as Issue from gis.AKR_BLDG_OTHER_PY_evw where POLYGONTYPE is null
union all
select OBJECTID, 'Error: POLYGONTYPE must not be Perimeter polygon' as Issue from gis.AKR_BLDG_OTHER_PY_evw where POLYGONTYPE = 'Perimeter polygon'
union all
select t1.OBJECTID, 'Error: POLYGONTYPE is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PY_evw as t1
  left join dbo.DOM_POLYGONTYPE as t2 on t1.POLYGONTYPE = t2.Code where t1.POLYGONTYPE is not null and t1.POLYGONTYPE <> 'Perimeter polygon' and t2.Code is null
union all
-- 2-8) Are equivalent to those for gis.AKR_BLDG_FOOTPRINT_PY; see discussion for gis.AKR_BLDG_FOOTPRINT_PY_evw for details
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.AKR_BLDG_OTHER_PY_evw where GEOMETRYID in (select GEOMETRYID from gis.AKR_BLDG_OTHER_PY_evw group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
from gis.AKR_BLDG_OTHER_PY_evw where
  -- Will ignore GEOMETRYID = NULL 
  len(GEOMETRYID) <> 38 
  OR left(GEOMETRYID,1) <> '{'
  OR right(GEOMETRYID,1) <> '}'
  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
select OBJECTID, 'Error: FEATUREID is not provided' as Issue from gis.AKR_BLDG_OTHER_PY_evw where FEATUREID is null
union all
select t1.OBJECTID, 'Error: FEATUREID not found in AKR_BLDG_CENTER_PT' as Issue from gis.AKR_BLDG_OTHER_PY_evw as t1
  left join gis.AKR_BLDG_CENTER_PT_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
union all
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_OTHER_PY_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PY_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_OTHER_PY_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.AKR_BLDG_OTHER_PY_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.AKR_BLDG_OTHER_PY_evw where SOURCEDATE > GETDATE()
union all
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.AKR_BLDG_OTHER_PY_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PY_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_OTHER_PY'
WHERE E.feature_oid IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_PARKLOTS_PY] AS select I.Issue, D.* from  gis.PARKLOTS_PY_evw AS D
join (

-------------------------
-- gis.PARKLOTS_PY
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POLYGONTYPE must be an recognized value; if it is null/empty, then it will default to 'Circumscribed polygon' without a warning
select t1.OBJECTID, 'Error: POLYGONTYPE is not a recognized value' as Issue from gis.AKR_BLDG_OTHER_PY_evw as t1
  left join dbo.DOM_POLYGONTYPE as t2 on t1.POLYGONTYPE = t2.Code where t1.POLYGONTYPE is not null and t1.POLYGONTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.PARKLOTS_PY_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.PARKLOTS_PY_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
	from gis.PARKLOTS_PY_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
--    If a single parking lot has multiple polygons, then use a multipolygon (merge in ArcMap), or create an exception.
select OBJECTID, 'Error: FEATUREID is not unique' as Issue from gis.PARKLOTS_PY_evw where FEATUREID in 
       (select FEATUREID from gis.PARKLOTS_PY_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.PARKLOTS_PY_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.PARKLOTS_PY_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.PARKLOTS_PY_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.PARKLOTS_PY_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.PARKLOTS_PY_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.PARKLOTS_PY_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) LOTNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: LOTNAME must use proper case' as Issue from gis.PARKLOTS_PY_evw where LOTNAME = upper(LOTNAME) Collate Latin1_General_CS_AI or LOTNAME = lower(LOTNAME) Collate Latin1_General_CS_AI
union all
-- 10) LOTALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) LOTTYPE must be in DOM_LOTTYPE. If NULL (or empty string) it is assumed to be 'Parking Lot' - with no warning
select t1.OBJECTID, 'Error: LOTTYPE is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_LOTTYPE as t2 on t1.LOTTYPE = t2.Code where t1.LOTTYPE is not null and t1.LOTTYPE <> '' and t2.Code is null
union all 
-- 13) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue from gis.PARKLOTS_PY_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS
union all
-- 14) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue from gis.PARKLOTS_PY_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 15) MAINTAINER is a optional domain value; TODO: if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.PARKLOTS_PY_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue from gis.PARKLOTS_PY_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 19) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue from gis.PARKLOTS_PY_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 18/19) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue from gis.PARKLOTS_PY_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 20) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue from gis.PARKLOTS_PY_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- TODO This query is very slow (~30-60sec) with versioning.  Figure it out, live with it, or run as separate check occasionally
select t1.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue from gis.PARKLOTS_PY_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE <> t2.Unit_Code
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.PARKLOTS_PY_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 21) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.PARKLOTS_PY_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.PARKLOTS_PY_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 22) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue from gis.PARKLOTS_PY_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue from gis.PARKLOTS_PY_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.PARKLOTS_PY_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 23) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue from gis.PARKLOTS_PY_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 24) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue from gis.PARKLOTS_PY_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 25) FACLOCID is optional free text, but if provided it must be unique and match a Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.PARKLOTS_PY_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Parking Area in FMSS' as Issue from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Asset_Code <> '1300'
union all
select t1.OBJECTID, 'Error: FACLOCID is not unique' as Issue from gis.PARKLOTS_PY_evw as t1 join
       (select FACLOCID from gis.PARKLOTS_PY_evw where FACLOCID is not null and FACLOCID <> '' group by FACLOCID having count(*) > 1) as t2 on t1.FACLOCID = t2.FACLOCID
union all
-- 26) FACASSETID is optional free text, but if provided it must be unique and match an ID in the FMSS Assets Export
--     TODO:  Get asset export from FMSS and compare
select t1.OBJECTID, 'Error: FACASSETID is not unique' as Issue from gis.PARKLOTS_PY_evw as t1 join
       (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FACASSETID <> '' group by FACASSETID having count(*) > 1) as t2 on t1.FACASSETID = t2.FACASSETID

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'PARKLOTS_PY'
WHERE E.feature_oid IS NULL
GO
