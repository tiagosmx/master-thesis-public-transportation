import { Client, Pool, Query, PoolConfig } from "pg";
import pgPromise = require("pg-promise");
const pgp = pgPromise();
import PontosLinha, { insertIntoPontosLinhaSQL } from "../models/pontosLinha";
import { ShapeLinha, insertIntoShapeLinha } from "../models/shapeLinha";
import { Veiculos, veiculosToSQL } from "../models/veiculos";
import { createTablePontosLinhaSQL } from "./../models/pontosLinha";
import { createTableShapeLinha } from "./../models/shapeLinha";
import { createTableVeiculos } from "./../models/veiculos";

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
    if (input === null || Number.isNaN(input) || input === undefined) {
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

  async pgSavePontosLinha(
    data: PontosLinha[],
    tableName: string = "pontosLinha"
  ) {
    try {
      const client = await this.pgPool.connect();
      try {
        const createRs = await client.query(
          createTablePontosLinhaSQL(tableName)
        );
        console.log("Success on command", createRs.command);

        const insertRs = await client.query(
          insertIntoPontosLinhaSQL(data, tableName)
        );
        //console.log(insertRs);
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
    tableName: string = "shape_linha"
  ) {
    try {
      console.log(`Creating table ${tableName}...`);
      const createTableRs = await this.pgPool.query(
        createTableShapeLinha(tableName)
      );
      console.log(`Table ${tableName} created!`);

      //console.log(insertIntoShapeLinha(data, tableName));
      const insertRs = await this.pgPool.query(
        insertIntoShapeLinha(data, tableName)
      );
    } catch (e) {
      console.log(e);
    }
  }

  async saveVeiculos(veiculos: Veiculos[]): Promise<void> {
    try {
      const createTableRes = await this.pgPool.query(createTableVeiculos());
      const insertRes = await this.pgPool.query(veiculosToSQL(veiculos));
      console.log("Save veiculos result", insertRes);
    } catch (error) {
      console.log(error);
    }
  }
}
