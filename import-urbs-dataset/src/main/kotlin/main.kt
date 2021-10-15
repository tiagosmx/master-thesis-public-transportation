import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromStream
import org.tukaani.xz.XZInputStream
import java.io.*
import java.net.URL
import java.sql.DriverManager

fun sl(literal: String?): String{
    if(literal == null){
        return "null"
    } else {
        return "$$${literal}$$"
    }
}

@Serializable
data class TabelaLinhaRaw(
    val HORA: String?,
    val PONTO: String?,
    val DIA: String?,
    val NUM: String?,
    val TABELA: String?,
    val ADAPT: String?,
    val COD: String?
) {
    fun createInsert(date: String): String{
        return "(${sl(HORA)}, ${sl(PONTO)}, ${DIA}, ${NUM}, $TABELA, $ADAPT, $COD, $date)"
    }
}

data class ColumnMapping(val columnName: String, val columnType: String, val datasetName: String)

val tabelaLinhaColumnMapping = mapOf<String, ColumnMapping>(
    "HORA" to ColumnMapping("time", "TIME", "HORA"),
    "PONTO" to ColumnMapping("bus_stop_name", "TEXT", "PONTO"),
    "DIA" to ColumnMapping("day_category", "TEXT", "DIA"),
    "NUM" to ColumnMapping("bus_stop_id", "TEXT", "NUM"),
    "TABELA" to ColumnMapping("schedule_id", "TEXT", "TABELA"),
    "ADAPT" to ColumnMapping("wheelchair_accessibility_type", "TEXT", "ADAPT"),
    "COD" to ColumnMapping("bus_line_id", "TEXT", "COD"),
    "FILE_DAY" to ColumnMapping("dia_amostra", "TEXT", "FILE_DAY")
)

val tlcm = tabelaLinhaColumnMapping

fun createTabelaLinhaSQL(tableName: String = "tabela_linha"): String {
    return "CREATE TABLE IF NOT EXISTS $tableName (\n" +
            tlcm.map { x -> "${x.value.columnName} ${x.value.columnType}" }.joinToString(",\n") +
            "PRIMARY KEY (${tlcm["FILE_DAY"]?.columnName},${tlcm["COD"]?.columnName}, ${tlcm["DIA"]?.columnName}, ${tlcm["TABELA"]?.columnName}, ${tlcm["NUM"]?.columnName}, ${tlcm["HORA"]?.columnName})\n);"
}

fun insertTabelaLinhaSQL(tableName: String = "tabela_linha", list: List<TabelaLinhaRaw>, date: String){
    val query = """INSERT INTO $tableName (${tlcm.map { x -> x.value.columnName}.joinToString(", ")}) VALUES ${list.map { x -> "(${x.HORA}, ${}, ${})" }}"""
}

@OptIn(ExperimentalSerializationApi::class)
fun main() {

    val postgreHostname = "localhost"
    val postgrePort = "5432"

    val link = "http://dadosabertos.c3sl.ufpr.br/curitibaurbs/2021_02_22_tabelaLinha.json.xz"
    val path = "./data/tabela-linha.json.xz"

    val urlInStream = URL(link).openStream()
    val xzInStream = XZInputStream(urlInStream)
    val listTabelaLinhaRaw = Json.decodeFromStream<List<TabelaLinhaRaw>>(xzInStream)

    val x = listTabelaLinhaRaw.filter { x -> x.NUM == null }
    println(x)

    println(createTabelaLinhaSQL("aaaaaaaaaaa"))


    /*
    {"HORA":"05:38","PONTO":"TERMINAL CAIUA","DIA":"1","NUM":"109132","TABELA":"1-1","ADAPT":"","COD":"702"}
    */


    //Json.decodeFromStream<List<TabelaLinhaRaw>>()
//    val tabelaLinhaJson = File("./data/tabela-linha.json").readText()
//    val tabelaLinhaRaw = Json.decodeFromString<List<TabelaLinhaRaw>>(tabelaLinhaJson)
//    println(tabelaLinhaRaw)

}