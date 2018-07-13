USE [akr_facility2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ToProperCase](@string VARCHAR(255)) RETURNS VARCHAR(255)
AS
BEGIN
  DECLARE @i INT           -- index
  DECLARE @l INT           -- input length
  DECLARE @c NCHAR(1)      -- current char
  DECLARE @f INT           -- first letter flag (1/0)
  DECLARE @o VARCHAR(255)  -- output string
  DECLARE @w VARCHAR(10)   -- characters considered as white space

  SET @w = '[' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(160) + ' ' + ']'
  SET @i = 1
  SET @l = LEN(@string)
  SET @f = 1
  SET @o = ''

  WHILE @i <= @l
  BEGIN
    SET @c = SUBSTRING(@string, @i, 1)
    IF @f = 1 
    BEGIN
     SET @o = @o + @c
     SET @f = 0
    END
    ELSE
    BEGIN
     SET @o = @o + LOWER(@c)
    END

    IF @c LIKE @w SET @f = 1

    SET @i = @i + 1
  END

  RETURN @o
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TrailUse](
     @a nvarchar(10), -- Foot
     @b nvarchar(10), -- Bike
     @c nvarchar(10), -- Horse
     @d nvarchar(10), -- ATV
     @e nvarchar(10), -- 4WD
     @f nvarchar(10), -- Motorbike
     @g nvarchar(10), -- snowmachine
     @h nvarchar(10), -- snowshoe
     @i nvarchar(10), -- ski (back country ski tour)
     @j nvarchar(10), -- Dogsled
     @k nvarchar(10), -- boat
     @l nvarchar(10), -- canoe
	 	 -- AKR Additions (listed as Other)
     @m nvarchar(10) = NULL, -- OHVSUB
     @n nvarchar(10) = NULL, -- nordic (groomed nordic ski trails)
     @o nvarchar(10) = NULL, -- downhill (groomed alpine skiing)
     @p nvarchar(10) = NULL, -- canyoneer
     @q nvarchar(10) = NULL, -- climb	 
     @r nvarchar(10) = NULL, -- other1	 
     @s nvarchar(10) = NULL, -- other2 
     @t nvarchar(10) = NULL  -- other3	 
) RETURNS VARCHAR(255)
AS
BEGIN
  DECLARE @result varchar(255)
  DECLARE @other varchar(255)
  if @m = 'Yes' or @n = 'Yes' or @o = 'Yes' or @p = 'Yes' or @q = 'Yes' or @r = 'Yes' or @s = 'Yes' or @t = 'Yes'
  BEGIN
	SET @other = '|Other'
  END
  SET @result = SUBSTRING(CONCAT(
    CASE @a WHEN 'Yes' THEN '|Hiker/Pedestrian' ELSE NULL END,
    CASE @b WHEN 'Yes' THEN '|Bicycle' ELSE NULL END,
    CASE @c WHEN 'Yes' THEN '|Pack and Saddle' ELSE NULL END,
    CASE @d WHEN 'Yes' THEN '|All-Terrain Vehicle' ELSE NULL END,
    CASE @e WHEN 'Yes' THEN '|Four-Wheel Drive Vehicle > 50” in Tread Width' ELSE NULL END,
    CASE @f WHEN 'Yes' THEN '|Motorcycle' ELSE NULL END,
    CASE @g WHEN 'Yes' THEN '|Snowmobile' ELSE NULL END,
    CASE @h WHEN 'Yes' THEN '|Snowshoe' ELSE NULL END,
    CASE @i WHEN 'Yes' THEN '|Cross-Country Ski' ELSE NULL END,
    CASE @j WHEN 'Yes' THEN '|Dog Sled' ELSE NULL END,
    CASE @k WHEN 'Yes' THEN '|Motorized Watercraft' ELSE NULL END,
    CASE @l WHEN 'Yes' THEN '|Non-Motorized Watercraft' ELSE NULL END,
	@other
  ), 2, 254)
  IF @result = ''
  BEGIN
    SET @result = 'Unknown'
  END
  RETURN @result
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TrailUseAKR](
     @a nvarchar(10), -- Foot
     @b nvarchar(10), -- Bike
     @c nvarchar(10), -- Horse
     @d nvarchar(10), -- ATV
     @e nvarchar(10), -- 4WD
     @f nvarchar(10), -- Motorbike
     @g nvarchar(10), -- snowmachine
     @h nvarchar(10), -- snowshoe
     @i nvarchar(10), -- nordic (groomed nordic ski trails)
     @j nvarchar(10), -- Dogsled
     @k nvarchar(10), -- boat
     @l nvarchar(10), -- canoe
	 -- AKR Additions
     @m nvarchar(10), -- OHVSUB (other)
     @n nvarchar(10), -- ski (back country ski tour)
     @o nvarchar(10), -- downhill (groomed alpine skiing)
     @p nvarchar(10), -- canyoneer
     @q nvarchar(10), -- climb	 
     @r nvarchar(10) = NULL, -- other1	 
     @s nvarchar(10) = NULL, -- other2 
     @t nvarchar(10) = NULL  -- other3	 
) RETURNS VARCHAR(255)
AS
BEGIN
  DECLARE @result varchar(255)
  DECLARE @other varchar(255)
  if @r = 'Yes' or @s = 'Yes' or @t = 'Yes'
  BEGIN
	SET @other = '|Other'
  END
  SET @result = SUBSTRING(CONCAT(
    CASE @a WHEN 'Yes' THEN '|Hiker/Pedestrian' WHEN 'No' THEN '|No Hiker/Pedestrian' ELSE NULL END,
    CASE @b WHEN 'Yes' THEN '|Bicycle' WHEN 'No' THEN '|No Bicycle' ELSE NULL END,
    CASE @c WHEN 'Yes' THEN '|Pack and Saddle' WHEN 'No' THEN '|No Pack and Saddle' ELSE NULL END,
    CASE @d WHEN 'Yes' THEN '|All-Terrain Vehicle' WHEN 'No' THEN '|No All-Terrain Vehicle' ELSE NULL END,
    CASE @e WHEN 'Yes' THEN '|Four-Wheel Drive Vehicle > 50” in Tread Width' WHEN 'No' THEN '|No Four-Wheel Drive Vehicle > 50” in Tread Width' ELSE NULL END,
    CASE @f WHEN 'Yes' THEN '|Motorcycle' WHEN 'No' THEN '|No Motorcycle' ELSE NULL END,
    CASE @g WHEN 'Yes' THEN '|Snowmobile' WHEN 'No' THEN '|No Snowmobile' ELSE NULL END,
    CASE @h WHEN 'Yes' THEN '|Snowshoe' WHEN 'No' THEN '|No Snowshoe' ELSE NULL END,
    CASE @i WHEN 'Yes' THEN '|Cross-Country Ski' WHEN 'No' THEN '|No Cross-Country Ski' ELSE NULL END,
    CASE @j WHEN 'Yes' THEN '|Dog Sled' WHEN 'No' THEN '|No Dog Sled' ELSE NULL END,
    CASE @k WHEN 'Yes' THEN '|Motorized Watercraft' WHEN 'No' THEN '|No Motorized Watercraft' ELSE NULL END,
    CASE @l WHEN 'Yes' THEN '|Non-Motorized Watercraft' WHEN 'No' THEN '|No Non-Motorized Watercraft' ELSE NULL END,
    CASE @m WHEN 'Yes' THEN '|OHV for Subsistence Use Only' WHEN 'No' THEN '|No OHV for Subsistence Use' ELSE NULL END,
    CASE @n WHEN 'Yes' THEN '|Backcountry Ski' WHEN 'No' THEN '|No Backcountry Ski' ELSE NULL END,
    CASE @o WHEN 'Yes' THEN '|Downhill Ski' WHEN 'No' THEN '|No Downhill Ski' ELSE NULL END,
    CASE @p WHEN 'Yes' THEN '|Canyoneering' WHEN 'No' THEN '|No Canyoneering' ELSE NULL END,
    CASE @q WHEN 'Yes' THEN '|Climbing' WHEN 'No' THEN '|No Climbing' ELSE NULL END
  ), 2, 254)
  IF @result = ''
  BEGIN
    SET @result = 'Unknown'
  END
  RETURN @result
