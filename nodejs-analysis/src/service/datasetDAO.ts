import axios from "axios";
import * as fs from "fs";
import * as readline from "readline";
import * as path from "path";
import * as lzma from "lzma-native";
import { Stream } from "stream";
import { DateTime } from "luxon";

import { ShapeLinha, ShapeLinhaRaw } from "../models/shapeLinha";
import PontosLinha from "../models/pontosLinha";
import { PontosLinhaRaw } from "../models/pontosLinha";
import { Veiculos, veiculosRawToVeiculos } from "../models/veiculos";
import { VeiculosRaw } from "./../models/veiculos";
import { pontosLinhaRawToPontosLinha } from "./../models/pontosLinha";

export default class DatasetDAO {
  protected static urlBegin = "http://dadosabertos.c3sl.ufpr.br/curitibaurbs/";
  // File names
  protected static fileNameLinhas = "linhas";
  protected static fileNameShapeLinha = "shapeLinha";
  protected static fileNamePontosLinha = "pontosLinha";
  protected static fileNameVeiculos = "veiculos";

  private static getCompressedFileName(
    date: string,
    selectedTable: string
  ): string {
    return `${date}_${selectedTable}.json.xz`;
  }

  private static getDecompressedFileName(
    date: string,
    selectedTable: string
  ): string {
    return `${date}_${selectedTable}.json`;
  }

  private static getCompressedFilePath(
    date: string,
    selectedTable: string
  ): string {
    return path.resolve(
      "./data/" + this.getCompressedFileName(date, selectedTable)
    );
  }

  private static getDecompressedFilePath(
    date: string,
    selectedTable: string
  ): string {
    return path.resolve(
      "./data/" + this.getDecompressedFileName(date, selectedTable)
    );
  }

  public static async getShapeLinha(date: string): Promise<ShapeLinha[]> {
    const decompressedFilePath = this.getDecompressedFilePath(
      date,
      DatasetDAO.fileNameShapeLinha
    );
    const compressedFilePath = this.getCompressedFilePath(
      date,
      DatasetDAO.fileNameShapeLinha
    );

    console.log("com", compressedFilePath);
    console.log("decom", decompressedFilePath);
    if (!fs.existsSync(decompressedFilePath)) {
      console.log(
        `File ${decompressedFilePath} is not present. Downloading...`
      );
      // Download compressed file and save it
      console.log("Trying to download compressed file.");
      const shapeLinhaResponse = await axios.get(
        DatasetDAO.urlBegin +
          this.getCompressedFileName(date, DatasetDAO.fileNameShapeLinha),
        { responseType: "stream" }
      );

      await new Promise((resolve, reject) => {
        const slrStream: Stream = shapeLinhaResponse.data;
        // Save downloaded compressed file to disk
        slrStream.pipe(
          fs.createWriteStream(
            this.getCompressedFilePath(date, DatasetDAO.fileNameShapeLinha)
          )
        );
        // Save downloaded decompressed file to disk
        slrStream
          .pipe(lzma.createDecompressor())
          .pipe(
            fs.createWriteStream(
              this.getDecompressedFilePath(date, DatasetDAO.fileNameShapeLinha)
            )
          )
          .on("finish", resolve)
          .on("error", reject);
      });

      console.log("Compressed and decompressed file saved!");
    }

    const slr: ShapeLinhaRaw[] = JSON.parse(
      fs
        .readFileSync(
          this.getDecompressedFilePath(date, DatasetDAO.fileNameShapeLinha)
        )
        .toString()
    );
    //console.log(slr);
    const sl = slr.map((item, index) => {
      return {
        ID: index,
        SHP: parseInt(item.SHP),
        COD: item.COD,
        LAT: parseFloat(item.LAT.replace(",", ".")),
        LON: parseFloat(item.LON.replace(",", ".")),
      };
    });
    //console.log(sl);
    return sl;
  }

