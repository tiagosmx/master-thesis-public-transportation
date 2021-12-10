select 
time_diff ,
time_diff_seconds ,
timestamp,
bus_stop_id ,
schedule_id vehicle_id,
bus_line_id,
file_date,
true is_theoretical 
from bus_stops_with_schedules_2021_03_25_bus_line_216 bswsbl 
union all
select
time_diff ,
time_diff_seconds ,
bus_arrival_time "timestamp",
bus_stop_id ,
vehicle_id,
bus_line_id,
file_date,
false is_theoretical
from duration_between_bus_arrivals_2021_03_25_bus_line_216 dbbabl 
