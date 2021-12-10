DO 
LANGUAGE 'plpgsql'
$$
DECLARE
	texto_teste TEXT;
	double_teste DOUBLE PRECISION;
	integer_teste INTEGER;
	record_teste RECORD;
	counter INTEGER;
	dates_text TEXT[];
	i INTEGER;
	table_name TEXT;
	queries TEXT[];
  final_query TEXT;
BEGIN
	-- Dropping table:
	DROP TABLE IF EXISTS temp_veiculos_statistics;
	-- Creating list of date values and putting into dates_text
	SELECT array_agg(to_char(dates, 'YYYY_MM_DD')) INTO dates_text
	FROM generate_series('2019-05-01','2019-05-14', '1 day'::INTERVAL) t(dates);
  -- Looping through each date
	FOR i IN 1 .. array_upper(dates_text, 1) LOOP
		table_name := 'veiculos_'||dates_text[i]||'_bus_line_216';
		queries[i] := format('
SELECT %L table_name, vehicle_id, COUNT(*) 
FROM %I 
WHERE bus_line_id = %L 
GROUP BY CUBE (vehicle_id)', table_name, table_name, '216');
	END LOOP;
  final_query := 'CREATE TEMP TABLE temp_veiculos_statistics AS (' || array_to_string(queries, ' UNION ALL ') || ');';
 EXECUTE final_query;
END;
$$;

SELECT *
FROM temp_veiculos_statistics
WHERE vehicle_id IS NULL
ORDER BY table_name
;