  public static async getPontosLinha(date: string): Promise<PontosLinha[]> {
    const fileType = DatasetDAO.fileNamePontosLinha;
    const decompressedFilePath = this.getDecompressedFilePath(
      date,
      DatasetDAO.fileNamePontosLinha
    );
    const compressedFilePath = this.getCompressedFilePath(
      date,
      DatasetDAO.fileNamePontosLinha
    );
    if (!fs.existsSync(decompressedFilePath)) {
      console.log(
        `File ${decompressedFilePath} is not present. Downloading...`
      );
      // Download compressed file and save it
      console.log("Trying to download compressed file.");
      const pontosLinhaResponse = await axios.get(
        DatasetDAO.urlBegin + this.getCompressedFileName(date, fileType),
        { responseType: "stream" }
      );

      await new Promise((resolve, reject) => {
        const slrStream: Stream = pontosLinhaResponse.data;
        // Save downloaded compressed file to disk
        slrStream.pipe(
          fs.createWriteStream(this.getCompressedFilePath(date, fileType))
        );
        // Save downloaded decompressed file to disk
        slrStream
          .pipe(lzma.createDecompressor())
          .pipe(
            fs.createWriteStream(this.getDecompressedFilePath(date, fileType))
          )
          .on("finish", resolve)
          .on("error", reject);
      });

      console.log("Compressed and decompressed file saved!");
    }

    const slr: PontosLinhaRaw[] = JSON.parse(
      fs.readFileSync(this.getDecompressedFilePath(date, fileType)).toString()
    );
    return slr.map((item, index) => {
      return pontosLinhaRawToPontosLinha(index, item);
    });
  }

  // TODO check if this method is working
  public static async getVeiculos({
    date,
    cod,
    vehicleNum,
    countLimit,
  }: {
    date: string;
    cod?: string;
    vehicleNum?: string;
    countLimit?: number;
  }): Promise<Array<Veiculos>> {
    const fileType = DatasetDAO.fileNameVeiculos;
    const decompressedFilePath = this.getDecompressedFilePath(date, fileType);
    const compressedFilePath = this.getCompressedFilePath(date, fileType);
    if (!fs.existsSync(decompressedFilePath)) {
      console.log(
        `File ${decompressedFilePath} is not present. Downloading...`
      );
      // Download compressed file and save it
      console.log("Trying to download compressed file.");
      const resp = await axios.get(
        DatasetDAO.urlBegin + this.getCompressedFileName(date, fileType),
        { responseType: "stream" }
      );

      await new Promise((resolve, reject) => {
        const slrStream: Stream = resp.data;
        // Save downloaded compressed file to disk
        slrStream.pipe(fs.createWriteStream(compressedFilePath));
        // Save downloaded decompressed file to disk
        slrStream
          .pipe(lzma.createDecompressor())
          .pipe(fs.createWriteStream(decompressedFilePath))
          .on("finish", resolve)
          .on("error", reject);
      });

      console.log("Compressed and decompressed file saved!");
    }

    async function processLineByLine(
      filePath: string
    ): Promise<Array<Veiculos>> {
      const fileStream = fs.createReadStream(filePath);

      const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity,
      });
      const veicBuffer: Array<Veiculos> = [];
      let count = 0;
      for await (const line of rl) {
        if (countLimit != null && count >= countLimit) {
          break;
        }
        count++;
        try {
          // Each line in input.txt will be successively available here as `line`.
          const vRaw: VeiculosRaw = JSON.parse(line);
          const v = veiculosRawToVeiculos(vRaw);
          let toSave = true;
          if (cod != null && cod !== v.COD_LINHA) {
            toSave = false;
          }
          if (vehicleNum != null && vehicleNum !== v.VEIC) {
            toSave = false;
          }
          if (toSave) {
            veicBuffer.push(v);
          }
        } catch (error) {
          console.log(error);
        }
      }
      return veicBuffer;
    }
    return await processLineByLine(decompressedFilePath);
  }
}
