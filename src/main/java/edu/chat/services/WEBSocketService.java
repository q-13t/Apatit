package edu.chat.services;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import edu.chat.Exceptions.InvalidFileException;
import edu.chat.Exceptions.InvalidTokenException;
import edu.chat.Exceptions.InvalidUserNameException;
import edu.chat.Exceptions.UserNotFoundException;
import edu.chat.routes.FileRoutes;
import edu.chat.routes.UserRoutes;
import edu.chat.utils.FileOperator;
import edu.chat.views.FileView;
import edu.chat.views.User;
import edu.chat.views.WEBSocketRequestType;

@Service
public class WEBSocketService {
    Logger log = Logger.getLogger(WEBSocketService.class.getName());

    @Autowired
    private UserRoutes userRoutes;
    @Autowired
    private FileRoutes fileRoutes;
    @Autowired
    FileOperator fileOperator;

    public JsonObject prepareGetUsersByUsernameResponse(WEBSocketRequestType requestType, JsonObject request) throws UserNotFoundException, InvalidUserNameException, InvalidTokenException {
        JsonObject response = new JsonObject();
        String searchUsername = request.get("username").getAsString();
        int offset = request.get("offset").getAsInt();
        int limit = request.get("limit").getAsInt();
        if (searchUsername == null) {
            throw new InvalidUserNameException();
        }
        List<User> usersByUsername = userRoutes.getUsersByUsernamePaginated(searchUsername, offset, limit);
        JsonArray list = new JsonArray();
        if (usersByUsername != null && !usersByUsername.isEmpty()) {
            for (User user : usersByUsername) {
                JsonObject userJson = new JsonObject();
                userJson.addProperty("id", user.getId());
                userJson.addProperty("username", user.getUsername());
                userJson.addProperty("pfp", user.getPfp());
                list.add(userJson);
            }
        }
        response.addProperty("type", requestType.toString());
        response.add("users", list);
        return response;

    }

    public JsonObject prepareGetPFPResponse(WEBSocketRequestType requestType, JsonObject request) throws InvalidUserNameException, InvalidFileException, IOException {
        JsonObject response = new JsonObject();
        response.addProperty("type", requestType.toString());
        String searchUsername = request.get("username").getAsString();
        if (searchUsername == null) {
            throw new InvalidUserNameException();
        }
        User user = userRoutes.getUserByUsername(searchUsername);
        FileView pfp = fileRoutes.getFileByID(user.getPfp());
        String payload;
        if (pfp != null && pfp.getId() != 0) {
            payload = Base64.getEncoder().encodeToString(fileOperator.getFile(pfp.getFile_url()));
        } else {
            payload = "null";
        }
        response.addProperty("bytes", payload);
        response.addProperty("username", searchUsername);
        return response;
    }
}
