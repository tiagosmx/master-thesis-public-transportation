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

export function pontosLinhaToSQL(pontosLinha: PontosLinha[]): string {
  const si = DatabaseDAO.si;
  return `INSERT INTO pontos_linha (
    index, 
    nome, 
    num, 
    lat, 
    lon, 
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
        `(${si(pl.INDEX)}, ${si(pl.NOME)}, ${si(pl.NUM)}, ${si(pl.LAT)}, ${si(
          pl.LON
        )}, ${si(pl.SEQ)}, ${si(pl.GRUPO)}, ${si(pl.SENTIDO)}, ${si(
          pl.TIPO
        )}, ${si(pl.ITINERARY_ID)}, ${si(pl.COD)})`
    )
    .join("\n,")}
  ;`;
}
