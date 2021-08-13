SELECT *
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
ROW_NUMBER() OVER (PARTITION BY "index" ORDER BY st_distance ASC) rank,
*
FROM
(
SELECT st_distance(pl.geom, sbs.geom), pl.*, sbs.shp
FROM pontos_linha pl
JOIN shapes_by_shapes sbs ON pl.cod = sbs.cod
WHERE pl.cod = '216'
ORDER BY cod, sentido, seq
) q1
) q2
WHERE rank = 1
GROUP BY (cod, shp, sentido)
) q3
WHERE rank <= top_ranks
;

-- CRIANDO TABELA PARA ARMAZENAR

CREATE TABLE shapes_and_sentidos AS
SELECT cod, shp, sentido
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
ROW_NUMBER() OVER (PARTITION BY "index" ORDER BY st_distance ASC) rank,
*
FROM
(
SELECT st_distance(pl.geom, sbs.geom), pl.*, sbs.shp
FROM pontos_linha pl
JOIN shapes_by_shapes sbs ON pl.cod = sbs.cod
--WHERE pl.cod = '216'
ORDER BY cod, sentido, seq
) q1
) q2
WHERE rank = 1
GROUP BY (cod, shp, sentido)
) q3
WHERE rank <= top_ranks
;

