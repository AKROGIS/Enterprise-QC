-- FMSS Domain Comparison
-------------------------

-- Maintainer
SELECT FAMARESP, count(*) from FMSSExport group by FAMARESP order by FAMARESP
SELECT * FROM DOM_MAINTAINER   -- Trails/Parkinglots
SELECT * FROM DOM_RDMAINTAINER -- Roads  (same as DOM_MAINTAINER plus 'Federal Highway Administration')
SELECT * FROM DOM_FACOCCUMAINT -- Buildings

-- Status
SELECT [Status], count(*) from FMSSExport group by [Status] order by [Status]
--  Nothing for Parking lots
SELECT * FROM DOM_TRLSTATUS  -- Trails  (same as RDSTATUS plus 'Abandoned', 'Not Applicable')
SELECT * FROM DOM_RDSTATUS   -- Roads
SELECT * FROM DOM_BLDGSTATUS -- Buildings (same as DOM_RDSTATUS)

-- Is_Admin
SELECT PRIMUSE, count(*) from FMSSExport group by PRIMUSE order by PRIMUSE
--  Nothing for Parking lots, or Roads
SELECT TRLISADMIN, count(*) from GIS.TRAILS_LN group by TRLISADMIN order by TRLISADMIN
SELECT * FROM DOM_YES_NO  -- Trails
SELECT FACUSE, count(*) from GIS.AKR_BLDG_CENTER_PT group by FACUSE order by FACUSE
SELECT * FROM DOM_FACUSE -- Buildings (same as DOM_RDSTATUS)

-- Seasonal

-- ????
