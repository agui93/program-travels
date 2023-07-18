package cases;

import com.mysql.jdbc.jdbc2.optional.MysqlDataSource;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * get connection by DriverManager
 * get connection by DataSource
 *
 * @author agui93
 * @since 2021/11/18
 */
public class JdbcCase2 {

    private static final String host = "192.168.57.201";
    private static final int port = 3306;
    private static final String user = "root";
    private static final String passwd = "123456";

    private static final String driverClass = "com.mysql.jdbc.Driver";
    private static final String jdbcUrl = String.format("jdbc:mysql://%s:%s/?" + "user=%s&password=%s", host, port, user, passwd);

    private static void buildConnectionByDriverManager() {
        Connection connection = null;
        try {
            Class.forName(driverClass);
            connection = DriverManager.getConnection(jdbcUrl);
            DatabaseMetaData dbMeta = connection.getMetaData();
            logDbMeta(dbMeta);
        } catch (SQLException | ClassNotFoundException e) {
            System.out.println("Exception: " + e.getMessage());
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    System.out.println("Exception: " + e.getMessage());
                }
            }
        }
    }

    private static void buildConnectionByDataSource() {
        Connection connection = null;
        try {
            MysqlDataSource dataSource = new MysqlDataSource();
            dataSource.setServerName(host);
            dataSource.setPort(port);
            dataSource.setUser(user);
            dataSource.setPassword(passwd);

            connection = dataSource.getConnection();
            DatabaseMetaData dbMeta = connection.getMetaData();
            logDbMeta(dbMeta);
        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage());
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    System.out.println("Exception: " + e.getMessage());
                }
            }
        }
    }

    private static void logDbMeta(DatabaseMetaData dbMeta) throws SQLException {
        System.out.println("Server name: " + dbMeta.getDatabaseProductName());
        System.out.println("Server version: " + dbMeta.getDatabaseProductVersion());
        System.out.println("Driver name: " + dbMeta.getDriverName());
        System.out.println("Driver version: " + dbMeta.getDriverVersion());
        System.out.println("JDBC major version: " + dbMeta.getJDBCMajorVersion());
        System.out.println("JDBC minor version: " + dbMeta.getJDBCMinorVersion());
    }


    public static void main(String[] args) {
        System.out.println("----------------------------------------------------");
        System.out.println("Get Connection By DriverManager:");
        buildConnectionByDriverManager();


        System.out.println("----------------------------------------------------");
        System.out.println("Get Connection By DataSource:");
        buildConnectionByDataSource();
        System.out.println("----------------------------------------------------");
    }

}
