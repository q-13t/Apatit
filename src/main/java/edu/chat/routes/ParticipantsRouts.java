package edu.chat.routes;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.jdbc.core.RowMapper;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import edu.chat.views.Participant;
import edu.chat.views.User;

class ParticipantMapper implements RowMapper<Participant> {
    @Override
    public Participant mapRow(ResultSet rs, int rowNum) throws SQLException {
        return new Participant(rs.getInt("id"), rs.getInt("user_id"), rs.getInt("chat_id"));
    }
}

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

    public boolean addParticipant(int chat_id, int user_id) {
        try {
            jdbcTemplate.update("INSERT INTO participants(chat_id, user_id) VALUES (?, ?)", chat_id, user_id);
            return true;
        } catch (Exception e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public boolean removeParticipant(int chat_id, int user_id) {
        try {
            jdbcTemplate.update("DELETE FROM participants WHERE chat_id = ? AND user_id = ?", chat_id, user_id);
            return true;
        } catch (Exception e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public List<User> getNParticipants(int chat_id, int offset, int limit) {
        try {
            return jdbcTemplate.query("SELECT * FROM \"user\" u  INNER JOIN participants p ON u.id = p.user_id WHERE chat_id = ? LIMIT ? OFFSET ?", new UserMapper(), chat_id, limit, offset);
        } catch (Exception e) {
            return null;
        }
    }

}
