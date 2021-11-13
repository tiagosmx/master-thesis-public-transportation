import { insertIntoShapeLinha } from "./models/shapeLinha";
import { insertIntoTabelaLinhaSQL } from "./models/tabelaLinha";
import DatabaseDAO from "./service/databaseDAO";
import DatasetDAO from "./service/datasetDAO";
import { createTableVeiculos } from "./models/veiculos";

async function downloadAndSavePontosLinha(
  db: DatabaseDAO,
  date: string,
  tableName: string
) {
  const pl = await DatasetDAO.getPontosLinha(date);
  // Salvando Pontos Linha do banco de dados
  await db.savePontosLinha(pl, tableName);
}

async function downloadAndSaveTabelaLinha(
  db: DatabaseDAO,
  date: string,
  tableName: string
) {
  const dados = await DatasetDAO.getTabelaLinha(date);
  // Salvando TabelaLinha do banco de dados
  await db.saveTabelaLinha(dados, tableName, date);
}

async function downloadAndSaveVeiculos(
  db: DatabaseDAO,
  date: string,
  tableName: string,
  busLine?: string
): Promise<void> {
  /* Getting Veiculos file*/
  const v = await DatasetDAO.getVeiculos({
    date: date,
    cod: busLine,
    //countLimit: 20,
  });
  //console.log("V:\n", v);
  //console.log(veiculosToSQL(v));
  const isoDate = date.replace(/_/g, "-");
  tableName = tableName + (busLine ? "_bus_line_" + busLine : "");
  await db.saveVeiculos(v, tableName, isoDate);
  //const veicRes = await db.saveVeiculos(dd);
  //console.log(veicRes);
}

async function downloadAndSaveShapeLinha(
  db: DatabaseDAO,
  date: string,
  tableName: string
): Promise<void> {
  const sl = await DatasetDAO.getShapeLinha(date);
  const fs = require("fs");
  const isoDate = date.replace(/_/g, "-");
  await db.pgSaveShapeLinha(sl, tableName, isoDate);
}

async function main() {
  try {
    const db = new DatabaseDAO({
      host: "localhost",
      port: 5432,
      database: "mestrado",
      user: "postgres",
      password: "postgres",
      max: 5,
    });
    await db.init();

    const dates = [
      "2019_05_01",
      "2019_05_02",
      "2019_05_03",
      "2019_05_04",
      "2019_05_05",
      "2019_05_06",
      "2019_05_07",
      "2019_05_08",
      "2019_05_09",
      "2019_05_10",
      "2019_05_11",
      "2019_05_12",
      "2019_05_13",
      "2019_05_14",
      "2019_05_15",
      "2019_05_16",
      "2019_05_17",
      "2019_05_18",
      "2019_05_19",
      "2019_05_20",
      "2019_05_21",
      "2019_05_22",
      "2019_05_23",
      "2019_05_24",
      "2019_05_25",
      "2019_05_26",
      "2019_05_27",
      "2019_05_28",
      "2019_05_29",
      "2019_05_30",
      "2019_05_31",
    ];

    dates.forEach(async (date) => {
      console.log("CURRENT DATE ", date);
      const isoDate = date.replace(/_/g, "-");
      const shapeLinhaTableName = "shape_linha_" + date;
      const pontosLinhaTableName = "pontos_linha_" + date;
      const tabelaLinhaTableName = "tabela_linha_" + date;
      const busLineId = "216";
      const veiculosTableName = "veiculos_" + date;

      await downloadAndSavePontosLinha(db, date, pontosLinhaTableName);
      await downloadAndSaveShapeLinha(db, date, shapeLinhaTableName);
      await downloadAndSaveTabelaLinha(db, date, tabelaLinhaTableName);
      await downloadAndSaveVeiculos(db, date, veiculosTableName, busLineId);
    });
  } catch (error) {
    console.log(error);
  }
}

main();
