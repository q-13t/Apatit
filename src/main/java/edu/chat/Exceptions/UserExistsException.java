package edu.chat.Exceptions;

public class UserExistsException extends Exception {
    private static final long serialVersionUID = 5L;

    public UserExistsException() {
        super("User already exists");
    }

    public UserExistsException(String message, Throwable cause) {
        super(message, cause);
    }

    public UserExistsException(Throwable cause) {
        super(cause);
    }

}
