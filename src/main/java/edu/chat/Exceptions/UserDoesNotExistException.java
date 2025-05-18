package edu.chat.Exceptions;

public class UserDoesNotExistException extends Exception {
    private static final long serialVersionUID = 1L;

    public UserDoesNotExistException() {
        super("User does not exist");
    }

    public UserDoesNotExistException(String message, Throwable cause) {
        super(message, cause);
    }

    public UserDoesNotExistException(Throwable cause) {
        super(cause);
    }
}
