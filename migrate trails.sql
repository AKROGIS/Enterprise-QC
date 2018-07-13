
-- for the following:
--   Yes => the trail was specifically designed/built/maintained for this activity
--   No => this activity is specifically prohiibted on this trail
--   Null => either the question hasn't been asked/answered, the answer is unknowable, or neither Yes nor No apply
-- These values are used to calculate the TRLUSE attribute; for every attribute with a Yes, a cooresponding piece of standard text is added to the TRLUSE column.
--   Similarly a No value can be used to add to the negative to the TRLUSE column (i.e. "No Bicylces"); however this is non-standard
--   No values could also be used to populate a TRLRESTRICTIONS column, but this is also non-standard
-- Several of these are seasonal, i.e. winter only activities  (not clear how that is captured or presented)
-- Several of these imply other values in other attributes.  e.g. TRLTYPE better be "Water Trail" for TRLUSE_CANOE = "Yes"
select TRLUSE_FOOT, count(*) from gis.TRAILS_LN group by TRLUSE_FOOT
select TRLUSE_BICYCLE, count(*) from gis.TRAILS_LN group by TRLUSE_BICYCLE
select TRLUSE_HORSE, count(*) from gis.TRAILS_LN group by TRLUSE_HORSE
select TRLUSE_ATV, count(*) from gis.TRAILS_LN group by TRLUSE_ATV
select TRLUSE_4WD, count(*) from gis.TRAILS_LN group by TRLUSE_4WD
select TRLUSE_MOTORCYCLE, count(*) from gis.TRAILS_LN group by TRLUSE_MOTORCYCLE
select TRLUSE_SNOWMOBILE, count(*) from gis.TRAILS_LN group by TRLUSE_SNOWMOBILE
select TRLUSE_SNOWSHOE, count(*) from gis.TRAILS_LN group by TRLUSE_SNOWSHOE
select TRLUSE_NORDIC, count(*) from gis.TRAILS_LN group by TRLUSE_NORDIC
select TRLUSE_DOGSLED, count(*) from gis.TRAILS_LN group by TRLUSE_DOGSLED
select TRLUSE_MOTORBOAT, count(*) from gis.TRAILS_LN group by TRLUSE_MOTORBOAT
select TRLUSE_CANOE, count(*) from gis.TRAILS_LN group by TRLUSE_CANOE
-- AKR Custom
select TRLUSE_OHVSUB, count(*) from gis.TRAILS_LN group by TRLUSE_OHVSUB
select TRLUSE_SKITOUR, count(*) from gis.TRAILS_LN group by TRLUSE_SKITOUR
select TRLUSE_DOWNHILL, count(*) from gis.TRAILS_LN group by TRLUSE_DOWNHILL
select TRLUSE_CANYONEER, count(*) from gis.TRAILS_LN group by TRLUSE_CANYONEER
select TRLUSE_CLIMB, count(*) from gis.TRAILS_LN group by TRLUSE_CLIMB

-- How will this be used?  It is implied if all the other uses are null
--  Suggest it be deleted.  It has no useful information.
select TRLUSE_UNKNOWN, count(*) from gis.TRAILS_LN group by TRLUSE_UNKNOWN

-- for the following:
--   Yes => the trail is this "kind" of trail
--   No => this trail is not this "kind" of a trail (default; assumed value for Null)
--   Null => either the question hasn't been asked/answered, the answer is unknowable.  Implies No
-- SOCIAL trail - a non-planned/designed/maintained path created by multiple people walking over the same location.  Usually because it is the most efficient/direct/convenient path from A to B
-- ANIMAL trail - a non-maintained path created by multiple animals walking over the same location.  Usually because it is the most efficient/direct/convenient path from A to B, may be used by humans, but they are not the primary animal developing the trail
--    A trail can be both a social trail and an animal trail, but it is typically one or the other depending on which kind of animal uses it the most.
-- ADMIN trail - a trail designed/built/maintained specifically for use by park staff and not for use by the public.  I.e a trail from camp housing to a place of work
select TRLISSOCIAL, count(*) from gis.TRAILS_LN group by TRLISSOCIAL -- was TRLUSE_SOCIAL
select TRLISANIMAL, count(*) from gis.TRAILS_LN group by TRLISANIMAL -- was TRLUSE_ANIMAL
select TRLISADMIN, count(*) from gis.TRAILS_LN group by TRLISADMIN


--There was some wrangling for the above attributes 'Unknown' => Null, TRLISADMIN = 'Not Applicable' => TRLISADMIN = 'No'

select TRLTYPE, TRLFEATTYPE, TRLISADMIN, TRLISANIMAL, TRLISSOCIAL from gis.TRAILS_LN group by TRLTYPE, TRLFEATTYPE, TRLISADMIN, TRLISANIMAL, TRLISSOCIAL
select TRLTYPE, TRLFEATTYPE, TRLTRACK, TRLCLASS from gis.TRAILS_LN group by TRLTYPE, TRLFEATTYPE, TRLTRACK, TRLCLASS

