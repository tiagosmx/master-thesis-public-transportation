import DatabaseDAO from "../service/databaseDAO";
import ColumnDefinition from "./ColumnDefinition";

export interface LinhasRaw {
  COD?: string;
  NOME?: string;
  SOMENTE_CARTAO?: string;
  CATEGORIA_SERVICO?: string;
  NOME_COR?: string;
}

export const LINHAS_MAPPING: Map<string, ColumnDefinition> = new Map()
  .set("COD", { cName: "bus_line_id", cType: "TEXT", pName: "COD" })
  .set("NOME", { cName: "bus_line_name", cType: "TEXT", pName: "NOME" })
  .set("SOMENTE_CARTAO", {
    cName: "card_only",
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
    cName: "file_date",
    cType: "DATE",
    pName: "DIA_AMOSTRA",
  });

export function createTableLinhaSQL(tableName: string = "linhas"): string {
  return `DROP TABLE IF EXISTS ${tableName};
  CREATE TABLE IF NOT EXISTS ${tableName} (
    ${Array.from(LINHAS_MAPPING.values())
      .map((lm) => lm.cName + " " + lm.cType)
      .join(",\n")}
  );`;
}

export function insertIntoLinhaSQL(
  tabelaLinha: LinhasRaw[],
  diaAmostra: string,
  tableName: string = "linhas"
): string {
  const sl = DatabaseDAO.sl;
  const si = DatabaseDAO.si;
  return `INSERT INTO ${si(tableName)} (
    ${Array.from(LINHAS_MAPPING.values())
      .map((lm) => lm.cName)
      .join(", ")}
    )
  VALUES
  ${tabelaLinha
    .map(
      (tl) =>
        `(
        ${sl(tl.COD)}, 
        ${sl(tl.NOME)}, 
        ${sl(tl.SOMENTE_CARTAO)}, 
        ${sl(tl.CATEGORIA_SERVICO)},
        ${sl(tl.NOME_COR)}, 
        ${sl(diaAmostra)}
        )`
    )
    .join("\n,")}
  ;`;
}
