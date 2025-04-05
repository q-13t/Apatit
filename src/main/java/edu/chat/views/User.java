package edu.chat.views;

import org.hibernate.validator.constraints.NotBlank;
import org.springframework.data.annotation.Id;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

public class User {

    @Id
    @JsonProperty("id")
    private int id;

    @JsonProperty("username")
    @NotBlank(message = "Username is required")
    private String username;

    @JsonProperty("password")
    @NotBlank(message = "Password is required")
    private String password;

    @JsonProperty("pfp")
    private int pfp;

    public User() {
    }

    @JsonCreator
    public User(@JsonProperty("id") int id, @JsonProperty("username") String username, @JsonProperty("password") String password, @JsonProperty("pfp") int pfp) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.pfp = pfp;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getPfp() {
        return pfp;
    }

    public void setPfp(int pfp) {
        this.pfp = pfp;
    }

    @Override
    public String toString() {
        return "ChatUser [id=" + id + ", username=" + username + ", password=" + password + ", pfp=" + pfp + "]";
    }

}
