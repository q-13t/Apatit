package edu.chat.controllers;

import org.springframework.http.MediaType;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import edu.chat.services.FileService;

@Controller
@RequestMapping("/file")
public class FileController {
    // private Logger log = Logger.getLogger(FileController.class.getName());
    private Logger log = LogManager.getLogger(FileController.class.getName());

    @Autowired
    private FileService fileService;

    @GetMapping(produces = "application/octet-stream")
    public ResponseEntity<byte[]> getFile(@RequestParam String uuid) {
        try {
            return ResponseEntity.ok().body(fileService.performGetFile(uuid));
        } catch (Exception e) {
            log.error("Error during authentication: " + e.getMessage());
            return ResponseEntity.internalServerError().body(null);
        }
    }

    @PutMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> saveFile(@RequestPart("file") MultipartFile file) {
        try {
            return fileService.performFileSave(file);
        } catch (Exception e) {
            log.error("Error during authentication: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).contentType(MediaType.APPLICATION_JSON).body(e.getMessage());
        }
    }

}
