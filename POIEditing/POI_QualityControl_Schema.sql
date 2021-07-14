USE [akr_socio]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_POI_LN] AS select I.Issue, I.Details, D.* from  gis.POI_LN_evw0 AS D
join (

-------------------------
-- gis.POI_LN
-------------------------

-- NOTE: This script is nearly identical to QC_ISSUES_POI_PT; Changes to one should be made to the other
--       Diffs: 1) Search/Replace gis.AKR_POI_PT_evw with gis.POI_LN_evw0
--              2) Search/Replace POINTTYPE with LINETYPE
--              3) Search/Replace POI_PT with POI_LN
--       POI_LN uses SDE Binary Geometry which does not support spatial queries in SQL, therefore we cannot
--        QC the shape or the UNITCODE until the geometry is replaced with SQL Server Geometry

-- OBJECTID - managed by ArcGIS no QC or Calculations required

-- POI Attributes
-- ==============

-- POINAME
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: POINAME must use proper case' as Issue, NULL as Details from gis.POI_LN_evw0 where  len(POINAME) > 10 AND (POINAME = upper(POINAME) Collate Latin1_General_CS_AI or POINAME = lower(POINAME) Collate Latin1_General_CS_AI)
union all

-- POIALTNAME
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- MAPLABEL
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: MAPLABEL must use proper case' as Issue, NULL from gis.POI_LN_evw0 where len(MAPLABEL) > 5 AND (MAPLABEL = upper(MAPLABEL) Collate Latin1_General_CS_AI or MAPLABEL = lower(MAPLABEL) Collate Latin1_General_CS_AI)
union all

-- POITYPE
--    must be in gis.DOM_POICONTAINER_POITYPE_ALTNAMES.
select t1.OBJECTID, 'Error: POITYPE is required' as Issue, NULL from gis.POI_LN_evw0 as t1
       where t1.POITYPE is null or t1.POITYPE = ''
union all
select t1.OBJECTID, 'Error: POITYPE is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
       left join gis.DOM_POICONTAINER_POITYPE_ALTNAMES as t2 on t1.POITYPE = t2.Code where t1.POITYPE is not null and t1.POITYPE <> '' and t2.Code is null
union all

-- POIDESC
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- Core Attributes
-- ===============

-- SEASONAL
--     is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
       left join gis.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.POI_LN_evw0 as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.POI_LN_evw0 as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all

-- SEASDESC
--     optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.POI_LN_evw0 as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all

-- MAINTAINER
--     is a optional domain value; if provided must be in DOM_FACOCCUMAINT (assume it is a facility maintainer (FACMAINTAIN), not a GIS MAINTAINER)
--     if FACLOCID or FACASSEETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
       left join akr_facility2.dbo.DOM_FACOCCUMAINT as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.POI_LN_evw0 as p join 
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.MAINTAINER <> f.FAMARESP
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.POI_LN_evw0 as p
  join akr_facility2.dbo.FMSSExport_Asset as a on p.FACASSETID = a.Asset join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = a.[Location] where p.MAINTAINER <> f.FAMARESP
union all

-- ISEXTANT
--     is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.POI_LN_evw0 where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join gis.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all

-- LINETYPE
--     must be an recognized value; if it is null/empty, then it will default to 'arbitrary point' without a warning
select t1.OBJECTID, 'Error: LINETYPE is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join gis.DOM_LINETYPE as t2 on t1.LINETYPE = t2.Code where t1.LINETYPE is not null and t1.LINETYPE <> '' and t2.Code is null
union all

-- ISCURRENTGEO - is obsolete and will be removed shortly

-- ISOUTPARK
--     This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check

-- PUBLICDISPLAY
--     is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.POI_LN_evw0 where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.POI_LN_evw0 where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join gis.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all

-- DATAACCESS
--     is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.POI_LN_evw0 where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join gis.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all

-- PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.POI_LN_evw0
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all

-- UNITCODE
--     is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance

-- TODO: replace SDE binary geometry with SQL Server Geometry and uncomment the following check
/*
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join akr_facility2.gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
*/

-- TODO: Should this non-spatial query use akr_facility2.dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1 left join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all

-- TODO: replace SDE binary geometry with SQL Server Geometry and uncomment the following check
/*
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from akr_facility2.gis.AKR_UNIT as t1
  left join gis.POI_LN_evw0 as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
*/

select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.POI_LN_evw0 as p join 
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from akr_facility2.dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.POI_LN_evw0 as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from akr_facility2.dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all

-- UNITNAME
--     is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.POI_LN_evw0 as t1 join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use akr_facility2.dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.POI_LN_evw0 as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all

-- GROUPCODE
--     is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in akr_facility2.dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or akr_facility2.dbo.DOM_UNITCODE
---- akr_facility2.dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1 left join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.POI_LN_evw0 as t1 left join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.POI_LN_evw0 as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.POI_LN_evw0 as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all

-- GROUPNAME
--     is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.POI_LN_evw0 as t1 join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all

-- REGIONCODE
--     is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.POI_LN_evw0 where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all

-- CREATEDATE is managed by ArcGIS no QC or Calculations required
-- CREATEUSER is managed by ArcGIS no QC or Calculations required
-- EDITDATE is managed by ArcGIS no QC or Calculations required
-- EDITUSER is managed by ArcGIS no QC or Calculations required

-- MAPMETHOD
--     is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.POI_LN_evw0 where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join gis.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all

-- MAPSOURCE
--     is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.POI_LN_evw0 where MAPSOURCE is null or MAPSOURCE = ''
union all

-- SOURCEDATE
--     is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--     check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.POI_LN_evw0 where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.POI_LN_evw0 where SOURCEDATE > GETDATE()
union all

-- XYACCURACY
--     is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.POI_LN_evw0 where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.POI_LN_evw0 as t1
  left join gis.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all

-- FACLOCID
--     is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.POI_LN_evw0 as t1 left join
  akr_facility2.dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all

-- FACASSETID
--     is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.POI_LN_evw0 as t1 left join
  akr_facility2.dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.POI_LN_evw0 as t1 join
  akr_facility2.dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  akr_facility2.dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all

-- FEATUREID
--     must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--     Each POI should be unique; therefore all FeatureIDs should be unique
select OBJECTID, 'Error: FEATUREID is not unique' as Issue, NULL from gis.POI_LN_evw0 where FEATUREID in 
       (select FEATUREID from gis.POI_LN_evw0 where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.POI_LN_evw0 where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all

-- GEOMETRYID
--     must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.POI_LN_evw0 where GEOMETRYID in 
       (select GEOMETRYID from gis.POI_LN_evw0 where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.POI_LN_evw0 where
	  -- Will ignore GEOMETRYID = NULL 
	  len(GEOMETRYID) <> 38 
	  OR left(GEOMETRYID,1) <> '{'
	  OR right(GEOMETRYID,1) <> '}'
	  OR GEOMETRYID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI

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

-- TODO: replace SDE binary geometry with SQL Server Geometry and uncomment the following check
/*
union 
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.POI_LN_evw0 where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.POI_LN_evw0 where shape.STIsValid() = 0
*/
-- Overlaps are possible (even exepcted among SITES)
-- Size checks are difficult because of variation in QTY units; May try later when trends are identified 

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'POI_LN'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
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
--     is a optional domain value; if provided must be in DOM_FACOCCUMAINT (assume it is a facility maintainer (FACMAINTAIN), not a GIS MAINTAINER)
--     if FACLOCID or FACASSEETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1
       left join akr_facility2.dbo.DOM_FACOCCUMAINT as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_POI_PT_evw as p join 
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.MAINTAINER <> f.FAMARESP
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.AKR_POI_PT_evw as p
  join akr_facility2.dbo.FMSSExport_Asset as a on p.FACASSETID = a.Asset join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = a.[Location] where p.MAINTAINER <> f.FAMARESP
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
-- TODO: Should this non-spatial query use akr_facility2.dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from akr_facility2.gis.AKR_UNIT as t1
  left join gis.AKR_POI_PT_evw as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_POI_PT_evw as p join 
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from akr_facility2.dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.AKR_POI_PT_evw as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from akr_facility2.dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all

-- UNITNAME
--     is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use akr_facility2.dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all

-- GROUPCODE
--     is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in akr_facility2.dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or akr_facility2.dbo.DOM_UNITCODE
---- akr_facility2.dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.AKR_POI_PT_evw as t1 left join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
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


-- Related records in souce databases
-- These queries assume selct source table configurations; it is not safe to create "dynamic" queries based on
-- The values in a table.  This section will need to be updated as the source tables change

-- Check for missing building center pointns
union all
select p.OBJECTID, 'Error: Related building center point is missing.' as Issue, Null
from akr_socio.gis.akr_POI_PT_evw as p left join akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b 
on p.SRCDBIDVAL = b.FEATUREID where b.FEATUREID is null and p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT'

-- Check for missing trail feature points
union all
select p.OBJECTID, 'Error: Related trail feature point is missing.' as Issue, Null
from akr_socio.gis.akr_POI_PT_evw as p left join akr_facility2.gis.TRAILS_FEATURE_PT_evw as b 
on p.SRCDBIDVAL = b.GEOMETRYID where b.GEOMETRYID is null and p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT'



) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'POI_PT'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[QC_ISSUES_POI_PY] AS select I.Issue, I.Details, D.* from  gis.POI_PY_evw0 AS D
join (

-------------------------
-- gis.POI_PY
-------------------------

-- NOTE: This script is nearly identical to QC_ISSUES_POI_PT; Changes to one should be made to the other
--       Diffs: 1) Search/Replace gis.AKR_POI_PT_evw with gis.POI_PY_evw0
--              2) Search/Replace POINTTYPE with POLYGONTYPE
--              3) Search/Replace POI_PT with POI_PY

