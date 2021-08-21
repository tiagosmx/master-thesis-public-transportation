WITH 
shapes_as_polylines AS (
    SELECT 
    cod,
    shp,
    st_makeline(shape_point_geom ORDER BY id) shape_polyline_geom
    FROM shape_linha_2021_03_25
    GROUP BY cod, shp
),
shapes_and_sentidos AS (
SELECT 
--*
cod, 
shp, 
sentido
FROM
(
    SELECT 
    ROW_NUMBER() OVER (PARTITION BY (cod) ORDER BY COUNT(*) DESC) rank,
    COUNT(*) OVER (PARTITION BY (cod)) rank_max,
    COUNT(*) OVER (PARTITION BY (cod))/2 top_ranks,
    COUNT(*),
    cod,
    shp, 
    sentido
    FROM
    (
        SELECT
        st_distance, 
		ROW_NUMBER() OVER (PARTITION BY "index" ORDER BY st_distance ASC) rank,
        pl.*, 
        sap.shp
        FROM pontos_linha_2021_03_25 pl
        JOIN shapes_as_polylines sap ON pl.cod = sap.cod,
		LATERAL (SELECT st_distance(pl.bus_stop_point_geom, sap.shape_polyline_geom) AS st_distance) x1
        WHERE pl.cod = '216'
        ORDER BY cod, sentido, seq
    ) q1
    WHERE rank = 1
    GROUP BY (cod, shp, sentido)
) q2
WHERE rank <= top_ranks
)
SELECT *
FROM shapes_and_sentidos
;