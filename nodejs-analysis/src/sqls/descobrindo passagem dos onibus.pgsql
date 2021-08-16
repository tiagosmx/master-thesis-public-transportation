WITH veiculos_with_azimuth AS (
SELECT
*,
LAG(geom) OVER w AS lag,
st_makeline(LAG(geom) OVER w, geom) AS line,
st_azimuth( LAG(geom) OVER w, geom) AS azimuth
FROM veiculos
WINDOW w AS (PARTITION BY cod_linha, veic ORDER BY dthr ASC)
ORDER BY (cod_linha, veic, dthr)
LIMIT 100
),
va_pa AS (
SELECT *,
st_closestpoint(va.line, pa.geom),
st_distance(va.line, pa.geom) distance_bus_to_stop
FROM veiculos_with_azimuth va
JOIN pontos_linha_azimuth pa ON TRUE
-- O onibus e o ponto de onibus precisam ser da mesma linha
AND va.cod_linha = pa.cod
-- O onibus precisa estar direcionado aproximadamente na mesma direção (entre -45 e +45 graus de diferença) em que o ponto de ônibus está (comparação de azimutes)
AND (va.azimuth - pa.azimuth + pi() + pi()*2)::NUMERIC % (pi()*2 - pi())::NUMERIC BETWEEN -pi()/4 AND pi()/4
-- A distância do ônibus até o ponto de ônibus precisa ser menor que 10m
AND st_distance(va.line, pa.geom) <= 5
)
SELECT *,
COUNT(*) OVER w window_count,
COUNT(*) OVER w_preceding window_preceding_count,
COUNT(*) OVER w_following window_following_count,
ARRAY_AGG(distance_bus_to_stop) OVER w,
ARRAY_AGG(distance_bus_to_stop) OVER w_preceding,
ARRAY_AGG(distance_bus_to_stop) OVER w_following,
ROW_NUMBER() OVER w,
MIN(distance_bus_to_stop) OVER w
--ROW_NUMBER() OVER (PARTITION BY cod_linha, veic, num ORDER BY distance_bus_to_point ASC RANGE BETWEEN '1 minutes'::INTERVAL PRECEDING AND '1 minutes'::INTERVAL FOLLOWING)
FROM va_pa
WINDOW    w AS (PARTITION BY cod_linha, veic, num ORDER BY dthr ASC RANGE BETWEEN '1 minutes' PRECEDING AND '1 minutes'  FOLLOWING),
w_preceding AS (PARTITION BY cod_linha, veic, num ORDER BY dthr ASC RANGE BETWEEN '1 minutes' PRECEDING AND '0'  PRECEDING),
w_following AS (PARTITION BY cod_linha, veic, num ORDER BY dthr ASC RANGE BETWEEN '0' FOLLOWING AND '1 minutes'  FOLLOWING)
ORDER BY cod_linha, veic, num, dthr
;