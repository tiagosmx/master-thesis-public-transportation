import { pontosLinhaToSQL } from "./models/pontosLinha";
import { veiculosToSQL } from "./models/veiculos";
import DatabaseDAO from "./service/databaseDAO";
import DatasetDAO from "./service/datasetDAO";

async function main() {
  try {
    const db = new DatabaseDAO();
    await db.init();
    //const pl = await DatasetDAO.getPontosLinha("2019_01_07");
    const v = await DatasetDAO.getVeiculos({
      date: "2019_01_08",
      cod: "216",
      //countLimit: 20,
    });
    //console.log(v);
    //console.log(veiculosToSQL(v));
    db.saveVeiculos(v);
    //const veicRes = await db.saveVeiculos(dd);
    //console.log(veicRes);
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
