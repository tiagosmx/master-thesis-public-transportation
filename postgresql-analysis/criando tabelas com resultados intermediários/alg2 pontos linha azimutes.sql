--------------- SETTING CURITIBA'S TIMEZONE ---------------
SET timezone = 'America/Sao_Paulo';

CREATE TABLE pontos_linha_azimutes_2019_05_02 AS
--------------- PARAMETERS ---------------
-- Operando sobre as tabelas de dia _2019_05_02
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
        veiculos_2019_05_01_bus_line_216
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
        pontos_linha_2019_05_02
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
        shape_linha_2019_05_02
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
    FROM tabela_veiculo_2019_05_02
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
)
SELECT *
FROM pontos_linha_and_azimuths