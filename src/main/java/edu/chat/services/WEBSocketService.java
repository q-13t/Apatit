package edu.chat.services;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import edu.chat.Exceptions.InvalidTokenException;
import edu.chat.Exceptions.InvalidUserNameException;
import edu.chat.Exceptions.UserNotFoundException;
import edu.chat.routes.UserRoutes;
import edu.chat.views.User;
import edu.chat.views.WEBSocketRequestType;

@Service
public class WEBSocketService {
    Logger log = Logger.getLogger(WEBSocketService.class.getName());

    @Autowired
    private UserRoutes userRoutes;

    public JsonObject prepareGetUsersByUsernameResponse(WEBSocketRequestType requestType, JsonObject request) throws UserNotFoundException, InvalidUserNameException, InvalidTokenException {
        JsonObject response = new JsonObject();
        String searchUsername = request.get("username").getAsString();
        String username = userRoutes.getUsernameByToken(request.get("token").getAsString());
        if (username == null) {
            throw new InvalidTokenException();
        }
        if (searchUsername == null) {
            throw new InvalidUserNameException();
        }
        List<User> usersByUsername = userRoutes.getUsersByUsername(searchUsername);
        if (usersByUsername == null || usersByUsername.isEmpty()) {
            throw new UserNotFoundException();
        }
        JsonArray list = new JsonArray();
        for (User user : usersByUsername) {
            JsonObject userJson = new JsonObject();
            userJson.addProperty("id", user.getId());
            userJson.addProperty("username", user.getUsername());
            list.add(userJson);
        }
        response.addProperty("type", requestType.toString());
        response.addProperty("users", list.toString());
        return response;

    }
}
