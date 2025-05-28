package edu.chat.views;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.gson.JsonObject;

import edu.chat.views.enums.ChatType;

public class Chat {

    @JsonProperty("id")
    private int id;

    @JsonProperty("type")
    private ChatType type;

    @JsonProperty("name")
    private String name;

    @JsonProperty("pfp")
    private int pfp;

    @JsonCreator
    public Chat(@JsonProperty("id") int id, @JsonProperty("type") ChatType type, @JsonProperty("name") String name, @JsonProperty("pfp") int pfp) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.pfp = pfp;
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

    public ChatType getType() {
        return type;
    }

    public void setType(ChatType type) {
        this.type = type;
    }

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("id", id);
        json.addProperty("type", type.toString());
        json.addProperty("name", name);
        json.addProperty("pfp", pfp);
        return json;
    }

    @Override
    public String toString() {
        return "Chat [id=" + id + ", type=" + type + ", name=" + name + ", pfp=" + pfp + "]";
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPfp() {
        return pfp;
    }

    public void setPfp(int pfp) {
        this.pfp = pfp;
    }

}
