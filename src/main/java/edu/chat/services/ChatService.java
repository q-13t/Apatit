package edu.chat.services;

import java.util.List;
import edu.chat.routes.UserRoutes;
import edu.chat.views.User;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import edu.chat.routes.ChatRoutes;
import edu.chat.routes.ParticipantsRouts;

@Service
public class ChatService {
    private Logger log = LogManager.getLogger(ChatService.class.getName());
    @Autowired
    private UserRoutes userRoutes;

    @Autowired
    private ChatRoutes chatRoutes;

    @Autowired
    private ParticipantsRouts participantsRouts;

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

    public ResponseEntity<String> addMessage(String message) {
        try {
            JsonObject map = new Gson().fromJson(message, JsonObject.class);
            String text = null;
            JsonElement texElement = map.get("text");
            if (texElement != null && !texElement.isJsonNull()) {
                text = texElement.getAsString();
            }
            String file_uuid = null;
            JsonElement uuidElement = map.get("file_uuid");
            if (uuidElement != null && !uuidElement.isJsonNull()) {
                file_uuid = uuidElement.getAsString();
            }
            String timeStamp = map.get("timeStamp").getAsString();
            int user_id = map.get("user_id").getAsInt();
            int chat_id = map.get("chat_id").getAsInt();
            String status = map.get("status").getAsString();
            String type = map.get("type").getAsString();
            if (chatRoutes.addMessage(text, timeStamp, user_id, chat_id, status, file_uuid, type)) {
                return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body("true");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body("false");
            }
        } catch (Exception e) {
            log.error("Error during message sending: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

}
