package cases;

import java.sql.*;
import java.util.Arrays;

/**
 * JDBC Statement
 * <p>
 * CREATE DATABASE IF NOT EXISTS jdbc_test;
 *
 * @author agui93
 * @since 2021/11/19
 */
public class JdbcCase3 {
    private static final String jdbcUrl = String.format("jdbc:mysql://%s:%s/%s?user=%s&password=%s&useSSL=false",
            "192.168.57.201", 3306, "jdbc_test", "root", "123456");

    static {
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException ignored) {
        }
    }

    private static Connection getConnection() {
        try {
            return DriverManager.getConnection(jdbcUrl);
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    private interface StatementCallback {
        void doInStatement(Statement statement) throws SQLException;
    }

    private static void execute(StatementCallback action) {
        Connection connection = getConnection();
        if (connection == null) {
            return;
        }

        Statement statement = null;
        try {
            statement = connection.createStatement();
            action.doInStatement(statement);
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            //回收statement
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            //回收connection
            try {
                connection.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        Connection connection = getConnection();
        if (connection == null) {
            System.out.println("get connection failed: %s");
            return;
        }

        execute(statement -> {
            statement.executeUpdate("DROP TABLE IF EXISTS Profile;");
            System.out.println("try to drop old table: Profile");
        });


        execute(statement -> {
            statement.executeUpdate("CREATE TABLE Profile (ID INTEGER PRIMARY KEY AUTO_INCREMENT, UserName VARCHAR(20) NOT NULL, BirthDate DATE DEFAULT '2021-11-19')");
            System.out.println("created table: Profile");
        });


        execute(statement -> {
            statement.executeUpdate("INSERT INTO Profile (UserName, BirthDate) VALUES ('a', '2001-01-01')");
            statement.executeUpdate("INSERT INTO Profile (UserName, BirthDate) VALUES ('b', '2001-02-01')");
            statement.executeUpdate("INSERT INTO Profile (UserName, BirthDate) VALUES ('c', '2001-03-01')");
            System.out.println("Insert Profile: a b c");
        });


        execute(statement -> {
            ResultSet resultSet = null;
            try {
                resultSet = statement.executeQuery("SELECT * FROM Profile");

                System.out.println("Query Profiles:");
                while (resultSet.next()) {
                    System.out.printf("  %s,%s,%s\n",
                            resultSet.getInt("ID"),
                            resultSet.getString("UserName"),
                            resultSet.getDate("BirthDate"));
                }
            } finally {
                //回收resultSet
                if (resultSet != null) {
                    try {
                        resultSet.close();
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
        });
    }
}
