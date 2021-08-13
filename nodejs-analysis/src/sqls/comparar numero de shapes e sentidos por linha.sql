SELECT COUNT(*) FILTER (
                        WHERE count_matches = true) matches_true,
                COUNT(*) FILTER (
                                 WHERE count_matches = false) matches_false
FROM
    (SELECT *,
            shp_count = sentido_count count_matches
     FROM
         (SELECT cod,
                 count(DISTINCT shp) shp_count
          FROM shapes
          GROUP BY (cod)) as ss
     FULL JOIN
         (SELECT cod,
                 count(DISTINCT sentido) sentido_count
          FROM pontos_linha
          GROUP BY (cod)) as pl ON ss.cod = pl.cod) as q1 /*
          261 que tem o mesmo numero de shapes por seqs	54 que tem numeros diferentes
          */