SELECT cod,
       array_agg(shp),
       COUNT(DISTINCT shp),
       st_collect(geom)
FROM
    (SELECT cod,
            shp,
            st_makeline(st_setsrid(st_makepoint(lon::float, lat::float),4326)
                        ORDER BY id) geom
     FROM shapes
     GROUP BY cod,
              shp) as s1
GROUP BY cod
