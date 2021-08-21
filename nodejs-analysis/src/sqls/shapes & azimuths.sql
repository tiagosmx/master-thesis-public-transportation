
WITH 
-- descobrindo o azimute dos shapes
shapes_and_azimuths AS (
SELECT *
FROM
(
	SELECT *,
	LAG(shape_point_geom) OVER (PARTITION BY (cod, shp) ORDER BY id),
	st_makeline(
		LAG(shape_point_geom) OVER (PARTITION BY (cod, shp) ORDER BY id),
		shape_point_geom
	) shape_line_geom,
	st_azimuth(
		LAG(shape_point_geom) OVER (PARTITION BY (cod, shp) ORDER BY id),
		shape_point_geom
	) shape_line_azimuth
	FROM shape_linha_2021_03_25
) AS q1
WHERE shape_line_azimuth IS NOT NULL
)


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