package edu.chat.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.JsonObject;

import edu.chat.utils.FileOperator;

@Service
public class FileService {

    @Autowired
    FileOperator fileOperator;

    public ResponseEntity<String> performFileSave(MultipartFile file) {
        JsonObject response = new JsonObject();
        try {
            fileOperator.storeFile(file);
        } catch (Exception e) {
            response.addProperty("success", false);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response.toString());
        }
        response.addProperty("success", true);
        return ResponseEntity.ok(response.toString());
    }

    public byte[] performGetFile(String uuid) {
        try {
            return fileOperator.getFile(uuid);
        } catch (Exception e) {
            return null;
        }

    }

}