-- OBJECTID - managed by ArcGIS no QC or Calculations required

-- POI Attributes
-- ==============

-- POINAME
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: POINAME must use proper case' as Issue, NULL as Details from gis.POI_PY_evw0 where  len(POINAME) > 10 AND (POINAME = upper(POINAME) Collate Latin1_General_CS_AI or POINAME = lower(POINAME) Collate Latin1_General_CS_AI)
union all

-- POIALTNAME
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- MAPLABEL
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.
--    Must use proper case - can only check for all upper or all lower case; Ignore names less than 6 characters
select OBJECTID, 'Error: MAPLABEL must use proper case' as Issue, NULL from gis.POI_PY_evw0 where len(MAPLABEL) > 5 AND (MAPLABEL = upper(MAPLABEL) Collate Latin1_General_CS_AI or MAPLABEL = lower(MAPLABEL) Collate Latin1_General_CS_AI)
union all

-- POITYPE
--    must be in gis.DOM_POICONTAINER_POITYPE_ALTNAMES.
select t1.OBJECTID, 'Error: POITYPE is required' as Issue, NULL from gis.POI_PY_evw0 as t1
       where t1.POITYPE is null or t1.POITYPE = ''
union all
select t1.OBJECTID, 'Error: POITYPE is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
       left join gis.DOM_POICONTAINER_POITYPE_ALTNAMES as t2 on t1.POITYPE = t2.Code where t1.POITYPE is not null and t1.POITYPE <> '' and t2.Code is null
union all

-- POIDESC
--    is not required, but if it provided is it should not be an empty string
--    This can be checked and fixed automatically; no need to alert the user.

-- Core Attributes
-- ===============

-- SEASONAL
--     is a optional domain value; must match valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: SEASONAL is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
       left join gis.DOM_YES_NO_UNK as t2 on t1.SEASONAL = t2.Code where t1.SEASONAL is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + FACLOCID + ' has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.POI_PY_evw0 as p join 
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has OPSEAS = ' + f.OPSEAS + ' when GIS has SEASONAL = ' + isnull(p.SEASONAL,'NULL') as Details
  from gis.POI_PY_evw0 as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on a.Location = f.Location where p.SEASONAL <> f.OPSEAS and f.OPSEAS <> 'Unknown'
union all

