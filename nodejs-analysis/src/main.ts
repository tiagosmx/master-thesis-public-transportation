import { deepStrictEqual } from "assert";
import { insertIntoShapeLinha } from "./models/shapeLinha";
import DatabaseDAO from "./service/databaseDAO";
import DatasetDAO from "./service/datasetDAO";

async function downloadAndSavePontosLinha(
  db: DatabaseDAO,
  date: string,
  tableName: string
) {
  const pl = await DatasetDAO.getPontosLinha(date);
  // Salvando Pontos Linha do banco de dados
  await db.pgSavePontosLinha(pl, tableName);
}

async function downloadAndSaveVeiculos(
  db: DatabaseDAO,
  date: string,
  busLine?: string
): Promise<void> {
  /* Getting Veiculos file*/
  const v = await DatasetDAO.getVeiculos({
    date: date,
    cod: busLine,
    //countLimit: 20,
  });
  //console.log(v);
  //console.log(veiculosToSQL(v));
  //db.saveVeiculos(v);
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
  await fs.writeFile("aaaaeee.json", insertIntoShapeLinha(sl), () => {});
  await db.pgSaveShapeLinha(sl, tableName);
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
      "2019_03_27",
      "2019_03_29",
      "2019_03_30",
      "2019_03_31",
      "2020_03_25",
      "2020_03_26",
      "2020_03_27",
      "2020_03_28",
      "2020_03_29",
      "2020_03_30",
      "2020_03_31",
      "2021_03_25",
      "2021_03_26",
      "2021_03_27",
      "2021_03_28",
      "2021_03_29",
      "2021_03_30",
      "2021_03_31",
    ];

    const date = "2021_03_25";
    const shapeLinhaTableName = "shape_linha_" + date;
    const pontosLinhaTableName = "pontos_linha_" + date;
    const tabelaLinhaTableName = "tabela_linha_" + date;

    //await downloadAndSavePontosLinha(db, date, pontosLinhaTableName);
    //await downloadAndSaveShapeLinha(db, date, shapeLinhaTableName);
    const tabelaLinha = await DatasetDAO.getTabelaLinha(date);
    db.saveTabelaLinha(tabelaLinha, tabelaLinhaTableName);
    console.log(await DatasetDAO.getTabelaLinha(date));
  } catch (error) {
    console.log(error);
  }
}

main();
