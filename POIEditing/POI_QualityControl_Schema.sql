SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_POI_PT] AS select I.Issue, I.Details, D.* from  gis.AKR_POI_PT_evw AS D
join (

-------------------------
-- gis.POI_PT
-------------------------

-- NOTE: We could ignore problems with attributes coming from a QC'd SRCDBNAME like facilities
--       as these attributes will be automatically overwritten by the "Do calculations" process
--       ignoring them will eliminate a lot of false positives during development (which will go away).
--       Not ignoring them will catch errors in the calculations process (more important)

-- OBJECTID - managed by ArcGIS no QC or Calculations required

-- POI Attributes
-- ==============

-- POINAME
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: POINAME must use proper case' as Issue, NULL as Details from gis.AKR_POI_PT_evw where  len(POINAME) > 10 AND (POINAME = upper(POINAME) Collate Latin1_General_CS_AI or POINAME = lower(POINAME) Collate Latin1_General_CS_AI)
union all

-- POIALTNAME
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- MAPLABEL
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: MAPLABEL must use proper case' as Issue, NULL from gis.AKR_POI_PT_evw where len(MAPLABEL) > 5 AND (MAPLABEL = upper(MAPLABEL) Collate Latin1_General_CS_AI or MAPLABEL = lower(MAPLABEL) Collate Latin1_General_CS_AI)
union all

-- POITYPE
--    must be in gis.DOM_POICONTAINER_POITYPE_ALTNAMES.
select t1.OBJECTID, 'Error: POITYPE is required' as Issue, NULL from gis.AKR_POI_PT_evw as t1
       where t1.POITYPE is null or t1.POITYPE = ''
union all
select t1.OBJECTID, 'Error: POITYPE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
       left join gis.DOM_POICONTAINER_POITYPE_ALTNAMES as t2 on t1.POITYPE = t2.Code where t1.POITYPE is not null and t1.POITYPE <> '' and t2.Code is null
union all

-- POIDESC
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- Core Attributes
-- ===============

-- SEASONAL
--     is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
       left join gis.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_POI_PT_evw as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.AKR_POI_PT_evw as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all

-- SEASDESC
--     optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.AKR_POI_PT_evw as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all

-- MAINTAINER
--     is a optional domain value; if FACLOCID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
       left join gis.DOM_MAINTAINER as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_POI_PT_evw as p join
  akr_facility2.dbo.FMSSExport as f on f.Location = p.FACLOCID where f.FAMARESP is not null and p.MAINTAINER not in (select code from akr_facility2.dbo.DOM_MAINTAINER where FMSS = f.FAMARESP)
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_POI_PT_evw as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  akr_facility2.dbo.FMSSExport as f on f.Location = a.Location where f.FAMARESP is not null and p.MAINTAINER not in (select code from akr_facility2.dbo.DOM_MAINTAINER where FMSS = f.FAMARESP)
union all

-- ISEXTANT
--     is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.AKR_POI_PT_evw where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join gis.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all

-- POINTTYPE
--     must be an recognized value; if it is null/empty, then it will default to 'arbitrary point' without a warning
select t1.OBJECTID, 'Error: POINTTYPE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join gis.DOM_POINTTYPE as t2 on t1.POINTTYPE = t2.Code where t1.POINTTYPE is not null and t1.POINTTYPE <> '' and t2.Code is null
union all

-- ISCURRENTGEO - is obsolete and will be removed shortly

-- ISOUTPARK
--     This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check

-- PUBLICDISPLAY
--     is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.AKR_POI_PT_evw where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.AKR_POI_PT_evw where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join gis.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all

-- DATAACCESS
--     is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.AKR_POI_PT_evw where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join gis.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all

-- PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.AKR_POI_PT_evw
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all

-- UNITCODE
--     is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join akr_facility2.gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use gis.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  gis.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue,
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from akr_facility2.gis.AKR_UNIT as t1
  left join gis.AKR_POI_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue,
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_POI_PT_evw as p join
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from gis.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_POI_PT_evw as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from gis.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all

-- UNITNAME
--     is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 join
  gis.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use gis.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all

-- GROUPCODE
--     is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in gis.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or gis.DOM_UNITCODE
---- gis.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  gis.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.AKR_POI_PT_evw as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.AKR_POI_PT_evw as t3 left join
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all

-- GROUPNAME
--     is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all

-- REGIONCODE
--     is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.AKR_POI_PT_evw where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all

-- CREATEDATE is managed by ArcGIS no QC or Calculations required
-- CREATEUSER is managed by ArcGIS no QC or Calculations required
-- EDITDATE is managed by ArcGIS no QC or Calculations required
-- EDITUSER is managed by ArcGIS no QC or Calculations required

-- MAPMETHOD
--     is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_POI_PT_evw where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join gis.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all

-- MAPSOURCE
--     is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_POI_PT_evw where MAPSOURCE is null or MAPSOURCE = ''
union all

-- SOURCEDATE
--     is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--     check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.AKR_POI_PT_evw where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.AKR_POI_PT_evw where SOURCEDATE > GETDATE()
union all

-- XYACCURACY
--     is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.AKR_POI_PT_evw where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
  left join gis.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all

-- FACLOCID
--     is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  akr_facility2.dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all

-- FACASSETID
--     is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  akr_facility2.dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.AKR_POI_PT_evw as t1 join
  akr_facility2.dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  akr_facility2.dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all

-- FEATUREID
--     must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--     Each POI should be unique; therefore all FeatureIDs should be unique
select OBJECTID, 'Error: FEATUREID is not unique' as Issue, NULL from gis.AKR_POI_PT_evw where FEATUREID in
       (select FEATUREID from gis.AKR_POI_PT_evw where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.AKR_POI_PT_evw where
	  -- Will ignore FEATUREID = NULL
	  len(FEATUREID) <> 38
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all

-- GEOMETRYID
--     must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.AKR_POI_PT_evw where GEOMETRYID in
       (select GEOMETRYID from gis.AKR_POI_PT_evw where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.AKR_POI_PT_evw where
	  -- Will ignore GEOMETRYID = NULL
	  len(GEOMETRYID) <> 38
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union

-- NOTES
--     is not required, but if it provided is it should not be an empty string
--     This can be checked and fixed automatically; no need to alert the user.


-- SRCDBNAME is for internal information only; No QC possible or required
-- SRCDBIDFLD is for internal information only; No QC possible or required
-- SRCDBIDVAL is for internal information only; No QC possible or required
-- SRCDBNMFLD is for internal information only; No QC possible or required
-- SRCDBNMVAL is for internal information only; No QC possible or required

-- WEBEDITUSER - is obsolete and will be removed shortly
-- WEBCOMMENT - is obsolete and will be removed shortly

-- Shape
--     is a valid, non-empty point that does not overlap with any other POI points
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.AKR_POI_PT_evw where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.AKR_POI_PT_evw where shape.STIsValid() = 0
-- Overlaps are possible (even exepcted among SITES)
-- Size checks are difficult because of variation in QTY units; May try later when trends are identified

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'POI_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
