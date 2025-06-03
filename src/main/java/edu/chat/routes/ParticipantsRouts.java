package edu.chat.routes;

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class ParticipantsRouts {
    private Logger log = LogManager.getLogger(ParticipantsRouts.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<Integer> getFromChat(int id) {
        try {
            return jdbcTemplate.queryForList("SELECT user_id FROM participants WHERE chat_id = ?", Integer.class, id);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return new ArrayList<>();
        }
    }
}
