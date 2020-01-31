    SELECT
      f.PARK, 'Trail' as Type, f.Location, f. description, F.Qty AS FMSS_Qty, round(g.Feet,0) as GIS_Qty, round(F.Qty/g.Feet,2) AS Ratio
    FROM akr_facility2.dbo.FMSSExport AS f
    JOIN (
      SELECT
        FACLOCID,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 3.28084 as Feet
      FROM
        akr_facility2.gis.TRAILS_LN_evw
      WHERE
        FACLOCID IS NOT NULL AND LINETYPE = 'Center line'
      GROUP BY
        FACLOCID
    ) AS g
    ON g.FACLOCID = f.Location
    WHERE (F.Qty/g.Feet < 0.9 OR F.Qty/g.Feet > 1.1) and Park = 'BELA'
UNION ALL
    SELECT
      f.PARK, 'Road' as Type, f.Location, f. description, F.Qty AS FMSS_Qty, round(g.Miles,0) as GIS_Qty, round(F.Qty/g.Miles,2) AS Ratio
    FROM akr_facility2.dbo.FMSSExport AS f
    JOIN (
      SELECT
        FACLOCID,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STLength()) * 0.000621371 as Miles
      FROM
        akr_facility2.gis.ROADS_LN_evw
      WHERE
        FACLOCID IS NOT NULL AND LINETYPE = 'Center line'
      GROUP BY
        FACLOCID
    ) AS g
    ON g.FACLOCID = f.Location
    WHERE (F.Qty/g.Miles < 0.9 OR F.Qty/g.Miles > 1.1)
UNION ALL 
    SELECT
      f.PARK, 'Parking' as Type, f.Location, f. description, F.Qty AS FMSS_Qty, round(g.Qty,0) as GIS_Qty, round(F.Qty/g.Qty,2) AS Ratio
    FROM akr_facility2.dbo.FMSSExport AS f
    JOIN (
      SELECT
        FACLOCID,
        SUM(GEOGRAPHY::STGeomFromText(shape.STAsText(),4269).STArea()) * 3.28084 * 3.28084 as Qty
      FROM
        akr_facility2.gis.PARKLOTS_PY_evw
      WHERE
        FACLOCID IS NOT NULL
      GROUP BY
        FACLOCID
    ) AS g
    ON g.FACLOCID = f.Location
    WHERE (F.Qty/g.Qty < 0.9 OR F.Qty/g.Qty > 1.1)
    AND f.Asset_Code = '1300'

