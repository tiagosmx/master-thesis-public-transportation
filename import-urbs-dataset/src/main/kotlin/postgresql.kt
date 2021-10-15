import java.sql.DriverManager

fun main() {
    val con = DriverManager.getConnection("jdbc:postgresql://localhost/mestrado", "postgres", "postgres")
    val rs = con.createStatement().executeQuery("SELECT version();")
    while (rs.next()){
        println(rs.getObject(1))
    }
}