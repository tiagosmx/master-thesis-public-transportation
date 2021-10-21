WITH 
chosen_bus_lines AS (
    SELECT
        *
    FROM
        (
            VALUES
                ('216')
        ) bus_lines (bus_line_id)
),
chosen_dates AS (
    SELECT *
    FROM (
	VALUES 
	    ('2021-03-25'::DATE)
    ) AS d(file_date)
),
tabela_linha as (
select 
time, 
bus_stop_name, 
day_category,
bus_stop_id, 
schedule_id, 
bus_line_id, 
file_date
from tabela_linha_2021_03_25
),
pontos_linha AS (
    SELECT
        -- (index) índice do ponto 
        file_index,
        -- (nome) nome do ponto
        bus_stop_name,
        -- (num) código do ponto
        bus_stop_id,
        -- (seq) índice do ponto no percurso
        seq,
        -- (grupo) grupo a qual este ponto de ônibus faz parte, onde pessoas podem pegar outros ônibus com uma mesma passagem
        bus_stop_group,
        -- (sentido) nome do último ponto de ônibus no final do percurso
        way,
        -- (tipo) tipo do ponto de ônibus
        bus_stop_type,
        -- (itinerary_id) id do itinerário
        itinerary_id,
        -- (cod) código da linha
        bus_line_id,
        -- (geom) coordenada geográfica do ponto de ônibus
        bus_stop_point_geom,
        -- a data do arquivo que originou o dado
        file_date
    FROM
        pontos_linha_2021_03_25
),
bus_stops_with_schedules as (
    SELECT *
    FROM tabela_linha tl
    WHERE TRUE
    AND bus_line_id IN (SELECT bus_line_id FROM chosen_bus_lines)
    AND file_date IN (SELECT file_date FROM chosen_dates)
    and case 
    when date_part('dow',tl.file_date) = 6 then tl.day_category = '2' 
    when date_part('dow',tl.file_date) = 0 then tl.day_category = '3' 
    else tl.day_category = '1'
    end
),
bus_stops_ids_with_schedules as (
select distinct file_date, bus_line_id, bus_stop_id
from bus_stops_with_schedules
),
pontos_linha_cleaned as (
select pl.*
from pontos_linha pl
join bus_stops_ids_with_schedules bsids on true
and pl.file_date = bsids.file_date 
and pl.bus_line_id = bsids.bus_line_id 
and pl.bus_stop_id = bsids.bus_stop_id
)
select *
from pontos_linha_cleaned