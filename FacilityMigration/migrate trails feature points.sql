--------------------------
-- Update TRAIL_FEATURE_PT
--------------------------

CREATE TABLE [gis].[TRAILS_FEATURE_PT](
	[OBJECTID] [int] NOT NULL,
	[TRLFEATNAME] [nvarchar](254) NULL,
	[TRLFEATALTNAME] [nvarchar](254) NULL,
	[MAPLABEL] [nvarchar](100) NULL,
	[TRLFEATTYPE] [nvarchar](50) NULL,
	[TRLFEATTYPEOTHER] [nvarchar](50) NULL,
	[TRLFEATSUBTYPE] [nvarchar](50) NULL,
	[TRLFEATDESC] [nvarchar](254) NULL,
	[TRLFEATCOUNT] [int] NULL,
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
 CONSTRAINT [TRAILS_FEATURE_PT_OBJECTID_pk] PRIMARY KEY CLUSTERED 
(
	[OBJECTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [gis].[TRAILS_FEATURE_PT]  WITH CHECK ADD  CONSTRAINT [TRAILS_FEATURE_PT_Shape_ck] CHECK  (([Shape].[STSrid]=(4269)))
GO

ALTER TABLE [gis].[TRAILS_FEATURE_PT] CHECK CONSTRAINT [TRAILS_FEATURE_PT_Shape_ck]
GO

SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE SPATIAL INDEX [TRAILS_FEATURE_PT_shape_idx] ON [gis].[TRAILS_FEATURE_PT]
(
	[Shape]
)USING  GEOMETRY_AUTO_GRID 
WITH (BOUNDING_BOX =(-400, -90, 400, 90), 
CELLS_PER_OBJECT = 16, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


-- MAPSOURCE went from 255 to 254, and a few of the records do not fit.
select mapsource, len(mapsource) from gis.TRAILS_FEATURE_PT_OLD where len(mapsource) > 254
update gis.TRAILS_FEATURE_PT_OLD set mapsource = replace(mapsource,'Postprocessed','postproc''d') where len(mapsource) > 254 and mapsource like '%Postprocessed%'
update gis.TRAILS_FEATURE_PT_OLD set mapsource = left(mapsource, 254) where len(mapsource) > 254


--Load data
INSERT INTO [akr_facility2].[gis].[TRAILS_FEATURE_PT]
      ([OBJECTID]
      ,[TRLFEATNAME]
      ,[TRLFEATALTNAME]
      ,[MAPLABEL]
      ,[TRLFEATTYPE]
      ,[TRLFEATTYPEOTHER]
      ,[TRLFEATSUBTYPE]
      ,[TRLFEATDESC]
      ,[TRLFEATCOUNT]
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
      ,[TRLFEATNAME]
      ,[TRLFEATALTNAMES]
	  ,NULL
      ,[TRLFEATTYPE]
      ,[TRLFEATTYPEOTHER]
      ,[TRLFEATSUBTYPE]
      ,[TRLFEATDESC]
      ,[TRLFEATCOUNT]
      ,[WHLENGTH]
      ,[WHLENUOM]
	  ,NULL
      ,[ISEXTANT]
	  ,NULL
      ,[DISTRIBUTE]
      ,[RESTRICTION]
      ,[UNITCODE]
      ,NULL --[UNITNAME]
      ,[GROUPCODE]
	  ,NULL
      ,[REGIONCODE]
      ,[CREATEDATE]
      ,[CREATEUSER]
      ,[EDITDATE]
      ,[EDITUSER]
      ,[MAPMETHOD]
      ,[MAPSOURCE]  -- A few of these records were truncated from 255 to 254 characters
      ,[SOURCEDATE]
--      ,[SRCESCALE]
      ,[XYERROR]
--      ,[ZERROR]
      ,[LOCATIONID]
      ,[ASSETID]
      ,[FEATUREID]
      ,[GEOMETRYID]
      ,[NOTES]
--      ,[METADATAID]
--      ,[TempLocationID]
	  ,NULL
	  ,NULL
      ,[Shape]
  FROM [akr_facility2].[gis].[TRAILS_FEATURE_PT_OLD]


-- FIX TRLFEATTYPE
SELECT TRLFEATTYPE, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATTYPE order by TRLFEATTYPE
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Culvert' where TRLFEATTYPE = '30'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Drain' where TRLFEATTYPE = '40'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'External Furnishing' where TRLFEATTYPE = '50'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Sign' where TRLFEATTYPE = '70'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Stairs' where TRLFEATTYPE = '80'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Walkable Structure' where TRLFEATTYPE = '100'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Wall' where TRLFEATTYPE = '110'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Wayside Feature' where TRLFEATTYPE = '120'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Trail Head' where TRLFEATTYPE = '130'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Trail End' where TRLFEATTYPE = '140'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Bridge' where TRLFEATTYPE = '150'
update gis.TRAILS_FEATURE_PT set TRLFEATTYPE = 'Other' where TRLFEATTYPE = '900'

-- FIX POINTTYPE
update gis.TRAILS_FEATURE_PT set POINTTYPE = 'Arbitrary point'

-- FIX ISEXTANT
SELECT ISEXTANT, count(*) FROM gis.TRAILS_FEATURE_PT group by ISEXTANT order by ISEXTANT
update gis.TRAILS_FEATURE_PT set ISEXTANT = 'Unknown' where ISEXTANT is null
update gis.TRAILS_FEATURE_PT set ISEXTANT = 'False' where ISEXTANT = 'No'
update gis.TRAILS_FEATURE_PT set ISEXTANT = 'True' where ISEXTANT = 'Yes'

-- FIX PUBLICDISPLAY
SELECT PUBLICDISPLAY, count(*) FROM gis.TRAILS_FEATURE_PT group by PUBLICDISPLAY order by PUBLICDISPLAY
SELECT PUBLICDISPLAY, DATAACCESS, count(*) FROM gis.TRAILS_FEATURE_PT group by PUBLICDISPLAY, DATAACCESS order by PUBLICDISPLAY, DATAACCESS
update gis.TRAILS_FEATURE_PT set PUBLICDISPLAY = 'Public Map Display' where PUBLICDISPLAY is null and DATAACCESS = 'Unrestricted'
update gis.TRAILS_FEATURE_PT set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is null
update gis.TRAILS_FEATURE_PT set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY = 'Internal Only'
update gis.TRAILS_FEATURE_PT set PUBLICDISPLAY = 'Public Map Display' where PUBLICDISPLAY = 'Public'

-- FIX DATAACCESS
SELECT DATAACCESS, count(*) FROM gis.TRAILS_FEATURE_PT group by DATAACCESS order by DATAACCESS
SELECT PUBLICDISPLAY, DATAACCESS, count(*) FROM gis.TRAILS_FEATURE_PT group by PUBLICDISPLAY, DATAACCESS order by PUBLICDISPLAY, DATAACCESS
update gis.TRAILS_FEATURE_PT set DATAACCESS = 'Unrestricted' where DATAACCESS = 'Agency Concurrence'
update gis.TRAILS_FEATURE_PT set DATAACCESS = 'Internal NPS Only' where DATAACCESS = 'No 3rd Party Release'
update gis.TRAILS_FEATURE_PT set DATAACCESS = 'Unrestricted' where DATAACCESS = 'Program Concurrence'
update gis.TRAILS_FEATURE_PT set PUBLICDISPLAY = 'No Public Map Display' where DATAACCESS = 'Internal NPS Only'

-- FIX MAPMETHOD
SELECT MAPMETHOD, count(*) FROM gis.TRAILS_FEATURE_PT group by MAPMETHOD order by MAPMETHOD
update gis.TRAILS_FEATURE_PT set MAPMETHOD = 'Unknown' where MAPMETHOD is null
--update gis.TRAILS_FEATURE_PT set MAPMETHOD = '' where MAPMETHOD = 'COGO'
update gis.TRAILS_FEATURE_PT set MAPMETHOD = 'GNSS: Consumer Grade' where MAPMETHOD = 'Consumer Grade GPS'
--update gis.TRAILS_FEATURE_PT set MAPMETHOD = '' where MAPMETHOD = 'Digitized'
--update gis.TRAILS_FEATURE_PT set MAPMETHOD = '' where MAPMETHOD = 'GNSS: Mapping Grade'
update gis.TRAILS_FEATURE_PT set MAPMETHOD = 'GNSS: Mapping Grade' where MAPMETHOD = 'Mapping Grade GPS'

-- FIX XYACCURACY
SELECT XYACCURACY, count(*) FROM gis.TRAILS_FEATURE_PT group by XYACCURACY order by XYACCURACY
SELECT XYACCURACY, MAPSOURCE FROM gis.TRAILS_FEATURE_PT where XYACCURACY = '<= 15 cm' 
SELECT XYACCURACY, MAPSOURCE FROM gis.TRAILS_FEATURE_PT where XYACCURACY = '> 15 cm and <= 1 m' and MAPSOURCE like '%XH%'
SELECT XYACCURACY, MAPSOURCE FROM gis.TRAILS_FEATURE_PT where XYACCURACY = '>15 cm and <= 1 m' 
update gis.TRAILS_FEATURE_PT set XYACCURACY = 'Unknown' where XYACCURACY is null
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=5cm and <50cm' where XYACCURACY = '<= 15 cm'
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=1m and <5m' where XYACCURACY = '> 1 m and <= 5 m'
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=14m' where XYACCURACY = '> 10 m'
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=5cm and <50cm' where XYACCURACY = '> 15 cm and <= 1 m'  and MAPSOURCE like '%XH%'
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=50cm and <1m' where XYACCURACY = '> 15 cm and <= 1 m'
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=5m and <14m' where XYACCURACY = '> 5 m and <= 10 m'
update gis.TRAILS_FEATURE_PT set XYACCURACY = '>=50cm and <1m' where XYACCURACY = '>15 cm and <= 1 m'

-- FIX Miscellaneous
SELECT TRLFEATNAME, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATNAME order by TRLFEATNAME
SELECT TRLFEATALTNAME, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATALTNAME order by TRLFEATALTNAME
SELECT TRLFEATTYPE, TRLFEATTYPEOTHER, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATTYPE, TRLFEATTYPEOTHER order by TRLFEATTYPE, TRLFEATTYPEOTHER
SELECT TRLFEATSUBTYPE, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATSUBTYPE order by TRLFEATSUBTYPE
SELECT TRLFEATTYPE, TRLFEATTYPEOTHER, TRLFEATSUBTYPE, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATTYPE, TRLFEATTYPEOTHER, TRLFEATSUBTYPE order by TRLFEATTYPE, TRLFEATTYPEOTHER, TRLFEATSUBTYPE
SELECT TRLFEATDESC, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATDESC order by TRLFEATDESC
SELECT TRLFEATCOUNT, count(*) FROM gis.TRAILS_FEATURE_PT group by TRLFEATCOUNT order by TRLFEATCOUNT
SELECT WHLENGTH, count(*) FROM gis.TRAILS_FEATURE_PT group by WHLENGTH order by WHLENGTH
SELECT WHLENUOM, count(*) FROM gis.TRAILS_FEATURE_PT group by WHLENUOM order by WHLENUOM
SELECT UNITCODE, count(*) FROM gis.TRAILS_FEATURE_PT group by UNITCODE order by UNITCODE
SELECT GROUPCODE, count(*) FROM gis.TRAILS_FEATURE_PT group by GROUPCODE order by GROUPCODE
SELECT REGIONCODE, count(*) FROM gis.TRAILS_FEATURE_PT group by REGIONCODE order by REGIONCODE
SELECT CREATEUSER, count(*) FROM gis.TRAILS_FEATURE_PT group by CREATEUSER order by CREATEUSER
SELECT CREATEDATE, count(*) FROM gis.TRAILS_FEATURE_PT group by CREATEDATE order by CREATEDATE
SELECT EDITUSER, count(*) FROM gis.TRAILS_FEATURE_PT group by EDITUSER order by EDITUSER
SELECT EDITDATE, count(*) FROM gis.TRAILS_FEATURE_PT group by EDITDATE order by EDITDATE
SELECT SOURCEDATE, count(*) FROM gis.TRAILS_FEATURE_PT group by SOURCEDATE order by SOURCEDATE
SELECT FACLOCID, count(*) FROM gis.TRAILS_FEATURE_PT group by FACLOCID order by FACLOCID
SELECT FACASSETID, count(*) FROM gis.TRAILS_FEATURE_PT group by FACASSETID order by FACASSETID
SELECT FEATUREID, count(*) FROM gis.TRAILS_FEATURE_PT group by FEATUREID order by FEATUREID
SELECT GEOMETRYID, count(*) FROM gis.TRAILS_FEATURE_PT group by GEOMETRYID order by count(*), GEOMETRYID
SELECT NOTES, count(*) FROM gis.TRAILS_FEATURE_PT group by NOTES order by NOTES

Update gis.TRAILS_FEATURE_PT set TRLFEATNAME = 'Brooks River Elevated Bridge and Boardwalk' where TRLFEATNAME = ' Brooks River Elevated Bridge and Boardwalk'
Update gis.TRAILS_FEATURE_PT set TRLFEATTYPEOTHER = null where TRLFEATTYPEOTHER = ''
Update gis.TRAILS_FEATURE_PT set GROUPCODE = null where GROUPCODE = ''
Update gis.TRAILS_FEATURE_PT set CREATEUSER = 'AKRO_GIS'  where CREATEUSER is null
Update gis.TRAILS_FEATURE_PT set CREATEDATE = '2000-01-01'  where CREATEDATE is null
Update gis.TRAILS_FEATURE_PT set EDITUSER = CREATEUSER where EDITUSER is null
Update gis.TRAILS_FEATURE_PT set EDITDATE = CREATEDATE  where EDITDATE is null
update gis.TRAILS_FEATURE_PT set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null
Update gis.TRAILS_FEATURE_PT set NOTES = null where NOTES = ''


-- Fixes for QC Checks
select GEOMETRYID from gis.TRAILS_FEATURE_PT where OBJECTID = 2628
update gis.TRAILS_FEATURE_PT set GEOMETRYID = left(GEOMETRYID,37) + '}' where OBJECTID = 2628

select OBJECTID, TRLFEATNAME from gis.TRAILS_FEATURE_PT where TRLFEATNAME = upper(TRLFEATNAME) Collate Latin1_General_CS_AI or TRLFEATNAME = lower(TRLFEATNAME) Collate Latin1_General_CS_AI
update gis.TRAILS_FEATURE_PT set TRLFEATNAME = 'Stepping Stones' where TRLFEATNAME = 'stepping stones'
update gis.TRAILS_FEATURE_PT set TRLFEATNAME = 'Stone Cobble' where TRLFEATNAME = 'stone cobble'

select t1.OBJECTID, '|'+FACLOCID+'|', 'Error: FACLOCID is not a valid ID' as Issue from gis.TRAILS_FEATURE_PT as t1 left join
  dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
select t1.objectid, t1.FACLOCID, t2.FACLOCID, t1.FEATUREID, t2.FEATUREID from gis.TRAILS_FEATURE_PT as t1 left join gis.TRAILS_LN as t2 on t1.FEATUREID = t2.featureid where t1.OBJECTID in (2590, 3806, 2365)
select * from FMSSExport where location = '78134'
select * from FMSSExport where location = '111932'
select * from FMSSExport where location = '247325'
update gis.TRAILS_FEATURE_PT set FACLOCID = '78134' where FACLOCID = '781341'
update gis.TRAILS_FEATURE_PT set FACLOCID = '111932' where FACLOCID = '11932'
update gis.TRAILS_FEATURE_PT set FACLOCID = '247325' where FACLOCID like '247325%'
