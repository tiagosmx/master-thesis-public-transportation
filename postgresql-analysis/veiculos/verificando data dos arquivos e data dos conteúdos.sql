DO 
LANGUAGE 'plpgsql'
$$
DECLARE
  dates DATE[];
	i INTEGER;
	table_name TEXT;
	queries TEXT[];
  final_query TEXT;
  date_text TEXT;
BEGIN
	-- Dropping table:
	DROP TABLE IF EXISTS temp_veiculos_statistics;
	-- Creating list of date values and putting into dates_text
	SELECT array_agg(d::DATE) INTO dates
	FROM generate_series('2019-05-01','2019-05-14', '1 day'::INTERVAL) t(d);
  -- Looping through each date
	FOR i IN 1 .. array_upper(dates, 1) LOOP
	  date_text := to_char(dates[i],'YYYY_MM_DD');
		table_name := 'veiculos_'||date_text||'_bus_line_216';
		queries[i] := format('
SELECT 
%L table_name, 
max(timestamp)::DATE, 
min(timestamp)::DATE,
array_agg(DISTINCT vehicle_id),
%L::DATE file_date
FROM %I', table_name, dates[i], table_name);
	END LOOP;
  final_query := 'CREATE TEMP TABLE temp_veiculos_statistics AS (' || array_to_string(queries, ' UNION ALL ') || ');';
 EXECUTE final_query;
END;
$$;

SELECT *
FROM temp_veiculos_statistics
ORDER BY table_name
;