-- Checking Photo foreign keys

-- We have all the old photos
select * from gis.AKR_ATTACH_evw as p left join gis.XXPHOTOS as p2 on p.UNITCODE = p2.Unit and p.ATCHNAME = p2.Filename where p2.OBJECTID is null
-- Bad FACLOCID = 0
select * from gis.AKR_ATTACH_evw as p left join FMSSExport as f             on p.FACLOCID = f.Location   where p.FACLOCID is not null and f.Location is null
-- BAD FEATUREID (with current buildings) = 10 photos, 3 buildings
select * from gis.AKR_ATTACH_evw as p left join gis.AKR_BLDG_CENTER_PT as b on p.FEATUREID = b.FEATUREID where p.FEATUREID is not null and b.FEATUREID is null
-- BAD FEATUREID (with all buildings, including archive) = 0
select * from gis.AKR_ATTACH_evw as p left join gis.AKR_BLDG_CENTER_PT_H as b on p.FEATUREID = b.FEATUREID where p.FEATUREID is not null and b.FEATUREID is null
-- BAD FACASSETID = 12
select * from gis.AKR_ATTACH_evw as p left join FMSSExport_Asset as f       on p.FACASSETID = f.Asset    where p.FACASSETID is not null and f.Asset is null
-- BAD FACASSETID, but another id is available = 10
select * from gis.AKR_ATTACH_evw as p left join FMSSExport_Asset as f       on p.FACASSETID = f.Asset    where p.FACASSETID is not null and f.Asset is null and (p.FEATUREID is not null or p.FACLOCID is not null)
-- BAD FACASSETID, but FACASSETID equals a valid FACLOCID = 10 (same as above)
select * from gis.AKR_ATTACH_evw as p left join FMSSExport as f on p.FACASSETID = f.Location left join FMSSExport_Asset as a on p.FACASSETID = a.Asset    where p.FACASSETID is not null and a.Asset is null and f.Location is not null
-- no foreign key = 88
select * from gis.AKR_ATTACH_evw where FACASSETID is null and FACLOCID is null and FEATUREID is null and GEOMETRYID is null
-- multiple foreign keys = 16 (all involve FACASSETID)
select * from gis.AKR_ATTACH_evw where 
  (FACASSETID is not null and not (FACLOCID is null and FEATUREID is null and GEOMETRYID is null)) or
  (FACLOCID is not null and not (FACASSETID is null and FEATUREID is null and GEOMETRYID is null)) or
  (FEATUREID is not null and not (FACLOCID is null and FACASSETID is null and GEOMETRYID is null)) or
  (GEOMETRYID is not null and not (FACLOCID is null and FEATUREID is null and FACASSETID is null))
-- FACLOCID not in a building dataset = 248
select * from gis.AKR_ATTACH_evw as p join FMSSExport as f on p.FACLOCID = f.Location
  left join gis.AKR_BLDG_CENTER_PT as b on b.FACLOCID = f.Location where p.FACLOCID is not null and b.FACLOCID is null
-- FACLOCID not in archived building dataset = 148
select * from gis.AKR_ATTACH_evw as p join FMSSExport as f on p.FACLOCID = f.Location
  left join gis.AKR_BLDG_CENTER_PT_H as b on b.FACLOCID = f.Location where p.FACLOCID is not null and b.FACLOCID is null
-- FACLOCID not in archived building dataset, but parent is = 25
select * from gis.AKR_ATTACH_evw as p join FMSSExport as f on p.FACLOCID = f.Location
  left join gis.AKR_BLDG_CENTER_PT_H as b on b.FACLOCID = f.Location
  left join gis.AKR_BLDG_CENTER_PT_H as b2 on b2.FACLOCID = f.Parent where p.FACLOCID is not null and b.FACLOCID is null and b2.FACLOCID is not null
-- Photos of a child of a building = 544
select * from gis.AKR_BLDG_CENTER_PT_H as b join FMSSExport as f on b.FACLOCID = f.parent join gis.AKR_ATTACH_evw as p on p.FACLOCID = f.Location
-- Photos of a non-building child of a building = 26
select * from gis.AKR_BLDG_CENTER_PT_H as b join FMSSExport as f on b.FACLOCID = f.parent join gis.AKR_ATTACH_evw as p on p.FACLOCID = f.Location and f.Asset_Code <> 4100
