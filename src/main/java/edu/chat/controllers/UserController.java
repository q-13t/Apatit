package edu.chat.controllers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.google.gson.JsonObject;
import edu.chat.services.UserService;
import edu.chat.views.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping(value = "/user")
public class UserController {

    private Logger log = LogManager.getLogger(UserController.class.getName());

    @Autowired
    private UserService userService;

    @RequestMapping(name = "getMe", value = "/getMe", method = RequestMethod.GET)
    public ResponseEntity<String> requestMethodName(HttpServletRequest request) {
        try {
            return userService.getMe(request.getHeader("Authorization").substring(7));
        } catch (Exception e) {
            log.error("Error during authentication: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @RequestMapping(name = "validateToken", value = "/validateToken", method = RequestMethod.POST)
    public ResponseEntity<String> requestMethodName() {
        // The response is ok, because filtering passed.
        return ResponseEntity.ok("Token is valid");
    }

    @RequestMapping(name = "login", value = "/login", method = RequestMethod.POST)
    public ResponseEntity<String> login(@Valid @RequestBody User user, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            JsonObject errorJson = new JsonObject();
            for (ObjectError error : bindingResult.getAllErrors()) {
                errorJson.addProperty("error", error.getDefaultMessage());
                break;
            }
            return ResponseEntity.badRequest().contentType(MediaType.APPLICATION_JSON).body(errorJson.toString());
        } else {
            try {
                return userService.authenticate(user);
            } catch (Exception e) {
                log.error("Error during authentication: " + e.getMessage());
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
            }

        }
    }

    @RequestMapping(name = "register", value = "/register", method = RequestMethod.POST)
    public ResponseEntity<String> register(@Valid @RequestBody User user, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            JsonObject errorJson = new JsonObject();
            for (ObjectError error : bindingResult.getAllErrors()) {
                errorJson.addProperty("error", error.getDefaultMessage());
                break;
            }
            return ResponseEntity.badRequest().contentType(MediaType.APPLICATION_JSON).body(errorJson.toString());
        }
        try {
            return userService.registerUser(user);
        } catch (Exception e) {
            log.error("Error during registration: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }

    }

    @RequestMapping(name = "changeUsername", value = "/changeUsername", method = RequestMethod.PATCH)
    public ResponseEntity<String> changeUsername(@RequestBody String body) {
        try {
            return userService.changeUsername(body);
        } catch (Exception e) {
            log.error("Error during username change: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @RequestMapping(name = "changePassword", value = "/changePassword", method = RequestMethod.PATCH)
    public ResponseEntity<String> changePassword(@RequestBody String body) {
        try {
            return userService.changePassword(body);
        } catch (Exception e) {
            log.error("Error during password change: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @RequestMapping(name = "changePfp", value = "/changePfp", method = RequestMethod.PATCH)
    public ResponseEntity<String> changePfp(@RequestBody String body) {
        try {
            return userService.changePassword(body);
        } catch (Exception e) {
            log.error("Error during profile picture change: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @RequestMapping(name = "getUser", value = "/getUser{username}", method = RequestMethod.GET)
    public ResponseEntity<String> getUser(@RequestParam String username) {
        try {
            return userService.getUserByUsername(username);
        } catch (Exception e) {
            log.error("Error during user retrieval: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @RequestMapping(name = "getUsers", value = "/getUsers{username}", method = RequestMethod.GET)
    public ResponseEntity<String> getUsers(@RequestParam String username) {
        try {
            return userService.getUsers(username);
        } catch (Exception e) {
            log.error("Error during user retrieval: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }
}
