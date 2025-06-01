package edu.chat.controllers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.*;
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

    @GetMapping(name = "getMe", value = "/getMe")
    public ResponseEntity<String> requestMethodName(HttpServletRequest request) {
        try {
            return userService.getMe(request.getHeader("Authorization").substring(7));
        } catch (Exception e) {
            log.error("Error during authentication: " + e.getMessage());
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).contentType(MediaType.APPLICATION_JSON).body(errorJson.toString());
        }
    }

    @PostMapping(name = "validateToken", value = "/validateToken")
    public ResponseEntity<String> validateToken() {
        // The response is ok, because filtering passed.
        return ResponseEntity.ok("Token is valid");
    }

    @PostMapping(name = "login", value = "/login")
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

    @PostMapping(name = "register", value = "/register")
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

    @PatchMapping(name = "changeUsername", value = "/changeUsername")
    public ResponseEntity<String> changeUsername(@RequestBody String body) {
        try {
            return userService.changeUsername(body);
        } catch (Exception e) {
            log.error("Error during username change: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @PatchMapping(name = "changePassword", value = "/changePassword")
    public ResponseEntity<String> changePassword(@RequestBody String body) {
        try {
            return userService.changePassword(body);
        } catch (Exception e) {
            log.error("Error during password change: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @PatchMapping(name = "changePfp", value = "/changePfp")
    public ResponseEntity<String> changePfp(@RequestBody String body) {
        try {
            return userService.changePfp(body);
        } catch (Exception e) {
            log.error("Error during profile picture change: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @GetMapping(name = "getUser", value = "/getUser{username}")
    public ResponseEntity<String> getUser(@RequestParam String username) {
        try {
            return userService.getUserByUsername(username);
        } catch (Exception e) {
            log.error("Error during user retrieval: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @GetMapping(name = "getUsers", value = "/getUsers{username}")
    public ResponseEntity<String> getUsers(@RequestParam String username) {
        try {
            return userService.getUsers(username);
        } catch (Exception e) {
            log.error("Error during user retrieval: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }
}
