package edu.chat.services;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import edu.chat.Exceptions.ExpiredTokenException;
import edu.chat.Exceptions.InvalidTokenException;
import edu.chat.Exceptions.UserDoesNotExistException;
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

    public void validateToken(String token) throws InvalidTokenException, ExpiredTokenException, UserDoesNotExistException {
        String username;
        try {
            username = jwtTokenUtil.extractUsername(token);
        } catch (Exception e) {
            throw new InvalidTokenException();
        }
        if (!checkUserExists(username)) {
            throw new UserDoesNotExistException();
        } else if (jwtTokenUtil.isTokenExpired(token)) {
            throw new ExpiredTokenException();
        } else {
            return;
        }
    }

    public String authenticate(User user) {
        return jwtTokenUtil.generateToken(user);
    }

    public boolean checkUserExists(String username) {
        User user = getUserByUsername(username);
        if (user == null) {
            return false;
        } else {
            return true;
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
        } catch (DataAccessException e) {
            log.error(e.getMessage(), e);
            return false;
        }
    }

    public List<User> getUsersByUsername(String username) {
        try {
            return jdbcTemplate.query("SELECT * FROM \"user\" WHERE user_name LIKE ?", new UserMapper(), username + "%");
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public User getUserByUsername(String username) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM \"user\" WHERE user_name = ?", new UserMapper(), username);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public boolean deleteUser(User user) {
        try {
            if (!checkUserExists(user.getUsername()))
                return false;
            jdbcTemplate.update("DELETE FROM \"user\" WHERE user_name = ?", user.getUsername());
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
        }
        return false;
    }

    public User changeUsername(User user, String newUsername) {
        try {
            if (!checkUserExists(user.getUsername()))
                return null;
            jdbcTemplate.update("UPDATE \"user\" SET user_name = ? WHERE user_name = ?", newUsername, user.getUsername());
            return getUserByUsername(newUsername);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
        }
        return null;
    }

    public User changePassword(User user, String newPassword) {
        try {
            if (!checkUserExists(user.getUsername()))
                return null;
            user.setPassword(passwordEncoder.encode(newPassword));
            jdbcTemplate.update("UPDATE \"user\" SET \"password\" = ? WHERE user_name = ?", user.getPassword(), user.getUsername());
            return getUserByUsername(user.getUsername());
        } catch (DataAccessException e) {
            log.error(e.getMessage());
        }
        return null;
    }

    public User getUserByID(int id) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM \"user\" WHERE id = ?", new UserMapper(), id);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public User changePfp(User user, String newPfp) {
        try {
            if (!checkUserExists(user.getUsername()))
                return null;
            jdbcTemplate.update("UPDATE \"user\" SET pfp = ? WHERE user_name = ?", newPfp, user.getUsername());
            return getUserByUsername(user.getUsername());
        } catch (DataAccessException e) {
            log.error(e.getMessage());
        }
        return null;
    }

    public boolean checkPassword(String username, String password) {
        try {
            User user = getUserByUsername(username);
            if (user == null) {
                return false;
            } else if (passwordEncoder.matches(password, user.getPassword())) {
                return true;
            } else {
                return false;
            }
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public String getUsernameByToken(String token) {
        return jwtTokenUtil.extractUsername(token);
    }

}