END
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
select 'DOM_RDCLASS' as TableName, 'DOM_RDCLASS_NPS2016' as DomainName, Code, Code as Value from DOM_RDCLASS
union all
select 'DOM_RDMAINTAINER' as TableName, 'DOM_RDMAINTAINER_NPS2016' as DomainName, Code, Code as Value from DOM_RDMAINTAINER
union all
select 'DOM_RDONEWAY' as TableName, 'DOM_RDONEWAY_NPS2016' as DomainName, Code, Code as Value from DOM_RDONEWAY
union all
select 'DOM_RDSTATUS' as TableName, 'DOM_RDSTATUS_NPS2016' as DomainName, Code, Code as Value from DOM_RDSTATUS
union all
select 'DOM_RDSURFACE' as TableName, 'DOM_RDSURFACE_NPS2016' as DomainName, Code, Code as Value from DOM_RDSURFACE
union all
select 'DOM_TRLCLASS' as TableName, 'DOM_TRLCLASS_NPS2016' as DomainName, Code, Code as Value from DOM_TRLCLASS
union all
select 'DOM_TRLFEATTYPE' as TableName, 'DOM_TRLFEATTYPE_NPSAKR2016' as DomainName, Code, Code as Value from DOM_TRLFEATTYPE
union all
select 'DOM_TRLSTATUS' as TableName, 'DOM_TRLSTATUS_NPSAKR2016' as DomainName, Code, Code as Value from DOM_TRLSTATUS
union all
select 'DOM_TRLSURFACE' as TableName, 'DOM_TRLSURFACE_NPS2016' as DomainName, Code, Code as Value from DOM_TRLSURFACE
union all
select 'DOM_TRLTRACK' as TableName, 'DOM_TRLTRACK_NPSAKR2016' as DomainName, Code, Code as Value from DOM_TRLTRACK
union all
select 'DOM_TRLTYPE' as TableName, 'DOM_TRLTYPE_NPS2016' as DomainName, Code, Code as Value from DOM_TRLTYPE
union all
select 'DOM_UNITCODE' as TableName, 'DOM_UNITCODE_NPSAKR2016' as DomainName, Code, Code as Value from DOM_UNITCODE
union all
select 'DOM_UOM' as TableName, 'DOM_UOM_NPSAKR2015' as DomainName, Code, Code as Value from DOM_UOM
union all
select 'DOM_WAYSIDE_FEAT' as TableName, 'DOM_WAYSIDE_FEAT_NPSAKR2015' as DomainName, Code, Code as Value from DOM_WAYSIDE_FEAT
union all
select 'DOM_XYACCURACY' as TableName, 'DOM_XYACCURACY_NPS2016' as DomainName, Code, Code as Value from DOM_XYACCURACY
union all
select 'DOM_YES_NO' as TableName, 'DOM_YES_NO_NPSAKR2016' as DomainName, Code, Code as Value from DOM_YES_NO
union all
select 'DOM_YES_NO_BOTH' as TableName, 'DOM_YES_NO_BOTH_NPSAKR2016' as DomainName, Code, Code as Value from DOM_YES_NO_BOTH
union all
select 'DOM_YES_NO_UNK' as TableName, 'DOM_YES_NO_UNK_NPS2016' as DomainName, Code, Code as Value from DOM_YES_NO_UNK
union all
select 'DOM_YES_NO_UNK_NA' as TableName, 'DOM_YES_NO_UNK_NA_NPSAKR2016' as DomainName, Code, Code as Value from DOM_YES_NO_UNK_NA
union all
select 'DOM_YES_NO_UNK_OTH' as TableName, 'DOM_YES_NO_UNK_OTH_NPS2016' as DomainName, Code, Code as Value from DOM_YES_NO_UNK_OTH
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
-- 29) FACLOCID is optional free text, but if provided it must be unique and match a *Building* Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID is not a Building (4100) asset' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t2.Asset_Code <> '4100'
union all
select t1.OBJECTID, 'Error: FACLOCID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FACLOCID from gis.AKR_BLDG_CENTER_PT_evw where FACLOCID is not null and FACLOCID <> '' group by FACLOCID having count(*) > 1) as t2 on t1.FACLOCID = t2.FACLOCID
union all
-- 30) FACASSETID is optional free text, but if provided it must be unique and match an ID in the FMSS Assets Export
select t1.OBJECTID, 'Error: FACASSETID is not unique' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FACASSETID from gis.AKR_BLDG_CENTER_PT_evw where FACASSETID is not null and FACASSETID <> '' group by FACASSETID having count(*) > 1) as t2 on t1.FACASSETID = t2.FACASSETID
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a Building (4100) asset in FMSS' as Issue from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where (t1.FACLOCID is null or t1.FACLOCID = t3.Location) and t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code <> '4100'
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
WHERE E.Explanation IS NULL
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
WHERE E.Explanation IS NULL
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
WHERE E.Explanation IS NULL
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
WHERE E.Explanation IS NULL
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
select t1.OBJECTID, 'Error: POLYGONTYPE is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
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
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.PARKLOTS_PY_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
--    TODO: Query for records with a FEATUREID far away from the average for all features with the FEATUREID
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
-- 15) MAINTAINER is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue from gis.PARKLOTS_PY_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID join dbo.DOM_MAINTAINER as d on f.FAMARESP = d.FMSS where p.MAINTAINER <> d.Code
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.PARKLOTS_PY_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
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
-- TODO This query is very slow with versioning when the dataset gets larger.  Figure it out, live with it, or run as separate check occasionally
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
-- 25) FACLOCID is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.PARKLOTS_PY_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Parking Area in FMSS' as Issue from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Asset_Code <> '1300'
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue from gis.PARKLOTS_PY_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.PARKLOTS_PY_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 26) FACASSETID is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue from gis.PARKLOTS_PY_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a Parking Area in FMSS' as Issue from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location  where (t1.FACLOCID is null or t1.FACLOCID = t3.Location) and t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code <> '1300'
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue from gis.PARKLOTS_PY_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)


