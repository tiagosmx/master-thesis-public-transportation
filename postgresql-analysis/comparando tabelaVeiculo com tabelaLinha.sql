
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
	DROP TABLE IF EXISTS temp_tl;
	-- Creating list of date values and putting into dates_text
	SELECT array_agg(d::DATE) INTO dates
	FROM generate_series('2019-05-01','2019-05-14', '1 day'::INTERVAL) t(d);
  -- Looping through each date
	FOR i IN 1 .. array_upper(dates, 1) LOOP
	  date_text := to_char(dates[i],'YYYY_MM_DD');
		table_name := 'tabela_linha_'||date_text;
		queries[i] := format('
			SELECT 
            COUNT(DISTINCT schedule_id), 
			%L::DATE file_date
			FROM %I 
            WHERE bus_line_id = ''216'' AND
            CASE 
				WHEN file_date = ''2019-01-05'' THEN day_category = ''4''
                WHEN date_part(''dow'',file_date) = 6 THEN day_category = ''2''
                WHEN date_part(''dow'',file_date) = 0 THEN day_category = ''3''
                ELSE day_category = ''1''
            END
            ', dates[i], table_name);
            
	END LOOP;
  final_query := 'CREATE TEMP TABLE temp_tl AS (' || array_to_string(queries, ' UNION ALL ') || ');';
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
	DROP TABLE IF EXISTS temp_tv;
	-- Creating list of date values and putting into dates_text
	SELECT array_agg(d::DATE) INTO dates
	FROM generate_series('2019-05-01','2019-05-14', '1 day'::INTERVAL) t(d);
  -- Looping through each date
	FOR i IN 1 .. array_upper(dates, 1) LOOP
	  date_text := to_char(dates[i],'YYYY_MM_DD');
		table_name := 'tabela_veiculo_'||date_text;
		queries[i] := format('
			SELECT 
            COUNT(DISTINCT vehicle_id),
						%L::DATE file_date
			FROM %I WHERE bus_line_id = ''216''', dates[i], table_name);
	END LOOP;
  final_query := 'CREATE TEMP TABLE temp_tv AS (' || array_to_string(queries, ' UNION ALL ') || ');';
 EXECUTE final_query;
END;
$$;

SELECT tl.file_date, tl.count tabela_linha_count, tv.count tabela_veiculo_count
FROM temp_tl tl
JOIN temp_tv tv ON tl.file_date = tv.file_date
;
