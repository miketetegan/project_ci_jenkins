package com.example.dao;

import com.example.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDao {
    private String jdbcURL = System.getenv("DB_URL"); // example: jdbc:mysql://database:3306/mydatabase
    private String jdbcUsername = System.getenv("DB_USERNAME"); //DB user
    private String jdbcPassword = System.getenv("DB_PASSWORD"); //DB secret

    private static final String INSERT_USER_SQL = "INSERT INTO users (name, email) VALUES (?, ?)";
    private static final String SELECT_ALL_USERS = "SELECT * FROM users";

    // Connect to the database
    protected Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return connection;
    }

    // Insert user into the database
    public void insertUser(User user) throws SQLException {
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(INSERT_USER_SQL)) {
            preparedStatement.setString(1, user.getName());
            preparedStatement.setString(2, user.getEmail());
            preparedStatement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

// Retrieve all users from the database
    public List<User> selectAllUsers() {
        List<User> users = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_USERS)) {

            System.out.println("Executing query: " + SELECT_ALL_USERS); // Debug info

            ResultSet rs = preparedStatement.executeQuery();
                while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String email = rs.getString("email");
                users.add(new User(id, name, email));
            }
        } catch (SQLException e) {
            System.err.println("SQL error: " + e.getMessage()); // Debugging SQL exceptions
            e.printStackTrace();
        }
        return users;
    }
}
