-- CREATE TABLE nome_da_sua_tabela AS
with chosen_bus_lines as (
select
	*
from
	(
values
                ('216')
        ) bus_lines (bus_line)
),
veiculos as (
select
	veiculo as veic,
	linha as cod_linha,
	dthr,
	geom
from
	vermelho_urbs_veiculos vuv
	--LIMIT 100
where
	true
	--dthr between '2021-03-05'::timestamptz and '2021-03-06'::timestamptz
	and linha = '216'
	and dthr between '2019-01-01' and '2020-01-01'
),
pontos_linha as (
select
	*
from
	pontos_linha_2021_03_25
),
shape_linha as (
select
	*
from
	shape_linha_2021_03_25
),
shapes_as_polylines as (
select
	cod,
	shp,
	st_makeline(
            shape_point_geom
order by
	id
        ) shape_polyline_geom
from
	shape_linha
group by
	cod,
	shp
),
shapes_and_sentidos as (
select
	--*
	cod,
	shp,
	sentido
from
	(
	select
		row_number() over (
                    partition by (cod)
	order by
		COUNT(*) desc
                ) rank,
		COUNT(*) over (partition by (cod)) rank_max,
		COUNT(*) over (partition by (cod)) / 2 top_ranks,
		COUNT(*),
		cod,
		shp,
		sentido
	from
		(
		select
			st_distance,
			row_number() over (
                            partition by "index"
		order by
			st_distance asc
                        ) rank,
			pl.*,
			sap.shp
		from
			pontos_linha pl
		join shapes_as_polylines sap on
			pl.cod = sap.cod,
			lateral (
			select
				st_distance(pl.bus_stop_point_geom,
				sap.shape_polyline_geom) as st_distance
                        ) x1
		where
			pl.cod in (
			select
				bus_line
			from
				chosen_bus_lines
                        )
		order by
			cod,
			sentido,
			seq
                ) q1
	where
		rank = 1
	group by
		(
                    cod,
		shp,
		sentido
                )
        ) q2
where
	rank <= top_ranks
),
shapes_and_azimuths as (
select
	*
from
	(
	select
		*,
		lag(shape_point_geom) over (
                    partition by (
                        cod,
		shp
                    )
	order by
		id
                ),
		st_makeline(
                    lag(shape_point_geom) over (
                        partition by (cod,
		shp)
	order by
		id
                    ),
		shape_point_geom
                ) shape_line_geom,
		st_azimuth(
                    lag(shape_point_geom) over (
                        partition by (cod,
		shp)
	order by
		id
                    ),
		shape_point_geom
                ) shape_line_azimuth
	from
		shape_linha
        ) as q1
where
	shape_line_azimuth is not null
),
pontos_linha_and_azimuths as (
select
	*
from
	(
	select
		pl.*,
		sa.id,
		sa.shp,
		shape_line_geom,
		shape_line_azimuth,
		st_distance(bus_stop_point_geom,
		shape_line_geom),
		row_number() over (
                    partition by index
	order by
		st_distance(bus_stop_point_geom,
		shape_line_geom) asc
                )
	from
		pontos_linha pl
	join shapes_and_sentidos ss on
		ss.cod = pl.cod
		and ss.sentido = pl.sentido
	join shapes_and_azimuths sa on
		sa.cod = ss.cod
		and sa.shp = ss.shp
	where
		pl.cod in (
		select
			bus_line
		from
			chosen_bus_lines
                )
        ) as q1
where
	row_number = 1
order by
	cod asc,
	sentido asc,
	seq asc
),
-- **************** VEICULOS WITH AZIMUTHS ****************
veiculos_with_azimuth as (
select
	cod_linha,
	veic,
	lag(dthr) over w as prev_dthr,
	dthr,
	lag(dthr) over w - dthr time_dif,
	st_makeline(lag(geom) over w,
	geom) as trajectory_line,
	st_azimuth(lag(geom) over w,
	geom) as trajectory_azimuth
from
	veiculos window w as (
            partition by cod_linha,
	veic
order by
	dthr asc
        )
order by
	(
            cod_linha,
	veic,
	dthr
        )
	--LIMIT 100
),
va_pa as (
select
	va.*,
	index bus_stop_index,
	nome bus_stop_name,
	num bus_stop_id,
	seq,
	grupo,
	sentido,
	tipo,
	itinerary_id,
	cod,
	bus_stop_point_geom,
	id shape_sequence,
	shp shape_id,
	shape_line_geom,
	shape_line_azimuth bus_stop_azimuth,
	st_distance distance_from_bus_stop_to_shape,
	st_closestpoint(va.trajectory_line,
	pa.bus_stop_point_geom) closest_point_vehicle_bus_stop,
	distance_bus_to_stop,
	MIN(distance_bus_to_stop) over w_preceding as min_distance_bus_to_stop_preceding,
	MIN(distance_bus_to_stop) over w_following as min_distance_bus_to_stop_following
from
	veiculos_with_azimuth va
	-- O onibus e o ponto de onibus precisam ser da mesma linha
join pontos_linha_and_azimuths pa on
	va.cod_linha = pa.cod,
	lateral (
	select
		-- Calcula a distância entre o ônibus e o ponto de ônibus
		st_distance(
                    st_closestpoint(va.trajectory_line,
		pa.bus_stop_point_geom) :: geography,
		pa.bus_stop_point_geom :: geography
                ) distance_bus_to_stop,
		-- Calcula a diferença entre o azimute da trajetória e o azimute do ponto de onibus
                (
                    va.trajectory_azimuth - pa.shape_line_azimuth + pi() + pi() * 2
                ) :: numeric % (pi() * 2) :: numeric - pi() angle_dif
        ) l1
where
	true
	-- A distância do ônibus até o ponto de ônibus precisa ser menor que 20m
	and distance_bus_to_stop <= 40
	-- A diferença em graus entre os azimutes precisa estar entre -45 e +45
	and angle_dif between - pi() / 4
        and pi() / 4 window w_preceding as (
            partition by cod_linha,
	veic,
	num,
	--bus stop id
	seq
order by
	dthr asc range between '20 minutes' preceding
                and current row exclude current row
        ),
	w_following as (
            partition by cod_linha,
	veic,
	num,
	--bus stop id
	seq
order by
	dthr asc range between current row
                and '20 minutes' following exclude current row
        )
),
chegadas as (
select
	--degrees(trajectory_azimuth) trajectory_azimuth_degrees,
	--degrees(bus_stop_azimuth) bus_stop_azimuth_degrees,
	--ST_Line_Locate_Point(trajectory_line, bus_stop_point_geom) * time_dif,
	prev_dthr horario_de_chegada,
	*
from
	va_pa
where
	true
	and distance_bus_to_stop < coalesce(min_distance_bus_to_stop_preceding, '+Infinity')
		and distance_bus_to_stop <= coalesce(min_distance_bus_to_stop_following, '+Infinity')
	order by
		cod_linha,
		veic,
		dthr,
		seq desc
),
prova as (
select
	*,
	lag(seq) over w lag_seq,
	seq as seqq,
	seq - lag(seq) over w seq_dif,
	lag(sentido) over w lag_sentido,
	lead(sentido) over w lead_sentido
from
	chegadas window w as (
            partition by cod_linha,
	veic
order by
	horario_de_chegada asc,
	seq desc
        )
),
prova2 as (
select
	*,
	sentido,
	lag(seq) over w lag_seq2,
	seq as seq2,
	seq - lag(seq) over w seq_dif2
from
	prova where 
	case
		when lag_sentido is not null
		and lead_sentido is not null
		and lag_sentido = lead_sentido
		and sentido <> lag_sentido then 
	false
		else true
	end
	--and seq_dif2 not in (1, -36, -32)
	window w as (
            partition by cod_linha,
	veic
order by
	horario_de_chegada asc,
	seq desc
        )
)
select
	*
