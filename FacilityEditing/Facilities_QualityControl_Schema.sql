USE [akr_facility2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Concat4ID](
     @a nvarchar(50), -- id 1
     @b nvarchar(50), -- id 2
     @c nvarchar(50), -- id 3
     @d nvarchar(50) -- id 4
) RETURNS VARCHAR(255)
AS
BEGIN
  DECLARE @result varchar(255)
  SET @result = SUBSTRING(CONCAT(
    CASE @a WHEN NULL THEN NULL ELSE '|'+ @a END,
    CASE @b WHEN NULL THEN NULL ELSE '|'+ @b END,
    CASE @c WHEN NULL THEN NULL ELSE '|'+ @c END,
    CASE @d WHEN NULL THEN NULL ELSE '|'+ @d END
  ), 2, 254)
  IF @result = ''
  BEGIN
    SET @result = NULL
  END
  RETURN @result
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[RoadIsFullyConnected](@featureid VARCHAR(255)) RETURNS int
AS
BEGIN
  Declare @segments Table (segment geometry)  -- contains all segments not yet connected
  DECLARE @shape geometry                     -- The union of the connected segments (starts with one segment and builds)
  DECLARE @connected_segments geometry        -- A geometry collection of all segments that intersect @Shape, but are not yet unioned
  DECLARE @count int                          -- How many segments are still unconnected
   
  INSERT INTO @segments select Shape from gis.ROADS_LN_evw where FEATUREID = @featureid;
  Select Top 1 @shape = segment from @segments order by segment.STLength() desc;
  delete @segments where segment.STEquals(@shape) = 1;

  WHILE @shape IS NOT NULL
  BEGIN
	-- if a segment touches @shape, remove from @segments and union with @shape
    select @connected_segments = geometry::CollectionAggregate(segment) from @segments where segment.STIntersects(@shape) = 1;
	delete from @segments where segment.STIntersects(@shape) = 1;
	Set @shape = @shape.STUnion(@connected_segments)  -- will be set to null if there are no connected segments, so we are done
  END
  SELECT @count = count(*) from @segments  -- fully connected if there are no segments left unconnected
  RETURN case when @count = 0 then 1 else 0 end
END
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

CREATE FUNCTION [dbo].[TrailIsFullyConnected](@featureid VARCHAR(255)) RETURNS int
AS
BEGIN
  Declare @segments Table (segment geometry)  -- contains all segments not yet connected
  DECLARE @shape geometry                     -- The union of the connected segments (starts with one segment and builds)
  DECLARE @connected_segments geometry        -- A geometry collection of all segments that intersect @Shape, but are not yet unioned
  DECLARE @count int                          -- How many segments are still unconnected
   
  INSERT INTO @segments select Shape from gis.TRAILS_LN_evw where FEATUREID = @featureid;
  Select Top 1 @shape = segment from @segments order by segment.STLength() desc;
  delete @segments where segment.STEquals(@shape) = 1;

  WHILE @shape IS NOT NULL
  BEGIN
	-- if a segment touches @shape, remove from @segments and union with @shape
    select @connected_segments = geometry::CollectionAggregate(segment) from @segments where segment.STIntersects(@shape) = 1;
	delete from @segments where segment.STIntersects(@shape) = 1;
	Set @shape = @shape.STUnion(@connected_segments)  -- will be set to null if there are no connected segments, so we are done
  END
  SELECT @count = count(*) from @segments  -- fully connected if there are no segments left unconnected
  RETURN case when @count = 0 then 1 else 0 end
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[TrailNotConnected](@featureid VARCHAR(255)) RETURNS geometry
AS
BEGIN
  Declare @segments Table (segment geometry)  -- contains all segments not yet connected
  DECLARE @shape geometry                     -- The union of the connected segments (starts with one segment and builds)
  DECLARE @connected_segments geometry        -- A geometry collection of all segments that intersect @Shape, but are not yet unioned
  DECLARE @count int                          -- How many segments are still unconnected
   
  INSERT INTO @segments select Shape from gis.TRAILS_LN_evw where FEATUREID = @featureid;
  Select Top 1 @shape = segment from @segments order by segment.STLength() desc;
  delete @segments where segment.STEquals(@shape) = 1;

  WHILE @shape IS NOT NULL
  BEGIN
	-- if a segment touches @shape, remove from @segments and union with @shape
    select @connected_segments = geometry::CollectionAggregate(segment) from @segments where segment.STIntersects(@shape) = 1;
	delete from @segments where segment.STIntersects(@shape) = 1;
	Set @shape = @shape.STUnion(@connected_segments)  -- will be set to null if there are no connected segments, so we are done
  END
  --SELECT @count = count(*) from @segments  -- fully connected if there are no segments left unconnected
  Select Top 1 @shape = segment from @segments
  RETURN @shape
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[TrailsNotConnected](@featureid VARCHAR(255)) RETURNS int
AS
BEGIN
  Declare @segments Table (segment geometry)  -- contains all segments not yet connected
  DECLARE @shape geometry                     -- The union of the connected segments (starts with one segment and builds)
  DECLARE @connected_segments geometry        -- A geometry collection of all segments that intersect @Shape, but are not yet unioned
  DECLARE @count int                          -- How many segments are still unconnected
   
  INSERT INTO @segments select Shape from gis.TRAILS_LN_evw where FEATUREID = @featureid;
  Select Top 1 @shape = segment from @segments order by segment.STLength() desc;
  delete @segments where segment.STEquals(@shape) = 1;

  WHILE @shape IS NOT NULL
  BEGIN
	-- if a segment touches @shape, remove from @segments and union with @shape
    select @connected_segments = geometry::CollectionAggregate(segment) from @segments where segment.STIntersects(@shape) = 1;
	delete from @segments where segment.STIntersects(@shape) = 1;
	Set @shape = @shape.STUnion(@connected_segments)  -- will be set to null if there are no connected segments, so we are done
  END
  SELECT @count = count(*) from @segments  -- fully connected if there are no segments left unconnected
  --Select Top 1 @shape = segment from @segments
  RETURN @count
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
     @i nvarchar(10), -- nordic (groomed nordic ski trails)
     @j nvarchar(10), -- Dogsled
     @k nvarchar(10), -- motorboat
     @l nvarchar(10), -- canoe
	 	 -- AKR Additions (listed as Other)
     @m nvarchar(10) = NULL, -- OHVSUB
     @n nvarchar(10) = NULL, -- skitour (back country ski tour)
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
    CASE @e WHEN 'Yes' THEN '|Four-Wheel Drive Vehicle > 50� in Tread Width' ELSE NULL END,
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
     @k nvarchar(10), -- motorboat
     @l nvarchar(10), -- canoe
	 -- AKR Additions
     @m nvarchar(10), -- OHVSUB (other)
     @n nvarchar(10), -- skitour (back country ski tour)
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
    CASE @e WHEN 'Yes' THEN '|Four-Wheel Drive Vehicle > 50� in Tread Width' WHEN 'No' THEN '|No Four-Wheel Drive Vehicle > 50� in Tread Width' ELSE NULL END,
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
select 'DOM_MAINTAINER' as TableName, 'DOM_MAINTAINER_NPS2018' as DomainName, Code, Code as Value from DOM_MAINTAINER
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
select 'DOM_RDMAINTAINER' as TableName, 'DOM_RDMAINTAINER_NPS2018' as DomainName, Code, Code as Value from DOM_RDMAINTAINER
union all
select 'DOM_RDONEWAY' as TableName, 'DOM_RDONEWAY_NPS2016' as DomainName, Code, Code as Value from DOM_RDONEWAY
union all
select 'DOM_RDSTATUS' as TableName, 'DOM_RDSTATUS_NPS2016' as DomainName, Code, Code as Value from DOM_RDSTATUS
union all
select 'DOM_RDSURFACE' as TableName, 'DOM_RDSURFACE_NPS2016' as DomainName, Code, Code as Value from DOM_RDSURFACE
union all
select 'DOM_TRLATTRTYPE' as TableName, 'DOM_TRLATTRTYPE' as DomainName, Code, Code as Value from DOM_TRLATTRTYPE
union all
select 'DOM_TRLCLASS' as TableName, 'DOM_TRLCLASS_NPS2016' as DomainName, Code, Code as Value from DOM_TRLCLASS
union all
select 'DOM_TRLFEATFEATTYPE' as TableName, 'DOM_TRLFEATFEATTYPE' as DomainName, Code, Code as Value from DOM_TRLFEATFEATTYPE
union all
select 'DOM_TRLFEATTYPE' as TableName, 'DOM_TRLFEATTYPE_NPSAKR2018' as DomainName, Code, Code as Value from DOM_TRLFEATTYPE
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
GRANT SELECT ON [dbo].[AKR_BLDG_PT] TO [akr_facility_editor] AS [dbo]
GO
GRANT SELECT ON [dbo].[AKR_BLDG_PT] TO [akr_reader_web] AS [dbo]
GO
GRANT SELECT ON [dbo].[AKR_BLDG_PT] TO [nps\Domain Users] AS [dbo]
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
GRANT SELECT ON [dbo].[AKR_BLDG_PY] TO [akr_facility_editor] AS [dbo]
GO
GRANT SELECT ON [dbo].[AKR_BLDG_PY] TO [akr_reader_web] AS [dbo]
GO
GRANT SELECT ON [dbo].[AKR_BLDG_PY] TO [nps\Domain Users] AS [dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[FMSS_Report_Cordinates] as 

	-- building with only one point
	select FACLOCID, Shape.STY as Lat1, Shape.STX as Long1, NULL as Lat2, NULL as Long2 from gis.AKR_BLDG_CENTER_PT_evw where FACLOCID in (SELECT FACLOCID from gis.AKR_BLDG_CENTER_PT_evw where FACLOCID is not null group by FACLOCID having count(*) = 1)
	union all

	-- buildings with multiple points
	select FACLOCID, geometry::EnvelopeAggregate(Shape).STCentroid().STY as Lat1, geometry::EnvelopeAggregate(Shape).STCentroid().STX as Long1, NULL as Lat2, NULL as Long2 from gis.AKR_BLDG_CENTER_PT_evw where FACLOCID is not null group by FACLOCID having count(*) >1
	union all

	-- parkinglot polygons (may be multiple), so union first, may also be part of a road asset (like a pullout), so eliminate those
	select FACLOCID,
	  geometry::UnionAggregate(Shape).STCentroid().STY as Lat1,
	  geometry::UnionAggregate(Shape).STCentroid().STX as Long1,
	  NULL as Lat2, NULL as Long2 
	from gis.PARKLOTS_PY_evw as t join FMSSExport as F on t.FACLOCID = f.Location where FACLOCID is not null and f.Asset_Code = '1300' group by FACLOCID
	union all

	-- Roads
	-- only one segment in the road
	select faclocid,  
	  Shape.STStartPoint().STY as Lat1,
	  Shape.STStartPoint().STX as Long1,
	  Shape.STEndPoint().STY as Lat2,
	  Shape.STEndPoint().STX as Long2
	from gis.ROADS_LN_evw where FACLOCID in (
		select FACLOCID from gis.ROADS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where FACLOCID is not null and linetype = 'Center Line' and f.Asset_Code = '1100' group by faclocid having count(*) = 1
	)
	union all
	-- multi segment roads
	select faclocid,  
	  geometry::UnionAggregate(Shape).STStartPoint().STY as Lat1,
	  geometry::UnionAggregate(Shape).STStartPoint().STX as Long1,
	  geometry::UnionAggregate(Shape).STEndPoint().STY as Lat2,
	  geometry::UnionAggregate(Shape).STEndPoint().STX as Long2
	from gis.ROADS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where FACLOCID is not null  and linetype = 'Center Line' and f.Asset_Code = '1100' group by faclocid having count(*) > 1
	union all

	-- Road Bridges (assume only one segment)
	  -- check assumption
	  -- select Faclocid, count(*) from gis.ROADS_LN_evw where ISBRIDGE = 'Yes' and FACLOCID is not null group by FACLOCID having count(*) > 1
	select FACLOCID, Shape.STStartPoint().STY as Lat1, Shape.STStartPoint().STX as Long1, Shape.STEndPoint().STY as Lat2, Shape.STEndPoint().STX as Long2 from gis.ROADS_LN_evw where FACLOCID in (
		select t.FACLOCID from gis.ROADS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where t.ISBRIDGE = 'Yes' and t.FACLOCID is not null and t.linetype = 'Center Line' and f.Asset_Code = '1700' group by FACLOCID having count(*) = 1
	) and linetype = 'Center Line' 
	union all

	-- Trails
	-- only one segment in the trail
	select faclocid,  
	  Shape.STStartPoint().STY as Lat1,
	  Shape.STStartPoint().STX as Long1,
	  Shape.STEndPoint().STY as Lat2,
	  Shape.STEndPoint().STX as Long2
	from gis.TRAILS_LN_evw where FACLOCID in (
		select t.FACLOCID from gis.TRAILS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where t.FACLOCID is not null and t.linetype = 'Center Line' and f.Asset_Code = '2100' group by FACLOCID having count(*) = 1
	)
	union all
	-- Multi segment trails
	select faclocid,  
	  geometry::UnionAggregate(Shape).STStartPoint().STY as Lat1,
	  geometry::UnionAggregate(Shape).STStartPoint().STX as Long1,
	  geometry::UnionAggregate(Shape).STEndPoint().STY as Lat2,
	  geometry::UnionAggregate(Shape).STEndPoint().STX as Long2
	from gis.TRAILS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where FACLOCID is not null and linetype = 'Center Line' and f.Asset_Code = '2100' group by faclocid having count(*) > 1
	union all

	-- Trail Bridges (assume There are some with multiple segments)
	  -- check assumption
	  -- select Faclocid, count(*) from gis.TRAILS_LN_evw where ISBRIDGE = 'Yes' and FACLOCID is not null  and linetype = 'Center Line' group by FACLOCID having count(*) > 1
	-- Single segment trail bridges
	select FACLOCID, Shape.STStartPoint().STY as Lat1, Shape.STStartPoint().STX as Long1, Shape.STEndPoint().STY as Lat2, Shape.STEndPoint().STX as Long2 from gis.TRAILS_LN_evw where FACLOCID in (
		select t.FACLOCID from gis.TRAILS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where t.ISBRIDGE = 'Yes' and t.FACLOCID is not null and t.linetype = 'Center Line' and f.Asset_Code = '2200' group by FACLOCID having count(*) = 1
	) and linetype = 'Center Line' 

	union all
	-- Multi segment trail bridges
	select faclocid,  
	  geometry::UnionAggregate(Shape).STStartPoint().STY as Lat1,
	  geometry::UnionAggregate(Shape).STStartPoint().STX as Long1,
	  geometry::UnionAggregate(Shape).STEndPoint().STY as Lat2,
	  geometry::UnionAggregate(Shape).STEndPoint().STX as Long2
	from gis.TRAILS_LN_evw as t join FMSSExport as F on t.FACLOCID = f.Location where ISBRIDGE = 'Yes' AND FACLOCID is not null and linetype = 'Center Line' and f.Asset_Code = '2200' group by faclocid having count(*) > 1


	/*

	-- We might be able to improve multi segment roads and trails by adding in the bridges (with different FACLOCID but same FEATUREID)
	-- all segments with the same faclocid must have the same featureid (QC check #31)
	-- all segments with the same featureid must be connected (QC check #3)
	-- I don't know what algorithm is used in the unionaggregate, but maybe a more explicit algorithm would yield better end points
	-- Maybe looking at the envelope of the unioned segments would help us pick a better set of end points. 
	-- group by faclocid, get the featureid, get the connected linestring for the featureid, get the start and end points

	-- It is tricky to get the right FACLOCID and FEATUREID in the GROUP BY situation
	select FEATUREID,  MAX(FACLOCID), MIN(FACLOCID),  -- these are often but not always the same, they may even both be bridges
	  geometry::UnionAggregate(Shape).STStartPoint().STY as Lat1,
	  geometry::UnionAggregate(Shape).STStartPoint().STX as Long1,
	  geometry::UnionAggregate(Shape).STEndPoint().STY as Lat2,
	  geometry::UnionAggregate(Shape).STEndPoint().STX as Long2
	from gis.ROADS_LN_evw where FEATUREID in (
	  select min(featureid) as featureid from gis.ROADS_LN_evw where FACLOCID is not null and linetype = 'Center Line' group by faclocid having count(*) > 1
	) GROUP BY FEATUREID

	*/

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_ASSET] AS select I.Issue, I.Details, D.* from  gis.AKR_ASSET_evw AS D
join (

-------------------------
-- gis.AKR_ASSET
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) No geometry type i.e. LINETYPE 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL as Details from gis.AKR_ASSET_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.AKR_ASSET_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_ASSET_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_ASSET_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) ASSETNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: ASSETNAME must use proper case' as Issue, NULL from gis.AKR_ASSET_evw where ASSETNAME = upper(ASSETNAME) Collate Latin1_General_CS_AI or ASSETNAME = lower(ASSETNAME) Collate Latin1_General_CS_AI
union all
-- 10) ASSETALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) ASSETTYPE must be in DOM_ASSETTYPE.
select t1.OBJECTID, 'Error: ASSETTYPE is required' as Issue, NULL from gis.AKR_ASSET_evw as t1
       where t1.ASSETTYPE is null or t1.ASSETTYPE = ''
union all 
select t1.OBJECTID, 'Error: ASSETTYPE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
       left join dbo.DOM_ASSETTYPE as t2 on t1.ASSETTYPE = t2.Code where t1.ASSETTYPE is not null and t1.ASSETTYPE <> '' and t2.Code is null
union all 
-- 13) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 14) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.AKR_ASSET_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 15) MAINTAINER is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  dbo.FMSSExport as f on f.Location = a.Location where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.AKR_ASSET_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.AKR_ASSET_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_ASSET_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 19) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_ASSET_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 18/19) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_ASSET_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 20) UNITCODE is a required domain value.
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select OBJECTID, 'Error: UNITCODE is required (It cannot be calculated for a non-spatial feature)' as Issue, NULL from gis.AKR_ASSET_evw
  where UNITCODE is null or UNITCODE = ''
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 21) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 22) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_ASSET_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_ASSET_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_ASSET_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 23) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 24) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_ASSET_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 25) FACLOCID is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue, NULL from gis.AKR_ASSET_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.AKR_ASSET_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 26) FACASSETID is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.AKR_ASSET_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue, NULL from gis.AKR_ASSET_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.AKR_ASSET_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- 27) ASSETCODE must be in DOM_ASSETCODE; if FACLOCID OR FACASSETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: ASSETCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
       left join dbo.DOM_ASSETCODE as t2 on t1.ASSETCODE = t2.Code where t1.ASSETCODE is not null and t1.ASSETCODE <> '' and t2.Code is null
union all 
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + FACLOCID + ' has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID 
  join dbo.FMSSExport as f on a.Location = f.Location
  where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
-- 28) ASSETTYPEOTHDESC is not required Unless ASSETTYPE = 'Other'.
--     If it provided is it should not be an empty string. This can be checked and fixed automatically; no need to alert the user.
select OBJECTID, 'Error: ASSETTYPEOTHDESC is required when ASSETTYPE is Other' as Issue, NULL from gis.AKR_ASSET_evw
       where ASSETTYPE = 'Other' and (ASSETTYPEOTHDESC = '' or ASSETTYPEOTHDESC is null)
union all 
-- 29) ASSETDESC is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 30) ASSETMATERIAL is an optional domain value;
select t1.OBJECTID, 'Error: ASSETMATERIAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_evw as t1
       left join dbo.DOM_ASSETMATERIAL as t2 on t1.ASSETMATERIAL = t2.Code where t1.ASSETMATERIAL is not null and t1.ASSETMATERIAL <> '' and t2.Code is null
union all
-- 31) ASSETDIAMETER_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDIAMETER_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_evw where ASSETDIAMETER_FT < 0
union all
-- 32) ASSETLENGTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETLENGTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_evw where ASSETLENGTH_FT < 0
union all
-- 33) ASSETWIDTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETWIDTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_evw where ASSETWIDTH_FT < 0
union all
-- 34) ASSETDEPTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDEPTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_evw where ASSETDEPTH_FT < 0

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_ASSET'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_ASSET_LN] AS select I.Issue, I.Details, D.* from  gis.AKR_ASSET_LN_evw AS D
join (

-------------------------
-- gis.AKR_ASSET_LN
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) LINETYPE must be an recognized value; if it is null/empty, then it will default to 'Center line' without a warning
select t1.OBJECTID, 'Error: LINETYPE is not a recognized value' as Issue, NULL as Details from gis.AKR_ASSET_LN_evw as t1
  left join dbo.DOM_LINETYPE as t2 on t1.LINETYPE = t2.Code where t1.LINETYPE is not null and t1.LINETYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.AKR_ASSET_LN_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.AKR_ASSET_LN_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_LN_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_LN_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- TODO: Fix for Lines (aggregate area will always be zero)
/*
select OBJECTID, 'Error: Features with the same FEATUREID are not close to each other' as Issue, 'FEATUREID = ''' + FEATUREID + '''' as Details
  from gis.AKR_ASSET_LN_evw where featureid in 
  (select FEATUREID from gis.AKR_ASSET_LN_evw group by FEATUREID having count(*) > 1 and
   geometry::ConvexHullAggregate(Shape).STArea()/geometry::CollectionAggregate(Shape).STArea() > 10)
union all
*/
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_ASSET_LN_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_ASSET_LN_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) ASSETNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: ASSETNAME must use proper case' as Issue, NULL from gis.AKR_ASSET_LN_evw where  len(ASSETNAME) > 5 AND (ASSETNAME = upper(ASSETNAME) Collate Latin1_General_CS_AI or ASSETNAME = lower(ASSETNAME) Collate Latin1_General_CS_AI)
union all
-- 10) ASSETALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: MAPLABEL must use proper case' as Issue, NULL from gis.AKR_ASSET_LN_evw where len(MAPLABEL) > 5 AND (MAPLABEL = upper(MAPLABEL) Collate Latin1_General_CS_AI or MAPLABEL = lower(MAPLABEL) Collate Latin1_General_CS_AI)
union all
-- 12) ASSETTYPE must be in DOM_ASSETTYPE.
select t1.OBJECTID, 'Error: ASSETTYPE is required' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
       where t1.ASSETTYPE is null or t1.ASSETTYPE = ''
union all 
select t1.OBJECTID, 'Error: ASSETTYPE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
       left join dbo.DOM_ASSETTYPE as t2 on t1.ASSETTYPE = t2.Code where t1.ASSETTYPE is not null and t1.ASSETTYPE <> '' and t2.Code is null
union all 
-- 13) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_LN_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_LN_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 14) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 15) MAINTAINER is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_LN_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_LN_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  dbo.FMSSExport as f on f.Location = a.Location where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.AKR_ASSET_LN_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 19) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_ASSET_LN_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 18/19) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_ASSET_LN_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 20) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.AKR_ASSET_LN_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_LN_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_LN_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 21) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 22) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_ASSET_LN_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 23) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 24) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_ASSET_LN_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 25) FACLOCID is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue, NULL from gis.AKR_ASSET_LN_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.AKR_ASSET_LN_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 26) FACASSETID is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue, NULL from gis.AKR_ASSET_LN_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.AKR_ASSET_LN_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- 27) ASSETCODE must be in DOM_ASSETCODE; if FACLOCID OR FACASSETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: ASSETCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
       left join dbo.DOM_ASSETCODE as t2 on t1.ASSETCODE = t2.Code where t1.ASSETCODE is not null and t1.ASSETCODE <> '' and t2.Code is null
union all 
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + FACLOCID + ' has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_LN_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_LN_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID 
  join dbo.FMSSExport as f on a.Location = f.Location
  where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
-- 28) ASSETTYPEOTHDESC is not required Unless ASSETTYPE = 'Other'.
--     If it provided is it should not be an empty string. This can be checked and fixed automatically; no need to alert the user.
select OBJECTID, 'Error: ASSETTYPEOTHDESC is required when ASSETTYPE is Other' as Issue, NULL from gis.AKR_ASSET_LN_evw
       where ASSETTYPE = 'Other' and (ASSETTYPEOTHDESC = '' or ASSETTYPEOTHDESC is null)
union all 
-- 29) ASSETDESC is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 30) ASSETMATERIAL is an optional domain value;
select t1.OBJECTID, 'Error: ASSETMATERIAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_LN_evw as t1
       left join dbo.DOM_ASSETMATERIAL as t2 on t1.ASSETMATERIAL = t2.Code where t1.ASSETMATERIAL is not null and t1.ASSETMATERIAL <> '' and t2.Code is null
