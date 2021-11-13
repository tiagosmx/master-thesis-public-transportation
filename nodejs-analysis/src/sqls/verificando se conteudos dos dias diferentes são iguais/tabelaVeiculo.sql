select count(*)
from
(
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_01
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_02
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_03
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_04
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_05
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_06
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_07
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_08
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_09
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_10
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_11
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_12
union all
select bus_line_id, vehicle_id, time, schedule_id, bus_stop_id
from tabela_veiculo_2019_05_13
) c
where bus_line_id = '216'
group by (bus_line_id, vehicle_id, time, schedule_id, bus_stop_id)
having count(*) <> 13
;