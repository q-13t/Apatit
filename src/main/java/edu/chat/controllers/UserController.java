package edu.chat.controllers;

import java.util.List;

import javax.validation.Valid;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import edu.chat.services.UserService;
import edu.chat.views.User;

@RestController
@RequestMapping(value = "/user")
public class UserController {

    Logger log = Logger.getLogger(UserController.class.getName());

    @Autowired
    private UserService userService;

    public UserController() {
    }

    @Autowired
    private PasswordEncoder passwordEncoder;

    // TODO: Return the WEBSOCKET TOKEN
    @RequestMapping(name = "login", value = "/login", method = RequestMethod.POST)
    public ResponseEntity<String> login(@Valid @RequestBody User user, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            StringBuilder errorMessage = new StringBuilder();
            for (ObjectError error : bindingResult.getAllErrors()) {
                errorMessage.append(error.getDefaultMessage()).append(" ");
            }
            return ResponseEntity.badRequest().body(errorMessage.toString());
        } else {
            if (!userService.checkUserExists(user.getUsername())) {
                return ResponseEntity.badRequest().body("User does not exist");
            }
            user.setPassword(passwordEncoder.encode(user.getPassword()));
            String token = userService.authenticate(user);
            if (token == null) {
                return ResponseEntity.badRequest().body("User Invalid");
            }
            return ResponseEntity.ok().body(token);
        }
    }

    @RequestMapping(name = "register", value = "/register", method = RequestMethod.POST)
    public ResponseEntity<String> register(@Valid @RequestBody User user, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            StringBuilder errorMessage = new StringBuilder();
            for (ObjectError error : bindingResult.getAllErrors()) {
                errorMessage.append(error.getDefaultMessage()).append(" ");
            }
            return ResponseEntity.badRequest().body(errorMessage.toString());
        }
        if (userService.addUser(user)) {
            String token = userService.authenticate(user);
            if (token == null) {
                return ResponseEntity.badRequest().body("User Invalid");
            }
            return ResponseEntity.ok().body(token);
        } else {
            return ResponseEntity.badRequest().body("User already exists");
        }
    }

    @RequestMapping(name = "changeUsername", value = "/changeUsername", method = RequestMethod.PATCH)
    public ResponseEntity<String> changeUsername(@RequestBody String body) {
        JsonObject map = new Gson().fromJson(body, JsonObject.class);
        String username = map.get("username").getAsString();
        String newUsername = map.get("newUsername").getAsString();
        User user = userService.changeUsername(userService.getUserByUsername(username), newUsername);
        if (user != null) {
            JsonObject json = new JsonObject();
            json.addProperty("id", user.getId());
            json.addProperty("username", user.getUsername());
            json.addProperty("pfp", user.getPfp());
            return ResponseEntity.ok().body(json.toString());
        }
        return ResponseEntity.badRequest().body("User does not exist");
    }

    @RequestMapping(name = "changePassword", value = "/changePassword", method = RequestMethod.PATCH)
    public ResponseEntity<String> changePassword(@RequestBody String body) {
        JsonObject map = new Gson().fromJson(body, JsonObject.class);
        String username = map.get("username").getAsString();
        String old_password = map.get("old_password").getAsString();
        String new_password = map.get("new_password").getAsString();
        User user = userService.getUserByUsername(username);
        if (user != null) {
            if (passwordEncoder.matches(old_password, user.getPassword())) {
                user.setPassword(passwordEncoder.encode(new_password));
                User userDB = userService.changePassword(user, new_password);
                if (userDB != null) {
                    JsonObject json = new JsonObject();
                    json.addProperty("id", userDB.getId());
                    json.addProperty("username", userDB.getUsername());
                    json.addProperty("pfp", userDB.getPfp());
                    return ResponseEntity.ok().body(json.toString());
                }
            } else {
                return ResponseEntity.badRequest().body("Old password does not match");
            }
        }
        return ResponseEntity.badRequest().body("User does not exist");
    }

    @RequestMapping(name = "changePfp", value = "/changePfp", method = RequestMethod.PATCH)
    public ResponseEntity<String> changePfp(@RequestBody String body) {
        JsonObject map = new Gson().fromJson(body, JsonObject.class);
        String username = map.get("username").getAsString();
        String pfp = map.get("pfp").getAsString();
        User user = userService.changePfp(userService.getUserByUsername(username), pfp);
        if (user != null) {
            JsonObject json = new JsonObject();
            json.addProperty("id", user.getId());
            json.addProperty("username", user.getUsername());
            json.addProperty("pfp", user.getPfp());
            return ResponseEntity.ok().body(json.toString());
        }
        return ResponseEntity.badRequest().body("User does not exist");
    }

    @RequestMapping(name = "getUser", value = "/getUser{username}", method = RequestMethod.GET)
    public ResponseEntity<String> getUser(@RequestParam String username) {
        User user = userService.getUserByUsername(username);
        if (user != null) {
            JsonObject json = new JsonObject();
            json.addProperty("id", user.getId());
            json.addProperty("username", user.getUsername());
            json.addProperty("pfp", user.getPfp());
            return ResponseEntity.ok().body(json.toString());
        }
        return ResponseEntity.badRequest().body("User does not exist");
    }

    @RequestMapping(name = "getUsers", value = "/getUsers{username}", method = RequestMethod.GET)
    public ResponseEntity<String> getUsers(@RequestParam String username) {
        List<User> users = userService.getUsersByUsername(username);
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
        return ResponseEntity.ok().body(new Gson().toJson(list));
    }
}
