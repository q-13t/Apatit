package edu.chat.utils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import edu.chat.Exceptions.InvalidFileException;

@Service
public class FileOperator {
    @SuppressWarnings("unused")
    private static Logger log = LogManager.getLogger(FileOperator.class.getName());
    private static File root = new File("src/main/resources/files/");

    public static byte[] getFile(String uuid) throws InvalidFileException, IOException {
        // log.info("Absolute Path: " + root.getAbsolutePath());
        if (!root.exists()) {
            root.mkdir();
            throw new FileNotFoundException();
        }
        byte[] allBytes = Files.readAllBytes(Paths.get(root.getAbsolutePath(), uuid));
        log.info("File Size: " + allBytes.length);
        return allBytes;
    }

    public static boolean storeFile(MultipartFile file) throws IOException, InvalidFileException {
        if (!root.exists()) {
            root.mkdir();
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
