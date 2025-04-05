package edu.chat.services;

import java.util.ArrayList;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import edu.chat.views.User;

@Service
public class UserService implements UserDetailsService {
    private Logger log = Logger.getLogger(UserService.class.getName());

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // TODO: Rewrite this to match springsecurity user getting from database
        return new org.springframework.security.core.userdetails.User("test", "test", new ArrayList<>());
    }

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

    public User getUserByUsername(String username) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'getUserByUsername'");
    }
}
