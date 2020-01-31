select f.PARK, COALESCE(g.cnt, 0) as Count, g.newest as Age, f.Location, f.description
FROM akr_facility2.dbo.FMSSExport as f
left JOIN
(Select FACLOCID, Count(*) as CNT, Year(getdate()) -  YEAR(COALESCE(max(ATCHDATE),getdate())) AS Newest
FROM akr_facility2.gis.AKR_ATTACH_evw
WHERE FACLOCID IS NOT NULL
GROUP BY FACLOCID) as g
ON f.Location = g.FACLOCID
WHERE f.Type = 'OPERATING' AND f.Status = 'OPERATING' AND f.Asset_Code = '4100'
AND (g.cnt < 2 OR g.Newest > 10 or G.cnt is null)
order by f.PARK, g.cnt, g.newest desc
