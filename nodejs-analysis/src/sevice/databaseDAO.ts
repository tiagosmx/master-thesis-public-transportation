import { Client, Pool, Query } from "pg";
import pgPromise = require("pg-promise");
const pgp = pgPromise();
import PontosLinha, { pontosLinhaToSQL } from "../models/pontosLinha";
import { ShapeLinha } from "../models/shapeLinha";
import { ShapeLinhaRaw } from "./../models/shapeLinha";

export default class DatabaseDAO {
  readonly pgPool: Pool;

  constructor() {
    this.pgPool = new Pool({
      host: "localhost",
      port: 49153,
      database: "postgres",
      user: "postgres",
      password: "postgres",
      max: 5,
    });
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

  public static si(input?: any): string {
    if (input === null || Number.isNaN(input) || input === undefined) {
      return "null";
    } else {
      return "'" + `${input}`.replace("'", "''") + "'";
    }
  }

  async pgSavePontosLinha(pontosLinha: PontosLinha[]) {
    try {
      const client = await this.pgPool.connect();
      try {
        const createRs = await client.query(
          `CREATE TABLE IF NOT EXISTS pontos_linha (
          index INTEGER PRIMARY KEY,
          nome TEXT,
          num INTEGER,
          lat DOUBLE PRECISION,
          lon DOUBLE PRECISION,
          seq INTEGER,
          grupo INTEGER,
          sentido TEXT,
          tipo TEXT,
          itinerary_id TEXT,
          cod TEXT
        );`
        );
        console.log("Success on command", createRs.command);

        const insertRs = await client.query(pontosLinhaToSQL(pontosLinha));
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

  async pgSaveShapeLinha(shapeLinha: ShapeLinha[]) {
    try {
      const xx = await this.pgPool.query(
        `
          CREATE TABLE IF NOT EXISTS shapes (
            id INTEGER PRIMARY KEY,
            shp INTEGER NOT NULL,
            cod TEXT NOT NULL,
            lat DOUBLE PRECISION NOT NULL,
            lon DOUBLE PRECISION NOT NULL
          );
          `
      );
    } catch (e) {
      console.log(e);
    }
  }

  async savePontosLinha(pontosLinha: PontosLinha[]): Promise<void> {
    const x = await this.pgPool.query(
      `CREATE TABLE IF NOT EXISTS pontos_linha (
          index INTEGER PRIMARY KEY,
          nome TEXT,
          num INTEGER,
          lat DOUBLE PRECISION,
          lon DOUBLE PRECISION,
          seq INTEGER,
          grupo INTEGER,
          sentido TEXT,
          tipo TEXT,
          itinerary_id TEXT,
          cod TEXT
        );`
    );
    console.log(x);

    const pgp = pgPromise();
    const cs = new pgp.helpers.ColumnSet(
      [
        { name: "index", prop: "INDEX" },
        { name: "nome", prop: "NOME" },
        { name: "num", prop: "NUM" },
        { name: "lat", prop: "LAT" },
        { name: "lon", prop: "LON" },
        { name: "seq", prop: "SEQ" },
        { name: "grupo", prop: "GRUPO" },
        { name: "sentido", prop: "SENTIDO" },
        { name: "tipo", prop: "TIPO" },
        { name: "itinerary_id", prop: "ITINERARY_ID" },
        { name: "cod", prop: "COD" },
      ],
      {
        table: "pontos_linha",
      }
    );
  }
}
