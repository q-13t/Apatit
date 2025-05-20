package edu.chat.Exceptions;

public class InvalidFileException extends Exception {
    private static final long serialVersionUID = 9L;

    public InvalidFileException() {
        super("File is invalid");
    }

    public InvalidFileException(String message, Throwable cause) {
        super(message, cause);
    }

    public InvalidFileException(Throwable cause) {
        super(cause);
    }
}
