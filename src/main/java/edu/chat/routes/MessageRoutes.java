package edu.chat.routes;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.jdbc.core.RowMapper;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import edu.chat.views.Message;

class MessageMapper implements RowMapper<Message> {

    @Override
    public Message mapRow(ResultSet rs, int rowNum) throws SQLException {
        Message message = new Message();
        message.setId(rs.getInt("id"));
        message.setText(rs.getString("text"));
        message.setTimeStamp(rs.getString("time_stamp"));
        message.setUser_id(rs.getInt("user_id"));
        message.setChat_id(rs.getInt("chat_id"));
        message.setStatus(rs.getString("status"));
        message.setFile_uuid(rs.getString("file_uuid"));
        message.setType(rs.getString("type"));
        return message;
    }
}

@Service
public class MessageRoutes {
    @Autowired
    private JdbcTemplate jdbcTemplate;
    private Logger log = LogManager.getLogger(MessageRoutes.class.getName());

    public int addMessage(String text, String timeStamp, int user_id, int chat_id, String status, String file_uuid, String type) {
        try {
            Integer id = jdbcTemplate.queryForObject("INSERT INTO message(text, time_stamp, user_id, chat_id, status, file_uuid, type)VALUES ( ?, ?, ?, ?, ?, ?, ?) RETURNING id;", Integer.class, text, java.sql.Timestamp.valueOf(timeStamp), user_id, chat_id, status, file_uuid, type);
            if (id == null)
                return -1;
            return id;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return -1;
        }
    }

    public List<Message> getMessages(int chat_id, int offset, int limit) {
        try {
            return jdbcTemplate.query("SELECT * FROM message WHERE chat_id = ? ORDER BY time_stamp DESC LIMIT ? OFFSET ?", new MessageMapper(), chat_id, limit, offset);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public boolean updateMessage(int id, String status) {
        try {
            return jdbcTemplate.update("UPDATE message SET status = ? WHERE id = ?", status, id) == 1;
        } catch (Exception e) {
            log.error(e.getMessage());
            return false;

        }
    }
}