-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'PARKLOTS_PY'
WHERE E.Explanation IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_ROADS_LN] AS select I.Issue, D.* from  gis.ROADS_LN_evw AS D
join (

-------------------------
-- gis.ROADS_LN
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) LINETYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary line' without a warning
--    TODO this is not part of the standard (maybe core after the fact), most is centerline
--    should we do something like bldgs with center being required, and edge or other being optional and linked
--    maybe require that this is a centerline feature class.
select t1.OBJECTID, 'Error: LINETYPE is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
  left join dbo.DOM_LINETYPE as t2 on t1.LINETYPE = t2.Code where t1.LINETYPE is not null and t1.LINETYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.ROADS_LN_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.ROADS_LN_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
	from gis.ROADS_LN_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    We haven't yet defined what it means, exactly, to be a road feature (i.e. what segments should share a FEATUREID), but we know that FEATUREID will not be unique.
--       This allows a long road to be broken into multiple smaller segments, and allows different segments with different attributes to be part of the same road.
--       however, it also allows errors like two different (by geography or attributes) trails having the same featureid (common copy/paste error)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
--    TODO: consider what attributes, in addition to FMSS attributes, should be the same when FEATUREID is the same
--    TODO: Query for records with a FEATUREID far away from the average for all features with the FEATUREID
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.ROADS_LN_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.ROADS_LN_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.ROADS_LN_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.ROADS_LN_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.ROADS_LN_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.ROADS_LN_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) RDNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: RDNAME must use proper case' as Issue from gis.ROADS_LN_evw where RDNAME = upper(RDNAME) Collate Latin1_General_CS_AI or RDNAME = lower(RDNAME) Collate Latin1_General_CS_AI
union all
-- 10) RDALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) RDSTATUS is a required domain value; default is 'Existing'
--     TODO: Compare with FMSS
select OBJECTID, 'Warning: RDSTATUS is not provided, default value of *Existing* will be used' as Issue from gis.ROADS_LN_evw where RDSTATUS is null or RDSTATUS = ''
union all
select t1.OBJECTID, 'Error: RDSTATUS is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDSTATUS as t2 on t1.RDSTATUS = t2.Code where t1.RDSTATUS is not null and t1.RDSTATUS <> '' and t2.Code is null
union all 
-- 13) RDCLASS is a required domain value; default is 'Unknown'
--     if a feature has a FACLOCID then RDCLASS = 'Parking Lot Road' implies FMSS.asset_code = '1300' and visa-versa
--     TODO: if a feature has a FACLOCID then the FMSS Funtional Class implies a RDCLASS.  See section 4.3 of the standard
select OBJECTID, 'Warning: RDCLASS is not provided, default value of *Unknown* will be used' as Issue from gis.ROADS_LN_evw where RDCLASS is null or RDCLASS = ''
union all
select t1.OBJECTID, 'Error: RDCLASS is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDCLASS as t2 on t1.RDCLASS = t2.Code where t1.RDCLASS is not null and t1.RDCLASS <> '' and t2.Code is null
union all 
select t1.OBJECTID, 'Error: RDCLASS does not match the FMSS.Asset_Code' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and ((t1.RDCLASS = 'Parking Lot Road' and t2.Asset_Code <> '1300') or (t1.RDCLASS <> 'Parking Lot Road' and t2.Asset_Code = '1300'))
union all
-- 14) RDSURFACE is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: RDSURFACE is not provided, default value of *Unknown* will be used' as Issue from gis.ROADS_LN_evw where RDSURFACE is null or RDSURFACE = ''
union all
select t1.OBJECTID, 'Error: RDSURFACE is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDSURFACE as t2 on t1.RDSURFACE = t2.Code where t1.RDSURFACE is not null and t1.RDSURFACE <> '' and t2.Code is null
union all 
-- 15) RDONEWAY is an optional domain value; default is Null
select t1.OBJECTID, 'Error: RDONEWAY is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDONEWAY as t2 on t1.RDONEWAY = t2.Code where t1.RDONEWAY is not null and t1.RDONEWAY <> '' and t2.Code is null
union all 
-- 16) RDLANES is an optional range value 1-8; default is Null
select OBJECTID, 'Error: RDLANES is not a recognized value' as Issue from gis.ROADS_LN_evw where RDLANES < 1 or RDLANES > 8
union all 
-- 17) RDHICLEAR is an optional domain value; default is Null
select t1.OBJECTID, 'Error: RDHICLEAR is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK_OTH as t2 on t1.RDHICLEAR = t2.Code where t1.RDHICLEAR is not null and t1.RDHICLEAR <> '' and t2.Code is null
union all 
-- 18) RTENUMBER is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 19) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue from gis.ROADS_LN_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS
union all
-- 20) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue from gis.ROADS_LN_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 21) RDMAINTAINER is a optional domain value;
--     TODO: if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDMAINTAINER as t2 on t1.RDMAINTAINER = t2.Code where t1.RDMAINTAINER is not null and t2.Code is null
union all
-- 22) ISEXTANT is a required domain value; Default to 'True' with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.ROADS_LN_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 23) PUBLICDISPLAY is a required Domain Value; Default to 'No Public Map Display' with Warning
--     TODO: are there requirements of other fields (i.e. RDSTATUS, ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue from gis.ROADS_LN_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 24) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue from gis.ROADS_LN_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 23/24) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue from gis.ROADS_LN_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 25) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the road is not within a unit boundary' as Issue from gis.ROADS_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.ROADS_LN_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.ROADS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- TODO This query is very slow (~30-60sec) with versioning.  Figure it out, live with it, or run as separate check occasionally
select t1.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue from gis.ROADS_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE <> t2.Unit_Code
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.ROADS_LN_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 26) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.ROADS_LN_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 27) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue from gis.ROADS_LN_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue from gis.ROADS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue from gis.ROADS_LN_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.ROADS_LN_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 28) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue from gis.ROADS_LN_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 29) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue from gis.ROADS_LN_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 30) ROUTEID is optional free text, but if provided it must be unique and match a records in the RIP
--     TODO: Get export of RIP, and ensure value is valid.
--     TODO: Verify format is NPS-UNITCODE-ROUTENUMBER (may be implicit in the RIP foreign key validation)
--     TODO: ROUTEID should be duplicate if featureid is duplicate, i.e. all line segments with the same ROUTEID must have the same featureid and all segements with the same featureid must have the same ROUTEID 
--     TODO: The ROUTEID is also related to a FMSS Functional Class. i.e. FMSS Functional Class I => Route numbers 1..99, II => 100..199, ...
select t1.OBJECTID, 'Error: ROUTEID is not unique' as Issue from gis.ROADS_LN_evw as t1 join
       (select ROUTEID from gis.ROADS_LN_evw where ROUTEID is not null and ROUTEID <> '' group by ROUTEID having count(*) > 1) as t2 on t1.ROUTEID = t2.ROUTEID
