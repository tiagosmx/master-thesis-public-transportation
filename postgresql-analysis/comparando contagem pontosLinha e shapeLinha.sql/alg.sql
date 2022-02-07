WITH count_pontos_linha AS (
	SELECT bus_line_id, COUNT(DISTINCT way)
	FROM pontos_linha_2019_05_03 pl 
	GROUP BY bus_line_id
),
count_shape_linha AS (
	SELECT bus_line_id, COUNT(DISTINCT shp)
	FROM shape_linha_2019_05_03 sl 
	GROUP BY bus_line_id
),
is_count_equal AS (
	SELECT *, cpl.count = csl.count is_count_equal
	FROM count_pontos_linha cpl
	FULL JOIN count_shape_linha csl ON cpl.bus_line_id = csl.bus_line_id 
)
SELECT 
COUNT(*) total,
COUNT(*) FILTER (WHERE is_count_equal = true) is_true,
COUNT(*) FILTER (WHERE is_count_equal = false) is_false,
COUNT(*) FILTER (WHERE is_count_equal = true)::REAL / COUNT(*)::REAL true_over_total,
COUNT(*) FILTER (WHERE is_count_equal = false)::REAL / COUNT(*)::REAL false_over_total,
COUNT (*) FILTER (WHERE is_count_equal IS NULL) nulls_total
FROM is_count_equal
;