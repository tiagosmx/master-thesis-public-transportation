SELECT *
FROM
(
SELECT *,
LAG(geom) OVER (PARTITION BY (cod, shp) ORDER BY id),
st_makeline(
	LAG(geom) OVER (PARTITION BY (cod, shp) ORDER BY id),
	geom
),
st_azimuth(
	LAG(geom) OVER (PARTITION BY (cod, shp) ORDER BY id),
	geom
)
FROM shapes
) as q1
WHERE st_azimuth IS NOT NULL
;
