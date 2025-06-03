package edu.chat.services;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import edu.chat.routes.MessageRoutes;

@Service
public class MessageService {
    private Logger log = LogManager.getLogger(MessageService.class.getName());

    @Autowired
    private MessageRoutes messageRoutes;

    public boolean addMessage(String message) {
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
            if (messageRoutes.addMessage(text, timeStamp, user_id, chat_id, status, file_uuid, type)) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            log.error("Error during message sending: " + e.getMessage());
            return false;
        }
    }

}
