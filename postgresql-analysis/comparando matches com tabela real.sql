-- Limpando a tabela de matches
WITH tabela_linha AS(
    SELECT
        DISTINCT day_reference,
        bus_line_id,
        day_category,
        schedule_id,
        bus_stop_id,
        time
    FROM
        public.tabela_linha_2021_03_25
    WHERE
        CASE
            WHEN bus_stop_id = '' THEN null
            ELSE bus_stop_id
        END IS NOT NULL
) CREATE TABLE cleaned_tabela_linha_2021_03_25 AS WITH cleaned_tabela_linha_2021_03_25 AS(
    SELECT
        DISTINCT day_reference,
        bus_line_id,
        day_category,
        schedule_id,
        bus_stop_id,
        time
    FROM
        public.tabela_linha_2021_03_25
    WHERE
        CASE
            WHEN bus_stop_id = '' THEN null
            ELSE bus_stop_id
        END IS NOT NULL
)
SELECT
    *
FROM
    cleaned_tabela_linha_2021_03_25;