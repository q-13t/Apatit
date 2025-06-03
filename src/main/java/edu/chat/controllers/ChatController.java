package edu.chat.controllers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import edu.chat.services.ChatService;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Controller
@RequestMapping("/chat")
public class ChatController {
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

    @PutMapping("/message")
    public ResponseEntity<String> putMessage(@RequestBody String message) {
        try {
            log.info(message);
            return chatService.addMessage(message);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }
}
