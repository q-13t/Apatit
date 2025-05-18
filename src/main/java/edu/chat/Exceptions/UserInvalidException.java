package edu.chat.Exceptions;

public class UserInvalidException extends Exception {
    private static final long serialVersionUID = 5L;

    public UserInvalidException() {
        super("Invalid user");
    }

    public UserInvalidException(String message) {
        super(message);
    }

    public UserInvalidException(String message, Throwable cause) {
        super(message, cause);
    }

    public UserInvalidException(Throwable cause) {
        super(cause);
    }
}