-- SEASDESC
--     optional free text.  Required if SEASONAL = 'Yes'; Convert empty string to null; default of "Winter seasonal closure" with a warning
select  p.OBJECTID, 'Warning: SEASDESC is required when SEASONAL is *Yes*, a default value of *Winter seasonal closure* will be used' as Issue, NULL from gis.POI_PY_evw0 as p
  left join (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
  on p.FACLOCID = f.Location where (p.SEASDESC is null or p.SEASDESC = '') and (p.SEASONAL = 'Yes' or (p.SEASONAL is null and f.OPSEAS = 'Yes'))
union all

-- MAINTAINER
--     is a optional domain value; if provided must be in DOM_FACOCCUMAINT (assume it is a facility maintainer (FACMAINTAIN), not a GIS MAINTAINER)
--     if FACLOCID or FACASSEETID is provided this should match a valid value in FMSS Lookup.
select t1.OBJECTID, 'Error: MAINTAINER is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
       left join akr_facility2.dbo.DOM_FACOCCUMAINT as t2 on t1.MAINTAINER = t2.Code where t1.MAINTAINER is not null and t2.Code is null
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + FACLOCID + ' has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.POI_PY_evw0 as p join 
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = p.FACLOCID where p.MAINTAINER <> f.FAMARESP
union all
select p.OBJECTID, 'Error: MAINTAINER does not match FMSS.FAMARESP' as Issue,
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has FAMARESP = ' + f.FAMARESP + ' when GIS has MAINTAINER = ' + p.MAINTAINER as Details
  from gis.POI_PY_evw0 as p
  join akr_facility2.dbo.FMSSExport_Asset as a on p.FACASSETID = a.Asset join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
  on f.Location = a.[Location] where p.MAINTAINER <> f.FAMARESP
union all

-- ISEXTANT
--     is a required domain value; Default to True with Warning
select OBJECTID, 'Warning: ISEXTANT is not provided, a default value of *True* will be used' as Issue, NULL from gis.POI_PY_evw0 where ISEXTANT is null
union all
select t1.OBJECTID, 'Error: ISEXTANT is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join gis.DOM_ISEXTANT as t2 on t1.ISEXTANT = t2.code where t1.ISEXTANT is not null and t2.code is null
union all

-- POLYGONTYPE
--     must be an recognized value; if it is null/empty, then it will default to 'arbitrary point' without a warning
select t1.OBJECTID, 'Error: POLYGONTYPE is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join gis.DOM_POLYGONTYPE as t2 on t1.POLYGONTYPE = t2.Code where t1.POLYGONTYPE is not null and t1.POLYGONTYPE <> '' and t2.Code is null
union all

-- ISCURRENTGEO - is obsolete and will be removed shortly

-- ISOUTPARK
--     This is not exposed for editing by the user, and will be overwritten regardless, so there is nothing to check

-- PUBLICDISPLAY
--     is a required Domain Value; Default to No Public Map Display with Warning
--     TODO: are there requirements of other fields (i.e. ISEXTANT, ISOUTPARK, UNITCODE) when PUBLICDISPLAY is true?
--           select ISEXTANT, ISOUTPARK, UNITCODE, Count(*) from gis.POI_PY_evw0 where PUBLICDISPLAY = 'Public Map Display' group by ISEXTANT, ISOUTPARK, UNITCODE
select OBJECTID, 'Warning: PUBLICDISPLAY is not provided, a default value of *No Public Map Display* will be used' as Issue, NULL from gis.POI_PY_evw0 where PUBLICDISPLAY is null or PUBLICDISPLAY = ''
union all
select t1.OBJECTID, 'Error: PUBLICDISPLAY is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join gis.DOM_PUBLICDISPLAY as t2 on t1.PUBLICDISPLAY = t2.code where t1.PUBLICDISPLAY is not null and t1.PUBLICDISPLAY <> '' and t2.code is null
union all

-- DATAACCESS
--     is a required Domain Value; Default to Internal NPS Only with Warning
select OBJECTID, 'Warning: DATAACCESS is not provided, a default value of *Internal NPS Only* will be used' as Issue, NULL from gis.POI_PY_evw0 where DATAACCESS is null or DATAACCESS = ''
union all
select t1.OBJECTID, 'Error: DATAACCESS is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join gis.DOM_DATAACCESS as t2 on t1.DATAACCESS = t2.code where t1.DATAACCESS is not null and t1.DATAACCESS <> '' and t2.code is null
union all

-- PUBLICDISPLAY and DATAACCESS are related
select OBJECTID, 'Error: PUBLICDISPLAY cannot be public while DATAACCESS is restricted' as Issue, NULL from gis.POI_PY_evw0
  where PUBLICDISPLAY = 'Public Map Display' and DATAACCESS in ('Internal NPS Only', 'Secure Access Only')
union all

-- UNITCODE
--     is a required domain value.  If null will be set spatially; error if not within a unit boundary
--     Error if it doesn't match valid value in FMSS Lookup Location.Park
--     TODO: Can we accept a null UNITCODE if GROUPCODE is not null and valid?  Need to merge for a standard compliance
select t1.OBJECTID, 'Error: UNITCODE is required when the point is not within a unit boundary' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join akr_facility2.gis.AKR_UNIT as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.UNITCODE is null and t2.Unit_Code is null
union all
-- TODO: Should this non-spatial query use akr_facility2.dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1 left join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITCODE is not null and t2.Unit_Code is null
--   union all
select t1.OBJECTID, 'Error: UNITCODE is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1 left join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITCODE is not null and t2.Code is null
union all
select t2.OBJECTID, 'Error: UNITCODE does not match the boundary it is within' as Issue, 
  'UNITCODE = ' + t2.UNITCODE + ' but it intersects ' + t1.Unit_Code as Details from akr_facility2.gis.AKR_UNIT as t1
  left join gis.POI_PY_evw0 as t2 on t1.shape.Filter(t2.shape) = 1 and t2.UNITCODE <> t1.Unit_Code where t1.Shape.STIntersects(t2.Shape) = 1
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + FACLOCID + ' has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.POI_PY_evw0 as p join 
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from akr_facility2.dbo.DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue, 
  'Location ' + a.Location + '(for Asset ' + p.FACASSETID + ') has PARK = ' + f.Park + ' when GIS has UNITCODE = ' + p.UNITCODE as Details
  from gis.POI_PY_evw0 as p
  join akr_facility2.dbo.FMSSExport_Asset as a on a.Asset = p.FACASSETID join
  (SELECT Park, Location FROM akr_facility2.dbo.FMSSExport where Park in (select Code from akr_facility2.dbo.DOM_UNITCODE)) as f
  on f.Location = a.Location where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
union all

-- UNITNAME
--     is calc'd from UNITCODE.  Issue a warning if not null and doesn't match the calc'd value
select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.POI_PY_evw0 as t1 join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.UNITNAME
union all
-- TODO: Should we use akr_facility2.dbo.DOM_UNITCODE or AKR_UNIT?  the list of codes is different
--   select t1.OBJECTID, 'Warning: UNITNAME will be overwritten by a calculated value' as Issue, NULL from gis.POI_PY_evw0 as t1 join
--     gis.AKR_UNIT as t2 on t1.UNITCODE = t2.Unit_Code where t1.UNITNAME is not null and t1.UNITNAME <> t2.Unit_Name
--   union all

-- GROUPCODE
--     is optional free text; AKR restriction: if provided must be in AKR_GROUP
--     it can be null and not spatially within a group (this check is problematic, see discussion below),
--     however if it is not null and within a group, the codes must match (this check is problematic, see discussion below)
--     GROUPCODE must match related UNITCODE in akr_facility2.dbo.DOM_UNITCODE (can fail. i.e if unit is KOVA and group is ARCN, as KOVA is in WEAR)
-- TODO: Should these checks use gis.AKR_GROUP or akr_facility2.dbo.DOM_UNITCODE
---- akr_facility2.dbo.DOM_UNITCODE does not allow UNIT in multiple groups
---- gis.AKR_GROUP does not try to match group and unit
select t1.OBJECTID, 'Error: GROUPCODE is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1 left join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t2.Group_Code is null
union all
select t1.OBJECTID, 'Error: GROUPCODE does not match the UNITCODE' as Issue, NULL from gis.POI_PY_evw0 as t1 left join
  akr_facility2.dbo.DOM_UNITCODE as t2 on t1.UNITCODE = t2.Code where t1.GROUPCODE <> t2.GROUPCODE
union all
-- TODO: Consider doing a spatial check.  There are several problems with the current approach:
----  1) it will generate multiple errors if point's group code is in multiple groups, and none match
----  2) it will generate spurious errors when outside the group location e.g. WEAR, but still within a network
--select t1.OBJECTID, 'Error: GROUPCODE does not match the boundary it is within' as Issue, NULL from gis.POI_PY_evw0 as t1
--  left join gis.AKR_GROUP as t2 on t1.Shape.STIntersects(t2.Shape) = 1 where t1.GROUPCODE <> t2.Group_Code
--  and t1.OBJECTID not in (select t3.OBJECTID from gis.POI_PY_evw0 as t3 left join 
--  gis.AKR_GROUP as t4 on t3.Shape.STIntersects(t4.Shape) = 1 where t3.GROUPCODE = t4.Group_Code)
--union all

-- GROUPNAME
--     is calc'd from GROUPCODE when non-null and  free text; AKR restriction: if provided must be in AKR_GROUP
select t1.OBJECTID, 'Error: GROUPNAME will be overwritten by a calculated value' as Issue, NULL from gis.POI_PY_evw0 as t1 join
  akr_facility2.gis.AKR_GROUP as t2 on t1.GROUPCODE = t2.Group_Code where t1.GROUPCODE is not null and t1.GROUPNAME <> t2.Group_Name
union all

-- REGIONCODE
--     is always 'AKR' Issue a warning if not null and not equal to 'AKR'
select OBJECTID, 'Warning: REGIONCODE will be replaced with *AKR*' as Issue, NULL from gis.POI_PY_evw0 where REGIONCODE is not null and REGIONCODE <> 'AKR'
union all

-- CREATEDATE is managed by ArcGIS no QC or Calculations required
-- CREATEUSER is managed by ArcGIS no QC or Calculations required
-- EDITDATE is managed by ArcGIS no QC or Calculations required
-- EDITUSER is managed by ArcGIS no QC or Calculations required

-- MAPMETHOD
--     is required free text; AKR applies an additional constraint that it be a domain value
select OBJECTID, 'Warning: MAPMETHOD is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.POI_PY_evw0 where MAPMETHOD is null or MAPMETHOD = ''
union all
select t1.OBJECTID, 'Error: MAPMETHOD is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join gis.DOM_MAPMETHOD as t2 on t1.MAPMETHOD = t2.code where t1.MAPMETHOD is not null and t1.MAPMETHOD <> '' and t2.code is null
union all

-- MAPSOURCE
--     is required free text; the only check we can make is that it is non null and not an empty string
select OBJECTID, 'Warning: MAPSOURCE is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.POI_PY_evw0 where MAPSOURCE is null or MAPSOURCE = ''
union all

-- SOURCEDATE
--     is required for some map sources, however since MAPSOURCE is free text we do not know when null is ok.
--     check to make sure date is before today, and after 1995 (earliest in current dataset, others can be exceptions)
select OBJECTID, 'Warning: SOURCEDATE is unexpectedly old (before 1995)' as Issue, NULL from gis.POI_PY_evw0 where SOURCEDATE < convert(Datetime2,'1995')
union all
select OBJECTID, 'Error: SOURCEDATE is in the future' as Issue, NULL from gis.POI_PY_evw0 where SOURCEDATE > GETDATE()
union all

-- XYACCURACY
--     is a required domain value; default is 'Unknown'
select OBJECTID, 'Warning: XYACCURACY is not provided, default value of *Unknown* will be used' as Issue, NULL from gis.POI_PY_evw0 where XYACCURACY is null or XYACCURACY = ''
union all
select t1.OBJECTID, 'Error: XYACCURACY is not a recognized value' as Issue, NULL from gis.POI_PY_evw0 as t1
  left join gis.DOM_XYACCURACY as t2 on t1.XYACCURACY = t2.code where t1.XYACCURACY is not null and t1.XYACCURACY <> '' and t2.code is null
union all

-- FACLOCID
--     is optional free text, but if provided it must match a Parking Lot Location in the FMSS Export;
--     All records with the same FACLOCID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACLOCID is not a valid ID' as Issue, NULL from gis.POI_PY_evw0 as t1 left join
  akr_facility2.dbo.FMSSExport as t2 on t1.FACLOCID = t2.Location where t1.FACLOCID is not null and t1.FACLOCID <> '' and t2.Location is null
