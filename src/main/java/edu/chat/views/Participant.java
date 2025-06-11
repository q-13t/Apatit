package edu.chat.views;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.gson.JsonObject;

public class Participant {
    @JsonProperty("id")
    int id;
    @JsonProperty("user_id")
    int user_id;
    @JsonProperty("chat_id")
    int chat_id;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Participant(int user_id, int chat_id) {
        this.user_id = user_id;
        this.chat_id = chat_id;
    }

    public Participant(int id, int user_id, int chat_id) {
        this.id = id;
        this.user_id = user_id;
        this.chat_id = chat_id;
    }

    public Participant() {
    }

    public int getUser_id() {
        return user_id;
    }

    public void setUser_id(int user_id) {
        this.user_id = user_id;
    }

    public int getChat_id() {
        return chat_id;
    }

    public void setChat_id(int chat_id) {
        this.chat_id = chat_id;
    }

    @Override
    public String toString() {
        return "Participant [id=" + id + ", user_id=" + user_id + ", chat_id=" + chat_id + "]";
    }

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("id", id);
        json.addProperty("user_id", user_id);
        json.addProperty("chat_id", chat_id);
        return json;
    }
}