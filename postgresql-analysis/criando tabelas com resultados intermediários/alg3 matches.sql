--------------- SETTING CURITIBA'S TIMEZONE ---------------
SET timezone = 'America/Sao_Paulo';

CREATE TABLE matches_2019_05_13 AS
--------------- PARAMETERS ---------------
-- Operando sobre as tabelas de dia _2019_05_13
-- Operando sobre a tabela veiculo dia _2019_05_14
-- Operando sobre o id 216
--INSERT INTO chegadas_filtradas
--------------- BUS LINE ID ---------------
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
--------------- PURE TABLES ---------------
veiculos AS (
    SELECT
        -- codigo da linha de ônibus
        bus_line_id,
        -- codigo do veiculo
        vehicle_id,
        -- data hora da mensuração
        timestamp,
        -- localização
        bus_location_point_geom geom,
        -- data do arquivo
        file_date
    FROM
        veiculos_2019_05_14_bus_line_216
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
        pontos_linha_2019_05_13
),
shape_linha AS (
    SELECT
        id,
        shp,
        lat,
        lon,
        shape_point_geom,
        bus_line_id,
        file_date
    FROM
        shape_linha_2019_05_13
),
tabela_veiculo AS (
    SELECT 
    bus_line_id, 
    bus_line_name, 
    vehicle_id, 
    "time",
    ("time" + file_date)::TIMESTAMPTZ programmed_timestamp,
    schedule_id, 
    bus_stop_id, 
    file_date
    FROM tabela_veiculo_2019_05_13
    WHERE bus_line_id IN (SELECT bus_line_id FROM chosen_bus_lines)
),
--------------- TABLE JOINS ---------------
--------------- SHAPES WITH AZIMUTHS ALGORITHMS ---------------
shapes_as_polylines AS (
    SELECT
        file_date,
        bus_line_id,
        shp,
        st_makeline (
            shape_point_geom
            ORDER BY
                id
        ) shape_polyline_geom
    FROM
        shape_linha
    GROUP BY
        file_date,
        bus_line_id,
        shp
),
shapes_and_sentidos AS (
    SELECT
    	file_date,
        bus_line_id,
        shp,
        way
    FROM
        (
            SELECT
                ROW_NUMBER() OVER (
                    PARTITION BY (file_date, bus_line_id)
                    ORDER BY
                        COUNT(*) DESC
                ) rank,
                COUNT(*) OVER (PARTITION BY (file_date, bus_line_id)) rank_max,
                COUNT(*) OVER (PARTITION BY (file_date, bus_line_id)) / 2 top_ranks,
                COUNT(*),
                file_date,
                bus_line_id,
                shp,
                way
            FROM
                (
                    SELECT
                        x1.st_distance,
                        ROW_NUMBER() OVER (
                            PARTITION BY pl.file_date, pl.file_index
                            ORDER BY
                                x1.st_distance ASC
                        ) rank,
                        pl.file_date,
                        pl.bus_line_id,
                        pl.way,
                        sap.shp
                    FROM
                        pontos_linha pl
                        JOIN shapes_as_polylines sap ON pl.file_date = sap.file_date and pl.bus_line_id = sap.bus_line_id,
                        LATERAL (
                            SELECT
                                st_distance (pl.bus_stop_point_geom, sap.shape_polyline_geom) AS st_distance
                        ) x1
                    WHERE
                        pl.bus_line_id IN (
                            SELECT
                                bus_line_id
                            FROM
                                chosen_bus_lines
                        )
                    ORDER BY
                        pl.file_date,
                        pl.bus_line_id,
                        pl.way,
                        pl.seq
                ) q1
            WHERE
                rank = 1
            GROUP BY
                (
                	file_date,
                    bus_line_id,
                    shp,
                    way
                )
        ) q2
    WHERE
        rank <= top_ranks
),
--------------- CREATE SHAPES AND AZIMUTHS ---------------
shapes_and_azimuths AS (
    SELECT
        *
    FROM
        (
            SELECT
                *,
                LAG(shape_point_geom) OVER w,
                st_makeline (
                    LAG(shape_point_geom) OVER w,
                    shape_point_geom
                ) shape_line_geom,
                st_azimuth (
                    LAG (shape_point_geom) OVER w,
                    shape_point_geom
                ) shape_line_azimuth
            FROM
                shape_linha
            WINDOW w AS (PARTITION BY (file_date, bus_line_id, shp) ORDER BY id)
        ) AS q1
    WHERE
        shape_line_azimuth IS NOT NULL
),
pontos_linha_and_azimuths AS (
    SELECT
        *
    FROM
        (
            SELECT
                pl.*,
                sa.id,
                sa.shp,
                shape_line_geom,
                shape_line_azimuth,
                st_distance (bus_stop_point_geom, shape_line_geom),
                ROW_NUMBER() OVER (
                    PARTITION BY pl.file_date, pl.file_index
                    ORDER BY
                        st_distance (bus_stop_point_geom, shape_line_geom) ASC
                )
            FROM
                pontos_linha pl
                JOIN shapes_and_sentidos ss ON ss.bus_line_id = pl.bus_line_id
                AND ss.way = pl.way
                JOIN shapes_and_azimuths sa ON sa.bus_line_id = ss.bus_line_id
                AND sa.shp = ss.shp
            WHERE
                pl.bus_line_id IN (
                    SELECT
                        bus_line_id
                    FROM
                        chosen_bus_lines
                )
        ) AS q1
    WHERE
        row_number = 1
    ORDER BY
        bus_line_id ASC,
        way ASC,
        seq ASC
),
-- **************** VEICULOS WITH AZIMUTHS ****************
veiculos_with_azimuth AS (
    select
    	file_date,
        bus_line_id,
        vehicle_id,
        LAG(timestamp) OVER w AS prev_dthr,
        timestamp,
        timestamp - LAG (timestamp) OVER w time_dif,
        st_makeline (LAG (geom) OVER w, geom) AS trajectory_line,
        st_azimuth (LAG (geom) OVER w, geom) AS trajectory_azimuth
    FROM
        veiculos WINDOW w AS (
            PARTITION BY 
            file_date,
            bus_line_id,
            vehicle_id
            ORDER BY
                timestamp ASC
        )
    ORDER BY
        (
        	file_date,
            bus_line_id,
            vehicle_id,
            timestamp
        ) --LIMIT 100
),
va_pa AS (
    select
    	va.file_date,
        va.bus_line_id,
        va.vehicle_id,
        va.prev_dthr,
        l1.bus_arrival_time,
        va.timestamp,
        va.time_dif,
        va.trajectory_line ,
        va.trajectory_azimuth,
        file_index bus_stop_index,
        pa.bus_stop_name,
        pa.bus_stop_id,
        pa.seq,
        pa.bus_stop_group,
        pa.way,
        pa.bus_stop_type,
        pa.itinerary_id,
        bus_stop_point_geom,
        pa.id shape_sequence,
        pa.shp shape_id,
        pa.shape_line_geom,
        pa.shape_line_azimuth bus_stop_azimuth,
        st_distance distance_from_bus_stop_to_shape,
        l1.distance_bus_to_stop,
        closest_point_vehicle_bus_stop,
        ratio_closest_point_vehicle_bus_stop,
        MIN (l1.distance_bus_to_stop) OVER w_preceding min_distance_bus_to_stop_preceding,
        MIN (l1.distance_bus_to_stop) OVER w_following min_distance_bus_to_stop_following
    FROM
        veiculos_with_azimuth va -- O onibus e o ponto de onibus precisam ser da mesma linha
        JOIN pontos_linha_and_azimuths pa ON TRUE
        AND va.bus_line_id = pa.bus_line_id,
        --AND va.file_date = pa.file_date,
        LATERAL (
        	SELECT
        	-- Calcula o ponto geográfico onde o ônibus mais perto ficou do ponto de ônibus
        	st_closestpoint (va.trajectory_line, pa.bus_stop_point_geom) closest_point_vehicle_bus_stop,
        	-- Calcula a proporção sobre a linha de trajetória do ponto geográfico onde o ônibus mais perto ficou do ponto de ônibus
        	st_linelocatepoint (va.trajectory_line, pa.bus_stop_point_geom) ratio_closest_point_vehicle_bus_stop
        ) l0,
        LATERAL (
            SELECT
                -- Calcula a distância entre o ônibus e o ponto de ônibus
                st_distance (
                    l0.closest_point_vehicle_bus_stop :: geography,
                    pa.bus_stop_point_geom :: geography
                ) distance_bus_to_stop,
                -- Calcula a diferença entre o azimute da trajetória e o azimute do ponto de onibus
                (
                    va.trajectory_azimuth - pa.shape_line_azimuth + pi () + pi () * 2
                ) :: numeric % (pi () * 2) :: numeric - pi () angle_dif,
                -- Calcula a estimativa do momento passado pelo onibus
                va.prev_dthr + (va.time_dif * l0.ratio_closest_point_vehicle_bus_stop) bus_arrival_time
        ) l1
    WHERE
        TRUE -- A distância do ônibus até o ponto de ônibus precisa ser menor que 20m
        AND distance_bus_to_stop <= 40 -- A diferença em graus entre os azimutes precisa estar entre -45 e +45
        AND angle_dif BETWEEN - pi () / 4
        AND pi () / 4 
        WINDOW w_preceding AS (
            PARTITION BY 
            va.file_date,
            va.bus_line_id,
            va.vehicle_id,
            pa.bus_stop_id,
            pa.seq
            ORDER BY
                timestamp ASC RANGE BETWEEN '20 minutes' PRECEDING
                AND CURRENT ROW EXCLUDE CURRENT ROW
        ),
        w_following AS (
            PARTITION BY 
            va.file_date,
            va.bus_line_id,
            va.vehicle_id,
            pa.bus_stop_id,
            pa.seq
            ORDER BY
                timestamp ASC RANGE BETWEEN CURRENT ROW
                AND '20 minutes' FOLLOWING EXCLUDE CURRENT ROW
        )
),
chegadas AS (
    SELECT
        *
    FROM
        va_pa
    WHERE
        TRUE
        AND distance_bus_to_stop < COALESCE(min_distance_bus_to_stop_preceding, '+Infinity')
        AND distance_bus_to_stop <= COALESCE(min_distance_bus_to_stop_following, '+Infinity')
    ORDER by
    	file_date,
        bus_line_id,
        vehicle_id,
        "timestamp"
)
SELECT *
FROM chegadas
