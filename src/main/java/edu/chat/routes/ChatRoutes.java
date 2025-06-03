package edu.chat.routes;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.antlr.v4.runtime.misc.Pair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
        chat.setType(rs.getString("type"));
        chat.setName(rs.getString("name"));
        chat.setPfp(rs.getString("pfp"));
        return chat;
    }
}

@Service
public class ChatRoutes {
    private Logger log = LogManager.getLogger(ChatRoutes.class.getName());

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
            List<Chat> chats = jdbcTemplate.query("SELECT * FROM chat WHERE id IN (SELECT chat_id FROM participants WHERE user_id = ?) LIMIT ? OFFSET ?", new ChatMapper(), user_id, limit, offset);
            for (Chat chat : chats) {
                try {
                    String type = jdbcTemplate.queryForObject("SELECT type FROM messages WHERE chat_id = ? ORDER BY time_stamp DESC LIMIT 1", String.class, chat.getId());
                    if (type == null) {
                        type = "Text";
                    }
                    chat.setType(type);
                    if (type.equals("Text")) {
                        chat.setLastMessage(jdbcTemplate.queryForObject("SELECT message FROM messages WHERE chat_id = ? ORDER BY time_stamp DESC LIMIT 1", String.class, chat.getId()));
                    } else {
                        chat.setLastMessage(type);
                    }
                } catch (DataAccessException e) {
                    chat.setLastMessage("");
                }
            }
            return chats;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
        }
    }

    public Pair<Integer, String> createChatPrivate(User user1, User user2) {
        try {
            String name = user1.getUsername() + " - " + user2.getUsername();
            Integer id = null;
            try {
                id = jdbcTemplate.queryForObject("SELECT id FROM chat WHERE name = ?", Integer.class, name);
            } catch (Exception e) {
            }

            if (id == null) {
                id = jdbcTemplate.queryForObject("INSERT INTO chat (type, name) VALUES (?,?) RETURNING id", Integer.class, ChatType.PRIVATE.toString(), name);
                if (jdbcTemplate.update("INSERT INTO participants (chat_id, user_id) VALUES (?, ?), (?, ?)", id, user1.getId(), id, user2.getId()) == 2) {
                    return new Pair<Integer, String>(id, name);
                } else {
                    jdbcTemplate.update("DELETE FROM chat WHERE id = ?", id);
                    return null;
                }
            }
            return new Pair<Integer, String>(id, name);
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return null;
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
            Integer id = jdbcTemplate.queryForObject("SELECT id FROM chat WHERE name = ?", Integer.class, name);
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
            Integer id = jdbcTemplate.queryForObject("SELECT id FROM chat WHERE name = ?", Integer.class, name);
            jdbcTemplate.update("DELETE FROM chat WHERE id = ?", id);
            return true;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }

    public void deleteChat(int chat_id) {
        try {

            if (jdbcTemplate.update("DELETE FROM participants WHERE chat_id = ?", chat_id) > 0) {
                jdbcTemplate.update("DELETE FROM chat WHERE id = ?", chat_id);
            }

        } catch (DataAccessException e) {
            log.error(e.getMessage());
        }
    }

    public boolean addMessage(String text, String timeStamp, int user_id, int chat_id, String status, String file_uuid, String type) {
        try {
            return jdbcTemplate.update("INSERT INTO message(text, time_stamp, user_id, chat_id, status, file_uuid, type)VALUES ( ?, ?, ?, ?, ?, ?, ?);", text, java.sql.Timestamp.valueOf(timeStamp), user_id, chat_id, status, file_uuid, type) == 1;
        } catch (DataAccessException e) {
            log.error(e.getMessage());
            return false;
        }
    }
}
