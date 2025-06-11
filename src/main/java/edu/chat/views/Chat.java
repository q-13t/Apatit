package edu.chat.views;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.gson.JsonObject;

public class Chat {

    @JsonProperty("id")
    private int id;

    @JsonProperty("type")
    private String type;

    @JsonProperty("name")
    private String name;

    @JsonProperty("pfp_uuid")
    private String pfp;

    @JsonProperty("lastMessage")
    private String lastMessage;

    @JsonCreator
    public Chat(@JsonProperty("id") int id, @JsonProperty("type") String type, @JsonProperty("name") String name, @JsonProperty("pfp_uuid") String pfp, @JsonProperty("lastMessage") String lastMessage) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.pfp = pfp;
        this.lastMessage = lastMessage;
    }

    public Chat() {
        // TODO Auto-generated constructor stub
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("id", id);
        json.addProperty("type", type.toString());
        json.addProperty("name", name);
        json.addProperty("pfp", pfp);
        json.addProperty("lastMessage", lastMessage);
        return json;
    }

    @Override
    public String toString() {
        return "Chat [id=" + id + ", type=" + type + ", name=" + name + ", pfp=" + pfp + ", lastMessage=" + lastMessage + "]";
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPfp() {
        return pfp;
    }

    public void setPfp(String pfp) {
        this.pfp = pfp;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

}
