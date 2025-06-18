package edu.chat.services;

import java.io.IOException;
import java.util.Base64;
import java.util.List;

import org.antlr.v4.runtime.misc.Pair;
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
import edu.chat.routes.MessageRoutes;
import edu.chat.routes.ParticipantsRouts;
import edu.chat.routes.UserRoutes;
import edu.chat.utils.FileOperator;
import edu.chat.views.Chat;
import edu.chat.views.Message;
import edu.chat.views.User;
import edu.chat.views.enums.WEBSocketRequestType;

@Service
public class WEBSocketService {
    @SuppressWarnings("unused")
    private Logger log = LogManager.getLogger(WEBSocketService.class.getName());

    @Autowired
    private MessageService messageService;

    @Autowired
    private UserRoutes userRoutes;

    @Autowired
    private ChatRoutes chatRoutes;

    @Autowired
    private MessageRoutes messageRoutes;

    @Autowired
    private FileOperator fileOperator;

    @Autowired
    private ParticipantsRouts participantsRouts;

    // WEBSocketService(MessageService messageService) {
    // this.messageService = messageService;
    // }

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
            payload = Base64.getEncoder().encodeToString(fileOperator.getFile(pfpUUID));
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
        Pair<Integer, String> id = chatRoutes.createChatPrivate(userRoutes.getUserByID(asJsonObject.get("user1").getAsInt()), userRoutes.getUserByID(asJsonObject.get("user2").getAsInt()));
        if (id == null) {
            response.addProperty("chat_id", -1);
            response.addProperty("name", "");
            return response;
        }
        response.addProperty("chat_id", id.a);
        response.addProperty("name", id.b);
        return response;
    }

    // JsonObject response = new JsonObject();
    // response.addProperty("type", requestType.toString());
    // return response;

    public int prepareSendMessageResponse(WEBSocketRequestType requestType, JsonObject asJsonObject) {
        String message = asJsonObject.toString();
        log.debug(message);
        return messageService.addMessage(message);
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

    public JsonObject prepareDeleteChatResponse(WEBSocketRequestType requestType, JsonObject data) {
        JsonObject response = new JsonObject();

        int chat_id = data.get("chat_id").getAsInt();
        chatRoutes.deleteChat(chat_id);

        response.addProperty("type", requestType.toString());
        return response;
    }

    public JsonObject prepareGetMessagesResponse(WEBSocketRequestType requestType, JsonObject data) {
        JsonObject response = new JsonObject();
        response.addProperty("type", requestType.toString());
        int chat_id = data.get("chat_id").getAsInt();
        int offset = data.get("offset").getAsInt();
        int limit = data.get("limit").getAsInt();
        List<Message> messages = messageRoutes.getMessages(chat_id, offset, limit);
        JsonArray list = new JsonArray();
        if (messages != null && !messages.isEmpty()) {
            for (Message message : messages) {
                list.add(message.toJson());
            }
        }
        response.add("messages", list);
        return response;
    }

    public boolean prepareUpdateMessageResponse(WEBSocketRequestType requestType, JsonObject data) {
        String message = data.toString();
        log.debug(message);
        messageService.updateMessage(message);
        return true;
    }

    public JsonObject prepareGetParticipantsResponse(WEBSocketRequestType requestType, JsonObject data) {
        JsonObject response = new JsonObject();

        int chat_id = data.get("chat_id").getAsInt();
        int offset = data.get("offset").getAsInt();
        int limit = data.get("limit").getAsInt();

        List<User> users = participantsRouts.getNParticipants(chat_id, offset, limit);
        JsonArray list = new JsonArray();
        if (users != null && !users.isEmpty()) {
            for (User user : users) {
                list.add(user.toJson());
            }
        }
        response.add("participants", list);

        response.addProperty("type", requestType.toString());
        return response;
    }
}