union all

-- FACASSETID
--     is optional free text, provided it must match a Parking Lot Location in the FMSS Assets Export
--     All records with the same FACASSETID must have the same FEATUREID
select t1.OBJECTID, 'Error: FACASSETID is not a valid ID' as Issue, NULL from gis.POI_PY_evw0 as t1 left join
  akr_facility2.dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset where t1.FACASSETID is not null and t1.FACASSETID <> '' and t2.Asset is null
union all
select t1.OBJECTID, 'Error: FACASSETID.Location does not match FACLOCID' as Issue, NULL from gis.POI_PY_evw0 as t1 join
  akr_facility2.dbo.FMSSExport_Asset as t2 on t1.FACASSETID = t2.Asset join
  akr_facility2.dbo.FMSSExport as t3 on t2.Location = t3.Location and t1.UNITCODE = t3.PARK where t1.FACLOCID <> t3.Location
union all

-- FEATUREID
--     must be well-formed or null/empty (in which case we will generate a unique well-formed value)
--     Each POI should be unique; therefore all FeatureIDs should be unique
select OBJECTID, 'Error: FEATUREID is not unique' as Issue, NULL from gis.POI_PY_evw0 where FEATUREID in 
       (select FEATUREID from gis.POI_PY_evw0 where FEATUREID is not null and FEATUREID <> '' group by FEATUREID having count(*) > 1)
union all
select OBJECTID, 'Error: FEATUREID is not well-formed' as Issue, NULL
	from gis.POI_PY_evw0 where
	  -- Will ignore FEATUREID = NULL 
	  len(FEATUREID) <> 38 
	  OR left(FEATUREID,1) <> '{'
	  OR right(FEATUREID,1) <> '}'
	  OR FEATUREID like '{%[^0123456789ABCDEF-]%}' Collate Latin1_General_CS_AI
union all

-- GEOMETRYID
--     must be unique and well-formed or null/empty (in which case we will generate a unique well-formed value)
select OBJECTID, 'Error: GEOMETRYID is not unique' as Issue, NULL from gis.POI_PY_evw0 where GEOMETRYID in 
       (select GEOMETRYID from gis.POI_PY_evw0 where GEOMETRYID is not null and GEOMETRYID <> '' group by GEOMETRYID having count(*) > 1)
union all
select OBJECTID, 'Error: GEOMETRYID is not well-formed' as Issue, NULL
	from gis.POI_PY_evw0 where
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
select OBJECTID, 'Error: SHAPE must not be empty' as Issue, NULL from gis.POI_PY_evw0 where shape.STIsEmpty() = 1
union all
select OBJECTID, 'Error: SHAPE must be valid' as Issue, NULL from gis.POI_PY_evw0 where shape.STIsValid() = 0
-- Overlaps are possible (even exepcted among SITES)
-- Size checks are difficult because of variation in QTY units; May try later when trends are identified 

) AS I
on D.OBJECTID = I.OBJECTID
LEFT JOIN gis.QC_ISSUES_EXPLAINED_evw AS E
ON E.feature_oid = D.OBJECTID AND E.Issue = I.Issue AND E.Feature_class = 'POI_PY'
WHERE E.Explanation IS NULL or E.Explanation = ''
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Regan Sarwas
-- Create date: 2021-07-08
-- Description:	Calculated properties for POI_LN
--
-- These calcs are largely for records that are maintained (and synced) from a source database (like facilities)
-- Nevertheless, synced attributes will also be calced if not synced first.
--
-- NOTE: the versioned view of `POI_ln` is `POI_ln_evw0` (not `POI_ln_evw` as expected)
--
-- This file is identical to dbo.Calc_POI_Pt except for:
--  1) Copy/replace `gis.AKR_POI_PT_evw` with `gis.POI_ln_evw0`
--  2) Replace POINTTYPE with LINETYPE and 'Arbitrary point' with 'Arbitrary line'
--  3) Commented out the calcs from ISOUTPARK and UNITCODE
--     Spatial operation in SQL not possible with SDE binary geometry - uncomment when replaced with SQLServer geometry
-- Future changes to calc_poi_pt should be included in this file as well
-- =============================================
CREATE PROCEDURE [dbo].[Calc_POI_LN] 
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

    -- POINAME
    --     if it is an empty string, change to NULL
    update gis.POI_ln_evw0 set POINAME = NULL where POINAME = ''

    -- POIALTNAME
    --     if it is an empty string, change to NULL
    update gis.POI_ln_evw0 set POIALTNAME = NULL where POIALTNAME = ''
    
    -- MAPLABEL
    --     if it is an empty string, change to NULL
    update gis.POI_ln_evw0 set MAPLABEL = NULL where MAPLABEL = ''
    
    -- POITYPE
    --     No calcs; NULL, Empty and not in DOM trigger QC Error
    
    -- POIDESC
    --     if it is an empty string, change to NULL
    update gis.POI_ln_evw0 set POIDESC = NULL where POIDESC = ''

    -- SEASONAL
    --     if it is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.POI_ln_evw0 as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.POI_ln_evw0 as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM akr_facility2.dbo.FMSSExport_Asset as t1 JOIN akr_facility2.dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;

    -- SEASDESC
    --     if it is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.POI_ln_evw0 set SEASDESC = NULL where SEASDESC = ''
    update gis.POI_ln_evw0 set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'

    -- MAINTAINER
    --     if it is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null and f.FAMARESP is not null)
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT t.FAMARESP, a.Asset FROM akr_facility2.dbo.FMSSExport_Asset as a
      join (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, [Location] FROM akr_facility2.dbo.FMSSExport) as t
      on a.Location = t.Location) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;

    -- ISEXTANT
    --     it defaults to 'True' with a warning (during QC)
    update gis.POI_ln_evw0 set ISEXTANT = 'True' where ISEXTANT is NULL

    -- POINTTYPE
    --     if it is NULL or empty, set to 'Arbitrary line'
    update gis.POI_ln_evw0 set LINETYPE = 'Arbitrary line' where LINETYPE is null or LINETYPE = '' 

    -- ISCURRENTGEO -- No calcs; it is obsolete and will be removed shortly

    -- ISOUTPARK
    --     it is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    -- Not possible with SDE binary geometry - uncomment when replaced with SQLServer Geometry
/*
    merge into gis.POI_ln_evw0 as t1 using akr_facility2.gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;
*/
    -- PUBLICDISPLAY
    --     it defaults to No Public Map Display
    update gis.POI_ln_evw0 set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''

    -- DATAACCESS
    --     it defaults to No Public Map Display
    update gis.POI_ln_evw0 set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''

    -- UNITCODE
    --     it is a spatial calc if null
    -- Not possible with SDE binary geometry - uncomment when replaced with SQLServer Geometry
