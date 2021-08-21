import DatabaseDAO from "../service/databaseDAO";

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
}

export function pontosLinhaRawToPontosLinha(
  index: number,
  plr: PontosLinhaRaw
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
  };
}

export function createTablePontosLinhaSQL(
  tableName: string = "pontos_linha"
): string {
  return `CREATE TABLE IF NOT EXISTS ${tableName} (
    index INTEGER PRIMARY KEY,
    nome TEXT,
    num INTEGER,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    bus_stop_point_geom GEOMETRY,
    seq INTEGER,
    grupo INTEGER,
    sentido TEXT,
    tipo TEXT,
    itinerary_id TEXT,
    cod TEXT
  );`;
}

export function insertIntoPontosLinhaSQL(
  pontosLinha: PontosLinha[],
  tableName: string = "pontos_linha"
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  return `INSERT INTO ${si(tableName)} (
    index, 
    nome, 
    num, 
    lat, 
    lon,
    bus_stop_point_geom,
    seq, 
    grupo, 
    sentido, 
    tipo, 
    itinerary_id, 
    cod
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
        ${sl(pl.COD)})`
    )
    .join("\n,")}
  ;`;
}
