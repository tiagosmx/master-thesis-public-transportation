CREATE TABLE shapes_by_shapes AS
    (SELECT cod,
            shp,
            st_makeline(st_setsrid(st_makepoint(lon::float, lat::float),4326)
                        ORDER BY id) geom
     FROM shapes
     GROUP BY cod,
              shp)
;
ALTER TABLE shapes_by_shapes
ADD PRIMARY KEY (cod, shp);