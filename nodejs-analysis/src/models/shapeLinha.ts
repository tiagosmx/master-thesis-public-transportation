import DatabaseDAO from "./../service/databaseDAO";

export interface ShapeLinhaRaw {
  SHP: string;
  LAT: string;
  LON: string;
  COD: string;
}

export interface ShapeLinha {
  ID: number;
  SHP: number;
  LAT: number;
  LON: number;
  COD: string;
}

export function createTableShapeLinha(
  tableName: string = "shape_linha"
): string {
  const si = DatabaseDAO.si;
  return `CREATE TABLE IF NOT EXISTS ${si(tableName)} (
    id INTEGER NOT NULL,
    shp SMALLINT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    shape_point_geom GEOMETRY,
    bus_line_id VARCHAR(3) NOT NULL,
    file_date DATE NOT NULL,
    PRIMARY KEY (shp, id)
  );`;
}

export function insertIntoShapeLinha(
  data: ShapeLinha[],
  tableName: string = "shape_linha",
  date: string
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  return `INSERT INTO ${si(tableName)} (
    id,
    shp,
    lat,
    lon,
    shape_point_geom,
    bus_line_id,
    file_date
    )
  VALUES
  ${data
    .map(
      (row) =>
        `(
          ${sl(row.ID)}, 
          ${sl(row.SHP)}, 
          ${sl(row.LAT)}, 
          ${sl(row.LON)}, 
          st_setsrid(st_makepoint(
            ${sl(row.LON)}::DOUBLE PRECISION, 
            ${sl(row.LAT)}::DOUBLE PRECISION),4326),
          ${sl(row.COD)},
          ${sl(date)}
        )`
    )
    .join("\n,")}
  ;`;
}