union all
-- 31) FACLOCID is optional free text, but if provided it must match a Location in the FMSS Export
--     FACLOCID should be duplicate if featureid is duplicate, i.e. all line segments with the same FACLOCID must have the same featureid and all segements with the same featureid must have the same FACLOCID 
--     TODO: A bridge/tunnel in a road will have the feature id, however the FACLOCID (and asset type) for the bridge/tunnel is different from the road on/in the bridge/tunnel
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.ROADS_LN_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Road in FMSS' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Asset_Code not in ('1100', '1300', '1700', '1800')
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue from gis.ROADS_LN_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.ROADS_LN_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 32) FACASSETID is optional free text, provided it must match a Road Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue from gis.ROADS_LN_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a road asset in FMSS' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('1100', '1700', '1800')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue from gis.ROADS_LN_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- 33) ISOUTPARK: This is an AKR extension, it is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 34) ISBRIDGE: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISBRIDGE is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISBRIDGE = t2.Code where t1.ISBRIDGE is not null and t1.ISBRIDGE <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISBRIDGE does not match the FMSS.Asset_Code' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and ((t1.ISBRIDGE = 'Yes' and t2.Asset_Code <> '1700') or (t1.ISBRIDGE <> 'Yes' and t2.Asset_Code = '1700'))
union all
-- 35) ISTUNNEL: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISTUNNEL is not a recognized value' as Issue from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISTUNNEL = t2.Code where t1.ISTUNNEL is not null and t1.ISTUNNEL <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISTUNNEL does not match the FMSS.Asset_Code' as Issue from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and ((t1.ISTUNNEL = 'Yes' and t2.Asset_Code <> '1800') or (t1.ISTUNNEL <> 'Yes' and t2.Asset_Code = '1800'))
--TODO: Shape Checks?
--union all
--select OBJECTID, 'Warning: Road is shorter than 5 meters' as Issue from gis.ROADS_LN_evw where SHAPE.STLength() < 5
--union all
--select OBJECTID, 'Error: Multiline roads are not allowed' as Issue from gis.ROADS_LN_evw where SHAPE.STGeometryType() = 'MultiLineString'