union all
-- 31) ASSETDIAMETER_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDIAMETER_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_LN_evw where ASSETDIAMETER_FT < 0
union all
-- 32) ASSETLENGTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETLENGTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_LN_evw where ASSETLENGTH_FT < 0
union all
-- 33) ASSETWIDTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETWIDTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_LN_evw where ASSETWIDTH_FT < 0
union all
-- 34) ASSETDEPTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDEPTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_LN_evw where ASSETDEPTH_FT < 0
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.AKR_ASSET_LN_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.AKR_ASSET_LN_evw where shape.STIsValid() = 0
-- Overlaps are possible (even exepcted among SITES)
-- Size checks are difficult because of variation in QTY units; May try later when trends are identified 

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_ASSET_LN'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_ASSET_PT] AS select I.Issue, I.Details, D.* from  gis.AKR_ASSET_PT_evw AS D
join (

-------------------------
-- gis.AKR_ASSET_PT
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be an recognized value; if it is null/empty, then it will default to 'arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue, NULL as Details from gis.AKR_ASSET_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.AKR_ASSET_PT_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.AKR_ASSET_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- TODO: Fix for points (aggregate area will always be zero)
/*
select OBJECTID, 'Error: Features with the same FEATUREID are not close to each other' as Issue, 'FEATUREID = ''' + FEATUREID + '''' as Details
  from gis.AKR_ASSET_PT_evw where featureid in 
  (select FEATUREID from gis.AKR_ASSET_PT_evw group by FEATUREID having count(*) > 1 and
   geometry::ConvexHullAggregate(Shape).STArea()/geometry::CollectionAggregate(Shape).STArea() > 10)
union all
*/
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_ASSET_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_ASSET_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) ASSETNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: ASSETNAME must use proper case' as Issue, NULL from gis.AKR_ASSET_PT_evw where  len(ASSETNAME) > 10 AND (ASSETNAME = upper(ASSETNAME) Collate Latin1_General_CS_AI or ASSETNAME = lower(ASSETNAME) Collate Latin1_General_CS_AI)
union all
-- 10) ASSETALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: MAPLABEL must use proper case' as Issue, NULL from gis.AKR_ASSET_PT_evw where len(MAPLABEL) > 5 AND (MAPLABEL = upper(MAPLABEL) Collate Latin1_General_CS_AI or MAPLABEL = lower(MAPLABEL) Collate Latin1_General_CS_AI)
union all
-- 12) ASSETTYPE must be in DOM_ASSETTYPE.
select t1.OBJECTID, 'Error: ASSETTYPE is required' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
       where t1.ASSETTYPE is null or t1.ASSETTYPE = ''
union all 
select t1.OBJECTID, 'Error: ASSETTYPE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
       left join dbo.DOM_ASSETTYPE as t2 on t1.ASSETTYPE = t2.Code where t1.ASSETTYPE is not null and t1.ASSETTYPE <> '' and t2.Code is null
union all 
-- 13) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_PT_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_PT_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 14) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 15) MAINTAINER is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_PT_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_PT_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  dbo.FMSSExport as f on f.Location = a.Location where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.AKR_ASSET_PT_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 19) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_ASSET_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 18/19) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_ASSET_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 20) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.AKR_ASSET_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_PT_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 21) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 22) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_ASSET_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 23) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 24) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_ASSET_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 25) FACLOCID is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
-- 26) FACASSETID is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all
-- 27) ASSETCODE must be in DOM_ASSETCODE; if FACLOCID OR FACASSETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: ASSETCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
       left join dbo.DOM_ASSETCODE as t2 on t1.ASSETCODE = t2.Code where t1.ASSETCODE is not null and t1.ASSETCODE <> '' and t2.Code is null
union all 
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + FACLOCID + ' has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_PT_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_PT_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID 
  join dbo.FMSSExport as f on a.Location = f.Location
  where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
-- 28) ASSETTYPEOTHDESC is not required Unless ASSETTYPE = 'Other'.
--     If it provided is it should not be an empty string. This can be checked and fixed automatically; no need to alert the user.
select OBJECTID, 'Error: ASSETTYPEOTHDESC is required when ASSETTYPE is Other' as Issue, NULL from gis.AKR_ASSET_PT_evw
       where ASSETTYPE = 'Other' and (ASSETTYPEOTHDESC = '' or ASSETTYPEOTHDESC is null)
union all 
-- 29) ASSETDESC is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 30) ASSETMATERIAL is an optional domain value;
select t1.OBJECTID, 'Error: ASSETMATERIAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PT_evw as t1
       left join dbo.DOM_ASSETMATERIAL as t2 on t1.ASSETMATERIAL = t2.Code where t1.ASSETMATERIAL is not null and t1.ASSETMATERIAL <> '' and t2.Code is null
