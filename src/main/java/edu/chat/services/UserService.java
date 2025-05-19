package edu.chat.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import edu.chat.Exceptions.ExpiredTokenException;
import edu.chat.Exceptions.InvalidPasswordException;
import edu.chat.Exceptions.InvalidTokenException;
import edu.chat.Exceptions.UserDoesNotExistException;
import edu.chat.Exceptions.UserExistsException;
import edu.chat.Exceptions.UserInvalidException;
import edu.chat.routes.UserRoutes;
import edu.chat.views.User;

@Service
public class UserService {

    @Autowired
    private UserRoutes userRoutes;
    @Autowired
    private PasswordEncoder passwordEncoder;

    public ResponseEntity<String> authenticate(User user) throws UserInvalidException, InvalidPasswordException, UserDoesNotExistException {
        if (!userRoutes.checkUserExists(user.getUsername())) {
            throw new UserDoesNotExistException();
        } else if (!userRoutes.checkPassword(user.getUsername(), user.getPassword())) {
            throw new InvalidPasswordException();
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        String token = userRoutes.authenticate(user);
        if (token == null) {
            throw new UserInvalidException();
        }
        JsonObject json = new JsonObject();
        json.addProperty("token", token);
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(json.toString());
    }

    public ResponseEntity<String> registerUser(User user) throws UserInvalidException, UserExistsException {
        if (userRoutes.addUser(user)) {
            String token = userRoutes.authenticate(user);
            if (token == null) {
                throw new UserInvalidException();
            }
            JsonObject json = new JsonObject();
            json.addProperty("token", token);
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(json.toString());
        } else {
            throw new UserExistsException();
        }
    }

    public ResponseEntity<String> changeUsername(String body) throws UserDoesNotExistException {
        JsonObject map = new Gson().fromJson(body, JsonObject.class);
        String username = map.get("username").toString();
        String newUsername = map.get("newUsername").toString();
        User user = userRoutes.changeUsername(userRoutes.getUserByUsername(username), newUsername);
        if (user != null) {
            JsonObject json = new JsonObject();
            json.addProperty("id", user.getId());
            json.addProperty("username", user.getUsername());
            json.addProperty("pfp", user.getPfp());
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(json.toString());
        }
        throw new UserDoesNotExistException();
    }

    public ResponseEntity<String> changePassword(String body) throws PasswordMismatchException, UserDoesNotExistException {
        JsonObject map = new Gson().fromJson(body, JsonObject.class);
        String username = map.get("username").toString();
        String old_password = map.get("old_password").toString();
        String new_password = map.get("new_password").toString();
        User user = userRoutes.getUserByUsername(username);
        if (user != null) {
            if (passwordEncoder.matches(old_password, user.getPassword())) {
                user.setPassword(passwordEncoder.encode(new_password));
                User userDB = userRoutes.changePassword(user, new_password);
                if (userDB != null) {
                    JsonObject json = new JsonObject();
                    json.addProperty("id", userDB.getId());
                    json.addProperty("username", userDB.getUsername());
                    json.addProperty("pfp", userDB.getPfp());
                    return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(json.toString());
                }
            } else {
                throw new PasswordMismatchException();
            }
        }
        throw new UserDoesNotExistException();
    }

    public ResponseEntity<String> changePfp(String body) throws UserDoesNotExistException {
        JsonObject map = new Gson().fromJson(body, JsonObject.class);
        String username = map.get("username").toString();
        String pfp = map.get("pfp").toString();
        User user = userRoutes.changePfp(userRoutes.getUserByUsername(username), pfp);
        if (user != null) {
            JsonObject json = new JsonObject();
            json.addProperty("id", user.getId());
            json.addProperty("username", user.getUsername());
            json.addProperty("pfp", user.getPfp());
            return ResponseEntity.ok().body(json.toString());
        }
        throw new UserDoesNotExistException();
    }

    public ResponseEntity<String> getUserByUsername(String username) throws UserDoesNotExistException {
        User user = userRoutes.getUserByUsername(username);
        if (user != null) {
            JsonObject json = new JsonObject();
            json.addProperty("id", user.getId());
            json.addProperty("username", user.getUsername());
            json.addProperty("pfp", user.getPfp());
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(json.toString());
        }
        throw new UserDoesNotExistException();
    }

    public ResponseEntity<String> getUsers(String username) {
        List<User> users = userRoutes.getUsersByUsername(username);
        JsonArray list = new JsonArray();
        if (users != null) {
            for (User user : users) {
                JsonObject json = new JsonObject();
                json.addProperty("id", user.getId());
                json.addProperty("username", user.getUsername());
                json.addProperty("pfp", user.getPfp());
                list.add(json);
            }
        }
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(new Gson().toJson(list));
    }

    public void validateToken(String data) throws InvalidTokenException, ExpiredTokenException, UserDoesNotExistException {
        JsonObject map = new Gson().fromJson(data, JsonObject.class);
        String token = map.get("token").toString();
        userRoutes.validateToken(token);
    }
}