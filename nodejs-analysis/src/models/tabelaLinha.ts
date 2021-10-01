import DatabaseDAO from "../service/databaseDAO";

export interface TabelaLinhaRaw {
  HORA: string;
  PONTO: string;
  DIA: string;
  NUM: string;
  TABELA: string;
  ADAPT: string;
  COD: string;
}

export interface TabelaLinha {
  HORA: string;
  PONTO: string;
  DIA: string;
  NUM: number;
  TABELA: string;
  ADAPT: string;
  COD: string;
  DIA_AMOSTRA: string;
}

export function toTabelaLinha(raw: TabelaLinhaRaw, dia: string): TabelaLinha {
  return {
    HORA: raw.HORA,
    PONTO: raw.PONTO,
    DIA: raw.DIA,
    NUM: parseInt(raw.NUM),
    TABELA: raw.TABELA,
    ADAPT: raw.ADAPT,
    COD: raw.COD,
    DIA_AMOSTRA: dia,
  };
}

export const TABELA_LINHA_COLUMNS = {
  HORA: { name: "time", type: "TIME" },
  PONTO: { name: "bus_stop_name", type: "TEXT" },
  DIA: { name: "day_category", type: "TEXT" },
  NUM: { name: "bus_stop_id", type: "INTEGER" },
  TABELA: { name: "schedule_id", type: "TEXT" },
  ADAPT: { name: "wheelchair_accessibility_type", type: "TEXT" },
  COD: { name: "bus_line_id", type: "TEXT" },
  DIA_AMOSTRA: { name: "dia", type: "DATE" },
};

export function createTableTabelaLinhaSQL(
  tableName: string = "tabela_linha"
): string {
  const C = TABELA_LINHA_COLUMNS;
  return `CREATE TABLE IF NOT EXISTS ${tableName} (
    ${C.HORA.name} ${C.HORA.type},
    ${C.PONTO.name} ${C.PONTO.type},
    ${C.DIA.name} ${C.DIA.type},
    ${C.NUM.name} ${C.NUM.type},
    ${C.TABELA.name} ${C.TABELA.type},
    ${C.ADAPT.name} ${C.ADAPT.type},
    ${C.COD.name} ${C.COD.type},
    ${C.DIA_AMOSTRA.name} ${C.DIA_AMOSTRA.type},
    PRIMARY KEY (${C.DIA_AMOSTRA.name},${C.COD.name}, ${C.DIA.name}, ${C.TABELA.name}, ${C.NUM.name}, ${C.HORA.name})
  );`;
  //
}
//

export function insertIntoTabelaLinhaSQL(
  tabelaLinha: TabelaLinha[],
  tableName: string = "tabela_linha"
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  const C = TABELA_LINHA_COLUMNS;
  return `INSERT INTO ${si(tableName)} (
    ${C.DIA_AMOSTRA.name},
    ${C.HORA.name},
    ${C.PONTO.name},
    ${C.DIA.name},
    ${C.NUM.name},
    ${C.TABELA.name},
    ${C.ADAPT.name},
    ${C.COD.name}
    )
  VALUES
  ${tabelaLinha
    .filter((x) => {
      return x.NUM !== null && x.NUM !== NaN;
    })
    .map(
      (c) =>
        `(
        ${sl(c.DIA_AMOSTRA)}, 
        ${sl(c.HORA)}, 
        ${sl(c.PONTO)}, 
        ${sl(c.DIA)}, 
        ${sl(c.NUM)},
        ${sl(c.TABELA)}, 
        ${sl(c.ADAPT)}, 
        ${sl(c.COD)}
        )`
    )
    .join("\n,")}
    ON CONFLICT (${C.DIA_AMOSTRA.name},${C.COD.name}, ${C.DIA.name}, ${
    C.TABELA.name
  }, ${C.NUM.name}, ${C.HORA.name})
    DO NOTHING
  ;`;
}
