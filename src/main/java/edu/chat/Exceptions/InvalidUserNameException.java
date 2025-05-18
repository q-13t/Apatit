package edu.chat.Exceptions;

public class InvalidUserNameException extends Exception {
    private static final long serialVersionUID = 7L;

    public InvalidUserNameException() {
        super("User name is invalid");
    }

    public InvalidUserNameException(String message, Throwable cause) {
        super(message, cause);
    }

    public InvalidUserNameException(Throwable cause) {
        super(cause);
    }
}
