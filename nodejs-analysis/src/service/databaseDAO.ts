import { Client, Pool, Query, PoolConfig } from "pg";
import pgPromise = require("pg-promise");
const pgp = pgPromise();
import PontosLinha, {
  insertIntoPontosLinhaSQL,
  createTablePontosLinhaSQL,
} from "../models/pontosLinha";
import {
  ShapeLinha,
  insertIntoShapeLinha,
  createTableShapeLinha,
} from "../models/shapeLinha";
import {
  createTableTabelaLinhaSQL,
  insertIntoTabelaLinhaSQL,
  TabelaLinhaRaw,
} from "../models/tabelaLinha";
import {
  createPrimaryKeyVeiculos,
  Veiculos,
  veiculosToSQL,
  createTableVeiculos,
} from "../models/veiculos";
import {
  LinhasRaw,
  createTableLinhaSQL,
  insertIntoLinhaSQL,
} from "./../models/linhas";

export default class DatabaseDAO {
  readonly pgPool: Pool;

  constructor(poolConfig?: PoolConfig) {
    this.pgPool = new Pool(poolConfig);
  }

  async init() {
    try {
      const client = await this.pgPool.connect();
      try {
        const rsVersion = await client.query("SELECT version();");
        console.log("Version: ", rsVersion.rows[0]);
      } catch (e) {
        console.log("Querying error ", e);
      } finally {
        client.release();
      }
    } catch (e) {
      console.log("Getting connection from pool error " + e);
    }
  }

  /** Sanitizes Literal (such as a number, constants.., etc) */
  public static sl(input?: any): string {
    if (input === null || Number.isNaN(input) || typeof input == "undefined") {
      return "null";
    } else {
      return "'" + `${input}`.replace("'", "''") + "'";
    }
  }

  /** Sanitizes Identifier (such as table names...) */
  public static si(input?: any): string {
    if (input === null || Number.isNaN(input) || input === undefined) {
      return "null";
    } else {
      return `"` + `${input}`.replace(`"`, `""`) + `"`;
    }
  }

  async savePontosLinha(
    data: PontosLinha[],
    tableName: string = "pontosLinha"
  ) {
    try {
      const client = await this.pgPool.connect();
      try {
        const createRs = await client.query(
          createTablePontosLinhaSQL(tableName)
        );
        console.log("Success on CREATE TABLE", tableName);
        const insert = insertIntoPontosLinhaSQL(data, tableName);
        //console.log("INSERT query:\n", insert);
        const insertRs = await client.query(insert);
        console.log(insertRs);
      } catch (e) {
        console.log(e);
      } finally {
        client.release();
      }
    } catch (e) {
      console.log(e);
    }
  }

  async pgSaveShapeLinha(
    data: ShapeLinha[],
    tableName: string = "shape_linha",
    date: string
  ) {
    try {
      console.log(`Creating table ${tableName}...`);
      const createTableRs = await this.pgPool.query(
        createTableShapeLinha(tableName)
      );
      console.log(`Table ${tableName} created!`);

      //console.log(insertIntoShapeLinha(data, tableName));
      const insertRs = await this.pgPool.query(
        insertIntoShapeLinha(data, tableName, date)
      );
    } catch (e) {
      console.log(e);
    }
  }

  async saveVeiculos(
    veiculos: Veiculos[],
    tableName: string,
    date: string
  ): Promise<void> {
    try {
      console.log(`Creating table ${tableName}`);
      const createTableRes = await this.pgPool.query(
        createTableVeiculos(tableName)
      );
      const insertSQL = veiculosToSQL(veiculos, tableName, date);
      console.log(`Inserting into table ${tableName}`);
      const insertRes = await this.pgPool.query(insertSQL);
      console.log("Save veiculos result", insertRes);
      console.log(`Creating PRIMARY KEY on ${tableName}...`);
      const pkRes = await this.pgPool.query(
        createPrimaryKeyVeiculos(tableName)
      );
      console.log(`pkRes`, pkRes);
    } catch (error) {
      console.log(error);
    }
  }

  async saveTabelaLinha(
    tabelaLinha: TabelaLinhaRaw[],
    tableName: string,
    sampleDay: string
  ) {
    try {
      const createTableRes = await this.pgPool.query(
        createTableTabelaLinhaSQL(tableName)
      );
      //console.log(insertIntoTabelaLinhaSQL(tabelaLinha, tableName));
      const insertRes = await this.pgPool.query(
        insertIntoTabelaLinhaSQL(tabelaLinha, tableName, sampleDay)
      );
      console.log("Save tabela_linha result", insertRes);
    } catch (error) {
      console.log(error);
    }
  }

  async saveLinha(
    tabelaLinha: LinhasRaw[],
    tableName: string,
    sampleDay: string
  ) {
    try {
      const createTableRes = await this.pgPool.query(
        createTableLinhaSQL(tableName)
      );
      //console.log(insertIntoTabelaLinhaSQL(tabelaLinha, tableName));
      const insertRes = await this.pgPool.query(
        insertIntoLinhaSQL(tabelaLinha, sampleDay, tableName)
      );
      console.log("Save tabela_linha result", insertRes);
    } catch (error) {
      console.log(error);
    }
  }
}
