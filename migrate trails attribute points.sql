----------------------------
-- Update TRAIL_ATTRIBUTE_PT
----------------------------

CREATE TABLE [gis].[TRAILS_ATTRIBUTE_PT](
	[OBJECTID] [int] NOT NULL,
	[TRLATTRTYPE] [nvarchar](50) NULL,
	[TRLATTRTYPEOTHER] [nvarchar](50) NULL,
	[TRLATTRVALUE] [nvarchar](254) NULL,
	[TRLATTRDESC] [nvarchar](254) NULL,
	[WHLENGTH] [numeric](38, 8) NULL,
	[WHLENUOM] [nvarchar](50) NULL,
	[POINTTYPE] [nvarchar](50) NULL,
	[ISEXTANT] [nvarchar](20) NULL,
	[ISOUTPARK] [nvarchar](10) NULL,
	[PUBLICDISPLAY] [nvarchar](50) NULL,
	[DATAACCESS] [nvarchar](50) NULL,
	[UNITCODE] [nvarchar](10) NULL,
	[UNITNAME] [nvarchar](254) NULL,
	[GROUPCODE] [nvarchar](10) NULL,
	[GROUPNAME] [nvarchar](254) NULL,
	[REGIONCODE] [nvarchar](4) NULL,
	[CREATEDATE] [datetime2](7) NULL,
	[CREATEUSER] [nvarchar](50) NULL,
	[EDITDATE] [datetime2](7) NULL,
	[EDITUSER] [nvarchar](50) NULL,
	[MAPMETHOD] [nvarchar](254) NULL,
	[MAPSOURCE] [nvarchar](254) NULL,
	[SOURCEDATE] [datetime2](7) NULL,
	[XYACCURACY] [nvarchar](50) NULL,
	[FACLOCID] [nvarchar](10) NULL,
	[FACASSETID] [nvarchar](10) NULL,
	[FEATUREID] [nvarchar](50) NULL,
	[GEOMETRYID] [nvarchar](38) NULL,
	[NOTES] [nvarchar](254) NULL,
	[WEBEDITUSER] [nvarchar](50) NULL,
	[WEBCOMMENT] [nvarchar](254) NULL,
	[Shape] [geometry] NULL,
 CONSTRAINT [TRAILS_ATTRIBUTE_PT_OBJECTID_pk] PRIMARY KEY CLUSTERED 
(
	[OBJECTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [gis].[TRAILS_ATTRIBUTE_PT]  WITH CHECK ADD  CONSTRAINT [TRAILS_ATTRIBUTE_PT_Shape_ck] CHECK  (([Shape].[STSrid]=(4269)))
GO

ALTER TABLE [gis].[TRAILS_ATTRIBUTE_PT] CHECK CONSTRAINT [TRAILS_ATTRIBUTE_PT_Shape_ck]
GO

SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE SPATIAL INDEX [TRAILS_ATTRIBUTE_PT_shape_idx] ON [gis].[TRAILS_ATTRIBUTE_PT]
(
	[Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- Any records that might not fit in the truncated fields?
select Notes, len(Notes), mapsource, len(mapsource), TRLATTRVALUE, len(TRLATTRVALUE), TRLATTRDESC, len(TRLATTRDESC) from gis.TRAILS_ATTRIBUTE_PT_OLD where len(Notes) > 254 or len(mapsource) > 254 or len(TRLATTRVALUE) > 254 or len(TRLATTRDESC) > 254
-- No

--Load data
INSERT INTO [akr_facility2].[gis].[TRAILS_ATTRIBUTE_PT]
      ([OBJECTID]
      ,[TRLATTRTYPE]
      ,[TRLATTRTYPEOTHER]
      ,[TRLATTRVALUE]
      ,[TRLATTRDESC]
      ,[WHLENGTH]
      ,[WHLENUOM]
      ,[POINTTYPE]
      ,[ISEXTANT]
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
      ,[FEATUREID]
      ,[GEOMETRYID]
      ,[NOTES]
      ,[WEBEDITUSER]
      ,[WEBCOMMENT]
      ,[Shape])
SELECT 
	   [OBJECTID]
      ,[TRLATTRTYPE]
      ,[TRLATTRTYPEOTHER]
      ,[TRLATTRVALUE]
      ,[TRLATTRDESC]
      ,[WHLENGTH]
      ,[WHLENUOM]
	  ,'Arbitrary point'
      ,[ISEXTANT]
	  ,NULL
      ,[DISTRIBUTE]
      ,[RESTRICTION]
      ,[UnitCode]
      ,[UnitName]
--    ,[UnitType]
      ,[GROUPCODE]
	  ,NULL
      ,[REGIONCODE]
      ,[CREATEDATE]
      ,[CREATEUSER]
      ,[EDITDATE]
      ,[EDITUSER]
      ,[MAPMETHOD]
      ,[MAPSOURCE]
      ,[SOURCEDATE]
--      ,[SRCESCALE]
      ,[XYERROR]
--      ,[ZERROR]
      ,[LOCATIONID]
      ,[ASSETID]
      ,[FeatureID]
      ,[GEOMETRYID]
      ,[NOTES]
--      ,[Load_File_Name]
	  ,NULL
	  ,NULL
      ,[Shape]
  FROM [akr_facility2].[gis].[TRAILS_ATTRIBUTE_PT_OLD]


-- FIX ISEXTANT
SELECT ISEXTANT, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by ISEXTANT order by ISEXTANT
update gis.TRAILS_ATTRIBUTE_PT set ISEXTANT = 'Unknown' where ISEXTANT is null
update gis.TRAILS_ATTRIBUTE_PT set ISEXTANT = 'True' where ISEXTANT = 'Yes'

-- FIX PUBLICDISPLAY
SELECT PUBLICDISPLAY, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by PUBLICDISPLAY order by PUBLICDISPLAY
SELECT PUBLICDISPLAY, DATAACCESS, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by PUBLICDISPLAY, DATAACCESS order by PUBLICDISPLAY, DATAACCESS
update gis.TRAILS_ATTRIBUTE_PT set PUBLICDISPLAY = 'Public Map Display' where PUBLICDISPLAY is null and DATAACCESS = 'Unrestricted'

-- FIX DATAACCESS
SELECT DATAACCESS, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by DATAACCESS order by DATAACCESS
SELECT PUBLICDISPLAY, DATAACCESS, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by PUBLICDISPLAY, DATAACCESS order by PUBLICDISPLAY, DATAACCESS
update gis.TRAILS_ATTRIBUTE_PT set DATAACCESS = 'Unrestricted' where DATAACCESS = 'Agency Concurrence'

-- FIX MAPMETHOD
SELECT MAPMETHOD, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by MAPMETHOD order by MAPMETHOD
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'GNSS: Mapping Grade' where MAPMETHOD = 'Mapping Grade GPS'
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'GNSS: Mapping Grade' where MAPMETHOD = 'See Map Source' and mapsource like '%Mapping Grade GPS%'
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'GNSS: Consumer Grade' where MAPMETHOD = 'See Map Source' and mapsource like '%GPS%'
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'Digitized' where MAPMETHOD = 'See Map Source' and mapsource like '%Digitized%'
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'Unknown' where MAPMETHOD = 'See Map Source' and (mapsource like '%Source of data ""%' or mapsource like '%Source of data "unk"%')
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'Other' where MAPMETHOD = 'Manual'
update gis.TRAILS_ATTRIBUTE_PT set MAPMETHOD = 'Other' where MAPMETHOD = 'See Map Source'

-- FIX XYACCURACY
SELECT XYACCURACY, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by XYACCURACY order by XYACCURACY
SELECT XYACCURACY, MAPSOURCE FROM gis.TRAILS_ATTRIBUTE_PT where XYACCURACY = '> 15 cm and <= 1 m' and MAPSOURCE like '%XH%'

update gis.TRAILS_ATTRIBUTE_PT set XYACCURACY = '>=5cm and <50cm' where XYACCURACY = '<= 15 cm'
update gis.TRAILS_ATTRIBUTE_PT set XYACCURACY = '>=1m and <5m' where XYACCURACY = '> 1 m and <= 5 m'
update gis.TRAILS_ATTRIBUTE_PT set XYACCURACY = '>=14m' where XYACCURACY = '> 10 m'
update gis.TRAILS_ATTRIBUTE_PT set XYACCURACY = '>=5cm and <50cm' where XYACCURACY = '> 15 cm and <= 1 m'  and MAPSOURCE like '%XH%'
update gis.TRAILS_ATTRIBUTE_PT set XYACCURACY = '>=50cm and <1m' where XYACCURACY = '> 15 cm and <= 1 m'
update gis.TRAILS_ATTRIBUTE_PT set XYACCURACY = '>=5m and <14m' where XYACCURACY = '> 5 m and <= 10 m'

-- FIX Miscellaneous
SELECT TRLATTRTYPE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by TRLATTRTYPE order by TRLATTRTYPE
SELECT TRLATTRTYPEOTHER, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by TRLATTRTYPEOTHER order by TRLATTRTYPEOTHER
SELECT TRLATTRDESC, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by TRLATTRDESC order by TRLATTRDESC
SELECT TRLATTRVALUE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by TRLATTRVALUE order by TRLATTRVALUE
SELECT TRLATTRTYPE, TRLATTRTYPEOTHER, TRLATTRDESC, TRLATTRVALUE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by TRLATTRTYPE, TRLATTRTYPEOTHER, TRLATTRDESC, TRLATTRVALUE order by TRLATTRTYPE, TRLATTRTYPEOTHER, TRLATTRDESC, TRLATTRVALUE
SELECT WHLENGTH, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by WHLENGTH order by WHLENGTH
SELECT WHLENUOM, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by WHLENUOM order by WHLENUOM
SELECT UNITCODE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by UNITCODE order by UNITCODE
SELECT GROUPCODE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by GROUPCODE order by GROUPCODE
SELECT REGIONCODE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by REGIONCODE order by REGIONCODE
SELECT CREATEUSER, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by CREATEUSER order by CREATEUSER
SELECT CREATEDATE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by CREATEDATE order by CREATEDATE
SELECT EDITUSER, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by EDITUSER order by EDITUSER
SELECT EDITDATE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by EDITDATE order by EDITDATE
SELECT SOURCEDATE, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by SOURCEDATE order by SOURCEDATE
SELECT FACLOCID, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by FACLOCID order by FACLOCID
SELECT FACASSETID, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by FACASSETID order by FACASSETID
SELECT FEATUREID, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by FEATUREID order by FEATUREID
SELECT GEOMETRYID, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by GEOMETRYID order by count(*), GEOMETRYID
SELECT NOTES, count(*) FROM gis.TRAILS_ATTRIBUTE_PT group by NOTES order by NOTES

Update gis.TRAILS_ATTRIBUTE_PT set TRLATTRVALUE = 'Earth' where TRLATTRVALUE = ' Earth'
Update gis.TRAILS_ATTRIBUTE_PT set TRLATTRVALUE = 'Gravel' where TRLATTRVALUE = ' Gravel'
select * from  gis.TRAILS_ATTRIBUTE_PT where TRLATTRDESC is not null -- Four records; descriptions are meaningless
-- TRLATTRTYPE,      TRLATTRDESC, TRLATTRVALUE, FACLOCID, FACASSETID, GEOMETRYID
-- Surface Material, 465928,      Gravel,       83277,    NULL,       {6D3D1D37-08D8-48F4-B6EC-F214FD00D2B6}
-- Surface Material, sand,        Other,        NULL,     NULL,       {6324704E-F18D-4DBC-B024-2464C94B05D5}
-- Surface Material, sand,        Gravel,       NULL,     NULL,       {F77EE65F-3732-4477-A365-DBDE04DCF6DC}
-- Surface Material, 455543,      Gravel,       19973,    NULL,       {9C3E4BBD-9A39-427F-A9E0-49EA34031A3D}
update gis.TRAILS_ATTRIBUTE_PT set TRLATTRVALUE = 'Sand' where GEOMETRYID = '{6324704E-F18D-4DBC-B024-2464C94B05D5}'
update gis.TRAILS_ATTRIBUTE_PT set TRLATTRDESC = NULL where TRLATTRDESC is not null
update gis.TRAILS_ATTRIBUTE_PT set WHLENUOM = NULL where WHLENGTH is NULL
Update gis.TRAILS_ATTRIBUTE_PT set CREATEDATE = '2000-01-01'  where CREATEDATE is null
Update gis.TRAILS_ATTRIBUTE_PT set CREATEDATE = '2000-01-01'  where CREATEDATE < '1900-01-01'


-- Fixes for QC Checks
select * from gis.TRAILS_ATTRIBUTE_PT as a left join gis.trails_ln as t on a.FEATUREID = t.FEATUREID where a.UNITCODE = 'FAIR' -- the trail's unitcode is 'YUCH' (and it is spatially in YUCH)
update gis.TRAILS_ATTRIBUTE_PT set UNITCODE = 'YUCH' where UNITCODE = 'FAIR'

select OBJECTID, GEOMETRYID as Issue from gis.TRAILS_ATTRIBUTE_PT where GEOMETRYID in 
       (select GEOMETRYID from gis.TRAILS_ATTRIBUTE_PT where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1) order by objectid, GEOMETRYID
update gis.TRAILS_ATTRIBUTE_PT set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where OBJECTID > 52664 and OBJECTID < 52674