-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'ROADS_LN'
WHERE E.Explanation IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[QC_ISSUES_TRAILS_ATTRIBUTE_PT] AS select I.Issue, D.* from gis.TRAILS_ATTRIBUTE_PT_evw AS D
join (

--------------------------
-- gis.TRAILS_ATTRIBUTE_PT
--------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_ATTRIBUTE_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
	from gis.TRAILS_ATTRIBUTE_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    TODO: are these feature independent of the trails, or are these the 'parent' featureid?
--    TODO: if the feature is tied to a 'parent' trail, would some of the attributes also be tied?  i.e. a sign on a internal trail should probably be internal
-- All FEATUREIDs should match a trail
select t1.OBJECTID, 'Error: FEATUREID not found in TRAILS_LN' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.TRAILS_ATTRIBUTE_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) TRLATTRTYPE must be non null and in DOM_TRLFEATFEATTYPE.  There is no default value
select OBJECTID, 'Error: TRLATTRTYPE is required' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where TRLATTRTYPE is null
union all
select t1.OBJECTID, 'Error: TRLATTRTYPE is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
       left join dbo.DOM_TRLATTRTYPE as t2 on t1.TRLATTRTYPE = t2.Code where t1.TRLATTRTYPE is not null and t1.TRLATTRTYPE <> '' and t2.Code is null
union all
-- 10) TRLATTRTYPEOTHER is optional free text unless TRLATTRTYPE = 'Other'. If it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Note: if there are common values here they can be promoted to TRLATTRTYPE
select OBJECTID, 'Error: TRLATTRTYPEOTHER is required when TRLFEATTYPE is Other' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw
       where TRLATTRTYPE = 'Other' and (TRLATTRTYPEOTHER is null or TRLATTRTYPEOTHER = '')
union all
select OBJECTID, 'Warning: TRLATTRTYPEOTHER will be cleared when TRLFEATTYPE is not Other' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw
       where TRLATTRTYPE <> 'Other' and TRLATTRTYPEOTHER is not null and TRLATTRTYPEOTHER <> ''
union all
-- 11) TRLATTRDESC is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) TRLATTRVALUE is optional int, but if it provided is it must be positive.
--     This can be checked and fixed automatically; no need to alert the user.
-- 13) WHLENGTH is optional real, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: WHLENGTH must be a poitive number' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where WHLENGTH < 0
union all
-- 14) WHLENUOM is an optional domain value (DOM_UOM); if WHLENGTH is not null it must be not null;
--     if WHLENGTH is null, this field will be silently set to null.
select OBJECTID, 'Error: WHLENUOM is required when WHLENGTH is positive' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where (WHLENUOM is null or WHLENUOM = '') and WHLENGTH > 0
union all
select t1.OBJECTID, 'Error: WHLENUOM is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_UOM as t2 on t1.WHLENUOM = t2.code where t1.WHLENUOM is not null and t1.WHLENUOM <> '' and t2.code is null
union all
-- 15) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 16) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 17) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: Are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE, ??) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 18) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 17/18) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 19) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- TODO: This query is very slow (~30-60sec) with versioning.  Figure it out, live with it, or run as separate check occasionally
select t1.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE <> t2.Unit_Code
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 20) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 21) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.TRAILS_ATTRIBUTE_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 22) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 23) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 24) FACLOCID is optional free text, but if provided it must match a trail location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
-- A trail attribute must be a 2100 (Trail) or a 2200 (Trail Bridge) or a 2300 (Trail Tunnel).
select t1.OBJECTID, 'Error: FACLOCID is not approriate for this kind of trail feature (based on the Asset Code)' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  where (t2.Asset_Code <> '2100' and t2.Asset_Code <> '2200' and t2.Asset_Code <> '2300')
union all
-- FACLOCID must be the same as the parent trail
-- TODO: This needs to be fixed; since featureid is not unique, this is a many to many relation,
--       so it will report a lot of false positives until the data is cleaned up.
--select t1.OBJECTID, 'Error: FACLOCID does not match the parent trail' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
--       gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t2.FEATUREID is not null and (t1.FACLOCID <> t2.FACLOCID or (t1.FACLOCID is null and t2.FACLOCID is not null) or (t2.FACLOCID is null and t1.FACLOCID is not null))
--union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.TRAILS_ATTRIBUTE_PT_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 25) FACASSETID is optional free text, provided it must match a Trail Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a trail asset in FMSS' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue from gis.TRAILS_ATTRIBUTE_PT_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'TRAILS_ATTRIBUTE_PT'
WHERE E.Explanation IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[QC_ISSUES_TRAILS_FEATURE_PT] AS select I.Issue, D.* from  gis.TRAILS_FEATURE_PT_evw AS D
join (

-------------------------
-- gis.TRAILS_FEATURE_PT
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.TRAILS_FEATURE_PT_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_FEATURE_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
	from gis.TRAILS_FEATURE_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    TODO: What is a featureid in this case?
--          is each sign, bench, etc a unique feature
--          are all the culverts on a trail a feature with the same featureid
--          is it a foreign key to the trail featureid that this sign, bench, etc is a part of (near to, maintained with, etc)
--    TODO: are these feature independent of the trails, or are these the 'parent' featureid?
--    TODO: if the feature is tied to a 'parent' trail, would some of the attributes also be tied?  i.e. a sign on a internal trail should probably be internal
-- A FEATUREID should either match a trail feature or be unique
select t1.OBJECTID, 'Error: FEATUREID not matching a TRAILS_LN must be unique' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
  and t1.FEATUREID in (select FEATUREID from gis.TRAILS_FEATURE_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
-- A featureID should be unique
--select OBJECTID, 'Error: FEATUREID must be unique' as Issue from gis.TRAILS_FEATURE_PT_evw where FEATUREID in 
--       (select FEATUREID from gis.TRAILS_FEATURE_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
--union all
-- TODO: Maybe all FEATUREIDs should match a trail
--select t1.OBJECTID, 'Error: FEATUREID not found in TRAILS_LN' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
--  left join gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
--union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.TRAILS_FEATURE_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_FEATURE_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_FEATURE_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.TRAILS_FEATURE_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.TRAILS_FEATURE_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_FEATURE_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) TRLFEATNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: TRLFEATNAME must use proper case' as Issue from gis.TRAILS_FEATURE_PT_evw where TRLFEATNAME = upper(TRLFEATNAME) Collate Latin1_General_CS_AI or TRLFEATNAME = lower(TRLFEATNAME) Collate Latin1_General_CS_AI
union all
-- 10) TRLFEATALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) TRLFEATTYPE must be non null and in DOM_TRLFEATFEATTYPE.  Theres is no default value
select OBJECTID, 'Error: TRLFEATTYPE is required' as Issue from gis.TRAILS_FEATURE_PT_evw where TRLFEATTYPE is null
union all
select t1.OBJECTID, 'Error: TRLFEATTYPE is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
       left join dbo.DOM_TRLFEATFEATTYPE as t2 on t1.TRLFEATTYPE = t2.Code where t1.TRLFEATTYPE is not null and t1.TRLFEATTYPE <> '' and t2.Code is null