/*
    merge into gis.POI_ln_evw0 as t1 using akr_facility2.gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;
*/

    -- UNITNAME
    --     it is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.POI_ln_evw0 set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.POI_ln_evw0 as t1 using akr_facility2.dbo.DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;

    -- GROUPCODE
    --     if it is an empty string, change to NULL
    update gis.POI_ln_evw0 set GROUPCODE = NULL where GROUPCODE = ''

    -- GROUPNAME
    --     it is always calc'd from GROUPCODE
    update gis.POI_ln_evw0 set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.POI_ln_evw0 as t1 using akr_facility2.gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;

    -- REGIONCODE
    --     it is always set to AKR
    update gis.POI_ln_evw0 set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'

    -- CREATEUSER, CREATEDATE, EDITUSER, EDITDATE -- No Calcs (managed by system)

    -- MAPMETHOD
    --     if it is NULL or an empty string, change to Unknown
    update gis.POI_ln_evw0 set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''

    -- MAPSOURCE
    --     if it is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.POI_ln_evw0 set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''

    -- SOURCEDATE: Nothing to do.

    -- XYACCURACY
    --     if it is NULL or an empty string, change to Unknown
    update gis.POI_ln_evw0 set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''

    -- FACLOCID
    --     if it is empty string change to null
    update gis.POI_ln_evw0 set FACLOCID = NULL where FACLOCID = ''

    -- FACASSETID
    --     if it is empty string change to null
    update gis.POI_ln_evw0 set FACASSETID = NULL where FACASSETID = ''

    -- FEATUREID
    --     if it if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.POI_ln_evw0 set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''

    -- GEOMETRYID
    --     if it is null/empty
    update gis.POI_ln_evw0 set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''

    -- NOTES
    --     if it is an empty string, change to NULL
    update gis.POI_ln_evw0 set NOTES = NULL where NOTES = ''

    -- SRCDBNAME is for internal information only; No Calcs possible or required
    -- SRCDBIDFLD is for internal information only; No Calcs possible or required
    -- SRCDBIDVAL is for internal information only; No Calcs possible or required
    -- SRCDBNMFLD is for internal information only; No Calcs possible or required
    -- SRCDBNMVAL is for internal information only; No Calcs possible or required

    -- WEBEDITUSER -- No calcs; it is obsolete and will be removed shortly
    -- WEBCOMMENT -- No calcs; it is obsolete and will be removed shortly

    -- Shape -- No Calcs

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
-- Create date: 2021-07-08
-- Description:	Calculated properties for POI_PT
--
-- These calcs are largely for records that are maintained (and synced) from a source database (like facilities)
-- Nevertheless, synced attributes will also be calced if not synced first.
--
-- NOTE: the versioned view of `POI_pt` is `akr_POI_pt_evw` (not `POI_pt_evw` as expected)
-- 
-- NOTE: Calc_POI_PY and Calc_POI_LN are nearly identical copies of this file; changes should be synced across all scripts
-- =============================================
CREATE PROCEDURE [dbo].[Calc_POI_Pt] 
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

    -- POINAME
    --     if it is an empty string, change to NULL
    update gis.AKR_POI_PT_evw set POINAME = NULL where POINAME = ''

    -- POIALTNAME
    --     if it is an empty string, change to NULL
    update gis.AKR_POI_PT_evw set POIALTNAME = NULL where POIALTNAME = ''
    
    -- MAPLABEL
    --     if it is an empty string, change to NULL
    update gis.AKR_POI_PT_evw set MAPLABEL = NULL where MAPLABEL = ''
    
    -- POITYPE
    --     No calcs; NULL, Empty and not in DOM trigger QC Error
    
    -- POIDESC
    --     if it is an empty string, change to NULL
    update gis.AKR_POI_PT_evw set POIDESC = NULL where POIDESC = ''

    -- SEASONAL
    --     if it is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM akr_facility2.dbo.FMSSExport_Asset as t1 JOIN akr_facility2.dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;

    -- SEASDESC
    --     if it is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.AKR_POI_PT_evw set SEASDESC = NULL where SEASDESC = ''
    update gis.AKR_POI_PT_evw set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'

    -- MAINTAINER
    --     if it is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null and f.FAMARESP is not null)
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT t.FAMARESP, a.Asset FROM akr_facility2.dbo.FMSSExport_Asset as a
      join (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, [Location] FROM akr_facility2.dbo.FMSSExport) as t
      on a.Location = t.Location) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;

    -- ISEXTANT
    --     it defaults to 'True' with a warning (during QC)
    update gis.AKR_POI_PT_evw set ISEXTANT = 'True' where ISEXTANT is NULL

    -- POINTTYPE
    --     if it is NULL or empty, set to 'Arbitrary point'
    update gis.AKR_POI_PT_evw set POINTTYPE = 'Arbitrary point' where POINTTYPE is null or POINTTYPE = '' 

    -- ISCURRENTGEO -- No calcs; it is obsolete and will be removed shortly

    -- ISOUTPARK
    --     it is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.AKR_POI_PT_evw as t1 using akr_facility2.gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;

    -- PUBLICDISPLAY
    --     it defaults to No Public Map Display
    update gis.AKR_POI_PT_evw set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''

    -- DATAACCESS
    --     it defaults to No Public Map Display
    update gis.AKR_POI_PT_evw set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''

    -- UNITCODE
    --     it is a spatial calc if null
    merge into gis.AKR_POI_PT_evw as t1 using akr_facility2.gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;

    -- UNITNAME
    --     it is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.AKR_POI_PT_evw set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.AKR_POI_PT_evw as t1 using akr_facility2.dbo.DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;

    -- GROUPCODE
    --     if it is an empty string, change to NULL
    update gis.AKR_POI_PT_evw set GROUPCODE = NULL where GROUPCODE = ''

    -- GROUPNAME
    --     it is always calc'd from GROUPCODE
    update gis.AKR_POI_PT_evw set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.AKR_POI_PT_evw as t1 using akr_facility2.gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;

    -- REGIONCODE
    --     it is always set to AKR
    update gis.AKR_POI_PT_evw set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'

    -- CREATEUSER, CREATEDATE, EDITUSER, EDITDATE -- No Calcs (managed by system)

    -- MAPMETHOD
    --     if it is NULL or an empty string, change to Unknown
    update gis.AKR_POI_PT_evw set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''

    -- MAPSOURCE
    --     if it is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.AKR_POI_PT_evw set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''

    -- SOURCEDATE: Nothing to do.

    -- XYACCURACY
    --     if it is NULL or an empty string, change to Unknown
    update gis.AKR_POI_PT_evw set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''

    -- FACLOCID
    --     if it is empty string change to null
    update gis.AKR_POI_PT_evw set FACLOCID = NULL where FACLOCID = ''

    -- FACASSETID
    --     if it is empty string change to null
    update gis.AKR_POI_PT_evw set FACASSETID = NULL where FACASSETID = ''

    -- FEATUREID
    --     if it if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.AKR_POI_PT_evw set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''

    -- GEOMETRYID
    --     if it is null/empty
    update gis.AKR_POI_PT_evw set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''

    -- NOTES
    --     if it is an empty string, change to NULL
    update gis.AKR_POI_PT_evw set NOTES = NULL where NOTES = ''

    -- SRCDBNAME is for internal information only; No Calcs possible or required
    -- SRCDBIDFLD is for internal information only; No Calcs possible or required
    -- SRCDBIDVAL is for internal information only; No Calcs possible or required
    -- SRCDBNMFLD is for internal information only; No Calcs possible or required
    -- SRCDBNMVAL is for internal information only; No Calcs possible or required

    -- WEBEDITUSER -- No calcs; it is obsolete and will be removed shortly
    -- WEBCOMMENT -- No calcs; it is obsolete and will be removed shortly

    -- Shape -- No Calcs

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
-- Create date: 2021-07-08
-- Description:	Calculated properties for POI_PY
--
-- These calcs are largely for records that are maintained (and synced) from a source database (like facilities)
-- Nevertheless, synced attributes will also be calced if not synced first.
--
-- NOTE: the versioned view of `POI_py` is `POI_py_evw0` (not `POI_py_evw` as expected)
--
-- This file is identical to dbo.Calc_POI_Pt except for:
--  1) Copy/replace `gis.AKR_POI_PT_evw` with `gis.POI_py_evw0`
--  2) Replace POINTTYPE with POLYGONTYPE and 'Arbitrary point' with 'Circumscribed polygon'
-- Future changes to calc_poi_pt should be included in this file as well
-- =============================================
CREATE PROCEDURE [dbo].[Calc_POI_PY] 
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

    -- POINAME
    --     if it is an empty string, change to NULL
    update gis.POI_py_evw0 set POINAME = NULL where POINAME = ''

    -- POIALTNAME
    --     if it is an empty string, change to NULL
    update gis.POI_py_evw0 set POIALTNAME = NULL where POIALTNAME = ''
    
    -- MAPLABEL
    --     if it is an empty string, change to NULL
    update gis.POI_py_evw0 set MAPLABEL = NULL where MAPLABEL = ''
    
    -- POITYPE
    --     No calcs; NULL, Empty and not in DOM trigger QC Error
    
    -- POIDESC
    --     if it is an empty string, change to NULL
    update gis.POI_py_evw0 set POIDESC = NULL where POIDESC = ''

    -- SEASONAL
    --     if it is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.POI_py_evw0 as p
      using (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM akr_facility2.dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;
    merge into gis.POI_py_evw0 as p
      using (SELECT case when t2.OPSEAS = 'Y' then 'Yes' when t2.OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, t1.Asset
            FROM akr_facility2.dbo.FMSSExport_Asset as t1 JOIN akr_facility2.dbo.FMSSExport as t2 on t1.Location = t2.Location) as f
      on f.Asset = p.FACLOCID and (p.SEASONAL is null and f.OPSEAS is not null)
      when matched then update set SEASONAL = f.OPSEAS;

    -- SEASDESC
    --     if it is an empty string, change to NULL
    --     Provide a default of "Winter seasonal closure" if null and SEASONAL = 'Yes'
    update gis.POI_py_evw0 set SEASDESC = NULL where SEASDESC = ''
    update gis.POI_py_evw0 set SEASDESC = 'Winter seasonal closure' where SEASDESC is null and SEASONAL = 'Yes'

    -- MAINTAINER
    --     if it is null and FACLOCID is non-null or FACASSETID is non-null use FMSS Lookup.
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM akr_facility2.dbo.FMSSExport) as f
      on f.Location = p.FACLOCID and (p.MAINTAINER is null and f.FAMARESP is not null)
      when matched then update set MAINTAINER = f.FAMARESP;
    merge into gis.AKR_POI_PT_evw as p
      using (SELECT t.FAMARESP, a.Asset FROM akr_facility2.dbo.FMSSExport_Asset as a
      join (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, [Location] FROM akr_facility2.dbo.FMSSExport) as t
      on a.Location = t.Location) as f
      on f.Asset = p.FACASSETID and (p.MAINTAINER is null or p.MAINTAINER = '' or p.MAINTAINER = 'Unknown') and f.FAMARESP is not null
      when matched then update set MAINTAINER = f.FAMARESP;

    -- ISEXTANT
    --     it defaults to 'True' with a warning (during QC)
    update gis.POI_py_evw0 set ISEXTANT = 'True' where ISEXTANT is NULL

    -- POINTTYPE
    --     if it is NULL or empty, set to 'Arbitrary point'
    update gis.POI_py_evw0 set POLYGONTYPE = 'Circumscribed polygon' where POLYGONTYPE is null or POLYGONTYPE = '' 

    -- ISCURRENTGEO -- No calcs; it is obsolete and will be removed shortly

    -- ISOUTPARK
    --     it is always calced based on the features location; assumes UNITCODE is QC'd and missing values populated
    merge into gis.POI_py_evw0 as t1 using akr_facility2.gis.AKR_UNIT as t2
      on t1.UNITCODE = t2.Unit_Code and (t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK)
      when matched then update set ISOUTPARK = CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END;

    -- PUBLICDISPLAY
    --     it defaults to No Public Map Display
    update gis.POI_py_evw0 set PUBLICDISPLAY = 'No Public Map Display' where PUBLICDISPLAY is NULL or PUBLICDISPLAY = ''

    -- DATAACCESS
    --     it defaults to No Public Map Display
    update gis.POI_py_evw0 set DATAACCESS = 'Internal NPS Only' where DATAACCESS is NULL or DATAACCESS = ''

    -- UNITCODE
    --     it is a spatial calc if null
    merge into gis.POI_py_evw0 as t1 using akr_facility2.gis.AKR_UNIT as t2
      on t1.Shape.STIntersects(t2.Shape) = 1 and t1.UNITCODE is null and t2.Unit_Code is not null
      when matched then update set UNITCODE = t2.Unit_Code;

    -- UNITNAME
    --     it is always calc'd from UNITCODE
    --     We use DOM_UNITCODE because it is a superset of AKR_UNIT.  (UNITNAME has been standardized to values in AKR_UNIT)
    update gis.POI_py_evw0 set UNITNAME = NULL where UNITCODE is null and UNITNAME is not null
    merge into gis.POI_py_evw0 as t1 using akr_facility2.dbo.DOM_UNITCODE as t2
      on t1.UNITCODE = t2.Code and (t1.UNITNAME <> t2.UNITNAME or (t1.UNITNAME is null and t2.UNITNAME is not null))
      when matched then update set UNITNAME = t2.UNITNAME;

    -- GROUPCODE
    --     if it is an empty string, change to NULL
    update gis.POI_py_evw0 set GROUPCODE = NULL where GROUPCODE = ''

    -- GROUPNAME
    --     it is always calc'd from GROUPCODE
    update gis.POI_py_evw0 set GROUPNAME = NULL where GROUPCODE is null and GROUPNAME is not null
    merge into gis.POI_py_evw0 as t1 using akr_facility2.gis.AKR_GROUP as t2
      on t1.GROUPCODE = t2.Group_Code and t1.GROUPNAME <> t2.Group_Name
      when matched then update set GROUPNAME = t2.Group_Name;

    -- REGIONCODE
    --     it is always set to AKR
    update gis.POI_py_evw0 set REGIONCODE = 'AKR' where REGIONCODE is null or REGIONCODE <> 'AKR'

    -- CREATEUSER, CREATEDATE, EDITUSER, EDITDATE -- No Calcs (managed by system)

    -- MAPMETHOD
    --     if it is NULL or an empty string, change to Unknown
    update gis.POI_py_evw0 set MAPMETHOD = 'Unknown' where MAPMETHOD is NULL or MAPMETHOD = ''

    -- MAPSOURCE
    --     if it is NULL or an empty string, change to Unknown
    --     by SQL Magic '' is the same as any string of just white space
    update gis.POI_py_evw0 set MAPSOURCE = 'Unknown' where MAPSOURCE is NULL or MAPSOURCE = ''

    -- SOURCEDATE: Nothing to do.

    -- XYACCURACY
    --     if it is NULL or an empty string, change to Unknown
    update gis.POI_py_evw0 set XYACCURACY = 'Unknown' where XYACCURACY is NULL or XYACCURACY = ''

    -- FACLOCID
    --     if it is empty string change to null
    update gis.POI_py_evw0 set FACLOCID = NULL where FACLOCID = ''

    -- FACASSETID
    --     if it is empty string change to null
    update gis.POI_py_evw0 set FACASSETID = NULL where FACASSETID = ''

    -- FEATUREID
    --     if it if null/empty in gis.AKR_BLDG_CENTER_PT
    update gis.POI_py_evw0 set FEATUREID = '{' + convert(varchar(max),newid()) + '}' where FEATUREID is null or FEATUREID = ''

    -- GEOMETRYID
    --     if it is null/empty
    update gis.POI_py_evw0 set GEOMETRYID = '{' + convert(varchar(max),newid()) + '}' where GEOMETRYID is null or GEOMETRYID = ''

    -- NOTES
    --     if it is an empty string, change to NULL
    update gis.POI_py_evw0 set NOTES = NULL where NOTES = ''

    -- SRCDBNAME is for internal information only; No Calcs possible or required
    -- SRCDBIDFLD is for internal information only; No Calcs possible or required
    -- SRCDBIDVAL is for internal information only; No Calcs possible or required
    -- SRCDBNMFLD is for internal information only; No Calcs possible or required
    -- SRCDBNMVAL is for internal information only; No Calcs possible or required

    -- WEBEDITUSER -- No calcs; it is obsolete and will be removed shortly
    -- WEBCOMMENT -- No calcs; it is obsolete and will be removed shortly

    -- Shape -- No Calcs

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
-- Create date: 2021-07-08
-- Description:	Sync attributes with a source table
--
-- These calcs replace attributes with the source attributes for records that are maintained in a source database (like facilities)
-- 
-- This file is nearly identical to Sync_POI_Pt_with_TrailFeatures; changes made to one should likely be made to the other
-- =============================================

