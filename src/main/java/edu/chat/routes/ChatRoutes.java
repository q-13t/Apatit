package edu.chat.routes;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import edu.chat.views.Chat;
import edu.chat.views.User;
import edu.chat.views.enums.ChatType;

class ChatMapper implements RowMapper<Chat> {

    @Override
    public Chat mapRow(ResultSet rs, int rowNum) throws SQLException {
        Chat chat = new Chat();
        chat.setId(rs.getInt("id"));
        chat.setType(ChatType.valueOf(rs.getString("type")));
        return chat;
    }
}

@Service
public class ChatRoutes {
    private Logger log = Logger.getLogger(ChatRoutes.class.getName());

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Chat getChat(int id) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM chat WHERE id = ?", new ChatMapper(), id);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public List<Chat> getChats(int user_id, int offset, int limit) {
        try {
            return jdbcTemplate.query("SELECT * FROM chat WHERE id IN (SELECT chat_id FROM participants WHERE user_id = ?) LIMIT ? OFFSET ?", new ChatMapper(), user_id, limit, offset);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public boolean createChatPrivate(User user1, User user2) {
        try {
            String name = user1.getUsername() + " - " + user2.getUsername();
            jdbcTemplate.update("INSERT INTO chat (type, name) VALUES (?,?)", ChatType.PRIVATE.toString(), name);
            int id = jdbcTemplate.queryForObject("SELECT id FROM chat WHERE name = ?", Integer.class, name);
            jdbcTemplate.update("INSERT INTO participants (chat_id, user_id) VALUES (?, ?), (?, ?)", id, user1.getId(), id, user2.getId());
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public boolean rename(int id, String new_name) {
        try {
            jdbcTemplate.update("UPDATE chat SET name = ? WHERE id = ?", new_name, id);
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public boolean createChatGroup(ArrayList<User> users, String name) {
        try {
            jdbcTemplate.update("INSERT INTO chat (type,name) VALUES ( ?,?)", ChatType.PRIVATE, name);
            int id = jdbcTemplate.queryForObject("SELECT id FROM chat WHERE name = ?", Integer.class, name);
            for (User user : users) {
                jdbcTemplate.update("INSERT INTO participants (chat_id, user_id) VALUES (?, ?)", id, user.getId());
            }
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public boolean delete(int id) {
        try {
            jdbcTemplate.update("DELETE FROM participants WHERE chat_id = ?", id);
            jdbcTemplate.update("DELETE FROM chat WHERE id = ?", id);
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public boolean delete(String name) {
        try {
            int id = jdbcTemplate.queryForObject("SELECT id FROM chat WHERE name = ?", Integer.class, name);
            jdbcTemplate.update("DELETE FROM chat WHERE id = ?", id);
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }
}
