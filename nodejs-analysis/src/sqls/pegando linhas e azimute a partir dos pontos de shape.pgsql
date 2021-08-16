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



-- EXEMPLO PARA ESTUDAR E AJUDAR NA RESOLUÇÃO
WITH aa (placa, distancia, ts) AS (
VALUES
	(12, 1, '2020-01-01 00:01'::timestamptz),
	(12, 2, '2020-01-01 00:02'),
	(12, 6, '2020-01-01 00:03'),
	(12, 4, '2020-01-01 00:04')
)
SELECT *,
count(*) OVER w
FROM aa
WINDOW w AS (
	PARTITION BY placa 
	ORDER BY ts ASC 
	RANGE BETWEEN 
	'1 second' PRECEDING AND 
	'1 second' FOLLOWING 
	EXCLUDE CURRENT ROW
)

-- https://modern-sql.com/caniuse/over_exclude