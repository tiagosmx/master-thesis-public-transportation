import * as fs from "fs";
import * as lzma from "lzma-native";
import * as axios from "axios";
import * as path from "path";
import * as _ from "lodash";
import pgPromise = require("pg-promise");
import { ShapeLinha, ShapeLinhaRaw } from "./models/shapeLinha";

const urlBegin = "http://dadosabertos.c3sl.ufpr.br/curitibaurbs/";
const linhas = "linhas";
const date = "2019_01_05";
const selectedTable = "shapeLinha";

/*
[   ]	2017_01_18_linhas.json.tar.gz	2017-01-18 07:07	3.9K	 
[   ]	2017_01_18_pois.json.tar.gz	2017-01-18 07:07	69K	 
[   ]	2017_01_18_pontosLinha.json.tar.gz	2017-01-18 07:07	678K	 
[   ]	2017_01_18_shapeLinha.json.tar.gz	2017-01-18 07:07	3.6M	 
[   ]	2017_01_18_tabelaLinha.json.tar.gz	2017-01-18 07:07	439K	 
[   ]	2017_01_18_tabelaVeiculo.json.tar.gz	2017-01-18 07:07	732K	 
[   ]	2017_01_18_trechosItinerarios.json.tar.gz	2017-01-19 10:19	73K	 
[   ]	2017_01_18_veiculos.json.tar.gz	2017-01-18 07:07	51M	 
*/

const compressedFileName = `${date}_${selectedTable}.json.xz`;
const decompressedFileName = `${date}_${selectedTable}.json`;

const compressedFilePath = path.resolve(`./data/${compressedFileName}`);
console.log(compressedFilePath);
const decompressedFilePath = path.resolve(`./data/${decompressedFileName}`);
console.log(decompressedFilePath);

function readStuff() {
  const cf = fs.readFileSync(decompressedFilePath);
  const shapeFile: ShapeLinhaRaw[] = JSON.parse(cf.toString());
  const shapeLinhas: ShapeLinha[] = shapeFile.map((item, index) => {
    return {
      ID: index,
      SHP: parseInt(item.SHP),
      COD: item.COD,
      LAT: parseFloat(item.LAT),
      LON: parseFloat(item.LON),
    };
  });

  //const cabralPortao = sf.filter((x) => x.COD == "216");
  //console.log(sf);
  // const result = _.chain(cabralPortao)
  //   .groupBy((x) => x.SHP)
  //   .map((value, key) => ({ shape: key, value: value }))
  //   .value();
  //console.log(result);
  const pgp = pgPromise();
  const db = pgp("postgres://postgres:postgres@localhost:49153/postgres");

  db.none(
    `
  CREATE TABLE IF NOT EXISTS shapes (
    ID INTEGER PRIMARY KEY,
    SHP INTEGER NOT NULL,
    COD TEXT NOT NULL,
    LAT DOUBLE PRECISION NOT NULL,
    LON DOUBLE PRECISION NOT NULL
  );
  `
  )
    .then(() => {
      console.log("Table created successfully");
    })
    .catch(() => {
      console.log("Error while creating table");
    });

  const cs = new pgp.helpers.ColumnSet(
    [
      { name: "id", prop: "ID" },
      { name: "shp", prop: "SHP" },
      { name: "lat", prop: "LAT" },
      { name: "lon", prop: "LON" },
      { name: "cod", prop: "COD" },
    ],
    {
      table: "shapes",
    }
  );

  const insert = pgp.helpers.insert(shapeLinhas, cs);
  db.none(insert)
    .then(() => {
      console.log("Success on batch insert.");
    })
    .catch((e) => {
      console.log("Error while batch inserting.", e);
    });
}

if (!fs.existsSync(compressedFilePath)) {
  console.log("Downloading file...");
  axios
    .default({
      method: "GET",
      url: urlBegin + compressedFileName,
      responseType: "stream",
    })
    .then((res) => {
      res.data.pipe(fs.createWriteStream(compressedFilePath));
      const xzDecompressor = lzma.createDecompressor();
      res.data
        .pipe(xzDecompressor)
        .pipe(fs.createWriteStream(decompressedFilePath));
      readStuff();
    });
} else {
  console.log("File is already present on disk.");
  readStuff();
}

/*
const buffer = fs.readFileSync(compressedFileName);
lzma.decompress(buffer, 9, (res) => {
  fs.writeFileSync(decompressedFileName, res);
});
*/

/*

lzma.compress("Teste de compressão", {}, (result) => {
  console.log("teste de compressão:", result);
  lzma.decompress(result, {})
});
*/
