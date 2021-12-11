
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
      COUNT(DISTINCT vehicle_id),
			%L::DATE file_date
			FROM %I', table_name, dates[i], table_name);
	END LOOP;
  final_query := 'CREATE TEMP TABLE temp_veiculos_statistics AS (' || array_to_string(queries, ' UNION ALL ') || ');';
 EXECUTE final_query;
END;
$$;

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
	DROP TABLE IF EXISTS temp_tabela_veiculos_statistics;
	-- Creating list of date values and putting into dates_text
	SELECT array_agg(d::DATE) INTO dates
	FROM generate_series('2019-04-29','2019-05-14', '1 day'::INTERVAL) t(d);
  -- Looping through each date
	FOR i IN 1 .. array_upper(dates, 1) LOOP
	  date_text := to_char(dates[i],'YYYY_MM_DD');
		table_name := 'tabela_veiculo_'||date_text;
		queries[i] := format('
			SELECT 
			array_agg(DISTINCT vehicle_id),
      COUNT(DISTINCT vehicle_id),
			%L::DATE file_date
			FROM %I WHERE bus_line_id = ''216''', dates[i], table_name);
	END LOOP;
  final_query := 'CREATE TEMP TABLE temp_tabela_veiculos_statistics AS (' || array_to_string(queries, ' UNION ALL ') || ');';
 EXECUTE final_query;
END;
$$;

SELECT vs.file_date v_file_date, vs.max v_value_date, vs.count v_count_vehicles, vs.array_agg v_array,
tvs.file_date tv_file_date, tvs.count tv_count_vehicles, tvs.array_agg tv_array,
array_intersect(vs.array_agg, tvs.array_agg) intersec,
array_length(array_intersect(vs.array_agg, tvs.array_agg),1) intersec_count
FROM temp_veiculos_statistics vs
JOIN temp_tabela_veiculos_statistics tvs ON vs.max = tvs.file_date
ORDER BY v_value_date
;
