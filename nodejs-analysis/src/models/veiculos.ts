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

export const tableVeiculos = `
    CREATE TABLE IF NOT EXISTS veiculos (
        cod_linha TEXT,
        veic TEXT,
        dthr TIMESTAMPTZ,
        lat DOUBLE PRECISION,
        lon DOUBLE PRECISION,
        PRIMARY KEY (cod_linha, veic, dthr)
    );
`;

export function veiculosToSQL(veiculos: Veiculos[]): string {
  const si = DatabaseDAO.si;
  return `INSERT INTO veiculos (
    cod_linha,
    veic,
    dthr,
    lat,
    lon
    )
    VALUES
    ${veiculos
      .map(
        (vei) =>
          `(${si(vei.COD_LINHA)}, ${si(vei.VEIC)}, ${si(vei.DTHR)}, ${si(
            vei.LAT
          )}, ${si(vei.LON)})`
      )
      .join("\n,")}
    ;`;
}

export function veiculosRawToVeiculos(raw: VeiculosRaw): Veiculos {
  const adjustedDate = DateTime.fromFormat(raw.DTHR, "dd/MM/yyyy HH:mm:ss");
  return {
    VEIC: raw.VEIC,
    LAT: parseFloat(raw.LAT),
    LON: parseFloat(raw.LON),
    DTHR: adjustedDate.toISO(),
    COD_LINHA: raw.COD_LINHA,
  };
}
