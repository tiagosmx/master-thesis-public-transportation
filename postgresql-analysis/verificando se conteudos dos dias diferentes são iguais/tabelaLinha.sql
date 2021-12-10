select count(*)
from
(
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_01
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_02
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_03
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_04
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_05
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_06
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_07
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_08
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_09
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_10
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_11
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_12
union all
select time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id
from tabela_linha_2019_05_13
) c
where bus_line_id = '216'
group by (time, day_category , bus_stop_id , schedule_id , wheelchair_accessibility_type, bus_line_id)
having count(*) <> 13
;