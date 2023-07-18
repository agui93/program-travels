package cases;

import java.sql.*;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * JDBC PreparedStatement
 * <p>
 * CREATE DATABASE IF NOT EXISTS jdbc_test;
 *
 * @author agui93
 * @since 2021/11/19
 */
public class JdbcCase4 {

    private static final String jdbcUrl = String.format("jdbc:mysql://%s:%s/%s?user=%s&password=%s&useSSL=false",
            "192.168.57.201", 3306, "jdbc_test", "root", "123456"
    );


    static {
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException ignored) {
        }
    }

    private interface PreparedStatementCallback {
        void doInPreparedStatement(PreparedStatement ps) throws SQLException;
    }


    private static Connection getConnection() {
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(jdbcUrl);
        } catch (SQLException e) {
            System.out.println("Exception: " + e.getMessage());
        }
        return connection;
    }


    private static void execute(String sql, PreparedStatementCallback action) {
        Connection connection = getConnection();
        if (connection == null) {
            return;
        }
        PreparedStatement ps = null;
        try {
            ps = connection.prepareStatement(sql);
            action.doInPreparedStatement(ps);
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            //回收PreparedStatement
            if (ps != null) {
                try {
                    ps.close();
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

    private static void createTable() {
        String dropOldTableSql = "DROP TABLE IF EXISTS Profile;";
        execute(dropOldTableSql, ps -> {
            ps.executeUpdate(dropOldTableSql);
            System.out.println("Try to drop old table: Profile");
        });


        String createSql = "CREATE TABLE Profile ( ID INTEGER PRIMARY KEY AUTO_INCREMENT, UserName VARCHAR(20) NOT NULL, BirthDate DATE DEFAULT '2021-11-19')";
        execute(createSql, ps -> {
            ps.executeUpdate(createSql);
            System.out.println("Created Table: Profile");
        });
    }

    private static void inserts(int size, List<String> preUserNames, List<String> preBirthdays) {
        String insertSql = "INSERT INTO Profile (UserName, BirthDate) VALUES (?,?)";
        execute(insertSql, ps -> {
            for (int i = 0; i < size; i++) {
                ps.setString(1, preUserNames.get(i));
                ps.setString(2, preBirthdays.get(i));
                ps.executeUpdate();
                System.out.println("Inserted: " + preUserNames.get(i) + "," + preBirthdays.get(i));
            }

        });
    }


    private static void queryById(int id) {
        String selectByIdSql = "SELECT * FROM Profile WHERE ID = ?";
        execute(selectByIdSql, ps -> {
            ps.setInt(1, id);
            try (ResultSet resultSet = ps.executeQuery()) {
                System.out.println("Query By Id=" + id);
                while (resultSet.next()) {
                    System.out.printf("  %s,%s,%s\n",
                            resultSet.getInt("ID"),
                            resultSet.getString("UserName"),
                            resultSet.getDate("BirthDate"));
                }
            }
        });
    }

    private static void queryCount() {
        String selectCountSql = "SELECT COUNT(*) FROM Profile";

        execute(selectCountSql, ps -> {
            try (ResultSet resultSet = ps.executeQuery(selectCountSql)) {
                if (resultSet.next()) {
                    System.out.println("Query Count: " + resultSet.getInt(1));
                }
            }
        });
    }

    private static void queryAll() {
        String selectSql = "SELECT * FROM Profile";

        execute(selectSql, ps -> {
            try (ResultSet resultSet = ps.executeQuery(selectSql)) {
                System.out.println("Query All:");
                while (resultSet.next()) {
                    System.out.printf("  %s,%s,%s\n",
                            resultSet.getInt("ID"),
                            resultSet.getString("UserName"),
                            resultSet.getDate("BirthDate"));
                }
            }
        });
    }

    private static void batchInserts(int size, List<String> batchUserNames, List<String> batchBirthdays) {
        String insertSql = "INSERT INTO Profile (UserName, BirthDate) VALUES (?,?)";
        execute(insertSql, ps -> {
            for (int i = 0; i < size; i++) {
                ps.setString(1, batchUserNames.get(i));
                ps.setString(2, batchBirthdays.get(i));
                ps.addBatch();
            }

            int[] counts = ps.executeBatch();
            int effectedRows = 0;
            for (int count : counts) {
                effectedRows += count;
            }

            System.out.println("BatchInsert Rows: " + effectedRows);
        });
    }


    public static void main(String[] args) {
        createTable();

        inserts(1, Collections.singletonList("a"), Collections.singletonList("2001-01-01"));
        inserts(2, Arrays.asList("b", "c"), Arrays.asList("2001-01-01", "2001-03-01"));
        queryById(1);
        queryById(2);
        queryCount();
        queryAll();


        batchInserts(2,
                Arrays.asList("m", "n"),
                Arrays.asList("2001-04-01", "2001-05-01")
        );
        batchInserts(3,
                Arrays.asList("x", "y", "z"),
                Arrays.asList("2001-06-01", "2001-07-01", "2001-08-01"));
        queryById(3);
        queryById(4);
        queryCount();
        queryAll();
    }

}