union all
-- 31) ASSETDIAMETER_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDIAMETER_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PT_evw where ASSETDIAMETER_FT < 0
union all
-- 32) ASSETLENGTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETLENGTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PT_evw where ASSETLENGTH_FT < 0
union all
-- 33) ASSETWIDTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETWIDTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PT_evw where ASSETWIDTH_FT < 0
union all
-- 34) ASSETDEPTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDEPTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PT_evw where ASSETDEPTH_FT < 0
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.AKR_ASSET_PT_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.AKR_ASSET_PT_evw where shape.STIsValid() = 0
-- Overlaps are possible (even exepcted among SITES)
-- Size checks are difficult because of variation in QTY units; May try later when trends are identified 

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_ASSET_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_ASSET_PY] AS select I.Issue, I.Details, D.* from  gis.AKR_ASSET_PY_evw AS D
join (

-------------------------
-- gis.AKR_ASSET_PY
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POLYGONTYPE must be an recognized value; if it is null/empty, then it will default to 'Circumscribed polygon' without a warning
select t1.OBJECTID, 'Error: POLYGONTYPE is not a recognized value' as Issue, NULL as Details from gis.AKR_ASSET_PY_evw as t1
  left join dbo.DOM_POLYGONTYPE as t2 on t1.POLYGONTYPE = t2.Code where t1.POLYGONTYPE is not null and t1.POLYGONTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.AKR_ASSET_PY_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.AKR_ASSET_PY_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_PY_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_ASSET_PY_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
select OBJECTID, 'Error: Features with the same FEATUREID are not close to each other' as Issue, 'FEATUREID = ''' + FEATUREID + '''' as Details
  from gis.AKR_ASSET_PY_evw where featureid in 
  (select FEATUREID from gis.AKR_ASSET_PY_evw group by FEATUREID having count(*) > 1 and
   geometry::ConvexHullAggregate(Shape).STArea()/geometry::CollectionAggregate(Shape).STArea() > 10)
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_ASSET_PY_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_ASSET_PY_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) ASSETNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: ASSETNAME must use proper case' as Issue, NULL from gis.AKR_ASSET_PY_evw where  len(ASSETNAME) > 5 AND (ASSETNAME = upper(ASSETNAME) Collate Latin1_General_CS_AI or ASSETNAME = lower(ASSETNAME) Collate Latin1_General_CS_AI)
union all
-- 10) ASSETALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: MAPLABEL must use proper case' as Issue, NULL from gis.AKR_ASSET_PY_evw where len(MAPLABEL) > 5 AND (MAPLABEL = upper(MAPLABEL) Collate Latin1_General_CS_AI or MAPLABEL = lower(MAPLABEL) Collate Latin1_General_CS_AI)
union all
-- 12) ASSETTYPE must be in DOM_ASSETTYPE.
select t1.OBJECTID, 'Error: ASSETTYPE is required' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
       where t1.ASSETTYPE is null or t1.ASSETTYPE = ''
union all 
select t1.OBJECTID, 'Error: ASSETTYPE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
       left join dbo.DOM_ASSETTYPE as t2 on t1.ASSETTYPE = t2.Code where t1.ASSETTYPE is not null and t1.ASSETTYPE <> '' and t2.Code is null
union all 
-- 13) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_PY_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_ASSET_PY_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 14) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 15) MAINTAINER is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_PY_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_ASSET_PY_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  dbo.FMSSExport as f on f.Location = a.Location where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.AKR_ASSET_PY_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 19) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_ASSET_PY_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 18/19) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_ASSET_PY_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 20) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.AKR_ASSET_PY_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_PY_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ASSET_PY_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 21) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 22) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_ASSET_PY_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 23) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 24) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_ASSET_PY_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 25) FACLOCID is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue, NULL from gis.AKR_ASSET_PY_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.AKR_ASSET_PY_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 26) FACASSETID is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue, NULL from gis.AKR_ASSET_PY_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.AKR_ASSET_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- 27) ASSETCODE must be in DOM_ASSETCODE; if FACLOCID OR FACASSETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: ASSETCODE is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
       left join dbo.DOM_ASSETCODE as t2 on t1.ASSETCODE = t2.Code where t1.ASSETCODE is not null and t1.ASSETCODE <> '' and t2.Code is null
union all 
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + FACLOCID + ' has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_PY_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> '' 
union all
select p.OBJECTID, 'Error: ASSETCODE does not match FMSS.ASSET_CODE' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has ASSET_CODE = ' + f.Asset_Code + ' when GIS has ASSETCODE = ' + p.ASSETCODE as Details
  from gis.AKR_ASSET_PY_evw as p
  join dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID 
  join dbo.FMSSExport as f on a.Location = f.Location
  where f.ASSET_CODE <> p.ASSETCODE and p.ASSETCODE <> ''
union all
-- 28) ASSETTYPEOTHDESC is not required Unless ASSETTYPE = 'Other'.
--     If it provided is it should not be an empty string. This can be checked and fixed automatically; no need to alert the user.
select OBJECTID, 'Error: ASSETTYPEOTHDESC is required when ASSETTYPE is Other' as Issue, NULL from gis.AKR_ASSET_PY_evw
       where ASSETTYPE = 'Other' and (ASSETTYPEOTHDESC = '' or ASSETTYPEOTHDESC is null)
union all 
-- 29) ASSETDESC is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 30) ASSETMATERIAL is an optional domain value;
select t1.OBJECTID, 'Error: ASSETMATERIAL is not a recognized value' as Issue, NULL from gis.AKR_ASSET_PY_evw as t1
       left join dbo.DOM_ASSETMATERIAL as t2 on t1.ASSETMATERIAL = t2.Code where t1.ASSETMATERIAL is not null and t1.ASSETMATERIAL <> '' and t2.Code is null
union all
-- 31) ASSETDIAMETER_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDIAMETER_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PY_evw where ASSETDIAMETER_FT < 0
union all
-- 32) ASSETLENGTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETLENGTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PY_evw where ASSETLENGTH_FT < 0
union all
-- 33) ASSETWIDTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETWIDTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PY_evw where ASSETWIDTH_FT < 0
union all
-- 34) ASSETDEPTH_FT is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: ASSETDEPTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ASSET_PY_evw where ASSETDEPTH_FT < 0
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.AKR_ASSET_PY_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.AKR_ASSET_PY_evw where shape.STIsValid() = 0
-- Overlaps are possible (even exepcted among SITES)
-- Size checks are difficult because of variation in QTY units; May try later when trends are identified 

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_ASSET_PY'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_ATTACH] AS select I.Issue, I.Details, D.* from  gis.AKR_ATTACH_evw AS D
join (

-----------------
-- gis.AKR_ATTACH
-----------------

-- 1) OBJECTID: managed by ArcGIS no QC required
-- 2) ATCHNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: ATCHNAME must use proper case' as Issue, NULL as Details from gis.AKR_ATTACH_evw where ATCHNAME = upper(ATCHNAME) Collate Latin1_General_CS_AI or ATCHNAME = lower(ATCHNAME) Collate Latin1_General_CS_AI
union all
-- 3) ATCHALTNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 4) MAPLABEL is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 5) ATCHTYPE is a required domain value; default is 'Photo'
select OBJECTID, 'Warning: ATCHTYPE is not provided, default value of *Photo* will be used' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHTYPE is null or ATCHTYPE = ''
union all
select t1.OBJECTID, 'Error: ATCHTYPE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_evw as t1
  left join dbo.DOM_ATCHTYPE as t2 on t1.ATCHTYPE = t2.code where t1.ATCHTYPE is not null and t1.ATCHTYPE <> '' and t2.code is null
union all
-- 6) ATCHLINK is required free text; The link should usually be unique, however there are occasions where the same attachment(photo) is
--    is added multiple times, once for each facility (foreign key) in the photo.
select OBJECTID, 'Error: ATCHLINK is not provided' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHLINK is null or ATCHLINK = ''
union all
select OBJECTID, 'Error: ATCHLINK is not unique' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHLINK in
       (select ATCHLINK from gis.AKR_ATTACH_evw where ATCHLINK is not null and ATCHLINK <> '' group by ATCHLINK, FACLOCID, FACASSETID, FEATUREID having count(*) > 1)
union all
-- 7) ATCHDATE is a required date; data type is guaranteed by database.  Check for null, and invalid values (after now or before 1995)
select OBJECTID, 'Error: ATCHDATE is not provided' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHDATE is null
union all
select OBJECTID, 'Warning: ATCHDATE is unexpectedly old (before 2000)' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHDATE < convert(Datetime2,'2000')
union all
select OBJECTID, 'Error: ATCHDATE is in the future' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHDATE > GETDATE()
union all
-- 8) ATCHSOURCE is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) ATCHDESC is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 10) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_ATTACH_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 11) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_ATTACH_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 10/11) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_ATTACH
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 12) UNITCODE is a required domain value.  Since this is not a spatial table, UNITCODE cannot be infered from the location
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select OBJECTID, 'Error: UNITCODE is required' as Issue, NULL from gis.AKR_ATTACH_evw where UNITCODE is null or UNITCODE = ''
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
/*
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_evw as t1 left join
  gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
union all
*/
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
-- 13) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ATTACH_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
/*
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ATTACH_evw as t1 join
  gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
union all
*/
-- 14) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_ATTACH_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- 15) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ATTACH_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 16) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_ATTACH_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 17) CREATEDATE: managed by ArcGIS no QC required
-- 18) CREATEUSER: managed by ArcGIS no QC required
-- 19) EDITDATE: managed by ArcGIS no QC required
-- 20) EDITUSER: managed by ArcGIS no QC required
-- 21) FACLOCID is optional free text, but if provided it must match a Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_ATTACH_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Location is null
union all
-- 22) FACASSETID is optional free text, but if provided it must match an Asset in the FMSS Assets Export
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_ATTACH_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t2.Asset is null
union all
-- 23) FEATUREID must be well-formed or null
--    TODO: if provided it should (warning) match a FEATUREID in one of the other spatial tables (including archives)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_ATTACH_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 24) GEOMETRYID must be well-formed or null
--    TODO: if provided it should (warning) match a GEOMETRYID in one of the other spatial tables (including archives)
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_ATTACH_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 21-24) Foreign key checks: Check for no or multiple foreign keys
/*
select OBJECTID, 'Warning: No foreign key, attachment will not be linked to a feature' as Issue, NULL
  from gis.AKR_ATTACH_evw where FACASSETID is null and FACLOCID is null and FEATUREID is null and GEOMETRYID is null and ATCHNAME not like 'Photo of GPS%'
union all
*/
/*
select OBJECTID, 'Warning: Multiple foreign keys may indicate an error' as Issue, NULL from gis.AKR_ATTACH_evw where 
  (FACASSETID is not null and not (FACLOCID is null and FEATUREID is null and GEOMETRYID is null)) or
  (FACLOCID is not null and not (FACASSETID is null and FEATUREID is null and GEOMETRYID is null)) or
  (FEATUREID is not null and not (FACLOCID is null and FACASSETID is null and GEOMETRYID is null)) or
  (GEOMETRYID is not null and not (FACLOCID is null and FEATUREID is null and FACASSETID is null))
union all
*/ 
-- 25) ATCHID must be unique and well-formed or null (in which case a unique GUID will be generated)
select OBJECTID, 'Error: ATCHID is not unique' as Issue, NULL from gis.AKR_ATTACH_evw where ATCHID in
       (select ATCHID from gis.AKR_ATTACH_evw where ATCHID is not null and ATCHID <> '' group by ATCHID having count(*) > 1)
union all
select OBJECTID, 'Error: ATCHID is not well-formed' as Issue, NULL
	from gis.AKR_ATTACH_evw where
	  -- Will ignore ATCHID = NULL 
	  len(ATCHID) <> 38 
	  OR left(ATCHID,1) <> '{'
	  OR right(ATCHID,1) <> '}'
	  OR ATCHID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
-- 26) NOTES is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 27) WEBEDITUSER: nothing to check; will likely be deleted
-- 28) WEBCOMMENT: nothing to check; will likely be deleted

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_ATTACH'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_ATTACH_PT] AS select I.Issue, I.Details, D.* from  gis.AKR_ATTACH_PT_evw  AS D
join (

--------------------
-- gis.AKR_ATTACH_PT_evw 
--------------------

-- 1) OBJECTID: managed by ArcGIS no QC required
-- 2) ATCHNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: ATCHNAME must use proper case' as Issue, NULL as Details from gis.AKR_ATTACH_PT_evw  where ATCHNAME = upper(ATCHNAME) Collate Latin1_General_CS_AI or ATCHNAME = lower(ATCHNAME) Collate Latin1_General_CS_AI
union all
-- 3) ATCHALTNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 4) MAPLABEL is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 5) ATCHTYPE is a required domain value; default is 'Photo'
select OBJECTID, 'Warning: ATCHTYPE is not provided, default value of *Photo* will be used' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where ATCHTYPE is null or ATCHTYPE = ''
union all
select t1.OBJECTID, 'Error: ATCHTYPE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
  left join dbo.DOM_ATCHTYPE as t2 on t1.ATCHTYPE = t2.code where t1.ATCHTYPE is not null and t1.ATCHTYPE <> '' and t2.code is null
union all
-- 6) ATCHLINK is required free text; Since each feature is a unique attachment (photo), there should be no duplicate (urls)
select OBJECTID, 'Error: ATCHLINK is not provided' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where ATCHLINK is null or ATCHLINK = ''
union all
select OBJECTID, 'Error: ATCHLINK is not unique' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where ATCHLINK in
       (select ATCHLINK from gis.AKR_ATTACH_PT_evw  where ATCHLINK is not null and ATCHLINK <> '' group by ATCHLINK having count(*) > 1)
union all
-- 7) ATCHDATE is a required date; data type is guaranteed by database.  Check for null, and invalid values (after now or before 1995)
select OBJECTID, 'Error: ATCHDATE is not provided' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where ATCHDATE is null
union all
select OBJECTID, 'Warning: ATCHDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where ATCHDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: ATCHDATE is in the future' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where ATCHDATE > GETDATE()
union all
-- 8) ATCHSOURCE is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) ATCHDESC is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 10) POINTTYPE must be 'Arbitrary point' (if NULL or '' assumed to be 'Arbitrary point' - no warning)
select OBJECTID, 'Error: POINTTYPE is not a Arbitrary point' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where POINTTYPE is not null and POINTTYPE <> '' and POINTTYPE <> 'Arbitrary point'
union all
-- 11) ISOUTPARK: This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check

-- 12) HEADING: This is an optional number < 360 and >= 0
select OBJECTID, 'Error: HEADING is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where HEADING < 0
union all
select OBJECTID, 'Error: HEADING is not allowed to be 360 or larger'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where HEADING >= 360
union all
-- 13) HFOV: This is an optional number <= 360 and > 0; if zero it is silently converted to NULL
select OBJECTID, 'Error: HFOV is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where HFOV < 0
union all
select OBJECTID, 'Error: HFOV is not allowed to be 360 or larger'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where HFOV >= 360
union all
-- 14) PITCH: This is an optional number <= 90 and >= -90
select OBJECTID, 'Error: PITCH is not allowed to be less than -90'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where PITCH < -90
union all
select OBJECTID, 'Error: PITCH is not allowed to greater than 90'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where PITCH > 90
union all
-- 15) VFOV: This is an optional number <= 360 and > 0; if zero it is silently converted to NULL
select OBJECTID, 'Error: VFOV is not allowed to be a negative number'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where VFOV < 0
union all
select OBJECTID, 'Error: VFOV is not allowed to be 360 or larger'  as Issue, NULL from gis.AKR_ATTACH_PT_evw  where VFOV >= 360
union all
-- 16) ALTITUDE: This must be null (will be derived from the shape) or match the shape
select OBJECTID, 'Error: ALTITUDE must match the Z value of the shape'  as Issue, 
       'SHAPE.Z = ' + ltrim(str(shape.Z, 15,9)) + ' while ALTITUDE = ' + ltrim(str(ALTITUDE, 15,9)) as Details
	   from gis.AKR_ATTACH_PT_evw  where shape.Z <> 0 and ABS(shape.Z - Altitude) > 0.0000001
union all
-- 17) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 18) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 17/18) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_ATTACH_PT_evw 
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 19) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.AKR_ATTACH_PT_evw  as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue,
  'Location ' + FACLOCID + ' has Park ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_ATTACH_PT_evw  as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 20) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 21) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_ATTACH_PT_evw  as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 22) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 23) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 24) CREATEDATE: managed by ArcGIS no QC required
-- 25) CREATEUSER: managed by ArcGIS no QC required
-- 26) EDITDATE: managed by ArcGIS no QC required
-- 27) EDITUSER: managed by ArcGIS no QC required
-- 28) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 29) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 30) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where SOURCEDATE > GETDATE()
union all
-- 31) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 32) FACLOCID is optional free text, but if provided it must match a Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Location is null
union all
-- 33) FACASSETID is optional free text, but if provided it must match an Asset in the FMSS Assets Export
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_ATTACH_PT_evw  as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t2.Asset is null
union all
-- 34) FEATUREID must be well-formed or null
--    TODO: if provided it should (warning) match a FEATUREID in one of the other spatial tables (including archives)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_ATTACH_PT_evw  where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 35) GEOMETRYID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where GEOMETRYID in
       (select GEOMETRYID from gis.AKR_ATTACH_PT_evw  where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_ATTACH_PT_evw  where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 36) NOTES is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 37) WEBEDITUSER: nothing to check; will likely be deleted
-- 38) WEBCOMMENT: nothing to check; will likely be deleted
-- 39) SHAPE: must not be empty
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.AKR_ATTACH_PT_evw  where shape.STIsEmpty() = 1

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_ATTACH_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_AKR_BLDG_CENTER_PT] AS select I.Issue, I.Details, D.* from  gis.AKR_BLDG_CENTER_PT_evw AS D
join (

-------------------------
-- gis.AKR_BLDG_CENTER_PT
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be 'Center point' (if NULL assumed to be 'Center point' - no warning)
--    even if the "Center point" is actually arbitrary, or derived, there must be one and only one
--    identified as the 'Center point' as required by the building data standard
select OBJECTID, 'Error: POINTTYPE is not a Center point' as Issue, NULL as Details from gis.AKR_BLDG_CENTER_PT_evw where POINTTYPE is not null and POINTTYPE <> '' and POINTTYPE <> 'Center point'
union all 
-- 2) GEOMETRYID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where GEOMETRYID in
       (select GEOMETRYID from gis.AKR_BLDG_CENTER_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_BLDG_CENTER_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: FEATUREID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where FEATUREID in
       (select FEATUREID from gis.AKR_BLDG_CENTER_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_BLDG_CENTER_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) BLDGNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: BLDGNAME must use proper case' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where BLDGNAME = upper(BLDGNAME) Collate Latin1_General_CS_AI or BLDGNAME = lower(BLDGNAME) Collate Latin1_General_CS_AI
union all
-- 10) BLDGALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) BLDGSTATUS is required and must be in domain; default is a valid FMSS value or Existing;
--     Additional AKR Constraint: BLDGSTATUS must match valid value in FMSS Lookup.
--     TODO: discuss this additional AKR Constraint
select p.OBJECTID, 'Warning: BLDGSTATUS is not provided, default value of *Existing* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as p
  left join (SELECT Status, Location FROM dbo.FMSSExport where Status in (select Code from dbo.DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where (BLDGSTATUS is null or BLDGSTATUS = '') and f.Status is null
union all
select t1.OBJECTID, 'Error: BLDGSTATUS is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGSTATUS as t2 on t1.BLDGSTATUS = t2.Code where BLDGSTATUS is not null and BLDGSTATUS <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: BLDGSTATUS does not match the FMSS Status' as Issue,
    'Location ' + FACLOCID + ' has Status ' + t2.Status + ' (' + t3.Standard + ') when GIS has BLDGSTATUS = ' + t1.BLDGSTATUS as Details
    from gis.AKR_BLDG_CENTER_PT_evw as t1
    join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
    join dbo.DOM_FMSS_Status as t3 on t3.Code = t2.Status
    join dbo.DOM_BLDGSTATUS as t4 on t3.Standard = t4.Code where t1.BLDGSTATUS <> t4.Code
    and (t1.BLDGSTATUS <> 'Temporarily Closed' or t2.Status <> 'OPERATING') -- Ignore (not an error) Temporarily Closed could mean OPERATING
    and (t1.BLDGSTATUS <> 'Temporarily Closed' or t2.Status <> 'INACTIVE') -- Ignore (not an error) Temporarily Closed could mean INACTIVE
union all
-- 13) BLDGCODE is an optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: BLDGCODE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGCODETYPE as t2 on t1.BLDGCODE = t2.Code where t1.BLDGCODE is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: BLDGCODE does not match FMSS.DOI_Code' as Issue,
  'Location ' + FACLOCID + ' has DOI_Code ' + f.DOI_Code + ' (' + d.Type + ') when GIS has BLDGCODE = ' + p.BLDGCODE + ' (' + p.BLDGTYPE + ')' as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p
  join dbo.FMSSExport as f on f.Location = p.FACLOCID
  join dbo.DOM_BLDGCODETYPE as d on f.DOI_Code = d.Code
  where p.BLDGCODE <> f.DOI_Code
union all
-- 14) BLDGTYPE is an optional domain value
select t1.OBJECTID, 'Error: BLDGTYPE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGCODETYPE as t2 on t1.BLDGTYPE = t2.Type where t1.BLDGTYPE is not null and t2.Type is null
union all
-- 13/14) BLDGCODE and BLDGTYPE are related; if one is null and not the other, null is populated with lookup
--     if BLDGCODE is null but gets set later by BLDGTYPE (not null and valid), then we should compare that value with FMSS
select t1.OBJECTID, 'Error: BLDGCODE does not match BLDGTYPE' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_BLDGCODETYPE as t2 on t1.BLDGCODE = t2.Code left join dbo.DOM_BLDGCODETYPE as t3 on t1.BLDGTYPE = t3.Type
	   where (t1.BLDGTYPE <> t2.Type and t3.Type is not null)
	      or (t1.BLDGCODE <> t3.Code and t2.Code is not null)
union all
select p.OBJECTID, 'Error: BLDGTYPE does not match type related to FMSS.DOI_Code' as Issue,
  'Location ' + FACLOCID + ' has DOI_Code ' + f.DOI_Code + ' when GIS has BLDGTYPE = ' + p.BLDGTYPE as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT DOI_Code, Location FROM dbo.FMSSExport where DOI_Code in (select Code from dbo.DOM_BLDGCODETYPE)) as f on f.Location = p.FACLOCID 
  join dbo.DOM_BLDGCODETYPE as d on p.BLDGTYPE = d.Type where p.BLDGCODE is null and d.Code <> f.DOI_Code
union all
-- 15) FACOWNER is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACOWNER is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACOWNER as t2 on t1.FACOWNER = t2.Code where t1.FACOWNER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACOWNER does not match FMSS.Asset_Ownership' as Issue,
  'Location ' + FACLOCID + ' has Asset_Ownership ' + f.Asset_Ownership + ' when GIS has FACOWNER = ' + p.FACOWNER as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Asset_Ownership, Location FROM dbo.FMSSExport where Asset_Ownership in (select Code from dbo.DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership
union all
-- 16) FACOCCUPANT is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACOCCUPANT is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACOCCUMAINT as t2 on t1.FACOCCUPANT = t2.Code where t1.FACOCCUPANT is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACOCCUPANT does not match FMSS.Occupant' as Issue,
  'Location ' + FACLOCID + ' has Occupant ' + f.Occupant + ' when GIS has FACOCCUPANT = ' + p.FACOCCUPANT as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Occupant, Location FROM dbo.FMSSExport where Occupant in (select Code from dbo.DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant
union all
-- 17) FACMAINTAIN is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACMAINTAIN is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACOCCUMAINT as t2 on t1.FACMAINTAIN = t2.Code where t1.FACMAINTAIN is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACMAINTAIN does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP ' + f.FAMARESP + ' when GIS has FACMAINTAIN = ' + p.FACMAINTAIN as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP
union all
-- 18) FACUSE is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: FACUSE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_FACUSE as t2 on t1.FACUSE = t2.Code where FACUSE is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: FACUSE does not match FMSS.PRIMUSE' as Issue,
  'Location ' + FACLOCID + ' has PRIMUSE ' + f.PRIMUSE + ' when GIS has FACUSE = ' + p.FACUSE as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT PRIMUSE, Location FROM dbo.FMSSExport where PRIMUSE in (select Code from dbo.DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE
union all
-- 19) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS ' + f.OPSEAS + ' when GIS has SEASONAL = ' + p.SEASONAL as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 20) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 21) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 12/21 ISEXTANT must align with BLDGSTATUS.
-- Extant       => Status
-- True or NULL => All status are valid (i.e. status indicates occupancy)
-- False        => not Existing or Temp Closed (must be decom/aban, prop, or planned)
-- Unknown      => ?? can't enforce anything on status
-- Partial      => same as existing
-- Other        => ?? can't enforce anything on status (ignore this should be removed)
-- *            => Error (in different check)

-- Status     => Extant
-- Existing   => must be True or Partial or NULL (=True) cannot be False, Unknown (what about Other)
-- NULL, '',  => see FMSS or Existing
-- Decom/Aban => any are valid
-- Plan/Prop  => any are valid
-- Closed     => must be True or NULL (=True)
-- Unknown    => ?? can't enforce anything on Extant
-- *          => Error (in different check)

-- Summary: if Extant = False then Status = Exist or Closed is an error
--          equivalently if Status = Existing or Closed then Extant = False is an error (seems unknown should also be an error)
--          Status Planned/Proposed and Extant = True is suspect; maybe issue a warning
select t1.OBJECTID, 'Error: ISEXTANT does not match BLDGSTATUS' as Issue,
  'ISEXTANT = ' + ISNULL(t1.ISEXTANT, 'True') + ' while BLDGSTATUS = ' + ISNULL(t1.BLDGSTATUS, 'NULL') + '(FMSS Status is ' + ISNULL(d.Standard, 'NULL') + ')' as Details
  from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.FMSSExport as f on f.Location = t1.FACLOCID
  left join dbo.DOM_FMSS_Status as d on f.Status = d.Code  -- Use d.Standard (= the standardized version of the FMSS Status, could be NULL)
  where t1.ISEXTANT = 'False' and (t1.BLDGSTATUS = 'Existing' or t1.BLDGSTATUS = 'Temporarily Closed' or ((t1.BLDGSTATUS is null or t1.BLDGSTATUS = '') and (d.Standard is null or d.Standard = 'Existing')))
union all
-- 22) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. BLDGSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE) when PUBLICDISPLAY is true?
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 23) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 22/23) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 24) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.AKR_BLDG_CENTER_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue,
  'Location ' + FACLOCID + ' has Park ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 25) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 26) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_BLDG_CENTER_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 27) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 28) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 29) FACLOCID is optional free text, but if provided it must be unique and match a *Building* Location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID is not a Building (4100) asset' as Issue,
  'Location ' + FACLOCID + ' has an Asset Code of ' + t2.Asset_Code + ' (' + t3.Description + ')' as Details
  from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as t3 on t2.Asset_Code = t3.Code
  where t2.Asset_Code <> '4100'
union all
select t1.OBJECTID, 'Error: FACLOCID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FACLOCID from gis.AKR_BLDG_CENTER_PT_evw where FACLOCID is not null and FACLOCID <> '' group by FACLOCID having count(*) > 1) as t2 on t1.FACLOCID = t2.FACLOCID
union all
-- 30) FACASSETID is optional free text, but if provided it must be unique and match an ID in the FMSS Assets Export
select t1.OBJECTID, 'Error: FACASSETID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FACASSETID from gis.AKR_BLDG_CENTER_PT_evw where FACASSETID is not null and FACASSETID <> '' group by FACASSETID having count(*) > 1) as t2 on t1.FACASSETID = t2.FACASSETID
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue,
  'FACASSETID ' + t1.FACASSETID + ' has an Location of ' + t3.Location +  ' when GIS has FACLOCID = ' + t1.FACLOCID as Details
  from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a Building (4100) asset in FMSS' as Issue,
  'FACASSETID ' + FACASSETID + ' has an Asset Code of ' + t3.Asset_Code + ' (' + t4.Description + ')' as Details
  from gis.AKR_BLDG_CENTER_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location join DOM_FMSS_ASSETCODE as t4 on t3.Asset_Code = t4.Code
  where (t1.FACLOCID is null or t1.FACLOCID = t3.Location) and t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code <> '4100'
union all
-- 31) CRID is optional free text, but if provided it must be unique and match an CR_ID in the Cultural Resource Database
--     TODO:  Get a link to the Cultural Resource Database and compare
select t1.OBJECTID, 'Error: CRID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select CRID from gis.AKR_BLDG_CENTER_PT_evw where CRID is not null and CRID <> '' group by CRID having count(*) > 1) as t2 on t1.CRID = t2.CRID
union all
-- 32) ASMISID is optional free text, but if provided it must be unique and match an ID in Archeological Sites Management Information System
--     TODO:  Get export from ASMIS and compare
select t1.OBJECTID, 'Error: ASMISID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select ASMISID from gis.AKR_BLDG_CENTER_PT_evw where ASMISID is not null and ASMISID <> '' group by ASMISID having count(*) > 1) as t2 on t1.ASMISID = t2.ASMISID
union all
-- 33) CLIID is optional free text, but if provided it must be unique and match an ID in the Cultural Landscape Inventory and a valid value in FMSS Lookup.
--     TODO:  Get export from CLI and compare
select t1.OBJECTID, 'Error: CLIID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select CLIID from gis.AKR_BLDG_CENTER_PT_evw where CLIID is not null and CLIID <> '' group by CLIID having count(*) > 1) as t2 on t1.CLIID = t2.CLIID
union all
select p.OBJECTID, 'Error: CLIID does not match FMSS.CLINO' as Issue,
  'Location ' + FACLOCID + ' has CLINO ' + f.CLINO + ' when GIS has CLIID = ' + p.CLIID as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (select CLINO, Location FROM dbo.FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where p.CLIID <> f.CLINO
union all
-- 34) LCSID is optional free text, but if provided it must be unique and match an ID in the List of Classified Structures and a valid value in FMSS Lookup.
--     TODO:  Get export from LCS and compare
select t1.OBJECTID, 'Error: LCSID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select LCSID from gis.AKR_BLDG_CENTER_PT_evw where LCSID is not null and LCSID <> '' group by LCSID having count(*) > 1) as t2 on t1.LCSID = t2.LCSID
union all
select p.OBJECTID, 'Error: LCSID does not match FMSS.CLASSSTR' as Issue,
  'Location ' + FACLOCID + ' has CLASSSTR ' + f.CLASSSTR + ' when GIS has LCSID = ' + p.LCSID as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (select CLASSSTR, Location FROM dbo.FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR
union all
-- 35) FIREBLDGID is optional free text, but if provided it must be unique and match an ID in the National Fire Database for Buildings
--     TODO:  Get export from FIREBLDG and compare
select t1.OBJECTID, 'Error: FIREBLDGID is not unique' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select FIREBLDGID from gis.AKR_BLDG_CENTER_PT_evw where FIREBLDGID is not null and FIREBLDGID <> '' group by FIREBLDGID having count(*) > 1) as t2 on t1.FIREBLDGID = t2.FIREBLDGID
union all
-- 36) PARKBLDGID is optional free text, but if provided it should be unique in a unit and match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: PARKBLDGID is not unique in the unit' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1 join
       (select PARKBLDGID, UNITCODE from gis.AKR_BLDG_CENTER_PT_evw where PARKBLDGID is not null and PARKBLDGID <> '' group by PARKBLDGID, UNITCODE having count(*) > 1) as t2
	    on t1.PARKBLDGID = t2.PARKBLDGID and t1.UNITCODE = t2.UNITCODE
union all
select p.OBJECTID, 'Error: PARKBLDGID does not match FMSS.PARKNUMB' as Issue,
  'Location ' + FACLOCID + ' has PARKNUMB ' + f.PARKNUMB + ' when GIS has PARKBLDGID = ' + p.PARKBLDGID as Details
  from gis.AKR_BLDG_CENTER_PT_evw as p join 
  (SELECT PARKNUMB, Location FROM dbo.FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB
-- 37) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 38) SHAPE
union all
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw where shape.STIsEmpty() = 1
union all
select c.OBJECTID, 'Error: SHAPE must be within the footprint' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as c
  join gis.AKR_BLDG_FOOTPRINT_PY_evw as f on c.FEATUREID = f.FEATUREID
  where c.Shape.STWithin(f.Shape) <> 1
union all

-- POITYPE
--    Can be null (but not empty - will be converted to a null in calcs)
--    If provided (and not empty), must be in akr_socio.gis.DOM_POICONTAINER_POITYPE_ALTNAMES
select t1.OBJECTID, 'Error: POITYPE is not a recognized value' as Issue, NULL from gis.AKR_BLDG_CENTER_PT_evw as t1
       left join akr_socio.gis.DOM_POICONTAINER_POITYPE_ALTNAMES as t2 on t1.POITYPE = t2.Code where t1.POITYPE is not null and t1.POITYPE <> '' and t2.Code is null



-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????


-- Related table check.
-- A building center point with a non null POITYPE should be replicated in the POI_PT table
union all
select b.OBJECTID, 'Error: Building center point with a POITYPE is not in POI_PT' as Issue, NULL as Details
from akr_socio.gis.akr_POI_PT_evw as p right join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID where b.POITYPE is not null and p.SRCDBIDVAL is null



) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_CENTER_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
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
---------------
-- Shape Checks
---------------
union all
select OBJECTID, 'Error: SHAPE must not be empty' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue from gis.AKR_BLDG_FOOTPRINT_PY_evw where shape.STIsValid() = 0
-- Sum of Areas grouped by faclocid should be close to Area FMSS.QTY (in SquareFeet)
-- TODO: Reassess this query
-- There are a lot of issues: 1) GIS SF is based on roof edge; not interior size; 2) GIS does not know about multiple floors; 3) footprint from GPS maybe a rectangular approximation.
/*
union all
select oid, 'Error: Building Area in GIS is more than 20% different from FMSS' as Issue,
  'Location ' + FACLOCID + ' is ' + convert(nvarchar(200),t1.sf) + ' SF in GIS, but ' + convert(nvarchar(200),t2.sf) + ' SF in FMSS (' + convert(nvarchar(200),100*(t1.sf - t2.sf)/ t2.sf) + '%)' as Details
  from (select min(f.objectid) as oid, c.FACLOCID, sum(GEOGRAPHY::STGeomFromText(f.shape.STAsText(),4269).STArea()) * 3.28084 * 3.28084 as sf from gis.AKR_BLDG_FOOTPRINT_PY_evw as f 
        join gis.AKR_BLDG_CENTER_PT_evw as c on c.FEATUREID = f.FEATUREID where c.faclocid is not null group by c.FACLOCID) as t1
  join (select Location, convert(real, replace(Qty,',','')) as sf from FMSSExport where UM = 'GSF') as t2 on t1.FACLOCID = t2.Location
  where abs(t1.sf - t2.sf)/ t2.sf > 0.2
*/


-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_FOOTPRINT_PY'
WHERE E.Explanation IS NULL or E.Explanation = ''
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
-- 9) SHAPE
union all
select OBJECTID, 'Error: SHAPE must not be empty' as Issue from gis.AKR_BLDG_OTHER_PT_evw where shape.STIsEmpty() = 1
union all
select o.OBJECTID, 'Error: SHAPE must be within 25m of centroid' as Issue from gis.AKR_BLDG_OTHER_PT_evw as o
  join gis.AKR_BLDG_CENTER_PT_evw as c on c.FEATUREID = o.FEATUREID
  where GEOGRAPHY::STGeomFromText(o.shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText(c.shape.STAsText(),4269)) > 25

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_OTHER_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
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
---------------
-- Shape Checks
---------------
union all
select OBJECTID, 'Error: SHAPE must not be empty' as Issue from gis.AKR_BLDG_OTHER_PY_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue from gis.AKR_BLDG_OTHER_PY_evw where shape.STIsValid() = 0

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'AKR_BLDG_OTHER_PY'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_PARKLOTS_PY] AS select I.Issue, I.Details, D.* from  gis.PARKLOTS_PY_evw AS D
join (

-------------------------
-- gis.PARKLOTS_PY
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POLYGONTYPE must be an recognized value; if it is null/empty, then it will default to 'Circumscribed polygon' without a warning
select t1.OBJECTID, 'Error: POLYGONTYPE is not a recognized value' as Issue, NULL as Details from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_POLYGONTYPE as t2 on t1.POLYGONTYPE = t2.Code where t1.POLYGONTYPE is not null and t1.POLYGONTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.PARKLOTS_PY_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.PARKLOTS_PY_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.PARKLOTS_PY_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--    All records with the same FeatureID must be proximal (in the vicinity of each other)
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.PARKLOTS_PY_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
select OBJECTID, 'Error: Features with the same FEATUREID are not close to each other' as Issue, 'FEATUREID = ''' + FEATUREID + '''' as Details
  from gis.PARKLOTS_PY_evw where featureid in 
  (select FEATUREID from gis.PARKLOTS_PY_evw group by FEATUREID having count(*) > 1 and
   geometry::ConvexHullAggregate(Shape).STArea()/geometry::CollectionAggregate(Shape).STArea() > 10)
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.PARKLOTS_PY_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.PARKLOTS_PY_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) LOTNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: LOTNAME must use proper case' as Issue, NULL from gis.PARKLOTS_PY_evw where LOTNAME = upper(LOTNAME) Collate Latin1_General_CS_AI or LOTNAME = lower(LOTNAME) Collate Latin1_General_CS_AI
union all
-- 10) LOTALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) LOTTYPE must be in DOM_LOTTYPE. If NULL (or empty string) it is assumed to be 'Parking Lot' - with no warning
select t1.OBJECTID, 'Error: LOTTYPE is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_LOTTYPE as t2 on t1.LOTTYPE = t2.Code where t1.LOTTYPE is not null and t1.LOTTYPE <> '' and t2.Code is null
union all 
-- 13) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.PARKLOTS_PY_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 14) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 15) MAINTAINER is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.PARKLOTS_PY_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 16) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 17) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 18) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.PARKLOTS_PY_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 19) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 18/19) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.PARKLOTS_PY_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 20) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.PARKLOTS_PY_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, NULL from gis.PARKLOTS_PY_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 21) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 22) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.PARKLOTS_PY_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 23) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 24) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.PARKLOTS_PY_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 25) FACLOCID is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Parking Area in FMSS' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Asset_Code <> '1300'
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue, NULL from gis.PARKLOTS_PY_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.PARKLOTS_PY_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 26) FACASSETID is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a Parking Area in FMSS' as Issue, NULL from gis.PARKLOTS_PY_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location  where (t1.FACLOCID is null or t1.FACLOCID = t3.Location) and t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code <> '1300'
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue, NULL from gis.PARKLOTS_PY_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- 27) LOTSTATUS is a required domain value; default is 'Existing'
select OBJECTID, 'Warning: LOTSTATUS is not provided, default value of *Existing* will be used' as Issue, NULL from gis.PARKLOTS_PY_evw where LOTSTATUS is null or LOTSTATUS = ''
union all
select t1.OBJECTID, 'Error: LOTSTATUS is not a recognized value' as Issue, NULL from gis.PARKLOTS_PY_evw as t1
       left join dbo.DOM_RDSTATUS as t2 on t1.LOTSTATUS = t2.Code where t1.LOTSTATUS is not null and t1.LOTSTATUS <> '' and t2.Code is null
union all 
select t1.OBJECTID, 'Error: LOTSTATUS does not match the FMSS Status' as Issue,
  'Location ' + FACLOCID + ' has Status ' + t2.Status + ' (' + t3.Standard + ') when GIS has LOTSTATUS = ' + t1.LOTSTATUS as Details
  from gis.PARKLOTS_PY_evw as t1
  join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  join dbo.DOM_FMSS_Status as t3 on t3.Code = t2.Status
  where t1.LOTSTATUS <> t3.Standard
  and (t1.LOTSTATUS <> 'Temporarily Closed' or t2.Status <> 'OPERATING') -- Ignore (not an error) Temporarily Closed could mean OPERATING
  and (t1.LOTSTATUS <> 'Temporarily Closed' or t2.Status <> 'INACTIVE') -- Ignore (not an error) Temporarily Closed could also mean INACTIVE
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.PARKLOTS_PY_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.PARKLOTS_PY_evw where shape.STIsValid() = 0
union all
select p1.OBJECTID, 'Error: Overlapping polygons are not allowed' as Issue, 'Overlaps with OBJECTID = ' + convert(nvarchar(20), p2.OBJECTID) as Details
from gis.PARKLOTS_PY_evw as p1 join gis.PARKLOTS_PY_evw as p2 on p1.shape.Filter(p2.shape) = 1 and p1.OBJECTID < p2.OBJECTID where p1.Shape.STOverlaps(p2.Shape) = 1
-- Sum of Areas grouped by faclocid should be close to Area FMSS.QTY (in SquareFeet)
-- TODO: Skip this check for now (there are significant errors that I don't have time to review/fix now)
-- One issue seems to be that GIS may only include the parking spaces, while FMSS may includes all the improved area (access road)
-- The issue may also be reversed
/*
union all
select oid, 'Error: Parking Area in GIS is more than 20% different from FMSS' as Issue,
  'Location ' + FACLOCID + ' is ' + convert(nvarchar(200),t1.sf) + ' SF in GIS, but ' + convert(nvarchar(200),t2.sf) + ' SF in FMSS (' + convert(nvarchar(200),100*(t1.sf - t2.sf)/ t2.sf) + '%)' as Details
  from (select min(objectid) as oid, FACLOCID, sum(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STArea()) * 3.28084 * 3.28084 as sf from gis.PARKLOTS_PY_evw where faclocid is not null group by FACLOCID) as t1
  join (select Location, convert(real, replace(Qty,',','')) as sf from FMSSExport where UM = 'SF') as t2 on t1.FACLOCID = t2.Location
  where abs(t1.sf - t2.sf)/ t2.sf > 0.2
  order by abs(t1.sf - t2.sf)
*/

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'PARKLOTS_PY'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_ROADS_FEATURE_PT] AS select I.Issue, I.Details, D.* from  gis.ROADS_FEATURE_PT_evw AS D
join (

-------------------------
-- gis.ROADS_FEATURE_PT
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue, NULL as Details from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.ROADS_FEATURE_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.ROADS_FEATURE_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
--    This is a primary key for each mapped feature, and not a foreign key to the "related" road.
select OBJECTID, 'Error: FEATUREID is not unique' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where FEATUREID in
       (select FEATUREID from gis.ROADS_FEATURE_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.ROADS_FEATURE_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) RDFEATNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: RDFEATNAME must use proper case' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where RDFEATNAME = upper(RDFEATNAME) Collate Latin1_General_CS_AI or RDFEATNAME = lower(RDFEATNAME) Collate Latin1_General_CS_AI
union all
-- 10) RDFEATALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) RDFEATTYPE must be non null and in DOM_RDFEATFEATTYPE.  Theres is no default value
select OBJECTID, 'Error: RDFEATTYPE is required' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where RDFEATTYPE is null
union all
select t1.OBJECTID, 'Error: RDFEATTYPE is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
       left join dbo.DOM_RDFEATFEATTYPE as t2 on t1.RDFEATTYPE = t2.Code where t1.RDFEATTYPE is not null and t1.RDFEATTYPE <> '' and t2.Code is null
union all
-- 13) RDFEATTYPEOTHER is optional free text unless RDFEATTYPE = 'Other'. If it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Note: if there are common values here they can be promoted to RDFEATTYPE
select OBJECTID, 'Error: RDFEATTYPEOTHER is required when RDFEATTYPE is Other' as Issue, NULL from gis.ROADS_FEATURE_PT_evw
       where RDFEATTYPE = 'Other' and (RDFEATTYPEOTHER is null or RDFEATTYPEOTHER = '')
union all
select OBJECTID, 'Warning: RDFEATTYPEOTHER will be cleared when RDFEATTYPE is not Other' as Issue, NULL from gis.ROADS_FEATURE_PT_evw
       where RDFEATTYPE <> 'Other' and RDFEATTYPEOTHER is not null and RDFEATTYPEOTHER <> ''
union all
-- 14) RDFEATSUBTYPE is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     TODO: do we want to make this a domain value that is sensitive to the RDFEATTYPE
-- 15) RDFEATDESC is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 16) RDFEATCOUNT is optional int, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: RDFEATCOUNT must be a poitive number' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where RDFEATCOUNT < 0
union all
-- 17) WHLENGTH is optional real, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: WHLENGTH must be a poitive number' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where WHLENGTH < 0
union all
-- 18) WHLENUOM is an optional domain value (DOM_UOM); if WHLENGTH is not null it must be not null;
--     if WHLENGTH is null, this field will be silently set to null.
select OBJECTID, 'Error: WHLENUOM is required when WHLENGTH is positive' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where (WHLENUOM is null or WHLENUOM = '') and WHLENGTH > 0
union all
select t1.OBJECTID, 'Error: WHLENUOM is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_UOM as t2 on t1.WHLENUOM = t2.code where t1.WHLENUOM is not null and t1.WHLENUOM <> '' and t2.code is null
union all
-- 19) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 20) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 21) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: Are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE, ??) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.ROADS_FEATURE_PT_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 22) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 21/22) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.ROADS_FEATURE_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 23) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.ROADS_FEATURE_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 24) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 25) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.ROADS_FEATURE_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 26) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 27) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 28) FACLOCID is optional free text, but if provided it must match a road Location in the FMSS Export
--     FACLOCID is a foreign key to the same feature in the FMSS location table.  Not many road features have
--     their own location records (like a bridge or wayside exhibit), so this is typically NULL.  FACLOCID is not used
--     to track the related "parent" road for this feature.
--     See SEGMENTID to get information about the road this feature is "on".
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
-- Check that FACLOCID is the appropriate type (Asset_code) for this type of road feature
-- if FACLOCID.Asset_Code = 2200 (road bridge), then RDFEATTYPE = Bridge
-- if FACLOCID.Asset_Code = 7%00, then RDFEATTYPE = 'Wayside Feature'
-- This list may need to be expanded as we develop the road features
-- TODO: Move "other" Asset codes, including 7%00 to a different feature class
select t1.OBJECTID, 'Error: FACLOCID is not approriate for this kind of road feature (based on the Asset Code)' as Issue,
  'RDFEATTYPE = ' + t1.RDFEATTYPE + ' but Asset Code for ' + t2.Location + ' = ' + t2.Asset_Code + ' (' + d.Description + ')' as Details
  from gis.ROADS_FEATURE_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  join DOM_FMSS_ASSETCODE as d on t2.Asset_Code = d.Code
  where (t2.Asset_Code = '1200' and not t1.RDFEATTYPE = 'Bridge')
     or (t2.Asset_Code like '7%00' and t1.RDFEATTYPE <> 'Wayside Feature')
union all
-- FACLOCID should be unique
select t1.oid, 'Error: Too many features are using the same FACLOCID' as Issue,
'There are ' + convert(nvarchar(10), t1.cnt) + ' features with FACLOCID = ' + t1.FACLOCID + '.' as Details from 
(select min(OBJECTID) as oid, FACLOCID, count(*)as cnt from gis.ROADS_FEATURE_PT_evw where FACLOCID is not null group by FACLOCID having count(*) > 1) as t1
where t1.cnt > 1
union all
-- 29) FACASSETID is optional free text. If provided it must match a record in the FMSSExport_Assets
--    Many features (like culverts and stairs) are FMSS assets of the parent road, and will have a non-null FACASSETID.
--    The location recored of an FMSS Asset should match the nearest road (feature.segmentid = road.geometryid)
--    It is not uncommon for several unique features (e.g. mapped culverts) to have the same FACASSETID (e.g. a 'bundle' of culverts)
--    FACLOCID must be NULL when FACASSETID is not null; See FACASSETID.Location for the parent location record
--    NOTE: FACASSETID is not globally UNIQUE, however it is unique to a park, which means FACASSETID/LOCATION is unique 
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue,
  'FACASSETID = ' + t1.FACASSETID + ' and FACLOCID = ' + t1.FACLOCID as Details
  from gis.ROADS_FEATURE_PT_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match SEGMENTID.FACLOCID' as Issue,
  'FACASSETID = ' + t1.FACASSETID + ' belongs to Location = ' + t2.Location + ' however SEGMENTID.FACLOCID = ' + t1.SEGMENTID + '.' + t3.FACLOCID as Details
  from gis.ROADS_FEATURE_PT_evw as t1
  join dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset
  join gis.ROADS_LN_evw as t3 on t1.SEGMENTID = t3.GEOMETRYID
  join dbo.FMSSExport as t4 on t2.Location = t4.Location
  where t2.Location <> t3.FACLOCID AND t4.Asset_Code = '1100' -- Only applies to road assets, not I&M assets
union all
select OBJECTID, 'Error: FACLOCID must be NULL when FACASSETID is not null' as Issue, NULL
  from gis.ROADS_FEATURE_PT_evw where FACASSETID is not null and FACLOCID is not null
union all
-- 30) SEGMENTID is the GEOMETRYID of the closest segment of the "Parent" road (i.e. the road that this feature is "on")
select OBJECTID, 'Warning: SEGMENTID is NULL and will be set to nearest road segment' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where SEGMENTID is null
union all
select a.OBJECTID, 'Error: SEGMENTID must match a GEOMETRYID in ROADS_LN' as Issue, NULL from gis.ROADS_FEATURE_PT_evw as a
  left join gis.ROADS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID where a.SEGMENTID is not null and t.GEOMETRYID is null
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.ROADS_FEATURE_PT_evw where shape.STIsEmpty() = 1
-- Check that the SEGMENTID is the closest road geometry
/*
-- Calculating the distance to SEGMENTID is a lot faster and easier than finding the closest road geometry
union all
select a.OBJECTID, 'Error: SHAPE is more than 20m from SEGMENTID in ROADS_LN' as Issue,
  'Point is ' + convert(nvarchar(50),round(GEOGRAPHY::STGeomFromText(a.shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText(t.shape.STAsText(),4269)),1)) + ' meters from ' + a.SEGMENTID as Details
  from gis.ROADS_FEATURE_PT_evw as a
  join gis.ROADS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID
  where GEOGRAPHY::STGeomFromText(a.shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText(t.shape.STAsText(),4269)) > 20
*/


-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'ROADS_FEATURE_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[QC_ISSUES_ROADS_LN] AS select I.Issue, I.Details, D.* from  gis.ROADS_LN_evw AS D
join (

-------------------------
-- gis.ROADS_LN
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) LINETYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary line' without a warning
--    This is not part of the road standard but an extension to the core standard.
--    TODO: Should we make the default be 'center line' as this is the working assumption?
--      Maybe enforce a center line requirement
--      Maybe we should we do something like bldgs and enforce Center as being the minimum requirement, and then put edges and all
--      other optional linetypes in a related feature class.
select t1.OBJECTID, 'Error: LINETYPE is not a recognized value' as Issue, NULL as Details from gis.ROADS_LN_evw as t1
  left join dbo.DOM_LINETYPE as t2 on t1.LINETYPE = t2.Code where t1.LINETYPE is not null and t1.LINETYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.ROADS_LN_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.ROADS_LN_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
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
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.ROADS_LN_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
--  Easy check to see if two segments are connected
select t1.OBJECTID, 'Error: Segments with the same FEATUREID are not connected' as Issue, '2 segments with FEATUREID = ''' + t1.FEATUREID + '''' as Details
  from (select FEATUREID, Shape, OBJECTID from gis.ROADS_LN_evw where FEATUREID in (select FEATUREID from gis.ROADS_LN_evw group by FEATUREID having count(*) = 2)) as t1
  join (select FEATUREID, Shape, OBJECTID from gis.ROADS_LN_evw where FEATUREID in (select FEATUREID from gis.ROADS_LN_evw group by FEATUREID having count(*) = 2)) as t2
  on t1.FEATUREID = t2.FEATUREID and t1.OBJECTID < t2.OBJECTID and t1.Shape.STIntersects(t2.Shape) = 0
union all
-- Harder check to see if more than two segments are all connected
--  RoadIsFullyConnected() is slow, I only want to call it once on each featureid that has more than 2 segments
select OBJECTID, 'Error: Segments with the same FEATUREID are not connected' as Issue, convert(NVARCHAR(10),cnt) + ' segments with FEATUREID = ''' + FEATUREID + '''' as Details
  from (select min(objectid) as OBJECTID, FEATUREID, dbo.RoadIsFullyConnected(FEATUREID) as contig, count(*) as cnt from gis.ROADS_LN_evw group by FEATUREID having count(*) > 2) as t where contig = 0
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_LN_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_LN_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.ROADS_LN_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.ROADS_LN_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_LN_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) RDNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: RDNAME must use proper case' as Issue, NULL from gis.ROADS_LN_evw where RDNAME = upper(RDNAME) Collate Latin1_General_CS_AI or RDNAME = lower(RDNAME) Collate Latin1_General_CS_AI
union all
-- 10) RDALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) RDSTATUS is a required domain value; default is 'Existing'
select OBJECTID, 'Warning: RDSTATUS is not provided, default value of *Existing* will be used' as Issue, NULL from gis.ROADS_LN_evw where RDSTATUS is null or RDSTATUS = ''
union all
select t1.OBJECTID, 'Error: RDSTATUS is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDSTATUS as t2 on t1.RDSTATUS = t2.Code where t1.RDSTATUS is not null and t1.RDSTATUS <> '' and t2.Code is null
union all 
select t1.OBJECTID, 'Error: RDSTATUS does not match the FMSS Status' as Issue,
  'Location ' + FACLOCID + ' has Status ' + t2.Status + ' (' + t3.Standard + ') when GIS has RDSTATUS = ' + t1.RDSTATUS as Details
  from gis.ROADS_LN_evw as t1
  join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  join dbo.DOM_FMSS_Status as t3 on t3.Code = t2.Status
  where t1.RDSTATUS <> t3.Standard
  and (t1.RDSTATUS <> 'Temporarily Closed' or t2.Status <> 'OPERATING') -- Ignore (not an error) Temporarily Closed could mean OPERATING
  and (t1.RDSTATUS <> 'Temporarily Closed' or t2.Status <> 'INACTIVE') -- Ignore (not an error) Temporarily Closed could also mean INACTIVE
union all 
-- 13) RDCLASS is a required domain value; default is 'Unknown'
--     if a feature has a FACLOCID then RDCLASS = 'Parking Lot Road' implies FMSS.asset_code = '1300' and visa-versa
--     if a feature has a FACLOCID then the FMSS Funtional Class implies a RDCLASS.  See section 4.3 of the standard
select OBJECTID, 'Warning: RDCLASS is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_LN_evw where RDCLASS is null or RDCLASS = ''
union all
select t1.OBJECTID, 'Error: RDCLASS is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDCLASS as t2 on t1.RDCLASS = t2.Code where t1.RDCLASS is not null and t1.RDCLASS <> '' and t2.Code is null
union all 
select t1.OBJECTID, 'Error: RDCLASS does not match the FMSS.Asset_Code' as Issue, 
  'Location ' + FACLOCID + ' has Asset Code ' + t2.Asset_Code + ' (' + t3.Description + ') when GIS has RDCLASS = ' + t1.RDCLASS as Details
  from gis.ROADS_LN_evw as t1 join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as t3 on t2.Asset_Code = t3.Code
  where t1.FACLOCID is not null and ((t1.RDCLASS = 'Parking Lot Road' and t2.Asset_Code <> '1300') or (t1.RDCLASS <> 'Parking Lot Road' and t2.Asset_Code = '1300'))
union all
select t1.OBJECTID, 'Error: RDCLASS does not match the FMSS Functional Class' as Issue,
       'Location ' + FACLOCID + ' has Functional ' + t2.FCLASS + ' (' + t3.Standard + ') when GIS has RDCLASS = ' + t1.RDCLASS + ' (' + t4.FMSS + ')' as Details
       from gis.ROADS_LN_evw as t1
       join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
       join dbo.DOM_FMSS_FunctionalClass as t3 on t3.Code = t2.FClass
       join dbo.DOM_RDCLASS as t4 on t1.RDCLASS = t4.Code where t1.RDCLASS <> t3.Standard and t2.FCLASS <> t4.FMSS
union all
-- 14) RDSURFACE is a required domain value; default is 'Unknown'
--     if facility_type = '1110' then all segments must be paved i.e. in ('Asphalt', 'Concrete', 'Brick/Pavers', 'Cobblestone', 'Other Paved')
--     if facility_type = '1120' then all segments must be not paved i.e. in ('Gravel', 'Native or Dirt', 'Other Unpaved', 'Sand')
--     if facility_type = '1130' then it will be a mix
--     if predominant_use like '%Dirt%' then all segments should be 'Native or Dirt'
--     if predominant_use like '%Gravel%' then all segments should be 'Gravel'
--     if predominant_use like '% Paved%' then all segments should be in ('Asphalt', 'Concrete', 'Brick/Pavers', 'Cobblestone', 'Other Paved')
--     if predominant_use like '% Unpaved%' then all segments should be in ('Gravel', 'Native or Dirt', 'Other Unpaved', 'Sand')
select OBJECTID, 'Warning: RDSURFACE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.ROADS_LN_evw where RDSURFACE is null or RDSURFACE = ''
union all
select t1.OBJECTID, 'Error: RDSURFACE is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDSURFACE as t2 on t1.RDSURFACE = t2.Code where t1.RDSURFACE is not null and t1.RDSURFACE <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: RDSURFACE does not match the FMSS Facility_Type' as Issue,
       'Location ' + FACLOCID + ' has Facility Type = ' + t2.Facility_Type + ' (' + t3.Description + ') when GIS has RDSURFACE = ' + t1.RDSURFACE as Details
       from gis.ROADS_LN_evw as t1
       join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
       join dbo.DOM_FMSS_FACILITYTYPE as t3 on t3.Code = t2.Facility_Type
       where (t2.Facility_Type = '1110' and t1.RDSURFACE in ('Gravel', 'Native or Dirt', 'Other Unpaved', 'Sand'))
	      or (t2.Facility_Type = '1120' and t1.RDSURFACE in ('Asphalt', 'Concrete', 'Brick/Pavers', 'Cobblestone', 'Other Paved'))
union all
select t1.OBJECTID, 'Error: RDSURFACE does not match the FMSS Predominant Use' as Issue,
       'Location ' + FACLOCID + ' has Predominant_Use = ' + t2.Predominant_Use + ' when GIS has RDSURFACE = ' + t1.RDSURFACE as Details
       from gis.ROADS_LN_evw as t1
       join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
       join dbo.DOM_FMSS_FACILITYTYPE as t3 on t3.Code = t2.Facility_Type
       where ((t2.Predominant_Use like '% Paved%' and t1.RDSURFACE in ('Gravel', 'Native or Dirt', 'Other Unpaved', 'Sand'))
	      or (t2.Predominant_Use like '%Gravel%'  and t1.RDSURFACE not in ('Gravel', 'Unknown'))
	      or (t2.Predominant_Use like '%Dirt%'  and t1.RDSURFACE not in ('Native or Dirt', 'Unknown'))
	      or (t2.Predominant_Use like '% Unpaved%'  and t1.RDSURFACE in ('Asphalt', 'Concrete', 'Brick/Pavers', 'Cobblestone', 'Other Paved')))
		  and not -- ignore the duplicate (RDSURFACE <> Facility type errors)
		  ((t2.Facility_Type = '1110' and t1.RDSURFACE in ('Gravel', 'Native or Dirt', 'Other Unpaved', 'Sand'))
	      or (t2.Facility_Type = '1120' and t1.RDSURFACE in ('Asphalt', 'Concrete', 'Brick/Pavers', 'Cobblestone', 'Other Paved')))
union all
-- 15) RDONEWAY is an optional domain value; default is Null
select t1.OBJECTID, 'Error: RDONEWAY is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDONEWAY as t2 on t1.RDONEWAY = t2.Code where t1.RDONEWAY is not null and t1.RDONEWAY <> '' and t2.Code is null
union all 
-- 16) RDLANES is an optional range value 1-8; default is Null
select OBJECTID, 'Error: RDLANES is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw where RDLANES < 1 or RDLANES > 8
union all
select t1.OBJECTID, 'Error: RDLANES does not match FMSS' as Issue,
       'Location ' + FACLOCID + ' has ' + convert(nvarchar(200),t2.NOLANE) + ' lanes in FMSS when GIS has RDLANES = ' + convert(nvarchar(200),t1.RDLANES) as Details
       from gis.ROADS_LN_evw as t1
       join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.RDLANES <> convert(int,convert(real,t2.NOLANE))
union all
-- 17) RDHICLEAR is an optional domain value; default is Null
select t1.OBJECTID, 'Error: RDHICLEAR is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK_OTH as t2 on t1.RDHICLEAR = t2.Code where t1.RDHICLEAR is not null and t1.RDHICLEAR <> '' and t2.Code is null
union all 
-- 18) RTENUMBER is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     This attribute has no counterpart in FMSS
-- 19) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.ROADS_LN_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 20) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.ROADS_LN_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 21) RDMAINTAINER is a optional domain value;  If FACLOCID is provided then it should match FMSS
--     TODO: We are using DOM_MAINTAINER not DOM_RDMAINTAINER for the FMSS values.  This should be integrated into one list of maintainers
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_RDMAINTAINER as t2 on t1.RDMAINTAINER = t2.Code where t1.RDMAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has RDMAINTAINER = ' + p.RDMAINTAINER as Details
  from gis.ROADS_LN_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.RDMAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 22) ISEXTANT is a required domain value; Default to 'True' with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.ROADS_LN_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 12/22 ISEXTANT must align with RDSTATUS. (See BLDGSTATUS for analysis)
select t1.OBJECTID, 'Error: ISEXTANT does not match RDSTATUS' as Issue,
  'ISEXTANT = ' + ISNULL(t1.ISEXTANT, 'True') + ' while RDSTATUS = ' + ISNULL(t1.RDSTATUS, 'NULL') + '(FMSS Status is ' + ISNULL(d.Standard, 'NULL') + ')' as Details
  from gis.ROADS_LN_evw as t1
  left join dbo.FMSSExport as f on f.Location = t1.FACLOCID
  left join dbo.DOM_FMSS_Status as d on f.Status = d.Code  -- Use d.Standard (= the standardized version of the FMSS Status, could be NULL)
  where t1.ISEXTANT = 'False' and (t1.RDSTATUS = 'Existing' or t1.RDSTATUS = 'Temporarily Closed' or ((t1.RDSTATUS is null or t1.RDSTATUS = '') and (d.Standard is null or d.Standard = 'Existing')))
union all
-- 23) PUBLICDISPLAY is a required Domain Value; Default to 'No Public Map Display' with Warning
--     TODO: are there requirements of other fields (i.e. RDSTATUS, ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select RDSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.ROADS_LN_evw where PUBLICDISPLAY = 'Public Map Display' group by RDSTATUS, ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.ROADS_LN_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 24) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.ROADS_LN_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 23/24) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.ROADS_LN_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 25) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
-- This requirement is relaxed for roads (this is a statewide road dataset, so many roads are not in or related to a park unit)
--   However any public roads must have a unit code
select t1.OBJECTID, 'Error: UNITCODE is required when the road is public and not within a unit boundary' as Issue, NULL from gis.ROADS_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
  and t1.PUBLICDISPLAY = 'Public Map Display'
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.ROADS_LN_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, NULL from gis.ROADS_LN_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 26) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.ROADS_LN_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.ROADS_LN_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 27) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.ROADS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.ROADS_LN_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.ROADS_LN_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 28) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.ROADS_LN_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 29) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.ROADS_LN_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 30) ROUTEID is optional free text, but if provided it must match a records in the RIP
--     All records with the same ROUTEID must have the same FEATUREID
--     We will assume that format of  NPS-UNITCODE-ROUTENUMBER is being enforced by FMSS or RIP lookup.  If routeid is not in one of those assume it is invalid
--     The ROUTEID is also related to a FMSS Functional Class. i.e. FMSS Functional Class I => Route numbers 1..99, II => 100..199, ...
--         This should be enforced in FMSS (it's not clear that it is.)  We will only endeavor to make ROUTEID and Functional Class match FMSS
--     TODO Get export of RIP, and ensure value is valid when FACLOCID is null, or FMSS does not provide a ROUTEID
select OBJECTID, 'Error: All records with the same ROUTEID must have the same FEATUREID' as Issue, NULL from gis.ROADS_LN_evw where ROUTEID in (
    select FACLOCID from (select ROUTEID from gis.ROADS_LN_evw where ROUTEID is not null and FEATUREID is not null group by FEATUREID, ROUTEID) as t group by ROUTEID having count(*) > 1)
union all
select p.OBJECTID, 'Error: ROUTEID does not match FMSS.ROUTEID' as Issue,
  'Location ' + FACLOCID + ' has ROUTEID = ' + f.ROUTEID + ' when GIS has ROUTEID = ' + p.ROUTEID as Details
  from gis.ROADS_LN_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.ROUTEID <> p.ROUTEID
union all
-- 31) FACLOCID is optional free text, but if provided it must match a Location in the FMSS Export
--     FACLOCID should be duplicate if featureid is duplicate, i.e. all line segments with the same FACLOCID must have the same featureid and all segements with the same featureid must have the same FACLOCID 
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.ROADS_LN_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Road in FMSS' as Issue, 
  'Location ' + FACLOCID + ' has an Asset Code of ' + t2.Asset_Code + ' (' + t3.Description + ')' as Details
  from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as t3 on t2.Asset_Code = t3.Code
  where t1.FACLOCID is not null and t2.Asset_Code not in ('1100', '1300', '1700', '1800')
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue, NULL from gis.ROADS_LN_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.ROADS_LN_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 32) FACASSETID is optional free text, provided it must match a Road Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.ROADS_LN_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a road asset in FMSS' as Issue, NULL from gis.ROADS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join 
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('1100', '1700', '1800')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue, NULL from gis.ROADS_LN_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- 33) ISOUTPARK: This is an AKR extension, it is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 34) ISBRIDGE: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISBRIDGE is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISBRIDGE = t2.Code where t1.ISBRIDGE is not null and t1.ISBRIDGE <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISBRIDGE does not match the FMSS.Asset_Code' as Issue,
  'GIS has ISBRIDGE = ' + t1.ISBRIDGE + ' while FMSS has Asset Code = ' + t2.Asset_Code + ' (' + d.Description + ')' as Details
  from gis.ROADS_LN_evw as t1 join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as d on t2.Asset_Code = d.Code 
  where t1.FACLOCID is not null and ((t1.ISBRIDGE = 'Yes' and t2.Asset_Code <> '1700') or (t1.ISBRIDGE <> 'Yes' and t2.Asset_Code = '1700'))
union all
-- 35) ISTUNNEL: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISTUNNEL is not a recognized value' as Issue, NULL from gis.ROADS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISTUNNEL = t2.Code where t1.ISTUNNEL is not null and t1.ISTUNNEL <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISTUNNEL does not match the FMSS.Asset_Code' as Issue,
  'GIS has ISTUNNEL = ' + t1.ISTUNNEL + ' while FMSS has Asset Code = ' + t2.Asset_Code + ' (' + d.Description + ')' as Details
  from gis.ROADS_LN_evw as t1 join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as d on t2.Asset_Code = d.Code 
  where t1.FACLOCID is not null and ((t1.ISTUNNEL = 'Yes' and t2.Asset_Code <> '1800') or (t1.ISTUNNEL <> 'Yes' and t2.Asset_Code = '1800'))
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.ROADS_LN_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.ROADS_LN_evw where shape.STIsValid() = 0
union all
-- Sum of lengths grouped by faclocid should be close to length FMSS.QTY (in miles)
select oid, 'Error: Road length in GIS is more than 20% different from FMSS' as Issue,
'Location ' + FACLOCID + ' is ' + convert(nvarchar(200),t1.miles) + ' miles in GIS, but ' + convert(nvarchar(200),t2.miles) + ' miles in FMSS (' + 
    case when t2.miles = 0 then 'xx' else convert(nvarchar(200),100*(t1.miles - t2.miles)/ t2.miles) end + '%)' as Details
  from (select min(objectid) as oid, FACLOCID, sum(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 0.000621371 as miles from gis.ROADS_LN_evw where faclocid is not null group by FACLOCID) as t1
  join (select Location, convert(real, Qty) as miles from FMSSExport where UM = 'mi') as t2 on t1.FACLOCID = t2.Location
  -- In Oct 2020, I noticed that several dozen FMSS records had the length truncated (not rounded) to 1 digit after the decimal, we'll do the same now.
  where (t2.miles = 0 AND t2.miles <> round(t1.miles,1,1)) OR (t2.miles <> 0 AND abs(t1.miles - t2.miles) > 0.1 AND  abs(t1.miles - t2.miles)/t2.miles > 0.2)
union all
select OBJECTID, 'Warning: Road segment is shorter than 10 meters' as Issue,
  'Length = ' + convert(nvarchar(200),GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) + ' meters' as Details
  from gis.ROADS_LN_evw where GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength() < 10
union all
select OBJECTID, 'Error: Multiline roads are not allowed' as Issue, NULL from gis.ROADS_LN_evw where SHAPE.STGeometryType() = 'MultiLineString'
union all
-- Overlapping road segments:  Takes about 30 seconds
select r1.OBJECTID, 'Error: Overlapping road segments are not allowed' as Issue, 'Overlaps with OBJECTID = ' + convert(nvarchar(20), r2.OBJECTID) as Details
from gis.ROADS_LN_evw as r1 join gis.ROADS_LN_evw as r2 on r1.shape.Filter(r2.shape) = 1 and r1.OBJECTID < r2.OBJECTID where r1.Shape.STOverlaps(r2.Shape) = 1

-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'ROADS_LN'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_TRAILS_ATTRIBUTE_PT] AS select I.Issue, I.Details, D.* from gis.TRAILS_ATTRIBUTE_PT_evw AS D
join (

--------------------------
-- gis.TRAILS_ATTRIBUTE_PT
--------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue, NULL as Details from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_ATTRIBUTE_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
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
select t1.OBJECTID, 'Error: FEATUREID not found in TRAILS_LN' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t1.FEATUREID is not null and t2.FEATUREID is null
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.TRAILS_ATTRIBUTE_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) TRLATTRTYPE must be non null and in DOM_TRLFEATFEATTYPE.  There is no default value
select OBJECTID, 'Error: TRLATTRTYPE is required' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where TRLATTRTYPE is null
union all
select t1.OBJECTID, 'Error: TRLATTRTYPE is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
       left join dbo.DOM_TRLATTRTYPE as t2 on t1.TRLATTRTYPE = t2.Code where t1.TRLATTRTYPE is not null and t1.TRLATTRTYPE <> '' and t2.Code is null
union all
-- 10) TRLATTRTYPEOTHER is optional free text unless TRLATTRTYPE = 'Other'. If it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Note: if there are common values here they can be promoted to TRLATTRTYPE
select OBJECTID, 'Error: TRLATTRTYPEOTHER is required when TRLFEATTYPE is Other' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw
       where TRLATTRTYPE = 'Other' and (TRLATTRTYPEOTHER is null or TRLATTRTYPEOTHER = '')
union all
select OBJECTID, 'Warning: TRLATTRTYPEOTHER will be cleared when TRLFEATTYPE is not Other' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw
       where TRLATTRTYPE <> 'Other' and TRLATTRTYPEOTHER is not null and TRLATTRTYPEOTHER <> ''
union all
-- 11) TRLATTRDESC is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) TRLATTRVALUE is optional int, but if it provided is it must be positive.
--     This can be checked and fixed automatically; no need to alert the user.
-- 13) WHLENGTH is optional real, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: WHLENGTH must be a poitive number' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where WHLENGTH < 0
union all
-- 14) WHLENUOM is an optional domain value (DOM_UOM); if WHLENGTH is not null it must be not null;
--     if WHLENGTH is null, this field will be silently set to null.
select OBJECTID, 'Error: WHLENUOM is required when WHLENGTH is positive' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where (WHLENUOM is null or WHLENUOM = '') and WHLENGTH > 0
union all
select t1.OBJECTID, 'Error: WHLENUOM is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_UOM as t2 on t1.WHLENUOM = t2.code where t1.WHLENUOM is not null and t1.WHLENUOM <> '' and t2.code is null
union all
-- 15) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 16) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 17) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: Are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE, ??) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.TRAILS_ATTRIBUTE_PT_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 18) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 17/18) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 19) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.TRAILS_ATTRIBUTE_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 20) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 21) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.TRAILS_ATTRIBUTE_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 22) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 23) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 24) FACLOCID is optional free text, but if provided it must match a trail location in the FMSS Export
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
-- A trail attribute must be a 2100 (Trail) or a 2200 (Trail Bridge) or a 2300 (Trail Tunnel).
select t1.OBJECTID, 'Error: FACLOCID is not approriate for this kind of trail feature (based on the Asset Code)' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  where (t2.Asset_Code <> '2100' and t2.Asset_Code <> '2200' and t2.Asset_Code <> '2300')
union all
-- FACLOCID must be the same as the parent trail
select t1.OBJECTID, 'Error: FACLOCID does not match the parent trail' as Issue,
  'Attribute point has FACLOCID = ' + t1.FACLOCID + ' but the trail it touches has FACLOCID = ' + t2.FACLOCID as Details
  from gis.TRAILS_ATTRIBUTE_PT_evw as t1
  --left join gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID where t2.FEATUREID is not null and (t1.FACLOCID <> t2.FACLOCID or (t1.FACLOCID is null and t2.FACLOCID is not null) or (t2.FACLOCID is null and t1.FACLOCID is not null))
  join gis.TRAILS_LN_evw as t2 on t1.SEGMENTID = t2.GEOMETRYID where t1.FACLOCID <> t2.FACLOCID
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.TRAILS_ATTRIBUTE_PT_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 25) FACASSETID is optional free text, provided it must match a Trail Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue,
  'FACASSETID = ' + t1.FACASSETID + ' with Location = ' + t2.Location + ' however FACLOCID = ' + t1.FACLOCID as Details
  from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a trail asset in FMSS' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.PARKLOTS_PY_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
-- SEGMENTID is the GEOMETRYID in TRAILS_LN which this attribute applies to
-- ideally it is coincident with the first vertex, but it is sufficient that it touches
-- this attribute will apply to the rest of the feature (all segments with the same featureid) in the digitized direction
-- until the end of the trail, or changed by a new attribute value.
select OBJECTID, 'Error: SEGMENTID must not be NULL' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where SEGMENTID is null
union all
select a.OBJECTID, 'Error: SEGMENTID must match a GEOMETRYID in TRAILS_LN' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as a
  left join gis.TRAILS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID where a.SEGMENTID is not null and t.GEOMETRYID is null
union all
select a.OBJECTID, 'Error: FEATUREID must match the FEATUREID of SEGMENTID in TRAILS_LN' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as a
  join gis.TRAILS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID where a.FEATUREID <> t.FEATUREID
union all
select a.OBJECTID, 'Error: SHAPE must touch the SEGMENTID in TRAILS_LN' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as a
  join gis.TRAILS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID where a.Shape.STIntersects(t.Shape) = 0
--select a.OBJECTID, 'Error: SHAPE must touch the first vertex of SEGMENTID in TRAILS_LN' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw as a
--  join gis.TRAILS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID where a.Shape.STIntersects(t.Shape.STPointN(1)) = 0
union all
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.TRAILS_ATTRIBUTE_PT_evw where shape.STIsEmpty() = 1


-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'TRAILS_ATTRIBUTE_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_TRAILS_FEATURE_PT] AS select I.Issue, I.Details, D.* from  gis.TRAILS_FEATURE_PT_evw AS D
join (

-------------------------
-- gis.TRAILS_FEATURE_PT
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) POINTTYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue, NULL as Details from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_FEATURE_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.TRAILS_FEATURE_PT_evw where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 3) FEATUREID must be unique and well-formed or null (in which case we will generate a unique well-formed value)
--    This is a primary key for each mapped feature, and not a foreign key to the "related" trail.
select OBJECTID, 'Error: FEATUREID is not unique' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where FEATUREID in
       (select FEATUREID from gis.TRAILS_FEATURE_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.TRAILS_FEATURE_PT_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) TRLFEATNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: TRLFEATNAME must use proper case' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where TRLFEATNAME = upper(TRLFEATNAME) Collate Latin1_General_CS_AI or TRLFEATNAME = lower(TRLFEATNAME) Collate Latin1_General_CS_AI
union all
-- 10) TRLFEATALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) TRLFEATTYPE must be non null and in DOM_TRLFEATFEATTYPE.  Theres is no default value
select OBJECTID, 'Error: TRLFEATTYPE is required' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where TRLFEATTYPE is null
union all
select t1.OBJECTID, 'Error: TRLFEATTYPE is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
       left join dbo.DOM_TRLFEATFEATTYPE as t2 on t1.TRLFEATTYPE = t2.Code where t1.TRLFEATTYPE is not null and t1.TRLFEATTYPE <> '' and t2.Code is null
union all
-- 13) TRLFEATTYPEOTHER is optional free text unless TRLFEATTYPE = 'Other'. If it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     Note: if there are common values here they can be promoted to TRLFEATTYPE
select OBJECTID, 'Error: TRLFEATTYPEOTHER is required when TRLFEATTYPE is Other' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw
       where TRLFEATTYPE = 'Other' and (TRLFEATTYPEOTHER is null or TRLFEATTYPEOTHER = '')
union all
select OBJECTID, 'Warning: TRLFEATTYPEOTHER will be cleared when TRLFEATTYPE is not Other' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw
       where TRLFEATTYPE <> 'Other' and TRLFEATTYPEOTHER is not null and TRLFEATTYPEOTHER <> ''
union all
-- 14) TRLFEATSUBTYPE is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
--     TODO: do we want to make this a domain value that is sensitive to the TRLFEATTYPE
-- 15) TRLFEATDESC is optional free text, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 16) TRLFEATCOUNT is optional int, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: TRLFEATCOUNT must be a poitive number' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where TRLFEATCOUNT < 0
union all
-- 17) WHLENGTH is optional real, but if it provided is it must be positive.
--     if it is zero, it will be silently converted to null
select OBJECTID, 'Error: WHLENGTH must be a poitive number' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where WHLENGTH < 0
union all
-- 18) WHLENUOM is an optional domain value (DOM_UOM); if WHLENGTH is not null it must be not null;
--     if WHLENGTH is null, this field will be silently set to null.
select OBJECTID, 'Error: WHLENUOM is required when WHLENGTH is positive' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where (WHLENUOM is null or WHLENUOM = '') and WHLENGTH > 0
union all
select t1.OBJECTID, 'Error: WHLENUOM is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_UOM as t2 on t1.WHLENUOM = t2.code where t1.WHLENUOM is not null and t1.WHLENUOM <> '' and t2.code is null
union all
-- 19) ISEXTANT is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 20) ISOUTPARK:  This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 21) PUBLICDISPLAY is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: Are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE, ??) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.TRAILS_FEATURE_PT_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 22) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 21/22) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 23) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.TRAILS_FEATURE_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 24) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 25) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.TRAILS_FEATURE_PT_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 26) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 27) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 28) FACLOCID is optional free text, but if provided it must match a Trail Location in the FMSS Export
--     FACLOCID is a foreign key to the same feature in the FMSS location table.  Not many trail features have
--     thier own location records (like a bridge or wayside exhibit), so this is typically NULL.  FACLOCID is not used
--     to track the related "parent" trail for this feature (except maybe for trail head/end features).
--     See SEGMENTID to get information on the trail this feature is "on".
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
-- Check that FACLOCID is the appropriate type (Asset_code) for this type of trail feature
-- if FACLOCID.Asset_Code = 2100 (trail), then TRLFEATTYPE = Trail head or Trail End, or Other/AnchorPt
-- if FACLOCID.Asset_Code = 2200 (trail bridge), then TRLFEATTYPE = Bridge or Walkable Structure
-- if FACLOCID.Asset_Code = 7%00, then TRLFEATTYPE = 'Wayside Feature'
-- This list may need to be expanded as we develop the trail features
select t1.OBJECTID, 'Error: FACLOCID is not approriate for this kind of trail feature (based on the Asset Code)' as Issue,
  'TRLFEATTYPE = ' + t1.TRLFEATTYPE + ' but Asset Code for ' + t2.Location + ' = ' + t2.Asset_Code + ' (' + d.Description + ')' as Details
  from gis.TRAILS_FEATURE_PT_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
  join DOM_FMSS_ASSETCODE as d on t2.Asset_Code = d.Code
  where (t2.Asset_Code = '2100' and not (t1.TRLFEATTYPE = 'Trail Head' or t1.TRLFEATTYPE = 'Trail End' or (t1.TRLFEATTYPE = 'Other' and t1.TRLFEATTYPEOTHER = 'AnchorPt')))
     or (t2.Asset_Code = '2200' and not (t1.TRLFEATTYPE = 'Bridge' or t1.TRLFEATTYPE = 'Walkable Structure'))
     or (t2.Asset_Code like '7%00' and t1.TRLFEATTYPE <> 'Wayside Feature')
union all
-- FACLOCID should be unique, except TRLFEATTYPE = Trail Start (1), Trail End (1) and Other/AnchorPt (many) may share the same FACLOCID
-- TODO: There are a lot of duplicate trail heads/ends; review the data and requirements before initiating cleanup
/*
select t1.oid, 'Error: Too many features are using the same FACLOCID' as Issue,
'There are ' + convert(nvarchar(10), t1.cnt) + ' features with FACLOCID = ' + t1.FACLOCID + '. ' +
convert(nvarchar(10), isnull(t2.cnt,0)) + ' Trail Heads (max 1), ' + 
convert(nvarchar(10), isnull(t3.cnt,0)) + ' Trail Ends (max 1), ' + 
convert(nvarchar(10), isnull(t4.cnt,0)) + ' Anchor Points (unlimited), ' + 
convert(nvarchar(10), t1.cnt - isnull(t2.cnt,0) - isnull(t3.cnt,0) - isnull(t4.cnt,0)) + ' Others (max 0)' as Details from 
(select min(OBJECTID) as oid, FACLOCID, count(*)as cnt from gis.TRAILS_FEATURE_PT_evw where FACLOCID is not null group by FACLOCID having count(*) > 1) as t1
left join (select FACLOCID, count(*) as cnt from gis.TRAILS_FEATURE_PT_evw where FACLOCID is not null and TRLFEATTYPE = 'Trail Head' group by FACLOCID) as t2 on t1.faclocid = t2.faclocid
left join (select FACLOCID, count(*) as cnt from gis.TRAILS_FEATURE_PT_evw where FACLOCID is not null and TRLFEATTYPE = 'Trail End' group by FACLOCID) as t3 on t1.faclocid = t3.faclocid
left join (select FACLOCID, count(*)as cnt from gis.TRAILS_FEATURE_PT_evw where FACLOCID is not null and TRLFEATTYPE = 'Other' and TRLFEATTYPEOTHER = 'AnchorPt' group by FACLOCID) as t4 on t1.faclocid = t4.faclocid
where isnull(t2.cnt,0) > 1 or  isnull(t3.cnt,0) > 1 or t1.cnt > isnull(t2.cnt,0) + isnull(t3.cnt,0) + isnull(t4.cnt,0)
*/
-- 29) FACASSETID is optional free text. If provided it must match a record in the FMSSExport_Assets
--    Many features (like culverts and stairs) are FMSS assets of the parent trail, and will have a non-null FACASSETID.
--    The location recored of an FMSS Asset should match the nearest trail (feature.segmentid = trail.geometryid)
--    It is not uncommon for several unique features (e.g. mapped culverts) to have the same FACASSETID (e.g. a 'bundle' of culverts)
--    FACLOCID must be NULL when FACASSETID is not null; See FACASSETID.Location for the parent location record
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue,
  'FACASSETID = ' + t1.FACASSETID + ' and FACLOCID = ' + t1.FACLOCID as Details
  from gis.TRAILS_FEATURE_PT_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match SEGMENTID.FACLOCID' as Issue,
  'FACASSETID = ' + t1.FACASSETID + ' belongs to Location = ' + t2.Location + ' however SEGMENTID.FACLOCID = ' + t1.SEGMENTID + '.' + t3.FACLOCID as Details
  from gis.TRAILS_FEATURE_PT_evw as t1
  join dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset
  join gis.TRAILS_LN_evw as t3 on t1.SEGMENTID = t3.GEOMETRYID
  join dbo.FMSSExport as t4 on t2.Location = t4.Location
  where t2.Location <> t3.FACLOCID AND t4.Asset_Code = '2100' -- Only applies to trail assets, not I&M assets
union all
select OBJECTID, 'Error: FACLOCID must be NULL when FACASSETID is not null' as Issue, NULL
  from gis.TRAILS_FEATURE_PT_evw where FACASSETID is not null and FACLOCID is not null
union all
-- 30) SEGMENTID is the GEOMETRYID of the closest segment of the "Parent" trail (i.e. the trail that this feature is "on")
--     SEGMENTID can be null; there are some "trail" features like interest points, that are not really part of a trail.
--     Maybe a feature without a related trail isn't a *trail* feature, and should be deleted and non-null SEGMENTID enforced
/*
select OBJECTID, 'Error: SEGMENTID must not be NULL' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where SEGMENTID is null
union all
*/
select a.OBJECTID, 'Error: SEGMENTID must match a GEOMETRYID in TRAILS_LN' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as a
  left join gis.TRAILS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID where a.SEGMENTID is not null and t.GEOMETRYID is null
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw where shape.STIsEmpty() = 1
-- Check that the SEGMENTID is the closest trail geometry
/*
-- Calculating the distance to SEGMENTID is a lot faster and easier than finding the closest trail geometry
union all
select a.OBJECTID, 'Error: SHAPE is more than 20m from SEGMENTID in TRAILS_LN' as Issue,
  'Point is ' + convert(nvarchar(50),round(GEOGRAPHY::STGeomFromText(a.shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText(t.shape.STAsText(),4269)),1)) + ' meters from ' + a.SEGMENTID as Details
  from gis.TRAILS_FEATURE_PT_evw as a
  join gis.TRAILS_LN_evw as t on a.SEGMENTID = t.GEOMETRYID
  where GEOGRAPHY::STGeomFromText(a.shape.STAsText(),4269).STDistance(GEOGRAPHY::STGeomFromText(t.shape.STAsText(),4269)) > 20
*/
union all

-- POITYPE
--    Can be null (but not empty - will be converted to a null in calcs)
--    If provided (and not empty), must be in akr_socio.gis.DOM_POICONTAINER_POITYPE_ALTNAMES
select t1.OBJECTID, 'Error: POITYPE is not a recognized value' as Issue, NULL from gis.TRAILS_FEATURE_PT_evw as t1
       left join akr_socio.gis.DOM_POICONTAINER_POITYPE_ALTNAMES as t2 on t1.POITYPE = t2.Code where t1.POITYPE is not null and t1.POITYPE <> '' and t2.Code is null



-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????


-- Related table check.
-- A trail feature point with a non null POITYPE should be replicated in the POI_PT table
union all
select t.OBJECTID, 'Error: Trail feature point with a POITYPE is not in POI_PT' as Issue, NULL as Details
from akr_facility2.gis.TRAILS_FEATURE_PT_evw as t left join akr_socio.gis.akr_POI_PT_evw as p
on p.SRCDBIDVAL = t.GEOMETRYID where t.POITYPE is not null and p.SRCDBIDVAL is null


) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'TRAILS_FEATURE_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[QC_ISSUES_TRAILS_LN] AS select I.Issue, I.Details, D.* from  gis.TRAILS_LN_evw AS D
join (

-------------------------
-- gis.TRAILS_LN
-------------------------

-- OBJECTID, SHAPE, CREATEDATE CREATEUSER, EDITDATE, EDITUSER - are managed by ArcGIS no QC or Calculations required

-- 1) LINETYPE must be an recognized value; if it is null/empty, then it will default to 'Arbitrary line' without a warning
--    TODO this is not part of the standard (maybe core after the fact), most is centerline
--    should we do something like bldgs with center being required, and edge or other being optional and linked
--    maybe require that this is a centerline feature class.
select t1.OBJECTID, 'Error: LINETYPE is not a recognized value'  as Issue, NULL as Details from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_LINETYPE as t2 on t1.LINETYPE = t2.Code where t1.LINETYPE is not null and t1.LINETYPE <> '' and t2.Code is null
union all 
-- 2) GEOMETRYID must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique'  as Issue, NULL from gis.TRAILS_LN_evw where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_LN_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed'  as Issue, NULL 
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
select OBJECTID, 'Error: FEATUREID is not well-formed'  as Issue, NULL 
	from gis.TRAILS_LN_evw where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all
select t1.OBJECTID, 'Error: Segments with the same FEATUREID are not connected' as Issue, '2 segments with FEATUREID = ''' + t1.FEATUREID + '''' as Details
  from (select FEATUREID, Shape, OBJECTID from gis.TRAILS_LN_evw where FEATUREID in (select FEATUREID from gis.TRAILS_LN_evw group by FEATUREID having count(*) = 2)) as t1
  join (select FEATUREID, Shape, OBJECTID from gis.TRAILS_LN_evw where FEATUREID in (select FEATUREID from gis.TRAILS_LN_evw group by FEATUREID having count(*) = 2)) as t2
  on t1.FEATUREID = t2.FEATUREID and t1.OBJECTID < t2.OBJECTID and t1.Shape.STIntersects(t2.Shape) = 0
union all
-- Harder check to see if more than two segments are all connected
--  TrailIsFullyConnected() is slow, I only want to call it once on each featureid that has more than 2 segments
select OBJECTID, 'Error: Segments with the same FEATUREID are not connected' as Issue, convert(NVARCHAR(10),cnt) + ' segments with FEATUREID = ''' + FEATUREID + '''' as Details
  from (select min(objectid) as OBJECTID, FEATUREID, dbo.TrailIsFullyConnected(FEATUREID) as contig, count(*) as cnt from gis.TRAILS_LN_evw group by FEATUREID having count(*) > 2) as t where contig = 0
union all
-- 4) MAPMETHOD is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all
-- 5) MAPSOURCE is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where MAPSOURCE is null or MAPSOURCE = ''
union all
-- 6) SOURCEDATE is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--    check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)'  as Issue, NULL from gis.TRAILS_LN_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future'  as Issue, NULL from gis.TRAILS_LN_evw where SOURCEDATE > GETDATE()
union all
-- 7) XYACCURACY is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all
-- 8) NOTES is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
-- 9) TRLNAME is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case
select OBJECTID, 'Error: TRLNAME must use proper case'  as Issue, NULL from gis.TRAILS_LN_evw where TRLNAME = upper(TRLNAME) Collate Latin1_General_CS_AI or TRLNAME = lower(TRLNAME) Collate Latin1_General_CS_AI
union all
-- 10) TRLALTNAME is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 11) MAPLABEL is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.
-- 12) TRLFEATTYPE is a required domain value; default is Unknown
--     TODO: Compare with FMSS i.e. if there is a valid FACLOCID, with an 'Existing' Status, then it can't be an unmaintained trail
select OBJECTID, 'Warning: TRLFEATTYPE is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where TRLFEATTYPE is null or TRLFEATTYPE = ''
union all
select t1.OBJECTID, 'Error: TRLFEATTYPE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLFEATTYPE as t2 on t1.TRLFEATTYPE = t2.Code where t1.TRLFEATTYPE is not null and t1.TRLFEATTYPE <> '' and t2.Code is null
union all 
-- 13) TRLSTATUS is a required domain value; default is 'Existing'
--     different parts of a single 'Feature' can have different status
--     TODO: removed 'Not Applicable' from Domain; consider removing Abandoned (use decomissioned) to match domain of roads/bldgs
select OBJECTID, 'Warning: TRLSTATUS is not provided, default value of *Existing* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where TRLSTATUS is null or TRLSTATUS = ''
union all
select t1.OBJECTID, 'Error: TRLSTATUS is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLSTATUS as t2 on t1.TRLSTATUS = t2.Code where t1.TRLSTATUS is not null and t1.TRLSTATUS <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLSTATUS does not match the FMSS Status'  as Issue,
    'Location ' + FACLOCID + ' has Status ' + t2.Status + ' (' + t3.Standard + ') when GIS has TRLSTATUS = ' + t1.TRLSTATUS as Details
    from gis.TRAILS_LN_evw as t1
    join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location
    join dbo.DOM_FMSS_Status as t3 on t3.Code = t2.Status
    join dbo.DOM_TRLSTATUS as t4 on t3.Standard = t4.Code where t1.TRLSTATUS <> t4.Code
    and (t1.TRLSTATUS <> 'Temporarily Closed' or t2.Status <> 'OPERATING') -- Ignore (not an error) Temporarily Closed could mean OPERATING
    and (t1.TRLSTATUS <> 'Temporarily Closed' or t2.Status <> 'IACTIVE') -- Ignore (not an error) Temporarily Closed could mean INACTIVE
    and (t1.TRLSTATUS <> 'Abandoned' or t2.Status <> 'OPERATING') -- Ignore (not an error) Abandoned could mean OPERATING
    and (t1.TRLSTATUS <> 'Abandoned' or t2.Status <> 'IACTIVE') -- Ignore (not an error) Abandoned could mean INACTIVE
union all
-- 14) TRLSURFACE is a required domain value; default is 'Unknown'
--     different parts of a single 'Feature' can have different surface
--     all parts of the feature with same FACLOCID will have the same surface as specified in FMSS.TREADTYP
select OBJECTID, 'Warning: TRLSURFACE is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where TRLSURFACE is null or TRLSURFACE = ''
union all
select t1.OBJECTID, 'Error: TRLSURFACE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLSURFACE as t2 on t1.TRLSURFACE = t2.Code where t1.TRLSURFACE is not null and t1.TRLSURFACE <> '' and t2.Code is null
union all 
select p.OBJECTID, 'Error: TRLSURFACE does not match FMSS.TREADTYP' as Issue,
  'Location ' + FACLOCID + ' has TREADTYP ' + f.TREADTYP + ' when GIS has TRLSURFACE = ' + p.TRLSURFACE + ' (' + d.FMSS_TREADTYP + ')' as Details
  from gis.TRAILS_LN_evw as p
  join dbo.FMSSExport as f on f.Location = p.FACLOCID
  join DOM_TRLSURFACE as d on p.TRLSURFACE = d.Code
  where d.FMSS_TREADTYP <> f.TREADTYP
union all
-- 15) TRLTYPE is a required domain value; default is 'Standard Terra Trail'
select OBJECTID, 'Warning: TRLTYPE is not provided, default value of *Standard Terra Trail* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where TRLTYPE is null or TRLTYPE = ''
union all
select t1.OBJECTID, 'Error: TRLTYPE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLTYPE as t2 on t1.TRLTYPE = t2.Code where t1.TRLTYPE is not null and t1.TRLTYPE <> '' and t2.Code is null
union all 
-- 16) TRLCLASS is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: TRLCLASS is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where TRLCLASS is null or TRLCLASS = ''
union all
select t1.OBJECTID, 'Error: TRLCLASS is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLCLASS as t2 on t1.TRLCLASS = t2.Code where t1.TRLCLASS is not null and t1.TRLCLASS <> '' and t2.Code is null
union all
select p.OBJECTID, 'Error: TRLCLASS does not match FMSS.Facility_Type' as Issue,
  'Location ' + FACLOCID + ' has Facility_Type ' + f.Facility_Type + ' (' + d1.Description + ') when GIS has TRLCLASS = ' + p.TRLCLASS as Details
  from gis.TRAILS_LN_evw as p
  join dbo.FMSSExport as f on f.Location = p.FACLOCID
  join DOM_FMSS_FACILITYTYPE as d1 on f.Facility_Type = d1.Code
  join DOM_TRLCLASS as d2 on p.TRLCLASS = d2.Code
  where f.Facility_Type like '21%' and (d2.FMSS_Facility_Type <> f.Facility_Type or (d2.FMSS_Facility_Type is null and p.TRLCLASS is not null and p.TRLCLASS <> '' and p.TRLCLASS <> 'Unknown'))
union all
-- 17) TRLUSE is a required pipe delimited list of approved uses
--     In AKR, this is a calculated field based on the various TRLUSE_* boolean columns
--     It will always be silently updated.  Woe to the unwary user that edits this field.
-- 18) SEASONAL is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS'  as Issue,
  'SEASONAL = ' + p.SEASONAL + ' while FMSS.OPSEAS = ' + f.OPSEAS as Details from gis.TRAILS_LN_evw as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
-- 19) SEASDESC optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used'  as Issue, NULL from gis.TRAILS_LN_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all
-- 20) MAINTAINER is a optional domain value;
--     If FACLOCID is provided MAINTAINER should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.TRAILS_LN_evw as p join 
  dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
-- 21) ISEXTANT is a required domain value; Default to 'True' with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all
-- 13/21 ISEXTANT must align with TRLSTATUS. (See BLDGSTATUS for analysis)
-- NOTE for trails it is acceptable to be existing and not extant if it is a route
select t1.OBJECTID, 'Error: ISEXTANT does not match TRLSTATUS' as Issue,
  'ISEXTANT = ' + ISNULL(t1.ISEXTANT, 'True') + ' while TRLSTATUS = ' + ISNULL(t1.TRLSTATUS, 'NULL') + '(FMSS Status is ' + ISNULL(d.Standard, 'NULL') + ')' as Details
  from gis.TRAILS_LN_evw as t1
  left join dbo.FMSSExport as f on f.Location = t1.FACLOCID
  left join dbo.DOM_FMSS_Status as d on f.Status = d.Code  -- Use d.Standard (= the standardized version of the FMSS Status, could be NULL)
  where t1.ISEXTANT = 'False' and t1.TRLFEATTYPE <> 'Route Path' and (t1.TRLSTATUS = 'Existing' or t1.TRLSTATUS = 'Temporarily Closed' or ((t1.TRLSTATUS is null or t1.TRLSTATUS = '') and (d.Standard is null or d.Standard = 'Existing')))
union all
-- 22) PUBLICDISPLAY is a required Domain Value; Default to 'No Public Map Display' with Warning
--     TODO: are there requirements of other fields (i.e. TRLSTATUS, ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select TRLSTATUS, ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.TRAILS_LN_evw where PUBLICDISPLAY = 'Public Map Display' group by TRLSTATUS, ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all
-- 23) DATAACCESS is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
  left join dbo.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all
-- 22/23) PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted'  as Issue, NULL from gis.TRAILS_LN_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all
-- 24) UNITCODE is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the road is not within a unit boundary'  as Issue, NULL from gis.TRAILS_LN_evw as t1
  left join gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from gis.AKR_UNIT as t1
  left join gis.TRAILS_LN_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park'  as Issue, NULL from gis.TRAILS_LN_evw as p join 
  (SELECT Park, Location FROM dbo.FMSSExport where Park in (select Code from dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
-- 25) UNITNAME is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value'  as Issue, NULL from gis.TRAILS_LN_evw as t1 join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value'  as Issue, NULL from gis.TRAILS_LN_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all
-- 26) GROUPCODE is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or dbo.DOM_UNITCODE
---- dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1 left join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE'  as Issue, NULL from gis.TRAILS_LN_evw as t1 left join
  dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within'  as Issue, NULL from gis.TRAILS_LN_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.TRAILS_LN_evw as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all
-- 27) GROUPNAME is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value'  as Issue, NULL from gis.TRAILS_LN_evw as t1 join
  gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all
-- 28) REGIONCODE is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*'  as Issue, NULL from gis.TRAILS_LN_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all
-- 29) FACLOCID is optional free text, but if provided it must be unique and match a Location in the FMSS Export
--     all line segments with the same FACLOCID must have the same featureid
--     NOTE: not all segements with the same featureid must have the same FACLOCID (we may associated spurs, etc with a trail network (one feature) that are not maintained in FMSS)
--     NOTE: A bridge/tunnel in a trail will have the same FEATUREID as the trail, however the FACLOCID (and asset type) for the bridge/tunnel is typically different from the trail
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID'  as Issue, NULL from gis.TRAILS_LN_evw as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all
select t1.OBJECTID, 'Error: FACLOCID does not match a Trail in FMSS'  as Issue, NULL from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t2.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACLOCID must have the same FEATUREID'  as Issue, NULL from gis.TRAILS_LN_evw where FACLOCID in (
    select FACLOCID from (select FACLOCID from gis.TRAILS_LN_evw where FACLOCID is not null and FEATUREID is not null group by FEATUREID, FACLOCID) as t group by FACLOCID having count(*) > 1)
union all
-- 32) FACASSETID is optional free text, provided it must match a Trail Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID'  as Issue, NULL from gis.TRAILS_LN_evw as t1 left join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID'  as Issue, NULL from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACLOCID <> t3.Location
union all
select t1.OBJECTID, 'Error: FACASSETID does not match a trail asset in FMSS'  as Issue, NULL from gis.TRAILS_LN_evw as t1 join
  dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  dbo.FMSSExport as t3 on t2.Location = t3.Location where t1.FACASSETID is not null and t1.FACASSETID <> '' and t3.Asset_Code not in ('2100', '2200', '2300')
union all
select OBJECTID, 'Error: All records with the same FACASSETID must have the same FEATUREID'  as Issue, NULL from gis.TRAILS_LN_evw where FACASSETID in (
    select FACASSETID from (select FACASSETID from gis.TRAILS_LN_evw where FACASSETID is not null and FEATUREID is not null group by FEATUREID, FACASSETID) as t group by FACASSETID having count(*) > 1)
union all
----------------------------------------------------
-- AKR Additions to the Trails Spatial Data Standard
----------------------------------------------------
-- 31) ISOUTPARK: This is an AKR extension, it is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check
-- 32) ISBRIDGE: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISBRIDGE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISBRIDGE = t2.Code where t1.ISBRIDGE is not null and t1.ISBRIDGE <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISBRIDGE does not match the FMSS.Asset_Code' as Issue, 
  'GIS has ISBRIDGE = ' + t1.ISBRIDGE + ' while FMSS has Asset Code = ' + t2.Asset_Code + ' (' + d.Description + ')' as Details
  from gis.TRAILS_LN_evw as t1 join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as d on t2.Asset_Code = d.Code 
  where t1.FACLOCID is not null and ((t1.ISBRIDGE = 'Yes' and t2.Asset_Code <> '2200') or (t1.ISBRIDGE <> 'Yes' and t2.Asset_Code = '2200'))
union all
-- 33) ISTUNNEL: This is an AKR extension; it is a required element in the Yes/No domain; it silently defaults to 'No'
--     if this feature has a FACLOCID then ISBRIDGE = 'Yes' implies FMSS.asset_code = '1700' and visa-versa
select t1.OBJECTID, 'Error: ISTUNNEL is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.ISTUNNEL = t2.Code where t1.ISTUNNEL is not null and t1.ISTUNNEL <> '' and t2.Code is null
union all
select t1.OBJECTID, 'Error: ISTUNNEL does not match the FMSS.Asset_Code' as Issue,
  'GIS has ISTUNNEL = ' + t1.ISTUNNEL + ' while FMSS has Asset Code = ' + t2.Asset_Code + ' (' + d.Description + ')' as Details
  from gis.TRAILS_LN_evw as t1 join dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location join DOM_FMSS_ASSETCODE as d on t2.Asset_Code = d.Code 
  where t1.FACLOCID is not null and ((t1.ISTUNNEL = 'Yes' and t2.Asset_Code <> '2300') or (t1.ISTUNNEL <> 'Yes' and t2.Asset_Code = '2300'))
union all 
-- 34) TRLTRACK: This is an AKR extension; it is a required domain element; defaults to 'Unknown' with warning
select OBJECTID, 'Warning: TRLTRACK is not provided, default value of *Unknown* will be used'  as Issue, NULL from gis.TRAILS_LN_evw where TRLTRACK is null or TRLTRACK = ''
union all
select t1.OBJECTID, 'Error: TRLTRACK is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_TRLTRACK as t2 on t1.TRLTRACK = t2.Code where t1.TRLTRACK is not null and t1.TRLTRACK <> '' and t2.Code is null
union all 
-- 35) TRLISSOCIAL: This is an AKR extension; it is a required domain element; defaults to 'No' without a warning
select t1.OBJECTID, 'Error: TRLISSOCIAL is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLISSOCIAL = t2.Code where t1.TRLISSOCIAL is not null and t1.TRLISSOCIAL <> '' and t2.Code is null
union all
-- 36) TRLISANIMAL: This is an AKR extension; it is a required domain element; defaults to 'No' without a warning
select t1.OBJECTID, 'Error: TRLISANIMAL is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLISANIMAL = t2.Code where t1.TRLISANIMAL is not null and t1.TRLISANIMAL <> '' and t2.Code is null
union all
-- 37) TRLISADMIN: This is an AKR extension; it is a required domain element; defaults to 'No' without a warning
select t1.OBJECTID, 'Error: TRLISADMIN is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLISADMIN = t2.Code where t1.TRLISADMIN is not null and t1.TRLISADMIN <> '' and t2.Code is null
union all
select p.OBJECTID, 'Error: TRLISADMIN does not match FMSS.PRIMUSE' as Issue,
  'Location ' + FACLOCID + ' has PRIMUSE ' + isnull(f.PRIMUSE,'NULL') + ' (' + f.TRLISADMIN + ') when GIS has TRLISADMIN = ' + p.TRLISADMIN as Details
  from gis.TRAILS_LN_evw as p join 
  (select Location, PRIMUSE, case when PRIMUSE = 'Admin Use' then 'Yes' when PRIMUSE is null then null else 'No' end as TRLISADMIN from dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.TRLISADMIN <> f.TRLISADMIN
union all
--TODO: Look for illogical combinations of TRLFEATTYPE and TRLIS*
-- 38) WHLENGTH_FT: This is an AKR extension; it is an optional numerical value > Zero. If zero is provided it will be silently converted to Null.
select OBJECTID, 'Error: WHLENGTH_FT is not allowed to be a negative number'  as Issue, NULL from gis.TRAILS_LN_evw where WHLENGTH_FT < 0
union all
-- 39) TRLDESC: This is an AKR extension; it is an optional free text field; it should not be an empty string
-- 40) TRLUSE_*: This is an AKR extension; It defaults to NULL (no data); Yes if the use is specifically supported; No if it is specifically prohibited
select t1.OBJECTID, 'Error: TRLUSE_FOOT is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_FOOT = t2.Code where t1.TRLUSE_FOOT is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_BICYCLE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_BICYCLE = t2.Code where t1.TRLUSE_BICYCLE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_HORSE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_HORSE = t2.Code where t1.TRLUSE_HORSE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_ATV is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_ATV = t2.Code where t1.TRLUSE_ATV is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_4WD is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_4WD = t2.Code where t1.TRLUSE_4WD is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_OHVSUB is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_OHVSUB = t2.Code where t1.TRLUSE_OHVSUB is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_MOTORCYCLE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_MOTORCYCLE = t2.Code where t1.TRLUSE_MOTORCYCLE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_SNOWMOBILE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_SNOWMOBILE = t2.Code where t1.TRLUSE_SNOWMOBILE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_SNOWSHOE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_SNOWSHOE = t2.Code where t1.TRLUSE_SNOWSHOE is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_SKITOUR is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_SKITOUR = t2.Code where t1.TRLUSE_SKITOUR is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_NORDIC is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_NORDIC = t2.Code where t1.TRLUSE_NORDIC is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_DOWNHILL is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_DOWNHILL = t2.Code where t1.TRLUSE_DOWNHILL is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_DOGSLED is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_DOGSLED = t2.Code where t1.TRLUSE_DOGSLED is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_CANYONEER is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_CANYONEER = t2.Code where t1.TRLUSE_CANYONEER is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_CLIMB is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_CLIMB = t2.Code where t1.TRLUSE_CLIMB is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_MOTORBOAT is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_MOTORBOAT = t2.Code where t1.TRLUSE_MOTORBOAT is not null and t2.Code is null
union all
select t1.OBJECTID, 'Error: TRLUSE_CANOE is not a recognized value'  as Issue, NULL from gis.TRAILS_LN_evw as t1
       left join dbo.DOM_YES_NO as t2 on t1.TRLUSE_CANOE = t2.Code where t1.TRLUSE_CANOE is not null and t2.Code is null
--TODO: Look for illogical combinations of TRLTYPE and TRLUSE_*
union all
---------------
-- Shape Checks
---------------
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.TRAILS_LN_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.TRAILS_LN_evw where shape.STIsValid() = 0
union all
select OBJECTID, 'Error: SHAPE is invalid (when converted to a geography)', shape.STAsText()
  from gis.TRAILS_LN_evw where GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STIsValid() = 0
union all
-- Sum of lengths grouped by faclocid should be close to length FMSS.QTY (in miles)
/*
-- Remove this query for now; These will take some research to resolve
-- TODO: Use this query for data cleanup in the future
select oid, 'Error: Trail length in GIS is more than 20% different from FMSS' as Issue,
  'Location ' + FACLOCID + ' is ' + convert(nvarchar(200),t1.feet) + ' feet in GIS, but ' + convert(nvarchar(200),t2.feet) + ' feet in FMSS (' + convert(nvarchar(200),100*(t1.feet - t2.feet)/ t2.feet) + '%)' as Details
  from (select min(objectid) as oid, FACLOCID, sum(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 3.28084 as feet from gis.TRAILS_LN_evw where faclocid is not null group by FACLOCID) as t1
  join (select Location, convert(real, replace(Qty,',','')) as feet from FMSSExport where UM = 'LF') as t2 on t1.FACLOCID = t2.Location
  where abs(t1.feet - t2.feet)/ t2.feet > 0.2
union all
*/
/*
-- Remove this query for now; too many short connectors that are valid
-- TODO: Use this query for data cleanup in the future
select OBJECTID, 'Warning: Trail segment is shorter than 5 meters' as Issue,
  'Length = ' + convert(nvarchar(200),GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) + ' meters' as Details
  from gis.TRAILS_LN_evw where GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength() < 5
union all
*/
select OBJECTID, 'Error: Multiline roads are not allowed' as Issue, NULL from gis.TRAILS_LN_evw where SHAPE.STGeometryType() = 'MultiLineString'
union all
-- Overlapping segments:  Takes about 15 seconds
select r1.OBJECTID, 'Error: Overlapping segments are not allowed' as Issue, 'Overlaps with OBJECTID = ' + convert(nvarchar(20), r2.OBJECTID) as Details
from gis.TRAILS_LN_evw as r1 join gis.TRAILS_LN_evw as r2 on r1.shape.Filter(r2.shape) = 1 and r1.OBJECTID < r2.OBJECTID where r1.LINETYPE <> 'Perimeter line' AND r2.LINETYPE <> 'Perimeter line' AND r1.Shape.STOverlaps(r2.Shape) = 1




-- ???????????????????????????????????
-- What about webedituser, webcomment?
-- ???????????????????????????????????

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'TRAILS_LN'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2020-02-11
-- Description:	Calculated properties for Assets
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Asset] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if ASSETNAME is an empty string, change to NULL
    update gis.AKR_ASSET_evw set ASSETNAME = NULL where ASSETNAME = ''
    -- 2) if ASSETALTNAME is an empty string, change to NULL
    update gis.AKR_ASSET_evw set ASSETALTNAME = NULL where ASSETALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_ASSET_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) if ASSETCODE is NULL or empty and FACLOCID is not null or FACASSETID is not null then calc from from FMSS
    merge into gis.AKR_ASSET_evw as t1 using FMSSExport as t2
      on t1.FACLOCID = t2.Location and (ASSETCODE is null or ASSETCODE = '') and FACLOCID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    merge into gis.AKR_ASSET_evw as t1 using 
      (SELECT t3.Asset, t4.Asset_Code FROM FMSSExport_Asset as t3 join FMSSExport as t4 on t3.Location = t4.Location) as t2
      on t1.FACASSETID = t2.Asset and (ASSETCODE is null or ASSETCODE = '') and FACASSETID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    -- 5) ASSETTYPE - No calcs; NULL, Empty and not in DOM trigger QC Error
    -- 6) if ASSETTYPEOTHDESC is an empty string, change to NULL
    update gis.AKR_ASSET_evw set ASSETTYPEOTHDESC = NULL where ASSETTYPEOTHDESC = ''
    -- 7) if ASSETDESC is an empty string, change to NULL
    update gis.AKR_ASSET_evw set ASSETDESC = NULL where ASSETDESC = ''
    -- 8) if ASSETMATERIAL is an empty string, change to NULL
    update gis.AKR_ASSET_evw set ASSETMATERIAL = NULL where ASSETMATERIAL = ''
    -- 9) if ASSETDIAMETER_FT is zero then converted to Null.
    update gis.AKR_ASSET_evw set ASSETDIAMETER_FT = NULL where ASSETDIAMETER_FT = 0
    -- 10) if ASSETLENGTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_evw set ASSETLENGTH_FT = NULL where ASSETLENGTH_FT = 0
    -- 11) if ASSETWIDTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_evw set ASSETWIDTH_FT = NULL where ASSETWIDTH_FT = 0
    -- 12) if ASSETDEPTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_evw set ASSETDEPTH_FT = NULL where ASSETDEPTH_FT = 0
    -- 13) if SEASONAL is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.AKR_ASSET_evw as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM dbo.FMSSExport_Asset as t1 JOIN dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    -- 14) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.AKR_ASSET_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.AKR_ASSET_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 15) if MAINTAINER is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_ASSET_evw as p
      using (SELECT d.Code as FAMARESP, a.Asset FROM dbo.FMSSExport_Asset as a join dbo.FMSSExport as t on a.Location = t.Location
             join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    -- 16) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.AKR_ASSET_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 17) ISOUTPARK is meaningless for non-spatial assets; Nothing to do
    -- 18) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_ASSET_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 19) DATAACCESS defaults to No Public Map Display
    update gis.AKR_ASSET_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 20) UNITCODE must be in DOM; Nothing to do
    -- 21) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_ASSET_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_ASSET_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 22) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_ASSET_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 23) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_ASSET_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_ASSET_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 24) REGIONCODE is always set to AKR
    update gis.AKR_ASSET_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- no CALCs for CREATEUSER, CREATEDATE, EDITUSER, EDITDATE (managed by system)
    -- 25) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 26) if MAPSOURCE is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.AKR_ASSET_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 27) SOURCEDATE: Nothing to do.
    -- 28) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 29) if FACLOCID is empty string change to null
    update gis.AKR_ASSET_evw set FACLOCID = NULL where FACLOCID = ''
    -- 30) if FACASSETID is empty string change to null
    update gis.AKR_ASSET_evw set FACASSETID = NULL where FACASSETID = ''
    -- 31) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_ASSET_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 32) Add GEOMETRYID if null/empty
    update gis.AKR_ASSET_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 33) if NOTES is an empty string, change to NULL
    update gis.AKR_ASSET_evw set NOTES = NULL where NOTES = ''
    -- no CALCs for WEBEDITUSER, WEBCOMMENT


    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2020-02-11
-- Description:	Calculated properties for Assets
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Asset_Ln] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if ASSETNAME is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set ASSETNAME = NULL where ASSETNAME = ''
    -- 2) if ASSETALTNAME is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set ASSETALTNAME = NULL where ASSETALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) if ASSETCODE is NULL or empty and FACLOCID is not null or FACASSETID is not null then calc from from FMSS
    merge into gis.AKR_ASSET_LN_evw as t1 using FMSSExport as t2
      on t1.FACLOCID = t2.Location and (ASSETCODE is null or ASSETCODE = '') and FACLOCID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    merge into gis.AKR_ASSET_LN_evw as t1 using 
      (SELECT t3.Asset, t4.Asset_Code FROM FMSSExport_Asset as t3 join FMSSExport as t4 on t3.Location = t4.Location) as t2
      on t1.FACASSETID = t2.Asset and (ASSETCODE is null or ASSETCODE = '') and FACASSETID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    -- 5) ASSETTYPE - No calcs; NULL, Empty and not in DOM trigger QC Error
    -- 6) if ASSETTYPEOTHDESC is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set ASSETTYPEOTHDESC = NULL where ASSETTYPEOTHDESC = ''
    -- 7) if ASSETDESC is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set ASSETDESC = NULL where ASSETDESC = ''
    -- 8) if ASSETMATERIAL is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set ASSETMATERIAL = NULL where ASSETMATERIAL = ''
    -- 9) if ASSETDIAMETER_FT is zero then converted to Null.
    update gis.AKR_ASSET_LN_evw set ASSETDIAMETER_FT = NULL where ASSETDIAMETER_FT = 0
    -- 10) if ASSETLENGTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_LN_evw set ASSETLENGTH_FT = NULL where ASSETLENGTH_FT = 0
    -- 11) if ASSETWIDTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_LN_evw set ASSETWIDTH_FT = NULL where ASSETWIDTH_FT = 0
    -- 12) if ASSETDEPTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_LN_evw set ASSETDEPTH_FT = NULL where ASSETDEPTH_FT = 0
    -- 13) if SEASONAL is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_LN_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.AKR_ASSET_LN_evw as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM dbo.FMSSExport_Asset as t1 JOIN dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    -- 14) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.AKR_ASSET_LN_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.AKR_ASSET_LN_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 15) if MAINTAINER is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_LN_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_ASSET_LN_evw as p
      using (SELECT d.Code as FAMARESP, a.Asset FROM dbo.FMSSExport_Asset as a join dbo.FMSSExport as t on a.Location = t.Location
             join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    -- 16) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.AKR_ASSET_LN_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 17) Add LINETYPE = 'Arbitrary line' if null/empty
    update gis.AKR_ASSET_LN_evw set LINETYPE = 'Arbitrary line' where LINETYPE is null or LINETYPE = '' 
    -- 18) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.AKR_ASSET_LN_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- 19) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_ASSET_LN_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 20) DATAACCESS defaults to No Public Map Display
    update gis.AKR_ASSET_LN_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 21) UNITCODE is a spatial calc if null
    merge into gis.AKR_ASSET_LN_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 22) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_ASSET_LN_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_ASSET_LN_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 23) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 24) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_ASSET_LN_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_ASSET_LN_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 25) REGIONCODE is always set to AKR
    update gis.AKR_ASSET_LN_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- no CALCs for CREATEUSER, CREATEDATE, EDITUSER, EDITDATE (managed by system)
    -- 26) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_LN_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 27) if MAPSOURCE is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.AKR_ASSET_LN_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 28) SOURCEDATE: Nothing to do.
    -- 29) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_LN_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 30) if FACLOCID is empty string change to null
    update gis.AKR_ASSET_LN_evw set FACLOCID = NULL where FACLOCID = ''
    -- 31) if FACASSETID is empty string change to null
    update gis.AKR_ASSET_LN_evw set FACASSETID = NULL where FACASSETID = ''
    -- 32) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_ASSET_LN_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 33) Add GEOMETRYID if null/empty
    update gis.AKR_ASSET_LN_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 34) if NOTES is an empty string, change to NULL
    update gis.AKR_ASSET_LN_evw set NOTES = NULL where NOTES = ''
    -- no CALCs for WEBEDITUSER, WEBCOMMENT


    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2020-02-11
-- Description:	Calculated properties for Assets
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Asset_Pt] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if ASSETNAME is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set ASSETNAME = NULL where ASSETNAME = ''
    -- 2) if ASSETALTNAME is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set ASSETALTNAME = NULL where ASSETALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) if ASSETCODE is NULL or empty and FACLOCID is not null or FACASSETID is not null then calc from from FMSS
    merge into gis.AKR_ASSET_PT_evw as t1 using FMSSExport as t2
      on t1.FACLOCID = t2.Location and (ASSETCODE is null or ASSETCODE = '') and FACLOCID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    merge into gis.AKR_ASSET_PT_evw as t1 using 
      (SELECT t3.Asset, t4.Asset_Code FROM FMSSExport_Asset as t3 join FMSSExport as t4 on t3.Location = t4.Location) as t2
      on t1.FACASSETID = t2.Asset and (ASSETCODE is null or ASSETCODE = '') and FACASSETID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    -- 5) ASSETTYPE - No calcs; NULL, Empty and not in DOM trigger QC Error
    -- 6) if ASSETTYPEOTHDESC is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set ASSETTYPEOTHDESC = NULL where ASSETTYPEOTHDESC = ''
    -- 7) if ASSETDESC is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set ASSETDESC = NULL where ASSETDESC = ''
    -- 8) if ASSETMATERIAL is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set ASSETMATERIAL = NULL where ASSETMATERIAL = ''
    -- 9) if ASSETDIAMETER_FT is zero then converted to Null.
    update gis.AKR_ASSET_PT_evw set ASSETDIAMETER_FT = NULL where ASSETDIAMETER_FT = 0
    -- 10) if ASSETLENGTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_PT_evw set ASSETLENGTH_FT = NULL where ASSETLENGTH_FT = 0
    -- 11) if ASSETWIDTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_PT_evw set ASSETWIDTH_FT = NULL where ASSETWIDTH_FT = 0
    -- 12) if ASSETDEPTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_PT_evw set ASSETDEPTH_FT = NULL where ASSETDEPTH_FT = 0
    -- 13) if SEASONAL is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_PT_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.AKR_ASSET_PT_evw as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM dbo.FMSSExport_Asset as t1 JOIN dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    -- 14) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.AKR_ASSET_PT_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.AKR_ASSET_PT_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 15) if MAINTAINER is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_PT_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_ASSET_PT_evw as p
      using (SELECT d.Code as FAMARESP, a.Asset FROM dbo.FMSSExport_Asset as a join dbo.FMSSExport as t on a.Location = t.Location
             join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    -- 16) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.AKR_ASSET_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 17) Add POINTTYPE = 'Arbitrary point' if null/empty
    update gis.AKR_ASSET_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = '' 
    -- 18) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.AKR_ASSET_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- 19) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_ASSET_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 20) DATAACCESS defaults to No Public Map Display
    update gis.AKR_ASSET_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 21) UNITCODE is a spatial calc if null
    merge into gis.AKR_ASSET_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 22) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_ASSET_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_ASSET_PT_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 23) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 24) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_ASSET_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_ASSET_PT_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 25) REGIONCODE is always set to AKR
    update gis.AKR_ASSET_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- no CALCs for CREATEUSER, CREATEDATE, EDITUSER, EDITDATE (managed by system)
    -- 26) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 27) if MAPSOURCE is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.AKR_ASSET_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 28) SOURCEDATE: Nothing to do.
    -- 29) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 30) if FACLOCID is empty string change to null
    update gis.AKR_ASSET_PT_evw set FACLOCID = NULL where FACLOCID = ''
    -- 31) if FACASSETID is empty string change to null
    update gis.AKR_ASSET_PT_evw set FACASSETID = NULL where FACASSETID = ''
    -- 32) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_ASSET_PT_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 33) Add GEOMETRYID if null/empty
    update gis.AKR_ASSET_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 34) if NOTES is an empty string, change to NULL
    update gis.AKR_ASSET_PT_evw set NOTES = NULL where NOTES = ''
    -- no CALCs for WEBEDITUSER, WEBCOMMENT


    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2020-02-11
-- Description:	Calculated properties for Assets
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Asset_Py] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if ASSETNAME is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set ASSETNAME = NULL where ASSETNAME = ''
    -- 2) if ASSETALTNAME is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set ASSETALTNAME = NULL where ASSETALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) if ASSETCODE is NULL or empty and FACLOCID is not null or FACASSETID is not null then calc from from FMSS
    merge into gis.AKR_ASSET_PY_evw as t1 using FMSSExport as t2
      on t1.FACLOCID = t2.Location and (ASSETCODE is null or ASSETCODE = '') and FACLOCID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    merge into gis.AKR_ASSET_PY_evw as t1 using 
      (SELECT t3.Asset, t4.Asset_Code FROM FMSSExport_Asset as t3 join FMSSExport as t4 on t3.Location = t4.Location) as t2
      on t1.FACASSETID = t2.Asset and (ASSETCODE is null or ASSETCODE = '') and FACASSETID is not null
      when matched then update set ASSETCODE = t2.Asset_Code;
    -- 5) ASSETTYPE - No calcs; NULL, Empty and not in DOM trigger QC Error
    -- 6) if ASSETTYPEOTHDESC is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set ASSETTYPEOTHDESC = NULL where ASSETTYPEOTHDESC = ''
    -- 7) if ASSETDESC is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set ASSETDESC = NULL where ASSETDESC = ''
    -- 8) if ASSETMATERIAL is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set ASSETMATERIAL = NULL where ASSETMATERIAL = ''
    -- 9) if ASSETDIAMETER_FT is zero then converted to Null.
    update gis.AKR_ASSET_PY_evw set ASSETDIAMETER_FT = NULL where ASSETDIAMETER_FT = 0
    -- 10) if ASSETLENGTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_PY_evw set ASSETLENGTH_FT = NULL where ASSETLENGTH_FT = 0
    -- 11) if ASSETWIDTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_PY_evw set ASSETWIDTH_FT = NULL where ASSETWIDTH_FT = 0
    -- 12) if ASSETDEPTH_FT is zero then converted to Null.
    update gis.AKR_ASSET_PY_evw set ASSETDEPTH_FT = NULL where ASSETDEPTH_FT = 0
    -- 13) if SEASONAL is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_PY_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.AKR_ASSET_PY_evw as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM dbo.FMSSExport_Asset as t1 JOIN dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    -- 14) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.AKR_ASSET_PY_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.AKR_ASSET_PY_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 15) if MAINTAINER is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_ASSET_PY_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_ASSET_PY_evw as p
      using (SELECT d.Code as FAMARESP, a.Asset FROM dbo.FMSSExport_Asset as a join dbo.FMSSExport as t on a.Location = t.Location
             join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    -- 16) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.AKR_ASSET_PY_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 17) Add POLYGONTYPE = 'Perimeter polygon' if null/empty
    update gis.AKR_ASSET_PY_evw set POLYGONTYPE = 'Perimeter polygon' where POLYGONTYPE is null or POLYGONTYPE = '' 
    -- 18) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.AKR_ASSET_PY_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- 19) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_ASSET_PY_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 20) DATAACCESS defaults to No Public Map Display
    update gis.AKR_ASSET_PY_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 21) UNITCODE is a spatial calc if null
    merge into gis.AKR_ASSET_PY_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 22) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_ASSET_PY_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_ASSET_PY_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 23) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 24) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_ASSET_PY_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_ASSET_PY_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 25) REGIONCODE is always set to AKR
    update gis.AKR_ASSET_PY_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- no CALCs for CREATEUSER, CREATEDATE, EDITUSER, EDITDATE (managed by system)
    -- 26) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_PY_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 27) if MAPSOURCE is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.AKR_ASSET_PY_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 28) SOURCEDATE: Nothing to do.
    -- 29) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.AKR_ASSET_PY_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 30) if FACLOCID is empty string change to null
    update gis.AKR_ASSET_PY_evw set FACLOCID = NULL where FACLOCID = ''
    -- 31) if FACASSETID is empty string change to null
    update gis.AKR_ASSET_PY_evw set FACASSETID = NULL where FACASSETID = ''
    -- 32) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_ASSET_PY_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 33) Add GEOMETRYID if null/empty
    update gis.AKR_ASSET_PY_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 34) if NOTES is an empty string, change to NULL
    update gis.AKR_ASSET_PY_evw set NOTES = NULL where NOTES = ''
    -- no CALCs for WEBEDITUSER, WEBCOMMENT


    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-08-30
-- Description:	Calculated properties for Attachments
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Attachments] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

	-- ATTACH_PT
	------------
	-- 1) OBJECTID: nothing to do
    -- 2) if ATCHNAME is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set ATCHNAME = NULL where ATCHNAME = ''
	merge into gis.AKR_ATTACH_evw as t1
      using (select f.Location, 'Photo of ' + d.Description AS ATCHNAME from dbo.FMSSExport as f join dbo.DOM_FMSS_ASSETCODE as d on f.Asset_Code = d.Code) as t2
      on t1.faclocid = t2.Location and t1.ATCHNAME IS NULL
      when matched then update set ATCHNAME = t2.ATCHNAME;
    -- 3) if ATCHALTNAME is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set ATCHALTNAME = NULL where ATCHALTNAME = ''
    -- 4) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 5) Add ATCHTYPE = 'Photo' if null/empty
    update gis.AKR_ATTACH_PT_evw set ATCHTYPE = 'Photo' where ATCHTYPE is null or ATCHTYPE = '' 
	-- 6) ATCHLINK: nothing to do
	-- 7) ATCHDATE: nothing to do
	-- 8) if ATCHSOURCE is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set ATCHSOURCE = NULL where ATCHSOURCE = ''
	-- 9) if ATCHDESC is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set ATCHDESC = NULL where ATCHDESC = ''
    -- 10) Add POINTYPE = 'Arbitrary point' if null/empty
    update gis.AKR_ATTACH_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = ''
	-- 11) ISOUTPARK must be calc'd after UNITCODE is calc'd (and QC'd) - See end of this procedure
	-- 12) HEADING: nothing to do
	-- 13) HFOV: if zero, set to NULL
    update gis.AKR_ATTACH_PT_evw set HFOV = NULL where HFOV = 0
	-- 14) PITCH: nothing to do
	-- 15) VFOV: if zero, set to NULL
    update gis.AKR_ATTACH_PT_evw set VFOV = NULL where VFOV = 0
	-- 16) Fix Altitude (if doesn't match shape Z)
    update gis.AKR_ATTACH_PT_evw set ALTITUDE = shape.Z where shape.Z <> 0 and (ALTITUDE is null or ABS(shape.Z - Altitude) > 0.0000001)
    -- 17) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_ATTACH_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 18) DATAACCESS defaults to No Public Map Display
    update gis.AKR_ATTACH_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 19) UNITCODE is a spatial calc if null
    merge into gis.AKR_ATTACH_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 20) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_ATTACH_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_ATTACH_PT_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 21) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 22) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_ATTACH_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_ATTACH_PT_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 23) REGIONCODE is always set to AKR
    update gis.AKR_ATTACH_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
	-- 24) CREATEDATE: nothing to do
	-- 25) CREATEUSER: nothing to do
	-- 26) EDITDATE: nothing to do
	-- 27) EDITUSER: nothing to do
    -- 28) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.AKR_ATTACH_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 29) if MAPSOURCE is NULL or an empty string, change to Unknown
    update gis.AKR_ATTACH_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 30) SOURCEDATE: Nothing to do.
    -- 31) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.AKR_ATTACH_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 32) if FACLOCID is empty string change to null
    update gis.AKR_ATTACH_PT_evw set FACLOCID = NULL where FACLOCID = ''
    -- 33) if FACASSETID is empty string change to null
    update gis.AKR_ATTACH_PT_evw set FACASSETID = NULL where FACASSETID = ''
    -- 34) if FEATUREID is empty string change to null
    update gis.AKR_ATTACH_PT_evw set FEATUREID = NULL where FEATUREID = ''
    -- 35) Add GEOMETRYID if null/empty
    update gis.AKR_ATTACH_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 36) if NOTES is an empty string, change to NULL
    update gis.AKR_ATTACH_PT_evw set NOTES = NULL where NOTES = ''
    -- 37) WEBEDITUSER: Nothing to do.
    -- 38) WEBCOMMENT: Nothing to do.
    -- 39) SHAPE: Update the Z value based on Altitude if Z value is missing
	update gis.AKR_ATTACH_PT_evw 
      set shape = geometry::STGeomFromText('POINT('+ltrim(str(shape.STX, 15,9))+' '+ltrim(str(shape.STY, 15,9))+' '+ltrim(str(ALTITUDE, 15,6))+')', 4269)
      where shape.Z = 0 and Altitude <> 0
    -- 11) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.AKR_ATTACH_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;

	-- ATTACH
	---------
	-- 1) OBJECTID: nothing to do
    -- 2) if BLDGNAME is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set ATCHNAME = NULL where ATCHNAME = ''
    -- 3) if BLDGALTNAME is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set ATCHALTNAME = NULL where ATCHALTNAME = ''
    -- 4) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 5) Add ATCHTYPE = 'Photo' if null/empty
    update gis.AKR_ATTACH_evw set ATCHTYPE = 'Photo' where ATCHTYPE is null or ATCHTYPE = '' 
	-- 6) ATCHLINK: nothing to do
	-- 7) ATCHDATE: nothing to do
	-- 8) if ATCHSOURCE is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set ATCHSOURCE = NULL where ATCHSOURCE = ''
	-- 9) if ATCHDESC is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set ATCHDESC = NULL where ATCHDESC = ''
    -- 10) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_ATTACH_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 11) DATAACCESS defaults to No Public Map Display
    update gis.AKR_ATTACH_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 12) UNITCODE: No shape, so we can't calc based on location
	--     TODO: calc based on shape or FMSS.PARK of foreign keys
    -- 13) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_ATTACH_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_ATTACH_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 14) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 15) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_ATTACH_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_ATTACH_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 16) REGIONCODE is always set to AKR
    update gis.AKR_ATTACH_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
	-- 17) CREATEDATE: nothing to do
	-- 18) CREATEUSER: nothing to do
	-- 19) EDITDATE: nothing to do
	-- 20) EDITUSER: nothing to do
    -- 21) if FACLOCID is empty string change to null
    update gis.AKR_ATTACH_evw set FACLOCID = NULL where FACLOCID = ''
    -- 22) if FACASSETID is empty string change to null
    update gis.AKR_ATTACH_evw set FACASSETID = NULL where FACASSETID = ''
    -- 23) if FEATUREID is empty string change to null
    update gis.AKR_ATTACH_evw set FEATUREID = NULL where FEATUREID = ''
    -- 24) if GEOMETRYID is empty string change to null
    update gis.AKR_ATTACH_evw set GEOMETRYID = NULL where GEOMETRYID = ''
    -- 25) Add ATCHID if null/empty
    update gis.AKR_ATTACH_evw set ATCHID = '{' + convert(varchar(max),newid()) + '}' where ATCHID is null or ATCHID = ''
    -- 26) if NOTES is an empty string, change to NULL
    update gis.AKR_ATTACH_evw set NOTES = NULL where NOTES = ''
    -- 27) WEBEDITUSER: Nothing to do.
    -- 28) WEBCOMMENT: Nothing to do.

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Buildings
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Buildings] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1a) Add POINTYPE = 'Center point' if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_BLDG_CENTER_PT_evw set POINTTYPE = 'Center point' where POINTTYPE is null or POINTTYPE = '' 
    -- 1b) Add POLYGONTYPE = 'Perimeter polygon' if null/empty in gis.AKR_BLDG_FOOTPRINT_PY
    update gis.AKR_BLDG_FOOTPRINT_PY_evw set POLYGONTYPE = 'Perimeter polygon' where POLYGONTYPE is null or POLYGONTYPE = '' 
    -- 2) Add GEOMETRYID if null/empty
    update gis.AKR_BLDG_CENTER_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    update gis.AKR_BLDG_OTHER_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    update gis.AKR_BLDG_FOOTPRINT_PY_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    update gis.AKR_BLDG_OTHER_PY_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 3) Add FEATUREID if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_BLDG_CENTER_PT_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 4) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.AKR_BLDG_CENTER_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    update gis.AKR_BLDG_OTHER_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    update gis.AKR_BLDG_FOOTPRINT_PY_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    update gis.AKR_BLDG_OTHER_PY_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 5) if MAPSOURCE is NULL or an empty string, change to Unknown
    --    by SQL Magic '' is the same as any string of just white space
    update gis.AKR_BLDG_CENTER_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    update gis.AKR_BLDG_OTHER_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    update gis.AKR_BLDG_FOOTPRINT_PY_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    update gis.AKR_BLDG_OTHER_PY_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 6) SOURCEDATE: Nothing to do.
    -- 7) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.AKR_BLDG_CENTER_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    update gis.AKR_BLDG_OTHER_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    update gis.AKR_BLDG_FOOTPRINT_PY_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    update gis.AKR_BLDG_OTHER_PY_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 8) if NOTES is an empty string, change to NULL
    update gis.AKR_BLDG_CENTER_PT_evw set NOTES = NULL where NOTES = ''
    update gis.AKR_BLDG_OTHER_PT_evw set NOTES = NULL where NOTES = ''
    update gis.AKR_BLDG_FOOTPRINT_PY_evw set NOTES = NULL where NOTES = ''
    update gis.AKR_BLDG_OTHER_PY_evw set NOTES = NULL where NOTES = ''
    -- 9) if BLDGNAME is an empty string, change to NULL
    update gis.AKR_BLDG_CENTER_PT_evw set BLDGNAME = NULL where BLDGNAME = ''
    -- 10) if BLDGALTNAME is an empty string, change to NULL
    update gis.AKR_BLDG_CENTER_PT_evw set BLDGALTNAME = NULL where BLDGALTNAME = ''
    -- 11) if MAPLABEL is an empty string, change to NULL
    update gis.AKR_BLDG_CENTER_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 12) if BLDGSTATUS; provide default value of Existing if missing
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
        using (SELECT t2.Standard as Status, Location FROM dbo.FMSSExport as t1 join dbo.DOM_FMSS_Status as t2 on t2.Code = t1.Status) as f
        on f.Location = p.FACLOCID and ((p.BLDGSTATUS is null or p.BLDGSTATUS = '' or p.BLDGSTATUS = 'Unknown') and f.Status is not null)
        when matched then update set BLDGSTATUS = f.Status;
    update gis.AKR_BLDG_CENTER_PT_evw set BLDGSTATUS = 'Existing' where BLDGSTATUS is null or BLDGSTATUS = ''
    -- 13/14) if BLDGCODE or BLDGTYPE is null but not the other replace null with lookup
    --     Be sure to set BLDGCODE from BLDGTYPE before comparing BLDGCODE to FMSS (do not compare BLDGTYPE to FMSS directly)
    merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using DOM_BLDGCODETYPE as t2
      on t1.BLDGTYPE = t2.Type and t1.BLDGCODE is null and t1.BLDGTYPE is not null and t2.Code is not null
      when matched then update set BLDGCODE = t2.Code;
    merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using DOM_BLDGCODETYPE as t2
      on t1.BLDGCODE = t2.Code and t1.BLDGTYPE is null and t1.BLDGCODE is not null and t2.Type is not null
      when matched then update set  BLDGTYPE = t2.Type;
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
      using (SELECT DOI_Code, Location FROM dbo.FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
      on f.Location = p.FACLOCID and (p.BLDGCODE is null and f.DOI_Code is not null)
      when matched then update set BLDGCODE = f.DOI_Code;
    -- 15) if FACOWNER is null and FACLOCID is non-null use FMSS Lookup.
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
      using (SELECT Asset_Ownership, Location FROM dbo.FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
      on f.Location = p.FACLOCID and (p.FACOWNER is null and f.Asset_Ownership is not null)
      when matched then update set FACOWNER = f.Asset_Ownership;
    -- 16) if FACOCCUPANT is null and FACLOCID is non-null use FMSS Lookup.
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
      using (SELECT Occupant, Location FROM dbo.FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
      on f.Location = p.FACLOCID and (p.FACOCCUPANT is null and f.Occupant is not null)
      when matched then update set FACOCCUPANT = f.Occupant;
    -- 17) if FACMAINTAIN is null and FACLOCID is non-null use FMSS Lookup.
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
      using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.FACMAINTAIN is null and f.FAMARESP is not null)
      when matched then update set FACMAINTAIN = f.FAMARESP;
    -- 18) if FACUSE is null and FACLOCID is non-null use FMSS Lookup.
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
      using (SELECT PRIMUSE, Location FROM dbo.FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
      on f.Location = p.FACLOCID and (p.FACUSE is null and f.PRIMUSE is not null)
      when matched then update set FACUSE = f.PRIMUSE;
    -- 19) if SEASONAL is null and FACLOCID is non-null use FMSS Lookup.
    merge into gis.AKR_BLDG_CENTER_PT_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    -- 20) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.AKR_BLDG_CENTER_PT_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.AKR_BLDG_CENTER_PT_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 21) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.AKR_BLDG_CENTER_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 22) PUBLICDISPLAY defaults to No Public Map Display
    update gis.AKR_BLDG_CENTER_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 23) DATAACCESS defaults to No Public Map Display
    update gis.AKR_BLDG_CENTER_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 24) UNITCODE is a spatial calc if null
    merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 25) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_BLDG_CENTER_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 26) if GROUPCODE is an empty string, change to NULL
    update gis.AKR_BLDG_CENTER_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 27) GROUPNAME is always calc'd from GROUPCODE
    update gis.AKR_BLDG_CENTER_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_BLDG_CENTER_PT_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 28) REGIONCODE is always set to AKR
    update gis.AKR_BLDG_CENTER_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- 29) if FACLOCID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set FACLOCID = NULL where FACLOCID = ''
    -- 30) if FACASSETID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set FACASSETID = NULL where FACASSETID = ''
    -- 31) if CRID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set CRID = NULL where CRID = ''
    -- 32) if ASMISID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set ASMISID = NULL where ASMISID = ''
    -- 33) if CLIID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set CLIID = NULL where CLIID = ''
    -- 34) if LCSID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set LCSID = NULL where LCSID = ''
    -- 35) if FIREBLDGID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set FIREBLDGID = NULL where FIREBLDGID = ''
    -- 36) if PARKBLDGID is empty string change to null
    update gis.AKR_BLDG_CENTER_PT_evw set PARKBLDGID = NULL where PARKBLDGID = ''
    -- 37) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.AKR_BLDG_CENTER_PT_evw as t1
      using (select c.GeometryID, u.Unit_Code, u.Shape as uShape, ISNULL(f.Shape, c.Shape) as fShape from gis.AKR_BLDG_CENTER_PT_evw as c join gis.AKR_UNIT as u on c.UNITCODE = u.Unit_Code left join gis.AKR_BLDG_FOOTPRINT_PY_evw as f on f.FEATUREID = c.FEATUREID) as t2
      on t1.GEOMETRYID = t2.GEOMETRYID and (t1.ISOUTPARK is null or CASE WHEN t2.uShape.STContains(fShape) = 1 THEN  'No' ELSE CASE WHEN t2.fShape.STIntersects(t2.uShape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.uShape.STContains(fShape) = 1 THEN  'No' ELSE CASE WHEN t2.fShape.STIntersects(t2.uShape) = 1 THEN 'Both' ELSE 'Yes' END END;

    -- POITYPE - if it is an empty string, change to NULL
    update gis.AKR_BLDG_CENTER_PT_evw set POITYPE = NULL where POITYPE = ''

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Parking Lots
-- =============================================
CREATE PROCEDURE [dbo].[Calc_ParkingLots] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if LOTNAME is an empty string, change to NULL
    update gis.PARKLOTS_PY_evw set LOTNAME = NULL where LOTNAME = ''
    -- 2) if LOTALTNAME is an empty string, change to NULL
    update gis.PARKLOTS_PY_evw set LOTALTNAME = NULL where LOTALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.PARKLOTS_PY_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) Add LOTTYPE = 'Parking Lot' if null in gis.PARKLOTS_PY
    update gis.PARKLOTS_PY_evw set LOTTYPE = 'Parking Lot' where LOTTYPE is null or LOTTYPE = '' 
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
    merge into gis.PARKLOTS_PY_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    -- 8) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.PARKLOTS_PY_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 9) Add POLYGONTYPE = 'Perimeter polygon' if null/empty in gis.PARKLOTS_PY
    update gis.PARKLOTS_PY_evw set POLYGONTYPE = 'Perimeter polygon' where POLYGONTYPE is null or POLYGONTYPE = '' 
    -- 10) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.PARKLOTS_PY_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- 11) PUBLICDISPLAY defaults to No Public Map Display
    update gis.PARKLOTS_PY_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 12) DATAACCESS defaults to No Public Map Display
    update gis.PARKLOTS_PY_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 13) UNITCODE is a spatial calc if null
    merge into gis.PARKLOTS_PY_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 14) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.PARKLOTS_PY_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.PARKLOTS_PY_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
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
	-- 27) LOTSTATUS - defaults to FMSSExport.Status or 'Existing'
    merge into gis.PARKLOTS_PY_evw as p
        using (SELECT t2.Standard as Status, Location FROM dbo.FMSSExport as t1 join dbo.DOM_FMSS_Status as t2 on t2.Code = t1.Status) as f
        on f.Location = p.FACLOCID and ((p.LOTSTATUS is null or p.LOTSTATUS = '' or p.LOTSTATUS = 'Unknown') and f.Status is not null)
        when matched then update set LOTSTATUS = f.Status;
    update gis.PARKLOTS_PY_evw set LOTSTATUS = 'Existing' where LOTSTATUS is null or LOTSTATUS = ''

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Road Feature Points
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Road_Features] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if RDFEATNAME is an empty string, change to NULL
    update gis.ROADS_FEATURE_PT_evw set RDFEATNAME = NULL where RDFEATNAME = ''
    -- 2) if RDFEATALTNAME is an empty string, change to NULL
    update gis.ROADS_FEATURE_PT_evw set RDFEATALTNAME = NULL where RDFEATALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.ROADS_FEATURE_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) RDFEATTYPE - Required Domain Value; no default value; nothing to do.
    -- 5) RDFEATTYPEOTHER: This is an AKR extension; it is optional free text.  Set empty string to null
    update gis.ROADS_FEATURE_PT_evw set RDFEATTYPEOTHER = null where RDFEATTYPEOTHER = ''
    update gis.ROADS_FEATURE_PT_evw set RDFEATTYPEOTHER = null where RDFEATTYPE <> 'Other' and RDFEATTYPEOTHER <> null 
    -- 6) RDFEATSUBTYPE: This is an AKR extension; it is optional free text.  Set empty string to null
    update gis.ROADS_FEATURE_PT_evw set RDFEATSUBTYPE = NULL where RDFEATSUBTYPE = ''
    -- 7) RDFEATDESC is an AKR extension; it is optional free text.  Set empty string to null
    update gis.ROADS_FEATURE_PT_evw set RDFEATDESC = NULL where RDFEATDESC = ''
    -- 8) RDFEATCOUNT is an AKR extension; it silently clears zero to null
    update gis.ROADS_FEATURE_PT_evw set RDFEATCOUNT = NULL where RDFEATCOUNT = 0
    -- 9) WHLENGTH is an AKR extension; it silently clears zero to null
    update gis.ROADS_FEATURE_PT_evw set WHLENGTH = NULL where WHLENGTH = 0
    -- 10) WHLENUOM  is an AKR extension; it silently defaults to 'No'
    update gis.ROADS_FEATURE_PT_evw set WHLENUOM = NULL where WHLENUOM = ''
    update gis.ROADS_FEATURE_PT_evw set WHLENUOM = NULL where WHLENGTH is NULL and WHLENUOM is not null
    -- 11) POINTTYPE: if it is null/empty, then it will default to 'Arbitrary point'
    update gis.ROADS_FEATURE_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = '' 
    -- 12) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.ROADS_FEATURE_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 13) ISOUTPARK (See the end, this must be done after UNITCODE)
    -- 14) PUBLICDISPLAY defaults to No Public Map Display
    update gis.ROADS_FEATURE_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 15) DATAACCESS defaults to No Public Map Display
    update gis.ROADS_FEATURE_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 16) UNITCODE is a spatial calc if null
    merge into gis.ROADS_FEATURE_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 17) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.ROADS_FEATURE_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.ROADS_FEATURE_PT_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 18) if GROUPCODE is an empty string, change to NULL
    update gis.ROADS_FEATURE_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 19) GROUPNAME is always calc'd from GROUPCODE
    update gis.ROADS_FEATURE_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.ROADS_FEATURE_PT_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 20) REGIONCODE is always set to AKR
    update gis.ROADS_FEATURE_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- 21) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.ROADS_FEATURE_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 22) if MAPSOURCE is NULL or an empty string, change to Unknown
    update gis.ROADS_FEATURE_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 23) SOURCEDATE: Nothing to do.
    -- 24) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.ROADS_FEATURE_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 25) if FACLOCID is empty string change to null
    update gis.ROADS_FEATURE_PT_evw set FACLOCID = NULL where FACLOCID = ''
    -- 26) if FACASSETID is empty string change to null
    update gis.ROADS_FEATURE_PT_evw set FACASSETID = NULL where FACASSETID = ''
    -- 27) Add FEATUREID is NULL or an empty string
    update gis.ROADS_FEATURE_PT_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 28) Add GEOMETRYID if null/empty
    update gis.ROADS_FEATURE_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 29) if NOTES is an empty string, change to NULL
    update gis.ROADS_FEATURE_PT_evw set NOTES = NULL where NOTES = ''
    -- 30) SEGMENTID is calced if null;
    merge into gis.ROADS_FEATURE_PT_evw as t1 using 
      (
        SELECT p.GEOMETRYID AS POINTID, LINEID
        FROM gis.roads_feature_pt_evw AS p
        CROSS APPLY (
            SELECT TOP 1 GEOMETRYID AS LINEID
            FROM gis.ROADS_LN_evw AS l
            WHERE  p.SEGMENTID IS NULL AND p.UNITCODE = l.UNITCODE AND l.Shape.STDistance(p.Shape) IS NOT NULL
            ORDER BY l.Shape.STDistance(p.Shape)
            ) AS b
      ) as t2
      on t1.GEOMETRYID = t2.POINTID
      when matched then update set SEGMENTID = t2.LINEID;
    -- 13) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.ROADS_FEATURE_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Roads
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Roads] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) if RDNAME is an empty string, default to FMSS.Description or NULL
    merge into gis.ROADS_LN_evw as p
        using dbo.FMSSExport as f
        on f.Location = p.FACLOCID and ((p.RDNAME is null or p.RDNAME = '' or p.RDSTATUS = 'Unknown') and f.Description is not null)
        when matched then update set RDNAME = f.Description;
    update gis.ROADS_LN_evw set RDNAME = NULL where RDNAME = ''
    -- 2) if RDALTNAME is an empty string, change to NULL
    update gis.ROADS_LN_evw set RDALTNAME = NULL where RDALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.ROADS_LN_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) RDSTATUS - defaults FMSSExport.Status or 'Existing'
    merge into gis.ROADS_LN_evw as p
        using (SELECT t2.Standard as Status, Location FROM dbo.FMSSExport as t1 join dbo.DOM_FMSS_Status as t2 on t2.Code = t1.Status) as f
        on f.Location = p.FACLOCID and ((p.RDSTATUS is null or p.RDSTATUS = '' or p.RDSTATUS = 'Unknown') and f.Status is not null)
        when matched then update set RDSTATUS = f.Status;
    update gis.ROADS_LN_evw set RDSTATUS = 'Existing' where RDSTATUS is null or RDSTATUS = ''
    -- 5) RDCLASS defaults FMSSExport.FCLASS or 'Unknown'
    merge into gis.ROADS_LN_evw as p
        using (SELECT t2.Standard as FCLASS, Location FROM dbo.FMSSExport as t1 join dbo.DOM_FMSS_FunctionalClass as t2 on t2.Code = t1.FCLASS) as f
        on f.Location = p.FACLOCID and ((p.RDCLASS is null or p.RDCLASS = '' or p.RDCLASS = 'Unknown') and f.FCLASS is not null)
        when matched then update set RDCLASS = f.FCLASS;
    update gis.ROADS_LN_evw set RDCLASS = 'Unknown' where RDCLASS is null or RDCLASS = ''
    -- 6) RDSURFACE defaults FMSS.Predominant_Use/Facility_Type or 'Unknown'
    --      Unfortunately, the FMSS attributes provide clues, but not a definitive answer.
    --      Fortunately in AKR, Paved can be assumed to mean Ashpalt, and Unpaved can be assumed to mean Gravel.
    merge into gis.ROADS_LN_evw as p
        using (select Location, CASE WHEN Predominant_Use like '% paved%' or Facility_Type = '1110' THEN 'Asphalt'
         WHEN Facility_Type = '1120' and (Predominant_Use like '%unpaved%' or Predominant_Use like '%gravel%' or Predominant_Use is null) THEN 'Gravel' 
         WHEN Predominant_Use like '%dirt%' THEN 'Native or Dirt' END as Surface from FMSSExport) as f
        on f.Location = p.FACLOCID and ((p.RDSURFACE is null or p.RDSURFACE = '' or p.RDSURFACE = 'Unknown') and f.Surface is not null)
        when matched then update set RDSURFACE = f.Surface;
    update gis.ROADS_LN_evw set RDSURFACE = 'Unknown' where RDSURFACE is null or RDSURFACE = ''
    -- 7) RDONEWAY is not required, but if it provided is it should not be an empty string
    update gis.ROADS_LN_evw set RDONEWAY = NULL where RDONEWAY = ''
    -- 9) RDLANES defaults to FMSS.NOLANE or NULL.
    merge into gis.ROADS_LN_evw as p
        using (SELECT convert(int,convert(real,NOLANE)) as NOLANE, Location FROM dbo.FMSSExport) as f
        on f.Location = p.FACLOCID and ((p.RDLANES is null or p.RDLANES = 0) and f.NOLANE is not null)
        when matched then update set RDLANES = f.NOLANE;
    -- 10) RDHICLEAR is not required, but if it provided is it should not be an empty string
    update gis.ROADS_LN_evw set RDHICLEAR = NULL where RDHICLEAR = ''
    -- 11) RTENUMBER is not required, but if it provided is it should not be an empty string
    update gis.ROADS_LN_evw set RTENUMBER = NULL where RTENUMBER = ''
    -- 12) ISBRIDGE is an AKR extension; it defaults to 'Yes' if FMSS.Asset_Code = 1700 otherwise 'No'
    merge into gis.ROADS_LN_evw as p
        using dbo.FMSSExport as f
        on f.Location = p.FACLOCID and ((p.ISBRIDGE is null or p.ISBRIDGE = '') and f.Asset_Code = '1700')
        when matched then update set ISBRIDGE = 'Yes';
    update gis.ROADS_LN_evw set ISBRIDGE = 'No' where ISBRIDGE is null or ISBRIDGE = ''
    -- 13) ISTUNNEL is an AKR extension; it defaults to 'Yes' if FMSS.Asset_Code = 1800 otherwise 'No'
    merge into gis.ROADS_LN_evw as p
        using dbo.FMSSExport as f
        on f.Location = p.FACLOCID and ((p.ISTUNNEL is null or p.ISTUNNEL = '') and f.Asset_Code = '1800')
        when matched then update set ISTUNNEL = 'Yes';
    update gis.ROADS_LN_evw set ISTUNNEL = 'No' where ISTUNNEL is null or ISTUNNEL = ''
    -- 14) SEASONAL defaults to FMSS.OPSEAS or Null.
    merge into gis.ROADS_LN_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else NULL end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null or p.SEASONAL = '' or p.SEASONAL = 'Unknown') and f.OPSEAS is not null
      when matched then update set SEASONAL = f.OPSEAS;
    -- 15) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.ROADS_LN_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.ROADS_LN_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 16) RDMAINTAINER defaults to FMSSExport.FAMARESP (mapped) or Null
    merge into gis.ROADS_LN_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.RDMAINTAINER is null or p.RDMAINTAINER = '' or p.RDMAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set RDMAINTAINER = f.FAMARESP;
    -- 17) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.ROADS_LN_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 18) Add LINETYPE = 'Center line' if null/empty in gis.ROADS_LN
    update gis.ROADS_LN_evw set LINETYPE = 'Center line' where LINETYPE is null or LINETYPE = '' 
    -- 19) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.ROADS_LN_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- 20) PUBLICDISPLAY defaults to No Public Map Display
    update gis.ROADS_LN_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 21) DATAACCESS defaults to No Public Map Display
    update gis.ROADS_LN_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 22) UNITCODE is a spatial calc if null
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
    --     It should also be set to FMSS.ROUTEID if applicable
    merge into gis.ROADS_LN_evw as p
        using dbo.FMSSExport as f
        on f.Location = p.FACLOCID and ((p.ROUTEID is null or p.ROUTEID = '' or p.ROUTEID = 'Unknown') and f.ROUTEID is not null)
        when matched then update set ROUTEID = f.ROUTEID;
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

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Trail Attribute Points
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Trail_Attributes] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- 1) TRLATTRTYPE - Required Domain Value; no default value; nothing to do.
    -- 2) TRLATTRTYPEOTHER: This is an AKR extension; it is optional free text.  Set empty string to null
    update gis.TRAILS_ATTRIBUTE_PT_evw set TRLATTRTYPEOTHER = null where TRLATTRTYPEOTHER = ''
    update gis.TRAILS_ATTRIBUTE_PT_evw set TRLATTRTYPEOTHER = null where TRLATTRTYPE <> 'Other' and TRLATTRTYPEOTHER <> null 
    -- 3) TRLATTRVALUE: This is an AKR extension; it is optional free text.  Set empty string to null
    update gis.TRAILS_ATTRIBUTE_PT_evw set TRLATTRVALUE = NULL where TRLATTRVALUE = ''
    -- 4) TRLATTRDESC is an AKR extension; it is optional free text.  Set empty string to null
    update gis.TRAILS_ATTRIBUTE_PT_evw set TRLATTRDESC = NULL where TRLATTRDESC = ''

    -- 5) WHLENGTH is an AKR extension; it silently clears zero to null
    update gis.TRAILS_ATTRIBUTE_PT_evw set WHLENGTH = NULL where WHLENGTH = 0
    -- 6) WHLENUOM  is an AKR extension; it silently defaults to 'No'
    update gis.TRAILS_ATTRIBUTE_PT_evw set WHLENUOM = NULL where WHLENUOM = ''
    update gis.TRAILS_ATTRIBUTE_PT_evw set WHLENUOM = NULL where WHLENGTH is NULL and WHLENUOM is not null
    -- 7) POINTTYPE: if it is null/empty, then it will default to 'Arbitrary point'
    update gis.TRAILS_ATTRIBUTE_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = '' 
    -- 8) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.TRAILS_ATTRIBUTE_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 9) ISOUTPARK (See the end, this must be done after UNITCODE)
    -- 10) PUBLICDISPLAY defaults to No Public Map Display
    update gis.TRAILS_ATTRIBUTE_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 11) DATAACCESS defaults to No Public Map Display
    update gis.TRAILS_ATTRIBUTE_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 12) UNITCODE is a spatial calc if null
    merge into gis.TRAILS_ATTRIBUTE_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 13) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.TRAILS_ATTRIBUTE_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.TRAILS_ATTRIBUTE_PT_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 14) if GROUPCODE is an empty string, change to NULL
    update gis.TRAILS_ATTRIBUTE_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 15) GROUPNAME is always calc'd from GROUPCODE
    update gis.TRAILS_ATTRIBUTE_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.TRAILS_ATTRIBUTE_PT_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 16) REGIONCODE is always set to AKR
    update gis.TRAILS_ATTRIBUTE_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- 17) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.TRAILS_ATTRIBUTE_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 18) if MAPSOURCE is NULL or an empty string, change to Unknown
    update gis.TRAILS_ATTRIBUTE_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 19) SOURCEDATE: Nothing to do.
    -- 20) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.TRAILS_ATTRIBUTE_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 21) if FACLOCID is empty string change to null
    update gis.TRAILS_ATTRIBUTE_PT_evw set FACLOCID = NULL where FACLOCID = ''
    -- 22) if FACASSETID is empty string change to null
    update gis.TRAILS_ATTRIBUTE_PT_evw set FACASSETID = NULL where FACASSETID = ''
    -- 23) FEATUREID: No action
    -- 24) Add GEOMETRYID if null/empty
    update gis.TRAILS_ATTRIBUTE_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 25) if NOTES is an empty string, change to NULL
    update gis.TRAILS_ATTRIBUTE_PT_evw set NOTES = NULL where NOTES = ''
    -- 9) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.TRAILS_ATTRIBUTE_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
	-- 26) SEGMENTID is the GEOMETRYID of the TRAILS_LN that this point touches
    merge into gis.TRAILS_ATTRIBUTE_PT_evw as a
      using gis.TRAILS_LN_evw as t
      on a.SEGMENTID is null and a.Shape.STIntersects(t.Shape) = 1
      and (a.FACLOCID = t.FACLOCID or a.FACLOCID is NULL) and (a.FEATUREID = t.FEATUREID or a.FEATUREID is NULL)
      when matched then update set SEGMENTID = t.GEOMETRYID;

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Trail Feature Points
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Trail_Features] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

-- 1) if TRLFEATNAME is an empty string, change to NULL
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATNAME = NULL where TRLFEATNAME = ''
    -- 2) if TRLFEATALTNAME is an empty string, change to NULL
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATALTNAME = NULL where TRLFEATALTNAME = ''
    -- 3) if MAPLABEL is an empty string, change to NULL
    update gis.TRAILS_FEATURE_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
    -- 4) TRLFEATTYPE - Required Domain Value; no default value; nothing to do.
    -- 5) TRLFEATTYPEOTHER: This is an AKR extension; it is optional free text.  Set empty string to null
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATTYPEOTHER = null where TRLFEATTYPEOTHER = ''
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATTYPEOTHER = null where TRLFEATTYPE <> 'Other' and TRLFEATTYPEOTHER <> null 
    -- 6) TRLFEATSUBTYPE: This is an AKR extension; it is optional free text.  Set empty string to null
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATSUBTYPE = NULL where TRLFEATSUBTYPE = ''
    -- 7) TRLFEATDESC is an AKR extension; it is optional free text.  Set empty string to null
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATDESC = NULL where TRLFEATDESC = ''
    -- 8) TRLFEATCOUNT is an AKR extension; it silently clears zero to null
    update gis.TRAILS_FEATURE_PT_evw set TRLFEATCOUNT = NULL where TRLFEATCOUNT = 0
    -- 9) WHLENGTH is an AKR extension; it silently clears zero to null
    update gis.TRAILS_FEATURE_PT_evw set WHLENGTH = NULL where WHLENGTH = 0
    -- 10) WHLENUOM  is an AKR extension; it silently defaults to 'No'
    update gis.TRAILS_FEATURE_PT_evw set WHLENUOM = NULL where WHLENUOM = ''
    update gis.TRAILS_FEATURE_PT_evw set WHLENUOM = NULL where WHLENGTH is NULL and WHLENUOM is not null
    -- 11) POINTTYPE: if it is null/empty, then it will default to 'Arbitrary point'
    update gis.TRAILS_FEATURE_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = '' 
    -- 12) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.TRAILS_FEATURE_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 13) ISOUTPARK (See the end, this must be done after UNITCODE)
    -- 14) PUBLICDISPLAY defaults to No Public Map Display
    update gis.TRAILS_FEATURE_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 15) DATAACCESS defaults to No Public Map Display
    update gis.TRAILS_FEATURE_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 16) UNITCODE is a spatial calc if null
    merge into gis.TRAILS_FEATURE_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
    -- 17) UNITNAME is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.TRAILS_FEATURE_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.TRAILS_FEATURE_PT_evw as t1 using DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;
    -- 18) if GROUPCODE is an empty string, change to NULL
    update gis.TRAILS_FEATURE_PT_evw set GROUPCODE = NULL where GROUPCODE = ''
    -- 19) GROUPNAME is always calc'd from GROUPCODE
    update gis.TRAILS_FEATURE_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.TRAILS_FEATURE_PT_evw as t1 using gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;
    -- 20) REGIONCODE is always set to AKR
    update gis.TRAILS_FEATURE_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'
    -- 21) if MAPMETHOD is NULL or an empty string, change to Unknown
    update gis.TRAILS_FEATURE_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''
    -- 22) if MAPSOURCE is NULL or an empty string, change to Unknown
    update gis.TRAILS_FEATURE_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''
    -- 23) SOURCEDATE: Nothing to do.
    -- 24) if XYACCURACY is NULL or an empty string, change to Unknown
    update gis.TRAILS_FEATURE_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''
    -- 25) if FACLOCID is empty string change to null
    update gis.TRAILS_FEATURE_PT_evw set FACLOCID = NULL where FACLOCID = ''
    -- 26) if FACASSETID is empty string change to null
    update gis.TRAILS_FEATURE_PT_evw set FACASSETID = NULL where FACASSETID = ''
    -- 27) Add FEATUREID is NULL or an empty string
    update gis.TRAILS_FEATURE_PT_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''
    -- 28) Add GEOMETRYID if null/empty
    update gis.TRAILS_FEATURE_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''
    -- 29) if NOTES is an empty string, change to NULL
    update gis.TRAILS_FEATURE_PT_evw set NOTES = NULL where NOTES = ''
    -- 13) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.TRAILS_FEATURE_PT_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;

    -- POITYPE - if it is an empty string, change to NULL
    update gis.TRAILS_FEATURE_PT_evw set POITYPE = NULL where POITYPE = ''

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2018-07-13
-- Description:	Calculated properties for Trails
-- =============================================
CREATE PROCEDURE [dbo].[Calc_Trails] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- Per the standard, Possible TSDS fields that can be populated using FMSS data are: 
    --     TRLNAME, TRLALTNAME, TRLSTATUS, TRLCLASS, TRLSURFACE, TRLTYPE, TRLUSE, SEASONAL, SEADESC, MAINTAINER, ISEXTENT, RESTRICTIION and ASSETID.
	--   DONE: TRLSTATUS, SEASONAL, MAINTAINER, TRLCLASS, TRLSURFACE
	--   SKIP: TRLNAME, TRLALTNAME, TRLTYPE, TRLUSE, SEADESC, ISEXTENT, RESTRICTIION and ASSETID

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
        using (SELECT t2.Standard as Status, Location FROM dbo.FMSSExport as t1 join dbo.DOM_FMSS_Status as t2 on t2.Code = t1.Status) as f
        on f.Location = p.FACLOCID and ((p.TRLSTATUS is null or p.TRLSTATUS = '' or p.TRLSTATUS = 'Unknown' or p.TRLSTATUS = 'Not Applicable') and f.Status is not null)
        when matched then update set TRLSTATUS = f.Status;
    update gis.TRAILS_LN_evw set TRLSTATUS = 'Existing' where TRLSTATUS is null or TRLSTATUS = ''
    -- 5a) TRLTYPE - Required Domain Value; defaults to 'Standard Terra Trail' with a warning
    update gis.TRAILS_LN_evw set TRLTYPE = 'Standard Terra Trail' where TRLTYPE is null or TRLTYPE = ''
    -- 6) TRLTRACK: This is an AKR extension; Required domain element; defaults to 'Unknown'
    update gis.TRAILS_LN_evw set TRLTRACK = 'Unknown' where TRLTRACK is null or TRLTRACK = ''
    -- 7) TRLCLASS defaults to FMSSExport.FeatureType (via transformation) or to 'Unknown'
    merge into gis.TRAILS_LN_evw as p
      using (SELECT d.Code as CLASS, location FROM dbo.FMSSExport as t join dbo.DOM_TRLCLASS as d on t.Facility_Type = d.FMSS_Facility_Type) as f
      on f.Location = p.FACLOCID and (TRLCLASS is null or TRLCLASS = '' or TRLCLASS = 'Unknown') and f.CLASS is not null
      when matched then update set TRLCLASS = f.CLASS;
    update gis.TRAILS_LN_evw set TRLCLASS = 'Unknown' where TRLCLASS is null or TRLCLASS = ''
    -- 8) TRLUSE_* -- Nothing to do, invalid values (including empty string) will generate an error
    -- 8) TRLUSE: Calculate from TRLUSE_*
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
    -- 11) TRLISADMIN is an AKR extension; it silently defaults FMSS.PRIMUSE (via transform) or 'No'
	merge into gis.TRAILS_LN_evw as p
      using (SELECT Location, case when PRIMUSE = 'Admin Use' then 'Yes' when PRIMUSE is null then null else 'No' end as PRIMUSE FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (TRLISADMIN is null or TRLISADMIN = '') and f.PRIMUSE is not null
      when matched then update set TRLISADMIN = f.PRIMUSE;
    update gis.TRAILS_LN_evw set TRLISADMIN = 'No' where TRLISADMIN is null or TRLISADMIN = ''
    -- 12) TRLSURFACE defaults to FMSS.TREADTYP (via transform) or 'Unknown'
    merge into  gis.TRAILS_LN_evw as p
      using (SELECT d.Code as TREADTYP, location FROM dbo.FMSSExport as t join dbo.DOM_TRLSURFACE as d on t.TREADTYP = d.FMSS_TREADTYP and d.FMSS_Default = 'Y') as f
      on f.Location = p.FACLOCID and (TRLSURFACE is null or TRLSURFACE = '' or TRLSURFACE = 'Unknown') and f.TREADTYP is not null
      when matched then update set TRLSURFACE = f.TREADTYP;
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
    merge into gis.TRAILS_LN_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else NULL end as OPSEAS, location FROM dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null or p.SEASONAL = '' or p.SEASONAL = 'Unknown') and f.OPSEAS is not null
      when matched then update set SEASONAL = f.OPSEAS;
    -- 18) if SEASDESC is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.TRAILS_LN_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.TRAILS_LN_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'
    -- 19) if MAINTAINER is null and FACLOCID is non-null use FMSS Lookup.
    merge into gis.TRAILS_LN_evw as p
      using (SELECT d.Code as FAMARESP, location FROM dbo.FMSSExport as t join dbo.DOM_MAINTAINER as d on t.FAMARESP = d.FMSS) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;
    -- 20) ISEXTANT defaults to 'True' with a warning (during QC)
    update gis.TRAILS_LN_evw set ISEXTANT = 'True' where ISEXTANT is NULL
    -- 21) Add LINETYPE = 'Center line' if null/empty in gis.ROADS_LN
    update gis.TRAILS_LN_evw set LINETYPE = 'Center line' where LINETYPE is null or LINETYPE = '' 
    -- 22) ISOUTPARK is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    --     Takes about 26 seconds on the base table;  To check for both in/out takes about 51 seconds on base table
    merge into gis.TRAILS_LN_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- Adds a check for both in/out 
    merge into gis.TRAILS_LN_evw as t1 using gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
    -- 23) PUBLICDISPLAY defaults to No Public Map Display
    update gis.TRAILS_LN_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''
    -- 24) DATAACCESS defaults to No Public Map Display
    update gis.TRAILS_LN_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''
    -- 25) UNITCODE is a spatial calc if null
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

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
