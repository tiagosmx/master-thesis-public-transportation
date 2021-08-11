import axios from "axios";
import * as fs from "fs";
import * as path from "path";
import * as lzma from "lzma-native";
import { Stream } from "stream";

import { ShapeLinha, ShapeLinhaRaw } from "../models/shapeLinha";
import DatabaseDAO from "./databaseDAO";
import PontosLinha from "../models/pontosLinha";
import { PontosLinhaRaw } from "./../models/pontosLinha";

export default class DatasetDAO {
  protected static urlBegin = "http://dadosabertos.c3sl.ufpr.br/curitibaurbs/";
  // File names
  protected static linhas = "linhas";
  protected static shapeLinha = "shapeLinha";
  protected static pontosLinha = "pontosLinha";

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
      DatasetDAO.shapeLinha
    );
    const compressedFilePath = this.getCompressedFilePath(
      date,
      DatasetDAO.shapeLinha
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
          this.getCompressedFileName(date, DatasetDAO.shapeLinha),
        { responseType: "stream" }
      );

      await new Promise((resolve, reject) => {
        const slrStream: Stream = shapeLinhaResponse.data;
        // Save downloaded compressed file to disk
        slrStream.pipe(
          fs.createWriteStream(
            this.getCompressedFilePath(date, DatasetDAO.shapeLinha)
          )
        );
        // Save downloaded decompressed file to disk
        slrStream
          .pipe(lzma.createDecompressor())
          .pipe(
            fs.createWriteStream(
              this.getDecompressedFilePath(date, DatasetDAO.shapeLinha)
            )
          )
          .on("finish", resolve)
          .on("error", reject);
      });

      console.log("Compressed and decompressed file saved!");
    }

    const slr: ShapeLinhaRaw[] = JSON.parse(
      fs
        .readFileSync(this.getDecompressedFilePath(date, DatasetDAO.shapeLinha))
        .toString()
    );
    return slr.map((item, index) => {
      return {
        ID: index,
        SHP: parseInt(item.SHP),
        COD: item.COD,
        LAT: parseFloat(item.LAT),
        LON: parseFloat(item.LON),
      };
    });
  }

  public static async getPontosLinha(date: string): Promise<PontosLinha[]> {
    const fileType = DatasetDAO.pontosLinha;
    const decompressedFilePath = this.getDecompressedFilePath(
      date,
      DatasetDAO.pontosLinha
    );
    const compressedFilePath = this.getCompressedFilePath(
      date,
      DatasetDAO.pontosLinha
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
      return {
        INDEX: index,
        NOME: item.NOME,
        NUM: parseInt(item.NUM),
        LAT: parseFloat(item.LAT),
        LON: parseFloat(item.LON),
        SEQ: parseInt(item.SEQ),
        GRUPO: parseInt(item.GRUPO),
        SENTIDO: item.SENTIDO,
        TIPO: item.TIPO,
        ITINERARY_ID: item.ITINERARY_ID,
        COD: item.COD,
      };
    });
  }
}
