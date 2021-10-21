import DatabaseDAO from "../service/databaseDAO";
import ColumnDefinition from "./ColumnDefinition";

export interface PontosLinhaRaw {
  NOME: string;
  NUM: string;
  LAT: string;
  LON: string;
  SEQ: string;
  GRUPO: string;
  SENTIDO: string;
  TIPO: string;
  ITINERARY_ID: string;
  COD: string;
}

export default interface PontosLinha {
  INDEX: number;
  NOME: string;
  NUM: number;
  LAT: number;
  LON: number;
  SEQ: number;
  GRUPO: number;
  SENTIDO: string;
  TIPO: string;
  ITINERARY_ID: string;
  COD: string;
  DATA_AMOSTRA: string;
}

export function pontosLinhaRawToPontosLinha(
  index: number,
  plr: PontosLinhaRaw,
  dataAmostra: string
): PontosLinha {
  return {
    INDEX: index,
    NOME: plr.NOME,
    NUM: parseInt(plr.NUM),
    LAT: parseFloat(plr.LAT.replace(",", ".")),
    LON: parseFloat(plr.LON.replace(",", ".")),
    SEQ: parseInt(plr.SEQ),
    GRUPO: parseInt(plr.GRUPO),
    SENTIDO: plr.SENTIDO,
    TIPO: plr.TIPO,
    ITINERARY_ID: plr.ITINERARY_ID,
    COD: plr.COD,
    DATA_AMOSTRA: dataAmostra,
  };
}

export function createTablePontosLinhaSQL(
  tableName: string = "pontos_linha"
): string {
  return `DROP TABLE IF EXISTS ${tableName};
  CREATE TABLE IF NOT EXISTS ${tableName} (
    file_index INTEGER PRIMARY KEY,
    bus_stop_name TEXT,
    bus_stop_id INTEGER,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    bus_stop_point_geom GEOMETRY,
    seq INTEGER,
    bus_stop_group INTEGER,
    way TEXT,
    bus_stop_type TEXT,
    itinerary_id TEXT,
    bus_line_id TEXT,
    file_date DATE
  );`;
}

export function insertIntoPontosLinhaSQL(
  pontosLinha: PontosLinha[],
  tableName: string = "pontos_linha"
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  return `INSERT INTO ${si(tableName)} (
    file_index, 
    bus_stop_name, 
    bus_stop_id, 
    lat, 
    lon,
    bus_stop_point_geom,
    seq, 
    bus_stop_group, 
    way, 
    bus_stop_type, 
    itinerary_id, 
    bus_line_id,
    file_date
    )
  VALUES
  ${pontosLinha
    .map(
      (pl) =>
        `(${sl(pl.INDEX)}, 
        ${sl(pl.NOME)}, 
        ${sl(pl.NUM)}, 
        ${sl(pl.LAT)}, 
        ${sl(pl.LON)}, 
        st_setsrid(st_makepoint(
          ${sl(pl.LON)}::DOUBLE PRECISION, 
          ${sl(pl.LAT)}::DOUBLE PRECISION),4326), 
        ${sl(pl.SEQ)}, 
        ${sl(pl.GRUPO)}, 
        ${sl(pl.SENTIDO)}, 
        ${sl(pl.TIPO)}, 
        ${sl(pl.ITINERARY_ID)}, 
        ${sl(pl.COD)},
        ${sl(pl.DATA_AMOSTRA)}
        )`
    )
    .join("\n,")}
  ;`;
}
