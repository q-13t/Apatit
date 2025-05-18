package edu.chat.Exceptions;

public class UserNotFoundException extends Exception {
    private static final long serialVersionUID = 8L;

    public UserNotFoundException() {
        super("User not found");
    }

    public UserNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }

    public UserNotFoundException(Throwable cause) {
        super(cause);
    }
}
