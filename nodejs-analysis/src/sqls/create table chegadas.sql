CREATE TABLE chegadas_2021_03_25 AS

WITH 
chosen_bus_lines AS (
	SELECT *
	FROM (
		VALUES ('216')
	) bus_lines (bus_line)
),
veiculos AS (
	SELECT
	veiculo AS veic,
	linha AS cod_linha,
	dthr,
	geom
	FROM vermelho_urbs3
	--LIMIT 100
),
pontos_linha AS (
    SELECT *
    FROM pontos_linha_2021_03_25
),
shape_linha AS (
    SELECT *
    FROM shape_linha_2021_03_25
),
shapes_as_polylines AS (
    SELECT 
    cod,
    shp,
    st_makeline(shape_point_geom ORDER BY id) shape_polyline_geom
    FROM shape_linha
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
        FROM pontos_linha pl
        JOIN shapes_as_polylines sap ON pl.cod = sap.cod,
		LATERAL (SELECT st_distance(pl.bus_stop_point_geom, sap.shape_polyline_geom) AS st_distance) x1
        WHERE pl.cod IN (SELECT bus_line FROM chosen_bus_lines)
        ORDER BY cod, sentido, seq
    ) q1
    WHERE rank = 1
    GROUP BY (cod, shp, sentido)
) q2
WHERE rank <= top_ranks
),
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
	FROM shape_linha
) AS q1
WHERE shape_line_azimuth IS NOT NULL
),
pontos_linha_and_azimuths AS (
SELECT *
FROM (
    SELECT 
    pl.*, 
    sa.id,
    sa.shp,
    shape_line_geom,
    shape_line_azimuth,
    st_distance(bus_stop_point_geom, shape_line_geom),
    ROW_NUMBER() OVER (PARTITION BY index ORDER BY st_distance(bus_stop_point_geom, shape_line_geom) ASC)
    FROM pontos_linha pl
    JOIN shapes_and_sentidos ss ON ss.cod = pl.cod AND ss.sentido = pl.sentido
    JOIN shapes_and_azimuths sa ON sa.cod = ss.cod AND sa.shp = ss.shp
    WHERE pl.cod IN (SELECT bus_line FROM chosen_bus_lines)
) as q1
WHERE row_number = 1
ORDER BY cod ASC, sentido ASC, seq ASC
),
-- **************** VEICULOS WITH AZIMUTHS ****************
veiculos_with_azimuth AS (
SELECT
cod_linha, 
veic, 
LAG(dthr) OVER w AS prev_dthr,
dthr,
LAG(dthr) OVER w - dthr time_dif,
st_makeline(LAG(geom) OVER w, geom) AS trajectory_line,
st_azimuth(LAG(geom) OVER w, geom) AS trajectory_azimuth
FROM veiculos
WINDOW w AS (PARTITION BY cod_linha, veic ORDER BY dthr ASC)
ORDER BY (cod_linha, veic, dthr)
),
va_pa AS (
SELECT
va.*,
index bus_stop_index,
nome bus_stop_name,
num bus_stop_id,
seq,
grupo,
sentido,
tipo,
itinerary_id,
cod,
bus_stop_point_geom,
id shape_sequence,
shp shape_id,
shape_line_geom,
shape_line_azimuth bus_stop_azimuth,
st_distance distance_from_bus_stop_to_shape,
st_closestpoint(va.trajectory_line, pa.bus_stop_point_geom) closest_point_vehicle_bus_stop,
distance_bus_to_stop,
MIN(distance_bus_to_stop) OVER w AS min_distance_bus_to_stop_others
FROM veiculos_with_azimuth va
-- O onibus e o ponto de onibus precisam ser da mesma linha
JOIN pontos_linha_and_azimuths pa ON va.cod_linha = pa.cod,
LATERAL (
	SELECT 
	-- Calcula a distância entre o ônibus e o ponto de ônibus
	st_distance(st_closestpoint(va.trajectory_line, pa.bus_stop_point_geom)::geography, pa.bus_stop_point_geom::geography) distance_bus_to_stop,
	-- Calcula a diferença entre o azimute da trajetória e o azimute do ponto de onibus
	(va.trajectory_azimuth - pa.shape_line_azimuth + pi() + pi()*2)::NUMERIC % (pi()*2)::NUMERIC - pi() angle_dif
) l1
WHERE TRUE
	-- A distância do ônibus até o ponto de ônibus precisa ser menor que 20m
	AND distance_bus_to_stop <= 15
	-- A diferença em graus entre os azimutes precisa estar entre -45 e +45 
	AND angle_dif BETWEEN -pi()/4 AND pi()/4
WINDOW    
w AS (
	PARTITION BY cod_linha, veic, num --bus stop id 
	ORDER BY dthr ASC 
	RANGE BETWEEN 
	'5 minutes' PRECEDING AND 
	'5 minutes' FOLLOWING 
	EXCLUDE CURRENT ROW
)
),
chegadas AS (
SELECT 
--degrees(trajectory_azimuth) trajectory_azimuth_degrees,
--degrees(bus_stop_azimuth) bus_stop_azimuth_degrees,
--ST_Line_Locate_Point(trajectory_line, bus_stop_point_geom) * time_dif,
prev_dthr horario_de_chegada,
*
FROM va_pa
WHERE distance_bus_to_stop < min_distance_bus_to_stop_others
ORDER BY cod_linha, veic, dthr
)
(
SELECT *
FROM chegadas
)

;