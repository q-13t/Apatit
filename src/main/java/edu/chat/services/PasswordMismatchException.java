package edu.chat.services;

public class PasswordMismatchException extends Exception {
    private static final long serialVersionUID = 6L;

    public PasswordMismatchException() {
        super("Password mismatch");
    }

    public PasswordMismatchException(String message) {
        super(message);
    }

    public PasswordMismatchException(String message, Throwable cause) {
        super(message, cause);
    }

    public PasswordMismatchException(Throwable cause) {
        super(cause);
    }
}
