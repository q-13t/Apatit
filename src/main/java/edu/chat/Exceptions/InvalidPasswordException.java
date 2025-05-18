package edu.chat.Exceptions;

public class InvalidPasswordException extends Exception {
    private static final long serialVersionUID = 4L;

    public InvalidPasswordException() {
        super("Invalid password");
    }

    public InvalidPasswordException(String message) {
        super(message);
    }

    public InvalidPasswordException(String message, Throwable cause) {
        super(message, cause);
    }

    public InvalidPasswordException(Throwable cause) {
        super(cause);
    }
}
