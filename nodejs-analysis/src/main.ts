import { pontosLinhaToSQL } from "./models/pontosLinha";
import DatabaseDAO from "./service/databaseDAO";
import DatasetDAO from "./service/datasetDAO";

async function main() {
  try {
    const db = new DatabaseDAO();
    await db.init();
    //const pl = await DatasetDAO.getPontosLinha("2019_01_07");
    const dd = await DatasetDAO.getVeiculos("2019_01_08");
    //console.log("Pl size: ", pl.length);

    //db.pgSavePontosLinha(pl);
    //db.saveShapeFiles();
    //const pl = await DatasetDAO.getPontosLinha("2019_01_07");
    //console.log(pl);

    //await db.savePontosLinha(pl);
  } catch (error) {
    console.log(error);
  }
}

main();
