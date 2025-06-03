
package edu.chat.views;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.gson.JsonObject;

public class Message {
    @JsonProperty("id")
    private int id;
    @JsonProperty("text")
    private String text;
    @JsonProperty("time_stamp")
    private String timeStamp;
    @JsonProperty("user_id")
    private int user_id;
    @JsonProperty("chat_id")
    private int chat_id;
    @JsonProperty("status")
    private String status;
    @JsonProperty("file_uuid")
    private String file_uuid;
    @JsonProperty("type")
    private String type;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getTimeStamp() {
        return timeStamp;
    }

    public void setTimeStamp(String timeStamp) {
        this.timeStamp = timeStamp;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getFile_uuid() {
        return file_uuid;
    }

    public void setFile_uuid(String file_uuid) {
        this.file_uuid = file_uuid;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Message(@JsonProperty("id") int id, @JsonProperty("text") String text, @JsonProperty("time_stamp") String timeStamp, @JsonProperty("user_id") int user_id, @JsonProperty("chat_id") int chat_id, @JsonProperty("status") String status, @JsonProperty("file_uuid") String file_uuid, @JsonProperty("type") String type) {
        this.id = id;
        this.text = text;
        this.timeStamp = timeStamp;
        this.user_id = user_id;
        this.chat_id = chat_id;
        this.status = status;
        this.file_uuid = file_uuid;
        this.type = type;
    }

    public Message() {
    }

    @Override
    public String toString() {
        return "Message [id=" + id + ", text=" + text + ", timeStamp=" + timeStamp + ", user_id=" + user_id + ", chat_id=" + chat_id + ", status=" + status + ", file_uuid=" + file_uuid + ", type=" + type + "]";
    }

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("id", id);
        json.addProperty("text", text);
        json.addProperty("timeStamp", timeStamp);
        json.addProperty("user_id", user_id);
        json.addProperty("chat_id", chat_id);
        json.addProperty("status", status);
        json.addProperty("file_uuid", file_uuid);
        json.addProperty("type", type);
        return json;
    }
}