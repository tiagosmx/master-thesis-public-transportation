select count(*)
from
(
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_01
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_02
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_03
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_04
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_05
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_06
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_07
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_08
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_09
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_10
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_11
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_12
union all
select id, shp, lat, lon, bus_line_id
from shape_linha_2019_05_13
) c
where bus_line_id = '216'
group by (id, shp, lat, lon, bus_line_id)
having count(*) <> 13
;