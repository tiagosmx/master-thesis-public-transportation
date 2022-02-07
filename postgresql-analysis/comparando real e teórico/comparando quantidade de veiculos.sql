WITH a AS ( -- 13
SELECT bus_line_id, vehicle_id, COUNT(*)
FROM tabela_veiculo_2019_05_02 tv
WHERE bus_line_id = '216'
GROUP BY bus_line_id, vehicle_id
),
b AS ( -- 13
SELECT bus_line_id, vehicle_id, COUNT(*)
FROM veiculos_2019_05_03_bus_line_216
WHERE bus_line_id = '216'
GROUP BY bus_line_id, vehicle_id 
)
SELECT *
FROM a
