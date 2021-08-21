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
  date: string
): Promise<void> {
  /* Getting Veiculos file*/
  const v = await DatasetDAO.getVeiculos({
    date: "2021_03_25",
    cod: "216",
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
      port: 49153,
      database: "postgres",
      user: "postgres",
      password: "postgres",
      max: 5,
    });
    await db.init();

    const date = "2021_03_25";
    const shapeLinhaTableName = "shape_linha_" + date;
    const pontosLinhaTableName = "pontos_linha_" + date;

    await downloadAndSavePontosLinha(db, date, pontosLinhaTableName);
    await downloadAndSaveShapeLinha(db, date, shapeLinhaTableName);
  } catch (error) {
    console.log(error);
  }
}

main();