union all
-- 13) TRLFEATTYPEOTHER is optional free text unless TRLFEATTYPE = 'Other'. If it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Note: if there are common values here they can be promoted to TRLFEATTYPE
select OBJECTID, 'Error: TRLFEATTYPEOTHER is required when TRLFEATTYPE is Other' as Issue from gis.TRAILS_FEATURE_PT_evw
       where TRLFEATTYPE = 'Other' and (TRLFEATTYPEOTHER is null or TRLFEATTYPEOTHER = '')
union all
select OBJECTID, 'Warning: TRLFEATTYPEOTHER will be cleared when TRLFEATTYPE is not Other' as Issue from gis.TRAILS_FEATURE_PT_evw
       where TRLFEATTYPE <> 'Other' and TRLFEATTYPEOTHER is not null and TRLFEATTYPEOTHER <> ''
union all
-- 14) TRLFEATSUBTYPE is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     TODO: do we want to make this a domain value that is sensitive to the TRLFEATTYPE
-- 15) TRLFEATDESC is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 16) TRLFEATCOUNT is optional int, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: TRLFEATCOUNT must be a poitive number' as Issue from gis.TRAILS_FEATURE_PT_evw where TRLFEATCOUNT < 0
union all
-- 17) WHLENGTH is optional real, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: WHLENGTH must be a poitive number' as Issue from gis.TRAILS_FEATURE_PT_evw where WHLENGTH < 0
union all
-- 18) WHLENUOM is an optional domain value (DOM_UOM); if WHLENGTH is not null it must be not null;
--     if WHLENGTH is null, this field will be silently set to null.
select OBJECTID, 'Error: WHLENUOM is required when WHLENGTH is positive' as Issue from gis.TRAILS_FEATURE_PT_evw where (WHLENUOM is null or WHLENUOM = '') and WHLENGTH > 0
union all
select t1.OBJECTID, 'Error: WHLENUOM is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_UOM as t2 on t1.WHLENUOM = t2.code where t1.WHLENUOM is not null and t1.WHLENUOM <> '' and t2.code is null
union all
-- 19) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.TRAILS_FEATURE_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 20) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 21) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: Are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE, ??) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue from gis.TRAILS_FEATURE_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 22) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue from gis.TRAILS_FEATURE_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 21/22) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue from gis.TRAILS_FEATURE_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 23) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- TODO: This query is very slow (~30-60sec) with versioning.  Figure it out, live with it, or run as separate check occasionally
select t1.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE <> t2.Unit_Code
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.TRAILS_FEATURE_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 24) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 25) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue from gis.TRAILS_FEATURE_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.TRAILS_FEATURE_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 26) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 27) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue from gis.TRAILS_FEATURE_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 28) FACLOCID is optional free text, but if provided it must match a Trail Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
-- A trail feature must be a 2100 (Trail) or a 2200 (Trail Bridge). A 2200 can be a TRLFEATTYPE Bridge or Walkable Structure. A TRLFEATTYPE Bridge must be a 2200, but a Walkable Structure can be a 2100 or a 2200
select t1.OBJECTID, 'Error: FACLOCID is not approriate for this kind of trail feature (based on the Asset Code)' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  where (t2.Asset_Code <> '2100' and t2.Asset_Code <> '2200')
     or (t2.Asset_Code = '2200' and t1.TRLFEATTYPE <> 'Bridge' and t1.TRLFEATTYPE <> 'Walkable Structure')
     or (t1.TRLFEATTYPE = 'Bridge' and t2.Asset_Code <> '2200')
     or (t1.TRLFEATTYPE = 'Walkable Structure' and t2.Asset_Code <> '2200' and t2.Asset_Code <> '2100')
union all
-- FACLOCID does not need to be unique (a single trail can have several features) 
-- FACLOCID must be the same as the parent trail
select t1.OBJECTID, 'Error: FACLOCID does not match the parent trail' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
       gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t2.FACLOCID is null or t1.FACLOCID <> t2.FACLOCID
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue from gis.TRAILS_FEATURE_PT_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.TRAILS_FEATURE_PT_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 29) FACASSETID is optional free text, provided it must match a Trail Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a trail asset in FMSS' as Issue from gis.TRAILS_FEATURE_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue from gis.TRAILS_FEATURE_PT_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)



