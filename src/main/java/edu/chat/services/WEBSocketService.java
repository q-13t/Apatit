package edu.chat.services;

import java.io.IOException;
import java.util.Base64;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import edu.chat.Exceptions.InvalidFileException;
import edu.chat.Exceptions.InvalidTokenException;
import edu.chat.Exceptions.InvalidUserNameException;
import edu.chat.Exceptions.UserNotFoundException;
import edu.chat.routes.ChatRoutes;
import edu.chat.routes.UserRoutes;
import edu.chat.utils.FileOperator;
import edu.chat.views.Chat;
import edu.chat.views.User;
import edu.chat.views.enums.WEBSocketRequestType;

@Service
public class WEBSocketService {
    @SuppressWarnings("unused")
    private Logger log = LogManager.getLogger(WEBSocketService.class.getName());

    @Autowired
    private UserRoutes userRoutes;

    @Autowired
    private ChatRoutes chatRoutes;

    public JsonObject prepareGetUsersByUsernameResponse(WEBSocketRequestType requestType, JsonObject request, String token) throws UserNotFoundException, InvalidUserNameException, InvalidTokenException {
        JsonObject response = new JsonObject();
        response.addProperty("type", requestType.toString());
        String searchUsername = request.get("username").getAsString();
        int offset = request.get("offset").getAsInt();
        int limit = request.get("limit").getAsInt();
        String callerUsername = userRoutes.getUsernameByToken(token);
        if (searchUsername == null) {
            throw new InvalidUserNameException();
        }
        List<User> usersByUsername = userRoutes.getUsersByUsernamePaginated(searchUsername, offset, limit);
        usersByUsername.removeIf(user -> user.getUsername().equals(callerUsername));
        JsonArray list = new JsonArray();
        if (usersByUsername != null && !usersByUsername.isEmpty()) {
            for (User user : usersByUsername) {
                JsonObject userJson = new JsonObject();
                userJson.addProperty("id", user.getId());
                userJson.addProperty("username", user.getUsername());
                userJson.addProperty("pfp_uuid", user.getPfpUUID());
                list.add(userJson);
            }
        }
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
        String pfpUUID = user.getPfpUUID();
        String payload;
        if (pfpUUID != null && pfpUUID != "") {
            payload = Base64.getEncoder().encodeToString(FileOperator.getFile(pfpUUID));
        } else {
            payload = "null";
        }
        response.addProperty("bytes", payload);
        response.addProperty("username", searchUsername);
        return response;
    }

    public JsonObject prepareNewChatPrivateResponse(WEBSocketRequestType requestType, JsonObject asJsonObject) {
        JsonObject response = new JsonObject();
        response.addProperty("type", requestType.toString());
        if (chatRoutes.createChatPrivate(userRoutes.getUserByID(asJsonObject.get("user1").getAsInt()), userRoutes.getUserByID(asJsonObject.get("user2").getAsInt()))) {
            response.addProperty("success", true);
        } else {
            response.addProperty("success", false);
        }
        return response;
    }

    // JsonObject response = new JsonObject();
    // response.addProperty("type", requestType.toString());
    // return response;

    public JsonObject prepareSendMessageResponse(WEBSocketRequestType requestType, JsonObject asJsonObject) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'prepareSendMessageResponse'");
    }

    public JsonObject prepareGetChatsResponse(WEBSocketRequestType requestType, JsonObject asJsonObject, String token) {
        JsonObject response = new JsonObject();
        response.addProperty("type", requestType.toString());

        String username = userRoutes.getUsernameByToken(token);
        int user_id = userRoutes.getUserByUsername(username).getId();
        int offset = asJsonObject.get("offset").getAsInt();
        int limit = asJsonObject.get("limit").getAsInt();
        List<Chat> chats = chatRoutes.getChats(user_id, offset, limit);
        JsonArray list = new JsonArray();
        if (chats != null && !chats.isEmpty()) {
            for (Chat chat : chats) {
                list.add(chat.toJson());
            }
        }
        response.add("chats", list);
        return response;
    }
}
