select distinct 
(timestamp::DATE) sample_date, 
file_date
from veiculos_2019_05_06_bus_line_216 vbl 

with veiculos as (
	select distinct bus_line_id, vehicle_id
	from veiculos_2019_05_06_bus_line_216 vbl 
	order by bus_line_id, vehicle_id 
),
tabela_veiculo as (
	select distinct bus_line_id, vehicle_id 
	from tabela_veiculo_2019_05_05 tv 
	where bus_line_id = '216'
	order by bus_line_id , vehicle_id 
),
missing as (
	select *
	from veiculos v
	except
	select *
	from tabela_veiculo
),
present as (
	select *
	from veiculos v
	intersect
	select *
	from tabela_veiculo
),
report as (
	select 'present', count(*)
	from present
	union all
	select 'missing', count(*)
	from missing
	union all
	select 'total_veiculos', count(*)
	from veiculos
	union all
	select 'total_tabela_veiculo', count(*)
	from tabela_veiculo
)
select *
from report
;