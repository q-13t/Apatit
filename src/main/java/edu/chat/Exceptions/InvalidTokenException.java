package edu.chat.Exceptions;

public class InvalidTokenException extends Exception {
    private static final long serialVersionUID = 2L;

    public InvalidTokenException() {
        super("Token is invalid");
    }

    public InvalidTokenException(String message, Throwable cause) {
        super(message, cause);
    }

    public InvalidTokenException(Throwable cause) {
        super(cause);
    }
}
