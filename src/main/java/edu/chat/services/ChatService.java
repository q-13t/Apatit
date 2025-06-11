package edu.chat.services;

import java.util.List;
import edu.chat.routes.UserRoutes;
import edu.chat.views.Chat;
import edu.chat.views.User;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import edu.chat.routes.ChatRoutes;
import edu.chat.routes.ParticipantsRouts;

@Service
public class ChatService {

    @Autowired
    private final ChatRoutes chatRoutes;

    @SuppressWarnings("unused")
    private Logger log = LogManager.getLogger(ChatService.class.getName());

    @Autowired
    private UserRoutes userRoutes;

    @Autowired
    private ParticipantsRouts participantsRouts;

    ChatService(ChatRoutes chatRoutes) {
        this.chatRoutes = chatRoutes;
    }

    public ResponseEntity<String> getParticipants(int id) {
        JsonArray response = new JsonArray();

        List<Integer> ids = participantsRouts.getFromChat(id);
        for (Integer user_id : ids) {
            User user = userRoutes.getUserByID(user_id);
            user.setPassword(null);
            response.add(user.toJson());
        }

        return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(response.toString());
    }

    public ResponseEntity<String> changeName(String param) {
        JsonObject map = new Gson().fromJson(param, JsonObject.class);
        String chat_name = map.get("chat_name").getAsString();
        int chat_id = map.get("chat_id").getAsInt();
        if (chatRoutes.changeName(chat_id, chat_name)) {
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(param);
        } else {
            return ResponseEntity.status(400).contentType(MediaType.APPLICATION_JSON).body(param);
        }
    }

    public ResponseEntity<String> changePfp(String param) {
        JsonObject map = new Gson().fromJson(param, JsonObject.class);
        String pfp = map.get("pfp_uuid").getAsString();
        int chat_id = map.get("chat_id").getAsInt();
        if (chatRoutes.changePfp(chat_id, pfp)) {
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(param);
        } else {
            return ResponseEntity.status(400).contentType(MediaType.APPLICATION_JSON).body(param);
        }
    }

    public ResponseEntity<String> addParticipant(String param) {
        JsonObject map = new Gson().fromJson(param, JsonObject.class);
        int chat_id = map.get("chat_id").getAsInt();
        int user_id = map.get("user_id").getAsInt();
        if (participantsRouts.addParticipant(chat_id, user_id)) {

            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(param);
        } else {
            return ResponseEntity.status(400).contentType(MediaType.APPLICATION_JSON).body(param);
        }
    }

    public ResponseEntity<String> removeParticipant(String param) {
        JsonObject map = new Gson().fromJson(param, JsonObject.class);
        int chat_id = map.get("chat_id").getAsInt();
        int user_id = map.get("user_id").getAsInt();
        if (participantsRouts.removeParticipant(chat_id, user_id)) {
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(param);
        } else {
            return ResponseEntity.status(400).contentType(MediaType.APPLICATION_JSON).body(param);
        }
    }

    public Chat getByID(int asInt) {
        try {
            return chatRoutes.getChat(asInt);
        } catch (Exception e) {
            return null;
        }
    }

    public List<User> getParticipants(int chat_id, int offset, int limit) {
        try {
            return participantsRouts.getNParticipants(chat_id, offset, limit);
        } catch (Exception e) {
            return null;
        }
    }

}
