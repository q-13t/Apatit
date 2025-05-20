package edu.chat.utils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import edu.chat.Exceptions.InvalidFileException;

@Service
public class FileOperator {
    private static Logger log = Logger.getLogger(FileOperator.class.getName());
    private static File root = new File("src/main/resources/files/");

    public byte[] getFile(String path) throws InvalidFileException, IOException {
        // log.info("Absolute Path: " + root.getAbsolutePath());
        if (!root.exists()) {
            root.mkdir();
        }
        return Files.readAllBytes(Paths.get(root.getAbsolutePath(), path));
    }

    public void storeFile(File file) throws IOException {
        // file.createNewFile();

    }
}
