import DatabaseDAO from "../service/databaseDAO";
import ColumnDefinition from "./ColumnDefinition";

export interface TabelaLinhaRaw {
  HORA?: string;
  PONTO?: string;
  DIA?: string;
  NUM?: string;
  TABELA?: string;
  ADAPT?: string;
  COD?: string;
}

export const TABELA_LINHA_MAPPING: Map<String, ColumnDefinition> = new Map()
  .set("HORA", { cName: "time", cType: "TIME(0)", pName: "HORA" })
  .set("PONTO", { cName: "bus_stop_name", cType: "TEXT", pName: "PONTO" })
  .set("DIA", { cName: "day_category", cType: "TEXT", pName: "DIA" })
  .set("NUM", { cName: "bus_stop_id", cType: "INTEGER", pName: "NUM" })
  .set("TABELA", { cName: "schedule_id", cType: "TEXT", pName: "TABELA" })
  .set("ADAPT", {
    cName: "wheelchair_accessibility_type",
    cType: "TEXT",
    pName: "ADAPT",
  })
  .set("COD", { cName: "bus_line_id", cType: "TEXT", pName: "COD" })
  .set("DIA_AMOSTRA", {
    cName: "file_date",
    cType: "DATE",
    pName: "DIA_AMOSTRA",
  });

export function createTableTabelaLinhaSQL(
  tableName: string = "tabela_linha"
): string {
  const tlm = TABELA_LINHA_MAPPING;
  return `DROP TABLE IF EXISTS ${tableName};
  CREATE TABLE IF NOT EXISTS ${tableName} (
    ${Array.from(TABELA_LINHA_MAPPING.values())
      .map((x) => `${x.cName} ${x.cType}`)
      .join(",\n")}
  );`;
}

export function insertIntoTabelaLinhaSQL(
  tabelaLinha: TabelaLinhaRaw[],
  tableName: string = "tabela_linha",
  diaAmostra: string
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  return `INSERT INTO ${si(tableName)} (
    ${Array.from(TABELA_LINHA_MAPPING.values())
      .map((x) => `${x.cName}`)
      .join(", ")}
    )
  VALUES
  ${tabelaLinha
    .map(
      (c) =>
        `(
        ${sl(c.HORA)}, 
        ${sl(c.PONTO)}, 
        ${sl(c.DIA)}, 
        nullif(${sl(c.NUM)},'')::INTEGER,
        ${sl(c.TABELA)}, 
        ${sl(c.ADAPT)}, 
        ${sl(c.COD)},
        ${sl(diaAmostra)}
        )`
    )
    .join("\n,")}
  ;`;
}