-- check for ISOUTPARK
-- Simple check; ignores both in/out: 26 seconds
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
-- Check for both in/out: 75 seconds
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN
  CASE WHEN t1.Shape.STWithin(t2.Shape) = 1 THEN 'No' ELSE 'Both' END
  ELSE 'Yes' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN CASE WHEN t1.Shape.STWithin(t2.Shape) = 1 THEN 'No' ELSE 'Both' END ELSE 'Yes' END <> t1.ISOUTPARK
-- Alternate check for both in/out: 51 seconds
select t1.objectid, t1.ISOUTPARK, CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN 'No' ELSE
  CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END
  END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.ISOUTPARK is null or CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN  'No' ELSE CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Both' ELSE 'Yes' END END <> t1.ISOUTPARK

 -- Out:  No, No, No, No
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STWithin(t2.Shape) = 1 THEN 'Within' ELSE 'Not Within' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=864 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STTouches(t2.Shape) = 1 THEN 'Touches' ELSE 'No Touches' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=864 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Intersects' ELSE 'No Intersects' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=864 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN 'Contains' ELSE 'No Contains' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=864 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK

--Border:  No, No, Yes, No
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STWithin(t2.Shape) = 1 THEN 'Within' ELSE 'Not Within' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=851 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STTouches(t2.Shape) = 1 THEN 'Touches' ELSE 'No Touches' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=851 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Intersects' ELSE 'No Intersects' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=851 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN 'Contains' ELSE 'No Contains' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=851 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK

--In:  Yes, No, Yes, Yes
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STWithin(t2.Shape) = 1 THEN 'Within' ELSE 'Not Within' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=6712 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STTouches(t2.Shape) = 1 THEN 'Touches' ELSE 'No Touches' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=6712 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'Intersects' ELSE 'No Intersects' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=6712 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK
select t1.objectid, t1.ISOUTPARK, CASE WHEN t2.Shape.STContains(t1.Shape) = 1 THEN 'Contains' ELSE 'No Contains' END from gis.TRAILS_LN as t1 join gis.AKR_UNIT as t2
  on t1.UNITCODE = t2.Unit_Code where t1.objectid=6712 -- t1.ISOUTPARK is null or CASE WHEN t1.Shape.STIntersects(t2.Shape) = 1 THEN 'No' ELSE 'Yes' END <> t1.ISOUTPARK




-- TRLUSE Calculator
select TRLUSE,
  dbo.TrailUse(TRLUSE_FOOT,TRLUSE_BICYCLE,TRLUSE_HORSE,TRLUSE_ATV,TRLUSE_4WD,TRLUSE_MOTORCYCLE,TRLUSE_SNOWMOBILE,TRLUSE_SNOWSHOE,TRLUSE_NORDIC,
               TRLUSE_DOGSLED,TRLUSE_MOTORBOAT,TRLUSE_CANOE,TRLUSE_OHVSUB,TRLUSE_SKITOUR,TRLUSE_DOWNHILL,TRLUSE_CANYONEER,TRLUSE_CLIMB,DEFAULT,DEFAULT,DEFAULT)
  from gis.TRAILS_LN_evw
  where TRLUSE <> dbo.TrailUse(TRLUSE_FOOT,TRLUSE_BICYCLE,TRLUSE_HORSE,TRLUSE_ATV,TRLUSE_4WD,TRLUSE_MOTORCYCLE,TRLUSE_SNOWMOBILE,TRLUSE_SNOWSHOE,TRLUSE_NORDIC,
                               TRLUSE_DOGSLED,TRLUSE_MOTORBOAT,TRLUSE_CANOE,TRLUSE_OHVSUB,TRLUSE_SKITOUR,TRLUSE_DOWNHILL,TRLUSE_CANYONEER,TRLUSE_CLIMB,DEFAULT,DEFAULT,DEFAULT)

select TRLUSE,
  dbo.TrailUseAKR(TRLUSE_FOOT,TRLUSE_BICYCLE,TRLUSE_HORSE,TRLUSE_ATV,TRLUSE_4WD,TRLUSE_MOTORCYCLE,TRLUSE_SNOWMOBILE,TRLUSE_SNOWSHOE,TRLUSE_NORDIC,
                  TRLUSE_DOGSLED,TRLUSE_MOTORBOAT,TRLUSE_CANOE,TRLUSE_OHVSUB,TRLUSE_SKITOUR,TRLUSE_DOWNHILL,TRLUSE_CANYONEER,TRLUSE_CLIMB,DEFAULT,DEFAULT,DEFAULT)
  from gis.TRAILS_LN_evw
  where TRLUSE <> dbo.TrailUseAKR(TRLUSE_FOOT,TRLUSE_BICYCLE,TRLUSE_HORSE,TRLUSE_ATV,TRLUSE_4WD,TRLUSE_MOTORCYCLE,TRLUSE_SNOWMOBILE,TRLUSE_SNOWSHOE,TRLUSE_NORDIC,
                                  TRLUSE_DOGSLED,TRLUSE_MOTORBOAT,TRLUSE_CANOE,TRLUSE_OHVSUB,TRLUSE_SKITOUR,TRLUSE_DOWNHILL,TRLUSE_CANYONEER,TRLUSE_CLIMB,DEFAULT,DEFAULT,DEFAULT)


