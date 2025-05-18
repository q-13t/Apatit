package edu.chat.Exceptions;

public class ExpiredTokenException extends Exception {
    private static final long serialVersionUID = 3L;

    public ExpiredTokenException() {
        super("Token expired");
    }

    public ExpiredTokenException(String message, Throwable cause) {
        super(message, cause);
    }

    public ExpiredTokenException(Throwable cause) {
        super(cause);
    }
}
