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


-- CRIANDO TABELA COM ESSES VALORES:

CREATE TABLE IF NOT EXISTS shapes_with_azimuth AS
SELECT id,
shp,
cod,
st_makeline as line,
st_azimuth as azimuth
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
