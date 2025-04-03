package edu.chat.services;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import edu.chat.views.User;

@Service
public class UserService {
    private Logger log = Logger.getLogger(UserService.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public int addUser(User user) {
        try {
            jdbcTemplate.update("INSERT INTO \"user\" (user_name, \"password\") VALUES (?, ?)", user.getUsername(), user.getPassword());
            return 1;
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return 0;
        }
    }
}
