select COUNT (*)
from
(
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_01 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_02 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_03 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_04 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_05 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_06 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_07 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_08 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_09 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_10 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_11 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_12 pl 
union all
select bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id
from pontos_linha_2019_05_13 pl 

) u
where bus_line_id = '216'
group by (bus_stop_name , bus_stop_id , lat, lon, seq, bus_stop_group , way, bus_stop_type, itinerary_id , bus_line_id)
having count(*) <> 13