from
	prova2
--where seq_dif2 not in (1, -36, -32)
--where seq_dif2 not in (1, -36, -32)

/*

Onibus BA602 totalmente louco, fazendo caminhos estranhos o dia inteiro

2019-03-27 20:34:40.000	216	BA602


-------
Pegou uns seqs aleatorios

2019-03-27 08:16:29.000	216	BA602
2019-03-27 08:18:55.000	216	BA602
2019-03-27 08:18:55.000	216	BA602
2019-03-27 08:20:06.000	216	BA602
2019-03-27 08:20:06.000	216	BA602
2019-03-27 08:22:00.000	216	BA602
2019-03-27 08:23:31.000	216	BA602
2019-03-27 08:26:00.000	216	BA602
2019-03-27 08:27:40.000	216	BA602
2019-03-27 08:28:35.000	216	BA602

Parece que os min_distance_bus_stop_following e preceding ficaram nulls

------------


Deu um pulo sinistro tambem
2019-03-27 07:36:54.000	216	BA602
2019-03-27 07:37:27.000	216	BA602
2019-03-27 07:37:27.000	216	BA602
2019-03-27 08:02:03.000	216	BA602
2019-03-27 08:03:24.000	216	BA602
2019-03-27 08:03:24.000	216	BA602

14	15	1
15	26	11
26	20	-6
20	27	7
27	29	2
29	28	-1

---------

14,15,22,23....
Deu um pulo sinistro

2019-03-27 06:38:04.000	216	BA602
2019-03-27 06:39:09.000	216	BA602
2019-03-27 06:49:02.000	216	BA602
2019-03-27 06:50:30.000	216	BA602


o onibus ficou parado um tempao no terminal
2019-03-30 09:48:40.000	216	BA600
2019-03-30 10:13:14.000	216	BA600
2019-03-30 11:18:25.000	216	BA600
2019-03-30 11:48:25.000	216	BA600

deu uma merda bem grande em por causa do bug de considerar dos arquivos diferentes como se fosse um so dia em operação consecutiva

2019-03-29 23:59:17.000	216	BA600
2019-03-29 23:59:56.000	216	BA600
2019-03-29 23:59:56.000	216	BA600
2019-03-29 23:59:56.000	216	BA600
2019-03-29 23:59:56.000	216	BA600
2019-03-30 09:28:36.000	216	BA600
*/

    /*
Fazer com que dias diferentes não sejam considerados no mesmo match do algoritmo
    */
/*
SELECT *
FROM prova
WHERE TRUE
*/
    --AND seq_dif NOT IN (1, -36, -32)

-- CASOS DE OUTLIERS NA CONSULTA:
/*
seq_dif = null, então simplesmente ignorar ele
*/

/*
    Como lidar com esses casos de seq??
    27	28	1
    28	29	1
    29	7	-22
    7	30	23
    30	31	1

    verificar qual o sentido de cada um...
    verificar se há um sentido "outlier" no meio de outras leituras, 
    onde 
    senitido atual != sentido dos X preceding 
    e sentido atual != sentido dos X following
    Fazer um window preceding e window following pra cada
    anterior, atual, dif

    (se a moda de preceding e a moda de followin forem iguais entre si, e a moda do elemento diferente, exclui-se ele)

    Casos que nao deve fazer nada
    A
    A
    B
    B
    B
    ----
    A
    A
    A
    A
    B
    ----
    A
    A
    A
    B
    B
    ----
    A
    A
    B
    B
    B
    ----
    Caso que deve excluir a linha do meio
    A
    A
    B
    A
    A
    (2)??? Caso que deve excluir a linha do meio
    A
    A
    B
    A
    A
    ----
    A
    A
    B
    A
    B
*/