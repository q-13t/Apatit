package edu.chat.views;

import org.springframework.data.annotation.Id;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.gson.JsonObject;

import jakarta.validation.constraints.NotBlank;

public class FileView {
    @Id
    @JsonProperty("id")
    @NotBlank
    private int id;

    @JsonProperty("file_name")
    @NotBlank
    private String file_name;

    @JsonProperty("file_extension")
    @NotBlank
    private String file_extension;

    @JsonProperty("file_url")
    @NotBlank
    private String file_url;

    @JsonCreator
    public FileView(@JsonProperty("id") int id, @JsonProperty("file_name") String file_name, @JsonProperty("file_extension") String file_extension, @JsonProperty("file_url") String file_url) {
        this.id = id;
        this.file_name = file_name;
        this.file_extension = file_extension;
        this.file_url = file_url;
    }

    public FileView() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFile_name() {
        return file_name;
    }

    public void setFile_name(String file_name) {
        this.file_name = file_name;
    }

    public String getFile_extension() {
        return file_extension;
    }

    public void setFile_extension(String file_extension) {
        this.file_extension = file_extension;
    }

    public String getFile_url() {
        return file_url;
    }

    public void setFile_url(String file_url) {
        this.file_url = file_url;
    }

    @Override
    public String toString() {
        return "FileView [id=" + id + ", file_name=" + file_name + ", file_type=" + file_extension + ", file_url=" + file_url + "]";
    }

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.addProperty("id", id);
        json.addProperty("file_name", file_name);
        json.addProperty("file_extension", file_extension);
        json.addProperty("file_url", file_url);
        return json;
    }
}
