WITH
shapes_as_polylines AS (
    SELECT 
    cod,
    shp,
    st_makeline(shape_point_geom ORDER BY id) shape_polyline_geom
    FROM shape_linha_2021_03_25
    GROUP BY cod, shp
)
SELECT 
cod,
array_agg(shp),
COUNT(DISTINCT shp),
st_collect(shape_polyline_geom)
FROM shapes_as_polylines
GROUP BY cod
