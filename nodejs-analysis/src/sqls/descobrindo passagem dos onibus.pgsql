WITH veiculos_with_azimuth AS (
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
LIMIT 100
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
geom bus_stop_location,
geom,
id shape_sequence,
shp shape_id,
line shape_line,
azimuth bus_stop_azimuth,
st_distance distance_from_bus_stop_to_shape,
st_closestpoint(va.trajectory_line, pa.geom) closest_point_vehicle_bus_stop,
distance_bus_to_stop,
MIN(distance_bus_to_stop) OVER w AS min_distance_bus_to_stop_others
FROM veiculos_with_azimuth va
-- O onibus e o ponto de onibus precisam ser da mesma linha
JOIN pontos_linha_azimuth pa ON va.cod_linha = pa.cod,
LATERAL (
	SELECT 
	-- Calcula a distância entre o ônibus e o ponto de ônibus
	st_distance(st_closestpoint(va.trajectory_line, pa.geom)::geography, pa.geom::geography) distance_bus_to_stop,
	-- Calcula a diferença entre o azimute da trajetória e o azimute do ponto de onibus
	(va.trajectory_azimuth - pa.azimuth + pi() + pi()*2)::NUMERIC % (pi()*2)::NUMERIC - pi() angle_dif
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
--ORDER BY cod_linha, veic, num, dthr
)
SELECT 
--degrees(trajectory_azimuth) trajectory_azimuth_degrees,
--degrees(bus_stop_azimuth) bus_stop_azimuth_degrees,
*
FROM va_pa
WHERE distance_bus_to_stop < min_distance_bus_to_stop_others
ORDER BY cod_linha, veic, dthr
;