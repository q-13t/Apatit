package edu.chat.utils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import edu.chat.Exceptions.InvalidFileException;

@Service
public class FileOperator {
    @SuppressWarnings("unused")
    private static Logger log = LogManager.getLogger(FileOperator.class.getName());

    @Value("${files.root}")
    private static String rootPath;

    private static File root;

    FileOperator() {
        if (rootPath == null) {
            rootPath = "/app/files/";
        }
        root = new File(rootPath);
    }

    public static byte[] getFile(String uuid) throws InvalidFileException, IOException {
        // log.info("Absolute Path: " + root.getAbsolutePath());
        if (!root.exists()) {
            boolean res = root.mkdir();
            ;
            if (!res) {
                log.error("Root directory could not be created");
            } else {
                log.info("Root directory created");
            }
            throw new FileNotFoundException();
        }
        byte[] allBytes = Files.readAllBytes(Paths.get(root.getAbsolutePath(), uuid));
        log.info("File Size: " + allBytes.length);
        return allBytes;
    }

    public static boolean storeFile(MultipartFile file) throws IOException, InvalidFileException {
        if (!root.exists()) {
            boolean res = root.mkdir();
            if (!res) {
                log.error("Root directory could not be created");
            } else {
                log.info("Root directory created");
            }
            throw new FileNotFoundException();
        }
        log.info("Storing file: " + file.getOriginalFilename());
        file.transferTo(new File(root.getAbsolutePath(), file.getOriginalFilename()));

        return true;
    }

    public static File convertUsingTransferTo(MultipartFile file) throws IOException {
        File convertedFile = new File(file.getOriginalFilename());
        file.transferTo(convertedFile);
        return convertedFile;
    }
}
