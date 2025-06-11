package edu.chat.controllers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import edu.chat.services.ChatService;

@Controller
@RequestMapping("/chat")
public class ChatController {
    @SuppressWarnings("unused")
    private Logger log = LogManager.getLogger(ChatController.class.getName());

    @Autowired
    private ChatService chatService;

    @GetMapping("/participants")
    public ResponseEntity<String> getParticipants(@RequestParam int id) {
        try {
            return chatService.getParticipants(id);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @PatchMapping("/changeName")
    public ResponseEntity<String> changeName(@RequestBody String param) {
        try {
            return chatService.changeName(param);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @PatchMapping("/changePfp")
    public ResponseEntity<String> changePfp(@RequestBody String param) {
        try {
            return chatService.changePfp(param);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @PatchMapping("/removeParticipant")
    public ResponseEntity<String> removeParticipant(@RequestBody String param) {
        try {
            return chatService.removeParticipant(param);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

    @PatchMapping("/addParticipant")
    public ResponseEntity<String> addParticipant(@RequestBody String param) {
        try {
            return chatService.addParticipant(param);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

}
