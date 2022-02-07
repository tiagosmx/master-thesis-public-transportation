--create table matches_with_theorical_2019_05_11 as(
/*
É preciso ter a tabela matches_2019_05_11 já criada
*/
with real_and_theorical as (
	select 
	*,
	coalesce(
		date_part('epoch', bus_arrival_time - 
		lag(bus_arrival_time) over (partition by "type", bus_line_id, vehicle_id order by bus_arrival_time asc)
		)/60,0
	) dif_minutes
	from (
	
		select distinct
		bus_line_id ,
		vehicle_id ,
		bus_arrival_time,
		bus_stop_id,
		'real' "type"
		from matches_2019_05_11 c 
	
		union all
	
		select bus_line_id,
		vehicle_id ,
		file_date + "time" "bus_arrival_time",
		bus_stop_id ,
		'theorical' "type"
		from tabela_veiculo_2019_05_11
		where bus_line_id = '216'
	) aa
)
SELECT
t.*,
--r_early.*,
--r_delayed.*,
who,
chosen.*
FROM real_and_theorical t
LEFT JOIN LATERAL (
	SELECT 
	rl.bus_arrival_time,
	rl.dif_minutes,
	date_part('epoch', rl.bus_arrival_time - t.bus_arrival_time) arrival_time_delay
	FROM real_and_theorical rl 
	WHERE "type" = 'real' 
	AND rl.bus_line_id = t.bus_line_id 
	AND rl.vehicle_id = t.vehicle_id 
	AND rl.bus_stop_id = t.bus_stop_id
	AND rl.bus_arrival_time <= t.bus_arrival_time
	ORDER BY rl.bus_arrival_time DESC 
	LIMIT 1
) r_early ON true
LEFT JOIN LATERAL (
	SELECT
	rl.bus_arrival_time,
	rl.dif_minutes,
	date_part('epoch', rl.bus_arrival_time - t.bus_arrival_time) arrival_time_delay
	FROM real_and_theorical rl 
	WHERE "type" = 'real' 
	AND rl.bus_line_id = t.bus_line_id 
	AND rl.vehicle_id = t.vehicle_id 
	AND rl.bus_stop_id = t.bus_stop_id
	AND rl.bus_arrival_time > t.bus_arrival_time
	ORDER BY rl.bus_arrival_time ASC 
	LIMIT 1
) r_delayed ON TRUE,
LATERAL (
	SELECT 
	CASE 
	WHEN r_early.arrival_time_delay IS NULL AND r_delayed.arrival_time_delay IS NOT NULL THEN 'delayed'
	WHEN r_early.arrival_time_delay IS NOT NULL AND r_delayed.arrival_time_delay IS NULL THEN 'early'
	WHEN r_early.arrival_time_delay IS NULL AND r_delayed.arrival_time_delay IS NULL THEN NULL
	WHEN ABS(r_early.arrival_time_delay) >= ABS(r_delayed.arrival_time_delay) THEN 'delayed'
	WHEN ABS(r_early.arrival_time_delay) < ABS(r_delayed.arrival_time_delay) THEN 'early'
	ELSE NULL
	END who
) who,
LATERAL (
	SELECT 
	CASE WHEN who = 'early' THEN r_early.bus_arrival_time WHEN who = 'delayed' THEN r_delayed.bus_arrival_time ELSE NULL END AS bus_arrival_time,
	CASE WHEN who = 'early' THEN r_early.arrival_time_delay WHEN who = 'delayed' THEN r_delayed.arrival_time_delay ELSE NULL END AS arrival_time_delay,
	CASE WHEN who = 'early' THEN r_early.dif_minutes WHEN who = 'delayed' THEN r_delayed.dif_minutes ELSE NULL END AS dif_minutes
) chosen
WHERE  t."type" = 'theorical'
;