-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'TRAILS_FEATURE_PT'
WHERE E.Explanation IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_TRAILS_LN] AS select I.Issue, D.* from  gis.TRAILS_LN_evw AS D
join (

-------------------------
-- gis.TRAILS_LN
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) LINETYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary line' without a warning
--    TODO this is not part of the standard (maybe core after the fact), most is centerline
--    should we do something like bldgs with center being required, and edge or other being optional and linked
--    maybe require that this is a centerline feature class.
select t1.OBJECTID, 'Error: LINETYPE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_LINETYPE as t2 on t1.LINETYPE = t2.Code where t1.LINETYPE is not null and t1.LINETYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue from gis.TRAILS_LN_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_LN_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue
	from gis.TRAILS_LN_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    We haven't yet defined what it means, exactly, to be a trail feature (i.e. what segments should share a FEATUREID), but we know that FEATUREID will not be unique.
--       This allows a long trail to be broken into multiple smaller segments, and allows different trail types (e.g. main and spur) to be part of the same "trail".
--       however, it also allows errors like two different (by geography or attributes) trails having the same featureid (common copy/paste error)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
--    TODO: consider what attributes, in addition to FMSS attributes, should be the same when FEATUREID is the same
--    TODO: Query for records with a FEATUREID far away from the average for all features with the FEATUREID
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue
	from gis.TRAILS_LN_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue from gis.TRAILS_LN_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue from gis.TRAILS_LN_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) TRLNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: TRLNAME must use proper case' as Issue from gis.TRAILS_LN_evw where TRLNAME = upper(TRLNAME) Collate Latin1_General_CS_AI or TRLNAME = lower(TRLNAME) Collate Latin1_General_CS_AI
