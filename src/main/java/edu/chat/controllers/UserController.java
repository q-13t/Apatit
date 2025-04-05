package edu.chat.controllers;

import javax.validation.Valid;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import edu.chat.services.UserService;
import edu.chat.utils.JWTUtil;
import edu.chat.views.User;

@RestController
@RequestMapping(value = "/user")
public class UserController {
    Logger log = Logger.getLogger(UserController.class.getName());

    @Autowired
    private UserService userService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JWTUtil jwtTokenUtil;

    UserController() {
    }

    private String authenticate(User user) {
        try {
            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(user.getUsername(), user.getPassword()));
        } catch (Exception e) {
            throw null;
        }
        String token = jwtTokenUtil.generateToken(user);
        return token;

    }

    @RequestMapping(name = "login", value = "/login", method = RequestMethod.POST)
    public ResponseEntity<String> login(@Valid @RequestBody User user, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            StringBuilder errorMessage = new StringBuilder();
            for (ObjectError error : bindingResult.getAllErrors()) {
                errorMessage.append(error.getDefaultMessage()).append(" ");
            }
            return ResponseEntity.badRequest().body(errorMessage.toString());
        } else {
            String token = authenticate(user);
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
