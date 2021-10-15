WITH 
selected_bus_lines AS (
    SELECT *
    FROM (
	VALUES 
	    ('216'::TEXT)
    ) AS b(bus_line_id)
),
selected_dates AS (
    SELECT *
    FROM (
	VALUES 
	    ('2021-03-25'::DATE)
    ) AS d(file_date)
),
distinct_bus_stops_with_schedules_tabela_linha AS (
    SELECT file_date, bus_line_id, bus_stop_id, count(*) as count_horarios_teoricos
    FROM tabela_linha_2021_03_25 tl
    WHERE TRUE
    AND bus_line_id IN (SELECT bus_line_id FROM selected_bus_lines)
    AND file_date IN (SELECT file_date FROM selected_dates)
    and case 
    when date_part('dow',file_date) = 6 then day_category = '2' --sabado
    when date_part('dow',file_date) = 0 then day_category = '3' --domingo
    else day_category = '1' --dias úteis
    end
    group by (file_date, bus_line_id, bus_stop_id)
),
distinct_bus_stops_pontos_linha AS (
    SELECT file_date, bus_stop_id, bus_line_id, count(*) as count_pontos_de_onibus
    FROM pontos_linha_2021_03_25
    WHERE TRUE
    AND bus_line_id IN (SELECT bus_line_id FROM selected_bus_lines)
    AND file_date IN (SELECT file_date FROM selected_dates)
    group by (file_date, bus_line_id, bus_stop_id)
),
distinct_bus_stops_with_schedules_cleaned as (
	SELECT ht.file_date, ht.bus_line_id, ht.bus_stop_id
	FROM distinct_bus_stops_with_schedules_tabela_linha ht
	inner join distinct_bus_stops_pontos_linha po on 
	po.file_date = ht.file_date 
	and po.bus_line_id = ht.bus_line_id 
	and po.bus_stop_id = ht.bus_stop_id
),
bus_stops_with_schedules_cleaned as (
	select tl.*
	from tabela_linha_2021_03_25 tl
	inner join distinct_bus_stops_with_schedules_cleaned c on true 
	and c.file_date = tl.file_date
	and c.bus_line_id = tl.bus_line_id
	and c.bus_stop_id = tl.bus_stop_id
	where 
	case 
    when date_part('dow',tl.file_date) = 6 then tl.day_category = '2' 
    when date_part('dow',tl.file_date) = 0 then tl.day_category = '3' 
    else tl.day_category = '1'
    end
),
bus_stops_with_schedules as (
    SELECT *
    FROM tabela_linha_2021_03_25 tl
    WHERE TRUE
    AND bus_line_id IN (SELECT bus_line_id FROM selected_bus_lines)
    AND file_date IN (SELECT file_date FROM selected_dates)
    and case 
    when date_part('dow',tl.file_date) = 6 then tl.day_category = '2' 
    when date_part('dow',tl.file_date) = 0 then tl.day_category = '3' 
    else tl.day_category = '1'
    end
)
select *
from bus_stops_with_schedules