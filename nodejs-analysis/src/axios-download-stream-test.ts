import * as axios from "axios";
import * as path from "path";
import * as fs from "fs";
import * as stream from "stream";
import * as lzma from "lzma-native";
import { Stream } from "stream";
import * as util from "util";

function main() {
  //   async () => {
  //     const aa = await axios.default.get(
  //       "http://dadosabertos.c3sl.ufpr.br/curitibaurbs/pontosLinha.json.xz",
  //       { responseType: "stream" }
  //     );
  //     aa.data
  //       .pipe(fs.createWriteStream(path.resolve("./data/huehue")))
  //       .finish(() => {
  //         console.log("Stream has ended.");
  //       });
  //   };
  try {
    const pontosLinhaResponse = async () =>
      await axios.default.get(
        "http://dadosabertos.c3sl.ufpr.br/curitibaurbs/2019_01_05_pontosLinha.json.xz",
        { responseType: "stream" }
      );
    async () =>
      await new Promise((resolve, reject) => {
        const plStream: Stream = pontosLinhaResponse.data;
        plStream
          .pipe(fs.createWriteStream(path.resolve("./data/hehe.json.xz")))
          .on("finish", resolve)
          .on("error", reject);
        plStream
          .pipe(lzma.createDecompressor())
          .pipe(fs.createWriteStream(path.resolve("./data/hehe.json")))
          .on("finish", resolve)
          .on("error", reject);
        console.log("Batata!");
      });
    console.log("Aeeehooo!");
  } catch (e) {
    console.log(e);
  }
}

main();