CREATE PROCEDURE [dbo].[Sync_POI_Pt_with_Buildings] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500),
    @source_version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the source version
    --   IMPORTANT:
    --   As of 2021-07-13: the source version view pulls from the source base table, not the version or even default view.
    --   Thia appears to be a bug. Work around was to compress tostate zero, so the base table reflected the source version
    --   Other solutions may be:
    --      1) set master as current database, and run all queries with fully qualified view names
    --      2) Upgrade the geodatabae on akr_socio (it is still at 10.2, while facilities is at 10.8)
    exec akr_facility2.sde.set_current_version @source_version

    -- Set the version to edit
    exec sde.set_current_version @version
    
    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- POINAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.POINAME <> b.BLDGNAME or (p.POINAME is null and b.BLDGNAME is not null) or (p.POINAME is not null and b.BLDGNAME is null))
      when matched then update set POINAME = b.BLDGNAME;

    -- POIALTNAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.POIALTNAME <> b.BLDGALTNAME or (p.POIALTNAME is null and b.BLDGALTNAME is not null) or (p.POIALTNAME is not null and b.BLDGALTNAME is null))
      when matched then update set POIALTNAME = b.BLDGALTNAME;
    
    -- MAPLABEL
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.MAPLABEL <> b.MAPLABEL or (p.MAPLABEL is null and b.MAPLABEL is not null) or (p.MAPLABEL is not null and b.MAPLABEL is null))
      when matched then update set MAPLABEL = b.MAPLABEL;
    
    -- POITYPE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.POITYPE <> b.POITYPE or (p.POITYPE is null and b.POITYPE is not null) or (p.POITYPE is not null and b.POITYPE is null))
      when matched then update set POITYPE = b.POITYPE;
    
    -- POIDESC
    --     No source value in buildings

    -- SEASONAL
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.SEASONAL <> b.SEASONAL or (p.SEASONAL is null and b.SEASONAL is not null) or (p.SEASONAL is not null and b.SEASONAL is null))
      when matched then update set SEASONAL = b.SEASONAL;

    -- SEASDESC
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.SEASDESC <> b.SEASDESC or (p.SEASDESC is null and b.SEASDESC is not null) or (p.SEASDESC is not null and b.SEASDESC is null))
      when matched then update set SEASDESC = b.SEASDESC;

    -- MAINTAINER
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.MAINTAINER <> b.FACMAINTAIN or (p.MAINTAINER is null and b.FACMAINTAIN is not null) or (p.MAINTAINER is not null and b.FACMAINTAIN is null))
      when matched then update set MAINTAINER = b.FACMAINTAIN;

    -- ISEXTANT
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.ISEXTANT <> b.ISEXTANT or (p.ISEXTANT is null and b.ISEXTANT is not null) or (p.ISEXTANT is not null and b.ISEXTANT is null))
      when matched then update set ISEXTANT = b.ISEXTANT;

    -- POINTTYPE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.POINTTYPE <> b.POINTTYPE or (p.POINTTYPE is null and b.POINTTYPE is not null) or (p.POINTTYPE is not null and b.POINTTYPE is null))
      when matched then update set POINTTYPE = b.POINTTYPE;

    -- ISCURRENTGEO -- No calcs; it is obsolete and will be removed shortly

    -- ISOUTPARK
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.ISOUTPARK <> b.ISOUTPARK or (p.ISOUTPARK is null and b.ISOUTPARK is not null) or (p.ISOUTPARK is not null and b.ISOUTPARK is null))
      when matched then update set ISOUTPARK = b.ISOUTPARK;

    -- PUBLICDISPLAY
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.PUBLICDISPLAY <> b.PUBLICDISPLAY or (p.PUBLICDISPLAY is null and b.PUBLICDISPLAY is not null) or (p.PUBLICDISPLAY is not null and b.PUBLICDISPLAY is null))
      when matched then update set PUBLICDISPLAY = b.PUBLICDISPLAY;

    -- DATAACCESS
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.DATAACCESS <> b.DATAACCESS or (p.DATAACCESS is null and b.DATAACCESS is not null) or (p.DATAACCESS is not null and b.DATAACCESS is null))
      when matched then update set DATAACCESS = b.DATAACCESS;

    -- UNITCODE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.UNITCODE <> b.UNITCODE or (p.UNITCODE is null and b.UNITCODE is not null) or (p.UNITCODE is not null and b.UNITCODE is null))
      when matched then update set UNITCODE = b.UNITCODE;

    -- UNITNAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.UNITNAME <> b.UNITNAME or (p.UNITNAME is null and b.UNITNAME is not null) or (p.UNITNAME is not null and b.UNITNAME is null))
      when matched then update set UNITNAME = b.UNITNAME;

    -- GROUPCODE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.GROUPCODE <> b.GROUPCODE or (p.GROUPCODE is null and b.GROUPCODE is not null) or (p.GROUPCODE is not null and b.GROUPCODE is null))
      when matched then update set GROUPCODE = b.GROUPCODE;

    -- GROUPNAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.GROUPNAME <> b.GROUPNAME or (p.GROUPNAME is null and b.GROUPNAME is not null) or (p.GROUPNAME is not null and b.GROUPNAME is null))
      when matched then update set GROUPNAME = b.GROUPNAME;

    -- REGIONCODE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.REGIONCODE <> b.REGIONCODE or (p.REGIONCODE is null and b.REGIONCODE is not null) or (p.REGIONCODE is not null and b.REGIONCODE is null))
      when matched then update set REGIONCODE = b.REGIONCODE;

    -- CREATEUSER, CREATEDATE, EDITUSER, EDITDATE -- No Calcs (managed by system)

    -- MAPMETHOD
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.MAPMETHOD <> b.MAPMETHOD or (p.MAPMETHOD is null and b.MAPMETHOD is not null) or (p.MAPMETHOD is not null and b.MAPMETHOD is null))
      when matched then update set MAPMETHOD = b.MAPMETHOD;

    -- MAPSOURCE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.MAPSOURCE <> b.MAPSOURCE or (p.MAPSOURCE is null and b.MAPSOURCE is not null) or (p.MAPSOURCE is not null and b.MAPSOURCE is null))
      when matched then update set MAPSOURCE = b.MAPSOURCE;

    -- SOURCEDATE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.SOURCEDATE <> b.SOURCEDATE or (p.SOURCEDATE is null and b.SOURCEDATE is not null) or (p.SOURCEDATE is not null and b.SOURCEDATE is null))
      when matched then update set SOURCEDATE = b.SOURCEDATE;

    -- XYACCURACY
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.XYACCURACY <> b.XYACCURACY or (p.XYACCURACY is null and b.XYACCURACY is not null) or (p.XYACCURACY is not null and b.XYACCURACY is null))
      when matched then update set XYACCURACY = b.XYACCURACY;

    -- FACLOCID
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.FACLOCID <> b.FACLOCID or (p.FACLOCID is null and b.FACLOCID is not null) or (p.FACLOCID is not null and b.FACLOCID is null))
      when matched then update set FACLOCID = b.FACLOCID;

    -- FACASSETID
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.FACASSETID <> b.FACASSETID or (p.FACASSETID is null and b.FACASSETID is not null) or (p.FACASSETID is not null and b.FACASSETID is null))
      when matched then update set FACASSETID = b.FACASSETID;

    -- FEATUREID
    --     This is unique to the POI feature

    -- GEOMETRYID
    --     This is unique to the this geometry

    -- NOTES
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.NOTES <> b.NOTES or (p.NOTES is null and b.NOTES is not null) or (p.NOTES is not null and b.NOTES is null))
      when matched then update set NOTES = b.NOTES;

    -- SRCDBNAME is for internal information only; No Calcs possible or required
    -- SRCDBIDFLD is for internal information only; No Calcs possible or required
    -- SRCDBIDVAL is for internal information only; No Calcs possible or required
    -- SRCDBNMFLD is for internal information only; No Calcs possible or required
    -- SRCDBNMVAL is for internal information only; No Calcs possible or required

    -- WEBEDITUSER -- No calcs; it is obsolete and will be removed shortly
    -- WEBCOMMENT -- No calcs; it is obsolete and will be removed shortly

    -- Shape
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.AKR_BLDG_CENTER_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.AKR_BLDG_CENTER_PT' and p.SRCDBIDVAL = b.FEATUREID
      and (p.Shape.STY <> b.Shape.STY or p.Shape.STX <> b.Shape.STY)
      when matched then update set Shape = Geometry::Point(b.Shape.STX, b.Shape.STY, b.Shape.STSrid);

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
-- Create date: 2021-07-08
-- Description:	Sync attributes with a source table
--
-- These calcs replace attributes with the source attributes for records that are maintained in a source database (like facilities)
-- 
-- This file is nearly identical to Sync_POI_Pt_with_Buildings; changes made to one should likely be made to the other
-- =============================================

