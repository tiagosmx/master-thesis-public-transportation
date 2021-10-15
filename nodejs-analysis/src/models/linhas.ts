import DatabaseDAO from "../service/databaseDAO";
import ColumnDefinition from "./ColumnDefinition";

export interface LinhasRaw {
  COD?: string;
  NOME?: string;
  SOMENTE_CARTAO?: string;
  CATEGORIA_SERVICO?: string;
  NOME_COR?: string;
}

export const LINHAS_COLUMNS = {
  COD: { name: "time", type: "TIME" },
  NOME: { name: "bus_stop_name", type: "TEXT" },
  SOMENTE_CARTAO: { name: "somente_cartao", type: "CHAR(1)" },
  CATEGORIA_SERVICO: { name: "categoria", type: "TEXT" },
  NOME_COR: { name: "cor", type: "TEXT" },
  DIA_AMOSTRA: { name: "dia", type: "DATE" },
};

export const LINHAS_MAPPING: Map<String, ColumnDefinition> = new Map()
  .set("COD", { cName: "bus_line_id", cType: "TEXT", pName: "COD" })
  .set("NOME", { cName: "bus_line_name", cType: "TEXT", pName: "NOME" })
  .set("SOMENTE_CARTAO", {
    cName: "only_card",
    cType: "CHAR(1)",
    pName: "SOMENTE_CARTAO",
  })
  .set("CATEGORIA_SERVICO", {
    cName: "bus_line_category",
    cType: "TEXT",
    pName: "CATEGORIA_SERVICO",
  })
  .set("NOME_COR", { cName: "color", cType: "TEXT", pName: "NOME_COR" })
  .set("DIA_AMOSTRA", {
    cName: "day_reference",
    cType: "DATE",
    pName: "DIA_AMOSTRA",
  });

export function createTableTabelaLinhaSQL(
  tableName: string = "linhas"
): string {
  const C = LINHAS_COLUMNS;
  const tlm = LINHAS_MAPPING;
  return `CREATE TABLE IF NOT EXISTS ${tableName} (
    ${Array.from(LINHAS_MAPPING.values())
      .map((x) => `${x.cName} ${x.cType}`)
      .join(",\n")}
  );`;
}

export function insertIntoTabelaLinhaSQL(
  tabelaLinha: LinhasRaw[],
  tableName: string = "linhas",
  diaAmostra: string
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  const C = LINHAS_COLUMNS;
  return `INSERT INTO ${si(tableName)} (
    ${Array.from(LINHAS_MAPPING.values())
      .map((x) => `${x.cName}`)
      .join(", ")}
    )
  VALUES
  ${tabelaLinha
    .map(
      (c) =>
        `(
        ${sl(c.COD)}, 
        ${sl(c.NOME)}, 
        ${sl(c.SOMENTE_CARTAO)}, 
        ${sl(c.CATEGORIA_SERVICO)},
        ${sl(c.NOME_COR)}, 
        ${sl(diaAmostra)}
        )`
    )
    .join("\n,")}
  ;`;
}