union all
-- 10) TRLALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) TRLFEATTYPE is a required domain value; default is Unknown
--     TODO: Compare with FMSS i.e. if there is a valid FACLOCID, with an 'Existing' Status, then it can't be an unmaintained trail
select OBJECTID, 'Warning: TRLFEATTYPE is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where TRLFEATTYPE is null or TRLFEATTYPE = ''
union all
select t1.OBJECTID, 'Error: TRLFEATTYPE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLFEATTYPE as t2 on t1.TRLFEATTYPE = t2.Code where t1.TRLFEATTYPE is not null and t1.TRLFEATTYPE <> '' and t2.Code is null
union all 
-- 13) TRLSTATUS is a required domain value; default is 'Existing'
--     different parts of a single 'Feature' can have different status
--     TODO: Compare with FMSS; all parts of the feature with same FACLOCID will have the same status 
select OBJECTID, 'Warning: TRLSTATUS is not provided, default value of *Existing* will be used' as Issue from gis.TRAILS_LN_evw where TRLSTATUS is null or TRLSTATUS = ''
union all
select t1.OBJECTID, 'Error: TRLSTATUS is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLSTATUS as t2 on t1.TRLSTATUS = t2.Code where t1.TRLSTATUS is not null and t1.TRLSTATUS <> '' and t2.Code is null
union all
-- 14) TRLSURFACE is a required domain value; default is 'Unknown'
--     different parts of a single 'Feature' can have different surface
--     TODO: Compare with FMSS; all parts of the feature with same FACLOCID will have the same surface 
select OBJECTID, 'Warning: TRLSURFACE is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where TRLSURFACE is null or TRLSURFACE = ''
union all
select t1.OBJECTID, 'Error: TRLSURFACE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLSURFACE as t2 on t1.TRLSURFACE = t2.Code where t1.TRLSURFACE is not null and t1.TRLSURFACE <> '' and t2.Code is null
union all 
-- 15) TRLTYPE is a required domain value; default is Unknown
select OBJECTID, 'Warning: TRLTYPE is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where TRLTYPE is null or TRLTYPE = ''
union all
select t1.OBJECTID, 'Error: TRLTYPE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLTYPE as t2 on t1.TRLTYPE = t2.Code where t1.TRLTYPE is not null and t1.TRLTYPE <> '' and t2.Code is null
union all 
-- 16) TRLCLASS is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: TRLCLASS is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where TRLCLASS is null or TRLCLASS = ''
union all
select t1.OBJECTID, 'Error: TRLCLASS is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLCLASS as t2 on t1.TRLCLASS = t2.Code where t1.TRLCLASS is not null and t1.TRLCLASS <> '' and t2.Code is null
union all 
-- 17) TRLUSE is a required pipe delimited list of approved uses
--     In AKR, this is a calculated field based on the various TRLUSE_* boolean columns
--     It will always be silently updated.  Woe to the unwary user that edits this field.
-- 18) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue from gis.TRAILS_LN_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS
union all
-- 19) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue from gis.TRAILS_LN_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 20) MAINTAINER is a optional domain value;
--     TODO: if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
-- 21) ISEXTANT is a required domain value; Default to 'True' with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue from gis.TRAILS_LN_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 22) PUBLICDISPLAY is a required Domain Value; Default to 'No Public Map Display' with Warning
--     TODO: are there requirements of other fields (i.e. TRLSTATUS, ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue from gis.TRAILS_LN_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 23) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue from gis.TRAILS_LN_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 22/23) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue from gis.TRAILS_LN_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 24) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the road is not within a unit boundary' as Issue from gis.TRAILS_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- TODO This query is very slow (~30-60sec) with versioning.  Figure it out, live with it, or run as separate check occasionally
select t1.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue from gis.TRAILS_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE <> t2.Unit_Code
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.TRAILS_LN_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 25) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_LN_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_LN_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 26) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue from gis.TRAILS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue from gis.TRAILS_LN_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.TRAILS_LN_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 27) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue from gis.TRAILS_LN_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 28) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue from gis.TRAILS_LN_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 29) FACLOCID is optional free text, but if provided it must be unique and match a Location in the FMSS Export
--     all line segments with the same FACLOCID must have the same featureid
--     NOTE: not all segements with the same featureid must have the same FACLOCID (we may associated spurs, etc with a trail network (one feature) that are not maintained in FMSS)
--     TODO: A bridge/tunnel in a trail will have the feature id, however the FACLOCID (and asset type) for the bridge/tunnel is different from the trail on/in the bridge/tunnel
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue from gis.TRAILS_LN_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Trail in FMSS' as Issue from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue from gis.TRAILS_LN_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.TRAILS_LN_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 32) FACASSETID is optional free text, provided it must match a Trail Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue from gis.TRAILS_LN_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a trail asset in FMSS' as Issue from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue from gis.TRAILS_LN_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.TRAILS_LN_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
----------------------------------------------------
-- AKR Additions to the Trails Spatial Data Standard
----------------------------------------------------
-- 31) ISOUTPARK: This is an AKR extension, it is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 32) ISBRIDGE: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISBRIDGE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISBRIDGE = t2.Code where t1.ISBRIDGE is not null and t1.ISBRIDGE <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISBRIDGE does not match the FMSS.Asset_Code' as Issue from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and ((t1.ISBRIDGE = 'Yes' and t2.Asset_Code <> '2200') or (t1.ISBRIDGE <> 'Yes' and t2.Asset_Code = '2200'))
union all
-- 33) ISTUNNEL: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISTUNNEL is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISTUNNEL = t2.Code where t1.ISTUNNEL is not null and t1.ISTUNNEL <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISTUNNEL does not match the FMSS.Asset_Code' as Issue from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and ((t1.ISTUNNEL = 'Yes' and t2.Asset_Code <> '2300') or (t1.ISTUNNEL <> 'Yes' and t2.Asset_Code = '2300'))
union all 
-- 34) TRLTRACK: This is an AKR extension; it is a required domain element; defaults to 'Unknown' with warning
select OBJECTID, 'Warning: TRLTRACK is not provided, default value of *Unknown* will be used' as Issue from gis.TRAILS_LN_evw where TRLTRACK is null or TRLTRACK = ''
union all
select t1.OBJECTID, 'Error: TRLTRACK is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLTRACK as t2 on t1.TRLTRACK = t2.Code where t1.TRLTRACK is not null and t1.TRLTRACK <> '' and t2.Code is null
union all 
-- 35) TRLISSOCIAL: This is an AKR extension; it is a required domain element; defaults to 'No' without a warning
select t1.OBJECTID, 'Error: TRLISSOCIAL is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLISSOCIAL = t2.Code where t1.TRLISSOCIAL is not null and t1.TRLISSOCIAL <> '' and t2.Code is null
union all
-- 36) TRLISANIMAL: This is an AKR extension; it is a required domain element; defaults to 'No' without a warning
select t1.OBJECTID, 'Error: TRLISANIMAL is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLISANIMAL = t2.Code where t1.TRLISANIMAL is not null and t1.TRLISANIMAL <> '' and t2.Code is null
union all
-- 37) TRLISADMIN: This is an AKR extension; it is a required domain element; defaults to 'No' without a warning
select t1.OBJECTID, 'Error: TRLISADMIN is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLISADMIN = t2.Code where t1.TRLISADMIN is not null and t1.TRLISADMIN <> '' and t2.Code is null
union all
--TODO: Look for illogical combinations of TRLFEATTYPE and TRLIS*
-- 38) WHLENGTH_FT: This is an AKR extension; it is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: WHLENGTH_FT is not allowed to be a negative number' as Issue from gis.TRAILS_LN_evw where WHLENGTH_FT < 0
union all
-- 39) TRLDESC: This is an AKR extension; it is an optional free text field; it should not be an empty string
-- 40) TRLUSE_*: This is an AKR extension; It defaults to NULL (no data); Yes if the use is specifically supported; No if it is specifically prohibited
select t1.OBJECTID, 'Error: TRLUSE_FOOT is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_FOOT = t2.Code where t1.TRLUSE_FOOT is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_BICYCLE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_BICYCLE = t2.Code where t1.TRLUSE_BICYCLE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_HORSE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_HORSE = t2.Code where t1.TRLUSE_HORSE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_ATV is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_ATV = t2.Code where t1.TRLUSE_ATV is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_4WD is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_4WD = t2.Code where t1.TRLUSE_4WD is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_OHVSUB is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_OHVSUB = t2.Code where t1.TRLUSE_OHVSUB is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_MOTORCYCLE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_MOTORCYCLE = t2.Code where t1.TRLUSE_MOTORCYCLE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_SNOWMOBILE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_SNOWMOBILE = t2.Code where t1.TRLUSE_SNOWMOBILE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_SNOWSHOE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_SNOWSHOE = t2.Code where t1.TRLUSE_SNOWSHOE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_SKITOUR is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_SKITOUR = t2.Code where t1.TRLUSE_SKITOUR is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_NORDIC is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_NORDIC = t2.Code where t1.TRLUSE_NORDIC is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_DOWNHILL is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_DOWNHILL = t2.Code where t1.TRLUSE_DOWNHILL is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_DOGSLED is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_DOGSLED = t2.Code where t1.TRLUSE_DOGSLED is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_CANYONEER is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_CANYONEER = t2.Code where t1.TRLUSE_CANYONEER is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_CLIMB is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_CLIMB = t2.Code where t1.TRLUSE_CLIMB is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_MOTORBOAT is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_MOTORBOAT = t2.Code where t1.TRLUSE_MOTORBOAT is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_CANOE is not a recognized value' as Issue from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_CANOE = t2.Code where t1.TRLUSE_CANOE is not null and t2.Code is null
--TODO: Look for illogical combinations of TRLTYPE and TRLUSE_*
--TODO: Shape Checks?
--union all
--select OBJECTID, 'Warning: Trail shorter than 5 meters' as Issue from gis.TRAILS_LN_evw where SHAPE.STLength() < 5
--union all
--select OBJECTID, 'Error: Multiline trails are not allowed' as Issue from gis.TRAILS_LN_evw  where SHAPE.STGeometryType() = 'MultiLineString'



-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'TRAILS_LN'
WHERE E.Explanation IS NULL
GO
