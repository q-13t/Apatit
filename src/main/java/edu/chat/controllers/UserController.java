package edu.chat.controllers;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import edu.chat.services.UserService;
import edu.chat.views.User;

@RestController
@RequestMapping(value = "/user")
public class UserController {

    @Autowired
    private UserService userService;

    @RequestMapping(name = "login", value = "/login", method = RequestMethod.POST)
    public String login() {
        return "yes";
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
        userService.addUser(user);
        return ResponseEntity.ok().body("User Valid");
    }

    @RequestMapping(name = "logout", value = "/logout", method = RequestMethod.POST)
    public String logout() {
        return null;
    }

    @RequestMapping(name = "changeUsername", value = "/changeUsername", method = RequestMethod.PATCH)
    public String changeUsername() {
        return null;
    }

    @RequestMapping(name = "changePassword", value = "/changePassword", method = RequestMethod.PATCH)
    public String changePassword() {
        return null;
    }

    @RequestMapping(name = "changePfp", value = "/changePfp", method = RequestMethod.PATCH)
    public String changePfp() {
        return null;
    }

    @RequestMapping(name = "getUser", value = "/getUser", method = RequestMethod.GET)
    public String getUser() {
        return "no";
    }

    @RequestMapping(name = "getUsers", value = "/getUsers", method = RequestMethod.GET)
    public String getUsers() {
        return null;
    }
}
