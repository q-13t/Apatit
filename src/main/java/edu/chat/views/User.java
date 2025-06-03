package edu.chat.views;

import org.springframework.data.annotation.Id;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.gson.JsonObject;

import jakarta.validation.constraints.NotBlank;

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

    @JsonProperty("pfpUUID")
    private String pfpUUID;

    public User() {
    }

    @JsonCreator
    public User(@JsonProperty("id") int id, @JsonProperty("username") String username, @JsonProperty("password") String password, @JsonProperty("pfpUUID") String pfpUUID) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.pfpUUID = pfpUUID;
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

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("id", id);
        json.addProperty("username", username);
        json.addProperty("password", password);
        json.addProperty("pfp_uuid", pfpUUID);
        return json;
    }

    @Override
    public String toString() {
        return "ChatUser [id=" + id + ", username=" + username + ", password=" + password + ", pfp=" + pfpUUID + "]";
    }

    public String getPfpUUID() {
        return pfpUUID;
    }

    public void setPfpUUID(String pfpUUID) {
        this.pfpUUID = pfpUUID;
    }

}
