import DatabaseDAO from "../service/databaseDAO";
import { DateTime } from "luxon";

//{"VEIC":"BA001","LAT":"-25.378111","LON":"-49.26265","DTHR":"02\/05\/2019 08:37:25","COD_LINHA":"242"}
export interface VeiculosRaw {
  VEIC: string;
  LAT: string;
  LON: string;
  DTHR: string;
  COD_LINHA: string;
}

export interface Veiculos {
  VEIC: string;
  LAT: number;
  LON: number;
  DTHR: string;
  COD_LINHA: string;
}

export function createTableVeiculos(tableName: string = "veiculos"): string {
  return `
CREATE TABLE IF NOT EXISTS ${tableName} (
    bus_line_id TEXT,
    vehicle_id TEXT,
    timestamp TIMESTAMPTZ,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    bus_location_point_geom GEOMETRY,
    file_date DATE
    --,PRIMARY KEY (bus_line_id, vehicle_id, timestamp)
);
`;
}

export function createPrimaryKeyVeiculos(
  tableName: string = "veiculos"
): string {
  return `ALTER TABLE ${tableName}
  ADD PRIMARY KEY (bus_line_id, vehicle_id, timestamp);
  `;
}

export function veiculosToSQL(
  data: Veiculos[],
  tableName: string = "veiculos",
  date: string
): string {
  const si = DatabaseDAO.sl;
  return `INSERT INTO ${tableName} (
    bus_line_id,
    vehicle_id,
    timestamp,
    lat,
    lon,
    bus_location_point_geom,
    file_date
    )
    VALUES\n${data
      .map(
        (vei) =>
          `(${si(vei.COD_LINHA)}, ${si(vei.VEIC)}, ${si(vei.DTHR)}, ${si(
            vei.LAT
          )}, ${si(vei.LON)}, st_setsrid(st_makepoint(${si(
            vei.LON
          )}::float, ${si(vei.LAT)}::float),4326), ${si(date)}::DATE)`
      )
      .join("\n,")}
    ;`;
}

export function veiculosRawToVeiculos(raw: VeiculosRaw): Veiculos {
  //string.replace(searchvalue, newvalue)
  const adjustedDate = DateTime.fromFormat(raw.DTHR, "dd/MM/yyyy HH:mm:ss");
  return {
    VEIC: raw.VEIC,
    LAT: parseFloat(raw.LAT.replace(",", ".")),
    LON: parseFloat(raw.LON.replace(",", ".")),
    DTHR: adjustedDate.toISO(),
    COD_LINHA: raw.COD_LINHA,
  };
}
