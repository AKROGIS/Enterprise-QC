-- Trail Existance/Status Issues

-- Routes
select ISEXTANT, TRLSTATUS, count(*) from gis.TRAILS_LN_evw where TRLFEATTYPE = 'Route Path' group by ISEXTANT, TRLSTATUS order by ISEXTANT, TRLSTATUS
-- Regular Trails
select ISEXTANT, TRLSTATUS, count(*) from gis.TRAILS_LN_evw where TRLFEATTYPE <> 'Route Path'  group by ISEXTANT, TRLSTATUS order by ISEXTANT, TRLSTATUS
