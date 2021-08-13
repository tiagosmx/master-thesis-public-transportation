CREATE TABLE pontos_linha_azimuth AS (
SELECT *
FROM
(
SELECT 
pl.*, 
sa.id,
sa.shp,
sa.line,
sa.azimuth,
st_distance(geom, line),
ROW_NUMBER() OVER (PARTITION BY index ORDER BY st_distance(geom, line) ASC)
FROM pontos_linha pl
JOIN shapes_and_sentidos ss ON ss.cod = pl.cod AND ss.sentido = pl.sentido
JOIN shapes_with_azimuth sa ON sa.cod = ss.cod AND sa.shp = ss.shp
WHERE pl.cod = '216'
) as q1
WHERE row_number = 1
ORDER BY cod ASC, sentido ASC, seq ASC
)