CREATE PROCEDURE [dbo].[Sync_POI_Pt_with_TrailFeatures] 
    -- Add the parameters for the stored procedure here
    @version nvarchar(500),
    @source_version nvarchar(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Set the source version
    --   IMPORTANT:
    --   As of 2021-07-13: the source version view pulls from the source base table, not the version or even default view.
    --   Thia appears to be a bug. Work around was to compress tostate zero, so the base table reflected the source version
    --   Other solutions may be:
    --      1) set master as current database, and run all queries with fully qualified view names
    --      2) Upgrade the geodatabae on akr_socio (it is still at 10.2, while facilities is at 10.8)
    exec akr_facility2.sde.set_current_version @source_version

    -- Set the version to edit
    exec sde.set_current_version @version

    -- Start editing
    exec sde.edit_version @version, 1 -- 1 to start edits

    -- add/update calculated values

    -- POINAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.POINAME <> b.TRLFEATNAME or (p.POINAME is null and b.TRLFEATNAME is not null) or (p.POINAME is not null and b.TRLFEATNAME is null))
      when matched then update set POINAME = b.TRLFEATNAME;

    -- POIALTNAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.POIALTNAME <> b.TRLFEATALTNAME or (p.POIALTNAME is null and b.TRLFEATALTNAME is not null) or (p.POIALTNAME is not null and b.TRLFEATALTNAME is null))
      when matched then update set POIALTNAME = b.TRLFEATALTNAME;
    
    -- MAPLABEL
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.MAPLABEL <> b.MAPLABEL or (p.MAPLABEL is null and b.MAPLABEL is not null) or (p.MAPLABEL is not null and b.MAPLABEL is null))
      when matched then update set MAPLABEL = b.MAPLABEL;
    
    -- POITYPE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.POITYPE <> b.POITYPE or (p.POITYPE is null and b.POITYPE is not null) or (p.POITYPE is not null and b.POITYPE is null))
      when matched then update set POITYPE = b.POITYPE;
    
    -- POIDESC
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.POIDESC <> b.TRLFEATDESC or (p.POIDESC is null and b.TRLFEATDESC is not null) or (p.POIDESC is not null and b.TRLFEATDESC is null))
      when matched then update set POIDESC = b.TRLFEATDESC;

    -- SEASONAL
    --     No source value in Trail Features

    -- SEASDESC
    --     No source value in Trail Features

    -- MAINTAINER
    --     No source value in Trail Features

    -- ISEXTANT
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.ISEXTANT <> b.ISEXTANT or (p.ISEXTANT is null and b.ISEXTANT is not null) or (p.ISEXTANT is not null and b.ISEXTANT is null))
      when matched then update set ISEXTANT = b.ISEXTANT;

    -- POINTTYPE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.POINTTYPE <> b.POINTTYPE or (p.POINTTYPE is null and b.POINTTYPE is not null) or (p.POINTTYPE is not null and b.POINTTYPE is null))
      when matched then update set POINTTYPE = b.POINTTYPE;

    -- ISCURRENTGEO -- No calcs; it is obsolete and will be removed shortly

    -- ISOUTPARK
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.ISOUTPARK <> b.ISOUTPARK or (p.ISOUTPARK is null and b.ISOUTPARK is not null) or (p.ISOUTPARK is not null and b.ISOUTPARK is null))
      when matched then update set ISOUTPARK = b.ISOUTPARK;

    -- PUBLICDISPLAY
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.PUBLICDISPLAY <> b.PUBLICDISPLAY or (p.PUBLICDISPLAY is null and b.PUBLICDISPLAY is not null) or (p.PUBLICDISPLAY is not null and b.PUBLICDISPLAY is null))
      when matched then update set PUBLICDISPLAY = b.PUBLICDISPLAY;

    -- DATAACCESS
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.DATAACCESS <> b.DATAACCESS or (p.DATAACCESS is null and b.DATAACCESS is not null) or (p.DATAACCESS is not null and b.DATAACCESS is null))
      when matched then update set DATAACCESS = b.DATAACCESS;

    -- UNITCODE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.UNITCODE <> b.UNITCODE or (p.UNITCODE is null and b.UNITCODE is not null) or (p.UNITCODE is not null and b.UNITCODE is null))
      when matched then update set UNITCODE = b.UNITCODE;

    -- UNITNAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.UNITNAME <> b.UNITNAME or (p.UNITNAME is null and b.UNITNAME is not null) or (p.UNITNAME is not null and b.UNITNAME is null))
      when matched then update set UNITNAME = b.UNITNAME;

    -- GROUPCODE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.GROUPCODE <> b.GROUPCODE or (p.GROUPCODE is null and b.GROUPCODE is not null) or (p.GROUPCODE is not null and b.GROUPCODE is null))
      when matched then update set GROUPCODE = b.GROUPCODE;

    -- GROUPNAME
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.GROUPNAME <> b.GROUPNAME or (p.GROUPNAME is null and b.GROUPNAME is not null) or (p.GROUPNAME is not null and b.GROUPNAME is null))
      when matched then update set GROUPNAME = b.GROUPNAME;

    -- REGIONCODE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.REGIONCODE <> b.REGIONCODE or (p.REGIONCODE is null and b.REGIONCODE is not null) or (p.REGIONCODE is not null and b.REGIONCODE is null))
      when matched then update set REGIONCODE = b.REGIONCODE;

    -- CREATEUSER, CREATEDATE, EDITUSER, EDITDATE -- No Calcs (managed by system)

    -- MAPMETHOD
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.MAPMETHOD <> b.MAPMETHOD or (p.MAPMETHOD is null and b.MAPMETHOD is not null) or (p.MAPMETHOD is not null and b.MAPMETHOD is null))
      when matched then update set MAPMETHOD = b.MAPMETHOD;

    -- MAPSOURCE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.MAPSOURCE <> b.MAPSOURCE or (p.MAPSOURCE is null and b.MAPSOURCE is not null) or (p.MAPSOURCE is not null and b.MAPSOURCE is null))
      when matched then update set MAPSOURCE = b.MAPSOURCE;

    -- SOURCEDATE
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.SOURCEDATE <> b.SOURCEDATE or (p.SOURCEDATE is null and b.SOURCEDATE is not null) or (p.SOURCEDATE is not null and b.SOURCEDATE is null))
      when matched then update set SOURCEDATE = b.SOURCEDATE;

    -- XYACCURACY
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.XYACCURACY <> b.XYACCURACY or (p.XYACCURACY is null and b.XYACCURACY is not null) or (p.XYACCURACY is not null and b.XYACCURACY is null))
      when matched then update set XYACCURACY = b.XYACCURACY;

    -- FACLOCID
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.FACLOCID <> b.FACLOCID or (p.FACLOCID is null and b.FACLOCID is not null) or (p.FACLOCID is not null and b.FACLOCID is null))
      when matched then update set FACLOCID = b.FACLOCID;

    -- FACASSETID
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.FACASSETID <> b.FACASSETID or (p.FACASSETID is null and b.FACASSETID is not null) or (p.FACASSETID is not null and b.FACASSETID is null))
      when matched then update set FACASSETID = b.FACASSETID;

    -- FEATUREID
    --     This is unique to the POI feature

    -- GEOMETRYID
    --     This is unique to the this geometry

    -- NOTES
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.NOTES <> b.NOTES or (p.NOTES is null and b.NOTES is not null) or (p.NOTES is not null and b.NOTES is null))
      when matched then update set NOTES = b.NOTES;

    -- SRCDBNAME is for internal information only; No Calcs possible or required
    -- SRCDBIDFLD is for internal information only; No Calcs possible or required
    -- SRCDBIDVAL is for internal information only; No Calcs possible or required
    -- SRCDBNMFLD is for internal information only; No Calcs possible or required
    -- SRCDBNMVAL is for internal information only; No Calcs possible or required

    -- WEBEDITUSER -- No calcs; it is obsolete and will be removed shortly
    -- WEBCOMMENT -- No calcs; it is obsolete and will be removed shortly

    -- Shape
    merge into gis.AKR_POI_PT_evw as p
      using akr_facility2.gis.TRAILS_FEATURE_PT_evw as b
      on p.SRCDBNAME = 'akr_facility2.GIS.TRAILS_FEATURE_PT' and p.SRCDBIDVAL = b.GEOMETRYID
      and (p.Shape.STY <> b.Shape.STY or p.Shape.STX <> b.Shape.STY)
      when matched then update set Shape = Geometry::Point(b.Shape.STX, b.Shape.STY, b.Shape.STSrid);

    -- Stop editing
    exec sde.edit_version @version, 2; -- 2 to stop edits

END
GO
