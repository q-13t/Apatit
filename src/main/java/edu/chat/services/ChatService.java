package edu.chat.services;

import java.util.List;
import edu.chat.routes.UserRoutes;
import edu.chat.views.User;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.google.gson.JsonArray;
import edu.chat.routes.ParticipantsRouts;

@Service
public class ChatService {
    @SuppressWarnings("unused")
    private Logger log = LogManager.getLogger(ChatService.class.getName());
    @Autowired
    private UserRoutes userRoutes;

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

}
