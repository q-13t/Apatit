package edu.chat.services;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import edu.chat.utils.JWTUtil;
import edu.chat.views.User;

@Service
public class UserService {
    private Logger log = Logger.getLogger(UserService.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;
    @Autowired
    private JWTUtil jwtTokenUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public String authenticate(User user) {
        return jwtTokenUtil.generateToken(user);
    }

    public boolean checkUserExists(String username) {
        try {
            User user = getUserByUsername(username);
            if (user == null) {
                return false;
            } else {
                return true;
            }
        } catch (Exception e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public boolean addUser(User user) {
        try {
            if (!checkUserExists(user.getUsername())) {
                user.setPassword(passwordEncoder.encode(user.getPassword()));
                jdbcTemplate.update("INSERT INTO \"user\" (user_name, \"password\") VALUES (?, ?)", user.getUsername(), user.getPassword());
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return false;
        }
    }

    public User getUserByUsername(String username) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM \"user\" WHERE user_name = ?", new UserMapper(), username);
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }
}
