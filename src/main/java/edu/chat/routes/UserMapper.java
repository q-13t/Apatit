package edu.chat.routes;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import edu.chat.views.User;

public class UserMapper implements RowMapper<User> {

    @Override
    public User mapRow(ResultSet result, int arg1) throws SQLException {
        User user = new User();
        user.setId(result.getInt("id"));
        user.setUsername(result.getString("user_name"));
        user.setPassword(result.getString("password"));
        user.setPfp(result.getInt("profile_picture"));
        return user;
    }

}
